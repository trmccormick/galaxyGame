class RockyBodyService
  attr_reader :body
  
  def initialize(body)
    @body = body
  end
  
  # Calculate erosion rate based on multiple environmental factors
  def calculate_erosion_rate
    return 0 unless body.hydrosphere.present? && body.atmosphere.present?
    
    # Get the total liquid coverage from the hydrosphere
    liquid_coverage = body.hydrosphere.state_distribution&.dig('liquid').to_f
    
    # Get primary liquid type
    primary_liquid = determine_primary_liquid
    
    # Atmospheric factors
    wind_factor = body.atmosphere.pressure.to_f / 101.3 # Normalized to Earth pressure
    precipitation = body.atmosphere.precipitation_rate.to_f
    
    # Temperature variation enhances erosion through freeze-thaw cycles
    temp_variation = body.atmosphere.temperature_variation.to_f
    
    # Calculate liquid erosivity factor - different liquids erode differently
    liquid_erosivity = case primary_liquid
                       when 'water' then 1.0 # baseline
                       when 'methane', 'ethane' then 0.6 # less erosive
                       when 'ammonia' then 0.8
                       when 'sulfuric_acid' then 1.4 # more erosive
                       else 0.7 # default for unknown liquids
                       end
    
    # Base erosion rate in mm/year
    base_rate = 0.01
    
    # Combined calculation
    liquid_effect = liquid_coverage / 100.0 * liquid_erosivity
    weather_effect = (wind_factor * 0.3) + (precipitation * 0.5)
    cycle_effect = 1.0 + (temp_variation / 100.0)
    
    erosion_rate = base_rate * (liquid_effect + weather_effect) * cycle_effect
    
    # Apply gravity adjustment - higher gravity leads to more erosion
    gravity_factor = body.gravity.present? ? (body.gravity / 9.8) : 1.0
    erosion_rate *= [gravity_factor, 0.2].max
    
    # Cap at reasonable maximum
    [erosion_rate, 1.0].min
  end
  
  # Calculate chemical weathering rate
  def calculate_weathering_rate
    return 0 unless body.atmosphere.present? && body.atmosphere.gases.present?
    
    # Check for atmosphere and liquid coverage
    has_atmosphere = body.atmosphere.pressure.to_f > 0.01
    liquid_coverage = body.hydrosphere&.state_distribution&.dig('liquid').to_f || 0
    
    return 0 unless has_atmosphere
    
    # Initialize material lookup service
    material_service = Lookup::MaterialLookupService.new
    
    # Calculate reactivity factor from atmosphere
    reactivity_score = 0
    total_percentage = 0
    
    body.atmosphere.gases.each do |gas|
      # Look up material data for the gas
      material_data = material_service.find_material(gas.name)
      
      if material_data
        # Get reactivity from material properties, with fallbacks
        reactivity = material_data.dig('properties', 'reactivity') || 
                    default_reactivity_for(gas.name) || 
                    0.5  # Default value if not found
        
        reactivity_score += gas.percentage.to_f * reactivity
        total_percentage += gas.percentage.to_f
      end
    end
    
    # Normalize reactivity score (0-1 scale)
    reactivity_factor = total_percentage > 0 ? (reactivity_score / total_percentage) / 2.0 : 0.1
    
    # Temperature effects - chemical reactions double every 10°C increase (rule of thumb)
    temp_factor = if body.surface_temperature.present?
                    reference_temp = 288 # 15°C in Kelvin
                    temp_diff = body.surface_temperature - reference_temp
                    2.0 ** (temp_diff / 10.0)
                  else
                    1.0
                  end
    
    # Cap temperature factor to reasonable range
    temp_factor = [[temp_factor, 0.1].max, 10.0].min
    
    # Liquid effect - more liquid = more weathering
    liquid_factor = 0.2 + (liquid_coverage / 100.0 * 0.8)
    
    # Calculate weathering rate (mm/year)
    base_rate = 0.002 # baseline weathering rate
    weathering_rate = base_rate * reactivity_factor * temp_factor * liquid_factor
    
    # Scale by gravity (higher gravity = slightly faster weathering due to pressure effects)
    gravity_factor = body.gravity.present? ? (body.gravity / 9.8) ** 0.3 : 1.0
    weathering_rate *= gravity_factor
    
    # Cap at reasonable maximum
    [weathering_rate, 0.1].min
  end
  
  # Assess potential for plate tectonics
  def potential_for_plate_tectonics
    # Key factors for plate tectonics:
    # 1. Internal heat (mass-related)
    # 2. Presence of a liquid layer under the crust
    # 3. Thickness of the crust
    # 4. Planet's age (younger = more likely)
    
    # Without mass or radius, we can't make a good estimate
    return 0 unless body.mass.present? && body.radius.present?
    
    # Calculate mass factor - need sufficient mass for internal heat
    earth_mass = 5.972e24 # kg
    mass_ratio = body.mass / earth_mass
    
    # Mass-size relationship affects internal heat
    earth_radius = 6.371e6 # meters
    radius_ratio = body.radius / earth_radius
    
    # Density affects composition and layering
    density = body.mass / ((4/3) * Math::PI * body.radius**3)
    density_factor = density / 5500.0 # Earth's density ~5500 kg/m³
    
    # Age factor - younger planets have more heat
    age_factor = if body.age.present?
                   [1.0 - (body.age / 10.0e9), 0.1].max
                 else
                   0.5 # Default if age unknown
                 end
    
    # Calculate potential score
    heat_potential = mass_ratio * density_factor / radius_ratio
    
    # Cap heat potential to a reasonable range (0-2)
    heat_potential = [[heat_potential, 0.1].max, 2.0].min
    
    # Calculate tectonic potential
    tectonic_potential = 50.0 * (
      heat_potential * 0.5 + 
      age_factor * 0.3 + 
      density_factor * 0.2
    )
    
    # Special case: if body has a known molten layer, increase potential
    if body.geosphere&.mantle_state == 'liquid' || body.geosphere&.mantle_state == 'partially_molten'
      tectonic_potential *= 1.5
    end
    
    # Cap at 100
    [tectonic_potential, 100.0].min
  end
  
  # Calculate volcanic activity potential
  def volcanic_activity_potential
    # Similar factors to plate tectonics but focused on volcanic processes
    tectonic_score = potential_for_plate_tectonics
    
    # Additional volcanic factors
    has_volatile_compounds = body.geosphere&.mantle_composition&.any? do |material, _|
      ['water', 'co2', 'sulfur', 'methane'].include?(material.downcase)
    end
    
    # Having volatiles in mantle increases explosive volcanism
    volatile_factor = has_volatile_compounds ? 1.3 : 1.0
    
    # Gravity affects magma ascent
    gravity_factor = if body.gravity.present?
                       gravity_ratio = body.gravity / 9.8
                       # Higher gravity makes it harder for magma to reach surface
                       1.0 / (0.5 + gravity_ratio * 0.5)
                     else
                       1.0
                     end
    
    # Calculate volcanic potential
    volcanic_potential = tectonic_score * 0.7 * volatile_factor * gravity_factor
    
    # Special case: if we know there's active volcanism, reflect that
    if body.geosphere&.volcanic_activity_level.present?
      known_activity = body.geosphere.volcanic_activity_level.to_f
      # Blend calculated with known values (70% known, 30% calculated)
      volcanic_potential = (known_activity * 0.7) + (volcanic_potential * 0.3)
    end
    
    # Cap at 100
    [volcanic_potential, 100.0].min
  end
  
  # Estimate atmospheric retention ability
  def atmospheric_retention_ability
    # Key factors:
    # 1. Gravity - higher gravity retains atmosphere better
    # 2. Distance from star - affects temperature
    # 3. Magnetic field - protects from stellar wind
    
    return 0 unless body.gravity.present?
    
    # Gravity factor - most important
    gravity_factor = (body.gravity / 9.8) ** 1.5
    
    # Magnetic field protection factor
    magnetic_protection = if body.respond_to?(:has_magnetic_field?) && body.has_magnetic_field?
                            1.5
                          else
                            1.0
                          end
    
    # Temperature factor - hotter bodies lose atmosphere faster
    temp_factor = if body.surface_temperature.present?
                    escape_temp = body.surface_temperature / 20.0
                    escape_factor = Math.exp(-escape_temp / 50.0)
                    [[escape_factor, 0.1].max, 1.0].min
                  else
                    0.8
                  end
    
    # Solar wind factor
    solar_wind_factor = if body.solar_system&.stars&.any?
                          star_type = body.solar_system.stars.first.spectral_type
                          
                          # More active stars create stronger stellar winds
                          case star_type[0]
                          when 'O', 'B' then 0.5 # Strong stellar wind
                          when 'A' then 0.7
                          when 'F' then 0.8
                          when 'G' then 1.0 # Solar-like
                          when 'K' then 1.1
                          when 'M' then 1.2 # Weak stellar wind
                          else 1.0
                          end
                        else
                          1.0
                        end
    
    # Calculate retention ability (0-100 scale)
    retention = 50.0 * gravity_factor * magnetic_protection * temp_factor * solar_wind_factor
    
    # Cap at reasonable limits
    [[retention, 10.0].max, 100.0].min
  end
  
  # Calculate core size and state
  def estimate_core_properties
    return {} unless body.mass.present? && body.radius.present?
    
    # Density calculation
    volume = (4.0/3.0) * Math::PI * (body.radius ** 3)
    density = body.mass / volume
    
    # Core size estimate
    # For Earth-like planets, core is about 30% of volume
    # Higher density planets tend to have larger cores
    density_ratio = density / 5500.0 # Earth's density
    core_volume_fraction = 0.3 * density_ratio
    core_radius_fraction = core_volume_fraction ** (1.0/3.0)
    core_radius = body.radius * core_radius_fraction
    
    # Core state estimate
    # Depends on mass, age, and composition
    earth_mass = 5.972e24
    mass_ratio = body.mass / earth_mass
    
    # Larger planets retain heat longer
    heat_retention = mass_ratio ** 0.5
    
    # Age affects cooling
    age_factor = if body.age.present?
                   [1.0 - (body.age / 10.0e9), 0.1].max
                 else
                   0.5
                 end
    
    # Estimate core temperature
    # Earth's core temperature ~5500K
    estimated_core_temp = 5500 * heat_retention * age_factor
    
    # Iron melting point ~1538°C (1811K)
    core_state = if estimated_core_temp > 1811
                   'molten'
                 elsif estimated_core_temp > 1200
                   'partially_molten'
                 else
                   'solid'
                 end
    
    {
      core_radius: core_radius.round,
      core_volume_fraction: (core_volume_fraction * 100).round(1),
      estimated_temperature: estimated_core_temp.round,
      estimated_state: core_state,
      composition: estimate_core_composition
    }
  end
  
  private
  
  def determine_primary_liquid
    return nil unless body.hydrosphere&.composition
    
    # Find the liquid with highest percentage
    body.hydrosphere.composition.max_by { |liquid, percentage| percentage.to_f }&.first
  end
  
  def estimate_core_composition
    # Estimate based on planet type, density, and known information
    if body.geosphere&.core_composition.present?
      return body.geosphere.core_composition
    end
    
    # Default iron-nickel composition similar to Earth
    # Varies slightly based on density
    density = if body.mass.present? && body.radius.present?
                volume = (4.0/3.0) * Math::PI * (body.radius ** 3)
                body.mass / volume
              else
                5500 # Earth-like default
              end
    
    # Adjust iron content based on density
    iron_content = 65 + ((density - 5500) / 1000 * 10)
    iron_content = [[iron_content, 40].max, 90].min
    
    nickel_content = 25
    remainder = 100 - iron_content - nickel_content
    
    {
      'iron' => iron_content,
      'nickel' => nickel_content,
      'sulfur' => remainder * 0.6,
      'other' => remainder * 0.4
    }
  end
  
  # Fallback method for well-known gases if property isn't in JSON
  def default_reactivity_for(gas_name)
    defaults = {
      'CO2' => 1.0,   # Baseline - forms carbonic acid
      'SO2' => 1.5,   # Forms sulfuric acid - stronger weathering
      'NO2' => 1.2,   # Forms nitric acid
      'O2' => 0.8,    # Oxidation reactions
      'Cl2' => 1.7,   # Very reactive
      'F2' => 2.0     # Extremely reactive
    }
    defaults[gas_name]
  end
end