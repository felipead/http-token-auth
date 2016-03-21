module HTTP
  module Authorization
    class Header
      attr_reader :schema

      def initialize(_)
        @schema = :token
      end
    end
  end
end
