module LinkResolver
  module LibKey
    class Service
      attr_accessor :display_name, :display_text, :client, :service_id

      def initialize
        self.display_name = "LibKey Link Resolver"
        self.display_text = "Get Full Text via LibKey Link Resolver"
        self.service_id = "LibKey"
        self.client = LinkResolver::LibKey::Client.new
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
