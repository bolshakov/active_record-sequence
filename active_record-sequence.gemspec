# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/sequence/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_record-sequence'
  spec.version       = ActiveRecord::Sequence::VERSION
  spec.authors       = ['Tema Bolshakov']
  spec.email         = ['abolshakov@spbtv.com']

  spec.summary       = "Provide access to PostgreSQL's sequences"
  spec.description   = "Provide access to PostgreSQL's sequences"
  spec.homepage      = 'https://github.com/bolshakov/active_record-sequence'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activerecord', '>= 3.2', '< 6.0.0'
  spec.add_development_dependency 'appraisal', '2.1.0'
  spec.add_development_dependency 'bundler', '1.13.1'
  spec.add_development_dependency 'pg', '0.19.0'
  spec.add_development_dependency 'rake', '11.3.0'
  spec.add_development_dependency 'rspec', '3.5.0'
  spec.add_development_dependency 'spbtv_code_style', '1.4.1'
end
