# Venus-Mars Atmosphere Transfer Simulation
# A test script to simulate transferring gases from Venus to Mars to terraform Mars

class VenusMarsAtmosphereTransferSimulation
  # Transfer modes
  RAW_TRANSFER = 'raw'    # Transfer atmosphere without processing
  SELECTIVE_TRANSFER = 'selective'  # Transfer only CO2
  PROCESSED_TRANSFER = 'processed'  # Process CO2 into O2 and transfer with N2
  
  # Simulation parameters
  TRANSFER_MODE = PROCESSED_TRANSFER
  FLEET_SIZE = 50_000  # Number of cyclers operating simultaneously
  VENUS_MARS_SYNODIC_PERIOD_DAYS = 583.92 # Time between optimal launch windows
  TRANSIT_TIME_DAYS = 120 # Average transit time between planets
  SIM_YEARS = 100 # Simulation length in Earth years
  
  def initialize
    @venus = CelestialBodies::TerrestrialPlanet.find_by(name: "Venus")
    @mars = CelestialBodies::TerrestrialPlanet.find_by(name: "Mars")
    
    raise "Venus not found in database" unless @venus
    raise "Mars not found in database" unless @mars
    
    @cycler = load_cycler_data
    
    # Track simulation data for reporting
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
    
    # Time tracking
    @current_day = 0
    @current_year = 0
  end
  
  def run
    puts "Starting Venus-Mars Terraforming Simulation"
    puts "============================================"
    puts "Transfer mode: #{TRANSFER_MODE.upcase}"
    puts "Initial conditions:"
    print_planet_status(@venus)
    print_planet_status(@mars)
    
    # Reset atmospheres to baseline
    reset_atmospheres
    
    # Get cycler capacity from data
    @cycler_capacity = get_cycler_capacity
    
    # Calculate number of trips based on synodic period
    total_days = SIM_YEARS * 365
    trips_possible = (total_days / VENUS_MARS_SYNODIC_PERIOD_DAYS).floor
    
    puts "\nSimulation parameters:"
    puts "- Running for #{SIM_YEARS} years (#{total_days} days)"
    puts "- Gas Giant Cycler capacity: #{format_mass(@cycler_capacity)} per cycler"
    puts "- Fleet size: #{FLEET_SIZE} cyclers (total capacity: #{format_mass(@cycler_capacity * FLEET_SIZE)})"
    puts "- Synodic period: #{VENUS_MARS_SYNODIC_PERIOD_DAYS.round(1)} days"
    puts "- Transit time: #{TRANSIT_TIME_DAYS} days"
    puts "- Maximum possible trips: #{trips_possible}"
    puts "- Transfer mode: #{TRANSFER_MODE}"
    
    puts "\nBeginning simulation..."
    
    # Main simulation loop
    while @current_day < total_days
      # Record data at the start of each year
      if (@current_day % 365) == 0
        @current_year = @current_day / 365
        record_yearly_data
      end
      
      # Check if we're at a launch window
      if (@current_day % VENUS_MARS_SYNODIC_PERIOD_DAYS).round == 0
        perform_transfer_mission
      end
      
      # Advance time
      @current_day += 1
    end
    
    print_simulation_results
  end
  
  private
  
  def reset_atmospheres
    puts "\nResetting atmospheres to baseline values..."
    
    @venus.atmosphere.reset
    @mars.atmosphere.reset
    
    puts "Venus atmosphere reset: #{@venus.atmosphere.pressure.round(2)} atm, CO2: #{get_gas_percentage(@venus, 'CO2').round(2)}%"
    puts "Mars atmosphere reset: #{@mars.atmosphere.pressure.round(4)} atm, CO2: #{get_gas_percentage(@mars, 'CO2').round(2)}%"
  end
  
  def perform_transfer_mission
    puts "\nDay #{@current_day} (Year #{@current_year}): Launch window opened"
    puts "-----------------------------------------------------"
    
    case TRANSFER_MODE
    when RAW_TRANSFER
      perform_raw_transfer
    when SELECTIVE_TRANSFER
      perform_selective_transfer('CO2')
    when PROCESSED_TRANSFER
      perform_processed_transfer
    end
  end
  
  # Transfer raw atmosphere with all gases proportionally
  def perform_raw_transfer
    venus_atm_mass = @venus.atmosphere.total_atmospheric_mass
    mars_atm_mass = @mars.atmosphere.total_atmospheric_mass
    
    # Use fleet capacity
    total_transfer_mass = [get_cycler_capacity * FLEET_SIZE, venus_atm_mass * 0.001].min
    
    puts "Total atmosphere to transfer: #{format_mass(total_transfer_mass)}"
    
    # Calculate the new masses and pressures
    new_venus_mass = venus_atm_mass - total_transfer_mass
    new_mars_mass = mars_atm_mass + (total_transfer_mass * 0.98) # 2% loss during transfer
    
    # Transfer each gas in proportion to its percentage in Venus atmosphere
    venus_gases = @venus.atmosphere.gases
    
    venus_gases.each do |gas|
      gas_percentage = gas.percentage / 100.0
      gas_mass_to_transfer = total_transfer_mass * gas_percentage
      
      puts "Transferring #{format_mass(gas_mass_to_transfer)} of #{gas.name} (#{gas.percentage.round(2)}% of Venus atmosphere)"
      
      # Remove from Venus and add to Mars
      @venus.atmosphere.remove_gas(gas.name, gas_mass_to_transfer)
      @mars.atmosphere.add_gas(gas.name, gas_mass_to_transfer * 0.98)
    end
    
    # Use debug function to update pressure
    update_pressure_debug(@venus, venus_atm_mass, new_venus_mass)
    update_pressure_debug(@mars, mars_atm_mass, new_mars_mass)
    
    # Track statistics
    venus_co2_gas = @venus.atmosphere.gases.find_by(name: 'CO2')
    @sim_data[:total_co2_transferred] += total_transfer_mass * (venus_co2_gas.percentage / 100.0) * 0.98
    @sim_data[:trips_completed] += 1
    
    # Print status after transfer
    print_planet_status(@venus)
    print_planet_status(@mars)
    
    puts "Return transit to Venus for next cycle..."
  end
  
  # Transfer only a specific gas
  def perform_selective_transfer(gas_name)
    gas = @venus.atmosphere.gases.find_by(name: gas_name)
    return unless gas
    
    # Use fleet capacity
    gas_to_transfer = [get_cycler_capacity * FLEET_SIZE, gas.mass * 0.01].min
    
    puts "Selectively extracting #{format_mass(gas_to_transfer)} of #{gas_name} from Venus..."
    @venus.atmosphere.remove_gas(gas_name, gas_to_transfer)
    
    # Apply efficiency loss
    gas_delivered = gas_to_transfer * 0.98
    puts "Delivering #{format_mass(gas_delivered)} of #{gas_name} to Mars..."
    @mars.atmosphere.add_gas(gas_name, gas_delivered)
    
    # Update pressures with debug function
    venus_atm_mass = @venus.atmosphere.total_atmospheric_mass + gas_to_transfer
    mars_atm_mass = @mars.atmosphere.total_atmospheric_mass - gas_delivered
    
    update_pressure_debug(@venus, venus_atm_mass, venus_atm_mass - gas_to_transfer)
    update_pressure_debug(@mars, mars_atm_mass, mars_atm_mass + gas_delivered)
    
    # Track statistics
    if gas_name == 'CO2'
      @sim_data[:total_co2_transferred] += gas_delivered
    end
    @sim_data[:trips_completed] += 1
    
    # Print status after transfer
    print_planet_status(@venus)
    print_planet_status(@mars)
    
    puts "Return transit to Venus for next cycle..."
  end
  
  # Process CO2 into O2 and CO (MOXIE-style electrolysis), return CO to Venus
  def perform_processed_transfer
    venus_co2_gas = @venus.atmosphere.gases.find_by(name: 'CO2')
    venus_n2_gas = @venus.atmosphere.gases.find_by(name: 'N2')
    
    return unless venus_co2_gas && venus_n2_gas
    
    # Use fleet capacity
    co2_to_process = [get_cycler_capacity * 0.8 * FLEET_SIZE, venus_co2_gas.mass * 0.01].min
    n2_to_transfer = [get_cycler_capacity * 0.2 * FLEET_SIZE, venus_n2_gas.mass * 0.01].min
    
    puts "Processing #{format_mass(co2_to_process)} of CO2 from Venus (using #{FLEET_SIZE} cyclers)..."
    puts "Extracting #{format_mass(n2_to_transfer)} of N2 from Venus..."
    
    # Remove gases from Venus
    @venus.atmosphere.remove_gas('CO2', co2_to_process)
    @venus.atmosphere.remove_gas('N2', n2_to_transfer)
    
    # Process CO2 using MOXIE-style electrolysis: CO2 → CO + ½O2
    # CO2 molecular weight = 44, CO molecular weight = 28, O2 molecular weight = 32
    # For every 44g of CO2, we get 28g of CO and 16g of O2
    o2_produced = co2_to_process * (16.0/44.0) * 0.95  # 95% efficiency
    co_produced = co2_to_process * (28.0/44.0) * 0.95  # 95% efficiency
    
    puts "Converting CO2 to CO and O2 (MOXIE process)..."
    puts "Producing #{format_mass(o2_produced)} of O2 and #{format_mass(co_produced)} of CO..."
    
    # Return CO to Venus instead of taking it to Mars
    puts "Returning CO to Venus atmosphere..."
    @venus.atmosphere.add_gas('CO', co_produced * 0.98) # 2% loss in transfer
    
    # Transfer only N2 and O2 to Mars
    n2_delivered = n2_to_transfer * 0.98  # 98% efficiency
    o2_delivered = o2_produced * 0.98     # 98% efficiency
    
    puts "Delivering #{format_mass(n2_delivered)} of N2 to Mars..."
    puts "Delivering #{format_mass(o2_delivered)} of O2 to Mars..."
    
    # Check if gases exist on Mars and add them with proper molar mass
    add_gas_with_molar_mass(@mars, 'N2', n2_delivered, 28.0)  # Nitrogen molecular weight
    add_gas_with_molar_mass(@mars, 'O2', o2_delivered, 32.0)  # Oxygen molecular weight
    
    # Update pressures directly
    venus_atm_mass = @venus.atmosphere.total_atmospheric_mass
    mars_atm_mass = @mars.atmosphere.total_atmospheric_mass
    
    # Net change to Venus: removed CO2 and N2, added CO
    total_removed_from_venus = co2_to_process + n2_to_transfer
    total_added_to_venus = co_produced * 0.98
    
    venus_new_mass = venus_atm_mass - total_removed_from_venus + total_added_to_venus
    mars_new_mass = mars_atm_mass + n2_delivered + o2_delivered
    
    # Update pressures with debug function
    update_pressure_debug(@venus, venus_atm_mass, venus_new_mass)
    update_pressure_debug(@mars, mars_atm_mass, mars_new_mass)
    
    # Track statistics
    @sim_data[:total_co2_transferred] += co2_to_process
    @sim_data[:total_n2_transferred] += n2_delivered
    @sim_data[:total_o2_produced] += o2_delivered
    @sim_data[:trips_completed] += 1
    
    # Print status after transfer
    print_planet_status(@venus)
    print_planet_status(@mars)
    
    puts "Return transit to Venus for next cycle..."
  end

  # Helper method to add a gas (simplified since AtmosphereConcern is fixed)
  def add_gas_with_molar_mass(planet, gas_name, amount, fallback_molar_mass)
    begin
      # Use the fixed add_gas method which now handles molar_mass correctly
      planet.atmosphere.add_gas(gas_name, amount)
    rescue => e
      puts "Error adding gas #{gas_name}: #{e.message}"
      
      # If we still get an error, try to fix the existing gas
      gas = planet.atmosphere.gases.find_by(name: gas_name)
      if gas && gas.molar_mass.nil?
        puts "Fixing molar mass for existing gas #{gas_name}"
        gas.update!(molar_mass: fallback_molar_mass)
        # Try again
        planet.atmosphere.add_gas(gas_name, amount)
      end
    end
  end
  
  def record_yearly_data
    @sim_data[:years] << @current_year
    @sim_data[:venus_pressure] << @venus.atmosphere.pressure
    @sim_data[:mars_pressure] << @mars.atmosphere.pressure
    @sim_data[:venus_co2_percentage] << get_gas_percentage(@venus, 'CO2')
    @sim_data[:mars_co2_percentage] << get_gas_percentage(@mars, 'CO2')
    @sim_data[:mars_o2_percentage] << get_gas_percentage(@mars, 'O2')
    
    if @current_year % 10 == 0
      puts "\n--- Year #{@current_year} Status ---"
      print_planet_status(@venus)
      print_planet_status(@mars)
      puts "Total CO2 processed: #{format_mass(@sim_data[:total_co2_transferred])}"
      
      if TRANSFER_MODE == PROCESSED_TRANSFER
        puts "Total O2 produced for Mars: #{format_mass(@sim_data[:total_o2_produced])}"
        puts "Total N2 transferred to Mars: #{format_mass(@sim_data[:total_n2_transferred])}"
      end
      
      puts "Completed trips: #{@sim_data[:trips_completed]}"
    end
  end
  
  def print_planet_status(planet)
    atmo = planet.atmosphere
    pressure = atmo.pressure
    temp = planet.surface_temperature
    
    co2_percentage = get_gas_percentage(planet, 'CO2')
    o2_percentage = get_gas_percentage(planet, 'O2')
    n2_percentage = get_gas_percentage(planet, 'N2')
    
    case planet.name
    when "Venus"
      target = "reducing"
      target_pressure = 90.0 # Starting pressure was ~92
    when "Mars"
      target = "increasing"
      target_pressure = 0.1 # 1/10th of Earth's pressure
    end
    
    if planet.name == "Mars"
      progress = (pressure / target_pressure) * 100
      progress_display = progress > 100 ? "100%" : "#{progress.round(2)}%"
    else
      initial = 92.0
      progress = ((initial - pressure) / (initial - target_pressure)) * 100
      progress_display = progress > 100 ? "100%" : "#{progress.round(2)}%"
    end
    
    gas_info = "CO2: #{co2_percentage.round(2)}%"
    
    if TRANSFER_MODE == PROCESSED_TRANSFER
      gas_info += ", O2: #{o2_percentage.round(2)}%, N2: #{n2_percentage.round(2)}%"
    end
    
    puts "#{planet.name}: Pressure: #{pressure.round(4)} atm (#{target} to #{target_pressure}), " +
         "Temperature: #{temp}K, #{gas_info} " +
         "Progress: #{progress_display}"
  end
  
  def get_gas_percentage(planet, gas_name)
    gas = planet.atmosphere.gases.find_by(name: gas_name)
    return 0.0 unless gas
    gas.percentage
  end
  
  def format_mass(kg)
    if kg >= 1_000_000_000_000
      "#{(kg / 1_000_000_000_000.0).round(2)} Tt"
    elsif kg >= 1_000_000_000
      "#{(kg / 1_000_000_000.0).round(2)} Gt"
    elsif kg >= 1_000_000
      "#{(kg / 1_000_000.0).round(2)} Mt"
    elsif kg >= 1_000
      "#{(kg / 1_000.0).round(2)} t"
    else
      "#{kg.round(2)} kg"
    end
  end
  
  def load_cycler_data
    file_path = "/home/galaxy_game/app/data/crafts/transport/cyclers/gas_giant_cycler_data.json"
    if File.exist?(file_path)
      JSON.parse(File.read(file_path))
    else
      puts "Warning: Cycler data not found at #{file_path}. Using default values."
      {
        "name" => "Gas Giant Cycler",
        "storage_capacity" => {
          "cryogenic_storage" => 500_000_000,
          "unit" => "kilogram"
        }
      }
    end
  end
  
  def get_cycler_capacity
    # Get from the cycler data if available
    if @cycler && @cycler.dig('storage_capacity', 'cryogenic_storage')
      capacity = @cycler.dig('storage_capacity', 'cryogenic_storage')
      puts "Using cycler data: capacity = #{format_mass(capacity)}"
      return capacity
    end
    
    # Fallback value if cycler data isn't available or doesn't contain capacity
    fallback = 500_000 # 500 thousand kg (500 metric tons)
    puts "Warning: Using fallback cycler capacity of #{format_mass(fallback)}"
    return fallback
  end
  
  def print_simulation_results
    puts "\n================================================"
    puts "Venus-Mars Terraforming Simulation Results"
    puts "================================================"
    puts "Simulation ran for #{SIM_YEARS} years (#{@current_day} days)"
    
    if TRANSFER_MODE == PROCESSED_TRANSFER
      puts "Total CO2 processed: #{format_mass(@sim_data[:total_co2_transferred])}"
      puts "Total O2 produced for Mars: #{format_mass(@sim_data[:total_o2_produced])}"
      puts "Total N2 transferred to Mars: #{format_mass(@sim_data[:total_n2_transferred])}"
    else
      puts "Total CO2 transferred: #{format_mass(@sim_data[:total_co2_transferred])}"
    end
    
    puts "Completed trips: #{@sim_data[:trips_completed]}"
    
    puts "\nVenus atmospheric pressure change: #{@sim_data[:venus_pressure].first.round(2)} → #{@sim_data[:venus_pressure].last.round(2)} atm"
    puts "Mars atmospheric pressure change: #{@sim_data[:mars_pressure].first.round(4)} → #{@sim_data[:mars_pressure].last.round(4)} atm"
    
    venus_co2_change = @sim_data[:venus_co2_percentage].first - @sim_data[:venus_co2_percentage].last
    mars_co2_change = @sim_data[:mars_co2_percentage].last - @sim_data[:mars_co2_percentage].first
    
    puts "Venus CO2 percentage change: #{@sim_data[:venus_co2_percentage].first.round(2)}% → #{@sim_data[:venus_co2_percentage].last.round(2)}% (#{venus_co2_change.round(2)}% decrease)"
    puts "Mars CO2 percentage change: #{@sim_data[:mars_co2_percentage].first.round(2)}% → #{@sim_data[:mars_co2_percentage].last.round(2)}% (#{mars_co2_change.round(2)}% increase)"
    
    if TRANSFER_MODE == PROCESSED_TRANSFER
      mars_o2_change = @sim_data[:mars_o2_percentage].last - @sim_data[:mars_o2_percentage].first
      puts "Mars O2 percentage change: #{@sim_data[:mars_o2_percentage].first.round(2)}% → #{@sim_data[:mars_o2_percentage].last.round(2)}% (#{mars_o2_change.round(2)}% increase)"
    end
    
    # Calculate time to reach target pressure on Mars
    initial_rate = (@sim_data[:mars_pressure][10] - @sim_data[:mars_pressure][0]) / 10.0 # Pressure increase per year
    target_pressure = 0.1 # 1/10th of Earth's
    years_to_target = initial_rate > 0 ? (target_pressure - @sim_data[:mars_pressure][0]) / initial_rate : 0
    
    puts "\nAt current transfer rate, Mars would reach 0.1 atm in approximately #{years_to_target.round} years."
    
    # Recommendations
    puts "\nRecommendations:"
    puts "- Deploy #{(@sim_data[:trips_completed] * 3).round} additional cyclers to reduce terraforming timeline."
    
    if TRANSFER_MODE == PROCESSED_TRANSFER
      puts "- Increase CO2 processing capacity to produce more O2 for future colonists."
      puts "- Begin surface carbon sequestration to create stable carbon sinks on Mars."
    else
      puts "- Consider switching to processed transfer mode to create a more Earth-like atmosphere."
      puts "- Process CO2 into O2 and fixed carbon to prepare for future plant life."
    end
    
    puts "- Begin introducing heat-trapping gases to raise Mars temperature."
  end

  def update_pressure_debug(planet, old_mass, new_mass)
    old_pressure = planet.atmosphere.pressure
    ratio = new_mass / old_mass
    new_pressure = old_pressure * ratio
    
    puts "DEBUG: #{planet.name} pressure calculation"
    puts "  Old mass: #{format_mass(old_mass)}"
    puts "  New mass: #{format_mass(new_mass)}"
    puts "  Mass ratio: #{ratio}"
    puts "  Old pressure: #{old_pressure} atm"
    puts "  New pressure: #{new_pressure} atm"
    
    planet.atmosphere.update!(pressure: new_pressure)
    puts "  Verified new pressure: #{planet.atmosphere.reload.pressure} atm"
  end
end

# Run the simulation
simulation = VenusMarsAtmosphereTransferSimulation.new
simulation.run