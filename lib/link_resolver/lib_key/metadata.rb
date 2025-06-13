module LinkResolver
  module LibKey
    class Metadata
      def self.for_json(data)
        new(data)
      end

      def initialize(attributes = data)
        @attributes = attributes
      end

      def [](key)
        @attributes[key]
      end
    end
  end
end
