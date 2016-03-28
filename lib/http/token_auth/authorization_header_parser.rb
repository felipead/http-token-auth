module HTTP
  module TokenAuth
    def self.parse_authorization_header(header)
      parser = AuthorizationHeaderParser.new
      parser.parse(header)
    end

    class AuthorizationHeaderParsingError < StandardError
    end

    class AuthorizationHeaderParser
      def initialize
        @scheme_parser = SchemeParser.new
      end

      def parse(header)
        build_credentials @scheme_parser.parse(header)
      end

      def build_credentials(attributes)
        Credentials.new token: attributes[:token],
                        coverage: parse_coverage(attributes[:coverage]),
                        nonce: attributes[:nonce],
                        auth: attributes[:auth],
                        timestamp: parse_timestamp(attributes[:timestamp])
      rescue CredentialsArgumentError => e
        raise AuthorizationHeaderParsingError, e.message
      end

      def parse_coverage(coverage)
        case coverage
        when nil
        when ''
        when 'none' then :none
        when 'base' then :base
        when 'base+body-sha-256' then :base_body_sha_256
        else raise AuthorizationHeaderParsingError, %(Unsupported coverage "#{coverage}")
        end
      end

      def parse_timestamp(timestamp)
        timestamp.nil? ? nil : timestamp.to_i
      end
    end
  end
end
