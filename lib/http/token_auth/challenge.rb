module HTTP
  module TokenAuth
    class ChallengeArgumentError < StandardError
    end

    class Challenge
      attr_reader :realm, :supported_coverages, :timestamp

      def initialize(realm:, supported_coverages:, timestamp: nil)
        @realm = realm
        @supported_coverages = supported_coverages
        @timestamp = timestamp
        validate_itself
      end

      def to_header
        attributes = []
        attributes << %(realm="#{@realm}")
        attributes << %(coverage="#{coverage_string}")
        "Token #{attributes.join(', ')}"
      end

      private

      def validate_itself
        raise ChallengeArgumentError, '"realm" is missing' unless @realm && !@realm.empty?
      end

      def coverage_string
        return 'coverage="none"' if supported_coverages.include?(:none)
      end
    end
  end
end
