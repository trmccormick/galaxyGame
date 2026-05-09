
# app/models/units/habitat.rb

# NOTE: This model overlaps with PopulationManagement concern.
# - Both define population_capacity/current_population logic and add/remove methods.
# - Habitat uses operational_data for state, PopulationManagement expects direct attributes.
#
# SUGGESTIONS for future update (when Claude is back):
# 1. Decide on a single source of truth for population state (attributes vs. operational_data).
# 2. Refactor PopulationManagement to support operational_data, or adapt Habitat to use attributes.
# 3. Remove duplicated logic and let the concern handle all population management if possible.
# 4. Keep Habitat focused on providing capacity/state to a craft or settlement.
#
# See also: app/models/concerns/population_management.rb

module Units
  class Habitat < BaseUnit
    # All configuration/state is in operational_data

    def population_capacity
      operational_data&.dig('population_capacity') || 0
    end

    def current_population
      operational_data&.dig('current_population') || 0
    end

    def add_population(amount)
      operational_data['current_population'] = current_population + amount
      save if respond_to?(:save)
    end

    def remove_population(amount)
      operational_data['current_population'] = [current_population - amount, 0].max
      save if respond_to?(:save)
    end

    def population_full?
      current_population >= population_capacity
    end

    def available_capacity
      population_capacity - current_population
    end

    protected

    def consume_resources
      # Example consumption based on population
      food_needed = current_population * 2  # 2 units of food per person
      water_needed = current_population * 3  # 3 liters of water per person
      power_needed = operating_requirements[:power]  # Power requirements from operating_requirements

      puts "#{name} consuming #{food_needed} units of food, #{water_needed} liters of water, and #{power_needed} kWh of power."

      Resource.consume(:food, food_needed)
      Resource.consume(:water, water_needed)
      Resource.consume(:power, power_needed)

      # Produce waste based on population
      waste_amount = current_population * 1
      waste_water_amount = current_population * 1
      biomass_amount = current_population * 0.5

      puts "#{name} produces #{waste_amount} units of solid waste, #{waste_water_amount} liters of wastewater, and #{biomass_amount} units of biomass."

      Resource.add_waste(waste_amount)
      Resource.add_waste_water(waste_water_amount)
      Resource.add_biomass(biomass_amount)
    end

    def produce_resources
      produced_oxygen = current_population * 2
      puts "#{name} produces #{produced_oxygen} units of oxygen."
      Resource.add(:oxygen, produced_oxygen)
    end
  end
end
  