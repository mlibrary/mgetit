# frozen_string_literal: true

require_relative "lib/umlaut/alma/version"

Gem::Specification.new do |spec|
  spec.name          = "umlaut-alma"
  spec.version       = Umlaut::Alma::VERSION
  spec.authors       = ["Albert Bertram"]
  spec.email         = ["bertrama@umich.edu"]

  spec.summary       = "Add support for Alma to Umlaut"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mlibrary/umlaut-alma"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "http://localhost'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{app,config,db,lib,active_record_patch}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_dependency 'openurl'
  spec.add_dependency 'httparty'
  spec.add_development_dependency 'pry'
end
