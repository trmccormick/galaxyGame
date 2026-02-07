# app/models/market/npc_price_calculator.rb
module Market
  class NpcPriceCalculator
    # Calculate the price at which NPCs would buy a resource
    # @param settlement [Settlement::BaseSettlement] The settlement doing the buying
    # @param resource [String] The resource name
    # @param demand [Integer] The quantity demanded
    # @return [Float] The bid price in GCC
    def self.calculate_bid(settlement, resource, demand: 1)
      # Simple pricing logic for now - can be enhanced later
      base_price = resource_base_price(resource)
      demand_multiplier = calculate_demand_multiplier(demand)
      supply_modifier = calculate_supply_modifier(settlement, resource)

      (base_price * demand_multiplier * supply_modifier).round(2)
    end

    # Calculate the price at which NPCs would sell a resource
    # @param settlement [Settlement::BaseSettlement] The settlement doing the selling
    # @param resource [String] The resource name
    # @param supply [Integer] The quantity supplied
    # @return [Float] The ask price in GCC
    def self.calculate_ask(settlement, resource, supply: 1)
      # Simple pricing logic for now - can be enhanced later
      base_price = resource_base_price(resource)
      supply_multiplier = calculate_supply_multiplier(supply)
      demand_modifier = calculate_demand_modifier(settlement, resource)

      (base_price * supply_multiplier * demand_modifier).round(2)
    end

    private

    # Get base price for a resource
    def self.resource_base_price(resource)
      # Simple base prices - can be made configurable later
      base_prices = {
        'ibeam' => 100.0,
        'aluminum_alloy' => 50.0,
        'steel' => 30.0,
        'titanium' => 200.0,
        'carbon_fiber' => 150.0,
        'solar_panel' => 500.0,
        'battery' => 300.0,
        'fuel_cell' => 400.0
      }

      base_prices[resource] || 10.0 # Default price
    end

    # Calculate demand multiplier based on quantity
    def self.calculate_demand_multiplier(demand)
      # Higher demand increases price
      1.0 + (demand - 1) * 0.1
    end

    # Calculate supply multiplier based on quantity
    def self.calculate_supply_multiplier(supply)
      # Higher supply decreases price
      1.0 / (1.0 + (supply - 1) * 0.05)
    end

    # Calculate supply modifier based on settlement's available resources
    def self.calculate_supply_modifier(settlement, resource)
      # For now, assume settlements have moderate supply
      # This can be enhanced to check actual inventory levels
      1.0
    end

    # Calculate demand modifier based on settlement's needs
    def self.calculate_demand_modifier(settlement, resource)
      # For now, assume settlements have moderate demand
      # This can be enhanced to check construction projects, population needs, etc.
      1.0
    end
  end
end