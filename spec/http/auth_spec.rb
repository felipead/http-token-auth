require 'http/auth/token_authorization_header'

describe HTTP::Auth do
  let :token_authorization do
    <<~EOS
      Token token="5ccc069c403ebaf9f0171e9517f40e41"
    EOS
  end

  describe '#parse_authorization_header' do
    it 'recognizes a Token schema' do
      header = HTTP::Auth.parse_authorization_header token_authorization
      expect(header).to be_a(HTTP::Auth::TokenAuthorizationHeader)
    end
  end
end
