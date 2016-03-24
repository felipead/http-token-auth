# HTTP Token Access Authentication

Ruby gem to handle the [HTTP Token Access Authentication](http://tools.ietf.org/html/draft-hammer-http-token-auth-01), which is still a draft specification.

I created this library to make it easier to authenticate REST APIs and **microservices** in Ruby using access tokens, without having to resort to complex protocols such as [OAuth 1.0](http://tools.ietf.org/html/rfc5849) or [OAuth 2.0](http://tools.ietf.org/html/rfc6749).

**WARNING**: Token Access Authentication, as well as Basic and Digest Access Authentication defined in [RFC-2617](http://tools.ietf.org/html/rfc2617), is vulnerable to [man-in-the-middle attacks](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) unless used over [HTTPS](https://en.wikipedia.org/wiki/HTTPS). HTTPS means transmiting HTTP through SSL/TLS encrypted TCP sockets, thus protecting the exchange of secrets and making sure no impostors are faking the server along the communication channel.

## Background

From the [draft specification](http://tools.ietf.org/html/draft-hammer-http-token-auth-01):

> With the growing use of distributed web services and cloud computing, clients need to allow other parties access to the resources they control. When granting access, clients should not be required to share their credentials (typically a username and password). Clients should also have the ability to restrict access to a limited subset of the resources they control or limit access to the methods supported by these resources. These goals require new classes of authentication credentials.
>
> The HTTP Basic and Digest Access authentication schemes defined by [RFC2617](http://tools.ietf.org/html/rfc2617), enable clients to make authenticated HTTP requests by using a username (or userid) and a password. In most cases, the client uses a single set of credentials to access all the resources it controls which are hosted by the server.
>
> While the Basic and Digest schemes can be used to send credentials other than a username and password, their wide deployment and well-established behavior in user-agents preclude them from being used with other classes of credentials. Extending these schemes to support new classes would require an impractical change to their existing deployment.
>
> The Token Access Authentication scheme provides a method for making authenticated HTTP requests using a token - an identifier used to denote an access grant with specific scope, duration, cryptographic properties, and other attributes. Tokens can be issued by the server, self-issued by the client, or issued by a third-party.
>
> The token scheme supports an extensible set of credential classes, authentication methods (e.g. cryptographic algorithm), and authentication coverage (the elements of the HTTP request - such as the request URI or entity-body - covered by the authentication).

For example, the following HTTP request:

    GET /resource/1 HTTP/1.1
    Host: example.com

returns the following authentication challenge:

    HTTP/1.1 401 Unauthorized
    WWW-Authenticate: Token realm="http://example.com/",
                            coverage="base base+body-sha-256",
                            timestamp="137131190"


The response means the server is expecting the client to authenticate using the token scheme, with a set of token credentials issued for the `http://example.com/` realm.The server supports the "base" and "base+body-sha-256"coverage methods which means the client must sign the base request components (e.g. host, port, request URI), and may also sign the request payload (entity-body).It also provides its current time to assist the client in synchronizing its clock with the server's clock for the purpose of producing a unique nonce value (used with some of the authentication methods).

The client has previously obtained a set of token credentials for accessing resources in the `http://example.com/` realm. The credentials issued to the client by the server included the following attributes:

- token: `h480djs93hd8`
- method: `hmac-sha-1`
- secret: `489dks293j39`
- expiration: `137217600`

The client attempts the HTTP request again, this time using the token credentials issued by the server earlier to authenticate. The client uses the "base" coverage method and applies the "hmac-sha-1" authentication method as dictated by the token credentials.

    GET /resource/1 HTTP/1.1
    Host: example.com
    Authorization: Token token="h480djs93hd8",
                         coverage="base",
                         timestamp="137131200",
                         nonce="dj83hs9s",
                         auth="djosJKDKJSD8743243/jdk33klY="


to which the server respond with the requested resource representation after validating the request.

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
