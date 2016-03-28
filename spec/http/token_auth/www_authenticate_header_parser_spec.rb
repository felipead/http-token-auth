require 'http/token_auth'

include HTTP::TokenAuth

describe WWWAuthenticateHeaderParser do
  it 'fails if "realm" is not defined' do
    header = 'Token coverage="none"'
    expect do
      HTTP::TokenAuth.parse_www_authenticate_header(header)
    end.to raise_error(WWWAuthenticateHeaderParsingError).with_message(/"realm" is missing/)
  end

  describe 'without using a cryptographic algorithm' do
    it 'parses it if "coverage" is "none"' do
      header = <<-EOS
        Token realm="http://example.com",
              coverage="none"
      EOS
      challenge = HTTP::TokenAuth.parse_www_authenticate_header(header)
      expect(challenge.realm).to eq('http://example.com')
      expect(challenge.supported_coverages).to contain_exactly(:none)
      expect(challenge.timestamp).to be_nil
    end
  end
end
