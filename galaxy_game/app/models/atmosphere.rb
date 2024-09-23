class Atmosphere
  attr_accessor :celestial_body, :temperature, :pressure, :gases, :atmospheric_mass

  IDEAL_GAS_CONSTANT = 8.314  # J/(mol·K) - Ideal gas constant
  DEFAULT_VOLUME = 1.0        # m^3 - Default volume for gas calculations

  def initialize(celestial_body:, temperature: 0, pressure: 0, atmosphere_composition: {}, total_atmospheric_mass: 0)
    @celestial_body = celestial_body
    @temperature = temperature
    @pressure = pressure
    @gases = []  # Initialize as an empty array of gas objects
    @atmospheric_mass = total_atmospheric_mass

    # Process the atmosphere composition by adding each gas
    atmosphere_composition.each do |name, percentage|
      amount = total_atmospheric_mass * percentage / 100
      material = celestial_body.materials.find_or_create_by(name: name)
      material.update(amount: amount)
      add_gas(Gas.new(name: name, percentage: percentage, material: material))
    end

    calculate_pressure  # Ensure pressure is calculated after initialization
  end

  # Adds a gas to the atmosphere, or updates the percentage if the gas already exists
  def add_gas(gas)
    existing_gas = @gases.find { |g| g.name == gas.name }
    if existing_gas
      existing_gas.percentage += gas.percentage
    else
      @gases << gas
    end
    recalculate_atmosphere
  end

  # Removes a gas from the atmosphere by name
  def remove_gas(gas_name)
    @gases.reject! { |g| g.name == gas_name }
    recalculate_atmosphere
  end

  # Recalculates the atmosphere after any changes to gases
  def recalculate_atmosphere
    calculate_pressure

    # Trigger TerraSim service to recalculate greenhouse effect and other factors
    terra_sim = TerraSim.new
    terra_sim.calc_current
  end

  # Calculates the pressure based on the number of moles and temperature
  def calculate_pressure
    return 0 if @gases.empty?

    total_moles = @gases.sum(&:moles)
    @pressure = (total_moles * IDEAL_GAS_CONSTANT * @temperature) / DEFAULT_VOLUME
    @pressure
  end

  # Outputs the atmosphere's current state
  def to_s
    gas_details = @gases.map { |g| "#{g.name}: #{g.percentage}%" }.join(", ")
    "Atmosphere: Gases - [#{gas_details}], Pressure - #{@pressure} atm, Temperature - #{@temperature}K"
  end
end




  