module HTTP
  module TokenAuth
    class ChallengeArgumentError < StandardError
    end

    class Challenge
      attr_reader :realm, :supported_coverages, :timestamp

      def initialize(realm:, supported_coverages: nil, timestamp: nil)
        @realm = realm
        @supported_coverages = supported_coverages_or_default(supported_coverages)
        @timestamp = timestamp
        validate_itself
      end

      def to_header
        attributes = []
        attributes << %(realm="#{@realm}")
        attributes << %(coverage="#{coverage_string}")
        unless supported_coverages.include?(:none)
          attributes << %(timestamp="#{@timestamp}")
        end
        "Token #{attributes.join(', ')}"
      end

      private

      def supported_coverages_or_default(list)
        return [:base] if list.nil? || list.empty?
        list
      end

      def validate_itself
        must_have_realm
        supported_coverages_must_be_consistent
        must_have_timestamp unless supported_coverages.include?(:none)
      end

      def must_have_realm
        raise ChallengeArgumentError, '"realm" is missing' if @realm.nil? || @realm.empty?
      end

      def must_have_timestamp
        raise ChallengeArgumentError, '"timestamp" is missing' if @timestamp.nil?
      end

      def supported_coverages_must_be_consistent
        return unless supported_coverages.include?(:none) && supported_coverages.size > 1
        raise ChallengeArgumentError, 'coverage "none" cannot be combined with other coverages'
      end

      def coverage_string
        @supported_coverages.map do |coverage|
          coverage_name(coverage)
        end.join(' ')
      end

      def coverage_name(coverage)
        case coverage
        when :none then 'none'
        when :base then 'base'
        when :base_body_sha_256 then 'base+body-sha-256'
        end
      end
    end
  end
end
