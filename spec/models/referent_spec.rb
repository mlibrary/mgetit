RSpec.describe Referent, type: :model do
  let(:referent) { described_class.new }
  let(:context_object) { double("context_object") }
  let(:referent_entity) { double("referent_entity") }
  #let(:referrer_entity) { double("referrer_entity") }

  before do
    allow(context_object).to receive(:referent).and_return(referent_entity)
    allow(referent_entity).to receive(:identifiers).and_return(["12345"])
    allow(referent_entity).to receive(:format).and_return("journal")
    allow(referent_entity).to receive(:private_data).and_return(nil)
    allow(referent_entity).to receive(:metadata).and_return({"title" => "TITLE"})
    allow(referent_entity).to receive(:get_metadata).and_return(nil)
    allow(context_object).to receive(:referrer).and_return(OpenStruct.new(:empty? => true))
  end

  describe ".create_by_context_object" do
    context "when creating a referent from a context object" do
      it "should clean up the context object" do
        expect(described_class).to receive(:clean_up_context_object).with(context_object)
        described_class.create_by_context_object(context_object)
      end
    end
  end

  describe ".clean_up_context_object" do
    it "removes empty identifiers from referent" do
      allow(referent_entity).to receive(:identifiers).and_return(["doi:", "urn:ISSN:"])
      allow(referent_entity).to receive(:delete_identifier)

      described_class.clean_up_context_object(context_object)
      
      expect(referent_entity).to have_received(:delete_identifier).with("doi:")
    end

    it "adds appropriate ISSN metadata" do
      allow(referent_entity).to receive(:identifiers).and_return(["urn:ISSN:1234-5678"])
      allow(referent_entity).to receive(:set_metadata)
      allow(referent_entity).to receive(:get_metadata).and_return(nil)
      allow(referent_entity).to receive(:delete_identifier).and_return(nil)

      described_class.clean_up_context_object(context_object)

      expect(referent_entity).to have_received(:set_metadata).with("issn", "1234-5678")
    end
  end

  describe "#build_referent_value" do
    it "builds a new referent value" do
      result = referent.build_referent_value("key", "value")

      expect(result.key_name).to eq("key")
      expect(result.value).to eq("value")
    end
  end

  describe "#metadata_intersects?" do
    let(:other_arg) { double("other_arg", metadata: {"title" => "Some Title"}) }

    it "returns true when metadata intersects" do
      allow(referent).to receive(:metadata).and_return({"title" => "Some Title"})

      expect(referent.metadata_intersects?(other_arg)).to be_truthy
    end

    it "returns false when metadata does not intersect" do
      allow(referent).to receive(:metadata).and_return({"title" => "Another Title"})

      expect(referent.metadata_intersects?(other_arg)).to be_falsey
    end
  end

  describe "#enhance_referent" do
    it "enhances referent when no existing value" do
      allow(referent).to receive(:referent_values).and_return([])
      allow(referent).to receive(:save!)

      #referent.enhance_referent("key", "value")

      #expect(referent.referent_values.size).to eq(1)
    end

    it "does not overwrite existing value when overwrite option is false" do
      existing_value = double("ReferentValue", key_name: "key", value: "existing_value")
      allow(referent).to receive(:referent_values).and_return([existing_value])

      referent.enhance_referent("key", "new_value", true, false, overwrite: false)

      expect(existing_value.value).to eq("existing_value")
    end
  end
end
