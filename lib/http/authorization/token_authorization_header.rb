module HTTP
  module Authorization
    class TokenAuthorizationHeader
      def schema
        :token
      end

      def self.parse(attributes)
        TokenAuthorizationHeader.new
      end
    end
  end
end
