require_relative '../../../lib/link_resolver/primo/metadata'
require_relative '../../../lib/link_resolver/primo/option'
require_relative '../../../lib/link_resolver/primo/option_list'

# You'll need to define or require these classes if they exist or create mocks/stubs.
# require_relative 'metadata'  # Assuming these files are named this way.
# require_relative 'option'

module LinkResolver
  module Primo
    RSpec.describe OptionList do
      let(:metadata) { double('Metadata') }
      let(:option) { double('Option') }
      let(:request) { double('Request', referent: referent) }
      let(:referent) { double('Referent', metadata: {}, set_metadata: nil) }
      let(:delivery_data) do
        {
          "delivery" => {
            "electronicServices" => [{}] # Assuming simple hash structure for illustration
          }
        }
      end
      let(:metadata_data) { { "title" => ["Test Book"] } }

      before do
        allow(Metadata).to receive(:for_json).and_return(metadata)
        allow(Option).to receive(:for_json).and_return(option)
      end

      describe '.for_json' do
        it 'initializes a new OptionList with options and metadata' do
          option_list = described_class.for_json(delivery: delivery_data, metadata: metadata_data)

          expect(option_list).to be_a(described_class)
          expect(Metadata).to have_received(:for_json).with(metadata_data)
          expect(Option).to have_received(:for_json).with({})
        end
      end

      describe '#empty?' do
        it 'returns true when options are empty' do
          option_list = described_class.new(metadata: metadata, options: [])
          expect(option_list).to be_empty
        end

        it 'returns false when options contain items' do
          option_list = described_class.new(metadata: metadata, options: [option])
          expect(option_list).not_to be_empty
        end
      end

      describe '#enhance_metadata' do
        it 'enhances metadata by setting corresponding metadata in referent' do
          allow(metadata).to receive(:each).and_yield({ 'title' => 'Test Book' })

          option_list = described_class.new(metadata: metadata, options: [option])
          option_list.enhance_metadata(request)

          expect(referent).to have_received(:set_metadata).with('title', 'Test Book')
        end
      end

      describe '#add_service' do
        it 'returns false when options are empty' do
          option_list = described_class.new(metadata: metadata, options: [])
          expect(option_list.add_service(request, 'some_service')).to be false
        end

        it 'adds fulltext if options are present' do
          allow(option).to receive(:add_fulltext).and_return(true)

          option_list = described_class.new(metadata: metadata, options: [option])
          result = option_list.add_service(request, 'some_service')

          expect(option).to have_received(:add_fulltext).with(request, hash_including(:service, :service_type_value))
          expect(result).to be true
        end
      end
    end
  end
end

