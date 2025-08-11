module LinkResolver
  module Primo
    class Client
      attr_reader :primo_key, :primo_host, :primo_scope, :primo_view, :primo_tab, :base_url

      def initialize(base_url)
        @base_url = base_url
        @primo_key = ENV["PRIMO_KEY"]
        @primo_host = ENV["PRIMO_HOST"]
        @primo_scope = ENV["PRIMO_SCOPE"]
        @primo_view  = ENV["PRIMO_VIEW"]
        @primo_tab  = ENV["PRIMO_TAB"]
        @primo_api_connection = Faraday.new(
          "https://#{primo_host}",
          headers: {"Content-Type" => "application/json"}
        )

        @primo_web_connection = Faraday.new(
          @base_url,
          headers: {"Content-Type" => "application/json"}
        )
      end

      def handle(request)
        id = find_primo_id(request.to_context_object)
        return OptionList.new unless id

        doc = fetch_primo_record(id)
        return OptionList.new unless doc

        delivery = fetch_delivery_options(doc)
        OptionList.for_json(delivery: delivery, metadata: doc["pnx"]["addata"])
      end

      private

      def fetch_delivery_options(doc)
        uri = URI(base_url.sub(":id", doc["@id"].split("/").last))
        response = @primo_web_connection.post(uri.path) do |req|
          req.body = { doc: doc }.to_json
        end
        JSON.parse(response.body).tap do |obj|
          next unless obj["delivery"] && obj["delivery"]["electronicServices"]
          obj["delivery"]["electronicServices"].each do |service|
            service["serviceUrl"] = "#{uri.scheme}://#{uri.host}#{service["serviceUrl"]}"
          end
        end
      end

      def fetch_primo_record(id)
        response = @primo_api_connection.get("/primo/v1/search") do |req|
          req.params["q"] = "id,exact,#{id}"
          req.params["apikey"] = primo_key
          req.params["tab"] = primo_tab
          req.params["scope"] = primo_scope
          req.params["vid"] = primo_view
        end
        JSON.parse(response.body)["docs"].first
      end

      def find_primo_id(context_object)
        if (primo_identifier = context_object.referent.identifiers.find { |identifier| identifier.start_with?("info:primo/") })
          return primo_identifier[11, primo_identifier.length]
        end
        nil
      end
    end
  end
end
