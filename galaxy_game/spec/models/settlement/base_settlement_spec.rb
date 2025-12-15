# spec/models/settlement/base_settlement_spec.rb

require 'rails_helper'

RSpec.describe Settlement::BaseSettlement, type: :model do
  # --- COMMON SETUP ---
  let!(:currency) { create(:financial_currency) }
  let(:player) { create(:player) }
  let!(:celestial_body) { create(:large_moon, :luna) }
  let(:location) do
    create(:celestial_location,
           name: "Test Location",
           coordinates: "0.00°N 0.00°E",
           celestial_body: celestial_body)
  end

  # Base Settlement with Account and Inventory created after_create
  let(:base_settlement) do
    create(:base_settlement, :independent,
           name: "Test Base",
           settlement_type: :base,
           current_population: 1,
           owner: player,
           location: location)
  end

  # Setup a Marketplace for association tests
  let!(:marketplace) { create(:marketplace, settlement: base_settlement) }

  # --- VALIDATIONS ---
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

  # --- ASSOCIATIONS ---
  describe 'associations' do
    let(:docked_craft) do
      craft = create(:base_craft, owner: player)
      craft.celestial_location = location
      craft.save!
      craft.update!(docked_at_id: base_settlement.id)
      craft.reload
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
      docked_craft
      storage_unit
      base_settlement.reload
    end

    it 'can belong to a player' do
      expect(base_settlement.owner).to eq(player)
    end

    it 'has many docked crafts' do
      expect(base_settlement.docked_crafts).to include(docked_craft)
    end

    it 'has many base units' do
      expect(base_settlement.base_units).to include(storage_unit)
    end

    it 'has a marketplace association using the correct foreign key' do
      expect(base_settlement.marketplace).to eq(marketplace)
    end

    it 'has a financial account' do
      expect(base_settlement.account).to be_present
    end

    it 'destroys the marketplace when destroyed' do
      settlement_to_destroy = create(:base_settlement, :independent, location: location)
      create(:marketplace, settlement: settlement_to_destroy)

      expect { settlement_to_destroy.destroy }.to change { Market::Marketplace.count }.by(-1)
    end
  end

  # --- STORAGE CAPACITY ---
  describe 'storage capacity' do
    let(:base_settlement) { create(:base_settlement, :independent, owner: player, location: location) }

    before(:each) do
      base_settlement.base_units.destroy_all

      @storage_unit = create(:base_unit, :storage,
        owner: base_settlement,
        attachable: base_settlement,
        operational_data: { 'storage' => { 'liquid' => 250000, 'gas' => 200000 } }
      )

      @housing_unit = create(:base_unit, :housing,
        owner: base_settlement,
        attachable: base_settlement,
        operational_data: { 'capacity' => 6, 'storage' => { 'multi' => 50000 } }
      )

      base_settlement.reload
    end

    it 'calculates storage capacity by type' do
      capacities = base_settlement.storage_capacity_by_type
      expect(capacities[:liquid]).to eq(250000)
      expect(capacities[:gas]).to eq(200000)
      expect(capacities[:multi]).to eq(50000)
    end

    it 'maintains backward compatibility with total storage capacity (liquid and gas only)' do
      expect(base_settlement.storage_capacity).to eq(450000)
    end

    it 'calculates total storage capacity (sum of all storage types)' do
      expect(base_settlement.total_storage_capacity).to eq(500000)
    end
  end

  # --- MARKET INTEGRATION ---
  describe 'Market Integration' do
    let(:resource) { 'iron_ore' }
    let(:mock_bid_price) { 50.0 }
    let(:available_cash) { 10000.0 }
    let(:available_storage) { 500 }

    before do
      # Create a stub class for NpcPriceCalculator
      stub_const('Market::NpcPriceCalculator', Class.new do
        def self.calculate_bid(settlement, resource)
          50.0
        end
      end)
      
      # Now we can allow it to receive and return custom values
      allow(Market::NpcPriceCalculator).to receive(:calculate_bid).with(base_settlement, resource).and_return(mock_bid_price)
      
      # Ensure the account and inventory exist and have test values
      base_settlement.account.update!(balance: available_cash)
      allow(base_settlement.inventory).to receive(:available_capacity_for?).with(resource).and_return(available_storage)
    end

    describe '#npc_market_bid' do
      it 'calls the NpcPriceCalculator with the correct arguments' do
        base_settlement.npc_market_bid(resource)
        expect(Market::NpcPriceCalculator).to have_received(:calculate_bid).with(base_settlement, resource)
      end

      it 'returns the calculated price' do
        expect(base_settlement.npc_market_bid(resource)).to eq(mock_bid_price)
      end
    end

    describe '#npc_buy_capacity' do
      context 'when storage is the limiting factor (50 units)' do
        let(:available_storage) { 50 }
        let(:available_cash) { 10000.0 }

        it 'limits capacity by available storage (50)' do
          expect(base_settlement.npc_buy_capacity(resource)).to eq(50)
        end
      end

      context 'when finances are the limiting factor (20 units)' do
        let(:available_storage) { 500 }
        let(:available_cash) { 1000.0 }

        it 'limits capacity by financial ability (20)' do
          expect(base_settlement.npc_buy_capacity(resource)).to eq(20)
        end
      end

      context 'when bid price is zero' do
        let(:mock_bid_price) { 0.0 }

        it 'returns 0 capacity' do
          expect(base_settlement.npc_buy_capacity(resource)).to eq(0)
        end
      end

      context 'when account or inventory is missing' do
        it 'returns 0 capacity if account is missing' do
          allow(base_settlement).to receive(:account).and_return(nil)
          expect(base_settlement.npc_buy_capacity(resource)).to eq(0)
        end

        it 'returns 0 capacity if inventory is missing' do
          allow(base_settlement).to receive(:inventory).and_return(nil)
          expect(base_settlement.npc_buy_capacity(resource)).to eq(0)
        end
      end
    end
  end

  # --- AFTER CREATE HOOKS ---
  describe 'after_create hooks' do
    it 'creates a financial account and inventory' do
      # Clean up any existing records to avoid conflicts
      Financial::Account.where(accountable_type: 'Settlement::BaseSettlement').delete_all
      Inventory.where(inventoryable_type: 'Settlement::BaseSettlement').delete_all
      
      settlement = Settlement::BaseSettlement.new(name: 'New Colony', settlement_type: :base, location: location)
      expect { settlement.save }.to change { Financial::Account.count }.by(1)
                                .and change { Inventory.count }.by(1)
    end
  end

  # --- DELEGATION & OTHER LOGIC ---
  describe 'celestial body delegation' do
    it 'delegates celestial_body to location' do
      expect(base_settlement.celestial_body).to eq(celestial_body)
    end
  end

  describe '#process_materials' do
    let(:storage_unit) do
      double('Unit',
        process_materials: nil,
        operational_data: { 'capacity' => 1000 },
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

  # --- OPERATIONAL DATA & CONSTRUCTION COST ---
  describe 'operational_data' do
    let(:base_settlement) { create(:base_settlement, :independent, owner: player, location: location) }

    it 'can store and retrieve operational data' do
      base_settlement.operational_data = {
        'power_management' => {
          'grid_status' => 'online',
          'total_capacity' => 5000,
          'current_usage' => 2500
        }
      }
      base_settlement.save!

      reloaded = Settlement::BaseSettlement.find(base_settlement.id)

      expect(reloaded.operational_data['power_management']['grid_status']).to eq('online')
      expect(reloaded.operational_data['power_management']['total_capacity']).to eq(5000)
      expect(reloaded.operational_data['power_management']['current_usage']).to eq(2500)
    end

    it 'provides default empty hash if operational_data is empty' do
      settlement = Settlement::BaseSettlement.create!(
        name: 'Test Settlement',
        settlement_type: :base,
        current_population: 1,
        location: location,
        owner: player,
        operational_data: {}
      )

      # The operational_data method should return {} for empty hash
      expect(settlement.operational_data).to eq({})
    end

    it 'works with energy management methods' do
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

      it 'handles empty operational_data gracefully' do
        base_settlement.update!(operational_data: {})
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
        base_settlement.construction_cost_percentage = 5.0
        base_settlement.save!
      end

      it 'calculates construction cost as percentage of purchase cost' do
        purchase_cost = 100_000
        expected_cost = 5_000.0

        expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
      end

      it 'rounds to 2 decimal places' do
        purchase_cost = 12_345
        expected_cost = 617.25

        expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
      end

      it 'handles zero purchase cost' do
        expect(base_settlement.calculate_construction_cost(0)).to eq(0.0)
      end

      it 'handles string input by converting to float' do
        purchase_cost = "50000"
        expected_cost = 2_500.0

        expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
      end

      it 'handles nil input gracefully' do
        expect(base_settlement.calculate_construction_cost(nil)).to eq(0.0)
      end
    end

    describe 'manufacturing settings' do
      it 'supports manufacturing efficiency setting' do
        base_settlement.operational_data = { 'manufacturing' => { 'efficiency_bonus' => 1.25 } }
        base_settlement.save!
        expect(base_settlement.manufacturing_efficiency).to eq(1.25)
      end

      it 'defaults manufacturing efficiency to 1.0' do
        expect(base_settlement.manufacturing_efficiency).to eq(1.0)
      end

      it 'supports equipment check setting' do
        base_settlement.operational_data = { 'manufacturing' => { 'check_equipment' => false } }
        base_settlement.save!
        expect(base_settlement.required_equipment_check_enabled?).to be false
      end

      it 'defaults equipment check to true' do
        expect(base_settlement.required_equipment_check_enabled?).to be true
      end
    end
  end

  describe 'construction cost integration' do
    let(:base_settlement) { create(:base_settlement, :independent, owner: player, location: location) }

    it 'integrates construction cost calculations with settlement manufacturing data' do
      base_settlement.operational_data = {
        'manufacturing' => {
          'construction_cost_percentage' => 7.5,
          'efficiency_bonus' => 1.15,
          'check_equipment' => true
        }
      }
      base_settlement.save!

      expect(base_settlement.construction_cost_percentage).to eq(7.5)
      expect(base_settlement.manufacturing_efficiency).to eq(1.15)
      expect(base_settlement.required_equipment_check_enabled?).to be true

      purchase_cost = 80_000
      expected_cost = 6_000.0
      expect(base_settlement.calculate_construction_cost(purchase_cost)).to eq(expected_cost)
    end

    it 'preserves other operational_data when updating construction settings' do
      base_settlement.operational_data = {
        'power_management' => { 'grid_status' => 'online', 'total_capacity' => 5000 },
        'life_support' => { 'atmosphere_pressure' => 101325 }
      }
      base_settlement.save!

      base_settlement.construction_cost_percentage = 6.0
      base_settlement.save!

      expect(base_settlement.operational_data['manufacturing']['construction_cost_percentage']).to eq(6.0)
      expect(base_settlement.operational_data['power_management']['grid_status']).to eq('online')
      expect(base_settlement.operational_data['life_support']['atmosphere_pressure']).to eq(101325)
    end

    it 'works correctly when operational_data starts empty' do
      base_settlement.update!(operational_data: {})

      base_settlement.construction_cost_percentage = 8.0
      base_settlement.operational_data['manufacturing']['efficiency_bonus'] = 1.3
      base_settlement.operational_data['manufacturing']['check_equipment'] = false
      base_settlement.save!

      expect(base_settlement.construction_cost_percentage).to eq(8.0)
      expect(base_settlement.manufacturing_efficiency).to eq(1.3)
      expect(base_settlement.required_equipment_check_enabled?).to be false
    end
  end
end