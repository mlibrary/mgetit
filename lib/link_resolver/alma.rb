# frozen_string_literal: true

require_relative "request"
require_relative "alma/metadata"
require_relative "alma/option"
require_relative "alma/option_list"
require_relative "alma/failed_option_list"
require_relative "alma/client"
require_relative "alma/service"

module LinkResolver
  module Alma
    class Error < StandardError; end
    # Your code goes here...

    def self.extract_keys(parsed_xml)
      parsed_xml.xpath("./xmlns:keys/xmlns:key").map do |key|
        {key["id"] => key.text}
      end
    end
  end
end
