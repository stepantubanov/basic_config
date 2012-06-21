# -*- encoding: utf-8 -*-
require File.expand_path('../lib/basic_config', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Stepan Tubanov']
  gem.email         = ['stepan773@gmail.com']
  gem.description   = 'Makes it easier to use configuration by wrapping it in a struct-like object'
  gem.summary       = 'Friendly configuration wrapper'
  gem.homepage      = 'https://github.com/stephan778/basic_config'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = 'basic_config'
  gem.require_path  = 'lib'
  gem.version       = '0.1.0'

  gem.add_development_dependency('rspec', '~> 2.10')
end
