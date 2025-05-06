require_relative '../../../lib/link_resolver/primo/option'

RSpec.describe LinkResolver::Primo::Option do
  let(:valid_json) do
    {
      "serviceType" => "someType",
      "serviceUrl" => "http://example.com",
      "filtered" => "false",
      "availability" => "Available",
      "authNote" => "Note1Note1",
      "publicNote" => "Public Note",
      "packageName" => "Some Package"
    }
  end

  describe '.for_json' do
    it 'initializes a new Option with the correct attributes' do
      option = described_class.for_json(valid_json)
      expect(option.url).to eq("http://example.com")
    end
  end

  describe '#filtered?' do
    it 'returns true if filtered is "true"' do
      filtered_json = valid_json.merge("filtered" => "true")
      option = described_class.new(attributes: filtered_json.map { |k, v| { k => v } })
      expect(option.filtered?).to be true
    end

    it 'returns false if filtered is not "true"' do
      option = described_class.new(attributes: valid_json.map { |k, v| { k => v } })
      expect(option.filtered?).to be false
    end
  end

  describe '#notes' do
    it 'joins available notes with newlines' do
      option = described_class.new(attributes: valid_json.map { |k, v| { k => v } })
      expected_notes = "Available\nNote1Note1\nPublic Note"
      expect(option.notes).to eq(expected_notes)
    end
  end

  describe '#package_name' do
    it 'returns the first package name' do
      option = described_class.new(attributes: valid_json.map { |k, v| { k => v } })
      expect(option.package_name).to eq("Some Package")
    end
  end

  describe '#availability' do
    let(:json_with_availability) { valid_json.merge("availiability" => "<br>Out of Stock") }

    it 'replaces <br> with new line' do
      option = described_class.new(attributes: json_with_availability.map { |k, v| { k => v } })
      expect(option.availability).to eq("Available")
    end
  end

  describe '#authentication_note' do
    it 'returns the first authNote' do
      option = described_class.new(attributes: valid_json.map { |k, v| { k => v } })
      expect(option.authentication_note).to eq("Note1")
    end
  end

  describe '#public_note' do
    it 'returns the first public note' do
      option = described_class.new(attributes: valid_json.map { |k, v| { k => v } })
      expect(option.public_note).to eq("Public Note")
    end
  end

  describe '#add_fulltext' do
    it 'does not add fulltext if filtered' do
      request = double('Request', add_service_response: nil)
      option = described_class.new(attributes: valid_json.map { |k, v| { k => v } }, type: "someType", url: "http://example.com")
      allow(option).to receive(:filtered?).and_return(true)
      expect(option.add_fulltext(request, {})).to be_nil
    end

    it 'adds fulltext if not filtered' do
      request = double('Request')
      option = described_class.new(attributes: valid_json.map { |k, v| { k => v } }, type: "someType", url: "http://example.com")
      allow(option).to receive(:filtered?).and_return(false)
      expect(request).to receive(:add_service_response).with(hash_including(
        display_text: "Go To Item",
        package_name: "Some Package",
        url: "http://example.com",
        availability: "Available"
      ))
      option.add_fulltext(request, {})
    end
  end
end
