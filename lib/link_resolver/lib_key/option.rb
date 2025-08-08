module LinkResolver
  module LibKey
    class Option
      def self.for_json(data)
         new(
           type: data["linkType"],
           url: data["bestLink"],
           open_access: data["openAccess"]
        )
      end

      attr_reader :url, :open_access

      def initialize(type: "unknown", url: "", open_access: false)
        @type = type
        @url = url
        @open_access = open_access
      end

      def add_fulltext(request, base)
        request.add_service_response(base.merge(
          display_text: "View PDF",
          package_name: "Direct PDF Link",
          url: url,
          availability: "",
          authentication_note: open_access ? "Open Access" : "Authorized U-M users (+ guests in U-M Libraries).",
          public_note: ""
        ))
      end
    end
  end
end
