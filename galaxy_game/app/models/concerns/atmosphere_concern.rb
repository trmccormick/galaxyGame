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
    gases.reset if gases.loaded?
    gas = gases.find_by(name: formula_or_name)
    return gas.percentage if gas
    # Fallback to composition hash
    if composition.present?
      return composition[formula_or_name].to_f if composition[formula_or_name]
    end
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
    gases.destroy_all
    body = celestial_body
    return unless body.present?
    lookup_service = Lookup::MaterialLookupService.new
    total_mass = total_atmospheric_mass || 0
    created = false
    composition.each do |input_key, data|
      percentage = if data.is_a?(Hash)
                    data['percentage'].to_f
                  else
                    data.to_f
                  end
      next if percentage <= 0
      mass = (percentage / 100.0) * total_mass
      material_data = lookup_service.find_material(input_key)
      next unless material_data && lookup_service.get_material_property(material_data, 'chemical_formula').present?
      chemical_formula = lookup_service.get_material_property(material_data, 'chemical_formula')
      molar_mass = lookup_service.get_material_property(material_data, 'molar_mass')&.to_f
      gas = gases.new(
        name: chemical_formula,
        percentage: percentage,
        mass: mass,
        molar_mass: molar_mass
      )
      gas.save!
      created = true
    end
    recalculate_gas_percentages
    created
  end

  # Replace the existing duplicate normalization logic
  def add_gas(chemical_formula, amount_kg)
    if chemical_formula.blank?
      raise InvalidGasError, "Chemical formula cannot be blank"
    end
    if amount_kg.nil? || amount_kg <= 0
      raise InvalidGasError, "Amount must be positive"
    end
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(chemical_formula)
    unless material_data && lookup_service.get_material_property(material_data, 'chemical_formula').present?
      raise InvalidGasError, "Unknown chemical formula or name: #{chemical_formula}. Check materials database."
    end
    formula = lookup_service.get_material_property(material_data, 'chemical_formula')
    gas = gases.find_or_initialize_by(name: formula)
    gas.mass = (gas.mass || 0.0) + amount_kg.to_f
    gas.molar_mass = lookup_service.get_material_property(material_data, 'molar_mass')&.to_f if gas.molar_mass.blank?
    
    # Set percentage to 0 initially to avoid validation error
    gas.percentage = 0
    
    begin
      gas.save!
    rescue ActiveRecord::RecordInvalid => e
      raise InvalidGasError, e.message
    end
    update_total_atmospheric_mass
    recalculate_gas_percentages
    gas
  end

  # Also update remove_gas to use the lookup service
  def remove_gas(chemical_formula, amount_kg = nil)
    raise InvalidGasError, "Chemical formula cannot be blank" if chemical_formula.blank?
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(chemical_formula)
    unless material_data && lookup_service.get_material_property(material_data, 'chemical_formula').present?
      raise InvalidGasError, "Unknown chemical formula or name: #{chemical_formula}. Check materials database."
    end
    formula = lookup_service.get_material_property(material_data, 'chemical_formula')
    gas = gases.find_by(name: formula)
    unless gas
      raise InvalidGasError, "Gas '#{formula}' not found in atmosphere"
    end
    amount_to_remove = amount_kg || gas.mass.to_f
    raise InvalidGasError, "Cannot remove negative amount" if amount_to_remove < 0
    raise InvalidGasError, "Cannot remove more than exists (#{gas.mass} kg available)" if amount_to_remove > gas.mass
    new_mass = gas.mass.to_f - amount_to_remove.to_f
    if new_mass <= 0.001
      gas.destroy!
    else
      gas.mass = new_mass
      gas.save!
    end
    update_total_atmospheric_mass
    recalculate_gas_percentages
    true
  end

  # Calculate atmospheric mass for a given volume, pressure, temperature, and composition
  def calculate_atmospheric_mass_for_volume(volume, pressure, temperature, composition)
    return 0 if volume.nil? || volume <= 0 || pressure.nil? || pressure <= 0 || temperature.nil? || temperature <= 0
    # Use ideal gas law: PV = nRT, where n = mass/molar_mass
    # Rearranging: mass = (P * V * molar_mass) / (R * T)
    # But we want density first: density = (P * molar_mass) / (R * T)
    molar_mass_kg_mol = estimate_molar_mass(composition) # Already in kg/mol
    pressure_pa = pressure * 1000.0 # convert kPa to Pa
    r = 8.314462618 # J/(mol·K)
    # density in kg/m³ = (Pa * kg/mol) / (J/(mol·K) * K) = kg/m³
    density = (pressure_pa * molar_mass_kg_mol) / (r * temperature)
    mass = density * volume # kg = kg/m³ * m³
    mass > 0 ? mass : 0
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

  def update_total_atmospheric_mass
    total = gases.sum(:mass)
    self.total_atmospheric_mass = total
    save!
    # Debug logging
    Rails.logger.debug "Total atmospheric mass calculation:"
    Rails.logger.debug "Individual gas masses: #{gases.pluck(:name, :mass)}"
    Rails.logger.debug "Sum result: #{total}"
  end  
  
  def estimate_molar_mass(composition)
    return 0.029 if composition.empty? # Default to air-like (29 g/mol)

    material_service = Lookup::MaterialLookupService.new
    total_weight = 0.0
    total_percentage = 0.0
    unknown_gases = []

    composition.each do |gas_name, percentage|
      pct = percentage.is_a?(Numeric) ? percentage : percentage.to_f
      next if pct <= 0
      gas_material = material_service.find_material(gas_name)
      if gas_material
        molar_mass_g_mol = material_service.get_material_property(gas_material, 'molar_mass')
        if molar_mass_g_mol
          molar_mass_kg_mol = molar_mass_g_mol.to_f / 1000.0
          total_weight += molar_mass_kg_mol * pct
          total_percentage += pct
        else
          unknown_gases << gas_name
        end
      else
        unknown_gases << gas_name
      end
    end
    # If we found some valid gases, use weighted average
    if total_percentage > 0
      weighted_average = total_weight / total_percentage
      return weighted_average
    end
    0.029 # fallback to air-like
  end

  def habitable?
    return false unless sealed? if respond_to?(:sealed?)  # ❌ This fails for planetary atmospheres
    return false if pressure < 60.0   # Minimum pressure for human survival (kPa)
    return false if o2_percentage < 16.0
    return false if co2_percentage > 0.5
    return false if temperature < 273.15 || temperature > 313.15  # 0°C to 40°C
    true
  end

  def pressure_in_atm
    (pressure || 0) / 101.325  # Convert kPa to atmospheres
  end

  def temperature_in_celsius
    (temperature || 0) - 273.15
  end

  def sealed?
    # Default implementation - override in specific atmosphere types
    sealing_status if respond_to?(:sealing_status)
  end  

  def pressure_in_psi
    (pressure || 0) * 0.145038  # Convert kPa to PSI
  end

  def pressure_in_mmhg
    (pressure || 0) * 7.50062   # Convert kPa to mmHg
  end

  def temperature_in_fahrenheit
    ((temperature || 0) - 273.15) * 9/5 + 32
  end


  def recalculate_gas_percentages
    # Reload association to ensure we have current gases after any deletions
    gases.reload
    return if gases.empty?
    # Use the stored total_atmospheric_mass instead of recalculating
    # to avoid race conditions with gas updates
    total_mass = self.total_atmospheric_mass
    return if total_mass.nil? || total_mass.zero?
    gases.each do |gas|
      next if gas.nil? || gas.mass.nil?
      percentage = (gas.mass.to_f / total_mass) * 100
      ppm = percentage * 10_000
      gas.update!(
        percentage: percentage,
        ppm: ppm
      )
    end
  end

  def increase_dust(amount = 0, properties = "Mainly composed of silicates and sulfates.")
    return unless amount > 0
    self.dust ||= {}
    self.dust['concentration'] = (self.dust['concentration'] || 0.0) + amount
    self.dust['concentration'] = 0.0 if self.dust['concentration'] < 0.0
    self.dust['properties'] = properties if properties
    save!
  end

  def decrease_dust(amount)
    return unless self.dust.present? && self.dust.is_a?(Hash) && self.dust.any?
    self.dust['concentration'] = (self.dust['concentration'] || 0.0) - amount
    self.dust['concentration'] = 0.0 if self.dust['concentration'] < 0.0
    save!
  end

  def increase_pollution(amount)
    self.pollution ||= 0
    self.pollution += amount
    save!
  end

  private

  def set_default_values
    return unless celestial_body # ✅ Guard clause for nil celestial_body
    
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

  def trigger_simulation
    TerraSim::AtmosphereSimulationService.new(self.celestial_body).simulate
  end

  def update_gas_percentages
    return if total_atmospheric_mass.nil? || total_atmospheric_mass.zero?
    gases.each do |gas|
      pct = (gas.mass.to_f / total_atmospheric_mass) * 100
      gas.update!(percentage: pct)
    end
  end

  # Helper method to get material ID from formula
  def material_id_for(formula)
    lookup_service = Lookup::MaterialLookupService.new
    material = lookup_service.find_material(formula)
    material ? material['id'] : formula
  end
end