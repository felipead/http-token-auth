require 'English'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http/token_auth/version'

Gem::Specification.new do |gem|
  gem.name                  = 'http-token-auth'
  gem.version               = HTTP::TokenAuth::VERSION
  gem.required_ruby_version = '>= 2.1.0'

  gem.authors     = ['Felipe Dornelas']
  gem.email       = ['m@felipedornelas.com']
  gem.homepage    = 'https://github.com/felipead/http-token-auth'
  gem.license     = 'MIT'
  gem.summary     = %s(Ruby gem to handle the HTTP Token Access Authentication draft specification, for securing HTTP-based service and microservice architectures using token credentials.)
  gem.description = %s(Ruby gem to handle the HTTP Token Access Authentication draft specification, for securing HTTP-based service and microservice architectures using token credentials. It supports both parsing and building a HTTP "Authentication" request header and a "WWW-Authenticate" response header using the token scheme.)

  gem.files         = `git ls-files bin lib http-token-auth.gemspec LICENSE.txt`.split($RS)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.11'
end
