# spec/models/units/base_unit_spec.rb
require 'rails_helper'

RSpec.describe Units::BaseUnit, type: :model do
  let!(:celestial_body) { create(:celestial_body, name: "Luna") }
  let!(:shackleton_crater) { 
    create(:celestial_location, 
           name: "Shackleton Crater Base", 
           coordinates: "89.90°S 0.00°E",
           celestial_body: celestial_body) 
  }
  let!(:base_settlement) { 
    create(:base_settlement, 
           name: "Alpha Base", 
           current_population: 100, 
           location: shackleton_crater) 
  }
  let!(:player) { create(:player, active_location: base_settlement.name) }

  describe 'validations' do
    it { should validate_presence_of(:identifier) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:unit_type) }
  end

  describe 'associations' do
    it { should belong_to(:owner) }
    it { should belong_to(:attachable).optional }
    it { should have_many(:attached_units) }
    it { should have_one(:location) }
    it { should have_one(:inventory) }
  end

  describe 'create new unit' do
    it 'creates a valid unit with given attributes' do
      unit = described_class.create(
        name: "Inflatable Habitat Unit", 
        unit_type: "housing_unit", 
        owner: base_settlement,
        location: shackleton_crater,
        identifier: "IHU001",
        operational_data: {
          capacity: 6,
          consumables: { energy: 4, water: 15, oxygen: 10 },
          aliases: ["living module", "inflatable shelter"],
          deployment_conditions: [
            { location: "lunar_surface", shielding_required: "regolith_cover" },
            { location: "mars_surface", shielding_required: "regolith_cover" },
            { location: "lava_tube", shielding_required: "none" }
          ]
        }
      )
      expect(unit).to be_valid
      expect(unit.attributes.symbolize_keys).to include(
        name: "Inflatable Habitat Unit",
        unit_type: "housing_unit",
        owner_id: base_settlement.id, # Compare owner_id
        owner_type: "Settlement::BaseSettlement" # Compare owner_type
      )
    end
  end

  describe 'location and celestial body' do
    let(:unit) { create(:base_unit, name: "Test Unit", unit_type: "housing", owner: base_settlement, location: shackleton_crater, identifier: "TEST001") }

    it 'returns the correct location' do
      expect(unit.current_location).to eq(shackleton_crater)
    end

    it 'returns the correct celestial body' do
      expect(unit.celestial_body).to eq(celestial_body)
    end
  end

  describe 'storage operations' do
    let(:lox_tank) do
      create(:base_unit,
        name: "LOX Storage Tank",
        unit_type: "lox_tank",
        owner: base_settlement,
        attachable: base_settlement,
        identifier: "LOX#{SecureRandom.hex(4)}",
        operational_data: {
          'storage' => { 'capacity' => 150000, 'type' => 'liquid', 'current_level' => 0 },
          'resources' => { 'stored' => {} }
        }
      )
    end

    describe '#store_resource' do
      before { allow_any_instance_of(Lookup::MaterialLookupService).to receive(:find_material).and_call_original }

      it 'stores oxygen in liquid state' do
        expect(lox_tank.store_resource('oxygen', 500)).to be true
        expect(lox_tank.current_storage_of('oxygen')).to eq(500)
      end

      it 'prevents overfilling tank' do
        lox_tank.store_resource('oxygen', 140000)
        expect(lox_tank.store_resource('oxygen', 20000)).to be false
      end

      it 'validates storage compatibility' do
        expect(lox_tank.store_resource('hematite', 100)).to be false
      end
    end

    describe '#store_item' do
      let(:storage_unit) do
        create(:base_unit,
          name: "Storage Unit",
          unit_type: "storage_unit",
          owner: base_settlement,
          attachable: base_settlement,
          identifier: "STORE#{SecureRandom.hex(4)}",
          operational_data: {
            'storage' => { 'type' => 'general', 'capacity' => 1000, 'current_level' => 0 },
            'resources' => { 'stored' => {} }
          }
        )
      end

      it 'stores items in both inventory and operational data' do
        expect(storage_unit.store_item('steel', 10)).to be true
        storage_unit.reload
        expect(storage_unit.inventory.items.first).to have_attributes(name: 'steel', amount: 10)
        expect(storage_unit.operational_data['resources']['stored']).to include('steel' => 10)
        expect(storage_unit.operational_data['storage']['current_level']).to eq(10)
      end

      it 'respects storage capacity limits' do
        expect(storage_unit.store_item('steel', 1500)).to be false
        storage_unit.reload
        expect(storage_unit.inventory.items).to be_empty
        expect(storage_unit.operational_data['resources']['stored']).to be_empty
        expect(storage_unit.operational_data['storage']['current_level']).to eq(0)
      end

      it 'updates existing items' do
        storage_unit.store_item('steel', 10)
        expect(storage_unit.store_item('steel', 15)).to be true
        storage_unit.reload
        expect(storage_unit.inventory.items.first).to have_attributes(amount: 25)
        expect(storage_unit.operational_data['resources']['stored']['steel']).to eq(25)
        expect(storage_unit.operational_data['storage']['current_level']).to eq(25)
      end
    end
  end

  describe 'general storage operations' do
    let(:storage_tank) { create(:base_unit, name: "Storage Tank", unit_type: "storage_tank", owner: base_settlement, attachable: base_settlement, identifier: "TANK#{SecureRandom.hex(4)}", operational_data: { 'storage' => { 'capacity' => 1000, 'type' => 'general', 'current_level' => 0 }, 'resources' => { 'stored' => {} } }) }

    describe '#store_resource' do
      before { allow_any_instance_of(Lookup::MaterialLookupService).to receive(:find_material).and_call_original }

      it 'can store items up to capacity' do
        expect(storage_tank.store_resource('oxygen', 500)).to be true
        expect(storage_tank.current_storage_of('oxygen')).to eq(500)
      end

      it 'tracks available capacity' do
        storage_tank.store_resource('oxygen', 600)
        expect(storage_tank.available_capacity).to eq(400)
      end
    end
  end

  describe 'inventory integration' do
    let(:storage_unit) { create(:base_unit, name: "Storage Unit", unit_type: "storage", owner: base_settlement, identifier: "STORE#{SecureRandom.hex(4)}", operational_data: { 'storage' => { 'capacity' => 1000, 'type' => 'general', 'current_level' => 0 }, 'resources' => { 'stored' => {} } }) }

    describe '#store_resource' do
      before { allow_any_instance_of(Lookup::MaterialLookupService).to receive(:find_material).and_call_original }

      it 'creates inventory items when storing resources' do
        expect { storage_unit.store_resource('hematite', 100) }.to change { storage_unit.inventory.items.count }.by(1)
      end

      it 'updates inventory when removing resources' do
        storage_unit.store_resource('hematite', 100)
        expect { storage_unit.remove_resource('hematite', 50) }.to change { storage_unit.inventory.items.find_by(name: 'hematite').amount }.by(-50)
      end
    end
  end

  describe 'unit initialization' do
    let(:lox_tank) { create(:base_unit, name: "LOX Storage Tank", unit_type: "lox_tank", owner: base_settlement, attachable: base_settlement, identifier: "LOX#{SecureRandom.hex(4)}", operational_data: { 'storage' => { 'capacity' => 150000, 'type' => 'liquid', 'current_level' => 0 }, 'resources' => { 'stored' => {} } }) }

    it 'loads correct storage configuration' do
      expect(lox_tank.operational_data).to include('storage' => { 'type' => 'liquid', 'capacity' => 150000, 'current_level' => 0 })
    end
  end

  describe '#process_resources' do
    it 'processes material based on composition' do
      base_unit = create(:base_unit, unit_type: "lunar_oxygen_extractor", owner: base_settlement, location: shackleton_crater)

      unit_info = { 'unit_type' => 'lunar_oxygen_extractor', 'input_resources' => [ { 'id' => 'lunar_regolith', 'amount' => 10 } ], 'storage_type' => 'mixed', 'capacity' => 100, 'storage' => { 'gas_buffer' => { 'type' => 'gas', 'capacity' => 100 }, 'regolith_hopper' => { 'type' => 'general', 'capacity' => 100 } } }
      allow(Lookup::UnitLookupService).to receive(:new).and_return(instance_double(Lookup::UnitLookupService, find_unit: unit_info))

      base_unit.send(:load_unit_info)
      expect(base_unit.operational_data.dig('storage', 'gas_buffer', 'capacity')).to eq(100)
      expect(base_unit.operational_data.dig('storage', 'regolith_hopper', 'capacity')).to eq(100)

      base_unit.send(:ensure_inventory)
      base_unit.inventory.items.create!(name: 'lunar_regolith', amount: 10, owner: base_settlement)

      material_info = { 'smelting_output' => [ { 'material' => 'oxygen', 'percentage' => 40 }, { 'material' => 'silicon', 'percentage' => 30 } ], 'waste_material' => [ { 'material' => 'processed_regolith', 'percentage' => 30 } ] }
      allow_any_instance_of(Lookup::MaterialLookupService).to receive(:find_material).with('lunar_regolith').and_return(material_info)
      allow(base_unit).to receive(:consume).with('lunar_regolith', 10).and_return(true)

      expect(base_unit.process_resources('lunar_regolith')).to be true
      expect(base_unit.get_buffer_level('gas_buffer')).to be > 0
      expect(base_unit.get_buffer_level('regolith_hopper')).to be > 0
    end
  end

  describe '#store_on_surface' do
    # Use a real settlement for attachable, and then stub its surface_storage
    let(:settlement_with_storage) { create(:base_settlement) }
    let!(:surface_storage_real) { create(:surface_storage, inventory: settlement_with_storage.inventory) } # Create a real surface_storage

    # Create base_unit attached to the real settlement
    let(:base_unit) { create(:base_unit, attachable: settlement_with_storage) }

    before do
      # Stub the add_pile method on the real surface_storage instance
      allow(surface_storage_real).to receive(:add_pile).and_return(true)
    end

    it 'calls add_pile on surface storage' do
      # Call the method under test
      base_unit.send(:store_on_surface, 'processed_regolith', 100) # Use send as it's a private method

      # Assert that add_pile was received by the real surface_storage_double
      expect(surface_storage_real).to have_received(:add_pile).with(
        material_name: 'processed_regolith',
        amount: 100,
        source_unit: base_unit # base_unit is a real object, so it will match
      )
    end

    it 'returns false if attachable does not respond to :surface_storage' do
      # Use a real model (e.g., Organization) as attachable
      dummy_attachable = create(:organization)
      # Stub respond_to? for :surface_storage
      allow(dummy_attachable).to receive(:respond_to?).and_call_original
      allow(dummy_attachable).to receive(:respond_to?).with(:surface_storage).and_return(false)

      base_unit_without_surface_storage = Units::BaseUnit.new(
        name: "Test Unit",
        unit_type: "test_type",
        owner: create(:organization),
        identifier: "TEST-NO-SURFACE-STORAGE"
      )
      base_unit_without_surface_storage.attachable = dummy_attachable

      expect(base_unit_without_surface_storage.send(:store_on_surface, 'processed_regolith', 100)).to be false
    end

    it 'returns false if surface_storage returns nil' do
      # Create a base_unit attached to a settlement that has no surface_storage
      settlement_no_storage = create(:base_settlement)
      base_unit_no_surface_storage = create(:base_unit, attachable: settlement_no_storage)
      
      # Ensure its surface_storage method returns nil
      allow(settlement_no_storage).to receive(:surface_storage).and_return(nil)

      # Call the method under test
      expect(base_unit_no_surface_storage.send(:store_on_surface, 'processed_regolith', 100)).to be false
      # Ensure add_pile was NOT called
      expect(surface_storage_real).not_to have_received(:add_pile)
    end
  end
end
