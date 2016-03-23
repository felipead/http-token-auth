require 'http/auth'

describe HTTP::Auth::TokenAuthorizationHeader do
  describe 'given a complete token authorization header' do
    let :complete_header_string do
      <<-EOS
        token="5ccc069c403ebaf9f0171e9517f40e41",
        coverage="base",
        nonce="2e0d73708933eff3e53319d884a0505c",
        auth="ed5a137d3724ec12ddd95bbea3e8a634",
        timestamp="1234567890"
      EOS
    end

    let :complete_header do
      HTTP::Auth::TokenAuthorizationHeader.parse(complete_header_string)
    end

    it 'returns token as the schema' do
      expect(complete_header.schema).to eq(:token)
    end

    it 'returns the "token" attribute' do
      expect(complete_header.token).to eq('5ccc069c403ebaf9f0171e9517f40e41')
    end

    it 'returns the "coverage" attribute' do
      expect(complete_header.coverage).to eq('base')
    end

    it 'returns the "nonce" attribute' do
      expect(complete_header.nonce).to eq('2e0d73708933eff3e53319d884a0505c')
    end

    it 'returns the "auth" attribute' do
      expect(complete_header.auth).to eq('ed5a137d3724ec12ddd95bbea3e8a634')
    end

    it 'returns the timestamp attribute' do
      expect(complete_header.timestamp).to eq('1234567890')
    end
  end

  describe 'given an incomplete token authorization header' do
    it 'fails if the "token" attribute is ommited' do
      without_token = 'coverage="base", nonce="2e0d73708933eff3e53319d884a0505c"'
      expect do
        HTTP::Auth::TokenAuthorizationHeader.parse without_token
      end.to raise_error(ArgumentError)
    end

    it 'fails if the "token" attribute is empty' do
      with_empty_token = 'token="", coverage="base", nonce="2e0d73708933eff3e53319d884a0505c"'
      expect do
        HTTP::Auth::TokenAuthorizationHeader.parse with_empty_token
      end.to raise_error(ArgumentError)
    end

    it 'returns "base" if the "coverage" attribute is ommited' do
      without_coverage = 'token="123123342"'
      header = HTTP::Auth::TokenAuthorizationHeader.parse without_coverage
      expect(header.coverage).to eq('base')
    end

    it 'returns "base" if the "coverage" attribute is empty' do
      with_empty_coverage = 'token="123142", coverage=""'
      header = HTTP::Auth::TokenAuthorizationHeader.parse with_empty_coverage
      expect(header.coverage).to eq('base')
    end
  end
end
