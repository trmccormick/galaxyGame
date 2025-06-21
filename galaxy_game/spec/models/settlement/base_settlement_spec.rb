require 'rails_helper'

RSpec.describe Settlement::BaseSettlement, type: :model do
  let(:player) { create(:player) }
  
  let!(:celestial_body) { create(:large_moon, :luna) }
  let(:location) { 
    create(:celestial_location, 
           name: "Test Location", 
           coordinates: "0.00°N 0.00°E",
           celestial_body: celestial_body) 
  }
  
  let(:base_settlement) do
    create(:base_settlement, :independent,
           name: "Test Base",
           settlement_type: :base,
           current_population: 1,
           owner: player,
           location: location)
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(base_settlement).to be_valid
    end

    it 'is not valid without a name' do
      base_settlement.name = nil
      expect(base_settlement).not_to be_valid
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
      craft = create(:base_craft, owner: player)
      craft.celestial_location = location
      craft.save!
      craft
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
    let(:base_settlement) { create(:base_settlement, :independent, owner: player, location: location) }

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

  describe 'operational_data' do
    let(:base_settlement) { create(:base_settlement, :independent, owner: player, location: location) }
    
    it 'can store and retrieve operational data' do
      # Set operational data
      base_settlement.operational_data = {
        'power_management' => {
          'grid_status' => 'online',
          'total_capacity' => 5000,
          'current_usage' => 2500
        }
      }
      base_settlement.save!
      
      # Reload from database
      reloaded = Settlement::BaseSettlement.find(base_settlement.id)
      
      # Verify data was saved
      expect(reloaded.operational_data['power_management']['grid_status']).to eq('online')
      expect(reloaded.operational_data['power_management']['total_capacity']).to eq(5000)
      expect(reloaded.operational_data['power_management']['current_usage']).to eq(2500)
    end
    
    it 'provides default empty hash if operational_data is nil in memory' do
      # Create with empty hash
      settlement = Settlement::BaseSettlement.create!(
        name: 'Test Settlement',
        settlement_type: :base,
        current_population: 1,
        location: location,
        owner: player,
        operational_data: {}
      )
      
      # Force the attribute to nil in memory (not in database)
      settlement.instance_variable_set(:@operational_data, nil)
      
      # Should return empty hash, not nil
      expect(settlement.operational_data).to eq({})
    end
    
    it 'works with energy management methods' do
      # Set up power generation and usage data
      base_settlement.operational_data = {
        'resource_management' => {
          'generated' => {
            'energy_kwh' => {'rate' => 5000, 'current_output' => 4500}
          },
          'consumables' => {
            'energy_kwh' => {'rate' => 3000, 'current_usage' => 2800}
          }
        }
      }
      base_settlement.save!
      
      # Test power-related methods
      expect(base_settlement.power_generation).to eq(5000.0)
      expect(base_settlement.power_usage).to eq(3000.0)
    end
  end

  describe 'construction cost management' do
    let(:base_settlement) { create(:base_settlement, :independent, owner: player, location: location) }
    
    describe '#construction_cost_percentage' do
      it 'returns default percentage when not set' do
        expect(base_settlement.construction_cost_percentage).to eq(GameConstants::DEFAULT_CONSTRUCTION_PERCENTAGE)
      end
      
      it 'returns custom percentage when set in operational_data' do
        base_settlement.operational_data = {
          'manufacturing' => {
            'construction_cost_percentage' => 10.5
          }
        }
        base_settlement.save!
        
        expect(base_settlement.construction_cost_percentage).to eq(10.5)
      end
      
      it 'handles empty operational_data gracefully' do
        base_settlement.update!(operational_data: {})
        expect(base_settlement.construction_cost_percentage).to eq(GameConstants::DEFAULT_CONSTRUCTION_PERCENTAGE)
      end
      
      it 'handles missing manufacturing section gracefully' do
        base_settlement.operational_data = {
          'power_management' => {
            'grid_status' => 'online'
          }
        }
        base_settlement.save!
        
        expect(base_settlement.construction_cost_percentage).to eq(GameConstants::DEFAULT_CONSTRUCTION_PERCENTAGE)
      end
      
      it 'handles nil operational_data in memory gracefully' do
        # First save with empty hash (database compatible)
        base_settlement.update!(operational_data: {})
        
        # Then test the method's behavior with nil by stubbing the accessor
        allow(base_settlement).to receive(:operational_data).and_return(nil)
        
        # Now test the method that should handle nil gracefully
        expect(base_settlement.construction_cost_percentage).to eq(GameConstants::DEFAULT_CONSTRUCTION_PERCENTAGE)
      end
    end
    
    describe '#construction_cost_percentage=' do
      it 'sets the construction cost percentage in operational_data' do
        base_settlement.construction_cost_percentage = 15.0
        base_settlement.save!
        
        reloaded = Settlement::BaseSettlement.find(base_settlement.id)
        expect(reloaded.operational_data['manufacturing']['construction_cost_percentage']).to eq(15.0)
      end
      
      it 'initializes operational_data manufacturing section if empty' do
        base_settlement.update!(operational_data: {})
        base_settlement.construction_cost_percentage = 8.5
        base_settlement.save!
        
        expect(base_settlement.operational_data['manufacturing']['construction_cost_percentage']).to eq(8.5)
      end
      
      it 'preserves existing operational_data when setting percentage' do
        base_settlement.operational_data = {
          'power_management' => {
            'grid_status' => 'online',
            'total_capacity' => 5000
          }
        }
        base_settlement.save!
        
        base_settlement.construction_cost_percentage = 12.0
        base_settlement.save!
        
        expect(base_settlement.operational_data['manufacturing']['construction_cost_percentage']).to eq(12.0)
        expect(base_settlement.operational_data['power_management']['grid_status']).to eq('online')
        expect(base_settlement.operational_data['power_management']['total_capacity']).to eq(5000)
      end
    end
    
    describe '#calculate_construction_cost' do
      before do
        base_settlement.construction_cost_percentage = 5.0  # 5%
        base_settlement.save!
      end
      
      it 'calculates construction cost as percentage of purchase cost' do
        purchase_cost = 100_000
        expected_cost = 5_000  # 5% of 100,000
        
        expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
      end
      
      it 'rounds to 2 decimal places' do
        purchase_cost = 12_345
        expected_cost = 617.25  # 5% of 12,345
        
        expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
      end
      
      it 'handles zero purchase cost' do
        expect(base_settlement.calculate_construction_cost(0)).to eq(0.0)
      end
      
      it 'uses different percentages correctly' do
        base_settlement.construction_cost_percentage = 2.5
        purchase_cost = 200_000
        expected_cost = 5_000  # 2.5% of 200,000
        
        expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
      end
      
      it 'handles negative purchase costs' do
        purchase_cost = -50_000
        expected_cost = -2_500  # 5% of -50,000
        
        expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
      end
      
      it 'handles floating point purchase costs' do
        purchase_cost = 12_345.67
        expected_cost = 617.28  # 5% of 12,345.67 rounded to 2 decimal places
        
        expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
      end
      
      it 'handles string input by converting to float' do
        purchase_cost = "50000"
        expected_cost = 2_500.0  # 5% of 50,000
        
        expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
      end
      
      it 'handles nil input gracefully' do
        expect(base_settlement.calculate_construction_cost(nil)).to eq(0.0)
      end
    end
    
    describe 'manufacturing settings' do
      it 'supports manufacturing efficiency setting' do
        base_settlement.operational_data = {
          'manufacturing' => {
            'efficiency_bonus' => 1.25
          }
        }
        base_settlement.save!
        
        expect(base_settlement.manufacturing_efficiency).to eq(1.25)
      end
      
      it 'defaults manufacturing efficiency to 1.0' do
        expect(base_settlement.manufacturing_efficiency).to eq(1.0)
      end
      
      it 'supports equipment check setting' do
        base_settlement.operational_data = {
          'manufacturing' => {
            'check_equipment' => false
          }
        }
        base_settlement.save!
        
        expect(base_settlement.required_equipment_check_enabled?).to be false
      end
      
      it 'defaults equipment check to true' do
        expect(base_settlement.required_equipment_check_enabled?).to be true
      end
      
      it 'handles missing manufacturing section for efficiency' do
        base_settlement.operational_data = {
          'power_management' => {
            'grid_status' => 'online'
          }
        }
        base_settlement.save!
        
        expect(base_settlement.manufacturing_efficiency).to eq(1.0)
      end
      
      it 'handles missing manufacturing section for equipment check' do
        base_settlement.operational_data = {
          'power_management' => {
            'grid_status' => 'online'
          }
        }
        base_settlement.save!
        
        expect(base_settlement.required_equipment_check_enabled?).to be true
      end
    end
  end

  describe 'construction cost integration' do
    let(:base_settlement) { create(:base_settlement, :independent, owner: player, location: location) }
    
    it 'integrates construction cost calculations with settlement manufacturing data' do
      # Set up a settlement with specific manufacturing configuration
      base_settlement.operational_data = {
        'manufacturing' => {
          'construction_cost_percentage' => 7.5,
          'efficiency_bonus' => 1.15,
          'check_equipment' => true
        }
      }
      base_settlement.save!
      
      # Test that all methods work together
      expect(base_settlement.construction_cost_percentage).to eq(7.5)
      expect(base_settlement.manufacturing_efficiency).to eq(1.15)
      expect(base_settlement.required_equipment_check_enabled?).to be true
      
      # Test cost calculation with this configuration
      purchase_cost = 80_000
      expected_cost = 6_000.0  # 7.5% of 80,000
      
      expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
    end
    
    it 'preserves other operational_data when updating construction settings' do
      # Set up initial operational data with various settings
      base_settlement.operational_data = {
        'power_management' => {
          'grid_status' => 'online',
          'total_capacity' => 5000
        },
        'life_support' => {
          'atmosphere_pressure' => 101325
        }
      }
      base_settlement.save!
      
      # Update construction cost percentage
      base_settlement.construction_cost_percentage = 6.0
      base_settlement.save!
      
      # Verify construction setting was added without overwriting other data
      expect(base_settlement.operational_data['manufacturing']['construction_cost_percentage']).to eq(6.0)
      expect(base_settlement.operational_data['power_management']['grid_status']).to eq('online')
      expect(base_settlement.operational_data['life_support']['atmosphere_pressure']).to eq(101325)
    end
    
    it 'works correctly when operational_data starts empty' do
      # Start with minimal operational_data
      base_settlement.update!(operational_data: {})
      
      # Set multiple manufacturing settings
      base_settlement.construction_cost_percentage = 8.0
      base_settlement.operational_data['manufacturing']['efficiency_bonus'] = 1.3
      base_settlement.operational_data['manufacturing']['check_equipment'] = false
      base_settlement.save!
      
      # Verify all settings are preserved
      expect(base_settlement.construction_cost_percentage).to eq(8.0)
      expect(base_settlement.manufacturing_efficiency).to eq(1.3)
      expect(base_settlement.required_equipment_check_enabled?).to be false
    end
    
    it 'handles complex operational_data structures' do
      base_settlement.operational_data = {
        'power_management' => {
          'grid_status' => 'online',
          'generators' => [
            {'type' => 'solar', 'capacity' => 1000},
            {'type' => 'nuclear', 'capacity' => 5000}
          ]
        },
        'life_support' => {
          'atmosphere' => {
            'pressure' => 101325,
            'composition' => {
              'nitrogen' => 78,
              'oxygen' => 21,
              'other' => 1
            }
          }
        }
      }
      base_settlement.save!
      
      # Add manufacturing settings
      base_settlement.construction_cost_percentage = 4.5
      base_settlement.save!
      
      # Verify complex structure is preserved
      expect(base_settlement.operational_data['power_management']['generators'].length).to eq(2)
      expect(base_settlement.operational_data['life_support']['atmosphere']['composition']['oxygen']).to eq(21)
      expect(base_settlement.construction_cost_percentage).to eq(4.5)
    end
  end
end