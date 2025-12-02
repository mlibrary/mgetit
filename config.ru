require "bundler"
Bundler.require

ENV["APP_ENV"] = ENV["RAILS_ENV"] if ENV["RAILS_ENV"]

require_relative "lib/mgetit"
require "rack/contrib/try_static"

use Rack::Timeout, service_timeout: ENV.fetch("RACK_TIMEOUT", 60).to_i
Rack::Timeout::Logger.logger = Logger.new(STDOUT)
Rack::Timeout::Logger.logger.level = Logger::Severity::WARN

use Metrics::Middleware

if (acme_challenge_hostname = ENV.fetch("PROXY_ACME_CHALLENGE", false))
  use Rack::ReverseProxy::SetHostHeader, host: acme_challenge_hostname, path: "/.well-known/acme-challenge/"
  use Rack::ReverseProxy do
    reverse_proxy_options verify_mode: OpenSSL::SSL::VERIFY_NONE
    reverse_proxy %r{^/.well-known/acme-challenge/(.*)$},
      "https://macc.kubernetes.lib.umich.edu/.well-known/acme-challenge/$1",
       preserve_host: false
  end
end

use Rack::Attack

Rack::Attack.track("haz_cookie") do |req|
  req.env.has_key?("HTTP_COOKIE") 
end

use Rack::TryStatic, root: "public", urls: %w[/], try: %w[index.html]
use LinkResolver::PreprocessQueryString
run MGetIt
