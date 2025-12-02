source "https://rubygems.org"

gem "logger"
gem "sinatra", require: "sinatra/base"
gem "sinatra-activerecord"
gem "rack-contrib"
gem "rack-attack" # Rack attack needs to be after "sinatra-activerecord"
gem "rack-timeout"
gem "mysql2"
gem "rake"
gem "puma"
gem "openurl", path: "gems/openurl", require: "openurl"
gem "sass"
gem "sassc"
gem "httparty"
gem "faraday"
gem "nokogiri"
gem "erubi"
gem "activesupport", "~> 8.1.1"
gem "titlecase"
gem "multi_json"
gem "standard", group: [:development, :test]
gem "pry", group: [:development, :test]
gem "pry-byebug", group: [:development, :test]
gem "rspec", group: [:development, :test]
gem "rack-test", group: [:development, :test]
gem "simplecov", group: [:development, :test]
gem "webmock", group: [:development, :test]

gem "ostruct"
gem "mutex_m"
gem "bigdecimal"
gem "fiddle"

gem "rack-reverse-proxy",
  path: "gems/rack-reverse-proxy",
  require: "rack/reverse_proxy"

group :metrics do
  gem "yabeda-puma-plugin"
  gem "yabeda-prometheus"
  gem "prometheus-client", require: File.expand_path(File.join(["lib", "metrics"]), __dir__)
end
