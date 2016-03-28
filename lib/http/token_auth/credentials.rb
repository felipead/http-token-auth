module HTTP
  module TokenAuth
    class InvalidCredentialsError < StandardError
      def initialize(message)
        super("Invalid token credentials: #{message}")
      end
    end

    class MissingCredentialsArgumentError < InvalidCredentialsError
      def initialize(argument_name)
        super(%("#{argument_name}" is missing))
      end
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
        unless @coverage == :none
          must_have_nonce
          must_have_auth
          must_have_timestamp
        end
      end

      def must_have_valid_coverage
        case @coverage
        when :none
        when :base
        when :base_body_sha_256
          return
        else
          raise InvalidCredentialsError, %(unsupported "#{@coverage}" coverage)
        end
      end

      def must_have_token
        raise MissingCredentialsArgumentError, 'token' if @token.nil? || @token.empty?
      end

      def must_have_nonce
        raise MissingCredentialsArgumentError, 'nonce' if @nonce.nil? || @nonce.empty?
      end

      def must_have_auth
        raise MissingCredentialsArgumentError, 'auth' if @auth.nil? || @auth.empty?
      end

      def must_have_timestamp
        raise MissingCredentialsArgumentError, 'timestamp' if @timestamp.nil?
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
