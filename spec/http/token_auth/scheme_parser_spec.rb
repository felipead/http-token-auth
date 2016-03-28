require 'http/token_auth'

include HTTP::TokenAuth

describe SchemeParser do
  let(:parser) { SchemeParser.new }

  describe '#parse' do
    it 'fails to parse if scheme is not "Token"' do
      expect do
        parser.parse('Basic QWxhZGRpbjpPcGVuU2VzYW1l')
      end.to raise_error(SchemeParsingError).with_message(/Unsupported scheme "Basic"/)
    end

    it 'fails if no attributes are provided' do
      expect do
        parser.parse('Token')
      end.to raise_error(SchemeParsingError).with_message(/No attributes provided/)
    end

    it 'parses it returning a list of attributes' do
      header = <<-EOS
        Token token="h480djs93hd8",
              coverage="base",
              nonce="dj83hs9s",
              auth="djosJKDKJSD8743243/jdk33klY=",
              timestamp="137131200"
      EOS
      attributes = parser.parse(header)
      expect(attributes[:token]).to eq('h480djs93hd8')
      expect(attributes[:coverage]).to eq('base')
      expect(attributes[:nonce]).to eq('dj83hs9s')
      expect(attributes[:auth]).to eq('djosJKDKJSD8743243/jdk33klY=')
      expect(attributes[:timestamp]).to eq('137131200')
    end
  end
end
