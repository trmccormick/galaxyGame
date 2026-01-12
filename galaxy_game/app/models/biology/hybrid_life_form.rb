# File: app/models/biology/hybrid_life_form.rb
module Biology
  class HybridLifeForm < BaseLifeForm
    def type_identifier
      "engineered"
    end
    
    # Add engineered traits
    store_accessor :properties, :engineered_traits, :creator_species
    
    # Food availability calculation - same as LifeForm
    def simulate_growth(_conditions = {})
      super()
    end

    def calculate_food_availability
      case properties['diet']
      when 'herbivore'
        100
      when 'carnivore'
        if biosphere && prey_for.any?
          prey_type = prey_for.first
          # Use find instead of where since diet is in JSONB
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

    # Environmental impact calculation - MUST return hash
    def environmental_impact
      pop = population || 0
      o2_rate = (self.o2_production_rate.nil? || self.o2_production_rate == 0) ? properties['o2_production_rate'].to_f : self.o2_production_rate
      co2_rate = (self.co2_production_rate.nil? || self.co2_production_rate == 0) ? properties['co2_production_rate'].to_f : self.co2_production_rate
      soil_rate = (self.soil_improvement_rate.nil? || self.soil_improvement_rate == 0) ? properties['soil_improvement_rate'].to_f : self.soil_improvement_rate

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

    # Interaction between life forms
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
    
    # Overrides the base rate calculation for engineered species
    def _calculate_base_growth_rate
      base_rate = super

      # Apply controls based on engineered traits
      if engineered_traits&.include?('growth_limited')
        base_rate = [base_rate, 1.1].min
      elsif engineered_traits&.include?('rapid_growth')
        base_rate *= 1.5
      end
      base_rate
    end
  end
end