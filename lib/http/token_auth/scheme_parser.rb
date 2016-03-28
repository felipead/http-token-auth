module HTTP
  module TokenAuth
    class SchemeParsingError < StandardError
    end

    class SchemeParser
      def parse(string)
        scheme, attributes_string = split(string)
        raise SchemeParsingError,
              'No attributes provided' if attributes_string.nil?
        raise SchemeParsingError,
              %(Unsupported scheme "#{scheme}") unless scheme == 'Token'
        parse_attributes(attributes_string)
      end

      def split(string)
        string.split(' ', 2)
      end

      def parse_attributes(string)
        attributes = {}
        string.scan(/(\w+)="([^"]*)"/).each do |group|
          attributes[group[0].to_sym] = group[1]
        end
        attributes
      end
    end
  end
end
