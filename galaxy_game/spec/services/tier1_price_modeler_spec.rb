# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tier1PriceModeler do
  # NOTE: With the new unified transport system, we no longer pass global params
  # Instead, pricing is determined by:
  # 1. Earth spot prices from economic_parameters.yml
  # 2. Transport costs from TransportCostService (category-based)
  # 3. Refining factors from economic_parameters.yml
  
  # Expected transport costs (from economic_parameters.yml):
  # - bulk_material: $100/kg
  # - manufactured: $150/kg
  # - high_tech: $200/kg

  # --- Material Definitions for Small Fuel Tank Components ---
  
  TITANIUM_DATA = {
    "id" => "titanium_alloy",
    "name" => "Titanium Alloy",
    "category" => "alloy",
    "type" => "alloy",
    "earth_spot_price_usd_per_kg" => 15.00,
    "refining_cost_factor" => 2.5
  }.freeze

  COMPOSITE_DATA = {
    "id" => "composite_insulation",
    "name" => "Composite Insulation",
    "category" => "manufactured",
    "type" => "composite",
    "earth_spot_price_usd_per_kg" => 1.50,
    "refining_cost_factor" => 4.0
  }.freeze

  VALVE_DATA = {
    "id" => "pressure_valves",
    "name" => "Pressure Valves",
    "category" => "manufactured",
    "type" => "component",
    "earth_spot_price_usd_per_kg" => 8.00,
    "refining_cost_factor" => 2.0
  }.freeze

  ELECTRONICS_DATA = {
    "id" => "electronics",
    "name" => "Electronics",
    "category" => "electronics",
    "type" => "electronics",
    "earth_spot_price_usd_per_kg" => 40.00,
    "refining_cost_factor" => 3.0
  }.freeze

  before(:all) do
    # Ensure economic config is loaded
    EconomicConfig.reload!
  end

  before do
    allow(EconomicConfig).to receive(:transport_rate).with('manufactured').and_return(150.0)
    allow(EconomicConfig).to receive(:transport_rate).with('high_tech').and_return(200.0)
    allow(EconomicConfig).to receive(:transport_rate).with('bulk_material').and_return(100.0)
  end

  describe '#calculate_eap' do
    context 'with titanium alloy' do
      let(:calculator) { described_class.new(TITANIUM_DATA, destination: 'luna') }
      
      it 'calculates the correct EAP' do
        # Earth cost: $15 * 2.5 = $37.50
        # Transport (manufactured category): $150/kg
        # Total: $37.50 + $150 = $187.50
        
        eap = calculator.calculate_eap
        expect(eap).to be_within(0.01).of(187.50)
      end
      
      it 'can print breakdown without errors' do
        expect { calculator.print_breakdown }.not_to raise_error
      end
    end

    context 'with composite insulation' do
      let(:calculator) { described_class.new(COMPOSITE_DATA, destination: 'luna') }
      
      it 'calculates the correct EAP' do
        # Earth cost: $1.50 * 4.0 = $6.00
        # Transport (manufactured category): $150/kg
        # Total: $6.00 + $150 = $156.00
        
        eap = calculator.calculate_eap
        expect(eap).to be_within(0.01).of(156.00)
      end
    end

    context 'with pressure valves' do
      let(:calculator) { described_class.new(VALVE_DATA, destination: 'luna') }
      
      it 'calculates the correct EAP' do
        # Earth cost: $8.00 * 2.0 = $16.00
        # Transport (manufactured category): $150/kg
        # Total: $16.00 + $150 = $166.00
        
        eap = calculator.calculate_eap
        expect(eap).to be_within(0.01).of(166.00)
      end
    end

    context 'with electronics' do
      let(:calculator) { described_class.new(ELECTRONICS_DATA, destination: 'luna') }
      
      it 'calculates the correct EAP' do
        # Earth cost: $40.00 * 3.0 = $120.00
        # Transport (high_tech category): $200/kg
        # Total: $120.00 + $200 = $320.00
        
        eap = calculator.calculate_eap
        expect(eap).to be_within(0.01).of(320.00)
      end
    end
    
    context 'with different destinations' do
      let(:material_data) do
        {
          "id" => "water",
          "name" => "Water",
          "category" => "bulk",
          "earth_spot_price_usd_per_kg" => 0.001,
          "refining_cost_factor" => 1.0
        }
      end
      
      it 'calculates different costs for different routes' do
        luna_calc = described_class.new(material_data, destination: 'luna')
        mars_calc = described_class.new(material_data, destination: 'mars')
        
        luna_eap = luna_calc.calculate_eap
        mars_eap = mars_calc.calculate_eap
        
        # Mars should be more expensive due to route modifiers
        expect(mars_eap).to be > luna_eap
      end
    end
    
    context 'with missing data' do
      let(:minimal_data) { { "name" => "Unknown Material" } }
      let(:calculator) { described_class.new(minimal_data) }
      
      it 'returns 0.0 without crashing' do
        eap = calculator.calculate_eap
        expect(eap).to eq(0.0)
      end
    end
  end

  describe 'EAP storage for downstream use' do
    it 'stores calculated EAPs in a hash' do
      new_market_prices = {}
      
      # Calculate all four materials
      titanium_calc = described_class.new(TITANIUM_DATA)
      new_market_prices["titanium_alloy"] = titanium_calc.calculate_eap
      
      composite_calc = described_class.new(COMPOSITE_DATA)
      new_market_prices["composite_insulation"] = composite_calc.calculate_eap
      
      valve_calc = described_class.new(VALVE_DATA)
      new_market_prices["pressure_valves"] = valve_calc.calculate_eap
      
      electronics_calc = described_class.new(ELECTRONICS_DATA)
      new_market_prices["electronics"] = electronics_calc.calculate_eap
      
      # Verify all prices are positive
      expect(new_market_prices.values).to all(be > 0)
      
      # Store globally for other specs if needed
      $new_market_prices = new_market_prices
    end
  end

  describe 'integration with EconomicConfig' do
    it 'uses transport costs from config' do
      calculator = described_class.new(TITANIUM_DATA)
      
      # Mock TransportCostService to verify it's being called
      allow(Logistics::TransportCostService).to receive(:calculate_cost_per_kg)
        .and_return(150.0)
      
      calculator.calculate_eap
      
      expect(Logistics::TransportCostService).to have_received(:calculate_cost_per_kg)
    end
    
    it 'uses earth spot prices from config when available' do
      # If titanium is defined in economic_parameters.yml, it should use that
      config_price = EconomicConfig.earth_spot_price('titanium')
      
      if config_price
        data = TITANIUM_DATA.dup.tap do |d|
          d.delete('earth_spot_price_usd_per_kg')
          d['id'] = 'titanium'
          d['name'] = 'Titanium'
        end
        calculator = described_class.new(data)
        
        eap = calculator.calculate_eap
        expect(eap).to be > 0
      end
    end
  end
  
  describe '#print_breakdown' do
    let(:calculator) { described_class.new(TITANIUM_DATA) }
    
    it 'outputs detailed breakdown' do
      expect { calculator.print_breakdown }.to output(/EARTH ANCHOR PRICE/).to_stdout
    end
    
    it 'returns the calculated EAP' do
      result = calculator.print_breakdown
      expect(result).to eq(calculator.calculate_eap)
    end
  end
end