# HTTP Token Access Authentication

Ruby gem to handle the [HTTP Token Access Authentication](http://tools.ietf.org/html/draft-hammer-http-token-auth-01), which is still a draft specification and may change in the future.

It supports both **parsing** and **building** a HTTP `Authentication` request header and a `WWW-Authenticate` response header using the token scheme.

The following authentication methods are supported:

- [x] [`none`](http://tools.ietf.org/html/draft-hammer-http-token-auth-01#section-7.1)
- [ ] [`hmac-sha-1`](http://tools.ietf.org/html/draft-hammer-http-token-auth-01#section-7.2)
- [ ] [`hmac-sha-256`](http://tools.ietf.org/html/draft-hammer-http-token-auth-01#section-7.3)
- [ ] [`rsassa-pkcs1-v1.5-sha-256`](http://tools.ietf.org/html/draft-hammer-http-token-auth-01#section-7.4)

Rather than being a complete opinionated authentication solution that only works with Rails or a specific HTTP framework, this library aims to be minimalistic and unobtrusive. This allows more flexibility and makes it compatible with virtually any HTTP servers and clients that run on the Ruby platform.

This library does not authenticate users nor provide methods for obtaining token credentials. For that you can use another protocol, such as [OAuth](http://tools.ietf.org/html/rfc5849), which is implemented by the [Ruby OAuth](https://github.com/oauth-xx/oauth-ruby) gem.

## Motivation

I created this library to help authenticate HTTP-based **microservices** and RESTful APIs in Ruby using token credentials.

Most user-facing applications need to authenticate their users before granting access to protected functionality and unlocking certain areas of the application. Service and microservice oriented architectures typically require an _authentication service_, responsible for validating user credentials such as e-mail and password. The application then sends user credentials to the authentication service using a secure protocol, such as [OAuth](http://tools.ietf.org/html/rfc5849). If authentication is successful, the authentication service will return a set of token credentials, which can be used to unlock other services in order to serve a set of features for the end user.

When receiving a HTTP request with a set token credentials, a service first needs to check if they are valid. That might include asking the authentication service if the token identifier is correct and was not expired. If credentials are valid, the service carries on with the request as expected. Otherwise, the request is denied with a `401 Unauthorized` status code.

The following sequence diagram illustrates the steps that need to happen for a successful token access authentication. In this example, an user-facing application needs to display private photos to its end user. First, it authenticates the user credentials using OAuth (it could use any other method for that). Then, in order to retrieve those photos, it makes a request to the _photo service_, which is the service responsible for the user photos domain. It also attaches to the request an `Authorization` request header with the token credentials. The photo service then validates those credentials before handling over the requested photos.

![Successful Token Access Authentication Diagram](https://rawgit.com/felipead/http-token-auth/master/doc/successful-token-authentication-diagram.svg)

If an unadvertised client makes a HTTP request to the photo service without providing valid token credentials, service is denied. The server sends a `401 Unauthorized` response with a `WWW-Authenticate` header containing the authentication challenge, which instructs the client on how to acquire token credentials.

![Service Denied Without Token Authorization Diagram](https://rawgit.com/felipead/http-token-auth/master/doc/service-denied-without-token-diagram.svg)

To protect itself against brute force or [DoS attacks](https://en.wikipedia.org/wiki/Denial-of-service_attack), the server should also throttle or reject consecutive requests with invalid token credentials coming from the same host.

Please keep in mind that the specification for Token Access Authentication does not define a method for authenticating users nor obtaining token credentials. It simply specifies how to transport and validate existing token credentials.

## Background

From the [specification](http://tools.ietf.org/html/draft-hammer-http-token-auth-01):

> The HTTP Basic and Digest Access authentication schemes defined by [RFC 2617](http://tools.ietf.org/html/rfc2617) enable clients to make authenticated HTTP requests by using a username (or userid) and a password. In most cases, the client uses a single set of credentials to access all the resources it controls which are hosted by the server.
>
> While the Basic and Digest schemes can be used to send credentials other than a username and password, their wide deployment and well-established behavior in user-agents preclude them from being used with other classes of credentials. Extending these schemes to support new classes would require an impractical change to their existing deployment.
>
> The Token Access Authentication scheme provides a method for making authenticated HTTP requests using a token - an identifier used to denote an access grant with specific scope, duration, cryptographic properties, and other attributes. Tokens can be issued by the server, self-issued by the client, or issued by a third-party.
>
> The token scheme supports an extensible set of credential classes, authentication methods (e.g. cryptographic algorithm), and authentication coverage (the elements of the HTTP request - such as the request URI or entity-body - covered by the authentication).

### Token Access Authentication without a Cryptographic Algorithm

The following HTTP request:

    GET /resource/1 HTTP/1.1
    Host: example.com

returns the following authentication challenge:

    HTTP/1.1 401 Unauthorized
    WWW-Authenticate: Token realm="http://example.com/",
                            coverage="none"

This response means the server is expecting the client to authenticate using the token scheme, with a set of token credentials issued for the `http://example.com/` realm. The `none` coverage method means the server does not employ a cryptographic algorithm and does not provide any security on its own. Servers utilizing this method use the token identifier as a bearer token, relying solely on the value of the token identifier to authenticate the client.

The client then uses another method to obtain the token credentials for accessing resources in the `http://example.com/` realm. In this example, the token identifier issued to the client is `h480djs93hd8`, and a new HTTP request is attempted:

    GET /resource/1 HTTP/1.1
    Host: example.com
    Authorization: Token token="h480djs93hd8"

Since this is a valid token, the request is authenticated and the server carries it on.

**WARNING**: Without a cryptographic algorithm, Token Access Authentication is insecure and vulnerable to [man-in-the-middle attacks](https://en.wikipedia.org/wiki/Man-in-the-middle_attack). This can be prevented by using HTTPS, which means transmitting HTTP through SSL/TLS encrypted TCP sockets, thus protecting the exchange of secrets and making sure no impostors are faking the server along the way.

### Token Access Authentication with a Cryptographic Algorithm

The following HTTP request:

    GET /resource/1 HTTP/1.1
    Host: example.com

returns the following authentication challenge:

    HTTP/1.1 401 Unauthorized
    WWW-Authenticate: Token realm="http://example.com/",
                            coverage="base base+body-sha-256",
                            timestamp="137131190"

The response means the server is expecting the client to authenticate using the token scheme, with a set of token credentials issued for the `http://example.com/` realm. The server supports the `base` and `base+body-sha-256` coverage methods which means the client must sign the base request components (e.g. host, port, request URI), and may also sign the request payload (entity-body). It also provides its current time to assist the client in synchronizing its clock with the server's clock for the purpose of producing a unique nonce value (used with some of the authentication methods).

The client has previously obtained a set of token credentials for accessing resources in the `http://example.com/` realm. The credentials issued to the client by the server included the following attributes:

- token: `h480djs93hd8`
- method: `hmac-sha-1`
- secret: `489dks293j39`
- expiration: `137217600`

The client attempts the HTTP request again, this time using the token credentials issued by the server earlier to authenticate. The client uses the `base` coverage method and applies the `hmac-sha-1` authentication method as dictated by the token credentials.

    GET /resource/1 HTTP/1.1
    Host: example.com
    Authorization: Token token="h480djs93hd8",
                         coverage="base",
                         timestamp="137131200",
                         nonce="dj83hs9s",
                         auth="djosJKDKJSD8743243/jdk33klY="

The server then authenticates the request and carries on as expected.

The following cryptographic authentication methods are defined in the specification:

- [`hmac-sha-1`](http://tools.ietf.org/html/draft-hammer-http-token-auth-01#section-7.2)
- [`hmac-sha-256`](http://tools.ietf.org/html/draft-hammer-http-token-auth-01#section-7.3)
- [`rsassa-pkcs1-v1.5-sha-256`](http://tools.ietf.org/html/draft-hammer-http-token-auth-01#section-7.4)

## Usage

### Parsing an `Authorization` Header

  ```ruby
  require 'http/token_auth'

  header = <<-EOS
    Token token="h480djs93hd8",
          coverage="base",
          timestamp="137131200",
          nonce="dj83hs9s",
          auth="djosJKDKJSD8743243/jdk33klY="
  EOS

  credentials = HTTP::TokenAuth.parse_authorization_header(header)
  credentials.token     # "h480djs93hd8"
  credentials.coverage  # :base
  credentials.timestamp # 137131200
  credentials.nonce     # "dj83hs9s"
  credentials.auth      # "djosJKDKJSD8743243/jdk33klY="
  ```

### Building an `Authorization` Header

#### Without a Cryptographic Algorithm

A nil `coverage` parameter translates to `coverage="none"` when building the header. However, the specification states that if coverage is `none`, then it can be ommited from the header string.

If coverage is "none", the `nonce`, `auth` and `timestamp` attributes are not used and should not be included in the header.

  ```ruby
  require 'http/token_auth'

  credentials = HTTP::TokenAuth::Credentials.new token: 'h480djs93hd8',
                                                 coverage: :none

  credentials.to_header

  # Token token="h480djs93hd8"
  ```

#### With a Cryptographic Algorithm

A cryptographic algorithm is used if coverage is set to `:basic` or `:base_body_sha_256`, which translates to the `coverage="base"` and `coverage="base+body-sha-256"` header attributes, respectively.

In this case, it is mandatory to specify the values of the `nonce`, `auth` and `timestamp` attributes. Details on how to fill those attributes depend on the cryptographic algorithm being used and can be found in the specification.

  ```ruby
  require 'http/token_auth'

  credentials = HTTP::TokenAuth::Credentials.new token: 'h480djs93hd8',
                                                 coverage: :base_body_sha_256,
                                                 nonce: 'dj83hs9s',
                                                 auth: 'djosJKDKJSD8743243/jdk33klY='
                                                 timestamp: 137131200,

  credentials.to_header

  # Token token="h480djs93hd8",
  #       coverage="base+body-sha-256",
  #       nonce="dj83hs9s",
  #       auth="djosJKDKJSD8743243/jdk33klY=",
  #       timestamp="137131200"
  ```

### Parsing a `WWW-Authenticate` Header

  ```ruby
  require 'http/token_auth'

  header = <<-EOS
    Token realm="http://example.com",
          coverage="base base+body-sha-256",
          timestamp="137131200"
  EOS

  challenge = HTTP::TokenAuth.parse_www_authenticate_header(header)
  challenge.realm                # "http://example.com"
  challenge.supported_coverages  # [:base, :base_body_sha_256]
  challenge.timestamp            # 137131200
  ```

### Building a `WWW-Authenticate` Header

#### Without a Cryptographic Algorithm

To create an authentication challenge without support for a cryptographic algorithm, pass `:none` as an element of the list `supported_coverages`. If not set, this list defaults to "base" as dictated by the specification, which requires a cryptographic algorithm.

It's also mandatory to specify the `realm` attribute with the authentication realm URI.

  ```ruby
  require 'http/token_auth'

  challenge = HTTP::TokenAuth::Challenge.new realm: 'http://example.com'
                                             supported_coverages: [:none]

  challenge.to_header

  # Token realm="http://example.com",
  #       coverage="none"
  ```

#### With a Cryptographic Algorithm

To create an authentication challenge with support for a cryptographic algorithm, you can pass `:base`, `:base_body_sha256` or both as elements of the list `supported_coverages`. It's also mandatory to specify the `realm` attribute with the authenticaiton realm URI and the `timestamp` attribute with the server's Unix timestamp.

  ```ruby
  require 'http/token_auth'

  challenge = HTTP::TokenAuth::Challenge.new realm: 'http://example.com',
                                             supported_coverages: [:base, :base_body_sha_256],
                                             timestamp: 137131200

  challenge.to_header

  # Token realm="http://example.com",
  #       coverage="base base+body-sha-256",
  #       timestamp="137131200"
  ```

## Installation

Add this line to your application's Gemfile:

  ```ruby
  gem 'http-token-auth'
  ```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http-token-auth

## Development

Install required gems:

    $ bundle install

Running [rspec](http://rspec.info/) tests and checking for [rubocop](http://batsov.com/rubocop/) violations:

    $ bundle exec rake

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/felipead/http-token-auth.

## License

This software is released under the mighty [MIT License](LICENSE.txt).
