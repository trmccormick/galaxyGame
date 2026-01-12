# ------------------------------------------------------------------------------
# 3. LIFE FORM DEPLOYMENT - Tracks a life form on a specific world
# ------------------------------------------------------------------------------
module Biology
  class LifeFormDeployment < ApplicationRecord
    belongs_to :biosphere, class_name: 'CelestialBodies::Spheres::Biosphere'
    belongs_to :life_form
    
    validates :coverage_percentage, numericality: { 
      greater_than_or_equal_to: 0, 
      less_than_or_equal_to: 100 
    }
    
    enum status: {
      thriving: 0,      # Ideal conditions, expanding
      stable: 1,        # Maintaining current coverage
      struggling: 2,    # Conditions marginal, may decline
      dying: 3,         # Actively losing coverage
      extinct: 4        # Coverage reached 0
    }
    
    # What's preventing this species from thriving?
    store_accessor :deployment_data,
      :limiting_factors,     # array: [:temperature, :pressure, :atmosphere]
      :deployment_date,      # game timestamp
      :adaptation_progress   # 0-100, if species is adapting
    
    scope :active, -> { where.not(status: :extinct) }
    
    # Simple growth/decline logic based on conditions
    def update_status_and_coverage(habitability_check)
      if habitability_check[:viable]
        # Thriving: slowly expand up to ecological limits
        self.status = :thriving
        max_coverage = calculate_max_coverage
        if coverage_percentage < max_coverage
          self.coverage_percentage = [coverage_percentage * 1.1, max_coverage].min
        end
      elsif habitability_check[:survival_probability] > 0.5
        # Struggling but surviving
        self.status = :struggling
        self.coverage_percentage *= 0.95 # Slow decline
        self.limiting_factors = habitability_check[:limiting_factors]
        
        # Check if can adapt
        if life_form.adaptation_potential > 50 && rand(100) < life_form.adaptation_potential
          self.adaptation_progress = (adaptation_progress || 0) + 10
          if adaptation_progress >= 100
            adapt_to_conditions!
          end
        end
      else
        # Dying
        self.status = :dying
        self.coverage_percentage *= 0.8 # Rapid decline
        self.limiting_factors = habitability_check[:limiting_factors]
      end
      
      # Check for extinction
      if coverage_percentage < 0.01
        self.status = :extinct
        self.coverage_percentage = 0
      end
      
      save!
    end
    
    private
    
    def calculate_max_coverage
      # Complex ecosystems need other species to reach high coverage
      species_count = biosphere.life_form_deployments.active.count
        
        base_max = case life_form.complexity.to_s # Use the complexity enum
                  when 'microbial' then 30.0
                  when 'simple' then 40.0 # Hardy Lichen, simple plants
                  when 'complex' then 60.0 # Trees, animals
                  when 'intelligent' then 70.0 # Maximum theoretical coverage
                  else 25.0
                  end
        
        # Each additional species type raises the ceiling
        base_max + (species_count * 5.0)
    end
    
    def adapt_to_conditions!
      # Create an adapted variant
      adapted_life_form = Biology::LifeForm.create!(
        name: "#{life_form.name} (Adapted)",
        life_form_type: life_form.life_form_type,
        parent_species: life_form,
        
        # Copy effects
        oxygen_production: life_form.oxygen_production,
        co2_consumption: life_form.co2_consumption,
        nitrogen_fixation: life_form.nitrogen_fixation,
        soil_improvement: life_form.soil_improvement,
        
        # Expand tolerances based on current conditions
        min_temperature: [life_form.min_temperature, biosphere.celestial_body.surface_temperature - 20].min,
        max_temperature: [life_form.max_temperature, biosphere.celestial_body.surface_temperature + 20].max,
        
        genetic_stability: life_form.genetic_stability - 10, # Less stable after adapting
        adaptation_potential: life_form.adaptation_potential - 20 # Harder to adapt again
      )

      # NEW: Record the parent-child lineage
      Biology::LifeFormParent.create!(
        parent: life_form, 
        child: adapted_life_form
      )      
      
      # Switch this deployment to the new adapted species
      update!(
        life_form: adapted_life_form,
        adaptation_progress: 0,
        status: :stable
      )
    end
  end
end
