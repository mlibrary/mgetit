module LinkResolver
  module Primo
    class Service
      attr_accessor :display_name, :display_text, :base_url, :client, :service_id

      def initialize
        self.display_name = "Primo Link Resolver"
        self.display_text = "Get Full Text via Primo Link Resolver"
        self.base_url = "https://umich.primo.exlibrisgroup.com/primaws/rest/pub/pcDelivery/:id?vid=01UMICH_INST:UMICH"
        self.service_id = "Primo"

        self.client = LinkResolver::Primo::Client.new(base_url)
      end


      def handle(request)
        options = client.handle(request)
        options.enhance_metadata(request)
        status = options.add_service(request, self)
        request.dispatched(self, status)
      end
    end
  end
end
