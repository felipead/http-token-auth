require 'http/token_auth'

include HTTP::TokenAuth

describe Challenge do
  describe 'building an "WWW-Authenticate" HTTP response header with the token scheme' do
    it 'fails if realm is not defined' do
      expect do
        Challenge.new realm: nil, supported_coverages: [:none]
      end.to raise_error(ChallengeArgumentError).with_message(/"realm" is missing/)
    end

    it 'fails if a "none" coverage is combined with other coverages' do
      expect do
        Challenge.new realm: 'http://example.com',
                      supported_coverages: %i[none base base_body_sha_256]
      end.to raise_error(ChallengeArgumentError).with_message(
        /coverage "none" cannot be combined with other coverages/
      )
    end

    describe 'supported coverages' do
      it 'defaults to "base" coverage for an empty list of supported coveragess' do
        challenge = Challenge.new realm: 'http://example.com',
                                  supported_coverages: [],
                                  timestamp: 137131200

        expect(challenge.supported_coverages).to contain_exactly(:base)
      end

      it 'defaults to "base" coverage for a null list of supported coveragess' do
        challenge = Challenge.new realm: 'http://example.com',
                                  supported_coverages: nil,
                                  timestamp: 137131200

        expect(challenge.supported_coverages).to contain_exactly(:base)
      end
    end

    describe 'using a cryptographic algorithm' do
      it 'builds it with only "base" as supported coverage' do
        challenge = Challenge.new realm: 'http://example.com',
                                  supported_coverages: [:base],
                                  timestamp: 137131200

        header = challenge.to_header
        expect(header).to start_with('Token')
        expect(header).to include('realm="http://example.com"')
        expect(header).to include('coverage="base"')
        expect(header).to include('timestamp="137131200"')
      end

      it 'builds it with only "base+body-sha-256" as supported coverage' do
        challenge = Challenge.new realm: 'http://example.com',
                                  supported_coverages: [:base_body_sha_256],
                                  timestamp: 137131200

        header = challenge.to_header
        expect(header).to start_with('Token')
        expect(header).to include('realm="http://example.com"')
        expect(header).to include('coverage="base+body-sha-256"')
        expect(header).to include('timestamp="137131200"')
      end

      it 'builds it with "base" and "base+body-sha-256" as supported coverages' do
        challenge = Challenge.new realm: 'http://example.com',
                                  supported_coverages: %i[base base_body_sha_256],
                                  timestamp: 137131200

        header = challenge.to_header
        expect(header).to start_with('Token')
        expect(header).to include('realm="http://example.com"')
        expect(header).to include('coverage="base base+body-sha-256"')
        expect(header).to include('timestamp="137131200"')
      end

      it 'fails if timestamp is not defined' do
        expect do
          Challenge.new realm: 'http://example.com',
                        supported_coverages: %i[base base_body_sha_256],
                        timestamp: nil
        end.to raise_error(ChallengeArgumentError).with_message(/"timestamp" is missing/)
      end
    end

    describe 'without a cryptographic algorithm' do
      it 'builds it with only "none" as supported coverage' do
        challenge = Challenge.new realm: 'http://example.com',
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
