require "nokogiri"

module LinkResolver
  module Alma
    class Client
      def initialize(base_url)
        @base_url = base_url
      end

      def handle(request)
        context_object = request.to_context_object
        transport = OpenURL::Transport.new(@base_url, context_object)
        transport.extra_args["svc_dat"] = "CTO"
        if request.http_env["REQUEST_URI"].include?("u.ignore_date_coverage=true")
          transport.extra_args["u.ignore_date_coverage"] = "true"
        end
        transport.instance_eval { @client.use_ssl = true }
        begin
          transport.get
          OptionList.from_xml(transport.response)
        rescue Errno::ECONNRESET => e
          raise e
        rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED => e
          FailedOptionList.new(e)
        end
      end
    end
  end
end
