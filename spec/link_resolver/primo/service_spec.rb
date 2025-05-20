require_relative '../../../lib/link_resolver/primo/option'
require_relative '../../../lib/link_resolver/primo/option_list'
require_relative '../../../lib/link_resolver/primo/metadata'
require_relative '../../../lib/link_resolver/primo/client'
require_relative '../../../lib/link_resolver/primo/service'

# You'll need to define or require these classes if they exist or create mocks/stubs.
# require_relative 'client'

module LinkResolver
  module Primo
    RSpec.describe Service do
      let(:client) { instance_double('LinkResolver::Primo::Client') }
      let(:request) { double('Request', dispatched: nil) }
      let(:options) { double('OptionList', enhance_metadata: nil, add_service: true) }

      before do
        allow(LinkResolver::Primo::Client).to receive(:new).and_return(client)
        allow(client).to receive(:handle).and_return(options)
      end

      describe '#initialize' do
        it 'sets default attributes' do
          service = described_class.new

          expect(service.display_name).to eq("Primo Link Resolver")
          expect(service.display_text).to eq("Get Full Text via Primo Link Resolver")
          expect(service.base_url).to eq("https://umich.primo.exlibrisgroup.com/primaws/rest/pub/pcDelivery/:id?vid=01UMICH_INST:UMICH")
          expect(service.service_id).to eq("Primo")
          expect(service.client).to be(client)
        end
      end

      describe '#handle' do
        it 'handles a request, enhancing metadata and adding services' do
          service = described_class.new

          service.handle(request)

          expect(client).to have_received(:handle).with(request)
          expect(options).to have_received(:enhance_metadata).with(request)
          expect(options).to have_received(:add_service).with(request, service)
          expect(request).to have_received(:dispatched).with(service, true)
        end
      end
    end
  end
end

