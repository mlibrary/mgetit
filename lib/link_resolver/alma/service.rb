module LinkResolver
  module Alma
    class Service
      attr_accessor :display_name, :display_text, :base_url, :institution,
        :campus_code, :client, :service_id

      def initialize
        self.display_name = "Alma Link Resolver"
        self.display_text = "Get Full Text via Alma Link Resolver"
        self.base_url = "https://na04.alma.exlibrisgroup.com/view/uresolver"
        self.institution = "01UMICH_INST"
        self.campus_code = "UMAA"
        self.service_id = "Alma"

        self.client = LinkResolver::Alma::Client.new(resolver_base_url)
      end

      def resolver_base_url
        "#{base_url}/#{institution}/openurl#{campus_code.nil? ? "" : "-" + campus_code}"
      end

      def handle(request)
        return if preempted?(request)
        options = client.handle(request)
        options.enhance_metadata(request)
        status = options.add_service(request, self)
        request.dispatched(self, status)
      end

      def preempted?(request)
        request.service_responses.any? do |response|
          LinkResolver::Primo::Service === response[:service] &&
            response[:service_type_value] == "fulltext"
        end
      end
    end
  end
end
