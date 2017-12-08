require 'http/token_auth'

include HTTP::TokenAuth

describe AuthorizationHeaderParser do
  describe 'given the value of an "Authorization" HTTP request header with the token scheme' do
    it 'fails if "token" is missing' do
      header = <<-HEADER
        Token coverage="base",
              nonce="dj83hs9s",
              auth="djosJKDKJSD8743243/jdk33klY=",
              timestamp="137131200"
      HEADER
      expect do
        HTTP::TokenAuth.parse_authorization_header(header)
      end.to raise_error(AuthorizationHeaderParsingError).with_message(/"token" is missing/)
    end

    it 'fails if "coverage" is different than "none", "base" or "base+body-sha-256"' do
      header = <<-HEADER
        Token token="h480djs93hd8",
              coverage="invalid",
              nonce="dj83hs9s",
              auth="djosJKDKJSD8743243/jdk33klY=",
              timestamp="137131200"
      HEADER
      expect do
        HTTP::TokenAuth.parse_authorization_header(header)
      end.to raise_error(AuthorizationHeaderParsingError).with_message(
        /Unsupported coverage "invalid"/
      )
    end

    describe 'using a cryptographic algorithm' do
      { 'base' => :base, 'base+body-sha-256' => :base_body_sha_256 }.each do |name, symbol|
        it %(parses it if coverage is "#{name}") do
          header = <<-HEADER
            Token token="h480djs93hd8",
                  coverage="#{name}",
                  nonce="dj83hs9s",
                  auth="djosJKDKJSD8743243/jdk33klY=",
                  timestamp="137131200"
          HEADER
          credentials = HTTP::TokenAuth.parse_authorization_header(header)
          expect(credentials.token).to eq('h480djs93hd8')
          expect(credentials.coverage).to eq(symbol)
          expect(credentials.nonce).to eq('dj83hs9s')
          expect(credentials.auth).to eq('djosJKDKJSD8743243/jdk33klY=')
          expect(credentials.timestamp).to eq(137131200)
        end
      end

      it 'fails if "nonce" is missing' do
        header = <<-HEADER
          Token token="h480djs93hd8",
                coverage="base",
                auth="djosJKDKJSD8743243/jdk33klY=",
                timestamp="137131200"
        HEADER
        expect do
          HTTP::TokenAuth.parse_authorization_header(header)
        end.to raise_error(AuthorizationHeaderParsingError).with_message(/"nonce" is missing/)
      end

      it 'fails if "auth" is missing' do
        header = <<-HEADER
          Token token="h480djs93hd8",
                coverage="base",
                nonce="dj83hs9s",
                timestamp="137131200"
        HEADER
        expect do
          HTTP::TokenAuth.parse_authorization_header(header)
        end.to raise_error(AuthorizationHeaderParsingError).with_message(/"auth" is missing/)
      end

      it 'fails if "timestamp" is missing' do
        header = <<-HEADER
          Token token="h480djs93hd8",
                coverage="base",
                nonce="dj83hs9s",
                auth="djosJKDKJSD8743243/jdk33klY="
        HEADER
        expect do
          HTTP::TokenAuth.parse_authorization_header(header)
        end.to raise_error(AuthorizationHeaderParsingError).with_message(/"timestamp" is missing/)
      end
    end

    describe 'without using a cryptographic algorithm' do
      it 'parses it if coverage is "none"' do
        header = <<-HEADER
          Token token="h480djs93hd8",
                coverage="none"
        HEADER
        credentials = HTTP::TokenAuth.parse_authorization_header(header)
        expect(credentials.token).to eq('h480djs93hd8')
        expect(credentials.coverage).to eq(:none)
        expect(credentials.nonce).to be_nil
        expect(credentials.auth).to be_nil
        expect(credentials.timestamp).to be_nil
      end

      it 'parses it if coverage is not defined' do
        header = <<-HEADER
          Token token="h480djs93hd8"
        HEADER
        credentials = HTTP::TokenAuth.parse_authorization_header(header)
        expect(credentials.token).to eq('h480djs93hd8')
        expect(credentials.coverage).to eq(:none)
        expect(credentials.nonce).to be_nil
        expect(credentials.auth).to be_nil
        expect(credentials.timestamp).to be_nil
      end
    end
  end
end
