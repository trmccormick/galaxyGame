require 'rails_helper'

describe Logistics::ShortageDetector do
  let(:settlement) { FactoryBot.create(:base_settlement) }
  let(:inventory) { double('Inventory') }

  before do
    allow(settlement).to receive(:inventory).and_return(inventory)
    allow(inventory).to receive(:resources).and_return(['water', 'food'])
    allow(inventory).to receive(:quantity_of).with('water').and_return(5)
    allow(inventory).to receive(:quantity_of).with('food').and_return(100)
    allow(settlement).to receive(:operational_data).and_return({ inventory_targets: { 'water' => 100, 'food' => 100 } })
  end

  it 'detects shortage when inventory < threshold' do
    shortages = described_class.detect_shortages(settlement, 20)
    expect(shortages).to be_an(Array)
    expect(shortages.size).to eq(1)
    expect(shortages.first[:resource]).to eq('water')
    expect(shortages.first[:critical]).to be true
  end

  it 'returns empty array when inventory is healthy' do
    allow(inventory).to receive(:quantity_of).with('water').and_return(90)
    shortages = described_class.detect_shortages(settlement, 20)
    expect(shortages).to be_empty
  end

  it 'marks as critical when < 10% of target' do
    allow(inventory).to receive(:quantity_of).with('water').and_return(5)
    shortages = described_class.detect_shortages(settlement, 20)
    expect(shortages.first[:critical]).to be true
  end

  it 'calculates target from operational_data' do
    target = described_class.calculate_target_inventory(settlement, 'water')
    expect(target).to eq(100)
  end

  it 'returns nil if no data available' do
    allow(settlement).to receive(:operational_data).and_return(nil)
    allow(settlement).to receive(:consumption_rates).and_return(nil)
    allow(settlement).to receive(:population).and_return(nil)
    target = described_class.calculate_target_inventory(settlement, 'unobtainium')
    expect(target).to be_nil
  end
end
