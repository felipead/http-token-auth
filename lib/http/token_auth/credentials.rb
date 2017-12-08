module HTTP
  module TokenAuth
    class CredentialsArgumentError < StandardError
    end

    class Credentials
      attr_reader :token, :coverage, :nonce, :auth, :timestamp

      def initialize(token:, coverage: nil, nonce: nil, auth: nil, timestamp: nil)
        @token = token
        @coverage = coverage.nil? ? :none : coverage
        @nonce = nonce
        @auth = auth
        @timestamp = timestamp
        validate_itself
      end

      def to_header
        attributes = []
        attributes << %(token="#{@token}")
        unless coverage == :none
          attributes << %(coverage="#{coverage_name}")
          attributes << %(nonce="#{@nonce}")
          attributes << %(auth="#{@auth}")
          attributes << %(timestamp="#{@timestamp}")
        end
        "Token #{attributes.join(', ')}"
      end

      private

      def validate_itself
        must_have_token
        must_have_valid_coverage
        return if @coverage == :none
        must_have_nonce
        must_have_auth
        must_have_timestamp
      end

      def must_have_valid_coverage
        return if %i[none base base_body_sha_256].include?(@coverage)
        raise CredentialsArgumentError, %(unsupported "#{@coverage}" coverage)
      end

      def must_have_token
        raise CredentialsArgumentError, '"token" is missing' if @token.nil? || @token.empty?
      end

      def must_have_nonce
        raise CredentialsArgumentError, '"nonce" is missing' if @nonce.nil? || @nonce.empty?
      end

      def must_have_auth
        raise CredentialsArgumentError, '"auth" is missing' if @auth.nil? || @auth.empty?
      end

      def must_have_timestamp
        raise CredentialsArgumentError, '"timestamp" is missing' if @timestamp.nil?
      end

      def coverage_name
        case @coverage
        when :base then 'base'
        when :base_body_sha_256 then 'base+body-sha-256'
        end
      end
    end
  end
end
