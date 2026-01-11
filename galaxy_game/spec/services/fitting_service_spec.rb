require 'rails_helper'

RSpec.describe FittingService, type: :service do
  let(:player) { create(:player) }
  let(:settlement) { create(:base_settlement, owner: player) }
  let(:inventory) { settlement.inventory }

  let(:craft) { create(:base_craft, owner: settlement) }

  let(:fit_data) do
    {
      'units' => [
        { 'id' => 'satellite_battery', 'count' => 1 }
      ],
      'modules' => [
        { 'id' => 'efficiency_module', 'count' => 1 }
      ],
      'rigs' => [
        { 'id' => 'gpu_coprocessor_rig', 'count' => 1 }
      ]
    }
  end

  before do
    inventory.items.create!(name: 'satellite_battery', amount: 1, owner: settlement.owner)
    inventory.items.create!(name: 'efficiency_module', amount: 1, owner: settlement.owner)
    inventory.items.create!(name: 'gpu_coprocessor_rig', amount: 1, owner: settlement.owner)
  end

  it "fits all components from inventory" do
    result = described_class.fit!(target: craft, fit_data: fit_data, inventory: inventory)
    puts result.errors unless result.success?
    expect(result.success?).to be true
    expect(result.fitted.size).to eq 3
    expect(result.errors).to be_empty
    expect(result.missing).to be_empty
  end

  it "returns errors if inventory is missing items" do
    inventory.items.where(name: 'satellite_battery').destroy_all
    result = described_class.fit!(target: craft, fit_data: fit_data, inventory: inventory)
    expect(result.success?).to be false
    expect(result.errors.any? { |e| e.include?('satellite_battery') }).to be true
    expect(result.missing).to include('satellite_battery')
  end

  it "fits components without inventory if inventory is nil" do
    result = described_class.fit!(target: craft, fit_data: fit_data, inventory: nil)
    expect(result.success?).to be true
    expect(result.fitted.size).to eq 3
  end

  it "does not persist changes if dry_run is true" do
    result = described_class.fit!(target: craft, fit_data: fit_data, inventory: inventory, dry_run: true)
    expect(result.fitted.all? { |c| !c.persisted? }).to be true
  end
end