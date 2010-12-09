include HgvMetaIdentifierHelper
class HgvMetaIdentifiersController < IdentifiersController
  layout 'site'
  before_filter :authorize
  before_filter :prune_params, :only => [:update]
  before_filter :complement_params, :only => [:update]

  def edit
    find_identifier
    @identifier.get_epidoc_attributes
  end

  def update
    find_identifier

    commit_sha = @identifier.set_epidoc(params[:hgv_meta_identifier], params[:comment])

    generate_flash_message

    save_comment(params[:comment], commit_sha)

    redirect_to polymorphic_path([@identifier.publication, @identifier],
                                 :action => :edit)
  end

  protected

    def prune_params

      if params[:hgv_meta_identifier]

        if params[:date][:master] == 'yes' #todocl: remove (date master), prune only if date master flag is set
          params[:hgv_meta_identifier]['textDate'].each_pair{|index, date|
  
            ['onDate', 'fromDate', 'toDate'].each {|dateType|
              if date['children'][dateType]
                if date['children'][dateType]['children']['century']['value'].empty? &&
                   date['children'][dateType]['children']['year']['value'].empty? &&
                   date['children'][dateType]['children']['month']['value'].empty? &&
                   date['children'][dateType]['children']['day']['value'].empty?
                  date['children'].delete dateType
                end
              end
            }

            if !date['children']['onDate'] &&
               !(date['children']['fromDate'] && date['children']['toDate'])
             params[:hgv_meta_identifier]['textDate'].delete index
            end

          }
        end #todocl: remove (date master)

        
        if params[:hgv_meta_identifier]['mentionedDate']
          params[:hgv_meta_identifier]['mentionedDate'].each_pair{|index, date|
            if date['children'] && date['children']['date'] && date['children']['date']['children'] && date['children']['date']['children']['certainty']
              date['children']['date']['children']['certainty'].each_pair{|certainty_index, certainty|
                if certainty['attributes'] && certainty['attributes']['relation'] && certainty['attributes']['relation'].empty?
                  date['children']['date']['children']['certainty'].delete certainty_index
                end
              }
            end
          }
        end

      end

    end

    def complement_params

      if params[:hgv_meta_identifier] && params[:hgv_meta_identifier]['textDate']
        params[:hgv_meta_identifier]['textDate'].each{|index, date| # foreach textDate, i.e. X, Y, Z
          
          # chronMin, chronMax and chron

          tasks = {}
          if date['children']['onDate'] && date['children']['onDate']['children']['offset']['value'].empty? # @when attribute will only be used if there is a single date
            tasks[:chron] = date['children']['onDate']
          else
            tasks[:chron] = nil
          end

          if date['children']['fromDate'] # attributes @notBefore and @notAfter will be used for single dates as well as time spans
            tasks[:chronMin] = date['children']['fromDate']
          elsif date['children']['onDate'] && (date['children']['onDate']['children']['offset']['value'] != 'before')
            tasks[:chronMin] = date['children']['onDate']
          elsif
            tasks[:chronMin] = nil
          end

          if date['children']['toDate']
            tasks[:chronMax] = date['children']['toDate']
          elsif date['children']['onDate'] && (date['children']['onDate']['children']['offset']['value'] != 'after')
            tasks[:chronMax] = date['children']['onDate']
          elsif
            tasks[:chronMax] = nil
          end

          tasks.each_pair{|chron, value|
if params[:date][:master] == 'yes' #todocl: remove (date master)
            if value
              date['attributes'][{:chron => 'textDateWhen', :chronMin => 'textDateFrom', :chronMax => 'textDateTo'}[chron]] = HgvFuzzy.getChron(
                value['children']['century']['value'],
                value['children']['year']['value'],
                value['children']['month']['value'],
                value['children']['day']['value'],
                value['children']['century']['attributes']['extent'],
                value['children']['year']['attributes']['extent'],
                value['children']['month']['attributes']['extent'],
                chron
              )
            else
              date['attributes'][{:chron => 'textDateWhen', :chronMin => 'textDateFrom', :chronMax => 'textDateTo'}[chron]] = nil
            end
end #todocl: remove (date master)
          }

          # HGV formatted date
if params[:date][:master] == 'yes' #todocl: remove (date master)
          if date['children']['onDate']
            date['value'] = HgvFormat.formatDate packDate(date['children']['onDate'])
          elsif date['children']['fromDate'] && date['children']['toDate']
            date['value'] = HgvFormat.formatDate(
              packDate(date['children']['fromDate']),
              packDate(date['children']['toDate'])
            )
          end
end #todocl: remove (date master)
          date['children'] = {} #todocl: remove this line when nesting dates into origDate and when the offset tag is allowed within EpiDoc
          #date['children'][dateType]['children'].delete 'offset' #todocl: remove this line 
          ['textDateFrom', 'textDateTo'].each{|chron| #todocl: remove this whole instruction when notBefor and notAfter will become full dates instead of only years
            if date['attributes'][chron].class == String and date['attributes'][chron].size >= 10
              date['attributes'][chron] = date['attributes'][chron][0..-7]
            end
          } 
        }
      end
    end
    
    def packDate date
      packedDate = date['children'].merge(date['attributes'])
      packedDate.each_pair{|k, v|
        if v.is_a?(Hash) && v.has_key?('value') 
          if k == 'offset'
            packedDate['offset'] = v['value']
          elsif v.has_key?('attributes')
            packedDate[k] = v['attributes'].merge({'value' => v['value']})
          end
        end
      }
    end

    def generate_flash_message
      flash[:notice] = "File updated."
      if %w{new editing}.include? @identifier.publication.status
        flash[:notice] += " Go to the <a href='#{url_for(@identifier.publication)}'>publication overview</a> if you would like to submit."
      end      
    end

    def save_comment (comment, commit_sha)
      if comment != nil && comment.strip != ""
        @comment = Comment.new( {:git_hash => commit_sha, :user_id => @current_user.id, :identifier_id => @identifier.id, :publication_id => @identifier.publication_id, :comment => comment, :reason => "commit" } )
        @comment.save
      end
    end

    def find_identifier
      @identifier = HGVMetaIdentifier.find(params[:id])
    end

end