module HTTP
  module TokenAuth
    class MissingArgumentError < StandardError
      def initialize(argument_name)
        super(%(Invalid token credentials: "#{argument_name}" is missing))
      end
    end

    class Credentials
      attr_reader :token, :coverage, :nonce, :auth, :timestamp

      def initialize(token:, coverage: nil, nonce: nil, auth: nil, timestamp: nil)
        @token = token
        @coverage = coverage
        @nonce = nonce
        @auth = auth
        @timestamp = timestamp
        validate_itself
      end

      def to_header
        attributes = []
        attributes << %(token="#{@token}")
        unless coverage.nil?
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
        return if @coverage.nil?
        must_have_nonce
        must_have_auth
        must_have_timestamp
      end

      def must_have_token
        raise MissingArgumentError, 'token' if @token.nil? || @token.empty?
      end

      def must_have_nonce
        raise MissingArgumentError, 'nonce' if @nonce.nil? || @nonce.empty?
      end

      def must_have_auth
        raise MissingArgumentError, 'auth' if @auth.nil? || @auth.empty?
      end

      def must_have_timestamp
        raise MissingArgumentError, 'timestamp' if @timestamp.nil?
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
