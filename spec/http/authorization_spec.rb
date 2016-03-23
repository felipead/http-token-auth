require 'http/authorization/token_authorization_header'

describe HTTP::Authorization do
  let :token_authorization do
    <<~EOS
      Token token="5ccc069c403ebaf9f0171e9517f40e41"
    EOS
  end

  describe '#parse_authorization_header' do
    it 'recognizes a Token schema' do
      header = HTTP::Authorization.parse_authorization_header token_authorization
      expect(header).to be_a(HTTP::Authorization::TokenAuthorizationHeader)
    end
  end
end
