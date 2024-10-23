RSpec.describe "/resolve routes", type: :request do
  include Rack::Test::Methods
  let(:app) { MGetIt }

  context "GET /resolve" do
    let(:pmid_links) do
      Nokogiri::HTML(get("/resolve?pmid=12345").body).css(".fulltext-link")
    end
    let(:doi_links) do
      Nokogiri::HTML(get("/resolve?doi=10.1108/9781804556108").body).css(".fulltext-link")
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
