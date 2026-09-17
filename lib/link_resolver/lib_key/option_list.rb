module LinkResolver
  module LibKey
    class OptionList
      def self.for_json(data)
        return new unless data

        integrator_link = data.dig("data", "bestIntegratorLink") || {}
        open_access_link = {"openAccess" => data.dig("data", "openAccess")}
        new(
          metadata: Metadata.for_json(data["data"]),
          options: [Option.for_json(integrator_link.merge(open_access_link))]
        )
      end

      def initialize(metadata: Metadata.new, options: [])
        @metadata = metadata
        @options = options
      end

      def empty?
        @options.empty?
      end

      def enhance_metadata(request)
        self
      end

      def add_service(request, service)
        if @options.empty?
           return false
        end
        @options.each do |option|
          base = {service: service, service_type_value: "fulltext"}
          option.add_fulltext(request, base)
        end
        true
      end
    end
  end
end
