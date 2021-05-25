module Umlaut
  module Alma
    class Metadata

      def self.for_xml_object(context_object)
        self.new(Umlaut::Alma.extract_keys(context_object))
      end

      def initialize(attributes = [])
        @attributes = attributes
      end

      def each(&block)
        @attributes.each(&block)
      end

      def [](key)
        @attributes.select {|kv| kv.has_key?(key)}.map(&:values).flatten
      end
    end
  end
end
