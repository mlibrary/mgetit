require 'umlaut/version'
require 'umlaut/routes'
require 'umlaut/util'


# not sure why including openurl gem doesn't do the require, but it
# seems to need this. 
require 'openurl'
require 'bootstrap-sass'

module Umlaut
  class Engine < Rails::Engine
    engine_name "umlaut"

    ## Umlaut patches assets:precompile rake task to make non-digest-named
    # copies of files matching this config. LOGICAL names of assets. 
    # These can be dirglobs if desired. 
    #
    # See lib/tasks/umlaut_asset_compile.rake
    # 
    # umlaut_ui.js and spinner.gif prob should have been put under umlaut/
    # dir, but we didn't. 
    config.non_digest_named_assets = ["umlaut/*.js", "umlaut_ui.js", "spinner.gif"]
    
    # We need the update_html.js script to be available as it's own
    # JS file too, not just compiled into application.js, so we can
    # deliver it to external apps using it (JQuery Content Utility).
    # It will now be available from path /assets/umlaut/update_html.js
    # in production mode with precompiled assets, also in dev mode, 
    # whatevers.     
    initializer "#{engine_name}.asset_pipeline" do |app|
      app.config.assets.precompile << 'umlaut/update_html.js'
      app.config.assets.precompile << "umlaut_ui.js"
    end

    initializer "#{engine_name}.preload" do
      require 'service_type_value' # stored in lib, load it ourselves, after Umlaut::Engine is loaded
    end

    config.whitelisted_backtrace = {}
    config.whitelisted_backtrace[self.root] = self.engine_name

    # The Rails backtrace cleaner strips some lines from exception backtraces,
    # and prettifies the lines left. 
    #
    # Umlaut uses the default backtrace cleaner for cleaning backtraces
    # for outputting in error logs in various places. 
    #
    # We want to make sure Umlaut lines stay in the backtrace and are prettified,
    # so we customize the default backtrace cleaner. You can add additional
    # gems (such as Umlaut plugins) to the whitelist of ones to keep in the
    # backtrace, for instance a Rails engine gem might define an initializer
    # in it's engine class, inserted to run BEFORE this one, that adds
    # itself, like:
    #
    #       initializer "#{engine_name}.backtrace_cleaner", :before => "umlaut.backtrace_cleaner" do
    #         Umlaut::Engine.config.whitelisted_backtrace[self.root] = self.engine_name
    #       end
    initializer "#{engine_name}.backtrace_cleaner" do |app|
      # config.whitelisted_backtrace is a hash from root file path t
      # short name. We want to turn the filepaths into regexes left-anchored
      # and with trailing separator. 
      whitelisted_path_regexes = config.whitelisted_backtrace.inject({}) do |h, (k, v)| 
        h[/^#{Regexp.escape(k.to_s + File::SEPARATOR)}/] = v.to_s
        h
      end
      union_name_re = Regexp.union whitelisted_path_regexes.values.collect {|n| /^#{Regexp.escape n}/}
      union_path_re = Regexp.union whitelisted_path_regexes.keys

      
      # Clean those ERB lines, we don't need the internal autogenerated
      # ERB method, what we do need (line number in ERB file) is already there
      Rails.backtrace_cleaner.add_filter do |line|
        line.sub /(\.erb:\d+)\:in.*$/, "\\1"
      end

      # Remove our own engine's path prefix, even if it's 
      # being used from a local path rather than the gem directory. 
      whitelisted_path_regexes.each_pair do |path_re, name|
        Rails.backtrace_cleaner.add_filter do |line|
          line.sub(path_re, "#{name} ")
        end
      end

      # Keep Umlaut's own stacktrace in the backtrace -- we have to remove Rails
      # silencers and re-add them how we want. 
      Rails.backtrace_cleaner.remove_silencers!

      # Silence what Rails silenced, UNLESS it looks like
      # it's from Umlaut engine
      Rails.backtrace_cleaner.add_silencer do |line|
        (line !~ Rails::BacktraceCleaner::APP_DIRS_PATTERN) &&
        (line !~ union_name_re  ) &&
        (line !~ union_path_re  )
      end
    end
    
    # Patch with fixed 'fair' version of ConnectionPool, see 
    # active_record_patch/connection_pool.rb
    #initializer("#{engine_name}.patch_connection_pool", :before => "active_record.initialize_database") do |app|
      load File.join(self.root, "active_record_patch", "connection_pool.rb")
    #end

  end
end


