# HTTP Authorization

Ruby gem that helps to build or parse an `Authorization` HTTP header. It currently supports the following schemes:

  - HTTP **Basic** and **Digest** Access Authentication, [RFC-2617](http://tools.ietf.org/html/rfc2617).
  - HTTP **Token** Access Authentication, [Draft](http://tools.ietf.org/html/draft-hammer-http-token-auth-01).

**WARNING**: Basic, Digest and Token Authentication are vulnerable to [man-in-the-middle attacks](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) unless used over [HTTPS](https://en.wikipedia.org/wiki/HTTPS). HTTPS means transmiting HTTP through SSL/TLS encrypted TCP sockets, thus protecting the exchange of secrets. If **all** communications happen over HTTPS, then using a simple mechanism like Basic, Digest or Token Authentication will be secure enough in most cases.

## Motivation

The reason I created this gem was to make it easier to authenticate REST APIs and **microservices** in Ruby when the HTTP libraries and frameworks being used do not offer _out of the box_ support for a specific scheme. This way, one can be free to choose the best tools to integrate its services based on other criteria. For example, performance or easiness of development.

The following table shows which authentication schemes some popular Ruby HTTP servers and frameworks support _out of the box_:

| HTTP Server | Basic | Digest | Token |
| --- | --- | --- | --- |
| [Rack](https://github.com/rack/rack) | Yes | Yes | - |
| [Grape](https://github.com/ruby-grape/grape) | Yes | Yes | - |
| [Sinatra](https://github.com/sinatra/sinatra) | - | - | - |
| [Rails](https://github.com/rails/rails) | Yes | Yes | Yes |

In contrast, these are the authentication schemes supported by most Ruby HTTP clients:

| HTTP Client | Basic | Digest | Token |
| --- | --- | --- | --- |
| [Net::HTTP](http://ruby-doc.org/stdlib-2.3.0/libdoc/net/http/rdoc/Net/HTTP.html) | Yes | [Plugin](https://github.com/drbrain/net-http-digest_auth) | - |
| [Faraday](https://github.com/lostisland/faraday) | Yes | - | Yes |
| [HTTParty](https://github.com/jnunemaker/httparty) | Yes | Yes | - |
| [REST Client](https://github.com/rest-client/rest-client) | Yes | - | - |
| [httpclient](https://github.com/nahi/httpclient) | Yes | Yes | - |
| [Excon](https://github.com/excon/excon) | Yes | - | - |
| [Typhoeus](https://github.com/typhoeus/typhoeus) | Yes | - | - |
| [Patron](https://github.com/toland/patron) | Yes | Yes | - |
| [EventMachine](https://github.com/igrigorik/em-http-request) | Yes | - | - |

## Installation

Add this line to your application's Gemfile:

  ```ruby
  gem 'http-authorization'
  ```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http-authorization

## Usage

This is an example that parses the response of a Digest Authentication in the `Authorization` HTTP header:

  ```ruby
  require 'http/auth'

  header_string = <<-EOS
    Digest qop="chap",
    realm="realm@example.com",
    username="foo",
    response="6629fae49393a05397450978507c4ef1",
    cnonce="5ccc069c403ebaf9f0171e9517f40e41"
  EOS

  header = HTTP::Auth::parse_authorization_header header_string
  header.scheme    # :digest
  header.qop       # "chap"
  header.realm     # "realm@example.com"
  header.username  # "foo"
  header.response  # "6629fae49393a05397450978507c4ef1"
  header.cnonce    # "5ccc069c403ebaf9f0171e9517f40e41"
  ```

Scheme values can be one of the following:

- `:basic`
- `:digest`
- `:token`

If given an unsupported authorization scheme, the `#scheme` property will return `nil`.
