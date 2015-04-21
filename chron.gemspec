# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chron/version'

Gem::Specification.new do |spec|
  spec.name          = "chron"
  spec.version       = Chron::VERSION
  spec.authors       = ["winfred"]
  spec.email         = ["winfred@hired.com"]

  spec.summary       = %q{declare arbitrary block of code to be fired against a given record at the time stored as the value in that column.}
  spec.homepage      = "http://github.com/hired/chron"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activejob', '~> 4.2'
  spec.add_dependency 'activerecord', '~> 4.2'
  spec.add_dependency 'activesupport', '~> 4.2'
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "rspec", "~> 3.2.0"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "timecop"
end
