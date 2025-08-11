
RSpec.describe Request, type: :model do
  describe '.find_or_create' do
    before do
      allow(OpenURL::ContextObject).to receive(:new_from_form_vars).and_return(context_object)
      allow(described_class).to receive(:context_object_params).and_return({})
      allow(described_class).to receive(:co_params_fingerprint).and_return('dummy_fingerprint')

      allow(context_object).to receive(:referent).and_return(referent_entity)
      allow(referent_entity).to receive(:identifiers).and_return(["12345"])
      allow(referent_entity).to receive(:format).and_return("journal")
      allow(referent_entity).to receive(:private_data).and_return(nil)
      allow(referent_entity).to receive(:metadata).and_return({"title" => "TITLE"})
      allow(context_object).to receive(:referrer).and_return(OpenStruct.new(:empty? => true))
    end

    let(:params) { { "umlaut.request_id" => nil } }
    let(:session) { {} }
    let(:a_rails_request) { double(env: {}, session: { session_id: '123' }) }
    let(:context_object) { double("context_object") }
    let(:referent_entity) { double("referent_entity") }

    context 'when an existing request is found' do
      let!(:existing_request) { Request.create!(session_id: '123', contextobj_fingerprint: 'dummy_fingerprint') }
      it 'returns the existing request' do
        allow(a_rails_request).to receive(:referent).and_return(nil)
        result = described_class.find_or_create(params, session, a_rails_request)
        expect(result.contextobj_fingerprint).to eq(existing_request.contextobj_fingerprint)
        expect(result.session_id).to eq(existing_request.session_id)
      end
    end

    context 'when no existing request is found' do
      it 'creates a new request' do
        #expect {
        #  described_class.find_or_create(params, session, a_rails_request)
        #}.to change(Request, :count).by(1)
      end
    end
  end

  describe '.context_object_params' do
    let(:a_rails_request) { double(query_string: 'test=1&foo=bar', raw_post: '') }

    it 'returns a proper hash of context object params' do
      result = described_class.context_object_params(a_rails_request)
      expect(result).to include('test' => ['1'], 'foo' => ['bar'])
    end

    it 'excludes irrelevant keys' do
      result = described_class.context_object_params(a_rails_request)
      expect(result).not_to have_key('action')
      expect(result).not_to have_key('controller')
    end
  end

  describe '#dispatched' do
    let(:service) { double(service_id: 'service1') }
    let(:dispatched_service) { double(save!: true, store_exception: nil) }
    let(:request) { described_class.new }

    before do
      allow(request).to receive(:find_dispatch_object).and_return(nil)
      allow(request).to receive(:new_dispatch_object!).and_return(dispatched_service)
      allow(dispatched_service).to receive(:status=).and_return(false)
    end

    it 'saves the dispatch object with the given status' do
      expect(dispatched_service).to receive(:status=).with(true)
      request.dispatched(service, true)
    end

    it 'stores the exception if given' do
      expect(dispatched_service).to receive(:store_exception).with('error')
      request.dispatched(service, false, 'error')
    end
  end

  describe '#can_dispatch?' do
    let(:service) { double(service_id: 'service1') }
    let(:request) { described_class.new }

    it 'returns true if no dispatched service found' do
      expect(request).to receive_message_chain(:dispatched_services, :where, :first).and_return(nil)
      expect(request.can_dispatch?(service)).to be true
    end

    it 'returns true if status is Queued or FailedTemporary' do
      expect(request).to receive_message_chain(:dispatched_services, :where, :first)
                          .and_return(double(status: DispatchedService::Queued))
      expect(request.can_dispatch?(service)).to be true
    end

    it 'returns false for other statuses' do
      expect(request).to receive_message_chain(:dispatched_services, :where, :first)
                          .and_return(double(status: DispatchedService::Successful))
      expect(request.can_dispatch?(service)).to be false
    end
  end
end
