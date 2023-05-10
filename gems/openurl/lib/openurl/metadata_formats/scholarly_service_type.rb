#
# scholarly_service_type.rb
#
# Created on Nov 1, 2007, 10:35:28 AM
#
# To change this template, choose Tools | Templates
# and open the template in the editor.

module OpenURL
  class ScholarlyServiceType < ContextObjectEntity
    def initialize
      super
      @format = "sch_svc"
      @metadata_keys = ["abstract", "citation", "fulltext", "holdings", "ill", "any"]
      @xml_ns = "info:ofi/fmt:xml:xsd:sch_svc"
      @kev_ns = "info:ofi/fmt:kev:mtx:sch_svc"
    end

    def method_missing(metadata, value = nil)
      meta = metadata.to_s.sub(/=$/, "")
      raise ArgumentError, "#{meta} is not a valid #{self.class} metadata field." unless @metadata_keys.index(meta)
      if /=$/.match?(metadata.to_s)
        set_metadata(meta, value)
      else
        self.metadata[meta]
      end
    end
  end

  class ScholarlyServiceTypeFactory < ContextObjectEntityFactory
    @@identifiers = ["info:ofi/fmt:kev:mtx:sch_svc", "info:ofi/fmt:xml:xsd:sch_svc"]
    def self.identifiers
      @@identifiers
    end

    def self.create
      OpenURL::ScholarlyServiceType.new
    end
  end
end
