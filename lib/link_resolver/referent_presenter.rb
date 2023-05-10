module LinkResolver
  class ReferentPresenter
    attr_reader :referent

    def initialize(referent)
      @referent = referent
    end

    def format
      referent.format
    end

    def metadata
      referent.metadata
    end

    def identifiers
      referent.identifiers
    end

    def title
      metadata["title"]
    end

    def author
      metadata["au"]
    end

    def container_title
      metadata["container_title"]
    end

    def volume
      metadata["volume"]
    end

    def issue
      metadata["issue"]
    end

    def date
      metadata["date"]
    end

    def page
      metadata["page"]
    end

    def pages
      metadata["pages"]
    end

    def spage
      metadata["spage"]
    end

    def epage
      metadata["epage"]
    end

    def issn
      metadata["issn"]
    end

    def isbn
      metadata["isbn"]
    end

    def type
      metadata["genre"]&.titlecase
    end

    def container_type
      format&.titlecase
    end

    def pmid
      identifiers.each do |id|
        if id.start_with?("info:pmid/")
          return id[10, id.length]
        end
      end
      nil
    end

    def doi
      identifiers.each do |id|
        if id.start_with?("info:doi/")
          return id[9, id.length]
        end
      end
      nil
    end
  end
end
