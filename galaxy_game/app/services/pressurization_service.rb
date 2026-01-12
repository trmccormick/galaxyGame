class PressurizationService
  def initialize(enclosed_environment)
    @environment = enclosed_environment
    
    # Handle different types of enclosed environments
    if enclosed_environment.is_a?(Structures::BaseStructure)
      # For structures, use atmospheric data and volume
      if enclosed_environment.respond_to?(:atmospheric_data) && enclosed_environment.atmospheric_data
        @atmosphere = enclosed_environment.atmospheric_data
      else
        raise ArgumentError, "Environment must be an enclosed structure with atmospheric data"
      end
      @volume = enclosed_environment.respond_to?(:volume) ? enclosed_environment.volume : 0
    elsif enclosed_environment.is_a?(CelestialBodies::Features::BaseFeature)
      # For features, use operational_data for pressurization tracking
      @atmosphere = nil # Features don't have atmosphere until pressurized
      @volume = calculate_feature_volume(enclosed_environment)
    else
      # For test doubles/mocks
      @atmosphere = enclosed_environment.respond_to?(:atmospheric_data) ? enclosed_environment.atmospheric_data : nil
      @volume = enclosed_environment.respond_to?(:volume) ? enclosed_environment.volume : 1000
    end
    
    # Get the settlement for resource access
    @settlement = if enclosed_environment.respond_to?(:settlement) && enclosed_environment.settlement
                    enclosed_environment.settlement
                  elsif enclosed_environment.respond_to?(:owner) && enclosed_environment.owner.respond_to?(:owned_settlements)
                    enclosed_environment.owner.owned_settlements.first
                  else
                    nil
                  end
    
    # Get the celestial body for environmental properties
    @celestial_body = if @settlement&.location&.celestial_body
                        @settlement.location.celestial_body
                      elsif enclosed_environment.respond_to?(:celestial_body)
                        enclosed_environment.celestial_body
                      else
                        nil
                      end
    
    # Ensure we have a volume to work with (skip for features during sealing check)
    if enclosed_environment.is_a?(Structures::BaseStructure)
      raise ArgumentError, "Environment must have a calculable volume" if @volume <= 0
    end
    
    # Initialize material lookup service
    @material_lookup = Lookup::MaterialLookupService.new
  end
  
  # Calculate retention multiplier for gas dumps based on planetary magnetic field
  def retention_multiplier
    return 1.0 unless @celestial_body
    
    strength = @celestial_body.properties&.dig("magnetic_field_tesla").to_f
    if strength >= 1.0
      1.0
    else
      [strength / 1.0, 0.0].max
    end
  end
  
  # Add a method to just calculate requirements without actually pressurizing
  def calculate_required_gases(target_pressure = GameConstants::STANDARD_PRESSURE_KPA)
    # Check if environment is sealed
    if @environment.respond_to?(:is_sealed) && !@environment.is_sealed
      return {}
    end
    
    # Check if we already have adequate pressure
    current_pressure_kpa = @atmosphere.pressure * 101.3 # Convert from atm to kPa
    if current_pressure_kpa >= target_pressure
      return {}
    end
    
    # Get location and adapt composition based on local availability
    location = get_location
    atmospheric_mix = get_optimal_atmospheric_mix(location)
    
    # Calculate gas needs based on atmospheric mix
    calculate_needed_gases(target_pressure, atmospheric_mix)
  end

  # Check if environment is ready for pressurization
  def check_sealing_status
    # Check traditional sealing for structures/units
    if @environment.respond_to?(:is_sealed) && !@environment.is_sealed
      return { ready: false, message: "Environment is not sealed" }
    end
    
    # Check pressurization targets (canyons/lava tubes)
    if @environment.is_a?(CelestialBodies::Features::Canyon) || @environment.is_a?(CelestialBodies::Features::LavaTube)
      progress = @environment.operational_data['pressurization_progress'] || {}
      
      if !progress['ready_for_pressurization']
        requirements = get_pressurization_requirements(@environment)
        seals = progress['seals'] || {}
        
        missing_seals = requirements.map do |seal_type, required_count|
          current_count = seals[seal_type] || 0
          if current_count < required_count
            "#{required_count - current_count} more #{seal_type.pluralize}"
          end
        end.compact
        
        if missing_seals.any?
          return { 
            ready: false, 
            message: "Pressurization target requires: #{missing_seals.join(', ')}" 
          }
        end
      end
    end
    
    { ready: true }
  end

  def pressurize(target_pressure = GameConstants::STANDARD_PRESSURE_KPA, provided_gases = nil) # kPa (Earth standard)
    # Check if environment is sealed
    sealing_check = check_sealing_status
    unless sealing_check[:ready]
      return { success: false, message: sealing_check[:message] }
    end
    
    # Check if we already have adequate pressure
    current_pressure_kpa = @atmosphere.pressure * 101.3 # Convert from atm to kPa
    if current_pressure_kpa >= target_pressure
      # If pressure is adequate but O2 is low, try air cycling instead
      if should_cycle_air_instead_of_import_o2?
        return cycle_air_through_scrubbers
      end
      return { success: true, message: "Already at target pressure" }
    end
    
    # Get location and adapt composition based on local availability
    location = get_location
    atmospheric_mix = get_optimal_atmospheric_mix(location)
    
    # Calculate gas needs based on atmospheric mix
    needed_gases = calculate_needed_gases(target_pressure, atmospheric_mix)
    
    # If specific gases are provided (through material requests)
    if provided_gases
      # Verify the provided gases match what's needed
      if verify_provided_gases(needed_gases, provided_gases)
        # Use the provided gases instead of checking inventory
        update_atmosphere(provided_gases, target_pressure)
        
        return { 
          success: true, 
          message: "Pressurization complete using provided gases", 
          new_pressure: @atmosphere.pressure * 101.3,
          consumed: provided_gases
        }
      else
        return { 
          success: false, 
          message: "Provided gases don't match requirements", 
          needed: needed_gases,
          provided: provided_gases 
        }
      end
    end
    
    # Check if needed gases are available
    unless gases_available?(needed_gases)
      return { 
        success: false, 
        message: "Insufficient gas supplies", 
        needed: needed_gases 
      }
    end
    
    # Consume gases from inventory
    consume_gases(needed_gases)
    
    # Update atmosphere
    update_atmosphere(needed_gases, target_pressure)
    
    # Report success
    { 
      success: true, 
      message: "Pressurization complete", 
      new_pressure: @atmosphere.pressure * 101.3,
      consumed: needed_gases
    }
  end
  
  private
  
  def get_location
    if @environment.respond_to?(:location) && @environment.location
      @environment.location
    elsif @environment.respond_to?(:settlement) && @environment.settlement&.location
      @environment.settlement.location
    else
      nil
    end
  end
  
  def get_optimal_atmospheric_mix(location)
    # Default to Earth-like if no location or celestial body
    return GameConstants::EARTH_ATMOSPHERE[:simplified_mix] unless location&.celestial_body
    
    celestial_body = location.celestial_body
    
    # If the body has an atmosphere, adapt our mix based on local availability
    if celestial_body.respond_to?(:atmosphere) && celestial_body.atmosphere
      # Look at local atmosphere to determine what gases are abundant
      local_gases = celestial_body.atmosphere.gases.pluck(:formula, :percentage).to_h
      
      # If the local atmosphere has significant nitrogen or argon, use it as buffer gas
      if local_gases["N2"].to_f > 5.0
        # Use more nitrogen if it's abundant
        { 'O2' => 0.21, 'N2' => 0.78, 'Ar' => 0.01 }
      elsif local_gases["Ar"].to_f > 1.0
        # Use more argon if nitrogen is scarce but argon is available (like on Mars)
        { 'O2' => 0.21, 'N2' => 0.70, 'Ar' => 0.09 }
      elsif local_gases["CO2"].to_f > 5.0
        # If there's lots of CO2 (like Venus/Mars), use some after processing
        { 'O2' => 0.21, 'N2' => 0.74, 'Ar' => 0.04, 'CO2' => 0.01 }
      else
        # Default Earth-like
        GameConstants::EARTH_ATMOSPHERE[:simplified_mix]
      end
    else
      # No atmosphere, use default Earth-like
      GameConstants::EARTH_ATMOSPHERE[:simplified_mix]
    end
  end
  
  def calculate_needed_gases(target_pressure_kpa, atmospheric_mix)
    # Calculate the pressure difference in kPa
    current_pressure_kpa = @atmosphere.pressure * 101.3
    pressure_diff_kpa = target_pressure_kpa - current_pressure_kpa
    
    # Skip if no pressure increase needed
    return {} if pressure_diff_kpa <= 0
    
    # Volume in cubic meters
    volume_m3 = @volume
    
    # Temperature in Kelvin
    temperature_k = @atmosphere.temperature + 273.15
    
    # Calculate moles needed using PV=nRT rearranged to n=PV/RT
    # P is in Pa (multiply kPa by 1000)
    total_moles_needed = (pressure_diff_kpa * 1000 * volume_m3) / (GameConstants::IDEAL_GAS_CONSTANT * temperature_k)
    
    # Distribute moles according to atmospheric mix
    result = {}
    
    atmospheric_mix.each do |formula, ratio|
      # Moles of this specific gas
      gas_moles = total_moles_needed * ratio
      
      # Get material data for this gas
      material_data = @material_lookup.find_material(formula)
      next unless material_data
      
      # Get proper name and molar mass
      gas_name = material_data["name"]
      molar_mass = material_data["molar_mass"] || get_fallback_molar_mass(formula)
      
      # Convert to mass (kg) using molar mass
      gas_mass_kg = gas_moles * molar_mass / 1000.0
      
      # Add to result if significant amount
      result[gas_name] = gas_mass_kg.round(2) if gas_mass_kg > 0.01
    end
    
    result
  end
  
  # Fallback molar masses in case the lookup fails
  def get_fallback_molar_mass(formula)
    case formula
    when "O2" then 32.0
    when "N2" then 28.0
    when "CO2" then 44.0
    when "Ar" then 39.95
    else 28.0 # Default to nitrogen-like if unknown
    end
  end
  
  def gases_available?(needed_gases)
    return false unless @settlement&.inventory
    
    needed_gases.all? do |gas_name, amount_needed|
      # Try to find the gas in inventory
      gas_item = @settlement.inventory.items.find_by(name: gas_name, material_type: :gas)
      gas_item && gas_item.amount >= amount_needed
    end
  end
  
  def consume_gases(needed_gases)
    return unless @settlement&.inventory
    
    needed_gases.each do |gas_name, amount_needed|
      gas_item = @settlement.inventory.items.find_by(name: gas_name, material_type: :gas)
      if gas_item
        gas_item.update!(amount: gas_item.amount - amount_needed)
      end
    end
  end
  
  def update_atmosphere(added_gases, target_pressure_kpa)
    # Convert target pressure from kPa to atm
    target_pressure_atm = target_pressure_kpa / 101.3
    
    # Update the atmosphere pressure
    @atmosphere.update!(pressure: target_pressure_atm)
    
    # Update composition through the atmosphere's gases association
    added_gases.each do |gas_name, amount|
      # Look up the formula using the material lookup service
      material_data = @material_lookup.find_material(gas_name)
      formula = material_data ? material_data["chemical_formula"] : gas_name
      
      # Find existing gas or create new
      gas = @atmosphere.gases.find_by(name: gas_name) || 
            @atmosphere.gases.find_by(formula: formula)
      
      if gas
        # Update existing gas
        new_percentage = (gas.percentage * @atmosphere.total_atmospheric_mass + amount) / 
                         (@atmosphere.total_atmospheric_mass + added_gases.values.sum)
        gas.update!(percentage: new_percentage)
      else
        # Add new gas
        new_percentage = amount / (@atmosphere.total_atmospheric_mass + added_gases.values.sum)
        @atmosphere.gases.create!(
          name: gas_name,
          formula: formula,
          percentage: new_percentage
        )
      end
    end
    
    # Update total atmospheric mass
    new_mass = @atmosphere.total_atmospheric_mass + added_gases.values.sum
    @atmosphere.update!(total_atmospheric_mass: new_mass)
  end
  
  # Check if air cycling through CO2 scrubbers is needed instead of O2 import
  def should_cycle_air_instead_of_import_o2?
    current_o2_partial_pressure = calculate_o2_partial_pressure
    target_o2_pp = 21.0 # kPa for 21% O2 at 101.3 kPa
    
    # If pressure is adequate but O2 is low, cycle air through scrubbers
    current_pressure_kpa = @atmosphere.pressure * 101.3
    current_pressure_kpa >= 80.0 && current_o2_partial_pressure < (target_o2_pp * 0.8)
  end

  # Cycle air through CO2 scrubbers to increase O2 concentration
  def cycle_air_through_scrubbers
    # This would trigger the CO2 scrubbing process to convert CO2 to O2
    # For now, simulate by adjusting atmosphere composition
    co2_gas = @atmosphere.gases.find_by(name: 'CO2')
    o2_gas = @atmosphere.gases.find_by(name: 'O2')
    
    if co2_gas && co2_gas.percentage > 1.0
      # Convert some CO2 to O2 (simplified)
      conversion_amount = [co2_gas.percentage * 0.1, 2.0].min # Convert up to 2% or 10% of CO2
      
      co2_gas.update!(percentage: co2_gas.percentage - conversion_amount)
      if o2_gas
        o2_gas.update!(percentage: o2_gas.percentage + conversion_amount)
      else
        @atmosphere.gases.create!(name: 'O2', percentage: conversion_amount)
      end
      
      { success: true, message: "Air cycled through scrubbers, O2 increased by #{conversion_amount}%" }
    else
      { success: false, message: "Insufficient CO2 for scrubbing" }
    end
  end

  private

  def calculate_feature_volume(feature)
    # For features, estimate volume from static data
    case feature
    when CelestialBodies::Features::LavaTube
      length = feature.length_m || 1000
      width = feature.width_m || 50
      height = feature.height_m || 30
      length * width * height
    when CelestialBodies::Features::Canyon
      length = feature.static_data&.dig('dimensions', 'length_m') || 2000
      width = feature.static_data&.dig('dimensions', 'width_m') || 100
      depth = feature.static_data&.dig('dimensions', 'depth_m') || 50
      length * width * depth
    else
      # Default volume estimate
      1000000 # 1000m³
    end
  end

  def calculate_o2_partial_pressure
    o2_gas = @atmosphere.gases.find_by(name: 'O2')
    return 0.0 unless o2_gas
    
    total_pressure_kpa = @atmosphere.pressure * 101.3
    (o2_gas.percentage / 100.0) * total_pressure_kpa
  end

  # Get pressurization requirements for a feature
  def get_pressurization_requirements(feature)
    # Default requirements - can be overridden by feature data
    feature.operational_data.dig('pressurization_requirements') || {
      'plugs' => 2,
      'domes' => 1
    }
  end
end
