require 'open-uri'

RSpec.describe LinkResolver::Proxy do
  describe '#initialize' do
    let(:valid_url) { 'http://example.com/image.jpg' }
    let(:fake_request) { double("request", env: {
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
    }) }

    before do
      stub_request(:get, valid_url).to_return(
        status: 200,
        body: "fake image data",
        headers: { "Content-Type" => "image/jpeg" }
      )
    end

    context 'with a valid URL' do
      it 'successfully initializes with correct data and headers' do
        proxy = described_class.new(valid_url, fake_request)
        expect(proxy.data).to eq("fake image data")
        expect(proxy.headers["Content-Type"]).to eq("image/jpeg")
        expect(proxy.headers["X-Original-Url"]).to eq(valid_url)
      end
    end

    context 'with an invalid URL' do
      it 'raises an exception' do
        expect {
          described_class.new('not_a_valid_url', fake_request)
        }.to raise_error(NoMethodError)
      end
    end

    context 'with a timeout error' do
      it 'raises a timeout error' do
        stub_request(:get, valid_url).to_timeout

        expect {
          described_class.new(valid_url, fake_request)
        }.to raise_error(Timeout::Error)
      end
    end
  end

  describe '#proxy_headers' do
    let(:fake_request) { double("request", env: {
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
    }) }
    let(:url) { 'http://example.com' }
    let(:proxy) { described_class.new(url, fake_request) }

    it 'generates proper proxy headers' do
stub_request(:get, "http://example.com/").
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Charset'=>'ISO-8859-1, utf-8',
       	  'Accept-Encoding'=>'',
       	  'Accept-Language'=>'en,fr',
       	  'Referer'=>'http://localhost/test',
       	  'User-Agent'=>'FakeAgent',
       	  'X-Forwarded-For'=>'1.2.3.4, 1.2.3.4',
       	  'X-Forwarded-Host'=>'example.com',
       	  'X-Forwarded-Server'=>'localhost'
           }).
         to_return(status: 200, body: "", headers: {})

      headers = proxy.send(:proxy_headers, fake_request, 'example.com')
      expect(headers["User-Agent"]).to eq("FakeAgent")
      expect(headers["Accept"]).to eq("*/*")
      expect(headers["Referer"]).to eq("http://localhost/test")
      expect(headers["X-Forwarded-For"]).to eq("1.2.3.4, 1.2.3.4")
    end
  end
end
