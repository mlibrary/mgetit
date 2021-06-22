module Umlaut
  module Alma
    class Service < ::Service
      required_config_params :base_url, :display_name, :institution

      # Call super once defaults have been set.
      def initialize(config)
        @display_name = 'Alma Link Resolver'
        @display_text = 'Get Full Text via Alma Link Resolver'

        super

        @client = Umlaut::Alma::Client.new(resolver_base_url)
      end

      def resolver_base_url
        "#{@base_url}/#{@institution}/openurl#{@campus_code.nil? ? '' : '-' + @campus_code}"
      end

      def service_types_generated
        [
          ServiceTypeValue['fulltext'],
          ServiceTypeValue['holding'],
          ServiceTypeValue['highlighted_link'],
          ServiceTypeValue['site_message'],
        ]
      end

      def handle(request)
        options = @client.handle(request)
        options.enhance_metadata(request)
        status = options.add_service(request, self)
        request.dispatched(self, status)
      end
    end
  end
end
