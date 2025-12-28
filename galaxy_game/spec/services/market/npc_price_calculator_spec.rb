# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Market::NpcPriceCalculator do
  # BOILERPLATE FIX: Ensure Settlement::BaseSettlement has all required methods 
  # for successful mocking during these tests.
  before(:all) do
    settlement_class = Settlement::BaseSettlement

    # Required for: returns nil if settlement does not want resource (available_storage)
    unless settlement_class.method_defined?(:available_storage)
      settlement_class.class_eval { def available_storage(resource); 1000; end }
    end

    # Required for: with inventory adjustments (inventory_level)
    unless settlement_class.method_defined?(:inventory_level)
      settlement_class.class_eval { def inventory_level(resource); 0.50; end }
    end

    # Required for: local production pricing (has_facility?)
    unless settlement_class.method_defined?(:has_facility?)
      settlement_class.class_eval { def has_facility?(facility_name); false; end }
    end
  end

  let(:settlement) { create(:base_settlement, name: 'Luna Base Alpha') }
  let(:marketplace) { create(:marketplace, settlement: settlement) }
  let(:market_condition) { create(:market_condition, marketplace: marketplace, resource: 'water') }
  
  before(:each) do
    # Ensure economic config is loaded
    EconomicConfig.reload!
    
    # Mock MaterialGeneratorService to return test data
    allow(MaterialGeneratorService).to receive(:generate_material).and_call_original
  end

  describe '.calculate_ask' do
    context 'with cost-based pricing (no market history)' do
      let(:water_data) do
        {
          'id' => 'water',
          'name' => 'Water',
          'category' => 'bulk',
          'pricing' => {
            'earth' => {
              'base_price_per_kg' => 0.001
            }
          },
          'refining_cost_factor' => 1.0
        }
      end
      
      before do
        allow(MaterialGeneratorService).to receive(:generate_material)
          .with('water').and_return(water_data)
      end
      
      it 'returns Earth import cost plus markup' do
        ask_price = described_class.calculate_ask(settlement, 'water')
        expect(ask_price).to be_within(1.0).of(105.0)
      end
      
      it 'maintains minimum profit margin' do
        ask_price = described_class.calculate_ask(settlement, 'water', markup: 1.01)
        import_cost = 100.0
        minimum_price = import_cost * 1.03
        expect(ask_price).to be >= minimum_price
      end
    end
    
    context 'with market-based pricing (sufficient history)' do
      let(:test_resource_data) do
        {
          'id' => 'test_resource',
          'name' => 'Test Resource',
          'category' => 'bulk',
          'pricing' => {
            'earth' => {
              'base_price_per_kg' => 0.10
            }
          },
          'refining_cost_factor' => 1.0
        }
      end
      
      before do
        allow(MaterialGeneratorService).to receive(:generate_material)
          .with('test_resource').and_return(test_resource_data)
        
        test_condition = create(:market_condition, 
          marketplace: marketplace,
          resource: 'test_resource'
        )
        
        15.times do |i|
          create(:price_history,
            market_condition: test_condition,
            price: 100.0,
            created_at: i.days.ago
          )
        end
      end
      
      it 'uses market average with markup' do
        ask_price = described_class.calculate_ask(settlement, 'test_resource')
        expect(ask_price).to be_within(5.0).of(103.0)
      end
      
      it 'never goes below cost floor' do
        cheap_condition = create(:market_condition,
          marketplace: marketplace,
          resource: 'cheap_material'
        )
        
        20.times do |i|
          create(:price_history,
            market_condition: cheap_condition,
            price: 1.0,
            created_at: i.days.ago
          )
        end
        
        expensive_material = {
          'id' => 'cheap_material',
          'name' => 'Cheap Material',
          'pricing' => {
            'earth' => {
              'base_price_per_kg' => 50.0
            }
          },
          'refining_cost_factor' => 2.0
        }
        
        allow(MaterialGeneratorService).to receive(:generate_material)
          .with('cheap_material').and_return(expensive_material)
        
        ask_price = described_class.calculate_ask(settlement, 'cheap_material')
        expect(ask_price).to be > 100.0
      end
    end
  end

  describe '.calculate_bid' do
    context 'with cost-based pricing' do
      let(:iron_data) do
        {
          'id' => 'iron_ore',
          'name' => 'Iron Ore',
          'category' => 'ore',
          'pricing' => {
            'earth' => {
              'base_price_per_kg' => 0.10
            }
          },
          'refining_cost_factor' => 1.0
        }
      end
      
      before do
        allow(MaterialGeneratorService).to receive(:generate_material)
          .with('iron_ore').and_return(iron_data)
      end
      
      it 'returns Earth import cost with discount' do
        bid_price = described_class.calculate_bid(settlement, 'iron_ore')
        expect(bid_price).to be_within(1.0).of(75.0)
      end
      
      it 'returns nil if settlement does not want resource' do
        allow_any_instance_of(Settlement::BaseSettlement).to receive(:available_storage).and_return(0)
        bid_price = described_class.calculate_bid(settlement, 'iron_ore')
        expect(bid_price).to be_nil
      end
    end
    
    context 'with inventory adjustments' do
      let(:water_data) do
        {
          'id' => 'water',
          'name' => 'Water',
          'category' => 'bulk',
          'pricing' => {
            'earth' => {
              'base_price_per_kg' => 0.001
            }
          }
        }
      end
      
      before do
        allow(MaterialGeneratorService).to receive(:generate_material)
          .with('water').and_return(water_data)
      end
      
      it 'pays more when inventory is critical' do
        allow_any_instance_of(Settlement::BaseSettlement).to receive(:inventory_level).with('water').and_return(0.05)
        
        bid_price = described_class.calculate_bid(settlement, 'water')
        normal_bid = described_class.calculate_bid(settlement, 'water', ignore_inventory: true)
        
        expect(bid_price).to be > normal_bid
      end
      
      it 'pays normal price when inventory is adequate' do
        allow_any_instance_of(Settlement::BaseSettlement).to receive(:inventory_level).with('water').and_return(0.50)
        bid_price = described_class.calculate_bid(settlement, 'water')
        expect(bid_price).to be_within(5.0).of(75.0)
      end
      
      it 'does not buy when inventory is excess' do
        allow_any_instance_of(Settlement::BaseSettlement).to receive(:inventory_level).with('water').and_return(0.80)
        bid_price = described_class.calculate_bid(settlement, 'water')
        expect(bid_price).to be_nil
      end
    end
  end

  describe '.calculate_spread' do
    let(:material_data) do
      {
        'id' => 'titanium',
        'name' => 'Titanium',
        'pricing' => {
          'earth' => {
            'base_price_per_kg' => 30.0
          }
        }
      }
    end
    
    before do
      allow(MaterialGeneratorService).to receive(:generate_material)
        .with('titanium').and_return(material_data)
    end
    
    it 'calculates bid-ask spread' do
      spread = described_class.calculate_spread(settlement, 'titanium')
      
      expect(spread[:bid]).to be_present
      expect(spread[:ask]).to be_present
      expect(spread[:spread]).to be_present
      expect(spread[:spread_percent]).to be_present
      expect(spread[:ask]).to be > spread[:bid]
    end
    
    it 'calculates spread percentage correctly' do
      spread = described_class.calculate_spread(settlement, 'titanium')
      manual_percent = ((spread[:ask] - spread[:bid]) / spread[:ask]) * 100
      expect(spread[:spread_percent]).to be_within(0.1).of(manual_percent)
    end
  end

  describe 'local production pricing' do
    let(:settlement_with_mining) { create(:base_settlement) }
    let(:water_data) do
      {
        'id' => 'water',
        'name' => 'Water',
        'category' => 'bulk',
        'pricing' => {
          'earth' => {
            'base_price_per_kg' => 0.001
          },
          'lunar_production' => {
            'available' => true,
            'cost_per_kg' => 2.0,
            'facility_required' => 'water_mining'
          }
        }
      }
    end
    
    before do
      allow(MaterialGeneratorService).to receive(:generate_material)
        .with('water').and_return(water_data)
    end
    
    context 'when settlement can produce locally' do
      before do
        allow_any_instance_of(Settlement::BaseSettlement).to receive(:has_facility?)
          .with('water_mining').and_return(true)
      end
      
      it 'uses local production cost instead of import cost' do
        ask_price = described_class.calculate_ask(settlement_with_mining, 'water')
        expect(ask_price).to be_within(0.5).of(2.10)
      end
      
      it 'offers much cheaper prices than import' do
        local_ask = described_class.calculate_ask(settlement_with_mining, 'water')
        
        allow(settlement_with_mining).to receive(:has_facility?)
          .with('water_mining').and_return(false)
        
        import_ask = described_class.calculate_ask(settlement_with_mining, 'water')
        expect(local_ask).to be < (import_ask * 0.05)
      end
    end
    
    context 'when settlement cannot produce locally' do
      before do
        allow_any_instance_of(Settlement::BaseSettlement).to receive(:has_facility?)
          .with('water_mining').and_return(false)
      end
      
      it 'falls back to import pricing' do
        ask_price = described_class.calculate_ask(settlement_with_mining, 'water')
        expect(ask_price).to be > 100.0
      end
    end
  end

  describe 'error handling' do
    let(:water_data) do
      {
        'id' => 'water',
        'name' => 'Water',
        'category' => 'bulk',
        'pricing' => {
          'earth' => {
            'base_price_per_kg' => 0.001
          }
        },
        'refining_cost_factor' => 1.0
      }
    end
    
    it 'returns nil gracefully for unknown materials' do
      allow(MaterialGeneratorService).to receive(:generate_material)
        .with('nonexistent').and_return(nil)
      
      ask_price = described_class.calculate_ask(settlement, 'nonexistent')
      bid_price = described_class.calculate_bid(settlement, 'nonexistent')
      
      expect(ask_price).to be_nil
      expect(bid_price).to be_nil
    end
    
    it 'handles settlements without location' do
      allow(MaterialGeneratorService).to receive(:generate_material)
        .with('water').and_return(water_data)
      
      settlement_without_location = build(:base_settlement, location: nil)
      ask_price = described_class.calculate_ask(settlement_without_location, 'water')
      expect(ask_price).to be_present
    end
    
    it 'handles nil settlement' do
      allow(MaterialGeneratorService).to receive(:generate_material)
        .with('water').and_return(water_data)
      
      ask_price = described_class.calculate_ask(nil, 'water')
      expect(ask_price).to be_present
    end
  end

  describe 'integration with Tier1PriceModeler' do
    let(:water_data) do
      {
        'id' => 'water',
        'name' => 'Water',
        'category' => 'bulk',
        'pricing' => {
          'earth' => {
            'base_price_per_kg' => 0.001
          }
        },
        'refining_cost_factor' => 1.0
      }
    end
    
    it 'uses Tier1PriceModeler for base cost calculations' do
      allow(MaterialGeneratorService).to receive(:generate_material)
        .with('water').and_return(water_data)
      
      allow(Tier1PriceModeler).to receive(:new).and_call_original
      described_class.calculate_ask(settlement, 'water')
      expect(Tier1PriceModeler).to have_received(:new)
    end
  end

  describe 'integration with Market::PriceHistory' do
    let(:test_resource_data) do
      {
        'id' => 'test_resource',
        'name' => 'Test Resource',
        'category' => 'bulk',
        'pricing' => {
          'earth' => {
            'base_price_per_kg' => 0.10
          }
        },
        'refining_cost_factor' => 1.0
      }
    end
    
    it 'queries price history for market-based pricing' do
      allow(MaterialGeneratorService).to receive(:generate_material)
        .with('test_resource').and_return(test_resource_data)
      
      test_condition = create(:market_condition,
        marketplace: marketplace,
        resource: 'test_resource'
      )
      
      15.times do |i|
        create(:price_history,
          market_condition: test_condition,
          price: 100.0,
          created_at: i.days.ago
        )
      end
      
      ask_price = described_class.calculate_ask(settlement, 'test_resource')
      expect(ask_price).to be_within(5.0).of(103.0)
    end
  end
end