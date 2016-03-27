require 'http/token_auth'

include HTTP::TokenAuth

describe Credentials do
  describe 'building an "Authentication" HTTP header with the token scheme' do
    it 'fails if token is not defined' do
      expect do
        Credentials.new token: nil,
                        coverage: :base,
                        nonce: 'dj83hs9s',
                        auth: 'djosJKDKJSD8743243/jdk33klY=',
                        timestamp: 137131200
      end.to raise_error(MissingCredentialsArgumentError).with_message(
        'Invalid token credentials: "token" is missing')
    end

    describe 'using a cryptographic algorithm' do
      { 'base' => :base, 'base+body-sha-256' => :base_body_sha_256 }.each do |name, symbol|
        it %(builds it if coverage is "#{name}") do
          credentials = Credentials.new token: 'h480djs93hd8',
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
          Credentials.new token: 'h480djs93hd8',
                          coverage: :base,
                          auth: 'djosJKDKJSD8743243/jdk33klY=',
                          timestamp: 137131200
        end.to raise_error(MissingCredentialsArgumentError).with_message(
          'Invalid token credentials: "nonce" is missing')
      end

      it 'fails if auth is not defined' do
        expect do
          Credentials.new token: 'h480djs93hd8',
                          coverage: :base,
                          nonce: 'dj83hs9s',
                          timestamp: 137131200
        end.to raise_error(MissingCredentialsArgumentError).with_message(
          'Invalid token credentials: "auth" is missing')
      end

      it 'fails if timestamp is not defined' do
        expect do
          Credentials.new token: 'h480djs93hd8',
                          coverage: :base,
                          nonce: 'dj83hs9s',
                          auth: 'djosJKDKJSD8743243/jdk33klY='
        end.to raise_error(MissingCredentialsArgumentError).with_message(
          'Invalid token credentials: "timestamp" is missing')
      end
    end

    describe 'without using a cryptographic algorithm' do
      it 'builds it if coverage is "none"' do
        credentials = Credentials.new token: 'h480djs93hd8',
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
        credentials = Credentials.new token: 'h480djs93hd8'

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
