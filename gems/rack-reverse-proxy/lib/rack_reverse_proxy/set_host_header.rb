module RackReverseProxy
  class SetHostHeader
    def initialize(app, **opts)
      @app = app
      @host = opts.fetch(:host)
      @path = opts.fetch(:path)
    end

    def call(env)
      if @host && (@path.nil? || env["PATH_INFO"].start_with?(@path))
        env["HTTP_HOST"] = env["SERVER_NAME"] = @host
      end
      @app.call(env)
    end
  end
end
