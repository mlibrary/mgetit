require 'nokogiri'

module Umlaut
  module Alma
    class Client

      def initialize(base_url)
        @base_url = base_url
      end

      def handle(request)
        context_object = request.to_context_object
        transport = OpenURL::Transport.new(@base_url, context_object)
        transport.extra_args['svc_dat'] = 'CTO'
        transport.instance_eval { @client.use_ssl = true }
        begin
          transport.get
          OptionList.from_xml(transport.response)
        rescue Errno::ECONNRESET => e
          puts e.inspect
          raise e
        rescue Net::ReadTimeout, Errno::ECONNREFUSED => e
          FailedOptionList.new(e)
        end
      end
    end
  end
end
