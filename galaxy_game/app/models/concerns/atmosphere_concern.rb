# app/models/concerns/atmosphere_concern.rb
module AtmosphereConcern
  extend ActiveSupport::Concern

  # Add error handling:
  class AtmosphereError < StandardError; end
  class InvalidGasError < AtmosphereError; end
  class PressureError < AtmosphereError; end
  
  # Gas percentage lookup method that checks multiple sources in order:
  # 1. First checks the actual Gas records in the database (with fresh reload)
  # 2. Then falls back to the composition hash
  # 3. Returns 0.0 if not found anywhere
  def gas_percentage(formula_or_name)
    # Force a fresh gases collection to avoid stale data
    gases.reset if gases.loaded?
    
    # First try by name (most common case)
    gas = gases.find_by(name: formula_or_name)
    return gas.percentage if gas
    
    # Fallback to composition hash
    if composition.present?
      return composition[formula_or_name].to_f if composition[formula_or_name]
    end
    
    # Default if not found anywhere
    0.0
  end

  # Convenience methods for common gases
  def o2_percentage
    gas_percentage('O2')
  end

  def co2_percentage
    gas_percentage('CO2')
  end

  def ch4_percentage
    gas_percentage('CH4')
  end

  included do
    before_validation :set_default_values, if: :new_record?
  end

  def reset
    return unless base_values.present?
    
    # First clear existing gases
    gases.destroy_all
    
    # Set initial values from base values
    update!(
      composition: base_values['composition'],
      total_atmospheric_mass: base_values['total_atmospheric_mass'],
      dust: base_values['dust']
    )
    initialize_gases
  end

  def initialize_gases
    return unless composition.present?
    
    # Delete existing gases to avoid duplicates
    gases.destroy_all
    
    # Find celestial body
    body = celestial_body
    return unless body.present?
    
    # Calculate the total atmospheric mass
    total_mass = total_atmospheric_mass || 0
    
    # Create gases
    composition.each do |name, percentage|
      # Skip if percentage is zero
      next if percentage.to_f <= 0
      
      # Calculate mass based on percentage
      mass = (percentage.to_f / 100) * total_mass
      
      # Create the gas record
      gas = gases.create!(
        name: name,
        percentage: percentage.to_f,
        mass: mass
      )
    end
    
    # Return true if gases were created
    gases.any?
  end

  # Replace the existing duplicate normalization logic
  def add_gas(name, mass)
    # Validate inputs properly
    raise InvalidGasError, "Invalid mass value" if mass <= 0
    raise InvalidGasError, "Gas name required" if name.blank?
    
    # Debug logging
    puts "ADD_GAS CALLED: '#{name}' (#{mass} kg) - Caller: #{caller[0]}"
    
    # Use the material lookup service
    material_lookup = Lookup::MaterialLookupService.new
    material_data = material_lookup.find_material(name)
    
    # Ensure material was found
    unless material_data
      raise InvalidGasError, "Gas name '#{name}' not found in materials database"
    end
    
    # FIX 1: Use name if ID is not available
    standardized_name = material_data['id'] || name
    
    # Extract molar mass
    molar_mass = material_data.dig('properties', 'molar_mass')
    
    # Calculate percentages
    current_total_gas_mass = gases.sum(:mass) || 0
    total_mass = current_total_gas_mass + mass
    percentage = (mass / total_mass.to_f) * 100.0
    
    # Update percentages of existing gases
    gases.each do |existing_gas|
      new_percentage = (existing_gas.mass / total_mass.to_f) * 100.0
      existing_gas.update!(percentage: new_percentage)
    end
    
    # Add or update this gas
    gas = gases.find_or_initialize_by(name: standardized_name)
    gas.mass ||= 0
    gas.mass += mass
    gas.molar_mass = molar_mass if molar_mass
    gas.percentage = percentage
    gas.save!
    
    # FIX 2: Update total atmospheric mass
    update_total_atmospheric_mass
    
    # Return the gas record
    gas
  end

  # Also update remove_gas to use the lookup service
  def remove_gas(gas_name, mass_to_remove)
    # Validate inputs
    raise InvalidGasError, "Invalid mass to remove" if mass_to_remove <= 0
    raise InvalidGasError, "Gas name required" if gas_name.blank?
    
    # Debug logging
    puts "REMOVE_GAS CALLED: '#{gas_name}' (#{mass_to_remove} kg) - Caller: #{caller[0]}"
    
    # Use the material lookup service
    material_lookup = Lookup::MaterialLookupService.new
    material_data = material_lookup.find_material(gas_name)
    
    # FIX 3: Raise error if material not found
    unless material_data
      puts "WARNING: Unknown gas: '#{gas_name}' - cannot remove - Material lookup failed"
      raise InvalidGasError, "Gas name '#{gas_name}' not found in materials database"
    end
    
    # FIX 4: Use name if ID is not available
    standardized_name = material_data['id'] || gas_name
    
    # Find gas
    gas = gases.find_by(name: standardized_name)
    
    # FIX 5: Raise error if gas not found
    unless gas
      puts "WARNING: Gas '#{standardized_name}' not found in atmosphere - gases available: #{gases.pluck(:name).join(', ')}"
      raise InvalidGasError, "Gas '#{standardized_name}' not found in atmosphere"
    end
    
    # FIX 6: Raise error if trying to remove more than exists
    if mass_to_remove > gas.mass
      puts "WARNING: Attempting to remove #{mass_to_remove} kg of #{standardized_name}, but only #{gas.mass} kg available"
      raise InvalidGasError, "Cannot remove more gas than exists (have: #{gas.mass}, trying to remove: #{mass_to_remove})"
    end
    
    # Update the gas
    gas.mass -= mass_to_remove
    
    if gas.mass <= 0
      puts "  → Gas '#{standardized_name}' fully removed from atmosphere"
      gas.destroy
    else
      gas.save!
    end
    
    # FIX 7: Update total atmospheric mass
    update_total_atmospheric_mass
    
    # Recalculate percentages for all remaining gases
    recalculate_gas_percentages
    
    # Return the amount removed
    mass_to_remove
  end

  def calculate_pressure
    return 0 unless celestial_body&.gravity && total_atmospheric_mass && celestial_body&.radius
    
    # Radius is already in meters - remove the incorrect conversion
    radius_meters = celestial_body.radius
    
    # Calculate surface area in square meters
    surface_area = 4 * Math::PI * (radius_meters**2)
    
    # Calculate pressure in pascals
    pressure_pascals = (total_atmospheric_mass * celestial_body.gravity) / surface_area
    
    # Convert to atmospheres
    pressure_atm = pressure_pascals / 101325.0
    
    # Update debug output to show correct units
    Rails.logger.debug "Pressure calculation for #{celestial_body.name}:"
    Rails.logger.debug "  radius = #{celestial_body.radius} meters"
    Rails.logger.debug "  surface_area = #{surface_area} m²"
    Rails.logger.debug "  pressure = #{pressure_pascals} Pa = #{pressure_atm} atm"
    
    pressure_atm
  end

  def update_pressure_from_mass!
    # Calculate new pressure based on current mass
    new_pressure = calculate_pressure
    
    # Check if this is an override situation (current != calculated)
    if pressure.round(6) == 0.006000 && new_pressure.round(6) != 0.006000
      puts "Warning: Preventing Mars pressure reset. Using calculated value: #{new_pressure}"
    end
    
    # Always update with calculated value
    update!(pressure: new_pressure)
  end  

  private

  def set_default_values
    # Fallback pressure logic
    if pressure.nil?
      self.pressure = celestial_body.known_pressure
      Rails.logger.debug "[AtmosphereConcern] Pressure not provided, falling back to known_pressure: #{self.pressure} atm"
    elsif celestial_body.known_pressure.present? && (pressure - celestial_body.known_pressure).abs > 5
      Rails.logger.warn "[AtmosphereConcern] Atmosphere pressure (#{pressure}) differs significantly from known_pressure (#{celestial_body.known_pressure}) on #{celestial_body.name}"
    end
  
    self.temperature ||= celestial_body.surface_temperature
    self.composition ||= {}
    self.total_atmospheric_mass ||= calculate_total_mass
    self.pollution ||= 0
    self.dust ||= {}
  end

  def calculate_total_mass
    total_mass = 0
    composition.each do |gas, data|
      material = Lookup::MaterialLookupService.new.find_material(gas)
      next unless material

      molar_mass = material['molar_mass']
      percentage = data['percentage'] / 100.0
      total_mass += molar_mass * percentage
    end
    total_mass
  end

  def destroy_gases
    return if gases.empty?  # Fix dangling return if
    
    gases.each do |gas|
      material = celestial_body.materials.find_by(name: gas.name)
      material&.destroy
    end
    gases.destroy_all
  end

  def recalculate_gas_percentages
    return if total_atmospheric_mass.zero?

    gases.each do |gas|
      gas.update!(percentage: (gas.mass / total_atmospheric_mass) * 100)
    end
  end

  def update_total_atmospheric_mass
    total = gases.sum(:mass)
    self.total_atmospheric_mass = total
    save!
    
    # Debug logging
    Rails.logger.debug "Total atmospheric mass calculation:"
    Rails.logger.debug "Individual gas masses: #{gases.pluck(:name, :mass)}"
    Rails.logger.debug "Sum result: #{total}"
  end 

  def trigger_simulation
    TerraSim::AtmosphereSimulationService.new(self.celestial_body).simulate
  end

  def update_gas_percentages
    return if total_atmospheric_mass.zero?

    gases.each do |gas|
      gas.update!(percentage: (gas.mass / total_atmospheric_mass) * 100)
    end
  end
end