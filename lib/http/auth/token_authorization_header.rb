module HTTP
  module Auth
    class TokenAuthorizationHeader
      attr_reader :token, :coverage, :nonce, :auth, :timestamp

      def initialize(attributes)
        remove_trailling_whitespace(attributes)
        @token = must_have_token(attributes[:token])
        @coverage = must_have_coverage_or_default(attributes[:coverage])
        @nonce = attributes[:nonce]
        @auth = attributes[:auth]
        @timestamp = attributes[:timestamp]
      end

      def schema
        :token
      end

      def self.parse(attributes_string)
        groups = extract_groups(attributes_string)
        TokenAuthorizationHeader.new extract_attributes(groups)
      end

      private

      def must_have_token(token)
        raise ArgumentError, 'Token attribute is required' unless token && !token.empty?
        token
      end

      def must_have_coverage_or_default(coverage)
        (coverage && !coverage.empty?) ? coverage : 'base'
      end

      def remove_trailling_whitespace(attributes)
        attributes.each do |_, value|
          value.strip! unless value.nil?
        end
      end

      def self.extract_groups(attributes_string)
        attributes_string.scan(/(\w+)="([^"]*)"/)
      end

      def self.extract_attributes(groups)
        attributes = {}
        groups.each do |group|
          attributes[group[0].to_sym] = group[1]
        end
        attributes
      end

      private_class_method :extract_attributes, :extract_groups
    end
  end
end
