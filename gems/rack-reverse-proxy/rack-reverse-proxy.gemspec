lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rack_reverse_proxy/version"

# rubocop:disable
Gem::Specification.new do |spec|
  spec.name          = "rack-reverse-proxy"
  spec.version       = RackReverseProxy::VERSION

  spec.authors = [
    "Jon Swope",
    "Ian Ehlert",
    "Roman Ernst",
    "Oleksii Fedorov"
  ]

  spec.email = [
    "jaswope@gmail.com",
    "ehlertij@gmail.com",
    "rernst@farbenmeer.net",
    "waterlink000@gmail.com"
  ]

  spec.summary       = "A Simple Reverse Proxy for Rack"
  spec.description   = <<eos
A Rack based reverse proxy for basic needs.
Useful for testing or in cases where webserver configuration is unavailable.
eos

  spec.homepage      = "https://github.com/waterlink/rack-reverse-proxy"
  spec.license       = "MIT"

  spec.files         = [
    ".document",
    ".gitignore",
    ".rspec",
    ".rubocop.yml",
    ".travis.yml",
    "CHANGELOG.md",
    "Gemfile",
    "LICENSE",
    "README.md",
    "Rakefile",
    "lib/rack/reverse_proxy.rb",
    "lib/rack_reverse_proxy.rb",
    "lib/rack_reverse_proxy/errors.rb",
    "lib/rack_reverse_proxy/middleware.rb",
    "lib/rack_reverse_proxy/response_builder.rb",
    "lib/rack_reverse_proxy/roundtrip.rb",
    "lib/rack_reverse_proxy/rule.rb",
    "lib/rack_reverse_proxy/version.rb",
    "rack-reverse-proxy.gemspec",
    "script/rubocop",
    "spec/rack/reverse_proxy_spec.rb",
    "spec/rack_reverse_proxy/response_builder_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/http_streaming_response_patch.rb",
  ]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 1.0.0"
  spec.add_dependency "rack-proxy", "~> 0.6", ">= 0.6.1"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.3"
end
# rubocop:enable
