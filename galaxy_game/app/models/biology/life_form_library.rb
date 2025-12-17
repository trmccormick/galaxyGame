# File: app/models/biology/life_form_library.rb

module Biology
  class LifeFormLibrary
    # Creates standard terraforming organisms that can be deployed
    
    def self.cyanobacteria(biosphere)
      LifeForm.find_or_create_by!(name: 'Cyanobacteria (Early Earth Type)', biosphere: biosphere) do |lf|
        lf.complexity = :microbial
        lf.domain = :aquatic
        lf.population = 1_000_000_000  # Start with 1 billion
        
        # Terraforming properties (per day, per billion organisms)
        lf.oxygen_production_rate = 0.1        # 0.1 kg O2 per day per billion
        lf.co2_consumption_rate = 0.15         # consumes 0.15 kg CO2 per day
        
        # Simulation properties
        lf.preferred_biome = 'Ocean'
        lf.size_modifier = 0.000001
        lf.reproduction_rate = 1.5
        lf.mortality_rate = 1.0
        lf.health_modifier = 1.0
        lf.diet = 'photosynthetic'
        
        # Description
        lf.description = 'Oxygen-producing photosynthetic bacteria, very hardy. Early Earth type organism.'
        lf.biochemistry = 'Carbon-based'
        lf.ecological_role = 'Primary producer'
      end
    end
    
    def self.nitrogen_fixer(biosphere)
      LifeForm.find_or_create_by!(name: 'Nitrogen-Fixing Bacteria', biosphere: biosphere) do |lf|
        lf.complexity = :microbial
        lf.domain = :terrestrial
        lf.population = 500_000_000
        
        # Terraforming properties
        lf.nitrogen_fixation_rate = 0.08
        lf.soil_improvement_rate = 0.02
        
        # Simulation properties
        lf.preferred_biome = 'Grassland'
        lf.size_modifier = 0.000001
        lf.reproduction_rate = 1.3
        lf.mortality_rate = 1.0
        lf.health_modifier = 1.0
        lf.diet = 'chemosynthetic'
        
        lf.description = 'Converts atmospheric nitrogen to usable form, improves soil fertility'
        lf.biochemistry = 'Carbon-based'
        lf.ecological_role = 'Nitrogen fixer'
      end
    end
    
    def self.methane_producer(biosphere)
      LifeForm.find_or_create_by!(name: 'Methanogenic Archaea', biosphere: biosphere) do |lf|
        lf.complexity = :microbial
        lf.domain = :subterranean
        lf.population = 2_000_000_000
        
        # Terraforming properties - produces greenhouse gas
        lf.methane_production_rate = 0.05
        lf.co2_consumption_rate = 0.03
        
        # Simulation properties
        lf.preferred_biome = 'Wetland'
        lf.size_modifier = 0.000001
        lf.reproduction_rate = 1.4
        lf.mortality_rate = 0.9
        lf.health_modifier = 1.0
        lf.diet = 'decomposer'
        
        lf.description = 'Produces methane for greenhouse warming. Useful for cold planets.'
        lf.biochemistry = 'Carbon-based'
        lf.ecological_role = 'Decomposer'
      end
    end
    
    def self.hardy_lichen(biosphere)
      LifeForm.find_or_create_by!(name: 'Extremophile Lichen', biosphere: biosphere) do |lf|
        lf.complexity = :simple
        lf.domain = :terrestrial
        lf.population = 100_000_000
        
        # Terraforming properties
        lf.oxygen_production_rate = 0.05
        lf.co2_consumption_rate = 0.06
        lf.soil_improvement_rate = 0.015
        
        # Simulation properties
        lf.preferred_biome = 'Tundra'
        lf.size_modifier = 0.0001
        lf.reproduction_rate = 1.1
        lf.mortality_rate = 0.8
        lf.health_modifier = 1.0
        lf.diet = 'photosynthetic'
        
        lf.description = 'Extremely hardy organism that can colonize bare rock. Survives extreme conditions.'
        lf.biochemistry = 'Carbon-based'
        lf.ecological_role = 'Pioneer species'
      end
    end
    
    def self.super_algae(biosphere)
      # An engineered organism for rapid terraforming
      HybridLifeForm.find_or_create_by!(name: 'Engineered Super-Algae', biosphere: biosphere) do |lf|
        lf.complexity = :simple
        lf.domain = :aquatic
        lf.population = 50_000_000
        
        # Boosted terraforming properties
        lf.oxygen_production_rate = 0.5        # 5x normal
        lf.co2_consumption_rate = 0.7
        
        # Engineered traits
        lf.engineered_traits = ['rapid_photosynthesis', 'high_yield']
        lf.creator_species = 'Human'
        
        # Simulation properties
        lf.preferred_biome = 'Ocean'
        lf.size_modifier = 0.00001
        lf.reproduction_rate = 1.6
        lf.mortality_rate = 1.2               # Less stable
        lf.health_modifier = 1.0
        lf.diet = 'photosynthetic'
        
        lf.description = 'Genetically engineered for rapid oxygen production. Less stable than natural organisms.'
        lf.biochemistry = 'Carbon-based (enhanced)'
        lf.ecological_role = 'Primary producer (engineered)'
      end
    end
    
    # Helper method to deploy all basic terraforming organisms
    def self.deploy_starter_ecosystem(biosphere)
      [
        cyanobacteria(biosphere),
        nitrogen_fixer(biosphere),
        hardy_lichen(biosphere)
      ]
    end
  end
end