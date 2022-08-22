require 'httparty'

module Umlaut
  module Alma
    class OptionList
      def self.from_xml(xml)
        return self.from_xml_object(Nokogiri::XML(xml))
      end

      def self.from_xml_object(parsed)
        self.new(
          metadata: Metadata.for_xml_object(parsed.xpath('//xmlns:context_object').first),
          options: parsed.xpath('//xmlns:context_service').map { |context_service|
            Option.for_xml_object(context_service)
          }
        )
      end

      def initialize(metadata: NullMetadata.new, options: []) 
        @metadata = metadata
        @options = deduplicate(options)
      end

      def enhance_metadata(request)
        rft = request.referent
        needed = {
          'rft.au' => true,
          'rft.title' => true,
          'rft.atitle' => true,
          'rft.btitle' => true,
          'rft.jtitle' => true,
          'rft.stitle' => true,
          'rft.title' => true,
          'rft.isbn' => true,
          'rft.issn' => true,
          'rft.eisbn' => true,
          'rft.eissn' => true,
          'rft.pubdate' => true,
          'rft.edition' => true,
          'rft.series' => true,
          'rft.pub'   => true,
          'rft.publisher' => true,
          'rft.place' => true,
          'rft.genre' => true,
          'rft.spage' => true,
          'rft.epage' => true,
          'rft.pages' => true,
          'rft.part' => true,
          'rft.volume' => true,
          'rft.issue' => true,
          'rft.year'  => true,
          'rft.aucorp' => true,
        }
        needed.keys.each do |key|
          needed[key] = false unless rft.metadata[key].nil?  || rft.metadata[key].empty?
        end
        list = {'rft.au' => true, 'au' => true}
        @metadata.each do |kv|
          key = kv.keys.first
          value = kv.values.first
          next unless key.start_with?('rft.')
          next if value.empty?
          if key == 'rft.object_type' && value == 'BOOK'
            rft.enhance_referent('genre', 'book');
            rft.enhance_referent('rft.genre', 'book');
            rft.enhance_referent('format', 'book');
            rft.enhance_referent('rft_val_fmt', 'info:ofi/fmt:kev:mtx:book');
          end
          next unless needed[key]
          target = key[4, key.length]
          if list[target]
            old_value = rft.metadata[target]
            next if old_value&.include? value
            values = [old_value, value].compact.reject(&:empty?)
            rft.enhance_referent(target, values.join('; '))
          else
            rft.enhance_referent(target, value)
          end
        end

        return self
      end

      def add_service(request, service)
        if @options.empty?
          context = request.referent.to_context_object.to_hash
          ids = context['rft_id'] || []
          if ids.any? { |id| id.start_With('info:pmid') }
            request.add_service_response(
              service: service,
              service_type_value: 'site_message',
              type: 'warning',
              message: 'umlaut.message.pubmed_unavailable'
            )
          end
          if ids.any? { |id| id.start_With('info:doi') }
            request.add_service_response(
              service: service,
              service_type_value: 'site_message',
              type: 'warning',
              message: 'umlaut.message.doi_unavailable'
            )
          end
          return false
        end
        @options.each do |option|
          base = { service: service, service_type_value: 'fulltext' }
          option.add_fulltext(request, base)
        end
        true
      end

      private
      def deduplicate(options)
        deduped = {}
        options.each do |option|
          response = HTTParty.head(option.url, follow_redirects: false)
          resolved_url = response.headers['location'] || option.url
          unless deduped.has_key?(resolved_url)
            deduped[resolved_url] = option
          end
        end
        deduped.values
      end
    end
  end
end
