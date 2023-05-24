require "nokogiri"

module LinkResolver
  module Alma
    class Client
      def initialize(base_url)
        @base_url = base_url
      end

      def fetch(request, context_object)
        transport = OpenURL::Transport.new(@base_url, context_object)
        transport.extra_args["svc_dat"] = "CTO"
        if request.http_env["REQUEST_URI"].include?("u.ignore_date_coverage=true")
          transport.extra_args["u.ignore_date_coverage"] = "true"
        end
        transport.instance_eval { @client.use_ssl = true }
        begin
          transport.get
          OptionList.from_xml(transport.response)
        rescue Net::OpenTimeout,
               Net::ReadTimeout,
               Errno::ECONNREFUSED,
               Errno::ECONNRESET => e
          FailedOptionList.new(e)
        end
      end

      def handle(request)
        option_list = fetch(request, request.to_context_object)
        return option_list unless request.referent&.format == 'book'
        new_query_string = request.raw_request.query_string

        while option_list.empty? && new_query_string.scan('isbn=').length > 1
          found = false
          new_query_string = new_query_string.split('&').reject do |kev|
            !found && kev.include?('isbn=') && found = true
          end.join('&')
          option_list = fetch(
            request,
            OpenURL::ContextObject.new_from_kev(new_query_string).tap {|co| co.serviceType.clear}
          )
        end
        option_list
      end
    end
  end
end
