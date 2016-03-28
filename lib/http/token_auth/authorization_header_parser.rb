module HTTP
  module TokenAuth
    def self.parse_authorization_header(header)
      parser = AuthorizationHeaderParser.new
      parser.parse(header)
    end

    class AuthorizationHeaderParsingError < StandardError
      def initialize(submessage)
        super(%(Error parsing "Authorization" HTTP header with token scheme: #{submessage}))
      end
    end

    class AuthorizationHeaderParser
      def parse(header)
        scheme, attributes = split(header)
        raise AuthorizationHeaderParsingError,
              'Header has no attributes' if attributes.nil?
        raise AuthorizationHeaderParsingError,
              %(Invalid scheme "#{scheme}") unless scheme == 'Token'
        build_credentials parse_attributes(attributes)
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
      rescue MissingCredentialsArgumentError => e
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
