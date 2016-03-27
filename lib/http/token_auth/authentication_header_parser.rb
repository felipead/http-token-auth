module HTTP
  module TokenAuth
    def self.parse_authentication_header(header)
      parser = AuthenticationHeaderParser.new
      parser.parse(header)
    end

    class AuthenticationHeaderParsingError < StandardError
      def initialize(submessage)
        super(%(Error parsing "Authorization" header with token schema: #{submessage}))
      end
    end

    class AuthenticationHeaderParser
      def parse(header)
        schema, attributes_string = split(header)
        raise HeaderParsingError, "Invalid schema #{schema}" unless schema == 'Token'
        build_credentials parse_attributes(attributes_string)
      end

      def split(header)
        header.split(' ', 2)
      end

      def parse_attributes(string)
        attributes = {}
        string.scan(/(\w+)="([^"]*)"/).each do |group|
          attributes[group[0].to_sym] = group[1]
        end
        attributes
      end

      def build_credentials(attributes)
        Credentials.new token: attributes[:token],
                        coverage: parse_coverage(attributes[:coverage]),
                        nonce: attributes[:nonce],
                        auth: attributes[:auth],
                        timestamp: parse_timestamp(attributes[:timestamp])
      end

      def parse_coverage(coverage)
        return nil if coverage.nil? || coverage.empty?
        case coverage
        when 'none' then nil
        when 'base' then :base
        when 'base+body-sha-256' then :base_body_sha_256
        else raise AuthenticationHeaderParsingError, %(Invalid coverage "#{coverage}")
        end
      end

      def parse_timestamp(timestamp)
        timestamp.nil? ? nil : timestamp.to_i
      end
    end
  end
end
