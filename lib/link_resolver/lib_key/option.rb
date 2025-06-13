module LinkResolver
  module LibKey
    class Option
      def self.for_json(data)
         new(
           type: data["linkType"],
           url: data["bestLink"]
        )
      end

      attr_reader :url

      def initialize(type: "unknown", url: "")
        @type = type
        @url = url
      end

      def add_fulltext(request, base)
        request.add_service_response(base.merge(
          display_text: "View PDF",
          package_name: "View PDF",
          url: url,
          availability: "",
          authentication_note: "",
          public_note: ""
        ))
      end
    end
  end
end
