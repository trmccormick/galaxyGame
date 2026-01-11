# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Manufacturing::CostCalculator do
  # --- Input Data using let blocks (better practice for RSpec) ---
  
  # 1. The Small Fuel Tank Unit Blueprint
  let(:fuel_tank_blueprint) do
    {
      "template" => "unit_blueprint",
      "id" => "fuel_tank_s",
      "name" => "Small Fuel Tank",
      "required_materials" => {
        "titanium_alloy" => { "amount" => 80, "unit" => "kilogram" },
        "composite_insulation" => { "amount" => 20, "unit" => "kilogram" },
        "pressure_valves" => { "amount" => 10, "unit" => "kilogram" },
        "electronics" => { "amount" => 10, "unit" => "kilogram" }
      },
      "production_data" => {
        "time_hours" => 1.8,
        "base_material_efficiency" => 0.95, # 5% waste
      },
      "cost_data" => {
        # The final market price set by the Earth corporation.
        "purchase_cost" => { "currency" => "GCC", "amount" => 8500 } 
      }
    }
  end

  # 2. Earth Anchor Prices (EAPs) for Tier 1 Materials (calculated prices from the first spec)
  # These are hardcoded here for testing independence, but represent the EAP.
  let(:eap_market_prices) do
    {
      "titanium_alloy" => 57.50, # (15.00 * 2.5) + 20.00 = 57.50
      "composite_insulation" => 26.00, # (1.50 * 4.0) + 20.00 = 26.00
      "pressure_valves" => 36.00, # (8.00 * 2.0) + 20.00 = 36.00
      "electronics" => 134.00 # (40.00 * 3.0) + 14.00 = 134.00
    }
  end
  
  # Calculation: 
  # Raw Cost: (80*57.5) + (20*26.0) + (10*36.0) + (10*134.0) = 4600 + 520 + 360 + 1340 = 6820
  # EAP-COGS: 6820 / 0.95 = 7178.9474
  let(:expected_eap_cogs) { 7178.9474 }
  
  # Local Anchor Prices (LAP) - Removes the logistics cost from EAP (EAP - Logistics)
  let(:local_anchor_prices) do
    {
      "titanium_alloy" => 37.50, 
      "composite_insulation" => 6.00,
      "pressure_valves" => 16.00,
      "electronics" => 120.00 
    }
  end

  # Calculation: 
  # Raw Cost: (80*37.5) + (20*6.0) + (10*16.0) + (10*120.0) = 3000 + 120 + 160 + 1200 = 4480
  # LAP-COGS: 4480 / 0.95 = 4715.7895
  let(:expected_lap_cogs) { 4715.7895 }

  describe 'Earth-Imported COGS (EAP-COGS)' do
    subject(:eap_calculator) { Manufacturing::CostCalculator.new(fuel_tank_blueprint, eap_market_prices) }

    it 'calculates the EAP-COGS (Earth Import Cost) for the unit' do
      puts "\n--- Calculating Earth-Imported COGS (EAP-COGS) for Small Fuel Tank ---"
      
      eap_calculator.print_breakdown 

      cogs = eap_calculator.calculate_cogs
      expect(cogs).to be_within(0.0001).of(expected_eap_cogs) 
      
      earth_price = fuel_tank_blueprint['cost_data']['purchase_cost']['amount']
      profit_margin = earth_price - cogs
      
      puts "\n== EAP-COGS Summary =="
      puts "Calculated EAP-COGS (Earth Import Floor Price): #{cogs.round(2)} GCC"
      puts "Blueprint Purchase Price (Earth Corp): #{earth_price.round(2)} GCC"
      puts "Profit/Labor Margin (Earth Corp): #{profit_margin.round(2)} GCC"
    end
  end
  
  describe 'Local Production COGS (LAP-COGS)' do
    subject(:lap_calculator) { Manufacturing::CostCalculator.new(fuel_tank_blueprint, local_anchor_prices) }
    
    it 'calculates the LAP-COGS (Local Production Cost) for the unit' do
      puts "\n--- Calculating Local Production COGS (LAP-COGS) for Small Fuel Tank ---"
      
      lap_calculator.print_breakdown 

      cogs = lap_calculator.calculate_cogs
      expect(cogs).to be_within(0.0001).of(expected_lap_cogs) 

      local_advantage = expected_eap_cogs - cogs

      puts "\n== LAP-COGS Summary =="
      puts "Calculated LAP-COGS (Local Floor Price): #{cogs.round(2)} GCC"
      puts "Earth Import COGS (EAP-COGS): #{expected_eap_cogs.round(2)} GCC"
      puts "Local Advantage (Logistics Savings): #{local_advantage.round(2)} GCC"
    end
  end
end