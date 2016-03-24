module HTTP
  class TokenAuth
    attr_reader :token, :coverage, :nonce, :auth, :timestamp

    def initialize(attributes)
      @token = must_have_token(strip_whitespace(attributes[:token]))
      @coverage = must_have_coverage_or_default(strip_whitespace(attributes[:coverage]))
      @nonce = strip_whitespace(attributes[:nonce])
      @auth = strip_whitespace(attributes[:auth])
      @timestamp = strip_whitespace(attributes[:timestamp])
    end

    def self.parse_header(string)
      schema, attributes_string = split_header(string)
      raise ArgumentError, "Invalid schema #{schema}" unless schema == 'Token'
      TokenAuth.new parse_attributes(attributes_string)
    end

    def to_s
      attributes = []
      attributes << %(token="#{@token}")
      attributes << %(coverage="#{@coverage}")
      attributes << %(nonce="#{@nonce}") if @nonce
      attributes << %(auth="#{@auth}") if @auth
      attributes << %(timestamp="#{@timestamp}") if @timestamp

      "Token #{attributes.join(', ')}"
    end

    private

    def must_have_token(token)
      raise ArgumentError, '"token" attribute is required' unless token && !token.empty?
      token
    end

    def must_have_coverage_or_default(coverage)
      (coverage && !coverage.empty?) ? coverage : 'base'
    end

    def strip_whitespace(string)
      string.nil? ? nil : string.strip
    end

    def self.split_header(string)
      string.split(' ', 2)
    end

    def self.parse_attributes(string)
      attributes = {}
      string.scan(/(\w+)="([^"]*)"/).each do |group|
        attributes[group[0].to_sym] = group[1]
      end
      attributes
    end

    private_class_method :split_header, :parse_attributes
  end
end
