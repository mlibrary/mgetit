require File.expand_path('../boot', __FILE__)

require 'rails/all'
require File.expand_path('../../lib/mgetit/request_patch', __FILE__)
require File.expand_path('../../lib/actionview_patch', __FILE__)
require File.expand_path('../../lib/rack/redirect_static_without_trailing_slash', __FILE__)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mgetit
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # From Stack Overflow
    # https://stackoverflow.com/questions/41613059/rails-do-not-allow-access-to-static-asset-directory-without-a-trailing
    config.middleware.insert_before('ActionDispatch::Static', 'Rack::RedirectStaticWithoutTrailingSlash')

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT'] || ''
    config.action_controller.relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT'] || ''
    config.dependency_loading = true if $rails_rake_task
    config.action_dispatch.default_headers.merge!({'X-Frame-Options' => 'ALLOWALL'})

    # Adapted from http://stackoverflow.com/questions/15212637/using-presenters-in-rails
    config.after_initialize do |app|
      app.config.paths.add 'app/presenters', eager_load: true
      Request.send(:include, Mgetit::RequestPatch)
    end
  end
end
