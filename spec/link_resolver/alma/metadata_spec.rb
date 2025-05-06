require_relative '../../../lib/link_resolver/alma/metadata'

# Assuming the LinkResolver::Alma module and the Metadata class are defined
module LinkResolver
  module Alma
    RSpec.describe Metadata do
      let(:context_object) { double('ContextObject') }
      let(:attributes) do
        [
          { "title" => "Example Title" },
          { "author" => "Example Author" },
          { "year" => "2023" }
        ]
      end

      before do
        allow(LinkResolver::Alma).to receive(:extract_keys).and_return(attributes)
      end

      describe '.for_xml_object' do
        it 'creates a new Metadata instance with extracted attributes' do
          metadata = described_class.for_xml_object(context_object)

          expect(metadata).to be_a(described_class)
          expect(LinkResolver::Alma).to have_received(:extract_keys).with(context_object)
          expect(metadata["title"]).to eq(["Example Title"])
          expect(metadata["author"]).to eq(["Example Author"])
          expect(metadata["year"]).to eq(["2023"])
        end
      end

      describe '#each' do
        it 'iterates over each attribute key-value pair' do
          metadata = described_class.new(attributes)
          expect { |block| metadata.each(&block) }.to yield_successive_args(
            { "title" => "Example Title" },
            { "author" => "Example Author" },
            { "year" => "2023" }
          )
        end
      end

      describe '#[]' do
        it 'retrieves the value array for a given key' do
          metadata = described_class.new(attributes)
          expect(metadata["title"]).to eq(["Example Title"])
          expect(metadata["author"]).to eq(["Example Author"])
          expect(metadata["year"]).to eq(["2023"])
        end

        it 'returns an empty array if the key is not present' do
          metadata = described_class.new(attributes)
          expect(metadata["nonexistent"]).to eq([])
        end
      end
    end
  end
end

