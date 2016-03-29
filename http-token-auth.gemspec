# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http/token_auth/version'

Gem::Specification.new do |gem|
  gem.name                  = 'http-token-auth'
  gem.version               = HTTP::TokenAuth::VERSION
  gem.required_ruby_version = '>= 2.0.0'

  gem.authors  = ['Felipe Dornelas']
  gem.email    = ['m@felipedornelas.com']
  gem.homepage = 'https://github.com/felipead/http-token-auth'
  gem.license  = 'MIT'

  gem.summary     = %s{Ruby gem to handle the HTTP Token Access Authentication draft specification, for securing HTTP-based service and microservice architectures using token credentials.}

  gem.description = %s{Ruby gem to handle the HTTP Token Access Authentication draft specification, for securing HTTP-based service and microservice architectures using token credentials.

It supports both parsing and building a HTTP "Authentication" request header and a "WWW-Authenticate" response header using the token scheme.

Rather than being a complete opinionated authentication solution that only works with Rails or a specific HTTP framework, this library aims to be minimalistic and unobtrusive. This allows more flexibility and makes it compatible with virtually any HTTP servers and clients that run on the Ruby platform.

This library does not authenticate users nor provide methods for obtaining token credentials. For that you can use another protocol, such as OAuth - http://tools.ietf.org/html/rfc5849.}

  gem.files         = `git ls-files bin lib http-token-auth.gemspec LICENSE.txt`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.11'
  gem.add_development_dependency 'rake', '~> 10.0'
end
