module LinkResolver
  class ServiceResponsePresenter
    attr_reader :service_response

    def initialize(service_response)
      @service_response = service_response
    end

    def label
      service_response[:display_text] || "Go To Item"
    end

    def href
      service_response[:url]
    end

    def authentication_note
      service_response[:authentication_note]
    end

    def public_note
      service_response[:public_note]
    end

    def availability
      service_response[:availability]
    end

    def package_name
      service_response[:package_name]
    end
  end
end
