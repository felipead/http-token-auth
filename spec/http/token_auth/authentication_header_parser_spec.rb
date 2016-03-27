require 'http/token_auth'

describe HTTP::TokenAuth::AuthenticationHeaderParser do
  describe 'given the value of an "Authentication" HTTP header with the token scheme' do
    describe 'using a cryptographic algorithm' do
      { 'base' => :base, 'base+body-sha-256' => :base_body_sha_256 }.each do |name, symbol|
        it %(parses it if coverage is "#{name}") do
          header = <<-EOS
            Token token="h480djs93hd8",
                  coverage="#{name}",
                  nonce="dj83hs9s",
                  auth="djosJKDKJSD8743243/jdk33klY=",
                  timestamp="137131200"
          EOS
          credentials = HTTP::TokenAuth.parse_authentication_header(header)
          expect(credentials.token).to eq('h480djs93hd8')
          expect(credentials.coverage).to eq(symbol)
          expect(credentials.nonce).to eq('dj83hs9s')
          expect(credentials.auth).to eq('djosJKDKJSD8743243/jdk33klY=')
          expect(credentials.timestamp).to eq(137131200)
        end
      end

      it 'fails if coverage is not recognized' do
        header = <<-EOS
          Token token="h480djs93hd8",
                coverage="invalid",
                nonce="dj83hs9s",
                auth="djosJKDKJSD8743243/jdk33klY=",
                timestamp="137131200"
        EOS
        expect do
          HTTP::TokenAuth.parse_authentication_header(header)
        end.to raise_error(HTTP::TokenAuth::AuthenticationHeaderParsingError).with_message(
          /Invalid coverage "invalid"/)
      end
    end

    describe 'without using a cryptographic algorithm' do
      it 'parses it if coverage is "none"' do
        header = <<-EOS
          Token token="h480djs93hd8",
                coverage="none"
        EOS
        credentials = HTTP::TokenAuth.parse_authentication_header(header)
        expect(credentials.token).to eq('h480djs93hd8')
        expect(credentials.coverage).to be_nil
        expect(credentials.nonce).to be_nil
        expect(credentials.auth).to be_nil
        expect(credentials.timestamp).to be_nil
      end

      it 'parses it if coverage is not defined' do
        header = <<-EOS
          Token token="h480djs93hd8"
        EOS
        credentials = HTTP::TokenAuth.parse_authentication_header(header)
        expect(credentials.token).to eq('h480djs93hd8')
        expect(credentials.coverage).to be_nil
        expect(credentials.nonce).to be_nil
        expect(credentials.auth).to be_nil
        expect(credentials.timestamp).to be_nil
      end
    end
  end
end
