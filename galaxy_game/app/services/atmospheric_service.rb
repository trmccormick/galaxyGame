class AtmosphericService
  include GameConstants

  def initialize(options = {})
    @temperature = options[:temperature] || STANDARD_TEMPERATURE
    @target_pressure = options[:target_pressure] || STANDARD_PRESSURE_PA
    @material_lookup = Lookup::MaterialLookupService.new
  end
  
  # Calculate moles from volume and pressure (PV=nRT)
  def calculate_moles(volume, pressure = @target_pressure, temp = @temperature)
    (pressure * volume) / (IDEAL_GAS_CONSTANT * temp)
  end
  
  # Calculate pressure from moles and volume (P=nRT/V)
  def calculate_pressure(moles, volume, temp = @temperature)
    (moles * IDEAL_GAS_CONSTANT * temp) / volume
  end
  
  # Convert moles to mass for a specific gas
  def moles_to_mass(moles, gas_name)
    molar_mass = get_molar_mass(gas_name)
    moles * molar_mass / 1000.0 # Convert g to kg
  end
  
  # Convert mass to moles for a specific gas
  def mass_to_moles(mass, gas_name)
    molar_mass = get_molar_mass(gas_name)
    mass * 1000.0 / molar_mass # Convert kg to g, then to moles
  end
  
  # Get molar mass from the material lookup service
  def get_molar_mass(gas_name)
    # Try to find material data
    material = @material_lookup.find_material(gas_name)
    if material && material.dig('properties', 'molar_mass')
      return material.dig('properties', 'molar_mass')
    end
    
    # Check for chemical formula match (CO2 vs carbon_dioxide)
    formula_lookup = {
      'CO2' => 'carbon_dioxide',
      'N2' => 'nitrogen',
      'O2' => 'oxygen',
      'CH4' => 'methane',
      'H2O' => 'water',
      'H2' => 'hydrogen',
      'He' => 'helium',
      'Ar' => 'argon',
      'CO' => 'carbon_monoxide'
    }
    
    if formula_lookup[gas_name]
      material = @material_lookup.find_material(formula_lookup[gas_name])
      if material && material.dig('properties', 'molar_mass')
        return material.dig('properties', 'molar_mass')
      end
    end
    
    # Fallback to approximation and log warning
    fallback_mass = case gas_name
                   when 'N2' then 28.01
                   when 'O2' then 32.0
                   when 'CO2' then 44.01
                   when 'Ar' then 39.95
                   when 'H2O' then 18.02
                   else 29.0 # Default if nothing else works
                   end
    
    Rails.logger.warn "MaterialLookupService: No molar mass found for gas: #{gas_name}, using fallback value (#{fallback_mass})"
    fallback_mass
  end
  
  # Get greenhouse factor for a gas
  def get_greenhouse_factor(gas_name)
    GREENHOUSE_FACTORS[gas_name] || 0.0
  end
  
  # Format values using GameFormatters
  def format_pressure(pressure_pa)
    # Convert Pa to atm
    pressure_atm = pressure_pa / STANDARD_PRESSURE_PA
    GameFormatters::AtmosphericData.format_pressure(pressure_atm)
  end
  
  def format_mass(mass_kg)
    GameFormatters::AtmosphericData.format_mass(mass_kg)
  end
  
  def format_volume(volume_m3)
    if volume_m3 >= 1_000_000_000
      "#{(volume_m3 / 1_000_000_000).round(2)} km³"
    elsif volume_m3 >= 1_000_000
      "#{(volume_m3 / 1_000_000).round(2)} million m³"
    elsif volume_m3 >= 1_000
      "#{(volume_m3 / 1_000).round(2)} thousand m³"
    else
      "#{volume_m3.round(2)} m³"
    end
  end
end