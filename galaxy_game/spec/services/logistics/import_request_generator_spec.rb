require 'rails_helper'

describe Logistics::ImportRequestGenerator do
  let(:settlement) { FactoryBot.create(:base_settlement) }
  let(:shortage_data) { { resource: 'water', current: 5, target: 100, amount: 95, critical: true } }

  before do
    allow(Settlements::CostAnalyzer).to receive(:compare_costs).and_return({ local_cost: 10, import_cost: 20, recommendation: :import })
    allow(Logistics::ManifestGenerator).to receive(:create_manifest).and_return(FactoryBot.create(:manifest))
  end

  it 'creates an import request for a shortage' do
    req = described_class.generate_import_request(settlement, shortage_data)
    expect(req).to be_persisted
    expect(req.resource).to eq('water')
    expect(req.quantity_needed).to eq(95)
    expect(req.status).to eq('created')
  end

  it 'raises error if manifest fails' do
    allow(Logistics::ManifestGenerator).to receive(:create_manifest).and_raise(StandardError, 'fail')
    expect {
      described_class.generate_import_request(settlement, shortage_data)
    }.to raise_error(Logistics::ImportRequestGenerator::ImportRequestError)
  end
end
