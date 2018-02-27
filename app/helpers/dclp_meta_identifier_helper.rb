module DclpMetaIdentifierHelper
  module DclpEdition

    # Assembles all valid type options for DCLP edition types (+publication+, +reference+, etc.)
    # - *Returns* :
    #   - +Array+ of +Array+s that can be used with rails' +options_for_select+ method
    def DclpEdition.typeOptions
      [
        [I18n.t('edition.type.publication'),  :publication],
        [I18n.t('edition.type.reference'),      :reference]
      ]
    end

    # Assembles all valid type options for DCLP edition subtypes (+principal+, +partial+, +previous+, etc.)
    # - *Returns* :
    #   - +Array+ of +Array+s that can be used with rails' +options_for_select+ method
    def DclpEdition.subtypeOptions
      [
        [I18n.t('edition.subtype.principal'),    :principal],
        [I18n.t('edition.subtype.partial'),      :partial],
        [I18n.t('edition.subtype.previous'),     :previous],
        [I18n.t('edition.subtype.readings'),     :readings],
        [I18n.t('edition.subtype.translation'),  :translation],
        [I18n.t('edition.subtype.study'),        :study],
        [I18n.t('edition.subtype.catalogue'),    :catalogue],
        [I18n.t('edition.subtype.palaeo'),       :palaeo]
      ]
    end

    # Assembles all valid type options for DCLP edition types and subtypes combined as one ‘ubertype’ (+principal+, +reference+, +partial+, etc.)
    # e.g. publication + principal = principal
    # e.g. reference + principal = reference
    # e.g. reference + partial = partial
    # - *Returns* :
    #   - +Array+ of +Array+s that can be used with rails' +options_for_select+ method
    def DclpEdition.ubertypeOptions1
      [
        [I18n.t('edition.ubertype.principal'),   :principal],
        [I18n.t('edition.ubertype.reference'),   :reference],
        [I18n.t('edition.ubertype.partial'),     :partial],
        [I18n.t('edition.ubertype.previous'),    :previous],
        [I18n.t('edition.ubertype.readings'),    :readings]
      ]
    end

    # Assembles all valid type options for DCLP edition types and subtypes combined as one ‘ubertype’ (+translation+, +study+, +catalogue+, etc.)
    # (those below the horizontal line in the drop down menu)
    # e.g. reference + translation = translation
    # e.g. reference + study = study
    # e.g. reference + catalogue = catalogue
    # - *Returns* :
    #   - +Array+ of +Array+s that can be used with rails' +options_for_select+ method
    def DclpEdition.ubertypeOptions2
      [
        [I18n.t('edition.ubertype.translation'),  :translation],
        [I18n.t('edition.ubertype.study'),        :study],
        [I18n.t('edition.ubertype.catalogue'),    :catalogue],
        [I18n.t('edition.ubertype.palaeo'),       :palaeo]
      ]
    end

    # Assembles all valid type options for DCLP languages (+de+, +en+, +it+, etc.)
    # - *Returns* :
    #   - +Array+ of +Array+s that can be used with rails' +options_for_select+ method
    def DclpEdition.languageOptions
      [
        ['', ''],
        [I18n.t('language.de'), :de],
        [I18n.t('language.en'), :en],
        [I18n.t('language.it'), :it],
        [I18n.t('language.es'), :es],
        [I18n.t('language.la'), :la],
        [I18n.t('language.fr'), :fr]
      ]
    end

    # Assembles all valid type options for DCLP biblScop/@unit (+book+, +chapter+, +column+, etc.)
    # listed in alphabetical order
    # - *Returns* :
    #   - +Array+ of +Array+s that can be used with rails' +options_for_select+ method
    def DclpEdition.extraOptions
      [
        [I18n.t('edition.extra.book'),      :book],
        [I18n.t('edition.extra.chapter'),   :chapter],
        [I18n.t('edition.extra.column'),    :column],
        [I18n.t('edition.extra.fascicle'),  :fascicle],
        [I18n.t('edition.extra.folio'),     :folio],
        [I18n.t('edition.extra.fragment'),  :fragment],
        [I18n.t('edition.extra.generic'),   :generic],
        [I18n.t('edition.extra.inventory'), :inventory],
        [I18n.t('edition.extra.issue'),     :issue],
        [I18n.t('edition.extra.line'),      :line],
        [I18n.t('edition.extra.number'),    :number],
        [I18n.t('edition.extra.page'),      :page],
        [I18n.t('edition.extra.part'),      :part],
        [I18n.t('edition.extra.plate'),     :plate],
        [I18n.t('edition.extra.poem'),      :poem],
        [I18n.t('edition.extra.side'),      :side],
        [I18n.t('edition.extra.tome'),      :tome],
        [I18n.t('edition.extra.volume'),    :volume]
      ]
    end

    # Test whether a given value (+test+) is comprised in above list (DclpEdition.extraOptions)
    def DclpEdition.validExtraOption? test
      if test.is_a?(Symbol) || test.is_a?(String)
        DclpEdition.extraOptions.each{ |option|
          if test.to_sym == option[1]
            return true
          end
        }
      end
      return false
    end

    # Data structure for publication information
    class Extra
      attr_accessor :value, :unit, :corresp, :from, :to
      def initialize value, unit, corresp = nil, from = nil, to = nil
        @value   = value
        @unit    = unit.to_sym
        @corresp = corresp
        @from    = from
        @to      = to
      end
    end

    class Edition
      # +Array+ of a valid values for @type
      @@typeList          = [:publication, :reference]
      # +Array+ of a valid values for @subtype
      @@subtypeList       = [:principal, :partial, :previous, :readings, :translation, :study, :catalogue, :palaeo]
      # +Array+ of a valid values for @xml:lang
      @@languageList       = [:de, :en, :it, :es, :la, :fr]
      # +Array+ of all String member attributes that have a TEI equivalent
      @@atomList          = [:type, :subtype, :ubertype, :language, :link, :title, :titleLevel, :titleType] # CROMULENT TITLE HACK

      attr_accessor :type, :subtype, :ubertype, :language, :link, :biblioId, :extraList, :preview, :title, :titleLevel, :titleType # CROMULENT TITLE HACK

      # Constructor
      # - *Args*  :
      #   - +init+ → +Hash+ object containing edition data as provided by the model class +DCLPMetaIdentifier+, used to initialise member variables, defaults to +nil+
      # Side effect on +@type+, +@subtype+, +@ubertype+, +@language+, +@link+, +@biblioId+, +@extraList+, +@preview+, +@title+, +@titleLevel+ and +@titleType+
      def initialize init = nil
        @type      = nil
        @subtype   = nil
        @ubertype  = nil
        @language  = nil
        @link      = nil
        @biblioId  = nil
        @extraList = []
        @preview   = nil
        @title      = nil # CROMULENT TITLE HACK
        @titleLevel = nil # CROMULENT TITLE HACK
        @titleType  = nil # CROMULENT TITLE HACK

        if init
          if init[:edition]
            if init[:edition][:attributes]
              self.populateAtomFromHash init[:edition][:attributes]
            end

            @ubertype = @subtype
            if @type == 'reference' && @subtype == 'principal'
              @ubertype = 'reference'
            end

            if init[:edition][:children]
              if init[:edition][:children][:link]
                @link = init[:edition][:children][:link][:value]
                @biblioId = @link.match(/\A.+\/(\d+)\Z/) ? @link.match(/\A.+\/(\d+)\Z/).captures[0] : nil
              end
              if init[:edition][:children][:title] # CROMULENT TITLE HACK
                @title = init[:edition][:children][:title][:value]
                if init[:edition][:children][:title][:attributes]
                  @titleLevel = init[:edition][:children][:title][:attributes][:level]
                  @titleType = init[:edition][:children][:title][:attributes][:type]
                end
              end
              if init[:edition][:children][:extra]
                init[:edition][:children][:extra].each {|extra|
                  @extraList << Extra.new(extra[:value], extra[:attributes][:unit], extra[:attributes][:corresp], extra[:attributes][:from], extra[:attributes][:to])
                }
              end
            end

          else
            self.populateAtomFromHash init
          end

        end

      end
      
      def type= value
        @type = value
      end
      
      def subtype= value
        @subtype = value
      end
      
      # Updates atomic instance variables (strings, numbers, etc.) from a given hash
      # - *Args*  :
      #   - +hash+ → key value pairs of object data
      # - *Returns* :
      #   - +Array+ of variable names for atomic values
      # Side effect on all member variables that are declared in +@@atomList+
      def populateAtomFromHash hash
        @@atomList.each {|member|
          self.send((member.to_s + '=').to_sym, hash[member] || nil)
        }
      end
    
    end
  end # module DclpEdition

  module DclpWork

    # List of all available authorities (+tlg+, +stoa+, +cwkb+, etc.)
    # - *Returns* :
    #   - +Array+ of +Array+s that can be used with rails' +options_for_select+ method
    def DclpWork.authorityOptions(mode = null)
      options = [
        [I18n.t('work.authority.tlg'),  :tlg],
        [I18n.t('work.authority.stoa'), :stoa],
        [I18n.t('work.authority.cwkb'), :cwkb],
        [I18n.t('work.authority.phi'),  :phi],
        [I18n.t('work.authority.tm'),   :tm]
      ]

      if(mode == :author)
        options.delete_if {|x| x[1] == :tm}
      elsif(mode == :title)
        options.delete_if {|x| x[1] == :phi}
      end

      options
    end

    # Assembles all valid subtype options for DCLP work (+ancient+, +ancientQuote+, etc.)
    # type is always +publication+
    # - *Returns* :
    #   - +Array+ of +Array+s that can be used with rails' +options_for_select+ method
    def DclpWork.subtypeOptions
      [
        [I18n.t('work.subtype.ancient'), :ancient],
        [I18n.t('work.subtype.ancientQuote'), :ancientQuote]
      ]
    end

    # Assembles all valid type options for DCLP work languages (+la+, +el+, etc.)
    # - *Returns* :
    #   - +Array+ of +Array+s that can be used with rails' +options_for_select+ method
    def DclpWork.languageOptions
      [
        ['', ''],
        [I18n.t('language.la'), :la],
        [I18n.t('language.el'), :grc],
      ]
    end
    
    def DclpWork.getIdFromUrl(urlList, type)
      if urlList
        id = ''
        urlList.each{|url|
          case type
          when :tlg
            if /\A.*tlg(?<id>\d+)\Z/ =~ url
              return id
            end
          when :tm
            if /\A.*authorwork\/(?<id>\d+)\Z/ =~ url
              return id
            end
          when :stoa
            if /\A.*stoa(?<id>\d+)\Z/ =~ url
              return id
            end
          when :phi
            if /\A.*phi(?<id>\d+)\Z/ =~ url
              return id
            end
          when :cwkb
            if /\A.*cwkb\.org\/(author|work).*[^\d](?<id>\d+)[^\d].*\Z/ =~ url
              return id
            end
          else
            return nil
          end
        }
      end
      return nil
    end
    
    def DclpWork.getLanguageFromUrl(urlList)
      if urlList
        language = ''
        urlList.each{|url|
          if /(?<language>greek|latin)/ =~ url
            case language
              when 'latin'
                return 'la'
              when 'greek'
                return 'grc'
            end
          end
        }
      end
      return nil
    end

    # Data structure for publication information
    class Author
      attr_accessor :name, :language, :tlg, :cwkb, :phi, :stoa, :authority, :certainty, :ref, :corresp
      def initialize init = nil
        @name      = init[:value]

        @ref       = init[:attributes][:ref] ? init[:attributes][:ref] : []
        @phi       = init[:children][:phi] ? init[:children][:phi][:value] : DclpWork.getIdFromUrl(@ref, :phi)
        @tlg       = init[:children][:tlg] ? init[:children][:tlg][:value] : DclpWork.getIdFromUrl(@ref, :tlg)
        @stoa      = init[:children][:stoa] ? init[:children][:stoa][:value] : DclpWork.getIdFromUrl(@ref, :stoa)
        @cwkb      = init[:children][:cwkb] ? init[:children][:cwkb][:value] : DclpWork.getIdFromUrl(@ref, :cwkb)
        @authority = {:phi => @phi, :tlg => @tlg, :stoa => @stoa, :cwkb => @cwkb}

        @language  = init[:attributes][:language] ? init[:attributes][:language] : DclpWork.getLanguageFromUrl(@ref)
        
        @certainty = init[:children][:certainty] ? init[:children][:certainty] : nil
      end

      def to_s()
        '[AUTHOR ' + (@name ? @name : '-') + ' | language ' + (@language || 'xxx') + ' | tlg ' + (@tlg || '') + ' | cwkb ' + (@cwkb || '') + ' | phi ' + (@phi || '') + ' | stoa ' + (@stoa || '') + ' | corresp ' + (@corresp || '') + ' | certainty ' + (@certainty || '') + ' | ref ' + (@ref.to_s || '') + ']'
      end
    end

    # Data structure for publication information
    class Title
      attr_accessor :name, :language, :tlg, :cwkb, :tm, :stoa, :authority, :certainty, :ref, :date, :from, :to, :corresp
      def initialize init = nil
        @name      = init[:value]
        
        @ref       = init[:attributes][:ref] ? init[:attributes][:ref] : []
        @tm        = init[:children][:tm] ? init[:children][:tm][:value] : DclpWork.getIdFromUrl(@ref, :tm)
        @tlg       = init[:children][:tlg] ? init[:children][:tlg][:value] : DclpWork.getIdFromUrl(@ref, :tlg)
        @stoa      = init[:children][:stoa] ? init[:children][:stoa][:value] : DclpWork.getIdFromUrl(@ref, :stoa)
        @cwkb      = init[:children][:cwkb] ? init[:children][:cwkb][:value] : DclpWork.getIdFromUrl(@ref, :cwkb)
        @authority = {:tm => @tm, :tlg => @tlg, :stoa => @stoa, :cwkb => @cwkb}
        @language  = init[:attributes][:language] ? init[:attributes][:language] : DclpWork.getLanguageFromUrl(@ref)
        
        @certainty = init[:children][:certainty] ? init[:children][:certainty] : nil
        @date      = init[:children][:date] ? init[:children][:date][:value] : nil
        @when      = init[:children][:date] ? init[:children][:date][:attributes][:when] : nil
        @from      = init[:children][:date] ? init[:children][:date][:attributes][:from] : @when
        @to        = init[:children][:date] ? init[:children][:date][:attributes][:to] : nil
        
      end

      def to_s()
        '[TITLE ' + (@name ? @name : '-') + ' | language ' + (@language || '') + ' | tm ' + (@tm || '') + ' | cwkb ' + (@cwkb || '') + ' | tlg ' + (@tlg || '') + ' | stoa ' + (@stoa || '') + ' | corresp ' + (@corresp || '') + ' | certainty ' + (@certainty || '') + ' | ref ' + (@ref.to_s || '') + ' | date ' + (@date || '') + (@when || @from || @to ? '(' + (@when || '') + (@from || '') + (@to ? '-' + @to : '') + ')' : '') + ']'
      end
    end

    # ContentText, genre, religion, culture and other keywords
    class ContentText
      attr_accessor :genre, :religion, :culture, :keywords, :overview
      def initialize init = nil
        @genre    = []
        @religion = []
        @culture  = []
        @keywords = []
        @overview = ''

        if init && init[:contentText]
          init[:contentText].each{|keyword|
            if keyword[:attributes] && keyword[:attributes][:class]
              case keyword[:attributes][:class]
                when 'culture'
                  @culture  << keyword[:value]
                when 'religion'
                  @religion << keyword[:value]
                when 'description'
                  @genre << keyword[:value]
                when 'overview'
                  @overview = keyword[:value]
                else
                  @keywords << keyword[:value]
              end
            else
              @keywords << keyword[:value]
            end
          }
        end
      end

      def to_s
        '[ContentText genre: ' + @genre.to_s + ', religion: ' + @religion.to_s + ', culture ' + @culture.to_s + '; overview: ' + @overview + ']' 
      end
    end

    # Data structure for publication information
    class Extra
      attr_accessor :value, :unit, :certainty, :from, :to

      def initialize init = nil
        @value     = nil
        @unit      = nil
        @certainty = nil
        @from      = nil
        @to        = nil
        @corresp   = nil

        if init
          @value     = defined?(init[:value]) ? init[:value] : nil
          if init[:attributes]
            @unit      = defined?(init[:attributes][:unit]) ? init[:attributes][:unit] : nil
            @from      = defined?(init[:attributes][:from]) ? init[:attributes][:from] : nil
            @to        = defined?(init[:attributes][:to]) ? init[:attributes][:to] : nil
            @corresp   = defined?(init[:attributes][:corresp]) ? init[:attributes][:corresp] : nil
          end
          if init[:children] && init[:children][:certainty]
            @certainty = init[:children][:certainty]
          end
        end
      end
    end

    class Work
      # +Array+ of a valid values for @subtype
      @@subtypeList = [:ancient, :ancientQuote]
      @@atomList = [:subtype, :corresp, :id, :exclude]

      attr_accessor :subtype, :corresp, :id, :exclude, :alternative, :author, :title, :extraList

      def self.alternative? workListAsObtainedFromEpiDoc
        workListAsObtainedFromEpiDoc.each do |work|
          if work && work[:attributes] && work[:attributes][:exclude] && !work[:attributes][:exclude].empty?
            return true
          end
        end
        return false
      end

      # Constructor
      # - *Args*  :
      #   - +init+ → +Hash+ object containing work data as provided by the model class +DCLPMetaIdentifier+, used to initialise member variables, defaults to +nil+
      # Side effect on +@subtype+, +@corresp+, +@id+, +@exclude+, +@alternative+, +@author+, +@title+ and +@extraList+
      def initialize init = nil
        @subtype     = nil
        @corresp     = nil
        @id          = nil
        @exclude     = nil
        @alternative = nil
        @author      = nil
        @title       = nil
        @extraList   = []

        if init
          if init[:attributes]
            self.populateAtomFromHash init[:attributes]
            if @id && !@id.empty?
              @alternative = true
            end
          end
          if init[:children]
            if init[:children][:author]
              @author = Author.new(init[:children][:author])
            end
            if init[:children][:title]
              @title = Title.new(init[:children][:title])
            end
            if init[:children][:extra]
              init[:children][:extra].each {|extra|
                @extraList << Extra.new(extra)
              }
            end
          end
        end
      end

      # Updates atomic instance variables (strings, numbers, etc.) from a given hash
      # - *Args*  :
      #   - +hash+ → key value pairs of object data
      # - *Returns* :
      #   - +Array+ of variable names for atomic values
      # Side effect on all member variables that are declared in +@@atomList+
      def populateAtomFromHash hash
        @@atomList.each {|member|
          self.send((member.to_s + '=').to_sym, hash[member] || nil)
        }
      end
      
      def to_s()
        if @subtype
          '[WORK Subtype: ' + @subtype + ' | ' + @author.to_s + ' | ' + @title.to_s + ' | count extra: ' + @extraList.length.to_s + ']'
        end
      end

    end

  end # module DclpWork
  
  module DclpObject
    class Collection
      attr_accessor :list
      def initialize collection, collectionList
        @list = []

        if collection
          @list << collection
        end
        
        if collectionList
          @list += collectionList
        end

      end
    end

  end # module DclpObject

end
