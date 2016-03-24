require 'http/auth'

describe HTTP::Auth::TokenAuthorizationHeader do
  describe 'given a complete token authorization header' do
    let :complete_header_with_extra_whitespaces do
      <<-EOS
        token="5ccc069c403ebaf9f0171e9517f40e41",
        coverage="foobar",
        nonce="2e0d73708933eff3e53319d884a0505c",
        auth="ed5a137d3724ec12ddd95bbea3e8a634",
        timestamp="1458771255"
      EOS
    end

    let :complete_header do
      complete_header_with_extra_whitespaces.gsub(/\s+/, ' ').strip
    end

    it 'successfully parses it' do
      parsed = HTTP::Auth::TokenAuthorizationHeader.parse(complete_header)
      expect(parsed.schema).to eq(:token)
      expect(parsed.token).to eq('5ccc069c403ebaf9f0171e9517f40e41')
      expect(parsed.coverage).to eq('foobar')
      expect(parsed.nonce).to eq('2e0d73708933eff3e53319d884a0505c')
      expect(parsed.auth).to eq('ed5a137d3724ec12ddd95bbea3e8a634')
      expect(parsed.timestamp).to eq('1458771255')
    end

    it 'successfully parses it regardless of extra whitespace' do
      parsed = HTTP::Auth::TokenAuthorizationHeader.parse(complete_header_with_extra_whitespaces)
      expect(parsed.schema).to eq(:token)
      expect(parsed.token).to eq('5ccc069c403ebaf9f0171e9517f40e41')
      expect(parsed.coverage).to eq('foobar')
      expect(parsed.nonce).to eq('2e0d73708933eff3e53319d884a0505c')
      expect(parsed.auth).to eq('ed5a137d3724ec12ddd95bbea3e8a634')
      expect(parsed.timestamp).to eq('1458771255')
    end

    it 'builds the header string' do
      parsed = HTTP::Auth::TokenAuthorizationHeader.parse(complete_header)
      expect(parsed.to_s).to eq("Token #{complete_header}")
    end
  end

  describe 'given an incomplete token authorization header' do
    it 'fails if the "token" attribute is ommited' do
      without_token = 'coverage="base", nonce="2e0d73708933eff3e53319d884a0505c"'
      expect do
        HTTP::Auth::TokenAuthorizationHeader.parse without_token
      end.to raise_error(ArgumentError).with_message('Token attribute is required')
    end

    it 'fails if the "token" attribute is empty' do
      with_empty_token = 'token="", coverage="base", nonce="2e0d73708933eff3e53319d884a0505c"'
      expect do
        HTTP::Auth::TokenAuthorizationHeader.parse with_empty_token
      end.to raise_error(ArgumentError).with_message('Token attribute is required')
    end

    it 'returns "base" if the "coverage" attribute is ommited' do
      without_coverage = 'token="a_token"'
      header = HTTP::Auth::TokenAuthorizationHeader.parse without_coverage
      expect(header.coverage).to eq('base')
    end

    it 'returns "base" if the "coverage" attribute is empty' do
      with_empty_coverage = 'token="a_token", coverage=""'
      header = HTTP::Auth::TokenAuthorizationHeader.parse with_empty_coverage
      expect(header.coverage).to eq('base')
    end

    it 'returns nil if the "nonce" attribute is ommited' do
      without_nonce = 'token="a_token"'
      header = HTTP::Auth::TokenAuthorizationHeader.parse without_nonce
      expect(header.nonce).to be_nil
    end

    it 'returns nil if the "auth" attribute is ommited' do
      without_auth = 'token="a_token"'
      header = HTTP::Auth::TokenAuthorizationHeader.parse without_auth
      expect(header.auth).to be_nil
    end

    it 'returns nil if the "timestamp" attribute is ommited' do
      without_timestamp = 'token="a_token"'
      header = HTTP::Auth::TokenAuthorizationHeader.parse without_timestamp
      expect(header.timestamp).to be_nil
    end
  end
end
