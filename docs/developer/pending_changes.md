# ==============================================================================
# File: app/models/biology/life_form.rb - IMPLEMENTED (Jan 15, 2026)
# ==============================================================================
# simulate_growth method now includes full environmental modeling with:
# - Temperature, O2/CO2 suitability calculations
# - Logistic growth with carrying capacity
# - Population bounds checking
# - Debug output for population changes
# ==============================================================================

module Biology
  class LifeForm < BaseLifeForm
    # ... existing code ...

    # IMPLEMENTED: Population growth model
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
    
    def calculate_growth_rate(temperature, o2_percentage, co2_percentage)
      # Base growth rate: 0.1% per day (conservative)
      base_rate = 0.001
      
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
      complexity = self.complexity&.downcase || 'simple'
      
      organisms_per_km2 = case complexity
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

    # ... rest of existing code ...
  end
end

# ==============================================================================
# File: app/models/celestial_bodies/spheres/biosphere.rb
# ADD THIS METHOD to calculate_habitability
# ==============================================================================

# Replace the existing calculate_habitability method with this improved version:
def calculate_habitability
  atmo = celestial_body&.atmosphere
  return 0.0 unless atmo && atmo.gases.exists?
  
  # Get environmental parameters
  o2_level = atmo.gases.find_by(name: 'O2')&.percentage.to_f
  pressure = atmo.pressure.to_f
  temp = celestial_body.surface_temperature.to_f
  
  # Get liquid water availability
  hydro = celestial_body.hydrosphere
  liquid_water_pct = hydro&.state_distribution&.dig('liquid').to_f || 0.0
  
  # === OXYGEN FACTOR ===
  # Need at least 0.1% O2 for complex life
  # Optimal: 10-21%
  # Toxic: >50%
  o2_factor = if o2_level < 0.1
    # Below minimum - scale from 0 to 1
    o2_level / 0.1
  elsif o2_level < 10.0
    # Building up to optimal
    0.5 + (o2_level / 20.0)
  elsif o2_level <= 21.0
    # Optimal range
    1.0
  elsif o2_level <= 50.0
    # Above optimal but not toxic
    1.0 - ((o2_level - 21.0) / 58.0)
  else
    # Toxic levels
    0.1
  end
  
  # === TEMPERATURE FACTOR ===
  # Mars: 210K is cold but microbes can survive
  # Optimal: 273-310K (0-37°C)
  temp_factor = if temp < 200
    # Too cold even for extremophiles
    0.0
  elsif temp < 250
    # Extreme cold - only extremophiles
    (temp - 200) / 50.0 * 0.3
  elsif temp < 273
    # Cold but survivable
    0.3 + ((temp - 250) / 23.0 * 0.3)
  elsif temp <= 310
    # Optimal temperature range
    1.0
  elsif temp < 350
    # Hot but survivable
    1.0 - ((temp - 310) / 40.0 * 0.5)
  else
    # Too hot
    0.1
  end
  
  # === PRESSURE FACTOR ===
  # Need at least 0.006 bar (Mars current)
  # Optimal: 0.5-2.0 bar
  pressure_factor = if pressure < 0.001
    0.0
  elsif pressure < 0.01
    # Very low pressure - only extremophiles
    pressure / 0.01 * 0.3
  elsif pressure < 0.5
    # Low pressure but increasing
    0.3 + ((pressure - 0.01) / 0.49 * 0.4)
  elsif pressure <= 2.0
    # Optimal pressure
    1.0
  elsif pressure < 5.0
    # High but tolerable
    1.0 - ((pressure - 2.0) / 3.0 * 0.3)
  else
    # Too high
    0.3
  end
  
  # === WATER FACTOR ===
  # Life needs liquid water
  water_factor = if liquid_water_pct < 0.1
    # Almost no liquid water
    liquid_water_pct / 0.1 * 0.2
  elsif liquid_water_pct < 1.0
    # Some liquid water
    0.2 + (liquid_water_pct / 1.0 * 0.3)
  else
    # Adequate liquid water
    [0.5 + (liquid_water_pct / 100.0 * 0.5), 1.0].min
  end
  
  # === COMBINED HABITABILITY ===
  # Weighted average with critical factors
  habitability = (
    o2_factor * 0.30 +        # 30% weight - critical for complex life
    temp_factor * 0.30 +       # 30% weight - critical for all life
    water_factor * 0.25 +      # 25% weight - essential for life
    pressure_factor * 0.15     # 15% weight - important but less critical
  )
  
  # Apply life presence bonus (bootstrapping effect)
  if life_forms.any? && life_forms.sum(:population) > 1_000_000
    life_bonus = [life_forms.count * 0.02, 0.1].min  # Up to 10% bonus
    habitability = [habitability + life_bonus, 1.0].min
  end
  
  self.habitable_ratio = habitability
  save!
  
  puts "  Habitability: #{(habitability * 100).round(2)}% " \
       "(O2:#{(o2_factor * 100).round(0)}% Temp:#{(temp_factor * 100).round(0)}% " \
       "H2O:#{(water_factor * 100).round(0)}% P:#{(pressure_factor * 100).round(0)}%)"
  
  habitability
end

# ==============================================================================
# File: app/services/terra_sim/biosphere_simulation_service.rb
# ADD THIS METHOD CALL in simulate()
# ==============================================================================

def simulate(time_skipped = 1)
  return if @simulation_in_progress
  @simulation_in_progress = true
  return unless @biosphere
  
  @time_skipped = time_skipped
  
  calculate_biosphere_conditions
  simulate_ecosystem_interactions
  
  # NEW: Add population dynamics
  simulate_population_dynamics(time_skipped)
  
  track_species_population
  manage_food_web
  balance_biomes 
  influence_atmosphere(time_skipped)
  
  # NEW: Update habitability at end
  @biosphere.calculate_habitability

  @simulation_in_progress = false
end

# NEW: Add this method to BiosphereSimulationService
def simulate_population_dynamics(time_skipped)
  return unless @biosphere.life_forms.any?
  
  puts "Simulating population dynamics for #{@biosphere.life_forms.count} species"
  
  # Get current environmental conditions
  conditions = {
    temperature: @celestial_body.surface_temperature,
    o2_percentage: @atmosphere.gas_percentage('O2'),
    co2_percentage: @atmosphere.gas_percentage('CO2')
  }
  
  # Simulate growth for each species
  @biosphere.life_forms.each do |life_form|
    # Scale iterations by time_skipped
    # For long simulations, don't iterate thousands of times
    iterations = [time_skipped, 365].min
    
    iterations.times do
      life_form.simulate_growth(conditions)
    end
  end
end