class Resource::GasMining
  def initialize(celestial_body)
    @celestial_body = celestial_body
  end

  def mine_gas(gas_name, mass_to_extract, altitude = 0)
    atmosphere = @celestial_body.atmosphere
    return unless atmosphere

    gas = atmosphere.gases.find_by(name: gas_name)
    return unless gas && gas.mass >= mass_to_extract

    # Adjust the mining efficiency based on atmospheric properties and altitude
    efficiency_factor = adjust_mining_efficiency(atmosphere, altitude)
    adjusted_mass = mass_to_extract * efficiency_factor

    # Ensure we don't mine more than the available amount
    adjusted_mass = [adjusted_mass, gas.mass].min

    # Remove gas from the atmosphere
    atmosphere.remove_gas(gas_name, adjusted_mass)

    # Add it to the celestial body's materials (for resource tracking)
    material = @celestial_body.materials.find_or_create_by(name: gas_name)
    material.update!(amount: material.amount + adjusted_mass)

    puts "Successfully mined #{adjusted_mass} kg of #{gas_name} from the atmosphere at #{altitude} km altitude."
  end

  private

  # Adjust the mining efficiency based on atmospheric pressure, temperature, altitude, and composition
  def adjust_mining_efficiency(atmosphere, altitude)
    case
    when altitude < 0
      raise ArgumentError, "Altitude cannot be negative."
    when altitude > atmosphere.top_of_atmosphere
      puts "Altitude is above the top of the atmosphere. Mining is not possible."
      return 0
    when altitude > 100 # Higher altitudes, lower pressure
      # At higher altitudes, the pressure drops significantly, making mining easier
      puts "Mining efficiency is higher due to lower pressure at high altitudes."
      return 1.2 # 120% efficiency at high altitudes

    when altitude > 50 # Mid-altitude range
      # At mid-altitudes, pressure is moderate
      puts "Mining efficiency is moderate at this altitude."
      return 1.0 # 100% efficiency at mid-altitudes

    when altitude > 20 # Lower altitudes, higher pressure
      # At lower altitudes, pressure starts to increase, making mining more challenging
      puts "Mining efficiency is reduced due to increased pressure at this altitude."
      return 0.8 # 80% efficiency at low altitudes

    else
      # Surface or lower altitude, extremely high pressure
      puts "Mining efficiency is very low at this depth due to extreme pressure."
      return 0.5 # 50% efficiency at the surface or high-pressure zones
    end
  end
end



  