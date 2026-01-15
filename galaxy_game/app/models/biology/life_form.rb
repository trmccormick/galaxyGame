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
    
    # NEW: Population growth model
    def simulate_growth(conditions = {})
      return if population.nil? || population <= 0
      
      # Get environmental conditions
      temp = conditions[:temperature] || biosphere&.celestial_body&.surface_temperature || 250.0
      o2_pct = conditions[:o2_percentage] || 0.0
      co2_pct = conditions[:co2_percentage] || 95.0
      
      # Calculate growth rate based on suitability
      growth_rate = calculate_growth_rate(temp, o2_pct, co2_pct)
      
      # Calculate carrying capacity
      carrying_capacity = calculate_carrying_capacity
      
      # Logistic growth equation: dN/dt = rN(1 - N/K)
      crowding_factor = 1.0 - (population.to_f / carrying_capacity)
      crowding_factor = [crowding_factor, 0.0].max  # Don't go negative
      
      population_change = (population * growth_rate * crowding_factor).to_i
      
      # Apply change
      new_population = population + population_change
      
      # Bounds checking
      new_population = [[new_population, 0].max, carrying_capacity].min
      
      self.population = new_population
      save!
      
      puts "  #{name}: pop #{population} (Δ#{population_change}, rate=#{(growth_rate * 100).round(2)}%)"
    end
    
    private
    
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
    
    def calculate_growth_rate(temperature, o2_percentage, co2_percentage)
      # Base growth rate: 1% per day (conservative)
      base_rate = 0.01
      
      # Temperature suitability
      min_temp = get_property('min_temperature', 170.0)
      max_temp = get_property('max_temperature', 320.0)
      optimal_temp = (min_temp + max_temp) / 2.0
      
      temp_suitability = if temperature < min_temp || temperature > max_temp
        0.0  # Outside tolerance = death
      else
        # Gaussian curve around optimal temperature
        temp_diff = (temperature - optimal_temp).abs
        temp_range = (max_temp - min_temp) / 2.0
        Math.exp(-(temp_diff**2) / (2 * (temp_range / 3.0)**2))
      end
      
      # Oxygen suitability (for aerobic organisms)
      diet_type = get_property('diet', 'photosynthetic')
      
      o2_suitability = case diet_type
      when 'photosynthetic'
        # Photosynthetic organisms produce O2, need CO2
        co2_percentage > 0.1 ? 1.0 : 0.5
      when 'chemosynthetic'
        # Don't need much O2
        0.8
      else
        # Aerobic organisms need O2
        if o2_percentage < 0.1
          o2_percentage / 0.1  # Scale up to 0.1%
        elsif o2_percentage < 10.0
          1.0
        else
          [2.0 - (o2_percentage / 20.0), 0.5].max  # Too much O2 is bad
        end
      end
      
      # Combined rate
      combined_rate = base_rate * temp_suitability * o2_suitability
      
      # Apply population health modifier if present
      health = get_property('health_modifier', 1.0)
      combined_rate * health
    end
    
    def calculate_carrying_capacity
      # Base carrying capacity on biosphere size
      return 1_000_000_000 unless biosphere
      
      # Get biosphere metrics
      habitable_ratio = biosphere.habitable_ratio || 0.1
      planet_radius = biosphere.celestial_body.radius || 3_389_500  # Mars default
      
      # Calculate habitable surface area (m²)
      total_surface = 4 * Math::PI * (planet_radius ** 2)
      habitable_surface = total_surface * habitable_ratio
      
      # Carrying capacity based on organism type and size
      complexity_val = self.complexity&.downcase || 'simple'
      
      organisms_per_km2 = case complexity_val
      when 'simple', 'microbial'
        1_000_000_000  # 1 billion per km²
      when 'complex'
        1_000_000      # 1 million per km²
      when 'intelligent'
        10_000         # 10k per km²
      else
        10_000_000     # 10 million per km²
      end
      
      # Convert surface area to km² and multiply
      habitable_km2 = habitable_surface / 1_000_000.0
      capacity = (habitable_km2 * organisms_per_km2).to_i
      
      # Minimum capacity
      [capacity, 10_000_000].max
    end
    
    def get_property(key, default = nil)
      # Try direct accessor first
      if respond_to?(key)
        value = send(key)
        return value if value && value != 0
      end
      
      # Try properties hash
      if properties && properties[key]
        return properties[key]
      end
      
      default
    end
    
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