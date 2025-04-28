# app/models/concerns/biosphere_concern.rb
module BiosphereConcern
  extend ActiveSupport::Concern

  included do
    # Additional scopes or class methods could be defined here
  end

  # Simulate ecological cycles
  def ecological_cycle_tick
    return unless celestial_body
    
    # Simulate ecological processes
    update_temperature_effects
    respond_to_atmospheric_changes
    handle_seasonal_changes
  end

  # Update biosphere based on temperature changes
  def update_temperature_effects
    # Biomes expand or contract based on temperature
    return unless biome_distribution.present? && biome_distribution.is_a?(Hash)
    
    current_temp = celestial_body.surface_temperature || 288.15 # Default to Earth average
    
    # Get a copy of biome_distribution to work with
    distribution = biome_distribution.dup
    
    distribution.each do |biome_name, data|
      # Simplified model - biomes have preferred temperature ranges
      biome = Biome.find_by(name: biome_name)
      next unless biome && biome.respond_to?(:temperature_range)
      
      # Check if current temperature is in the biome's preferred range
      temp_compatibility = temperature_compatibility(biome, current_temp)
      
      # Update biome area based on compatibility
      data['area_percentage'] = data['area_percentage'] * (0.9 + (temp_compatibility * 0.2))
    end
    
    # Normalize percentages to ensure they sum to 100%
    total_percentage = distribution.sum { |_, data| data['area_percentage'].to_f }
    if total_percentage > 0
      distribution.each do |name, data|
        data['area_percentage'] = (data['area_percentage'].to_f / total_percentage) * 100.0
      end
    end
    
    # Save the updated distribution back
    self.biome_distribution = distribution
    save!
  end

  # Handle seasonal changes (if the planet has seasons)
  def handle_seasonal_changes
    # Implementation could vary based on the planet's axial tilt, orbit, etc.
  end

  # Check if biosphere is habitable for earth-like life
  def habitable_for_earth_life?
    return false unless celestial_body&.atmosphere
    
    # Check for basic requirements
    atmosphere = celestial_body.atmosphere
    oxygen_percentage = atmosphere.gases.find_by(name: 'O2')&.percentage.to_f
    
    # Basic criteria: oxygen, temperature, pressure
    has_oxygen = oxygen_percentage >= 15.0
    has_suitable_temp = temperature_tropical.between?(273, 320) # 0°C to 47°C
    has_suitable_pressure = atmosphere.pressure.between?(0.5, 1.5)
    
    has_oxygen && has_suitable_temp && has_suitable_pressure
  end

  private

  # Calculate temperature compatibility for a biome
  def temperature_compatibility(biome, temperature)
    return 1.0 unless biome.respond_to?(:temperature_range)
    
    temp_range = biome.temperature_range
    min_temp = temp_range.min
    max_temp = temp_range.max
    
    # If temperature is within the range, perfect compatibility
    return 1.0 if temperature >= min_temp && temperature <= max_temp
    
    # Otherwise, calculate compatibility based on distance from range
    if temperature < min_temp
      distance = min_temp - temperature
    else
      distance = temperature - max_temp
    end
    
    # Compatibility decreases with distance
    [1.0 - (distance / 50.0), 0.0].max
  end

  # Respond to atmospheric changes
  def respond_to_atmospheric_changes
    return unless celestial_body&.atmosphere
    
    # Get key atmospheric compositions
    atmosphere = celestial_body.atmosphere
    co2_level = atmosphere.gases.find_by(name: 'CO2')&.percentage.to_f || 0
    o2_level = atmosphere.gases.find_by(name: 'O2')&.percentage.to_f || 0
    
    # Simulate carbon cycle - biosphere absorbs CO2 and releases O2
    if biodiversity_index > 0.1
      absorption_rate = biodiversity_index * 0.01 # 0.1% to 1% of CO2 per cycle
      co2_absorbed = [co2_level * absorption_rate, co2_level].min
      o2_produced = co2_absorbed * 0.8 # Simplified photosynthesis conversion
      
      # Update atmosphere
      if co2_absorbed > 0
        co2_gas = atmosphere.gases.find_by(name: 'CO2')
        co2_gas.update(percentage: co2_level - co2_absorbed) if co2_gas
        
        o2_gas = atmosphere.gases.find_by(name: 'O2')
        if o2_gas
          o2_gas.update(percentage: o2_level + o2_produced)
        else
          atmosphere.gases.create(name: 'O2', percentage: o2_produced)
        end
      end
    end
  end
end
