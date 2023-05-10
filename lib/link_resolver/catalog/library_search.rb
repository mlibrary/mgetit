module LinkResolver
  module Catalog
    class LibrarySearch
      def initialize(base, rft)
        @url = base.merge(query: query_from_rft(rft))
      end

      def to_s
        URI::HTTPS.build(@url).to_s
      end

      def query_from_rft(rft)
        params = {}
        query = []
        if rft.metadata["genre"] == "book"
          params["filter.format"] = "Book"
          params["filter.date_of_publication"] = rft.metadata["year"] unless rft.metadata["year"].nil?

          title = rft.metadata["btitle"] || rft.metadata["title"]
          unless title.nil? || title.empty?
            query << "title:(#{prepare_title(title)})"
          end

          author = rft.metadata["au"] || [rft.metadata["aulast"], rft.metadata["aufirst"]].compact.join(", ")
          unless author.nil? || author.empty?
            query << "author:(#{author})"
          end
        elsif rft.metadata["genre"] == "article"
          title = rft.metadata["jtitle"] || rft.metadata["title"]
          unless title.nil? || title.empty?
            query << "title:(#{prepare_title(title)})"
          end
        elsif rft.metadata["title"] && !rft.metadata["title"].empty?
          query << "title:(#{prepare_title(rft.metadata["title"])})"
        end

        params["query"] = query.join(" AND ")
        params.to_query
      end

      private

      def prepare_title(title)
        '"' + title.delete('"') + '"'
      end
    end
  end
end
