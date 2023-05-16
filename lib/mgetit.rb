$:.unshift File.dirname(__FILE__)

require "link_resolver"
require "marc_helper"
require "metadata_helper"
require "rails"
require "sinatra/activerecord"
Dir.glob(File.join("models", "*.rb"), base: File.dirname(__FILE__)) do |model|
  require model
end

class MGetIt < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure do
    enable :sessions
    #set :logging, Logger.new(STDOUT)
  end

  helpers do
    def t(text, default: nil)
      {
        "umlaut.call_to_action.default" => "Go To Item"
      }.fetch(text, default || text)
    end

    def link_resolvers
      @link_resolvers ||= [
        LinkResolver::GoogleBookSearch.new,
        LinkResolver::Alma::Service.new,
        LinkResolver::Catalog::Service.new
      ]
    end

    def link_to(inner_text = nil, href = nil, params = {})
      if Hash === inner_text
        params = inner_text
        inner_text = nil
      end
      attributes = if href
        [
          "href=\"#{CGI.escapeHTML(href)}\""
        ]
      else
        []
      end
      [:href, :target, :rel, :class].each do |param|
        if params[param]
          attributes << "#{param}=\"#{CGI.escapeHTML(params[param])}\""
        end
      end
      "<a #{attributes.join(" ")}>#{(inner_text && CGI.escapeHTML(inner_text)) || yield}</a>"
    end

    def asset_path(file)
      ["images", "javascripts", "stylesheets"].each do |type|
        if File.exist?("public/assets/#{type}/#{file}")
          return "/assets/#{type}/#{file}"
        end
      end
      "/#{file}"
    end
  end

  not_found do
    resolver_request = LinkResolver::Request.for_raw_request(request)
    erb :application, locals: {request: resolver_request} do
      "Page not found"
    end
  end

  get '/sfx_locater' do
    if request.query_string.nil? || request.query_string.length == 0
      redirect "/citation-linker/"
    else
      redirect "/resolve?" + request.query_string
    end
  end

  get "/" do
    if request.query_string.nil? || request.query_string.length == 0
      redirect "/citation-linker/"
    else
      redirect "/resolve?" + request.query_string
    end
  end

  get "/resource/proxy" do
    service_response = ServiceResponse.find_by_id(params["id"])
    if service_response
      proxy = LinkResolver::Proxy.new(service_response.url, request)
      headers(proxy.headers)
      proxy.data
    else
      status 404
      resolver_request = LinkResolver::Request.for_raw_request(request)
      erb :application, locals: {request: resolver_request} do
        "Page not found"
      end
    end
  end

  get "/link_router/index/:id" do
    service_response = ServiceResponse.find_by_id(params["id"])
    if service_response
      redirect service_response.url
    else
      status 404
      resolver_request = LinkResolver::Request.for_raw_request(request)
      erb :application, locals: {request: resolver_request} do
        "Page not found"
      end
    end
  end

  error Exception do
    resolver_request = LinkResolver::Request.for_raw_request(request)
    erb :application, locals: {request: resolver_request} do
      "Internal Server Error"
    end
  end

  get "/go/:id" do
    resolver_request = LinkResolver::Request.for_raw_request(request)
    user_request = Request.find_by_id(params["id"])
    if user_request
      resolver_request.context_object = user_request.referent.to_context_object
      resolver_request.service_responses = user_request.service_responses
      resolver_request.request_id = user_request.id
      erb :application, locals: {request: resolver_request, user_request: user_request} do
        erb :resolve, locals: {request: resolver_request, user_request: user_request}
      end
    else
      status 404
      erb :application, locals: {request: resolver_request} do
        "Page not found"
      end
    end
  end

  get "/resolve" do
    params.values.each { |v| v.scrub! if v.respond_to?(:scrub!) }
    options = {}
    user_request ||= Request.find_or_create(params, request.session, request, options)
    resolver_request = LinkResolver::Request.for_raw_request(request)
    if user_request.service_responses.empty?
      link_resolvers.each do |resolver|
        resolver.handle(resolver_request)
      end
      resolver_request.service_responses.each do |response|
        user_request.add_service_response(response)
      end
      resolver_request.referent.metadata.each_pair do |k, v|
        user_request.referent.enhance_referent(k, v)
      end
      user_request.save
    end
    resolver_request.context_object = user_request.referent.to_context_object
    resolver_request.service_responses = user_request.service_responses
    resolver_request.request_id = user_request.id

    erb :application, locals: {request: resolver_request, user_request: user_request} do
      erb :resolve, locals: {request: resolver_request, user_request: user_request}
    end
  end
end
