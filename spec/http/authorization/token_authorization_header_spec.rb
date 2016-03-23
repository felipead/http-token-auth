require 'http/authorization'

describe HTTP::Authorization::TokenAuthorizationHeader do
  let :attributes do
    <<~EOS
      token="5ccc069c403ebaf9f0171e9517f40e41"
    EOS
  end

  describe '#schema' do
    it 'returns token' do
      header = HTTP::Authorization::TokenAuthorizationHeader.parse(attributes)
      expect(header.schema).to eq(:token)
    end
  end
end
