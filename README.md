# HTTP Authorization Header

Ruby gem that parses the `Authorization` HTTP header. It currently supports the following authentication schemes:

  - HTTP Basic and Digest Access Authentication ([RFC-2617](http://tools.ietf.org/html/rfc2617)).
  - HTTP Token Access Authentication ([Draft Specification](http://tools.ietf.org/html/draft-hammer-http-token-auth-01)).

The reason I created this gem was to make it easier to authenticate REST APIs and microservices in Ruby when the HTTP framework being used does not offer support for a specific Auth scheme.

**WARNING**: Basic, Digest and Token Authentication are insecure and vulnerable to [man-in-the-middle attacks](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) unless used over [HTTPS](https://en.wikipedia.org/wiki/HTTPS). HTTPS means transmiting HTTP through SSL/TLS encrypted TCP sockets, thus protecting the exchange of secrets. If all communications happen over HTTPS, then using a simple mechanism like Basic, Digest or Token Authentication will be secure enough in most cases.

## Installation

Add this line to your application's Gemfile:

  ```ruby
  gem 'http-authorization-header'
  ```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http-authorization-header

## Usage

This is an example that parses the response of a Digest Authentication in the `Authorization` HTTP header:

  ```ruby
  require 'http_authorization_header'
  
  authorization_string = <<-EOS
    Digest qop="chap",
    realm="realm@example.com",
    username="foo",
    response="6629fae49393a05397450978507c4ef1",
    cnonce="5ccc069c403ebaf9f0171e9517f40e41"
  EOS
  
  authorization = HttpAuthorizationHeader.new authorization_string
  authorization.scheme    # :digest
  authorization.qop       # "chap"
  authorization.realm     # "realm@example.com"
  authorization.username  # "foo"
  authorization.response  # "6629fae49393a05397450978507c4ef1"
  authorization.cnonce    # "5ccc069c403ebaf9f0171e9517f40e41"
  ```

Scheme values can be one of the following:

- `:basic`
- `:digest`
- `:token`

If given an unsupported authorization scheme, the `#scheme` property will return `nil`.
