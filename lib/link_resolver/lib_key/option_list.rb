module LinkResolver
  module LibKey
    class OptionList
      def self.for_json(data)
        return new unless data
        new(
          metadata: Metadata.for_json(data["data"]),
          options: [Option.for_json(data.dig("data", "bestIntegratorLink").merge("openAccess" => data.dig("data","openAccess")))]
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
