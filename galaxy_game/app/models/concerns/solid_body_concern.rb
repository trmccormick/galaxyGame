module SolidBodyConcern
  extend ActiveSupport::Concern
  
  included do
    validates :radius, numericality: { greater_than: 0 }, allow_nil: true
  end
  
  # Add this method to access age from properties
  def age
    # Use age from properties if present, otherwise estimate based on parent star
    properties.try(:[], 'age') || estimate_age_from_star || 4.5e9
  end

  def estimate_age_from_star
    # If body belongs to a solar system with stars, use primary star's age
    if respond_to?(:solar_system) && solar_system&.primary_star
      solar_system.primary_star.age
    else
      nil
    end
  end
  
  def has_solid_surface?
    true
  end
  
  def surface_composition
    geosphere&.crust_composition || {}
  end
  
  def dominant_surface_feature
    return :unknown unless hydrosphere.present?
    
    # Instead of water_coverage, check for any liquid coverage
    liquid_coverage = total_liquid_coverage
    average_temperature = surface_temperature.to_f
    has_atmosphere = atmosphere&.gases&.any?
    
    case
    when liquid_coverage > 75
      :liquid_covered
    when liquid_coverage > 40
      :partially_liquid
    when average_temperature > determine_primary_liquid_boiling_point && has_atmosphere
      :vapor_world
    when average_temperature < determine_primary_liquid_freezing_point && liquid_coverage > 20
      :frozen_surface
    when average_temperature > 500
      :molten_surface
    when !has_atmosphere && average_temperature < 200
      :barren
    else
      :mixed_terrain
    end
  end
  
  # Get total coverage by any liquid
  def total_liquid_coverage
    return 0 unless hydrosphere&.state_distribution
    
    # Look for liquid state in state distribution
    hydrosphere.state_distribution['liquid'].to_f
  end
  
  # Determine primary liquid in the hydrosphere
  def primary_liquid
    return nil unless hydrosphere.present?
    
    # Method 1: Check composition field
    if hydrosphere.composition.present? && hydrosphere.composition.is_a?(Hash)
      # Find the liquid with highest percentage
      dominant = hydrosphere.composition.max_by { |liquid, percentage| percentage.to_f }
      if dominant && dominant.last.to_f > 0
        # Return the chemical formula, not the common name
        return normalize_liquid_name(dominant.first)
      end
    end
    
    # Method 2: Check actual liquid materials in the hydrosphere
    if hydrosphere.respond_to?(:materials)
      liquid_materials = hydrosphere.materials.where(location: 'hydrosphere', state: 'liquid')
      if liquid_materials.any?
        # Find the one with the most mass/amount
        dominant = liquid_materials.max_by { |mat| mat.amount.to_f }
        return normalize_liquid_name(dominant.name) if dominant
      end
    end
    
    # Method 3: Check liquid_bodies structure
    if hydrosphere.liquid_bodies.present? && hydrosphere.liquid_bodies.is_a?(Hash)
      # Look for keys that represent liquids (not ice_caps, groundwater, etc.)
      liquid_keys = hydrosphere.liquid_bodies.keys.reject do |key|
        ['ice_caps', 'groundwater', 'briny_flows', 'oceans', 'lakes', 'rivers'].include?(key)
      end
      
      if liquid_keys.any?
        # If there are explicit liquid type keys, use the first one
        return normalize_liquid_name(liquid_keys.first)
      end
      
      # Otherwise, check if we have volume data to infer the type
      has_liquid_volume = hydrosphere.liquid_bodies.values.any? do |body|
        body.is_a?(Hash) && body['volume'].to_f > 0
      end
      
      if has_liquid_volume
        # Default based on body name or temperature
        return infer_liquid_from_context
      end
    end
    
    # Method 4: Infer from context (body name, temperature)
    infer_liquid_from_context
  end
  
  def determine_primary_liquid_boiling_point
    liquid = primary_liquid
    return 373 unless liquid # Default to water's boiling point if unknown
    
    # Get material properties from lookup service
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(liquid)
    
    # Return boiling point or default to water's boiling point
    material_data&.dig('properties', 'boiling_point') || 373
  end
  
  def determine_primary_liquid_freezing_point
    liquid = primary_liquid
    return 273 unless liquid # Default to water's freezing point if unknown
    
    # Get material properties from lookup service
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(liquid)
    
    # Return freezing point or default to water's freezing point
    material_data&.dig('properties', 'freezing_point') || 273
  end
  
  def calculate_erosion_rate
    return 0 unless hydrosphere.present? && atmosphere.present?
    
    # Base erosion factors - now using liquid_coverage instead of water_coverage
    liquid_factor = total_liquid_coverage / 100.0
    wind_factor = atmosphere.pressure.to_f / 101.3 # Normalized to Earth pressure
    
    # Calculate based on environmental factors
    base_rate = 0.01 # mm/year
    erosion_rate = base_rate * (liquid_factor * 0.7 + wind_factor * 0.3)
    
    # Temperature cycles enhance erosion
    if atmosphere.temperature_variation && atmosphere.temperature_variation > 0
      temp_cycle_factor = atmosphere.temperature_variation / 50.0
      erosion_rate *= (1 + temp_cycle_factor)
    end
    
    # Adjust based on primary liquid properties
    liquid = primary_liquid
    if liquid
      lookup_service = Lookup::MaterialLookupService.new
      material_data = lookup_service.find_material(liquid)
      
      if material_data
        # Different liquids have different erosion capabilities
        # Water is more erosive than hydrocarbons, for example
        if liquid == 'water'
          erosion_rate *= 1.2
        elsif ['methane', 'ethane'].include?(liquid)
          erosion_rate *= 0.7
        end
      end
    end
    
    erosion_rate
  end
  
  def calculate_weathering_rate
    return 0 unless atmosphere.present? && atmosphere.gases.present?
    
    # Weathering depends on atmosphere composition
    acid_gases = ['CO2', 'SO2', 'NO2']
    acid_concentration = acid_gases.sum do |gas|
      atmosphere.gases.find_by(name: gas)&.percentage.to_f || 0
    end / 100.0
    
    # Weathering rate calculation
    base_rate = 0.005 # base rate per year
    humidity_factor = atmosphere.humidity.to_f / 100.0
    
    weathering_rate = base_rate * (1 + acid_concentration * 2) * (1 + humidity_factor)
    
    # Temperature effect - higher temp = faster reactions
    if surface_temperature && surface_temperature > 273
      temp_factor = (surface_temperature - 273) / 50.0
      weathering_rate *= (1 + [temp_factor, 1.0].min)
    end
    
    # Adjust based on primary liquid
    liquid = primary_liquid
    if liquid && liquid != 'water'
      # Non-water liquids generally cause less chemical weathering
      weathering_rate *= 0.6
    end
    
    weathering_rate
  end
  
  def estimate_core_size
    return nil unless radius.present? && density.present?
    
    # Estimate core radius as a percentage of total radius
    # Higher density generally means larger core relative to size
    density_factor = [density / 5.5, 0.2].max # 5.5 g/cm³ is Earth's density
    
    # Core size is roughly proportional to body size and density
    core_percentage = 0.5 * density_factor
    
    # Return estimated core radius in meters
    (radius * core_percentage).round
  end
  
  def surface_gravity
    return nil unless mass.present? && radius.present?
    
    # Calculate surface gravity using Newton's law of universal gravitation
    # g = G * M / r²
    g = GameConstants::GRAVITATIONAL_CONSTANT * mass / (radius ** 2)
    
    # Return in m/s²
    g
  end
  
  def has_magnetic_field?
    return false unless geosphere.present?
    
    # Factors that contribute to magnetic field:
    # 1. Molten metallic core
    # 2. Rotation (for dynamo effect)
    has_core = estimate_core_size.to_f > (radius.to_f * 0.15)
    rotates = rotational_period.to_f > 0
    
    if geosphere.core_composition.present?
      iron_content = geosphere.core_composition['iron'].to_f
      molten_core = geosphere.core_temperature.to_f > 1800 # Iron melting point ~1538°C
      
      has_core && rotates && iron_content > 30 && molten_core
    else
      # Estimate based on mass and rotation if no core composition data
      has_core && rotates && mass.to_f > 1.0e23
    end
  end
  
  def potential_for_volcanism
    return 0 unless geosphere.present?
    
    # Factors contributing to volcanism:
    # 1. Internal heat (related to mass)
    # 2. Geological activity
    # 3. Age (younger = more active)
    
    mass_factor = mass.present? ? [mass / 1.0e23, 0.1].max : 0.5
    geo_activity = geosphere.geological_activity.to_f / 100.0
    age_factor = age.present? ? [1.0 - (age / 10.0e9), 0.1].max : 0.5
    
    volcanism_potential = 50 * (mass_factor * 0.4 + geo_activity * 0.4 + age_factor * 0.2)
    [volcanism_potential, 100.0].min
  end
  
  def surface_features
    features = []
    
    # Add features based on surface composition and conditions
    if hydrosphere.present?
      liquid = primary_liquid
      
      if total_liquid_coverage > 10
        if ['methane', 'ethane'].include?(liquid)
          features << 'hydrocarbon pools'
        elsif liquid == 'water'
          features << 'lakes'
        else
          features << "#{liquid} pools"
        end
      end
      
      if total_liquid_coverage > 40
        if ['methane', 'ethane'].include?(liquid)
          features << 'hydrocarbon seas'
        elsif liquid == 'water'
          features << 'oceans'
        else
          features << "#{liquid} seas"
        end
      end
      
      # Check for frozen material
      if hydrosphere.state_distribution['solid'].to_f > 30
        if liquid == 'water'
          features << 'glaciers'
        else
          features << "frozen #{liquid}"
        end
      end
    end
    
    if geosphere.present?
      if geosphere.geological_activity.to_f > 60
        features << 'active volcanoes'
        features << 'mountain ranges'
      elsif geosphere.geological_activity.to_f > 30
        features << 'dormant volcanoes'
        features << 'hills'
      end
      
      if geosphere.regolith_depth.to_f > 10
        features << 'deep soil layers'
      elsif geosphere.regolith_depth.to_f > 1
        features << 'thin soil'
      else
        features << 'exposed bedrock'
      end
      
      if geosphere.tectonic_activity
        features << 'tectonic plates'
        features << 'fault lines'
      end
    end
    
    if atmosphere.present? && atmosphere.pressure.to_f > 0.1
      if atmosphere.wind_patterns.present?
        features << 'erosion patterns'
      end
      
      if atmosphere.humidity.to_f > 60
        features << 'wetlands'
      end
    end
    
    # Return unique features
    features.uniq
  end
  
  def erosion_susceptibility
    return :none unless atmosphere.present? && geosphere.present?
    
    # Factors affecting erosion:
    # 1. Atmosphere pressure (wind)
    # 2. Surface material hardness
    # 3. Water presence
    
    pressure = atmosphere.pressure.to_f
    water = hydrosphere.present? ? hydrosphere.water_coverage.to_f : 0
    
    # Estimate surface hardness from composition
    crust_comp = geosphere.crust_composition || {}
    
    # Hardness factors (relative values)
    hardness_factors = {
      'iron' => 0.8,
      'silicon' => 0.6,
      'carbon' => 0.7,
      'water ice' => 0.3,
      'regolith' => 0.1
    }
    
    # Calculate weighted hardness
    total_known = 0
    hardness = 0.5 # default
    
    crust_comp.each do |material, percentage|
      if hardness_factors.key?(material)
        hardness += hardness_factors[material] * (percentage.to_f / 100.0)
        total_known += percentage.to_f / 100.0
      end
    end
    
    # Adjust for known percentages
    hardness = hardness / total_known if total_known > 0
    
    # Calculate overall susceptibility
    susceptibility = (pressure / 100.0) * 0.4 + (water / 100.0) * 0.4 + (1 - hardness) * 0.2
    
    # Categorize
    case susceptibility
    when 0..0.2 then :very_low
    when 0.2..0.4 then :low
    when 0.4..0.6 then :moderate
    when 0.6..0.8 then :high
    else :very_high
    end
  end

  # Calculate surface area based on radius
  def surface_area
    return 0 unless radius.present?
    4 * Math::PI * (radius ** 2)
  end
  
  # Calculate volume based on radius
  def volume
    return 0 unless radius.present?
    (4.0 / 3) * Math::PI * (radius ** 3)
  end
  
  # Calculate density based on mass and volume
  def density
    return nil if mass.nil? || volume.nil?
    mass_float = mass.to_f
    mass_float / volume
  end
  
  # Calculate gravity based on mass and radius
  def calculate_gravity
    return nil unless radius.present? && mass.present?
    mass_float = mass.to_f
    (GameConstants::GRAVITATIONAL_CONSTANT * mass_float) / (radius ** 2)
  end
  
  # Update gravity when mass or radius changes
  def update_gravity
    return if new_record? # Don't calculate for new records - use seeded value
    
    # Only calculate if mass or radius changed
    if (saved_changes.keys & ['mass', 'radius']).any?
      self.gravity = calculate_gravity
      save!
    end
  end
  
  # Calculate escape velocity
  def calculate_escape_velocity
    return 0 unless mass.present? && radius.present?
    # v_escape = sqrt(2GM/R)
    Math.sqrt(2 * GameConstants::GRAVITATIONAL_CONSTANT * mass.to_f / radius)
  end
  
  # Method to determine if this body is a planet/dwarf planet vs a gas giant
  def has_solid_surface?
    !type.to_s.include?('GasGiant') && !type.to_s.include?('IceGiant')
  end
  
  # Method to get surface composition
  def surface_composition
    geosphere&.crust_composition || {}
  end  

  private

  # Normalize liquid names to chemical formulas
  def normalize_liquid_name(name)
    name_lower = name.to_s.downcase.strip
    
    # Map common names to chemical formulas
    case name_lower
    when 'water', 'h2o', 'ice'
      'H2O'
    when 'methane', 'ch4'
      'CH4'
    when 'ethane', 'c2h6'
      'C2H6'
    when 'ammonia', 'nh3'
      'NH3'
    when 'nitrogen', 'n2'
      'N2'
    else
      # If it's already a chemical formula, return as-is (uppercase)
      name.to_s.upcase
    end
  end

  # Infer liquid type from body characteristics
  def infer_liquid_from_context
    body_name = name.to_s.downcase
    temp = surface_temperature.to_f
    
    # Check for known bodies
    case body_name
    when /titan/
      return 'CH4'  # Titan has methane/ethane lakes
    when /mars/, /earth/, /venus/, /europa/, /enceladus/
      return 'H2O'  # Rocky planets and icy moons have water
    when /triton/
      return 'N2'   # Triton may have nitrogen
    end
    
    # Infer from temperature
    if temp < 90
      'CH4'  # Very cold = hydrocarbons (methane)
    elsif temp < 100
      'N2'   # Cold = nitrogen
    elsif temp < 200
      'NH3'  # Cold but not frozen = ammonia
    else
      'H2O'  # Normal temps = water
    end
  end
end