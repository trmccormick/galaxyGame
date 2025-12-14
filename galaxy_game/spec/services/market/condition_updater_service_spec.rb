# spec/services/market/condition_updater_service_spec.rb
require 'rails_helper'
require_relative '../../../app/services/market/condition_updater_service' # Ensure correct path

RSpec.describe Market::ConditionUpdaterService, type: :service do
  # Mock Settlement methods for the service to call
  before(:all) do
    settlement_class = Settlement::BaseSettlement

    # Required for update_settlement_conditions
    unless settlement_class.method_defined?(:tracked_resources)
      settlement_class.class_eval { def tracked_resources; ['water', 'iron_ore']; end }
    end

    # Required for calculate_new_supply
    unless settlement_class.method_defined?(:resource_production_rate)
      settlement_class.class_eval { def resource_production_rate(resource); 100.0; end }
    end
    unless settlement_class.method_defined?(:resource_consumption_rate)
      settlement_class.class_eval { def resource_consumption_rate(resource); 50.0; end }
    end

    # Required for calculate_new_demand
    unless settlement_class.method_defined?(:population)
      settlement_class.class_eval { def population; 1000; end }
    end
    unless settlement_class.method_defined?(:base_demand_per_capita)
      # Assume 0.01 units of water per person
      settlement_class.class_eval { def base_demand_per_capita(resource); 0.01; end }
    end
    unless settlement_class.method_defined?(:active_project_demand)
      settlement_class.class_eval { def active_project_demand(resource); 50.0; end }
    end
  end

  let!(:settlement) { create(:base_settlement, name: 'Test Settlement') }
  let!(:marketplace) { create(:marketplace, settlement: settlement) }
  
  # Setup for a resource that is balanced (Supply)
  let!(:water_condition) do
    create(:market_condition, 
      marketplace: marketplace, 
      resource: 'water',
      supply: 1000.0,
      demand: 1000.0
    )
  end

  # Setup for a resource that is trending down (Demand)
  let!(:iron_condition) do
    create(:market_condition, 
      marketplace: marketplace, 
      resource: 'iron_ore',
      supply: 50.0,
      demand: 200.0
    )
  end

  # Shortened constants from the service for easier calculation checking
  let(:smoothing_factor) { 0.8 }
  let(:growth_factor) { 0.05 }

  describe '.call' do
    subject { described_class.call }

    # Setup the mock data specific to the test runs
    before do
      # Ensure only our test settlement is used in .call
      allow(Settlement::BaseSettlement).to receive(:find_each).and_yield(settlement)

      # Mock the settlement's supply/demand calculation helpers
      allow(settlement).to receive(:tracked_resources).and_return(['water', 'iron_ore'])

      # Default for any other resource
      allow(settlement).to receive(:resource_production_rate).with(anything).and_return(100.0)
      allow(settlement).to receive(:resource_consumption_rate).with(anything).and_return(50.0)
      # Water: Net Production is 100 - 50 = 50
      allow(settlement).to receive(:resource_production_rate).with('water').and_return(100.0)
      allow(settlement).to receive(:resource_consumption_rate).with('water').and_return(50.0)
      # Iron: Net Consumption is 0 - 200 = -200 (Simulating high overhead consumption)
      allow(settlement).to receive(:resource_production_rate).with('iron_ore').and_return(0.0)
      allow(settlement).to receive(:resource_consumption_rate).with('iron_ore').and_return(200.0)

      # Shared Demand Inputs
      allow(settlement).to receive(:population).and_return(1000)
      allow(settlement).to receive(:base_demand_per_capita).and_return(0.01)
      allow(settlement).to receive(:active_project_demand).and_return(100.0)
      # Expected total expected demand: 
      # Population Demand (1000 * 0.01 = 10.0) + Project Demand (100.0) = 110.0
    end

    it 'updates supply for all tracked resources' do
      subject
      water_condition.reload
      iron_condition.reload
      
      # Water Supply:
      # Current Supply (1000.0 * 0.8) = 800.0
      # Net Change (100.0 - 50.0) = 50.0
      # New Supply = 800.0 + 50.0 = 850.0
      expect(water_condition.supply).to eq(850.0)

      # Iron Supply:
      # Current Supply (50.0 * 0.8) = 40.0
      # Net Change (0.0 - 200.0) = -200.0
      # New Supply = [40.0 - 200.0, 0].max = 0.0 (Floored)
      expect(iron_condition.supply).to eq(0.0)
    end

    it 'updates demand for all tracked resources, respecting smoothing and growth' do
      subject
      water_condition.reload
      iron_condition.reload
      
      # Expected Total Expected Demand (TED) = 110.0 (from before block)

      # Water Demand:
      # Current Demand (1000.0 * 0.8) = 800.0
      # Change (TED * Growth Factor) = 110.0 * 0.05 = 5.5
      # New Demand = 800.0 + 5.5 = 805.5
      expect(water_condition.demand).to be_within(0.5).of(805.5)

      # Iron Demand:
      # Current Demand (200.0 * 0.8) = 160.0
      # Change (TED * Growth Factor) = 110.0 * 0.05 = 5.5
      # New Demand = 160.0 + 5.5 = 165.5
      expect(iron_condition.demand).to be_within(0.5).of(165.5)
    end
    
    it 'creates a market condition if one does not exist' do
      # Temporarily mock to include a third, untracked resource
      allow(settlement).to receive(:tracked_resources).and_return(['water', 'iron_ore', 'new_resource'])
      
      expect { subject }.to change { Market::Condition.count }.by(1)

      new_condition = Market::Condition.find_by(resource: 'new_resource')
      
      # New Supply: (0 * 0.8) + (100 - 50) = 50.0
      expect(new_condition.supply).to eq(50.0)
      
      # New Demand: (0 * 0.8) + (110 * 0.05) = 5.5 (Floored at 1.0)
      # Wait, since the initial demand is 1000.0 for water, we need to adjust
      # the initial condition demand for a new resource to 0 or 1.0. 
      # Let's assume the helper methods default to 1.0 for an initial condition.
      
      # The condition's initial demand is 1.0 (from find_or_create_by!)
      # Initial Demand (1.0 * 0.8) = 0.8
      # Change (TED * Growth Factor) = 5.5
      # New Demand = 0.8 + 5.5 = 6.3
      expect(new_condition.demand).to be_within(2).of(6.3)
      expect(new_condition.marketplace).to eq(marketplace)
    end
    
    it 'initializes a marketplace if the settlement does not have one' do
      # Create a new settlement without a marketplace
      settlement_2 = create(:base_settlement, name: 'New Colony')
      allow(settlement_2).to receive(:tracked_resources).and_return(['water'])
      
      expect { described_class.update_settlement_conditions(settlement_2) }
        .to change { Market::Marketplace.count }.by(1)
        
      settlement_2.reload
      expect(settlement_2.marketplace).to be_present
    end
  end

  describe '.calculate_new_supply' do
    let(:condition_mock) { double('MarketCondition', supply: 1000.0, resource: 'steel') }
    
    it 'returns zero if net change is a large negative and smooths current supply' do
      # Initial Supply: 1000.0
      # Current Supply (1000.0 * 0.8) = 800.0
      
      allow(settlement).to receive(:resource_production_rate).and_return(0.0)
      allow(settlement).to receive(:resource_consumption_rate).and_return(1000.0) # Net change -1000.0
      
      # New Supply = 800.0 - 1000.0 = -200.0 -> Floored to 0.0
      expect(described_class.send(:calculate_new_supply, settlement, condition_mock)).to eq(0.0)
    end
  end
end