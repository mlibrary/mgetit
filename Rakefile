require "bundler"
Bundler.require

module Rails
  def self.env
    ENV.fetch("RAILS_ENV", "development")
  end

  def self.application
    OpenStruct.new(config: OpenStruct.new(load_database_yaml:
      {development: {}, test: {}, production: {}}))
  end
end

require_relative "lib/mgetit"
require "sinatra/activerecord/rake"
require "sass"
require "sass/exec"
require "standard/rake" unless Rails.env == "production"

namespace "db" do
  desc "Prune old records from the database"
  task :prune do
    deadline = 4.years.ago
    batchsize = 1000
    # created_at
    [
      Clickthrough,
      DispatchedService,
      ReferentValue,
      Referent,
      Request,
      ServiceResponse,
    ].each do |model|
      model.where("created_at < ?", deadline).in_batches(of: batchsize).delete_all
    end

    # created_on
    [
      Permalink,
    ].each do |model|
      model.where("created_on < ?", deadline).in_batches(of: batchsize).delete_all
    end
  end
end

namespace "assets" do
  desc "Precompile assets"
  task :precompile do
    assets_path = File.expand_path(File.join("..", "public", "assets"), __FILE__)
    images_path = File.join(assets_path, "images")
    javascripts_path = File.join(assets_path, "javascripts")
    stylesheets_path = File.join(assets_path, "stylesheets")

    images_source = File.join(File.expand_path(File.join("..", "lib", "assets", "images"), __FILE__), ".")

    javascript_sources = [
      File.expand_path(File.join("..", "gems", "jquery-rails", "vendor", "assets", "javascripts", "jquery.js"), __FILE__),
      File.expand_path(File.join("..", "gems", "jquery-rails", "vendor", "assets", "javascripts", "jquery_ujs.js"), __FILE__),
      File.expand_path(File.join("..", "lib", "assets", "javascripts", "mgetit.js"), __FILE__)
    ]

    stylesheets_source = File.expand_path(File.join("..", "lib", "assets", "stylesheets", "umlaut.css.scss"), __FILE__)

    FileUtils.mkdir_p([images_path, javascripts_path, stylesheets_path])

    FileUtils.cp_r(images_source, images_path)

    File.open(File.join(javascripts_path, "mgetit.js"), "w") do |js|
      javascript_sources.each do |source|
        js.write(IO.read(source))
      end
    end

    opts = Sass::Exec::SassScss.new([stylesheets_source, File.join(stylesheets_path, "mgetit.css")], :scss)
    opts.parse!
  end
end
