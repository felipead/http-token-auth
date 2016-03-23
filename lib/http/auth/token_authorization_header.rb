module HTTP
  module Auth
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
