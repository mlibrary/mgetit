# frozen_string_literal: true

require_relative "alma/version"

if defined?(Rails)
  require_relative 'alma/railtie'
  require_relative 'alma/search_methods'
end

module Umlaut
  module Alma
    class Error < StandardError; end
    # Your code goes here...

    def self.extract_keys(parsed_xml)
      parsed_xml.xpath('./xmlns:keys/xmlns:key').map do |key|
        { key['id'] => key.text }
      end
    end
  end
end
