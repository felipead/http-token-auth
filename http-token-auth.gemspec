# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http/token_auth/version'

Gem::Specification.new do |gem|
  gem.name          = 'http-token-auth'
  gem.version       = HTTP::TokenAuth::VERSION
  gem.authors       = ['Felipe Dornelas']
  gem.email         = ['m@felipedornelas.com']
  gem.description   = %s(Ruby gem to handle the HTTP Token Access Authentication.)
  gem.summary       = %s(Ruby gem to handle the HTTP Token Access Authentication.)
  gem.homepage      = 'https://github.com/felipead/http-token-auth'

  # rubocop:disable Style/SpecialGlobalVars
  gem.files         = `git ls-files bin lib http-token-auth.gemspec LICENSE.txt`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.license       = 'MIT'

  gem.add_development_dependency 'bundler', '~> 1.11'
  gem.add_development_dependency 'rake', '~> 10.0'
end
