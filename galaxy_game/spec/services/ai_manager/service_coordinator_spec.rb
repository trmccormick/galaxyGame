require 'rails_helper'

describe AIManager::ServiceCoordinator do
  let(:settlement) { FactoryBot.create(:base_settlement) }
  let(:shortage) { { resource: 'water', current: 5, target: 100, amount: 95, critical: true } }
  let(:import_request) { FactoryBot.create(:import_request) }

  before do
    allow(Logistics::ShortageDetector).to receive(:detect_shortages).and_return([shortage])
    allow(Logistics::ImportRequestGenerator).to receive(:generate_import_request).and_return(import_request)
  end

  it 'detects and requests imports for shortages' do
    coordinator = described_class.new(double('SharedContext', add_listener: nil))
    results = coordinator.detect_and_request_imports(settlement)
    expect(results).to be_an(Array)
    expect(results.first).to eq(import_request)
  end
end
