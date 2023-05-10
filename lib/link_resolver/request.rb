module LinkResolver
  class Request
    attr_accessor :raw_request, :context_object, :service_responses,
      :dispatched_service, :dispatched_status, :request_id

    def self.for_raw_request(raw_request)
      new(
        raw_request,
        OpenURL::ContextObject.new_from_kev(raw_request.query_string)
      )
    end

    def initialize(raw_request, context_object)
      self.raw_request = raw_request
      self.context_object = context_object
      self.service_responses = []
    end

    def to_context_object
      OpenURL::ContextObject.new_from_context_object(context_object)
    end

    def referent
      context_object.referent
    end

    def add_service_response(response)
      service_responses << response
    end

    def http_env
      raw_request.env
    end

    def permalink_url
      return "" unless request_id
      return "#{ENV['RAILS_RELATIVE_URL_ROOT']}/go/#{request_id}" if ENV['RAILS_RELATIVE_URL_ROOT']
      "#{http_env["rack.url_scheme"]}://#{http_env["SERVER_NAME"]}#{[80, 443].include?(http_env["SERVER_PORT"])? "" : ":" }#{http_env["SERVER_PORT"]}/go/#{request_id}"
    end

    def dispatched(service, status)
      dispatched_service = service
      dispatched_status = status
    end

    def not_available_online
      get_service_type("holding_search") + get_service_type("document_delivery")
    end

    def found_a_problem
      get_service_type("help")
    end

    def fulltext
      get_service_type("fulltext")
    end

    def referent_presenter
      ReferentPresenter.new(referent)
    end

    def get_service_type(type)
      ret = []
      service_responses.each do |response|
        ret << response if response[:service_type_value_name] == type.to_s
      end
      ret
    end
  end
end
