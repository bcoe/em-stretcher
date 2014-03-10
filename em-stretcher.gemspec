# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'em/stretcher/version'

Gem::Specification.new do |spec|
  spec.name          = "em-stretcher"
  spec.version       = EventMachine::Stretcher::VERSION
  spec.authors       = ["Benjamin Coe"]
  spec.email         = ["ben@yesware.com"]
  spec.summary       = %q{EventMachine for Stretcher a Fast, Elegant, ElasticSearch client}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "stretcher"
  spec.add_dependency "deferrable_gratification"
  spec.add_dependency "eventmachine"
  spec.add_dependency "em-http-request"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-eventmachine"
  spec.add_development_dependency "rake"
end
