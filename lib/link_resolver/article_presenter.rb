module LinkResolver
  class ArticlePresenter < ReferentPresenter
    def title
      metadata["atitle"]
    end

    def container_title
      metadata["jtitle"]
    end
  end
end
