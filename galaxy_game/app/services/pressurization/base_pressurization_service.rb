module Pressurization
  class BasePressurizationService
    def initialize(volume_m3, available_gases = {}, options = {})
      @volume = volume_m3 # in cubic meters
      @available_gases = available_gases # { oxygen: x, nitrogen: y, ... } in kg
      @target_pressure = options[:target_pressure] || GameConstants::EARTH_PRESSURE # Pa
      @temperature = options[:temperature] || GameConstants::DEFAULT_TEMPERATURE # K
      @current_pressure = options[:current_pressure] || 0 # Start at vacuum
      @gas_mix = options[:gas_mix] || default_gas_mix
    end
    
    # Default Earth-like atmosphere mix
    def default_gas_mix
      # Use the existing constant from GameConstants instead of duplicating
      GameConstants::EARTH_ATMOSPHERE[:simplified_mix]
    end
    
    # Calculate total moles of gas needed based on ideal gas law: PV = nRT
    def calculate_total_moles
      (@target_pressure * @volume) / (GameConstants::IDEAL_GAS_CONSTANT * @temperature)
    end
    
    # Calculate mass of each gas needed based on its ratio and molar mass
    def calculate_needed_gases
      total_moles = calculate_total_moles
      
      @gas_mix.each_with_object({}) do |(gas_formula, ratio), result|
        gas_moles = total_moles * ratio
        gas_molar_mass = get_molar_mass(gas_formula) # g/mol
        common_name = get_common_name(gas_formula).downcase
        result[common_name] = (gas_moles * gas_molar_mass) / 1000.0 # Convert to kg
      end
    end
    
    # Determine max achievable pressure based on gas availability
    def calculate_achievable_pressure
      needed_gases = calculate_needed_gases
      
      # Find the limiting gas (lowest ratio of available/needed)
      limiting_ratio = 1.0
      needed_gases.each do |gas, needed|
        next if needed == 0
        available = @available_gases[gas.to_sym] || 0
        ratio = available / needed
        limiting_ratio = [limiting_ratio, ratio].min if ratio < limiting_ratio
      end
      
      @target_pressure * limiting_ratio
    end
    
    # Perform the pressurization
    def pressurize
      needed_gases = calculate_needed_gases
      achievable_pressure = calculate_achievable_pressure
      
      # Adjust to achievable pressure
      pressure_ratio = achievable_pressure / @target_pressure
      
      # Use gases based on achievable pressure
      used_gases = {}
      needed_gases.each do |gas, needed|
        used_amount = needed * pressure_ratio
        @available_gases[gas.to_sym] -= used_amount
        used_gases[gas] = used_amount
      end
      
      @current_pressure = achievable_pressure
      
      {
        achieved_pressure: @current_pressure,
        used_gases: used_gases,
        success: (@current_pressure >= @target_pressure * 0.95), # Success if we reach 95% of target
        human_breathable: check_human_breathability,
        error: (@current_pressure < @target_pressure * 0.95) ? "Insufficient gas supply" : nil
      }
    end
    
    # Check if the gas mixture and pressure are suitable for human breathing
    def check_human_breathability
      # Define minimum oxygen partial pressure (Pa)
      min_oxygen_partial = 18000 # ~18 kPa, minimum for human survival
      
      # Define maximum CO2 partial pressure (Pa)
      max_co2_partial = 1000 # ~1 kPa, maximum for human comfort
      
      # Calculate partial pressures
      oxygen_partial = @current_pressure * (@gas_mix['oxygen'] || 0)
      co2_partial = @current_pressure * (@gas_mix['carbon_dioxide'] || 0)
      
      # Check if pressure is sufficient
      return false if @current_pressure < 30000 # Minimum total pressure ~30 kPa
      
      # Check oxygen level
      return false if oxygen_partial < min_oxygen_partial
      
      # Check CO2 level
      return false if co2_partial > max_co2_partial
      
      # If we pass all checks, the atmosphere is breathable
      true
    end
    
    private
    
    # Get common name for a gas formula
    def get_common_name(gas_formula)
      gas_info = GameConstants::EARTH_ATMOSPHERE[:composition][gas_formula]
      gas_info&.dig(:common_name) || gas_formula
    end

    # Get molar mass for common gases (g/mol)
    def get_molar_mass(gas)
      # This should be moved to a Material database lookup
      case gas.to_s.downcase
      when 'oxygen', 'o2' then 32.0
      when 'nitrogen', 'n2' then 28.0
      when 'argon', 'ar' then 39.95
      when 'carbon_dioxide', 'co2' then 44.01
      when 'water_vapor', 'h2o' then 18.02
      else
        # Try to find it in your materials database
        material = Lookup::MaterialLookupService.new.find_material(gas.to_s)
        return material['molar_mass'] if material&.dig('molar_mass')
        
        raise ArgumentError, "Unknown gas: #{gas} - molar mass not found"
      end
    end
  end
end