# HTTP Token Access Authentication

Ruby gem to handle the [HTTP Token Access Authentication](http://tools.ietf.org/html/draft-hammer-http-token-auth-01), which is still a draft specification and may change in the future.

Currently, it only supports

## Motivation

I created this gem to make it easier to authenticate HTTP-based **microservices** and RESTful APIs in Ruby using access tokens.

Most user-facing applications need to authenticate their users before granting access to protected functionality and unlocking certain areas of the application. Service and microservice oriented architectures tipically use an authentication service, responsible for the "user" domain and for validating user credentials such as e-mail and password. The application then sends user credentials to the authentication service using a secure protocol, such as [OAuth](http://tools.ietf.org/html/rfc5849). If authentication is successful, the authentication service will return an access token, tipically a random hexadecimal string like `"e59ff97941044f85df5297e1c302d260"`. This token can be used to unlock other services in order to securely provide the desired functionality for the end user.

When receiving a HTTP request with an access token, a service first asks the authentication service if that token is valid. If it is, the service carries on with the request as expected. Otherwise, the request is denied with a `401 Unauthorized` status code.

The following sequence diagram illustrates the steps that need to happen for a successful token access authentication. In this example, an user-facing application needs to display private photos to its end user. First, it authenticates the user credentials using OAuth (it could use any other protocol for that). Then, in order to retrieve those photos, it make requests to another service. Since the photos are sensitive and private, this service needs to validate the token before handling over them.

![Successful Token Access Authentication Diagram](https://rawgit.com/felipead/http-token-auth/master/doc/successful-token-authentication-diagram.svg)

Now, if an unexpected client makes a HTTP request to the photos service without providing an access token, service is denied:

![Service Denied Without Token Diagram](https://rawgit.com/felipead/http-token-auth/master/doc/service-denied-without-token-diagram.svg)

Here, we illustrate what should happen if an impostor client tries to steal the private photos using brute force:

![Service Denied Due To Brute Force Attack Diagram](https://rawgit.com/felipead/http-token-auth/master/doc/service-denied-brute-force-attack-diagram.svg)

Please keep in mind that the specification for Token Access Authentication does not define a protocol for authenticating user credentials or a way for clients to obtain access tokens. It simply specifies methods to transport and validate a token.

## Background

From the [draft specification](http://tools.ietf.org/html/draft-hammer-http-token-auth-01):

> With the growing use of distributed web services and cloud computing, clients need to allow other parties access to the resources they control. When granting access, clients should not be required to share their credentials (typically a username and password). Clients should also have the ability to restrict access to a limited subset of the resources they control or limit access to the methods supported by these resources. These goals require new classes of authentication credentials.
>
> The HTTP Basic and Digest Access authentication schemes defined by [RFC-2617](http://tools.ietf.org/html/rfc2617), enable clients to make authenticated HTTP requests by using a username (or userid) and a password. In most cases, the client uses a single set of credentials to access all the resources it controls which are hosted by the server.
>
> While the Basic and Digest schemes can be used to send credentials other than a username and password, their wide deployment and well-established behavior in user-agents preclude them from being used with other classes of credentials. Extending these schemes to support new classes would require an impractical change to their existing deployment.
>
> The Token Access Authentication scheme provides a method for making authenticated HTTP requests using a token - an identifier used to denote an access grant with specific scope, duration, cryptographic properties, and other attributes. Tokens can be issued by the server, self-issued by the client, or issued by a third-party.
>
> The token scheme supports an extensible set of credential classes, authentication methods (e.g. cryptographic algorithm), and authentication coverage (the elements of the HTTP request - such as the request URI or entity-body - covered by the authentication).
>
> This specification defines four token authentication methods to support the most common use cases and describes their security properties. The methods through which clients obtain tokens supporting these methods are beyond the scope of this specification. The [OAuth protocol](http://tools.ietf.org/html/draft-ietf-oauth-web-delegation-01) defines one such set of methods for obtaining token credentials.

For example, the following HTTP request:

    GET /resource/1 HTTP/1.1
    Host: example.com

returns the following authentication challenge:

    HTTP/1.1 401 Unauthorized
    WWW-Authenticate: Token realm="http://example.com/",
                            coverage="base base+body-sha-256",
                            timestamp="137131190"


The response means the server is expecting the client to authenticate using the token scheme, with a set of token credentials issued for the `"http://example.com/"` realm. The server supports the `"base"` and `"base+body-sha-256"` coverage methods which means the client must sign the base request components (e.g. host, port, request URI), and may also sign the request payload (entity-body). It also provides its current time to assist the client in synchronizing its clock with the server's clock for the purpose of producing a unique nonce value (used with some of the authentication methods).

The client has previously obtained a set of token credentials for accessing resources in the `http://example.com/` realm. The credentials issued to the client by the server included the following attributes:

- token: `h480djs93hd8`
- method: `hmac-sha-1`
- secret: `489dks293j39`
- expiration: `137217600`

The client attempts the HTTP request again, this time using the token credentials issued by the server earlier to authenticate. The client uses the `"base"` coverage method and applies the `"hmac-sha-1"` authentication method as dictated by the token credentials.

    GET /resource/1 HTTP/1.1
    Host: example.com
    Authorization: Token token="h480djs93hd8",
                         coverage="base",
                         timestamp="137131200",
                         nonce="dj83hs9s",
                         auth="djosJKDKJSD8743243/jdk33klY="


to which the server respond with the requested resource representation after validating the request.

## Usage

Parsing a Token Access Authentication header:

  ```ruby
  require 'http/token_auth'

  header <<-EOS
    Token token="h480djs93hd8",
          coverage="base",
          timestamp="137131200",
          nonce="dj83hs9s",
          auth="djosJKDKJSD8743243/jdk33klY="
  EOS

  parsed = HTTP::TokenAuth.parse_header(header)
  parsed.token     # "h480djs93hd8"
  parsed.coverage  # "base"
  parsed.timestamp # "137131200"
  parsed.nonce     # "dj83hs9s"
  parsed.auth      # "djosJKDKJSD8743243"
  ```

Building a Token Access Authentication header:

  ```ruby
  require 'http/token_auth'

  header = HTTP::TokenAuth.new(
    token: 'h480djs93hd8',
    coverage: 'base',
    timestamp: '137131200',
    nonce: 'dj83hs9s',
    auth: 'djosJKDKJSD8743243'
  )

  header.to_s # The header string
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

Running tests:

    $ bundle exec rspec

Running code linter:

    $ bundle exec rubocop


## License

This software is released under the mighty [MIT License](LICENSE).
