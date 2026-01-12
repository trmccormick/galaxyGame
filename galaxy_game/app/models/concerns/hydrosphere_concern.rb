# app/models/concerns/hydrosphere_concern.rb
module HydrosphereConcern
  extend ActiveSupport::Concern

  included do
    before_validation :set_default_values, if: :new_record?
  end

  def calculate_state_distributions(temperature = nil, pressure = nil)
    temp = temperature || self.temperature || celestial_body.surface_temperature || 288.15
    press = pressure || self.pressure || celestial_body.atmosphere&.pressure || 1.0
    
    {
      solid: percentage_frozen(temp, press),
      liquid: percentage_liquid(temp, press),
      vapor: percentage_vapor(temp, press)
    }
  end

  def water_cycle_tick
    return unless celestial_body&.atmosphere
    handle_evaporation
    handle_precipitation
  end

  def primary_liquid
    # Get the primary liquid material from composition
    return 'H2O' unless composition.present?
    
    # Find the liquid with the highest percentage
    liquid_composition = composition.select { |k, v| v.is_a?(Hash) && v['state'] == 'liquid' }
    return 'H2O' if liquid_composition.empty?
    
    # Return the liquid with highest mass percentage
    liquid_composition.max_by { |k, v| v['percentage'].to_f }&.first || 'H2O'
  end

  def calculate_evaporation_rate
    return 0 unless celestial_body&.atmosphere
    
    liquid_material = primary_liquid
    
    # Get current temperature
    temp = self.temperature || celestial_body.surface_temperature || 288.15
    
    # Get current liquid percentage
    liquid_percent = state_distribution["liquid"].to_f
    
    # Calculate total liquid mass
    liquid_mass = (liquid_percent / 100.0) * total_liquid_mass
    
    # Base evaporation rate factors
    temp_factor = [(temp - 273.15) / 100.0, 0].max # Higher temp = more evaporation
    surface_area_factor = 0.01 # 1% of surface per tick at maximum rate
    
    # Calculate evaporation - more liquid evaporates when it's hotter
    evaporation_amount = liquid_mass * temp_factor * surface_area_factor
    
    # Cap at 10% of liquid per tick
    [evaporation_amount, liquid_mass * 0.1].min
  end

  def handle_evaporation
    # Calculate evaporation amount
    amount = calculate_evaporation_rate
    return if amount <= 0
    
    liquid_material = primary_liquid
    
    # If there's no liquid vapor in atmosphere, create it
    if celestial_body.atmosphere.gases.where(name: liquid_material).count == 0
      celestial_body.atmosphere.add_gas(liquid_material, amount)
    else
      # Add to atmosphere
      celestial_body.atmosphere.add_gas(liquid_material, amount)
    end
    
    # Remove from hydrosphere
    self.total_liquid_mass -= amount
    
    # Update state distribution
    recalculate_state_distribution
    
    save!
  end

  def handle_precipitation
    return unless celestial_body&.atmosphere
    
    liquid_material = primary_liquid
    
    # Find liquid vapor in atmosphere
    liquid_gas = celestial_body.atmosphere.gases.find_by(name: liquid_material)
    return unless liquid_gas && liquid_gas.mass > 0
    
    # Calculate precipitation amount
    amount = calculate_precipitation_rate
    return if amount <= 0
    
    # Remove from atmosphere
    begin
      celestial_body.atmosphere.remove_gas(liquid_material, amount)
    rescue => e
      Rails.logger.error "Error removing #{liquid_material} from atmosphere: #{e.message}"
      return
    end
    
    # Add to hydrosphere
    self.total_liquid_mass += amount
    
    # Update state distribution
    recalculate_state_distribution
    
    save!
  end

  def recalculate_state_distribution
    self.state_distribution = calculate_state_distributions
  end

  private

  def calculate_precipitation_rate
    return 0 unless celestial_body&.atmosphere
    
    liquid_material = primary_liquid
    
    # Find liquid vapor in atmosphere
    liquid_gas = celestial_body.atmosphere.gases.find_by(name: liquid_material)
    return 0 unless liquid_gas&.mass.to_f > 0
    
    # Get current temperature
    temp = celestial_body.atmosphere.temperature || celestial_body.surface_temperature || 288.15
    
    # Precipitation is higher at lower temperatures
    temp_factor = [(373.15 - temp) / 100.0, 0].max
    
    # Base rate - about 5% of atmospheric liquid per tick at optimal conditions
    precipitation_rate = liquid_gas.mass * temp_factor * 0.05
    
    # Cap at 25% of atmospheric liquid per tick
    [precipitation_rate, liquid_gas.mass * 0.25].min
  end

  def percentage_frozen(temp, pressure = 1.0)
    liquid_material = primary_liquid
    
    # Get material properties
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(liquid_material)
    
    # Default to water properties if material not found
    freezing_point = material_data&.dig('phase_change_temperatures', 'freezing')&.to_f || 273.15
    
    # Simplified model - below freezing, most liquid is solid
    if temp < freezing_point
      # The colder it is, the more solid
      freeze_factor = [(freezing_point - temp) / 50.0, 1.0].min
      90 * freeze_factor + 10 # 10-100% depending on how cold
    else
      # Above freezing, only high-altitude/polar liquid might be solid
      [(freezing_point + 10 - temp) * 2, 0].max # Some solid if within 5 degrees of freezing
    end
  end

  def percentage_liquid(temp, pressure = 1.0)
    frozen = percentage_frozen(temp, pressure)
    vapor = percentage_vapor(temp, pressure)
    
    # Ensure we don't exceed 100%
    liquid = 100 - frozen - vapor
    [liquid, 0].max
  end

  def percentage_vapor(temp, pressure = 1.0)
    liquid_material = primary_liquid
    
    # Get material properties
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(liquid_material)
    
    # Default to water properties if material not found
    boiling_point = material_data&.dig('phase_change_temperatures', 'boiling')&.to_f || 373.15
    
    # Simplified model - vapor increases with temperature
    if temp > boiling_point
      95 # Almost all liquid is vapor above boiling
    else
      # Linear increase from freezing to boiling
      freezing_point = material_data&.dig('phase_change_temperatures', 'freezing')&.to_f || 273.15
      temp_range = boiling_point - freezing_point
      temp_range = 100 if temp_range <= 0 # Prevent division by zero
      
      vapor_factor = [(temp - freezing_point) / temp_range, 0].max
      vapor_factor * 70 # Up to 70% as vapor as it approaches boiling
    end
  end

  def set_default_values
    self.temperature ||= celestial_body&.surface_temperature
    self.pressure ||= celestial_body&.atmosphere&.pressure || 1.0
    self.composition ||= {}
    self.liquid_bodies ||= {}
    self.state_distribution ||= calculate_state_distributions
    self.total_liquid_mass ||= 0
    self.pollution ||= 0
  end
end