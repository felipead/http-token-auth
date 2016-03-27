module HTTP
  module TokenAuth
    class Challenge
      attr_reader :realm, :supported_coverages
      def initialize(realm:, supported_coverages:)
        @realm = realm
        @supported_coverages = supported_coverages
      end

      def to_header
        attributes = []
        attributes << %(realm="#{@realm}")
        attributes << %(coverage="#{coverage_string}")
        "Token #{attributes.join(', ')}"
      end

      private

      def coverage_string
        return 'coverage="none"' if supported_coverages.include?(:none)
      end
    end
  end
end
