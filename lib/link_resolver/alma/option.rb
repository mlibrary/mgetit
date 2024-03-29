module LinkResolver
  module Alma
    class Option
      def self.for_xml_object(context_service)
        new(
          type: context_service["service_type"],
          attributes: LinkResolver::Alma.extract_keys(context_service),
          url: context_service.xpath("./xmlns:resolution_url").text
        )
      end

      attr_reader :url

      def initialize(type: "unknown", attributes: [], url: "")
        @type = type
        @attributes = attributes
        @url = url
      end

      def [](key)
        @attributes.select { |attribute| attribute.has_key?(key) }.map(&:values).flatten
      end

      def filtered?
        self["Filtered"].include?("true")
      end

      def notes
        [self["Availability"], self["Authentication_note"], self["public_note"]].flatten.reject(&:empty?).join("\n")
      end

      def package_name
        self["package_display_name"].first
      end

      def availability
        self["Availability"].first&.gsub(/<br>/, "\n")
      end

      def authentication_note
        tmp = self["Authentication_note"].first
        return tmp if tmp.nil?
        if tmp.length % 2 == 0
          left = tmp[0...tmp.length / 2]
          right = tmp[tmp.length / 2...tmp.length]
          return left if left == right
        end
        tmp
      end

      def public_note
        self["public_note"].first
      end

      def add_fulltext(request, base)
        return nil if filtered?
        request.add_service_response(base.merge(
          display_text: "Go To Item",
          package_name: package_name,
          url: url,
          availability: availability,
          authentication_note: authentication_note,
          public_note: public_note
        ))
      end
    end
  end
end
