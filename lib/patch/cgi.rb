require "cgi"

unless CGI.respond_to?(:parse)
  class CGI
    # File lib/cgi/core.rb, line 393
    def self.parse(query)
      params = {}
      query.split(/[&;]/).each do |pairs|
        key, value = pairs.split('=',2).collect{|v| CGI.unescape(v) }

        next unless key

        params[key] ||= []
        params[key].push(value) if value
      end

      params.default=[].freeze
      params
    end
  end
end
