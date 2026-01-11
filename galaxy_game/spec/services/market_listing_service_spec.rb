# frozen_string_literal: true

require_relative '../../app/services/market_listing_service' 

RSpec.describe MarketListingService do
  # The Small Fuel Tank Unit Blueprint
  FUEL_TANK_BLUEPRINT = {
    "template" => "unit_blueprint",
    "id" => "fuel_tank_s",
    "name" => "Small Fuel Tank",
    "required_materials" => {
      "titanium_alloy" => { "amount" => 80, "unit" => "kilogram" },
      # ... other materials
    },
    "production_data" => {
      "time_hours" => 1.8,
      "base_material_efficiency" => 0.95,
    },
    "cost_data" => {
      # The final market price set by the Earth corporation (our competitor).
      "purchase_cost" => { "currency" => "GCC", "amount" => 8500.00 } 
    }
  }.freeze

  # COGS calculated using Earth Anchor Prices (Imported Materials)
  EAP_COGS = 7178.95 

  # COGS calculated using Local Anchor Prices (Locally Produced Materials)
  LAP_COGS = 4715.79 
  
  # --- Scenario 1: Undercutting Earth Price is Possible (EAP-COGS) ---
  context 'when selling based on EAP-COGS (Initial Import Phase)' do
    it 'sets the price exactly 5% below the Earth Price' do
      puts "\n--- Pricing Scenario 1: Initial Import Phase (EAP-COGS) ---"
      
      # Earth Price is 8500
      # 5% Undercut Target: 8500 * 0.95 = 8075.00
      # COGS Floor + 1%: 7178.95 * 1.01 = 7250.74
      # Final Price is MAX(8075.00, 7250.74) = 8075.00
      
      service = MarketListingService.new(FUEL_TANK_BLUEPRINT, EAP_COGS)
      listing_price = service.determine_listing_price
      
      expect(listing_price).to be_within(0.01).of(8075.00)
      
      puts "EAP-COGS (Floor): #{EAP_COGS.round(2)} GCC"
      puts "Earth Price (Competitor): 8500.00 GCC"
      puts "Listing Price: #{listing_price.round(2)} GCC (5% Undercut)"
    end
  end

  # --- Scenario 2: Massive Local Advantage (LAP-COGS) ---
  context 'when selling based on LAP-COGS (Local Production Phase)' do
    it 'sets the price exactly 5% below the Earth Price, maximizing margin' do
      puts "\n--- Pricing Scenario 2: Local Production Phase (LAP-COGS) ---"

      # Earth Price is 8500
      # 5% Undercut Target: 8500 * 0.95 = 8075.00
      # COGS Floor + 1%: 4715.79 * 1.01 = 4762.95
      # Final Price is MAX(8075.00, 4762.95) = 8075.00 (The AI maintains the undercut)
      
      service = MarketListingService.new(FUEL_TANK_BLUEPRINT, LAP_COGS)
      listing_price = service.determine_listing_price
      
      expect(listing_price).to be_within(0.01).of(8075.00)
      
      puts "LAP-COGS (Floor): #{LAP_COGS.round(2)} GCC"
      puts "Earth Price (Competitor): 8500.00 GCC"
      puts "Listing Price: #{listing_price.round(2)} GCC (5% Undercut)"
      puts "Margin vs. LAP-COGS: #{(listing_price - LAP_COGS).round(2)} GCC"
    end
  end
  
  # --- Scenario 3: Undercutting Earth Price is NOT Possible (Edge Case) ---
  context 'when COGS is too high to undercut the Earth Price by 5%' do
    it 'sets the price to the Minimum Acceptable Price (COGS + 1%)' do
      # Simulate a material price spike leading to an extremely high COGS
      HIGH_COGS = 8400.00 # Earth Price is 8500.00

      # Earth Price is 8500
      # 5% Undercut Target: 8500 * 0.95 = 8075.00
      # COGS Floor + 1%: 8400.00 * 1.01 = 8484.00
      # Final Price is MAX(8075.00, 8484.00) = 8484.00 (Must choose the minimum acceptable price)
      
      service = MarketListingService.new(FUEL_TANK_BLUEPRINT, HIGH_COGS)
      listing_price = service.determine_listing_price
      
      expect(listing_price).to be_within(0.01).of(8484.00)

      puts "\n--- Pricing Scenario 3: High COGS Edge Case ---"
      puts "HIGH_COGS (Floor): #{HIGH_COGS.round(2)} GCC"
      puts "Earth Price (Competitor): 8500.00 GCC"
      puts "Listing Price: #{listing_price.round(2)} GCC (COGS + 1% Margin)"
    end
  end
end