require 'ostruct'

class VenusMarsAtmosphereTransferSimulation
  RAW_TRANSFER = 'raw'
  SELECTIVE_TRANSFER = 'selective'
  PROCESSED_TRANSFER = 'processed'

  TRANSFER_MODE = PROCESSED_TRANSFER
  VENUS_MARS_SYNODIC_PERIOD_DAYS = 583.92
  TRANSIT_TIME_DAYS = 120
  SIM_YEARS = 100
  FLEET_SIZE = 10_000  # Number of cyclers operating simultaneously

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
    # Add this at the start of your run method
    puts "Initial values check:"
    puts "Venus radius: #{@venus.radius} meters (#{@venus.radius/1000} km)"
    puts "Venus gravity: #{@venus.gravity} m/s²"

    puts "Mars data check:"
    puts "  - radius: #{@mars.radius} meters (#{@mars.radius/1000} km)"
    puts "  - gravity: #{@mars.gravity} m/s²"
    puts "  - Initial pressure: #{@mars.atmosphere.pressure}"
    puts "  - Composition: #{@mars.atmosphere.composition}"
    puts "  - Base values: #{@mars.atmosphere.base_values}"

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
    puts "- Single Cycler Capacity: #{format_mass(@cycler_capacity)}"
    puts "- Fleet Size: #{FLEET_SIZE} cyclers"
    puts "- Total Fleet Capacity per Trip: #{format_mass(@cycler_capacity * FLEET_SIZE)}"
    puts "- Synodic Period: #{VENUS_MARS_SYNODIC_PERIOD_DAYS.round(1)} days"
    puts "- Max Possible Trips: #{trips_possible}"

    while @current_day < total_days
      if (@current_day % 365).zero?
        @current_year = @current_day / 365
        record_yearly_data
        
        # Print status every 10 years
        if @current_year % 10 == 0 && @current_year > 0
          puts "\n--- Year #{@current_year} Status ---"
          print_planet_status(@venus)
          print_planet_status(@mars)
          puts "Completed trips: #{@sim_data[:trips_completed]}"
        end
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
    
    # Record baseline mass for debugging
    @venus_baseline_mass = @venus.atmosphere.total_atmospheric_mass
    @mars_baseline_mass = @mars.atmosphere.total_atmospheric_mass
    
    puts "Venus baseline mass: #{format_mass(@venus_baseline_mass)}"
    puts "Mars baseline mass: #{format_mass(@mars_baseline_mass)}"
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
    # Use fleet capacity
    transfer_mass = [@cycler_capacity * FLEET_SIZE, @venus.atmosphere.total_atmospheric_mass * 0.001].min
    puts "Transferring total atmosphere: #{format_mass(transfer_mass)} (using #{FLEET_SIZE} cyclers)"

    @venus.atmosphere.gases.each do |gas|
      gas_mass = transfer_mass * (gas.percentage / 100.0)
      delivered = gas_mass * 0.98
      puts " - #{gas.name}: #{format_mass(delivered)}"
      @venus.atmosphere.remove_gas(gas.name, gas_mass)
      @mars.atmosphere.add_gas(gas.name, delivered)
    end

    update_pressures_with_debug
    @sim_data[:trips_completed] += 1
  end

  def perform_selective_transfer(gas_name)
    gas = @venus.atmosphere.gases.find_by(name: gas_name)
    return unless gas

    # Use fleet capacity
    transfer_mass = [@cycler_capacity * FLEET_SIZE, gas.mass * 0.005].min
    delivered = transfer_mass * 0.98

    puts "Transferring #{gas_name}: #{format_mass(delivered)} (using #{FLEET_SIZE} cyclers)"
    @venus.atmosphere.remove_gas(gas_name, transfer_mass)
    @mars.atmosphere.add_gas(gas_name, delivered)

    update_pressures_with_debug
    @sim_data[:total_co2_transferred] += delivered if gas_name == 'CO2'
    @sim_data[:trips_completed] += 1
  end

  def perform_processed_transfer
    co2 = @venus.atmosphere.gases.find_by(name: 'CO2')
    n2 = @venus.atmosphere.gases.find_by(name: 'N2')
    return unless co2 && n2

    # Use fleet capacity
    co2_mass = [@cycler_capacity * 0.8 * FLEET_SIZE, co2.mass * 0.005].min
    n2_mass = [@cycler_capacity * 0.2 * FLEET_SIZE, n2.mass * 0.005].min

    puts "Processing CO2: #{format_mass(co2_mass)} | N2: #{format_mass(n2_mass)} (using #{FLEET_SIZE} cyclers)"

    @venus.atmosphere.remove_gas('CO2', co2_mass)
    @venus.atmosphere.remove_gas('N2', n2_mass)

    o2_mass = co2_mass * (16.0 / 44.0) * 0.95
    co_mass = co2_mass * (28.0 / 44.0) * 0.95

    puts "→ MOXIE Output: #{format_mass(o2_mass)} O2 | #{format_mass(co_mass)} CO"
    @venus.atmosphere.add_gas('CO', co_mass * 0.98)

    n2_delivered = n2_mass * 0.98
    o2_delivered = o2_mass * 0.98
    
    add_gas_with_molar_mass(@mars, 'N2', n2_delivered, 28.0)
    add_gas_with_molar_mass(@mars, 'O2', o2_delivered, 32.0)

    update_pressures_with_debug

    @sim_data[:total_co2_transferred] += co2_mass
    @sim_data[:total_n2_transferred] += n2_delivered
    @sim_data[:total_o2_produced] += o2_delivered
    @sim_data[:trips_completed] += 1

    monitor_mars_pressure do
      @mars.atmosphere.update_pressure_from_mass!
    end

    # Add to perform_processed_transfer after adding gases
    # @mars.atmosphere.update_column(:pressure, @mars.atmosphere.calculate_pressure)

    # Add this right after adding gases to Mars
    mars_atm_mass = @mars.atmosphere.total_atmospheric_mass
    mars_gravity = @mars.gravity
    mars_radius = @mars.radius

    # Calculate expected pressure correctly - NO CONVERSION NEEDED!
    mars_surface_area = 4 * Math::PI * (mars_radius**2)  # Remove the * 1000
    mars_pressure_pascals = (mars_atm_mass * mars_gravity) / mars_surface_area
    mars_pressure_atm = mars_pressure_pascals / 101325.0

    # Directly update the pressure column, bypassing any callbacks/validations
    @mars.atmosphere.update_column(:pressure, mars_pressure_atm)
  end

  def update_pressures_with_debug
    # Get masses before update
    venus_old_mass = @venus.atmosphere.total_atmospheric_mass
    mars_old_mass = @mars.atmosphere.total_atmospheric_mass
    
    # Get pressures before update
    venus_old_pressure = @venus.atmosphere.pressure
    mars_old_pressure = @mars.atmosphere.pressure
    
    # Update the pressures
    @venus.atmosphere.update_pressure_from_mass!
    @mars.atmosphere.update_pressure_from_mass!
    
    # Get new values after update
    venus_new_mass = @venus.atmosphere.total_atmospheric_mass
    mars_new_mass = @mars.atmosphere.total_atmospheric_mass
    venus_new_pressure = @venus.atmosphere.pressure
    mars_new_pressure = @mars.atmosphere.pressure
    
    # Calculate actual ratios
    venus_mass_ratio = venus_new_mass / venus_old_mass
    mars_mass_ratio = mars_new_mass / mars_old_mass
    venus_pressure_ratio = venus_new_pressure / venus_old_pressure
    mars_pressure_ratio = mars_new_pressure / mars_old_pressure
    
    # Print debug information
    puts "\nDEBUG: Pressure Update"
    puts "Venus: Mass #{format_mass(venus_old_mass)} → #{format_mass(venus_new_mass)} (#{format_ratio(venus_mass_ratio)})"
    puts "Venus: Pressure #{format_pressure(venus_old_pressure)} → #{format_pressure(venus_new_pressure)} (#{format_ratio(venus_pressure_ratio)})"
    
    puts "Mars: Mass #{format_mass(mars_old_mass)} → #{format_mass(mars_new_mass)} (#{format_ratio(mars_mass_ratio)})"
    puts "Mars: Pressure #{format_pressure(mars_old_pressure)} → #{format_pressure(mars_new_pressure)} (#{format_ratio(mars_pressure_ratio)})"
    
    # Calculate progress percentage
    venus_progress = ((@venus_baseline_mass - venus_new_mass) / (@venus_baseline_mass * 0.01)) * 100
    mars_progress = ((mars_new_mass - @mars_baseline_mass) / (@mars_baseline_mass * 10)) * 100
    
    puts "Venus mass reduced by: #{venus_progress.round(2)}% of 1% target"
    puts "Mars mass increased by: #{mars_progress.round(2)}% of 1000% target"
  end

  def add_gas_with_molar_mass(planet, gas_name, amount, fallback_molar_mass)
    begin
      planet.atmosphere.add_gas(gas_name, amount)
    rescue => e
      puts "Error adding #{gas_name}: #{e.message}"
      gas = planet.atmosphere.gases.find_by(name: gas_name)
      if gas && gas.molar_mass.nil?
        puts "Setting molar mass of #{gas_name} to #{fallback_molar_mass}"
        gas.update!(molar_mass: fallback_molar_mass)
        retry
      else
        puts "Could not add gas #{gas_name}: #{e.message}"
      end
    end
  end

  def monitor_mars_pressure
    old_pressure = @mars.atmosphere.pressure
    yield # Run the code we want to monitor
    new_pressure = @mars.atmosphere.reload.pressure
    
    if new_pressure == 0.006 && old_pressure != 0.006
      puts "ALERT: Mars pressure fixed to 0.006 atm after operation!"
      puts "  - Before: #{old_pressure}"
      puts "  - After: #{new_pressure}"
      puts "  - Backtrace: #{caller[0..5].join("\n    ")}"
    end
  end

  def load_cycler_data
    OpenStruct.new(capacity: 1.0e13)  # 10 trillion kg per cycler
  end

  def get_cycler_capacity
    @cycler.capacity
  end

  def format_mass(mass)
    if mass >= 1.0e18
      "#{(mass / 1.0e18).round(2)} Exatons"
    elsif mass >= 1.0e15
      "#{(mass / 1.0e15).round(2)} Pt"
    elsif mass >= 1.0e12
      "#{(mass / 1.0e12).round(2)} Tt"
    elsif mass >= 1.0e9
      "#{(mass / 1.0e9).round(2)} Gt"
    elsif mass >= 1.0e6
      "#{(mass / 1.0e6).round(2)} Mt"
    else
      "#{mass.round(2)} kg"
    end
  end

  def format_pressure(pressure_atm)
    if pressure_atm >= 0.1
      # Use atm for Earth and Venus
      "#{pressure_atm.round(3)} atm"
    elsif pressure_atm >= 0.0001
      # Use millibars for Mars and thin atmospheres
      mbar = pressure_atm * 1013.25
      "#{mbar.round(2)} mbar"
    elsif pressure_atm >= 0.00000001
      # Use microbars for very thin atmospheres (1 µbar = 0.001 mbar)
      ubar = pressure_atm * 1013250
      "#{ubar.round(2)} µbar"
    else
      # Use pascals for extremely thin atmospheres
      pascals = pressure_atm * 101325
      "#{pascals.round(2)} Pa"
    end
  end

  def format_ratio(ratio)
    # For ratios close to 1, show percentage change
    if (ratio > 0.9 && ratio < 1.1)
      change = ((ratio - 1) * 100).round(2)
      sign = change >= 0 ? "+" : ""
      "#{sign}#{change}%"
    else
      # For bigger changes, show a simple multiplier
      "×#{ratio.round(2)}"
    end
  end

  def record_yearly_data
    @sim_data[:years] << @current_year
    @sim_data[:venus_pressure] << @venus.atmosphere.pressure
    @sim_data[:mars_pressure] << @mars.atmosphere.pressure

    @sim_data[:venus_co2_percentage] << gas_percentage(@venus, 'CO2')
    @sim_data[:mars_co2_percentage] << gas_percentage(@mars, 'CO2')
    @sim_data[:mars_o2_percentage] << gas_percentage(@mars, 'O2')
    
    # Print every 10th year to track progress
    if @current_year % 10 == 0 && @current_year > 0
      print_progress_status
    end
  end

  def gas_percentage(planet, gas_name)
    gas = planet.atmosphere.gases.find_by(name: gas_name)
    gas&.percentage || 0.0
  end

  def print_planet_status(planet)
    # Force a reload to ensure we see the latest DB value
    planet.reload
    
    # Get the atmosphere pressure directly from DB with reload
    db_pressure = planet.atmosphere.reload.pressure
    
    # Calculate the expected pressure
    atm_mass = planet.atmosphere.total_atmospheric_mass
    gravity = planet.gravity
    radius = planet.radius
    
    # Radius in our JSON data is already in meters, don't multiply by 1000
    surface_area = 4 * Math::PI * (radius**2)
    
    calculated_pressure = (atm_mass * gravity) / surface_area / 101325.0
    
    puts "\nStatus of #{planet.name}:"
    puts "- DB Pressure: #{format_pressure(db_pressure)}"
    puts "- Calculated Pressure: #{format_pressure(calculated_pressure)}"
    puts "- Match?: #{(db_pressure - calculated_pressure).abs < 0.001 ? 'YES' : 'NO - Database value differs!'}"
    puts "- Total Mass: #{format_mass(planet.atmosphere.total_atmospheric_mass)}"
    
    planet.atmosphere.gases.each do |gas|
      puts "  • #{gas.name}: #{gas.percentage.round(2)}% (#{format_mass(gas.mass)})"
    end
  end
  
  def print_progress_status
    if @sim_data[:years].size > 10
      # Calculate rate of change over last 10 years
      venus_pressure_change = @sim_data[:venus_pressure].last - @sim_data[:venus_pressure][-10]
      mars_pressure_change = @sim_data[:mars_pressure].last - @sim_data[:mars_pressure][-10]
      
      venus_yearly_change = venus_pressure_change / 10.0
      mars_yearly_change = mars_pressure_change / 10.0
      
      # Estimate time to target
      if mars_yearly_change > 0
        # Convert to millibars for clearer representation
        current_mbar = @sim_data[:mars_pressure].last * 1013.25
        target_mbar = 101.325  # 0.1 atm
        years_to_target = (target_mbar - current_mbar) / (mars_yearly_change * 1013.25)
        
        puts "Current Mars pressure: #{current_mbar.round(2)} mbar"
        puts "At current rate (+#{(mars_yearly_change * 1013.25).round(4)} mbar/year), Mars will reach:"
        puts "  - 10 mbar (1% Earth) in #{(10 - current_mbar) / (mars_yearly_change * 1013.25).round} years"
        puts "  - 100 mbar (10% Earth) in #{years_to_target.round} years"
        puts "  - 500 mbar (50% Earth) in #{((500 - current_mbar) / (mars_yearly_change * 1013.25)).round} years"
      end
    end
  end

  def print_simulation_results
    venus_pressure_change = @sim_data[:venus_pressure].last - @sim_data[:venus_pressure].first
    mars_pressure_change = @sim_data[:mars_pressure].last - @sim_data[:mars_pressure].first
    
    # Convert to millibars for Mars
    mars_initial_mbar = @sim_data[:mars_pressure].first * 1013.25
    mars_final_mbar = @sim_data[:mars_pressure].last * 1013.25
    mars_change_mbar = mars_pressure_change * 1013.25
    
    puts "\n=== Simulation Complete ==="
    puts "- Years simulated: #{SIM_YEARS}"
    puts "- Transfers completed: #{@sim_data[:trips_completed]}"
    puts "- Total CO2 transferred: #{format_mass(@sim_data[:total_co2_transferred])}"
    puts "- Total N2 transferred:  #{format_mass(@sim_data[:total_n2_transferred])}"
    puts "- Total O2 produced:    #{format_mass(@sim_data[:total_o2_produced])}"
    
    puts "\nAtmospheric Changes:"
    puts "- Venus pressure: #{format_pressure(@sim_data[:venus_pressure].first)} → #{format_pressure(@sim_data[:venus_pressure].last)}"
    puts "  (#{venus_pressure_change.round(8)} atm change, #{format_ratio(@sim_data[:venus_pressure].last / @sim_data[:venus_pressure].first)} relative change)"
    
    puts "- Mars pressure: #{mars_initial_mbar >= 0.1 ? mars_initial_mbar.round(2) : mars_initial_mbar.round(4)} mbar → #{mars_final_mbar.round(2)} mbar"
    puts "  (#{mars_change_mbar.round(2)} mbar increase, #{format_ratio(@sim_data[:mars_pressure].last / @sim_data[:mars_pressure].first)} relative change)"
    
    puts "- Venus CO2: #{@sim_data[:venus_co2_percentage].first.round(2)}% → #{@sim_data[:venus_co2_percentage].last.round(2)}%"
    puts "- Mars CO2: #{@sim_data[:mars_co2_percentage].first.round(2)}% → #{@sim_data[:mars_co2_percentage].last.round(2)}%"
    puts "- Mars O2: #{@sim_data[:mars_o2_percentage].first.round(2)}% → #{@sim_data[:mars_o2_percentage].last.round(2)}%"
    
    # Show progress to Mars habitability thresholds
    final_mbar = @sim_data[:mars_pressure].last * 1013.25
    yearly_rate = (mars_final_mbar - mars_initial_mbar) / SIM_YEARS
    
    puts "\nMars Terraforming Milestones:"
    puts "- Current pressure: #{final_mbar.round(2)} mbar (#{(@sim_data[:mars_pressure].last * 100).round(4)}% of Earth)"
    puts "- Rate of increase: #{yearly_rate.round(4)} mbar per year"
    puts "- Time to 10 mbar (plants can grow): #{((10 - final_mbar) / yearly_rate).round} years"
    puts "- Time to 100 mbar (minimal breathing): #{((100 - final_mbar) / yearly_rate).round} years"
    puts "- Time to 500 mbar (comfortable breathing): #{((500 - final_mbar) / yearly_rate).round} years"
    
    puts "\nFinal Status:"
    print_planet_status(@venus)
    print_planet_status(@mars)
  end

  def display_mars_pressure_calculation(mass, gravity, radius, expected_pressure, actual_pressure)
    surface_area = 4 * Math::PI * (radius * 1000)**2
    
    puts "Mars pressure calculation:"
    puts "  - Mass: #{format_mass(mass)}"
    puts "  - Gravity: #{gravity.round(2)} m/s²"
    puts "  - Radius: #{radius} km"
    
    # Calculate pressure in all useful units
    pascals = (mass * gravity) / surface_area
    atm = pascals / 101325.0
    mbar = atm * 1013.25
    ubar = mbar * 1000
    
    # Choose the appropriate unit based on magnitude
    if atm >= 0.1
      puts "  - Expected pressure: #{atm.round(4)} atm"
    elsif mbar >= 0.1
      puts "  - Expected pressure: #{mbar.round(2)} mbar (#{atm.round(6)} atm)"
    else
      puts "  - Expected pressure: #{ubar.round(2)} µbar (#{atm.round(8)} atm)"
    end
    
    puts "  - Actual pressure: #{format_pressure(actual_pressure)}"
    
    if (atm - actual_pressure).abs > 0.00001
      puts "  - WARNING: Expected and actual pressure differ! Check database update."
    end
  end
end

# Run the simulation
simulation = VenusMarsAtmosphereTransferSimulation.new
simulation.run