require 'http/authorization'

describe HTTP::Authorization::Header do
  it 'parses a token schema' do
    header = HTTP::Authorization::Header.new 'Token token="foobar"'
    expect(header.schema).to eq(:token)
  end
end
