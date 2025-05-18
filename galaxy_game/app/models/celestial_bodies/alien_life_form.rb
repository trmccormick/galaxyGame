module CelestialBodies
  class AlienLifeForm < ApplicationRecord
    # Set the table name to match what was created in the migration
    self.table_name = 'celestial_bodies_alien_life_forms'
    
    belongs_to :biosphere, class_name: 'CelestialBodies::Spheres::Biosphere'
    
    enum complexity: { microbial: 0, simple: 1, complex: 2, intelligent: 3 }
    enum domain: { aquatic: 0, terrestrial: 1, aerial: 2, subterranean: 3 }
    
    # Store description in JSONB
    store_accessor :properties, :description, :biochemistry, :ecological_role
    
    validates :name, presence: true
    validates :population, numericality: { greater_than_or_equal_to: 0 }
    
    # Example method for population growth simulation
    def simulate_growth
      growth_rate = calculate_growth_rate
      self.population = (population * growth_rate).to_i
      save
    end
    
    private
    
    def calculate_growth_rate
      # Base growth rate depends on complexity
      base_rate = case complexity
                  when 'microbial' then 1.5  # 50% growth per cycle
                  when 'simple' then 1.2     # 20% growth per cycle
                  when 'complex' then 1.1    # 10% growth per cycle
                  when 'intelligent' then 1.05 # 5% growth per cycle
                  end
      
      # Modify based on biosphere conditions
      habitability = biosphere.habitable_ratio
      base_rate * habitability
    end
  end
end