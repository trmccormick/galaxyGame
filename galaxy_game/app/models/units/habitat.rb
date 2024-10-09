# app/models/habitat.rb
module Units
    class Habitat < BaseUnit
    attr_accessor :population_capacity, :current_population
  
    def initialize(name, base_materials, operating_requirements, input_resources, output_resources, population_capacity)
      super(name, base_materials, operating_requirements, input_resources, output_resources)
      @population_capacity = population_capacity
      @current_population = 0
    end
  
    def allocate_population(num_people)
      if num_people + current_population <= population_capacity
        @current_population += num_people
        puts "#{num_people} people allocated to #{name}."
      else
        puts "Not enough capacity for #{num_people} people in #{name}!"
      end
    end
  
    protected
  
    def consume_resources
      # Example consumption based on population
      food_needed = current_population * 2  # Assuming 2 units of food per person
      water_needed = current_population * 3  # Assuming 3 liters of water per person
      power_needed = operating_requirements[:power]  # Power requirements defined in the operating requirements
  
      puts "#{name} consuming #{food_needed} units of food, #{water_needed} liters of water, and #{power_needed} kWh of power."
  
      # Here, we would reduce the resources accordingly
      Resource.consume(:food, food_needed)
      Resource.consume(:water, water_needed)
      Resource.consume(:power, power_needed)
  
      # Produce waste based on population
      waste_amount = current_population * 1  # Assuming 1 unit of waste per person
      waste_water_amount = current_population * 1  # Assuming 1 liter of wastewater per person
      biomass_amount = current_population * 0.5  # Assuming 0.5 units of biomass per person
  
      puts "#{name} produces #{waste_amount} units of solid waste, #{waste_water_amount} liters of wastewater, and #{biomass_amount} units of biomass."
  
      Resource.add_waste(waste_amount)
      Resource.add_waste_water(waste_water_amount)
      Resource.add_biomass(biomass_amount)
    end
  
    def produce_resources
      # Example resource production
      produced_oxygen = current_population * 2  # Assuming 2 units of oxygen produced per person
  
      puts "#{name} produces #{produced_oxygen} units of oxygen."
      Resource.add(:oxygen, produced_oxygen)
  
      # Handle any additional production logic if needed
    end
  end
end
  