# app/services/market/condition_updater_service.rb
module Market
  class ConditionUpdaterService
    
    # === CONFIGURATION CONSTANTS ===
    # Factor to determine how much previous supply/demand data influences the new value
    SMOOTHING_FACTOR = 0.8
    
    # Factor to apply to the overall rate of change (e.g., how quickly demand ramps up)
    GROWTH_FACTOR = 0.05 
    
    # The main entry point, usually called by a scheduled job (e.g., Sidekiq cron)
    def self.call
      Settlement::BaseSettlement.find_each do |settlement|
        update_settlement_conditions(settlement)
      end
    end
    
    private
    
    # Iterates through all market conditions for a settlement and updates them
    def self.update_settlement_conditions(settlement)
      # Find or create a Market::Marketplace for the settlement
      marketplace = settlement.marketplace || Market::Marketplace.create!(settlement: settlement)
      
      # Iterate over all resources the settlement tracks (e.g., defined in its config)
      settlement.tracked_resources.each do |resource_name|
        condition = marketplace.market_conditions.find_or_create_by!(resource: resource_name)
        
        # 1. Calculate New Supply
        new_supply = calculate_new_supply(settlement, condition)
        
        # 2. Calculate New Demand
        new_demand = calculate_new_demand(settlement, condition)
        
        # 3. Update the condition record
        condition.update!(
          supply: new_supply,
          demand: new_demand,
          # Optionally track trade volume or other metrics here
        )
      end
    end

    # Calculates the updated supply based on production, consumption, and previous supply
    def self.calculate_new_supply(settlement, condition)
      # --- BASE SUPPLY CALCULATION ---
      
      # 1. Current Supply (smoothed from previous period)
      current_supply = (condition.supply || 0.0) * SMOOTHING_FACTOR # ADD || 0.0
      
      # 2. Local Production Rate
      # Assume settlement has a method to get hourly/daily production for a resource
      production_rate = settlement.resource_production_rate(condition.resource)
      
      # 3. Consumption Rate
      # Assume consumption is a fixed overhead or related to population/facilities
      consumption_rate = settlement.resource_consumption_rate(condition.resource)
      
      # 4. Net Change
      net_change = production_rate - consumption_rate
      
      # 5. Apply Net Change (with a floor of zero)
      smoothed_supply = [current_supply + net_change, 0].max
      
      return smoothed_supply
    end
    
    # Calculates the updated demand based on population, projects, and previous demand
    def self.calculate_new_demand(settlement, condition)
      # --- BASE DEMAND CALCULATION ---

      # 1. Current Demand (smoothed from previous period)
      current_demand = (condition.demand || 0.0) * SMOOTHING_FACTOR

      # 2. Population-driven Demand
      # Demand increases based on population and a growth factor.
      # This is often the primary driver of basic resources (food, water, etc.)
      population_demand = settlement.population * settlement.base_demand_per_capita(condition.resource)

      # 3. Project/Facility Demand (e.g., building a new factory needs 500 Iron Ore)
      project_demand = settlement.active_project_demand(condition.resource)

      # 4. Total Expected Demand
      total_expected_demand = population_demand + project_demand

      # 5. Apply Growth Factor to ensure demand trend is recognized
      new_demand = current_demand + (total_expected_demand * GROWTH_FACTOR)

      # Ensure minimum demand of 1 to avoid division by zero in price calculation
      return [new_demand, 1.0].max
    end
    
  end
end