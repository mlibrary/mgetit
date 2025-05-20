require_relative '../../../lib/link_resolver/alma/option'
require 'nokogiri' # Assuming you're using Nokogiri for XML parsing

module LinkResolver
  module Alma
    RSpec.describe Option do
      let(:context_service) do
        xml_string = File.read("spec/fixtures/openurl_response.xml").encode('UTF-8')
 #<<-XML
          #<service xmlns="http://com/exlibris/urm/uresolver/xmlbeans/u" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            #<service_type>someType</service_type>
            #<resolution_url>http://example.com</resolution_url>
          #</service>
        #XML
        Nokogiri::XML(xml_string).xpath("//xmlns:context_service").first
      end

      let(:attributes) do
        [
          { "Filtered" => "false" },
          { "Availability" => "Available" },
          { "Authentication_note" => "Note" },
          { "package_display_name" => "Sample Package" },
          { "public_note" => "Public Note" }
        ]
      end

      before do
        allow(LinkResolver::Alma).to receive(:extract_keys).and_return(attributes)
      end

      describe '.for_xml_object' do
        it 'creates a new Option instance with attributes and url from XML' do
          option = described_class.for_xml_object(context_service)

          expect(option).to be_a(described_class)
          expect(LinkResolver::Alma).to have_received(:extract_keys).with(context_service)
          expect(option.url).to eq("https://umich.alma.exlibrisgroup.com/view/action/uresolver.do?operation=resolveService&package_service_id=80396425340006381&institutionId=6381&customerId=6380")
        end
      end

      describe '#filtered?' do
        it 'returns false when Filtered is not "true"' do
          option = described_class.new(attributes: attributes)
          expect(option.filtered?).to be false
        end
      end

      describe '#notes' do
        it 'returns joined notes' do
          option = described_class.new(attributes: attributes)
          expected_notes = "Available\nNote\nPublic Note"
          expect(option.notes).to eq(expected_notes)
        end
      end

      describe '#package_name' do
        it 'returns the package display name' do
          option = described_class.new(attributes: attributes)
          expect(option.package_name).to eq("Sample Package")
        end
      end

      describe '#availability' do
        it 'returns availability with <br> replaced by new line' do
          option = described_class.new(attributes: attributes)
          expect(option.availability).to eq("Available")
        end
      end

      describe '#authentication_note' do
        it 'returns the appropriate authentication note' do
          option = described_class.new(attributes: attributes)
          expect(option.authentication_note).to eq("Note")
        end
      end

      describe '#public_note' do
        it 'returns the public note' do
          option = described_class.new(attributes: attributes)
          expect(option.public_note).to eq("Public Note")
        end
      end

      describe '#add_fulltext' do
        let(:request) { double('Request', add_service_response: nil) }
        let(:base) { { service: 'some_service' } }

        it 'does not add fulltext if filtered' do
          filtered_attributes = attributes.dup
          filtered_attributes << { "Filtered" => "true" }
          option = described_class.new(attributes: filtered_attributes)
          expect(option.add_fulltext(request, base)).to be_nil
        end

        it 'adds fulltext if not filtered' do
          option = described_class.new(attributes: attributes, url: "http://example.com")
          allow(option).to receive(:filtered?).and_return(false)

          expected_response = {
            display_text: "Go To Item",
            package_name: "Sample Package",
            url: "http://example.com",
            availability: "Available",
            authentication_note: "Note",
            public_note: "Public Note"
          }

          expect(request).to receive(:add_service_response).with(hash_including(expected_response))
          option.add_fulltext(request, base)
        end
      end
    end
  end
end

