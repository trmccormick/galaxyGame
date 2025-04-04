require 'rails_helper'

RSpec.describe Craft::BaseCraft, type: :model do
  let!(:celestial_body) { create(:celestial_body, :luna) }
  let!(:location) { 
    create(:celestial_location, 
           name: "Shackleton Crater Base", 
           coordinates: "89.90°S 0.00°E",  # Correctly formatted coordinates
           celestial_body: celestial_body) 
  }

  let!(:craft) { create(:base_craft) }
  let(:inventory) { craft.inventory }

  describe 'initialization' do
    it 'initializes with the correct name' do
      expect(craft.name).to   start_with "Starship"
    end

    it 'initializes with the correct craft_name' do
      expect(craft.craft_name).to eq('starship')
    end

    it 'initializes with the correct craft_type' do
      expect(craft.craft_type).to eq('transport')
    end

    it 'initializes with the correct location' do
      expect(craft.current_location).to eq('Shackleton Crater Base')
    end    

    it 'creates all recommended units' do
      craft.base_units.reload # Ensure we have latest data
      expect(craft.base_units.where(unit_type: 'raptor_engine').count).to eq(6)
      expect(craft.base_units.where(unit_type: 'lox_tank').count).to eq(1)
      expect(craft.base_units.where(unit_type: 'methane_tank').count).to eq(1)
      expect(craft.base_units.where(unit_type: 'starship_habitat_unit').count).to eq(1)
      expect(craft.base_units.where(unit_type: 'storage_unit').count).to eq(1)
    end

    it 'sets correct tank capacities' do
      lox_tank = craft.base_units.find_by(unit_type: 'lox_tank')
      methane_tank = craft.base_units.find_by(unit_type: 'methane_tank')
      
      expect(lox_tank&.operational_data&.dig('storage', 'capacity')).to eq(150000)
      expect(methane_tank&.operational_data&.dig('storage', 'capacity')).to eq(100000)
    end

    it 'sets correct habitat capacity' do
      habitat = craft.base_units.find_by(unit_type: 'starship_habitat_unit')

      expect(habitat&.operational_data&.dig('capacity', 'passenger_capacity')).to eq(20)
    end
  end

  describe 'units creation' do
    let(:habitation_unit) { craft.base_units.find_by(unit_type: 'starship_habitat_unit') }

    it 'creates required starship units' do
      expect(habitation_unit).to be_present
      expect(habitation_unit.operational_data.dig('capacity', 'passenger_capacity')).to eq(20)
    end
  end

  describe 'population capacity' do
    it 'returns the correct population capacity' do
      expect(craft.population_capacity).to eq(20)
    end
  end

  describe 'power usage' do
    it 'returns the correct power usage' do
      expect(craft.power_usage).to eq(200)
    end
  end

  describe 'input resources' do
    it 'returns the correct input resources' do
      expect(craft.operational_data['consumables']).to include(
        'methane' => 100000,
        'oxygen' => 200000,
        'energy' => 200
      )
    end
  end

  describe 'structural mass' do
    it 'returns total mass from blueprint' do
      expect(craft.total_mass).to eq(163000) # Sum of all material amounts
    end
  end

  describe 'deployment' do
    it 'deploys to a valid location' do
      allow(craft).to receive(:valid_deployment_location?).and_return(true)
      expect { craft.deploy(location.name) }.not_to raise_error
      expect(craft.current_location).to eq(location.name)
      expect(craft.deployed).to be_truthy
    end

    it 'raises an error when deploying to an invalid location' do
      expect { craft.deploy('invalid_location') }.to raise_error('Invalid deployment location')
    end

    it 'can deploy to valid locations' do
      allow(craft).to receive(:valid_deployment_location?).with(location.name).and_return(true)
    end

    context 'unit loading and initialization' do
      let(:unit_service) { Lookup::UnitLookupService.new }

      it 'properly loads tank unit data' do
        lox_tank = craft.base_units.find_by(unit_type: 'lox_tank')
        methane_tank = craft.base_units.find_by(unit_type: 'methane_tank')

        expect(lox_tank).to be_present
        expect(methane_tank).to be_present

        expect(lox_tank.operational_data).to include(
          'name' => 'LOX Storage Tank',
          'storage' => include('capacity' => 150000)
        )

        expect(methane_tank.operational_data).to include(
          'name' => 'Methane Storage Tank',
          'storage' => include('capacity' => 100000)
        )
      end

      it 'maintains unit data consistency after reloading' do
        lox_tank = craft.base_units.find_by(unit_type: 'lox_tank')
        original_data = lox_tank.operational_data.deep_dup
        
        lox_tank.reload
        expect(lox_tank.operational_data).to eq(original_data)
      end

      it 'properly associates units with craft' do
        craft.base_units.each do |unit|
          expect(unit.attachable).to eq(craft)
          expect(unit.owner).to eq(craft.owner)
        end
      end

      it 'validates unit requirements' do
        required_units = craft.operational_data['recommended_units']
        expect(required_units).to be_present
        
        required_units.each do |unit_info|
          count = craft.base_units.where(unit_type: unit_info['id']).count
          expect(count).to eq(unit_info['count']), 
            "Expected #{unit_info['count']} units of type #{unit_info['id']}, but found #{count}"
        end
      end

      it 'collects materials from storage units' do
        # Create and initialize storage unit
        storage_unit = craft.base_units.find_by(unit_type: 'storage_unit')
        expect(storage_unit).to be_present
        
        # Initialize storage properly
        storage_unit.operational_data['storage'] ||= {
          'type' => 'general',
          'capacity' => 1000,
          'current_level' => 0
        }
        storage_unit.operational_data['resources'] ||= { 'stored' => {} }
        storage_unit.save!
        
        # Store items
        result = storage_unit.store_item('steel_bar', 10)
        expect(result).to be true
        
        result = storage_unit.store_item('titanium_plate', 10)
        expect(result).to be true
        
        # Verify storage
        storage_unit.reload
        expect(storage_unit.operational_data['resources']['stored']).to include(
          'steel_bar' => 10,
          'titanium_plate' => 10
        )
        
        # Ensure craft has inventory
        craft.ensure_inventory
        
        # Collect materials
        result = craft.collect_materials
        expect(result).to be true
        
        # Verify results
        craft.inventory.reload
        storage_unit.reload
        
        expect(craft.inventory.items.count).to eq(2)
        expect(craft.inventory.items.pluck(:name, :amount)).to contain_exactly(
          ['steel_bar', 10],
          ['titanium_plate', 10]
        )
      end
    end

    describe 'craft initialization' do
      it 'initializes with correct operational data structure' do
        expect(craft.operational_data).to include(
          'name',
          'unit_type',
          'recommended_units',
          'consumables'
        )
      end

      it 'sets up proper inventory associations' do
        expect(craft.inventory).to be_present
        expect(craft.inventory.inventoryable).to eq(craft)
      end

      it 'maintains data consistency after reloading' do
        original_data = craft.operational_data.deep_dup
        craft.reload
        expect(craft.operational_data).to eq(original_data)
      end
    end
  end

  describe '#valid_deployment_location?' do
    before do
      allow(craft).to receive(:craft_info).and_return({
        'deployment' => {
          'deployment_locations' => ['Lunar Surface', 'Low Lunar Orbit']
        }
      })
    end

    it 'returns true for valid deployment locations' do
      expect(craft.valid_deployment_location?('Lunar Surface')).to be true
      expect(craft.valid_deployment_location?('Low Lunar Orbit')).to be true
    end

    it 'returns true for current location' do
      craft.current_location = 'Some Location'
      expect(craft.valid_deployment_location?('Some Location')).to be true
    end

    it 'returns false for invalid locations' do
      expect(craft.valid_deployment_location?('Invalid Location')).to be false
      expect(craft.valid_deployment_location?(nil)).to be false
    end

    it 'returns true for valid deployment locations' do
      expect(craft.valid_deployment_location?('starship')).to be true
    end
  end

  describe 'operational capabilities' do
    it 'calculates total population capacity' do
      expect(craft.total_capacity).to eq(20)  # Match actual data
    end

    it 'returns correct fuel capacities' do
      expect(craft.fuel_capacity('lox')).to eq(150000)
      expect(craft.fuel_capacity('methane')). to eq(100000)
    end
  end
end