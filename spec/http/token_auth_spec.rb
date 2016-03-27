require 'http/token_auth'

describe HTTP::TokenAuth do
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
          credentials = HTTP::TokenAuth.parse_header(header)
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
          HTTP::TokenAuth.parse_header(header)
        end.to raise_error(HTTP::TokenAuthHeaderParsingError).with_message(
          /Invalid coverage "invalid"/)
      end
    end

    describe 'without using a cryptographic algorithm' do
      it 'parses it if coverage is "none"' do
        header = <<-EOS
          Token token="h480djs93hd8",
                coverage="none"
        EOS
        credentials = HTTP::TokenAuth.parse_header(header)
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
        credentials = HTTP::TokenAuth.parse_header(header)
        expect(credentials.token).to eq('h480djs93hd8')
        expect(credentials.coverage).to be_nil
        expect(credentials.nonce).to be_nil
        expect(credentials.auth).to be_nil
        expect(credentials.timestamp).to be_nil
      end
    end
  end

  describe 'building an "Authentication" HTTP header with the token scheme' do
    it 'fails if token is not defined' do
      expect do
        HTTP::TokenAuth.new token: nil,
                            coverage: :base,
                            nonce: 'dj83hs9s',
                            auth: 'djosJKDKJSD8743243/jdk33klY=',
                            timestamp: 137131200
      end.to raise_error(HTTP::TokenAuthArgumentError).with_message(
        'Invalid token credentials: "token" is missing')
    end

    describe 'using a cryptographic algorithm' do
      { 'base' => :base, 'base+body-sha-256' => :base_body_sha_256 }.each do |name, symbol|
        it %(builds it if coverage is "#{name}") do
          credentials = HTTP::TokenAuth.new token: 'h480djs93hd8',
                                            coverage: symbol,
                                            nonce: 'dj83hs9s',
                                            auth: 'djosJKDKJSD8743243/jdk33klY=',
                                            timestamp: 137131200

          header = credentials.to_header
          expect(header).to start_with('Token')
          expect(header).to include('token="h480djs93hd8"')
          expect(header).to include(%(coverage="#{name}"))
          expect(header).to include('nonce="dj83hs9s"')
          expect(header).to include('auth="djosJKDKJSD8743243/jdk33klY="')
          expect(header).to include('timestamp="137131200"')
        end
      end

      it 'fails if nonce is not defined' do
        expect do
          HTTP::TokenAuth.new token: 'h480djs93hd8',
                              coverage: :base,
                              auth: 'djosJKDKJSD8743243/jdk33klY=',
                              timestamp: 137131200
        end.to raise_error(HTTP::TokenAuthArgumentError).with_message(
          'Invalid token credentials: "nonce" is missing')
      end

      it 'fails if auth is not defined' do
        expect do
          HTTP::TokenAuth.new token: 'h480djs93hd8',
                              coverage: :base,
                              nonce: 'dj83hs9s',
                              timestamp: 137131200
        end.to raise_error(HTTP::TokenAuthArgumentError).with_message(
          'Invalid token credentials: "auth" is missing')
      end

      it 'fails if timestamp is not defined' do
        expect do
          HTTP::TokenAuth.new token: 'h480djs93hd8',
                              coverage: :base,
                              nonce: 'dj83hs9s',
                              auth: 'djosJKDKJSD8743243/jdk33klY='
        end.to raise_error(HTTP::TokenAuthArgumentError).with_message(
          'Invalid token credentials: "timestamp" is missing')
      end
    end

    describe 'without using a cryptographic algorithm' do
      it 'builds it if coverage is "none"' do
        credentials = HTTP::TokenAuth.new token: 'h480djs93hd8',
                                          coverage: nil

        header = credentials.to_header
        expect(header).to start_with('Token')
        expect(header).to include('token="h480djs93hd8"')
        expect(header).to_not include('coverage')
        expect(header).to_not include('nonce')
        expect(header).to_not include('auth')
        expect(header).to_not include('timestamp')
      end

      it 'builds it if coverage is not defined' do
        credentials = HTTP::TokenAuth.new token: 'h480djs93hd8'

        header = credentials.to_header
        expect(header).to start_with('Token')
        expect(header).to include('token="h480djs93hd8"')
        expect(header).to_not include('coverage')
        expect(header).to_not include('nonce')
        expect(header).to_not include('auth')
        expect(header).to_not include('timestamp')
      end
    end
  end
end
