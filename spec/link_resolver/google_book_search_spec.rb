module LinkResolver
  RSpec.describe GoogleBookSearch do
    let(:service) { described_class.new }
    let(:request) { double('request') }
    let(:referent) { double('referent') }

    before do
      allow(request).to receive(:referent).and_return(referent)
      allow(service).to receive(:http_fetch)
    end

    describe '#service_id' do
      it 'returns gbs' do
        expect(service.service_id).to eq("gbs")
      end
    end

    describe '#service_types_generated' do
      it 'returns the correct service types based on initial settings' do
        expect(service.service_types_generated).to contain_exactly(:fulltext, :cover_image)
      end
    end

    describe '#handle' do
      context 'when valid bibkeys are passed' do
        before do
          allow(referent).to receive(:identifiers).and_return(["urn:isbn:1234567890"])
          allow(service).to receive(:get_bibkeys).and_return("sample_bibkeys")
          allow(service).to receive(:do_query).and_return({"totalItems" => 1, "items" => [{"accessInfo" => {"viewability" => true}}]})
        end

        it 'dispatches the request as handled successfully' do
          allow(request).to receive(:dispatched)
          service.handle(request)
          expect(request).to have_received(:dispatched).with(service, true)
        end
      end

      context 'when no bibkeys are found' do
        before do
          allow(service).to receive(:get_bibkeys).and_return(nil)
          allow(request).to receive(:dispatched)
        end

        it 'dispatches the request immediately' do
          service.handle(request)
          expect(request).to have_received(:dispatched).with(service, true)
        end
      end
    end

    describe '#get_bibkeys' do
      it 'returns a string of escaped bibkeys' do
        allow(referent).to receive(:identifiers).and_return(["urn:isbn:1234567890"])
        allow(referent).to receive(:lccn).and_return(nil)
        allow(referent).to receive(:get_metadata).and_return(nil)
        allow(referent).to receive(:metadata).and_return({})

        bibkeys = service.get_bibkeys(referent)
        expect(bibkeys).to eq(CGI.escape('isbn:1234567890'))
      end
    end

    describe '#do_query' do
      it 'returns parsed data from an API request' do
        allow(service).to receive(:build_headers).and_return({})
        allow(service).to receive(:http_fetch).and_return(double(body: '{}'))
      
        data = service.do_query('test_query', request)
        expect(data).to be_a(Hash)
      end
    end

    describe '#enhance_referent' do
      it 'enhances the referent with title, author and publisher from volumeInfo' do
        mock_data = {
          "items" => [{ "volumeInfo" => { "title" => "Test Title", "authors" => ["Author"], "publisher" => "Publisher" } }]
        }

        allow(request).to receive(:referent).and_return(referent)
        allow(referent).to receive(:enhance_referent)

        service.enhance_referent(request, mock_data)

        expect(referent).to have_received(:enhance_referent).with("title", "Test Title", true, false, overwrite: false)
        expect(referent).to have_received(:enhance_referent).with("au", "Author", true, false, overwrite: false)
        expect(referent).to have_received(:enhance_referent).with("pub", "Publisher", true, false, overwrite: false)
      end
    end

    describe '#build_headers' do
      it 'returns headers with X-Forwarded-For when client IP is valid' do
        allow(request).to receive(:http_env).and_return({})
        allow(request).to receive(:client_ip_addr).and_return("1.1.1.1")
        headers = service.build_headers(request)
        expect(headers).to eq("X-Forwarded-For" => "1.1.1.1")
      end
    end
  end
end
