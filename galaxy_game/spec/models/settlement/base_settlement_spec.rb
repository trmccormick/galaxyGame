require 'rails_helper'

RSpec.describe Settlement::BaseSettlement, type: :model do
  let(:player) { create(:player) }
  let(:celestial_body) { create(:celestial_body, :luna) }
  let(:shackleton_crater) { create(:celestial_location, celestial_body: celestial_body) }
  let(:base_settlement) do
    create(:base_settlement,
           name: "Test Base",
           settlement_type: :base,
           current_population: 1,
           owner: player,
           location: shackleton_crater)
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(base_settlement).to be_valid
    end

    it 'is not valid without a name' do
      base_settlement.name = nil
      expect(base_settlement).not_to be_valid  # Fix: not_to instead of not.to
    end

    it 'is not valid with a negative current population' do
      base_settlement.current_population = -1
      expect(base_settlement).not_to be_valid
    end

    it 'is not valid with a non-integer current population' do
      base_settlement.current_population = 1.5
      expect(base_settlement).not_to be_valid
    end
  end

  describe 'associations' do
    let(:docked_craft) do
      create(:base_craft,
             name: "Test Craft",
             craft_type: "transport", # Changed from "spaceships" to "transport"
             owner: player,
             current_location: base_settlement)
    end

    let(:storage_unit) do
      create(:base_unit, :storage,
             name: "Test Storage",
             unit_type: "storage",
             owner: base_settlement,
             attachable: base_settlement,
             operational_data: {
               'storage' => {
                 'capacity' => 500,
                 'current_contents' => 'N2'
               }
             })
    end

    before do
      docked_craft.update!(docked_at_id: base_settlement.id)
      storage_unit
      base_settlement.reload
    end

    it 'can belong to a player' do
      base_settlement.owner = player
      expect(base_settlement.owner).to eq(player)
    end

    it 'has many docked crafts' do
      expect(base_settlement.docked_crafts).to include(docked_craft)
    end

    it 'has many base units' do
      expect(base_settlement.base_units).to include(storage_unit)
    end
  end

  describe 'storage capacity' do
    let(:base_settlement) { create(:base_settlement) } # Create without default storage units

    before(:each) do
      base_settlement.base_units.destroy_all # Clear any existing units
      
      # Add our test units with exact capacities
      @storage_unit = create(:base_unit, :storage,
        owner: base_settlement,
        attachable: base_settlement,
        operational_data: {
          'storage' => {
            'liquid' => 250000,
            'gas' => 200000
          }
        }
      )
      
      @housing_unit = create(:base_unit, :housing,
        owner: base_settlement,
        attachable: base_settlement,
        operational_data: {
          'capacity' => 6,
          'storage' => {
            'multi' => 50000
          }
        }
      )
      
      base_settlement.reload
    end

    it 'calculates storage capacity by type' do
      puts "Debug: Base units count: #{base_settlement.base_units.count}"
      puts "Debug: Storage unit data: #{@storage_unit.operational_data.inspect}"
      puts "Debug: Housing unit data: #{@housing_unit.operational_data.inspect}"
      
      capacities = base_settlement.storage_capacity_by_type
      expect(capacities[:liquid]).to eq(250000)
      expect(capacities[:gas]).to eq(200000)
      expect(capacities[:multi]).to eq(50000)
    end

    it 'maintains backward compatibility with total storage capacity' do
      # Only count liquid and gas for backward compatibility
      expect(base_settlement.storage_capacity).to eq(450000)
    end

    it 'calculates total storage capacity' do
      # Sum of all storage types
      expect(base_settlement.total_storage_capacity).to eq(500000)
    end
  end

  describe 'celestial body delegation' do
    it 'delegates celestial_body to location' do
      expect(base_settlement.celestial_body).to eq(celestial_body)
    end
  end

  describe '#process_materials' do
    let(:storage_unit) do
      double('Unit',
        process_materials: nil,
        operational_data: {'capacity' => 1000},
        unit_type: 'storage'
      )
    end

    before do
      allow(base_settlement).to receive(:base_units).and_return([storage_unit])
    end

    it 'processes materials using base units' do
      expect { base_settlement.process_materials }.not_to raise_error
    end
  end
end