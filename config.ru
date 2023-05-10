require "bundler"
Bundler.require

ENV['APP_ENV'] = ENV['RAILS_ENV'] if ENV['RAILS_ENV']

require_relative "lib/mgetit"
require "rack/contrib/try_static"

use Rack::TryStatic, root: "public", urls: %w[/], try: %w[index.html]

run MGetIt
