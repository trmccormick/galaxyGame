# app/models/concerns/population_management.rb
module PopulationManagement
    extend ActiveSupport::Concern
  
    included do
      # Common validations
      validates :population_capacity, numericality: { greater_than_or_equal_to: 0 }
      validates :current_population, numericality: { greater_than_or_equal_to: 0 }
    end
  
    # Methods for managing population
    def add_population(amount)
      return false if current_population + amount > population_capacity
  
      self.current_population += amount
      true
    end
  
    def remove_population(amount)
      return false if current_population - amount < 0
  
      self.current_population -= amount
      true
    end
  
    # Check if there's enough capacity
    def has_capacity_for?(amount)
      current_population + amount <= population_capacity
    end
  
    # Resource allocation per person (e.g., food, water, etc.)
    def resource_requirements
      {
        food: current_population * food_per_person,
        water: current_population * water_per_person,
        energy: current_population * energy_per_person
      }
    end
  
    # Operational costs calculation
    def operational_costs
      current_population * daily_maintenance_cost_per_person
    end
  end
  