require 'rails_helper'

describe Logistics::ShortageDetector do
  let(:settlement) { double('Settlement') }
  before do
    # Avoid load-order dependency by stubbing the ISRU manager used by the service
    isru_mgr = double('ISRUCapabilityManager')
    stub_const('Logistics::ISRUCapabilityManager', isru_mgr)
    allow(isru_mgr).to receive(:has_basic_isru?).and_return(true)
    # ShortageDetector inspects settlement.items (each item responds to :material_type and :amount)
    item_water = double('Item', material_type: 'water', amount: 5)
    item_food  = double('Item', material_type: 'food', amount: 100)
    allow(settlement).to receive(:items).and_return([item_water, item_food])
    # ShortageDetector reads :survival_targets from operational_data
    allow(settlement).to receive(:operational_data).and_return({ survival_targets: { 'water' => 100, 'food' => 100 } })
  end

  it 'detects shortage when inventory < target' do
    report = described_class.detect_shortages(settlement)
    expect(report).to be_a(Hash)
    expect(report[:survival_shortages].size).to eq(1)
    expect(report[:survival_shortages].first[:material]).to eq('water')
    expect(report[:survival_shortages].first[:priority]).to eq('critical')
  end

  it 'returns no survival shortages when inventory is healthy' do
    # simulate higher quantity on the water item
    allow(settlement.items.first).to receive(:amount).and_return(120)
    report = described_class.detect_shortages(settlement)
    expect(report[:survival_shortages]).to be_empty
  end

  it 'marks as critical when < 10% of target' do
    allow(settlement.items.first).to receive(:amount).and_return(5)
    report = described_class.detect_shortages(settlement)
    expect(report[:survival_shortages].first[:priority]).to eq('critical')
  end
end
