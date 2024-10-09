# app/services/trade_service.rb
class TradeService
    def initialize(inventory, buyer_colony)
      @inventory = inventory
      @buyer_colony = buyer_colony
    end
  
    # Dynamic price calculation based on scarcity, transportation costs, and potential market fluctuations
    def dynamic_price
      scarcity_factor = (1000.0 / (@inventory.quantity + 1)) # Avoid division by zero
      base_price = base_price_for_type
      fuel_cost = calculate_fuel_cost
      market_modifier = market_conditions
  
      total_price = base_price * scarcity_factor + fuel_cost + market_modifier
      total_price.round(2) # Rounded for better readability
    end
  
    # Base price based on material type (raw material vs processed good)
    def base_price_for_type
      case @inventory.material_type
      when 'raw_material'
        5.0  # Example base price for raw materials
      when 'processed_good'
        20.0 # Higher base price for processed goods
      else
        10.0 # Fallback price if material_type isn't set
      end
    end
  
    # Simulate transportation fuel cost
    def fuel_cost_per_unit
      0.1 # Example fuel cost per unit distance
    end
  
    # Calculate distance between colonies
    def distance_to_buyer
      (@inventory.colony.planet.distance_from(@buyer_colony.planet)) / 1000.0 # Simplified distance calculation
    end
  
    def calculate_fuel_cost
      distance_to_buyer * fuel_cost_per_unit
    end
  
    # Market conditions: Simulate a random market fluctuation for pricing
    def market_conditions
      rand(-5.0..5.0) # A random modifier, could be tied to more complex economy logic
    end
end
  