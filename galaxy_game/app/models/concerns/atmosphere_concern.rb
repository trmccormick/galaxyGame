# app/models/concerns/atmosphere_concern.rb
module AtmosphereConcern
  extend ActiveSupport::Concern

  # Add error handling:
  class AtmosphereError < StandardError; end
  class InvalidGasError < AtmosphereError; end
  class PressureError < AtmosphereError; end

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

  def add_gas(name, mass)
    raise InvalidGasError, "Invalid mass value" if mass <= 0
    raise InvalidGasError, "Gas name required" if name.blank?

    # Format the mass for display using our formatter
    formatted_mass = GameFormatters::AtmosphericData.format_mass(mass)
    puts "Adding #{formatted_mass} of #{name} to the atmosphere."

    # Find the material properties using lookup service
    material_lookup = Lookup::MaterialLookupService.new
    material_data = material_lookup.find_material(name)
    
    # Handle chemical formula mapping
    if material_data.nil?
      formula_to_id = {
        'CO2' => 'carbon_dioxide',
        'N2' => 'nitrogen',
        'O2' => 'oxygen',
        'Ar' => 'argon',
        'Water' => 'water',
        'H2O' => 'water',
        'CH4' => 'methane'
      }
      
      if formula_to_id[name]
        material_data = material_lookup.find_material(formula_to_id[name])
      end
    end
    
    # Extract molar mass
    molar_mass = material_data&.dig('properties', 'molar_mass')
    
    if molar_mass.nil?
      # Default values based on common gases
      default_molar_masses = {
        'CO2' => 44.01, 'N2' => 28.01, 'O2' => 32.0, 
        'CO' => 28.01, 'Ar' => 39.95, 'He' => 4.00,
        'H2O' => 18.02, 'Water' => 18.02, 'CH4' => 16.04
      }
      molar_mass = default_molar_masses[name] || 29.0
      puts "Warning: Molar mass not found for #{name}, using default value: #{molar_mass}"
    end
    
    # Now update or create the gas in the database
    gas = gases.find_or_initialize_by(name: name)
    
    # If gas is new (mass = 0) set its molar mass
    if gas.new_record? || gas.mass == 0
      gas.molar_mass = molar_mass
    end
    
    # Update the gas mass
    old_mass = gas.mass || 0
    gas.mass = old_mass + mass
    
    # Recalculate total mass
    old_total = total_atmospheric_mass || 0
    new_total = old_total + mass
    
    # Update the atmosphere total mass
    self.total_atmospheric_mass = new_total
    
    # Save the gas
    gas.save!
    
    # Update gas percentages
    update_gas_percentages
    
    # Update pressure
    update_pressure_from_mass!
    
    gas
  end

  def remove_gas(gas_name, mass_to_remove)
    gas = gases.find_by(name: gas_name)
    
    raise InvalidGasError, "Gas #{gas_name} not found in atmosphere" unless gas
    raise InvalidGasError, "Cannot remove more than exists (#{gas.mass} kg)" if mass_to_remove > gas.mass
    
    # Format mass for output
    formatted_mass = GameFormatters::AtmosphericData.format_mass(mass_to_remove)
    puts "Removing #{formatted_mass} of #{gas_name} from the atmosphere."
    
    # Update gas
    gas.mass -= mass_to_remove
    
    # Update total
    self.total_atmospheric_mass -= mass_to_remove
    
    # If mass is practically zero, destroy the gas
    if gas.mass < 0.001
      gas.destroy
    else
      gas.save!
    end
    
    # Update gas percentages
    update_gas_percentages
    
    # Update pressure
    update_pressure_from_mass!
    
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