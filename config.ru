# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
class Debug
  def initialize(app)
    @app = app
  end

  def call(env)
    puts env.inspect
    @app.call(env)
  end
end

use Debug
run Rails.application
