require 'http/token_auth'

include HTTP::TokenAuth

describe WWWAuthenticateHeaderParser do
  describe 'given the value of an "WWW-Authenticate" HTTP response header with the token scheme' do
    it 'fails if "realm" is missing' do
      header = 'Token coverage="none"'
      expect do
        HTTP::TokenAuth.parse_www_authenticate_header(header)
      end.to raise_error(WWWAuthenticateHeaderParsingError).with_message(/"realm" is missing/)
    end

    it 'fails with a coverage different than "none", "base" or "base+body-sha-256"' do
      header = <<-HEADER
          Token realm="http://example.com",
                coverage="invalid",
                timestamp="137131200"
        HEADER
      expect do
        HTTP::TokenAuth.parse_www_authenticate_header(header)
      end.to raise_error(WWWAuthenticateHeaderParsingError).with_message(
        /Unsupported coverage "invalid"/
      )
    end

    describe 'using a cryptographic algorithm' do
      it 'parses it if "coverage" is "base"' do
        header = <<-HEADER
          Token realm="http://example.com",
                coverage="base",
                timestamp="137131200"
        HEADER
        challenge = HTTP::TokenAuth.parse_www_authenticate_header(header)
        expect(challenge.realm).to eq('http://example.com')
        expect(challenge.supported_coverages).to contain_exactly(:base)
        expect(challenge.timestamp).to eq(137131200)
      end

      it 'parses it if "coverage" is "base+body-sha-256"' do
        header = <<-HEADER
          Token realm="http://example.com",
                coverage="base+body-sha-256",
                timestamp="137131200"
        HEADER
        challenge = HTTP::TokenAuth.parse_www_authenticate_header(header)
        expect(challenge.realm).to eq('http://example.com')
        expect(challenge.supported_coverages).to contain_exactly(:base_body_sha_256)
        expect(challenge.timestamp).to eq(137131200)
      end

      it 'parses it if "coverage" is both "base" and "base+body-sha-256"' do
        header = <<-HEADER
          Token realm="http://example.com",
                coverage="base base+body-sha-256",
                timestamp="137131200"
        HEADER
        challenge = HTTP::TokenAuth.parse_www_authenticate_header(header)
        expect(challenge.realm).to eq('http://example.com')
        expect(challenge.supported_coverages).to contain_exactly(:base, :base_body_sha_256)
        expect(challenge.timestamp).to eq(137131200)
      end

      it 'defaults to "base" coverage if coverage is not defined' do
        header = <<-HEADER
          Token realm="http://example.com"
                timestamp="137131200"
          HEADER
        challenge = HTTP::TokenAuth.parse_www_authenticate_header(header)
        expect(challenge.realm).to eq('http://example.com')
        expect(challenge.supported_coverages).to contain_exactly(:base)
        expect(challenge.timestamp).to eq(137131200)
      end

      it 'fails if "timestamp" is missing' do
        header = <<-HEADER
          Token realm="http://example.com",
                coverage="base"
        HEADER
        expect do
          HTTP::TokenAuth.parse_www_authenticate_header(header)
        end.to raise_error(WWWAuthenticateHeaderParsingError).with_message(/"timestamp" is missing/)
      end
    end

    describe 'without using a cryptographic algorithm' do
      it 'parses it if "coverage" is "none"' do
        header = <<-HEADER
          Token realm="http://example.com",
                coverage="none"
        HEADER
        challenge = HTTP::TokenAuth.parse_www_authenticate_header(header)
        expect(challenge.realm).to eq('http://example.com')
        expect(challenge.supported_coverages).to contain_exactly(:none)
        expect(challenge.timestamp).to be_nil
      end
    end
  end
end
