module LinkResolver
  class Presenter
    def self.for(obj)
      if OpenURL::ContextObjectEntity === obj
        if obj.format == "journal"
          if obj.metadata["genre"] == "article"
            return ArticlePresenter.new(obj)
          end
        end
        return ReferentPresenter.new(obj)
      elsif Hash === obj
        if obj.has_key?(:service_type_response)
          return ServiceResponsePresenter.new(obj)
        end
      end
      obj
    end
  end
end
