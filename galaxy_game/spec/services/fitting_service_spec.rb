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
    allow_any_instance_of(Craft::BaseCraft).to receive(:get_ports_data).and_return({
      'internal_module_ports' => 3,
      'external_module_ports' => 0,
      'internal_unit_ports' => 5,
      'external_unit_ports' => 2,
      'internal_rig_ports' => 2,
      'external_rig_ports' => 2
    })
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

  it "rejects modules not in inventory" do
    inventory.items.where(name: 'efficiency_module').destroy_all
    result = described_class.fit!(target: craft, fit_data: fit_data, inventory: inventory)
    expect(result.success?).to be false
    expect(result.errors.any? { |e| e.include?('efficiency_module') }).to be true
    expect(result.missing).to include('efficiency_module')
  end

  it "rejects rigs not in inventory" do
    inventory.items.where(name: 'gpu_coprocessor_rig').destroy_all
    result = described_class.fit!(target: craft, fit_data: fit_data, inventory: inventory)
    expect(result.success?).to be false
    expect(result.errors.any? { |e| e.include?('gpu_coprocessor_rig') }).to be true
    expect(result.missing).to include('gpu_coprocessor_rig')
  end

  it "fits all components from inventory (modules and rigs)" do
    result = described_class.fit!(target: craft, fit_data: fit_data, inventory: inventory)
    expect(result.success?).to be true
    expect(result.fitted.size).to eq(3)
    expect(result.errors).to be_empty
    expect(result.missing).to be_empty
  end
end