module LinkResolver
  module Primo
    class Option
      def self.for_json(object)
         new(
           type: object["serviceType"],
           attributes: object.map {|k,v| {k => v}},
           url: object["serviceUrl"]
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
        self["filtered"].include?("true")
      end

      def notes
        [self["availability"], self["authNote"], self["publicNote"]].flatten.reject(&:empty?).join("\n")
      end

      def package_name
        self["packageName"].first
      end

      def availability
        (self["availability"] + self["availiability"]).first&.gsub(/<br>/, "\n")
      end

      def authentication_note
        tmp = self["authNote"].first
        return tmp if tmp.nil?
        if tmp.length % 2 == 0
          left = tmp[0...tmp.length / 2]
          right = tmp[tmp.length / 2...tmp.length]
          return left if left == right
        end
        tmp
      end

      def public_note
        self["publicNote"].first
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
