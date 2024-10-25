lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/sequence/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_record-sequence'
  spec.version       = ActiveRecord::Sequence::VERSION
  spec.authors       = ['Tëma Bolshakov']
  spec.email         = ['tema@bolshakov.dev']
  spec.license       = "MIT"

  spec.summary       = "Provide access to PostgreSQL's sequences"
  spec.description   = "Provide access to PostgreSQL's sequences"
  spec.homepage      = 'https://github.com/bolshakov/active_record-sequence'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '>= 4.2.11', '<= 6.0.0.beta1'
  spec.add_runtime_dependency 'pg'

  spec.add_development_dependency 'appraisal', '2.1.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '11.3.0'
  spec.add_development_dependency 'rspec', '3.5.0'
  spec.add_development_dependency 'rubocop', '0.64.0'
end
