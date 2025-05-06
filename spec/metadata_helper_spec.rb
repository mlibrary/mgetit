require 'ostruct' # For creating mock-like objects
require 'cgi' # For unescaping URIs

require_relative "../lib/marc_helper"
require_relative "../lib/metadata_helper"

RSpec.describe MetadataHelper do
  let(:test_class) do
    Class.new do
      include MetadataHelper
    end
  end

  let(:instance) { test_class.new }
  let(:referent) do
    OpenStruct.new(
      identifiers: [],
      metadata: {
        "title" => "Example Title",
        "aulast" => "Doe"
      },
      format: "journal"
    )
  end

  describe '#get_search_terms' do
    it 'returns a hash with title and creator' do
      result = instance.get_search_terms(referent)
      expect(result).to eq(title: "example title", creator: "Doe")
    end
  end

  describe '#normalize_title' do
    it 'normalizes a title by applying various heuristics' do
      title = "The Great Gatsby [electronic resource]"
      result = instance.normalize_title(title)
      expect(result).to eq('the great gatsby')
    end
  end

  describe '#get_search_title' do
    it 'returns a normalized search title based on metadata' do
      result = instance.get_search_title(referent)
      expect(result).to eq('example title')
    end
  end

  describe '#get_search_creator' do
    it 'selects the best available creator from metadata' do
      result = instance.get_search_creator(referent)
      expect(result).to eq('Doe')
    end
  end

  describe '#get_identifier' do
    it 'retrieves an identifier from referent metadata' do
      referent.identifiers = ["info:oclcnum/123456"]
      result = instance.get_identifier(:info, 'oclcnum', referent)
      expect(result).to eq('123456')
    end
  end

  describe '#get_lccn' do
    it 'returns a normalized LCCN from metadata' do
      allow(instance).to receive(:get_identifier).with(:info, "lccn", referent).and_return("123456789")
      result = instance.get_lccn(referent)
      expect(result).to eq('123456789')
    end
  end

  describe '#get_issn' do
    it 'returns a valid ISSN if present in metadata' do
      referent.metadata["issn"] = "1234-5678"
      result = instance.get_issn(referent)
      expect(result).to eq('1234-5678')
    end

    it 'returns nil for an invalid ISSN' do
      referent.metadata["issn"] = "invalid"
      result = instance.get_issn(referent)
      expect(result).to be_nil
    end
  end

  describe '#get_isbn' do
    it 'returns a stripped and valid ISBN from identifiers' do
      allow(instance).to receive(:get_identifier).with(:urn, "isbn", referent).and_return("0-123-45678-X")
      result = instance.get_isbn(referent)
      expect(result).to eq('012345678X')
    end
  end

  describe '#get_year' do
    it 'retrieves a year from metadata' do
      referent["date"] = "2023-01-01"
      result = instance.get_year(referent)
      expect(result).to eq("2023")
    end
  end

  describe '#title_is_serial?' do
    it 'determines the title is a serial based on metadata conditions' do
      referent.metadata = { "genre" => "journal", "jtitle" => "Some Journal" }
      result = MetadataHelper.title_is_serial?(referent)
      expect(result).to be true
    end
  end
end

