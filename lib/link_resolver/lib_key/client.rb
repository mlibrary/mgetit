module LinkResolver
  module LibKey
    class Client
      attr_reader :host, :key, :library_id

      def initialize
        @host = ENV["LIBKEY_HOST"]
        @key = ENV["LIBKEY_KEY"]
        @library_id = ENV["LIBKEY_LIBRARY_ID"]

        @connection = Faraday.new(
          @host,
          headers: { "Authorization" => "Bearer #{@key}" }
        )
      end

      def handle(request)
        return OptionList.new unless host && key && library_id
        identifiers  = request.to_context_object.referent.identifiers
        pmid = identifiers.find {|id| id.start_with?("info:pmid/") }
        doi  = identifiers.find {|id| id.start_with?("info:doi/") }
        OptionList.for_json(fetch_pmid(pmid) || fetch_doi(doi))
      end

      private

      def fetch_pmid(id)
        return nil unless id
        response = fetch("pmid", id[10..id.length])
        return nil unless response&.body
        return nil if response.body.empty?
        JSON.parse(response.body)
      end

      def fetch_doi(id)
        return nil unless id
        response = fetch("doi", id[9..id.length])
        return nil unless response&.body
        return nil if response.body.empty?
        JSON.parse(response.body)
      end

      def fetch(type, data)
        @connection.get("/public/v1/libraries/#{library_id}/articles/#{type}/#{CGI.escape(data)}")
      end
    end
  end
end
