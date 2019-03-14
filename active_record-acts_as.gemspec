lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'active_record/acts_as/version'

Gem::Specification.new do |spec|
  spec.name          = "active_record-acts_as"
  spec.version       = ActiveRecord::ActsAs::VERSION
  spec.authors       = ["Hassan Zamani", "Manuel Meurer"]
  spec.email         = ["hsn.zamani@gmail.com", "manuel@krautcomputing.com"]
  spec.summary       = %q{Simulate multi-table inheritance for activerecord models}
  spec.description   = %q{Simulate multi-table inheritance for activerecord models using a plymorphic association}
  spec.homepage      = "http://github.com/krautcomputing/active_record-acts_as"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.2"

  spec.add_development_dependency "sqlite3", "~> 1.3", "< 1.4"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "rake", "~> 10"
  spec.add_development_dependency "appraisal", "~> 2.1"
  spec.add_development_dependency "guard-rspec", "~> 4.7"

  spec.add_dependency "activesupport", ">= 4.2"
  spec.add_dependency "activerecord", ">= 4.2"
end
