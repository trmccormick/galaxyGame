class VenusMarsAtmosphereTransferSimulation
  RAW_TRANSFER = 'raw'
  SELECTIVE_TRANSFER = 'selective'
  PROCESSED_TRANSFER = 'processed'

  TRANSFER_MODE = PROCESSED_TRANSFER
  VENUS_MARS_SYNODIC_PERIOD_DAYS = 583.92
  TRANSIT_TIME_DAYS = 120
  SIM_YEARS = 100

  def initialize
    @venus = CelestialBodies::TerrestrialPlanet.find_by(name: "Venus")
    @mars = CelestialBodies::TerrestrialPlanet.find_by(name: "Mars")
    raise "Venus not found" unless @venus
    raise "Mars not found" unless @mars

    @cycler = load_cycler_data
    @sim_data = {
      years: [],
      venus_pressure: [],
      mars_pressure: [],
      venus_co2_percentage: [],
      mars_co2_percentage: [],
      mars_o2_percentage: [],
      total_co2_transferred: 0,
      total_n2_transferred: 0,
      total_o2_produced: 0,
      trips_completed: 0
    }

    @current_day = 0
    @current_year = 0
  end

  def run
    puts "\n=== Venus-Mars Terraforming Simulation ==="
    puts "Transfer mode: #{TRANSFER_MODE.upcase}"
    puts "-------------------------------------------"
    print_planet_status(@venus)
    print_planet_status(@mars)

    reset_atmospheres
    @cycler_capacity = get_cycler_capacity
    total_days = SIM_YEARS * 365
    trips_possible = (total_days / VENUS_MARS_SYNODIC_PERIOD_DAYS).floor

    puts "\nSimulation Parameters:"
    puts "- Duration: #{SIM_YEARS} years (#{total_days} days)"
    puts "- Cycler Capacity: #{format_mass(@cycler_capacity)} per trip"
    puts "- Synodic Period: #{VENUS_MARS_SYNODIC_PERIOD_DAYS.round(1)} days"
    puts "- Max Possible Trips: #{trips_possible}"

    while @current_day < total_days
      if (@current_day % 365).zero?
        @current_year = @current_day / 365
        record_yearly_data
      end

      if (@current_day % VENUS_MARS_SYNODIC_PERIOD_DAYS).round.zero?
        perform_transfer_mission
      end

      @current_day += 1
    end

    print_simulation_results
  end

  private

  def reset_atmospheres
    puts "\nResetting atmospheres to baseline values..."
    @venus.atmosphere.reset
    @mars.atmosphere.reset
  end

  def perform_transfer_mission
    puts "\nDay #{@current_day} (Year #{@current_year}): Transfer Window Opened"
    puts "-----------------------------------------------------"
    case TRANSFER_MODE
    when RAW_TRANSFER then perform_raw_transfer
    when SELECTIVE_TRANSFER then perform_selective_transfer('CO2')
    when PROCESSED_TRANSFER then perform_processed_transfer
    else
      puts "Unknown transfer mode: #{TRANSFER_MODE}"
    end
  end

  def perform_raw_transfer
    transfer_mass = [@cycler_capacity, @venus.atmosphere.total_atmospheric_mass * 0.0001].min
    puts "Transferring total atmosphere: #{format_mass(transfer_mass)}"

    @venus.atmosphere.gases.each do |gas|
      gas_mass = transfer_mass * (gas.percentage / 100.0)
      delivered = gas_mass * 0.98
      puts " - #{gas.name}: #{format_mass(delivered)}"
      @venus.atmosphere.remove_gas(gas.name, gas_mass)
      @mars.atmosphere.add_gas(gas.name, delivered)
    end

    update_pressures
    @sim_data[:trips_completed] += 1
  end

  def perform_selective_transfer(gas_name)
    gas = @venus.atmosphere.gases.find_by(name: gas_name)
    return unless gas

    transfer_mass = [@cycler_capacity, gas.mass * 0.001].min
    delivered = transfer_mass * 0.98

    puts "Transferring #{gas_name}: #{format_mass(delivered)}"
    @venus.atmosphere.remove_gas(gas_name, transfer_mass)
    @mars.atmosphere.add_gas(gas_name, delivered)

    update_pressures
    @sim_data[:total_co2_transferred] += delivered if gas_name == 'CO2'
    @sim_data[:trips_completed] += 1
  end

  def perform_processed_transfer
    co2 = @venus.atmosphere.gases.find_by(name: 'CO2')
    n2 = @venus.atmosphere.gases.find_by(name: 'N2')
    return unless co2 && n2

    co2_mass = [@cycler_capacity * 0.8, co2.mass * 0.001].min
    n2_mass = [@cycler_capacity * 0.2, n2.mass * 0.001].min

    puts "Processing CO2: #{format_mass(co2_mass)} | N2: #{format_mass(n2_mass)}"

    @venus.atmosphere.remove_gas('CO2', co2_mass)
    @venus.atmosphere.remove_gas('N2', n2_mass)

    o2_mass = co2_mass * (16.0 / 44.0) * 0.95
    co_mass = co2_mass * (28.0 / 44.0) * 0.95

    puts "→ MOXIE Output: #{format_mass(o2_mass)} O2 | #{format_mass(co_mass)} CO"
    @venus.atmosphere.add_gas('CO', co_mass * 0.98)

    add_gas_with_molar_mass(@mars, 'N2', n2_mass * 0.98, 28.0)
    add_gas_with_molar_mass(@mars, 'O2', o2_mass * 0.98, 32.0)

    update_pressures

    @sim_data[:total_co2_transferred] += co2_mass
    @sim_data[:total_n2_transferred] += n2_mass * 0.98
    @sim_data[:total_o2_produced] += o2_mass * 0.98
    @sim_data[:trips_completed] += 1
  end

  def update_pressures
    @venus.atmosphere.update_pressure_from_mass!
    @mars.atmosphere.update_pressure_from_mass!
  end

  def add_gas_with_molar_mass(planet, gas_name, amount, fallback_molar_mass)
    planet.atmosphere.add_gas(gas_name, amount)
  rescue => e
    puts "Error adding #{gas_name}: #{e.message}"
    gas = planet.atmosphere.gases.find_by(name: gas_name)
    if gas && gas.molar_mass.nil?
      gas.update!(molar_mass: fallback_molar_mass)
      retry
    end
  end

  def load_cycler_data
    OpenStruct.new(capacity: 1.0e13)  # 10 trillion kg
  end

  def get_cycler_capacity
    @cycler.capacity
  end

  def format_mass(mass)
    "#{(mass / 1.0e12).round(2)} Tt"
  end

  def record_yearly_data
    @sim_data[:years] << @current_year
    @sim_data[:venus_pressure] << @venus.atmosphere.pressure
    @sim_data[:mars_pressure] << @mars.atmosphere.pressure

    @sim_data[:venus_co2_percentage] << gas_percentage(@venus, 'CO2')
    @sim_data[:mars_co2_percentage] << gas_percentage(@mars, 'CO2')
    @sim_data[:mars_o2_percentage] << gas_percentage(@mars, 'O2')
  end

  def gas_percentage(planet, gas_name)
    gas = planet.atmosphere.gases.find_by(name: gas_name)
    gas&.percentage || 0.0
  end

  def print_planet_status(planet)
    puts "\nStatus of #{planet.name}:"
    puts "- Pressure: #{planet.atmosphere.pressure.round(4)} atm"
    planet.atmosphere.gases.each do |gas|
      puts "  • #{gas.name}: #{gas.percentage.round(2)}%"
    end
  end

  def print_simulation_results
    puts "\n=== Simulation Complete ==="
    puts "- Years simulated: #{SIM_YEARS}"
    puts "- Transfers completed: #{@sim_data[:trips_completed]}"
    puts "- Total CO2 transferred: #{format_mass(@sim_data[:total_co2_transferred])}"
    puts "- Total N2 transferred:  #{format_mass(@sim_data[:total_n2_transferred])}"
    puts "- Total O2 produced:    #{format_mass(@sim_data[:total_o2_produced])}"
    puts "\nFinal Status:"
    print_planet_status(@venus)
    print_planet_status(@mars)
  end
end

# Run the simulation
simulation = VenusMarsAtmosphereTransferSimulation.new
simulation.run


