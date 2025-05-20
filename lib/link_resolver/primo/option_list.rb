module LinkResolver
  module Primo
    class OptionList
      def self.for_json(delivery: {}, metadata: {})
        services = delivery.dig("delivery", "electronicServices")
        new(
          metadata: Metadata.for_json(metadata),
          options: services.map {|service| Option.for_json(service) },
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
        rft = request.referent
        needed = {
          "rft.au" => true,
          "rft.title" => true,
          "rft.atitle" => true,
          "rft.btitle" => true,
          "rft.jtitle" => true,
          "rft.stitle" => true,
          "rft.isbn" => true,
          "rft.issn" => true,
          "rft.eisbn" => true,
          "rft.eissn" => true,
          "rft.pubdate" => true,
          "rft.edition" => true,
          "rft.series" => true,
          "rft.pub" => true,
          "rft.publisher" => true,
          "rft.place" => true,
          "rft.genre" => true,
          "rft.spage" => true,
          "rft.epage" => true,
          "rft.pages" => true,
          "rft.part" => true,
          "rft.volume" => true,
          "rft.issue" => true,
          "rft.year" => true,
          "rft.aucorp" => true
        }
        needed.keys.each do |key|
          needed[key] = false unless rft.metadata[key].nil? || rft.metadata[key].empty?
        end

        list = {"rft.au" => true, "au" => true}
        @metadata.each do |kv|
          key = kv.keys.first
          value = kv.values.first
          key_10 = "rft." + key
          next unless needed[key_10]
          next if value.empty?
          if list[key]
            old_value = rft.metadata[key]
            next if old_value&.include?(value)
            values = [old_value, value].compact.reject(&:empty?)
            rft.set_metadata(key, values.join("; "))
          else
            rft.set_metadata(key, value)
          end
        end
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
