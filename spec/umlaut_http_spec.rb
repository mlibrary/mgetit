require_relative '../lib/umlaut_http.rb'

RSpec.describe UmlautHttp do
 let(:dummy_class) do
    Class.new do
      include UmlautHttp
    end
  end
  describe '.proxy_like_headers' do
    let(:fake_http_env) do
      {
        "HTTP_USER_AGENT" => "FakeAgent",
        "HTTP_ACCEPT" => "*/*",
        "HTTP_ACCEPT_LANGUAGE" => "en,fr",
        "HTTP_ACCEPT_ENCODING" => "",
        "HTTP_ACCEPT_CHARSET" => "ISO-8859-1, utf-8",
        "HTTP_HOST" => "localhost",
        "REQUEST_URI" => "/test",
        "HTTP_X_FORWARDED_FOR" => "1.2.3.4",
        "REMOTE_ADDR" => "1.2.3.4",
        "SERVER_NAME" => "localhost"
      }
    end
    let(:request) { double("request", http_env: fake_http_env, client_ip_addr: "1.2.3.4") }
    
    it 'generates proper headers for a proxy-like request' do
      headers = dummy_class.new.proxy_like_headers(request, 'example.com')
      expect(headers["User-Agent"]).to eq("FakeAgent")
      expect(headers["Accept"]).to eq("*/*")
      expect(headers["Referer"]).to eq("http://localhost/test")
      expect(headers["X-Forwarded-For"]).to eq("1.2.3.4, 1.2.3.4")
      expect(headers["Accept-Encoding"]).to eq("identity")
      expect(headers["X-Forwarded-Host"]).to eq('example.com')
    end
  end

  describe '.http_fetch' do
    let(:url) { 'http://example.com/resource' }
    let(:http_response) { Net::HTTPOK.new('1.1', 200, 'OK') }

    before do
      allow(Net::HTTP).to receive(:new).and_return(double("net_http", request_get: http_response))
    end
    
    context 'when the request is successful' do
      it 'returns the response' do
        response = dummy_class.new.http_fetch(url)
        expect(response).to be_a(Net::HTTPSuccess)
      end
    end

    context 'when the request is a redirection' do
      let(:http_response) { Net::HTTPRedirection.new('1.1', 301, 'Moved Permanently') }
      
      before do
        http_response['location'] = 'http://example.com/new_location'
        stub_request(:get, 'http://example.com/new_location').to_return(status: 200, body: 'Success')
      end

      it 'raises an ArgumentError' do
        expect {
          dummy_class.new.http_fetch(url)
        }.to raise_error(ArgumentError, /redirect too deep/)
      end
    end

    context 'when the max redirects is exceeded' do
      it 'raises an ArgumentError' do
        stub_request(:get, url).to_return(status: 301, headers: { 'Location' => url })
        
        response = dummy_class.new.http_fetch(url, max_redirects: 3)
        expect(response.code).to eq(200)
      end
    end
  end
end

