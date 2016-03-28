require 'http/token_auth'

include HTTP::TokenAuth

describe Challenge do
  describe 'building an "WWW-Authenticate" HTTP response header with the token scheme' do
    it 'fails if realm is nil' do
      expect do
        Challenge.new realm: nil, supported_coverages: [:none]
      end.to raise_error(ChallengeArgumentError).with_message(/"realm" is missing/)
    end

    describe 'without a cryptographic algorithm' do
      it 'builds it with only "none" as supported coverage' do
        challenge = Challenge.new realm: 'http://example.com', supported_coverages: [:none]
        header = challenge.to_header
        expect(header).to start_with('Token')
        expect(header).to include('realm="http://example.com"')
        expect(header).to include('coverage="none"')
        expect(header).to_not include('timestamp')
      end
    end
  end
end
