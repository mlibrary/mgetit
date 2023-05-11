require "bundler"
Bundler.require

module Rails
  def self.env
    ENV.fetch("RAILS_ENV", "development")
  end
end

require_relative "lib/mgetit"
require "sinatra/activerecord/rake"
#require "standard/rake"
