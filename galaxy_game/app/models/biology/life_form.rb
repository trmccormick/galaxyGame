# ==============================================================================
# File: app/models/biology/life_form.rb - COMPLETE FILE
# ==============================================================================
module Biology
  class LifeForm < BaseLifeForm
    # Add simulation attributes to properties JSONB
    store_accessor :properties, :atmospheric_effects, :biomass_kg, :efficiency, :min_temperature, :max_temperature, :min_oxygen, :max_oxygen

    def type_identifier
      "natural"
    end
    
    def adapt_to_environment(environment_changes)
      adaptation_score = environment_changes.values.sum / environment_changes.size.to_f
      
      if adaptation_score < 0.3
        self.population = (population * 0.8).to_i
      elsif adaptation_score > 0.7
        self.population = (population * 1.2).to_i
      end
      
      save
    end
    
    # Food availability calculation - FIXED to use .find instead of .where
    def calculate_food_availability
      case properties['diet']
      when 'herbivore'
        100
      when 'carnivore'
        if biosphere && prey_for.any?
          prey_type = prey_for.first
          # Use .find instead of .where since diet is in properties JSONB
          prey = biosphere.life_forms.find { |lf| lf.properties['diet'] == prey_type }
          return (prey&.population || 0) / 2
        end
        50
      when 'photosynthetic'
        nil
      else
        nil
      end
    end

    # Environmental impact returns hash
    def environmental_impact
      pop = population || 0
      # Read rates from both accessors and properties, preferring accessor if set
      o2_rate = properties['o2_production_rate'].nil? ? self.o2_production_rate : properties['o2_production_rate'].to_f
      co2_rate = properties['co2_production_rate'].nil? ? self.co2_production_rate : properties['co2_production_rate'].to_f
      soil_rate = properties['soil_improvement_rate'].nil? ? self.soil_improvement_rate : properties['soil_improvement_rate'].to_f

      diet_value = (!self.diet.nil? ? self.diet : properties['diet'])

      o2_change = (o2_rate.to_f * pop).to_i
      co2_change = (co2_rate.to_f * pop).to_i
      soil_change = (diet_value == 'decomposer' ? (soil_rate.to_f * pop / 10000.0) : 0)

      {
        oxygen_change: o2_change,
        co2_change: co2_change,
        methane_change: 0,
        nitrogen_change: 0,
        soil_quality_change: soil_change
      }
    end

    # NEW: Calculate atmospheric contribution scaled by population
    # This is what BiosphereSimulationService.calculate_life_form_atmospheric_effects calls
    def atmospheric_contribution
      return zero_contribution if population.nil? || population <= 0
      
      # Scale factor: normalize population to billions for reasonable scaling
      # (1 billion organisms = 1.0 scale factor)
      population_scale = population / 1_000_000_000.0
      
      # Get rates from properties (preferring direct accessors if available)
      o2_rate = get_rate('oxygen_production_rate', 'o2_production_rate')
      co2_rate = get_rate('co2_consumption_rate')
      ch4_rate = get_rate('methane_production_rate', 'ch4_production_rate')
      n2_rate = get_rate('nitrogen_fixation_rate')
      soil_rate = get_rate('soil_improvement_rate')
      
      {
        o2: o2_rate * population_scale,
        co2: co2_rate * population_scale,
        ch4: ch4_rate * population_scale,
        n2: n2_rate * population_scale,
        soil: soil_rate * population_scale
      }
    end

    # Interaction with other life forms
    def interact_with
      case properties['diet']
      when 'herbivore'
        self.population = [population - 1, 0].max
        save
      when 'carnivore'
        self.population = population + 1
        save
      end
      true
    end
    
    # Ensure prey_for is always an array
    def prey_for
      value = super
      value.is_a?(Array) ? value : (value.nil? ? [] : [value])
    end
    
    protected
    
    def calculate_individual_mass
      return super unless properties.present?
      
      individual_mass = properties['individual_mass'].to_f
      biomass = properties['biomass'].to_f
      mass = properties['mass'].to_f
      
      custom_mass = individual_mass > 0 ? individual_mass : 
                    biomass > 0 ? biomass : 
                    mass > 0 ? mass : nil
      
      custom_mass || super
    end
    
    private
    
    # Helper to get rate from properties with fallback names
    def get_rate(*property_names)
      property_names.each do |prop_name|
        # Try accessor first
        value = send(prop_name) if respond_to?(prop_name)
        return value.to_f if value && value.to_f != 0.0
        
        # Try properties hash
        value = properties[prop_name]
        return value.to_f if value && value.to_f != 0.0
      end
      
      0.0
    end
    
    def zero_contribution
      { o2: 0.0, co2: 0.0, ch4: 0.0, n2: 0.0, soil: 0.0 }
    end
  end
end