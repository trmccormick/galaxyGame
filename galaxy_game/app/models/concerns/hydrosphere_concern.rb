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

  def calculate_evaporation_rate
    return 0 unless celestial_body&.atmosphere
    
    # Get current temperature
    temp = self.temperature || celestial_body.surface_temperature || 288.15
    
    # Get current liquid water percentage
    liquid_percent = state_distribution["liquid"].to_f
    
    # Calculate total liquid water mass
    liquid_water_mass = (liquid_percent / 100.0) * total_water_mass
    
    # Base evaporation rate factors
    temp_factor = [(temp - 273.15) / 100.0, 0].max # Higher temp = more evaporation
    surface_area_factor = 0.01 # 1% of surface per tick at maximum rate
    
    # Calculate evaporation - more water evaporates when it's hotter
    evaporation_amount = liquid_water_mass * temp_factor * surface_area_factor
    
    # Cap at 10% of liquid water per tick
    [evaporation_amount, liquid_water_mass * 0.1].min
  end

  def handle_evaporation
    # Calculate evaporation amount
    amount = calculate_evaporation_rate
    return if amount <= 0
    
    # If there's no H2O in atmosphere, create it
    if celestial_body.atmosphere.gases.where(name: 'H2O').count == 0
      celestial_body.atmosphere.add_gas('H2O', amount)
    else
      # Add to atmosphere
      celestial_body.atmosphere.add_gas('H2O', amount)
    end
    
    # Remove from hydrosphere
    self.total_water_mass -= amount
    
    # Update state distribution
    recalculate_state_distribution
    
    save!
  end

  def handle_precipitation
    return unless celestial_body&.atmosphere
    
    # Find water vapor in atmosphere
    h2o_gas = celestial_body.atmosphere.gases.find_by(name: 'H2O')
    return unless h2o_gas && h2o_gas.mass > 0
    
    # Calculate precipitation amount
    amount = calculate_precipitation_rate
    return if amount <= 0
    
    # Remove from atmosphere
    begin
      celestial_body.atmosphere.remove_gas('H2O', amount)
    rescue => e
      Rails.logger.error "Error removing H2O from atmosphere: #{e.message}"
      return
    end
    
    # Add to hydrosphere
    self.total_water_mass += amount
    
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
    
    # Find water vapor in atmosphere
    h2o_gas = celestial_body.atmosphere.gases.find_by(name: 'H2O')
    return 0 unless h2o_gas&.mass.to_f > 0
    
    # Get current temperature
    temp = celestial_body.atmosphere.temperature || celestial_body.surface_temperature || 288.15
    
    # Precipitation is higher at lower temperatures
    temp_factor = [(373.15 - temp) / 100.0, 0].max
    
    # Base rate - about 5% of atmospheric water per tick at optimal conditions
    precipitation_rate = h2o_gas.mass * temp_factor * 0.05
    
    # Cap at 25% of atmospheric water per tick
    [precipitation_rate, h2o_gas.mass * 0.25].min
  end

  def percentage_frozen(temp, pressure = 1.0)
    # Simplified model - below freezing, most water is ice
    if temp < 273.15
      # The colder it is, the more ice
      freeze_factor = [(273.15 - temp) / 50.0, 1.0].min
      90 * freeze_factor + 10 # 10-100% depending on how cold
    else
      # Above freezing, only high-altitude/polar water might be ice
      [(273.15 + 10 - temp) * 2, 0].max # Some ice if within 5 degrees of freezing
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
    # Simplified model - vapor increases with temperature
    if temp > 373.15
      95 # Almost all water is vapor above boiling
    else
      # Linear increase from freezing to boiling
      vapor_factor = [(temp - 273.15) / 100.0, 0].max
      vapor_factor * 70 # Up to 70% as vapor as it approaches boiling
    end
  end

  def set_default_values
    self.temperature ||= celestial_body&.surface_temperature
    self.pressure ||= celestial_body&.atmosphere&.pressure || 1.0
    self.composition ||= {}
    self.water_bodies ||= {}
    self.state_distribution ||= calculate_state_distributions
    self.total_water_mass ||= 0
    self.pollution ||= 0
  end
end