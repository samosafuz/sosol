module JRubyXML
  class << self
    def stream_from_string(input_string)
      javax.xml.transform.stream.StreamSource.new(
        java.io.StringReader.new(input_string))
    end

    def stream_from_file(input_file)
      javax.xml.transform.stream.StreamSource.new(input_file)
    end

    def apply_xsl_transform(xml_stream, xsl_stream)
      java.lang.System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl")
  
      transformer_factory = javax.xml.transform.TransformerFactory.newInstance()
      transformer = transformer_factory.newTransformer(xsl_stream)
  
      string_writer = java.io.StringWriter.new()
      result = javax.xml.transform.stream.StreamResult.new(string_writer)

      transformer.transform(xml_stream, result)
  
      string_writer.toString()
    end
  end
end