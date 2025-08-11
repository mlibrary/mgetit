RSpec.describe "/resolve routes", type: :request do
  include Rack::Test::Methods
  let(:app) { MGetIt }

  before do
    stub_request(:get, "https://na04.alma.exlibrisgroup.com/view/uresolver/01UMICH_INST/openurl-UMAA?ctx_enc=info:ofi/enc:UTF-8&ctx_id=&ctx_tim=2025-01-01T00:00:00%2B00:00&ctx_ver=Z39.88-2004&rft_id=info:pmid/12345&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&svc_dat=CTO&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&url_ver=Z39.88-2004").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
      }).
      to_return(status: 200, body: File.read("spec/fixtures/pmid=12345.xml"), headers: {})

    stub_request(:head, "https://umich.alma.exlibrisgroup.com/view/action/uresolver.do?customerId=6380&institutionId=6381&operation=resolveService&package_service_id=80443525680006381").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: "", headers: {})

    stub_request(:get, "https://www.googleapis.com/books/v1/volumes?printType=books&q=isbn:0190228636").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby',
          'X-Forwarded-For'=>'127.0.0.1'
      }).
      to_return(status: 200, body: File.read("spec/fixtures/isbn=0190228636.json"), headers: {})

    stub_request(:get, "https://na04.alma.exlibrisgroup.com/view/uresolver/01UMICH_INST/openurl-UMAA?ctx_enc=info:ofi/enc:UTF-8&ctx_id=&ctx_tim=2025-01-01T00:00:00%2B00:00&ctx_ver=Z39.88-2004&rft_id=info:doi/10.1108/9781804556108&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&svc_dat=CTO&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&url_ver=Z39.88-2004").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
      }).
      to_return(status: 200, body: File.read("spec/fixtures/doi.xml"), headers: {})

    stub_request(:head, "https://umich.alma.exlibrisgroup.com/view/action/uresolver.do?customerId=6380&institutionId=6381&operation=resolveService&package_service_id=80443569600006381").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
      }).
      to_return(status: 200, body: "", headers: {})

    stub_request(:get, "https://na04.alma.exlibrisgroup.com/view/uresolver/01UMICH_INST/openurl-UMAA?ctx_enc=info:ofi/enc:UTF-8&ctx_id=10_1&ctx_tim=2024-10-22%2014:04:37&ctx_ver=Z39.88-2004&rfr_id=info:sid/primo.exlibrisgroup.com-oup&rft.atitle=The%20Strategic%20Use%20of%20State%20Repression%20and%20Political%20Violence&rft.au=Jacqueline%20H.%20R.%20deMeritt&rft.btitle=Oxford%20Research%20Encyclopedia%20of%20Politics&rft.date=2016-10-26&rft.genre=chapter&rft.isbn=0190228636&rft.pub=Oxford%20University%20Press&rft.rft_oup_id=10_1093_acrefore_9780190228637_013_32&rft.utm_source=library-search&rft_dat=%3Coup%3E10_1093_acrefore_9780190228637_013_32%3C/oup%3E&rft_id=info:doi/10.1093/acrefore/9780190228637.013.32&rft_val_fmt=info:ofi/fmt:kev:mtx:book&svc_dat=CTO&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&url_ver=Z39.88-2004").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
      }).
      to_return(status: 200, body: File.read("spec/fixtures/openurl.xml"), headers: {})

    stub_request(:head, "https://umich.alma.exlibrisgroup.com/view/action/uresolver.do?customerId=6380&institutionId=6381&operation=resolveService&package_service_id=80443569570006381").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
      }).
      to_return(status: 200, body: "", headers: {})
  end

  context "GET /resolve" do
    let(:pmid_links) do
      Nokogiri::HTML(get("/resolve?pmid=12345&ctx_tim=2025-01-01T00:00:00%2B00:00").body).css(".fulltext-link")
    end
    let(:doi_links) do
      Nokogiri::HTML(get("/resolve?doi=10.1108/9781804556108&ctx_tim=2025-01-01T00:00:00%2B00:00").body).css(".fulltext-link")
    end
    let(:book_links) do
      Nokogiri::HTML(get(
        "/resolve?ctx_enc=info%3Aofi%2Fenc%3AUTF-8&ctx_id=10_1&ctx_tim=2024-10-22+14%3A04%3A37&ctx_ver=Z39.88-2004&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&url_ver=Z39.88-2004&rfr_id=info%3Asid%2Fprimo.exlibrisgroup.com-oup&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&rft.genre=chapter&rft.atitle=The+Strategic+Use+of+State+Repression+and+Political+Violence&rft.btitle=Oxford+Research+Encyclopedia+of+Politics&rft.au=Jacqueline+H.+R.+deMeritt&rft.date=2016-10-26&rft.isbn=0190228636&rft_id=info%3Adoi%2F10.1093%2Facrefore%2F9780190228637.013.32&rft.pub=Oxford+University+Press&rft_dat=<oup>10_1093_acrefore_9780190228637_013_32<%2Foup>&svc_dat=viewit&rft_oup_id=10_1093_acrefore_9780190228637_013_32&utm_source=library-search"
      ).body).css(".fulltext-link")
    end

    it "retrieves pmids" do
      expect(pmid_links.count).to be > 0
    end

    it "retrieves dois" do
      expect(doi_links.count).to be > 0
    end

    it "retrieves books" do
      expect(book_links.count).to be > 0
    end
  end
end
