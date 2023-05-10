module LinkResolver
  module Catalog
    class Service
      attr_accessor :client, :service_id

      def initialize
        @service_id = "Catalog"

        @holding_search = {
          "base" => {
            host: "search.lib.umich.edu",
            path: "/catalog"
          },
          "label" => "Holdings Search"
        }
        @help = {
          "base" => {
            host: "umich.qualtrics.com",
            path: "/SE/",
            query: {
              SID: "SV_2broDMHlZrBYwJL",
              LinkModel: "unknown",
              ReportSource: "MGetIt",
              DocumentID: "unknown"
            }
          },
          "label" => "Help"
        }
        @document_delivery = {
          "base" => {
            host: "ill.lib.umich.edu",
            path: "/illiad/illiad.dll"
          },
          "label" => "Document Delivery"
        }

        @preempted_by = [
          {"existing_type" => :disambiguation}
        ]
      end

      def request_has_error?(request)
        error = false
        request.service_responses.to_a.find do |response|
          error ||= response[:service_type_value] == "site_message" && response.service_data[:type] == "warning"
        end
        error
      end

      def handle(request)
        add_help_link(request) unless request_has_error?(request)
        add_document_delivery_link(request)
        add_holding_search_link(request)
        request.dispatched(self, true)
      end

      # Have to override the default here.
      def parse_for_fulltext_links(marc, request)
        eight_fifty_sixes = []
        marc.find_all { |f| "856" === f.tag }.each do |link|
          eight_fifty_sixes << link
        end
        eight_fifty_sixes.each do |link|
          next if link.indicator2.match?(/[28]/)
          next unless link["u"]
          next if link["u"].match?(/(sfx\.galib\.uga\.edu)|(findit\.library\.gatech\.edu)/)
          label = (link["z"] || "Electronic Access")
          request.add_service_response(
            service: self,
            key: label,
            value_string: link["u"],
            service_type_value: "fulltext"
          )
        end
      end

      def add_holding_search_link(request)
        request.add_service_response(
          service: self,
          display_text: @holding_search["label"],
          url: holding_search_url(request),
          service_type_value: "holding_search"
        )
      end

      def holding_search_url(request)
        rft = request.referent
        base = @holding_search["base"].symbolize_keys
        LibrarySearch.new(base, rft).to_s
      end

      def add_help_link(request)
        request.add_service_response(
          service: self,
          display_text: @help["label"],
          url: problem_url(request),
          service_type_value: "help"
        )
      end

      def problem_url(request)
        base = @help["base"].symbolize_keys
        http_env = request.http_env
        hostname = http_env["HTTP_X_FORWARDED_HOST"] || http_env["HTTP_HOST"]
        query = base[:query].merge(
          LinkModel: "unknown",
          DocumentID: "https://" + hostname + http_env["REQUEST_URI"]
        )
        URI::HTTP.build(base.merge(query: query.to_query)).to_s
      end

      def add_document_delivery_link(request)
        request.add_service_response(
          service: self,
          display_text: @document_delivery["label"],
          url: document_delivery_url(request),
          service_type_value: "document_delivery"
        )
      end

      def document_delivery_url(request)
        base = @document_delivery["base"].symbolize_keys
        rft = request.referent
        URI::HTTPS.build(base.merge(query: illiad_params(rft).to_query)).to_s
      end

      def illiad_params(rft)
        metadata = rft.metadata

        pmid = nil
        doi = nil
        rft.identifiers.each do |id|
          pmid = id.slice(10, id.length) if id.start_with?("info:pmid/")
          doi = id.slice(9, id.length) if id.start_with?("info:doi/")
        end

        params = {}
        params["Action"] = 10
        params["ESPNumber"] = rft.oclcnum if rft.respond_to?(:oclcnum)
        params["PhotoJournalVolume"] = metadata["volume"]
        params["ISSN"] = metadata["issn"] || metadata["eissn"] || metadata["isbn"] || metadata["eisbn"]
        params["PhotoJournalIssue"] = metadata["issue"]
        params["LoanTitle"] =
          params["PhotoJournalTitle"] =
            metadata["jtitle"] || metadata["btitle"] || metadata["title"]

        params["PMID"] = pmid
        params["DOI"] = doi

        if metadata["date"] && (metadata["date"].length == 7 || metadata["date"].length == 10)
          params["PhotoJournalYear"] = metadata["date"].slice(0, 4)
          params["PhotoJournalMonth"] = metadata["date"].slice(5, 2)
        end

        params["PhotoJournalInclusivePages"] = metadata["pages"] ||
          (metadata["spage"] && metadata["epage"] && "#{metadata["spage"]}-#{metadata["epage"]}") ||
          metadata["spage"] ||
          metadata["epage"]

        params["PhotoArticleTitle"] = get_illiad_article_title(metadata)
        params["PhotoArticleAuthor"] = get_illiad_article_author(metadata)
        params["LoanAuthor"] =
          params["PhotoItemAuthor"] =
            get_illiad_item_author(metadata)
        params["Form"] = get_illiad_form(metadata)

        params
      end

      def get_illiad_article_title(metadata)
        title = metadata["atitle"]
        if title.present? && title == (metadata["btitle"] || metadata["jtitle"] || metadata["title"])
          nil
        else
          title
        end
      end

      def get_illiad_article_author(metadata)
        case metadata["genre"]
        when "book", "journal"
          nil
        else
          get_author(metadata)
        end
      end

      def get_illiad_item_author(metadata)
        case metadata["genre"]
        when "book", "journal"
          get_author(metadata)
        end
      end

      def get_author(metadata)
        metadata["au"] ||
          (metadata["aulast"] && metadata["aufirst"] && "#{metadata["aulast"]}, #{metadata["aufirst"]}") ||
          metadata["aulast"] ||
          metadata["aufirst"]
      end

      def get_illiad_form(metadata)
        case metadata["genre"]
        when "dissertation"
          27
        when "article"
          22
        when "bookitem"
          23
        when "book", "journal"
          21
        else
          22
        end
      end

      def version_01_params(rft)
        params = rft.metadata.dup
        if params["title"].nil?
          params["title"] = params["jtitle"] || params["btitle"]
        end

        if params["aufirst"].nil?
          params["aufirst"] = params["au"]
        end
        params
      end

      # Override the default here.
      def response_url(service_response, http_params)
        service_response.url
      end
    end
  end
end
