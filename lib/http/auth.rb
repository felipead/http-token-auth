require 'http/auth/token_authorization_header'

module HTTP
  module Auth
    def self.parse_authorization_header(header)
      schema, remainder = header.split(' ', 2)
      case schema
      when 'Token' then TokenAuthorizationHeader.parse(remainder)
      end
    end
  end
end
