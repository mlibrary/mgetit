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
          next unless (rft.metadata[key].nil? || rft.metadata[key].empty?)
          rft.enhance_referent(key, value)
        end
        if rft.title.nil? || rft.title.empty?
          title = rft.metadata['rft.title'] ||
             rft.metadata['rft.jtitle'] ||
             rft.metadata['rft.stitle'] ||
             rft.metadata['rft.btitle']
          rft.enhance_referent('title', title)
        end
        if rft.issn.nil? || rft.issn.empty?
          issn = rft.metadata['rft.issn'] || rft.metadata['rft.eissn']
          rft.enhance_referent('issn', issn)
        end
        if rft.isbn.nil? || rft.isbn.empty?
          isbn = rft.metadata['rft.isbn'] || rft.metadata['rft.isbn']
          rft.enhance_referent('isbn', isbn)
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
