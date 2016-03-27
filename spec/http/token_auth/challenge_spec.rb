require 'http/token_auth'

describe HTTP::TokenAuth::Challenge do
  describe 'building an "WWW-Authenticate" HTTP response header with the token scheme' do
    describe 'without a cryptographic algorithm' do
      it 'builds it with only "none" as supported coverage method' do
        challenge = HTTP::TokenAuth::Challenge.new realm: 'http://example.com',
                                                   supported_coverages: [:none]
        header = challenge.to_header
        expect(header).to start_with('Token')
        expect(header).to include('realm="http://example.com"')
        expect(header).to include('coverage="none"')
        expect(header).to_not include('timestamp')
      end
    end
  end
end
