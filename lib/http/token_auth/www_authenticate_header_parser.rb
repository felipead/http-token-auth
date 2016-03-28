module HTTP
  module TokenAuth
    def self.parse_www_authenticate_header(header)
      parser = WWWAuthenticateHeaderParser.new
      parser.parse(header)
    end

    class WWWAuthenticateHeaderParsingError < StandardError
    end

    class WWWAuthenticateHeaderParser
      def initialize
        @schema_parser = SchemeParser.new
      end

      def parse(header)
        build_challenge @schema_parser.parse(header)
      end

      private

      def build_challenge(attributes)
        Challenge.new realm: attributes[:realm],
                      supported_coverages: parse_coverage(attributes[:coverage]),
                      timestamp: parse_timestamp(attributes[:timestamp])
      rescue ChallengeArgumentError => e
        raise WWWAuthenticateHeaderParsingError, e.message
      end

      def parse_coverage(string)
        return [:base] if string.nil?
        string.split.map do |token|
          case token
          when 'none' then :none
          when 'base' then :base
          when 'base+body-sha-256' then :base_body_sha_256
          else raise WWWAuthenticateHeaderParsingError, %(Unsupported coverage "#{token}")
          end
        end
      end

      def parse_timestamp(string)
        string.nil? ? nil : string.to_i
      end
    end
  end
end
