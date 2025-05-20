module LinkResolver
  class PreprocessQueryString
    attr_accessor :app
    def initialize(app)
      @app = app
    end

    def call(env)
      doi = %r{https?%3[Aa]%2[Ff]%2[Ff](dx\.)?doi\.org%2[Ff]([^&]+)}
      pubmed = %r{https?%3[Aa]%2[Ff]%2[Ff]pubmed\.ncbi\.nlm\.nih\.gov%2[Ff](\d+)[^&]*}
      ["QUERY_STRING", "REQUEST_URI"].each do |key|
        next if env[key].frozen?
        env[key]&.gsub!(doi, "\\2")
        env[key]&.gsub!(pubmed, "\\1")
      end
      app.call(env)
    end
  end
end
