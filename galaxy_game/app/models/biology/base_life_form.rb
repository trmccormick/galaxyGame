# File: app/models/biology/base_life_form.rb
module Biology
  class BaseLifeForm < ApplicationRecord
    self.abstract_class = false
    self.table_name = 'biology_life_forms'

    belongs_to :origin_planet, class_name: 'CelestialBodies::Planet', optional: true
    belongs_to :biosphere, class_name: 'CelestialBodies::Spheres::Biosphere'

    validates :name, presence: true
    validates :population, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    enum complexity: { microbial: 0, simple: 1, complex: 2, intelligent: 3 }
    enum domain: { aquatic: 0, terrestrial: 1, aerial: 2, subterranean: 3 }

    # UPDATED: Add terraforming and simulation properties
    store_accessor :properties, 
      # Existing properties
      :diet, :prey_for, :description, :biochemistry, :ecological_role,
      :reproduction_mode, :lifespan, :resistance_traits,
      
      # NEW: Terraforming effects (per day, per billion organisms)
      :oxygen_production_rate,      # kg/day per billion organisms
      :co2_consumption_rate,         # kg/day per billion organisms
      :methane_production_rate,      # kg/day per billion organisms (greenhouse gas)
      :nitrogen_fixation_rate,       # kg/day per billion organisms
      :soil_improvement_rate,        # quality points/day per billion organisms
      
      # NEW: Simulation properties (used by BiosphereSimulationService)
      :preferred_biome,              # string - which biome this species lives in
      :size_modifier,                # float - affects carrying capacity
      :reproduction_rate,            # float - birth rate
      :mortality_rate,               # float - death rate
      :health_modifier,              # float - current health/fitness
      :consumption_rate,             # float - food needed
      :mass,                         # kg - individual mass
      :foraging_efficiency,          # float - for herbivores
      :hunting_efficiency            # float - for carnivores

    has_many :parent_relations, class_name: 'Biology::LifeFormParent', foreign_key: 'child_id', dependent: :destroy
    has_many :parents, through: :parent_relations, source: :parent
    has_many :child_relations, class_name: 'Biology::LifeFormParent', foreign_key: 'parent_id', dependent: :destroy
    has_many :children, through: :child_relations, source: :child

    def simulate_growth
      actual_base_rate = _calculate_base_growth_rate
      habitability_factor = if biosphere&.respond_to?(:habitable_ratio)
                            biosphere.habitable_ratio
                          else
                            1.0
                          end

      self.population = ((population || 0) * actual_base_rate * habitability_factor).to_i
      save
    end

    def total_biomass
      (population || 0) * calculate_individual_mass
    end

    # NEW: Calculate atmospheric contribution from this life form
    def atmospheric_contribution
      return {} unless population && population > 0
      
      # Scale by population (normalize to billions)
      pop_scale = population / 1_000_000_000.0
      
      {
        o2: (properties['oxygen_production_rate'].to_f * pop_scale),
        co2: (properties['co2_consumption_rate'].to_f * pop_scale),
        ch4: (properties['methane_production_rate'].to_f * pop_scale),
        n2: (properties['nitrogen_fixation_rate'].to_f * pop_scale),
        soil: (properties['soil_improvement_rate'].to_f * pop_scale)
      }
    end

    def type_identifier
      raise NotImplementedError, "Subclasses must implement #type_identifier"
    end

    protected
    
    def calculate_individual_mass
      case complexity.to_s
      when 'microbial', '0' then 0.000001
      when 'simple', '1' then 0.01
      when 'complex', '2' then 1.0
      when 'intelligent', '3' then 50.0
      else 1.0
      end
    end

    def _calculate_base_growth_rate
      case complexity
      when 'microbial' then 1.5
      when 'simple' then 1.2
      when 'complex' then 1.1
      when 'intelligent' then 1.05
      else 1.0
      end
    end
  end
end
