require_relative '../../../lib/link_resolver/primo/metadata'


RSpec.describe LinkResolver::Primo::Metadata do
      let(:json_data) do
        {
          "title" => ["Book Title"],
          "author" => ["Author Name"],
          "date" => ["2023"]
        }
      end

      describe '.for_json' do
        it 'initializes a new Metadata instance with structured attributes' do
          metadata = described_class.for_json(json_data)
          expect(metadata).to be_a(described_class)
          expect(metadata["title"]).to eq(["Book Title"])
          expect(metadata["author"]).to eq(["Author Name"])
          expect(metadata["date"]).to eq(["2023"])
        end
      end

      describe '#each' do
        it 'iterates over each attribute key-value pair' do
          metadata = described_class.for_json(json_data)
          expect { |block| metadata.each(&block) }.to yield_successive_args(
            { "title" => "Book Title" },
            { "author" => "Author Name" },
            { "date" => "2023" }
          )
        end
      end

      describe '#[]' do
        it 'retrieves the value array for a given key' do
          metadata = described_class.for_json(json_data)
          expect(metadata["title"]).to eq(["Book Title"])
          expect(metadata["author"]).to eq(["Author Name"])
          expect(metadata["date"]).to eq(["2023"])
        end

        it 'returns an empty array if the key is not present' do
          metadata = described_class.for_json(json_data)
          expect(metadata["nonexistent"]).to eq([])
        end
      end
end
