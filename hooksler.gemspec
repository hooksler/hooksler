# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hooksler/version'

Gem::Specification.new do |spec|
  spec.name          = "hooksler"
  spec.version       = Hooksler::VERSION
  spec.authors       = ["schalexey@gmail.com"]
  spec.email         = ["schalexey@gmail.com"]

  spec.summary       = %q{WebHooks multiplexer.}
  spec.description   = %q{WebHooks multiplexer, for send notify from One-to-One, Many-to-One, Many-To-Many with preprocessing etc.}
  spec.homepage      = "https://github.com/fuCtor/hooksler"
  spec.license       = "MIT"


#  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rack'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'hashie'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack-test', ['>= 0']
  spec.add_development_dependency 'simplecov'
end
