module LinkResolver
  module Primo
    class Metadata
      def self.for_json(object)
        new(object.map { |k,v| {k => v.first}})
      end

      def initialize(attributes = [])
        @attributes = attributes
      end

      def each(&block)
        @attributes.each(&block)
      end

      def [](key)
        @attributes.select { |kv| kv.has_key?(key) }.map(&:values).flatten
      end
    end
  end
end
