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

      def build_challenge(attributes)
        Challenge.new realm: attributes[:realm],
                      supported_coverages: parse_coverage(attributes[:coverage]),
                      timestamp: nil
      rescue ChallengeArgumentError => e
        raise WWWAuthenticateHeaderParsingError, e.message
      end

      def parse_coverage(coverage)
        coverage.split.map do |c|
          :none if c == 'none'
        end
      end
    end
  end
end
