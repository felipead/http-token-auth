module HTTP
  class TokenAuthArgumentError < StandardError
    def initialize(argument)
      super(%(Invalid token credentials: "#{argument}" is missing))
    end
  end

  class TokenAuthHeaderParsingError < StandardError
    def initialize(submessage)
      super(%(Error parsing token schema "Authorization" header: #{submessage}))
    end
  end

  class TokenAuth
    attr_reader :token, :coverage, :nonce, :auth, :timestamp

    def initialize(token:, coverage: nil, nonce: nil, auth: nil, timestamp: nil)
      @token = token
      @coverage = coverage
      @nonce = nonce
      @auth = auth
      @timestamp = timestamp
      validate_itself
    end

    def self.parse_header(string)
      schema, attributes_string = split_header(string)
      raise ArgumentError, "Invalid schema #{schema}" unless schema == 'Token'
      from_attributes parse_attributes(attributes_string)
    end

    def to_header
      attributes = []
      attributes << %(token="#{@token}")
      unless coverage.nil?
        attributes << %(coverage="#{coverage_name}")
        attributes << %(nonce="#{@nonce}")
        attributes << %(auth="#{@auth}")
        attributes << %(timestamp="#{@timestamp}")
      end
      "Token #{attributes.join(', ')}"
    end

    private

    def validate_itself
      must_have_token
      return if @coverage.nil?
      must_have_nonce
      must_have_auth
      must_have_timestamp
    end

    def must_have_token
      raise TokenAuthArgumentError, 'token' if @token.nil? || @token.empty?
    end

    def must_have_nonce
      raise TokenAuthArgumentError, 'nonce' if @nonce.nil? || @nonce.empty?
    end

    def must_have_auth
      raise TokenAuthArgumentError, 'auth' if @auth.nil? || @auth.empty?
    end

    def must_have_timestamp
      raise TokenAuthArgumentError, 'timestamp' if @timestamp.nil?
    end

    def coverage_name
      case @coverage
      when :base then 'base'
      when :base_body_sha_256 then 'base+body-sha-256'
      end
    end

    def self.split_header(string)
      string.split(' ', 2)
    end
    private_class_method :split_header

    def self.parse_attributes(string)
      attributes = {}
      string.scan(/(\w+)="([^"]*)"/).each do |group|
        attributes[group[0].to_sym] = group[1]
      end
      attributes
    end
    private_class_method :parse_attributes

    def self.from_attributes(attributes)
      TokenAuth.new token: attributes[:token],
                    coverage: parse_coverage(attributes[:coverage]),
                    nonce: attributes[:nonce],
                    auth: attributes[:auth],
                    timestamp: parse_timestamp(attributes[:timestamp])
    end
    private_class_method :from_attributes

    def self.parse_coverage(coverage)
      return nil if coverage.nil? || coverage.empty?
      case coverage
      when 'none' then nil
      when 'base' then :base
      when 'base+body-sha-256' then :base_body_sha_256
      else raise TokenAuthHeaderParsingError, %(Invalid coverage "#{coverage}")
      end
    end
    private_class_method :parse_coverage

    def self.parse_timestamp(timestamp)
      timestamp.nil? ? nil : timestamp.to_i
    end
    private_class_method :parse_timestamp
  end
end
