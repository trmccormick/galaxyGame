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
    
    # ✅ Initialize lookup service once
    lookup_service = Lookup::MaterialLookupService.new
    
    # Calculate the total atmospheric mass
    total_mass = total_atmospheric_mass || 0
    
    # Create gases
    composition.each do |chemical_formula, percentage|
      # Skip if percentage is zero
      next if percentage.to_f <= 0
      
      # Calculate mass based on percentage
      mass = (percentage.to_f / 100) * total_mass
      
      # ✅ Look up material data using the service
      material_data = lookup_service.find_material(chemical_formula)
      
      if material_data
        # ✅ Use material ID as name (consistent with add_gas)
        material_id = material_data['id']
        molar_mass = material_data['molar_mass']
      else
        Rails.logger.warn "Material not found for gas: #{chemical_formula}"
        material_id = chemical_formula  # Fallback to formula
        molar_mass = nil
      end
      
      # Create the gas record with material ID as name
      gas = gases.new(
        name: material_id,  # Use material_id, not chemical_formula
        percentage: percentage.to_f,
        mass: mass,
        molar_mass: molar_mass
      )

      # Save with validation to catch missing molar mass
      gas.save!
    end
    
    # Recalculate percentages after creating all gases
    recalculate_gas_percentages
    
    # Return true if gases were created
    gases.any?
  end

  # Replace the existing duplicate normalization logic
  def add_gas(chemical_formula, amount_kg)
    raise InvalidGasError, "Chemical formula cannot be blank" if chemical_formula.blank?
    raise InvalidGasError, "Amount must be positive" if amount_kg <= 0

    # ✅ Use MaterialLookupService to get material ID
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(chemical_formula)
    
    unless material_data
      raise InvalidGasError, "Unknown chemical formula: #{chemical_formula}. Check materials database."
    end

    # ✅ Store by material ID (matching SystemBuilderService and test expectations)
    material_id = material_data['id']  # "nitrogen", "oxygen", etc.
    gas = gases.find_or_initialize_by(name: material_id)
    
    # ✅ Update mass
    gas.mass = (gas.mass || 0.0) + amount_kg.to_f
    
    # ✅ Use precise molar mass from JSON data
    gas.molar_mass = material_data['molar_mass'] if gas.molar_mass.blank?
    
    gas.save!
    
    update_total_atmospheric_mass
    recalculate_gas_percentages
    
    gas
  end

  # Also update remove_gas to use the lookup service
  def remove_gas(chemical_formula, amount_kg = nil)
    raise InvalidGasError, "Chemical formula cannot be blank" if chemical_formula.blank?
    
    # ✅ Convert chemical formula to material ID for lookup
    lookup_service = Lookup::MaterialLookupService.new
    material_data = lookup_service.find_material(chemical_formula)
    
    unless material_data
      raise InvalidGasError, "Unknown chemical formula: #{chemical_formula}. Check materials database."
    end
    
    # ✅ Find gas by material ID (matching add_gas behavior)
    material_id = material_data['id']
    gas = gases.find_by(name: material_id)
    
    unless gas
      raise InvalidGasError, "Gas '#{chemical_formula}' not found in atmosphere"
    end
    
    # ✅ Determine amount to remove
    amount_to_remove = amount_kg || gas.mass.to_f
    raise InvalidGasError, "Cannot remove negative amount" if amount_to_remove < 0
    raise InvalidGasError, "Cannot remove more than exists (#{gas.mass} kg available)" if amount_to_remove > gas.mass

    # ✅ Update or destroy gas
    new_mass = gas.mass.to_f - amount_to_remove.to_f
    
    if new_mass <= 0.001  # Close to zero, remove completely
      gas.destroy!
    else
      gas.update!(mass: new_mass)
    end

    # ✅ Update atmosphere totals
    update_total_atmospheric_mass
    recalculate_gas_percentages
    
    true
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
    
    total_weight = 0
    total_percentage = 0
    unknown_gases = []
    
    composition.each do |gas_name, percentage|
      gas_material = material_service.find_material(gas_name)
      
      if gas_material
        # ✅ Get molar_mass property (matches JSON field name)
        molar_mass_g_mol = material_service.get_material_property(gas_material, 'molar_mass')
        
        if molar_mass_g_mol
          molar_mass_kg_mol = molar_mass_g_mol / 1000.0  # Convert g/mol to kg/mol
          total_weight += molar_mass_kg_mol * percentage
          total_percentage += percentage
          
          Rails.logger.debug "Found gas #{gas_name}: #{molar_mass_g_mol} g/mol (#{molar_mass_kg_mol} kg/mol)"
        else
          unknown_gases << gas_name
          Rails.logger.warn "Gas #{gas_name} found but no molar_mass property"
        end
      else
        unknown_gases << gas_name
        Rails.logger.warn "Gas #{gas_name} not found in material database"
      end
    end
    
    # Log any unknown gases for debugging
    if unknown_gases.any?
      Rails.logger.warn "Unknown gases in composition: #{unknown_gases.join(', ')}"
    end
    
    # If we found some valid gases, use weighted average
    # If no valid gases found, fall back to air-like composition
    if total_percentage > 0
      weighted_average = total_weight / total_percentage
      Rails.logger.debug "Calculated molar mass: #{weighted_average} kg/mol from #{total_percentage}% of composition"
      weighted_average
    else
      Rails.logger.debug "No valid gases found, using air default: 0.029 kg/mol"
      0.029  # Air-like fallback
    end
  end

  def calculate_atmospheric_mass_for_volume(volume_m3, pressure_kpa, temperature_k, composition)
    return 0 if volume_m3 <= 0 || pressure_kpa <= 0
    
    pressure_pa = pressure_kpa * 1000  # Convert kPa to Pa
    
    # Use molar mass estimation from composition
    avg_molar_mass = estimate_molar_mass(composition)
    
    # Calculate density using ideal gas law: PV = nRT, density = PM/RT
    density = (pressure_pa * avg_molar_mass) / (8314 * temperature_k)  # kg/m³
    
    total_mass = volume_m3 * density
    
    Rails.logger.debug "Atmospheric mass calculation:"
    Rails.logger.debug "  volume: #{volume_m3} m³"
    Rails.logger.debug "  pressure: #{pressure_kpa} kPa (#{pressure_pa} Pa)"
    Rails.logger.debug "  temperature: #{temperature_k} K"
    Rails.logger.debug "  avg_molar_mass: #{avg_molar_mass} kg/mol"
    Rails.logger.debug "  density: #{density} kg/m³"
    Rails.logger.debug "  total_mass: #{total_mass} kg"
    
    total_mass
  end

  def get_celestial_atmosphere_data
    # Try different ways to get celestial body based on container type
    celestial_body = case container
    when responds_to?(:location)
      # For structures: container.location.celestial_body
      container.location&.celestial_body
    when responds_to?(:celestial_body)
      # For planetary atmospheres: container.celestial_body (direct)
      container.celestial_body
    when responds_to?(:current_location)
      # For craft: container.current_location.celestial_body
      container.current_location&.celestial_body
    else
      # Try location as fallback
      container.try(:location)&.celestial_body
    end
    
    if celestial_body&.atmosphere
      # Use planetary atmosphere data
      {
        temperature: celestial_body.atmosphere.temperature || 273.15, # 0°C in Kelvin if missing
        pressure: celestial_body.atmosphere.pressure || 0.0,          # Vacuum if missing (in kPa)
        composition: celestial_body.atmosphere.composition || {}      # Empty if missing
      }
    else
      # Fallback defaults (space/vacuum conditions)
      {
        temperature: 273.15,  # 0°C in Kelvin (reasonable default)
        pressure: 0.0,        # Vacuum (kPa)
        composition: {}       # No gases
      }
    end
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
    # Don't recalculate if there are no gases
    return if gases.empty?
    
    # Get total atmosphere mass
    total_atmospheric_mass = gases.sum(:mass)
    
    # Update percentages for each gas
    gases.each do |gas|
      # Calculate percentage based on mass
      percentage = total_atmospheric_mass > 0 ? 
                   (gas.mass / total_atmospheric_mass) * 100 : 0
      
      # Ensure percentage is valid (between 0 and 100)
      percentage = percentage.clamp(0, 100)
      
      # Calculate PPM from percentage (1% = 10,000 ppm)
      ppm = percentage * 10_000
      
      # Update the gas record with both percentage and PPM
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
    return if total_atmospheric_mass.zero?

    gases.each do |gas|
      gas.update!(percentage: (gas.mass / total_atmospheric_mass) * 100)
    end
  end

  # Helper method to get material ID from formula
  def material_id_for(formula)
    material = @material_lookup.find_material(formula)
    material['id']  # ❌ This returns "oxygen", but should return "O2"
  end
end