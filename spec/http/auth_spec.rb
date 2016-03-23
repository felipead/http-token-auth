require 'http/auth/token_authorization_header'

describe HTTP::Auth do
  describe '#parse_authorization_header' do
    let :token_authorization_header do
      <<-EOS
        Token token="5ccc069c403ebaf9f0171e9517f40e41",
              coverage="foobar",
              nonce="2e0d73708933eff3e53319d884a0505c",
              auth="ed5a137d3724ec12ddd95bbea3e8a634",
              timestamp="1458771255"
      EOS
    end

    it 'recognizes a Token schema' do
      header = HTTP::Auth.parse_authorization_header token_authorization_header
      expect(header).to be_a(HTTP::Auth::TokenAuthorizationHeader)
      expect(header.token).to eq('5ccc069c403ebaf9f0171e9517f40e41')
      expect(header.coverage).to eq('foobar')
      expect(header.nonce).to eq('2e0d73708933eff3e53319d884a0505c')
      expect(header.auth).to eq('ed5a137d3724ec12ddd95bbea3e8a634')
      expect(header.timestamp).to eq('1458771255')
    end
  end
end
