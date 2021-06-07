# From Stack Overfliew:
# https://stackoverflow.com/questions/41613059/rails-do-not-allow-access-to-static-asset-directory-without-a-trailing

module Rack
  class RedirectStaticWithoutTrailingSlash
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      original_path_info = request.path_info

      response = @app.call(env)

      updated_path_info = request.path_info

      if serving_index_for_path_without_trailing_slash?(original_path_info, updated_path_info)
        redirect_using_trailing_slash(original_path_info)
      else
        response
      end
    end

    def serving_index_for_path_without_trailing_slash?(original_path_info, updated_path_info)
      updated_path_info.end_with?('index.html') &&
        original_path_info != updated_path_info &&
        !original_path_info.end_with?('/')
    end

    def redirect_using_trailing_slash(path)
      redirect("#{path}/")
    end

    def redirect(url)
      [301, {'Location' => url, 'Content-Type' => 'text/html'}, ['Moved Permanently']]
    end
  end
end
