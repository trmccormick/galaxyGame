class PlanetUpdateService
  # Constants for different time scales
  SIMULATION_DETAIL = {
    short: { days: 0..30, interval: 1 },       # Daily updates for first month
    medium: { days: 31..365, interval: 7 },    # Weekly updates for first year
    long: { days: 366..3650, interval: 30 },   # Monthly updates for decade
    very_long: { days: 3651..Float::INFINITY, interval: 365 } # Yearly for longer
  }

  def initialize(planet, time_skipped)
    @planet = planet
    @time_skipped = time_skipped # in days
    @events = [] # Collect interesting events during simulation
  end
  
  def run
    # Check if the object is a planet using class instead of type
    is_planet = @planet.is_a?(CelestialBodies::CelestialBody) && 
                !@planet.is_a?(CelestialBodies::Star) &&
                (@planet.class.name.include?('::Planets::') || 
                 @planet.is_a?(CelestialBodies::Planets::Planet))
    
    return unless is_planet
    
    if @time_skipped <= 30
      simulate_detailed
    else
      simulate_progressive
    end
    log_simulation_results
    @events
  end
  
  private
  
  # Detailed simulation for short time periods
  def simulate_detailed
    # Process each sphere in appropriate order
    process_atmosphere
    process_geosphere
    process_hydrosphere
    process_biosphere
    
    # Handle interfaces between spheres
    process_sphere_interfaces
    
    # Update planet properties
    update_planet_properties
  end
  
  # Progressive simulation for longer time periods
  def simulate_progressive
    remaining_time = @time_skipped
    elapsed = 0
    
    # Determine appropriate simulation intervals
    SIMULATION_DETAIL.each do |detail_level, config|
      range = config[:days]
      interval = config[:interval]
      
      # Calculate how much time to simulate at this detail level
      time_at_this_level = [remaining_time, range.max].min - elapsed
      next if time_at_this_level <= 0
      
      # Simulate in steps of the appropriate interval
      full_steps = (time_at_this_level / interval).floor
      
      # Debug
      Rails.logger.debug "#{detail_level}: #{full_steps} steps of #{interval} days each"
      
      full_steps.times do
        # Run a simulation step at this interval
        step_simulation(interval)
        elapsed += interval
        check_for_events(elapsed)
      end
      
      # Handle any remaining partial interval
      remaining_partial = time_at_this_level % interval
      if remaining_partial > 0
        step_simulation(remaining_partial)
        elapsed += remaining_partial
        check_for_events(elapsed)
      end
      
      # Update remaining time
      remaining_time -= time_at_this_level
      break if remaining_time <= 0
    end
  end
  
  # Run a single simulation step
  def step_simulation(days)
    # Process each sphere
    process_atmosphere(days)
    process_geosphere(days)
    process_hydrosphere(days)
    process_biosphere(days)
    
    # Process interfaces
    process_sphere_interfaces
    
    # Update planet properties
    update_planet_properties
  end
  
  # Check for notable events and record them
  def check_for_events(elapsed_days)
    # These would be significant changes worth reporting to the player
    
    # Example: Atmospheric changes
    if @planet.atmosphere
      # Check for large pressure changes
      if @planet.atmosphere.previous_changes[:pressure] && 
         (@planet.atmosphere.pressure - @planet.atmosphere.previous_changes[:pressure][0]).abs > 0.1
        @events << {
          day: elapsed_days,
          type: :atmosphere,
          description: "Significant atmospheric pressure change on #{@planet.name}"
        }
      end
      
      # Check for gas composition changes
      @planet.atmosphere.gases.each do |gas|
        if gas.previous_changes[:percentage] && 
           (gas.percentage - gas.previous_changes[:percentage][0]).abs > 5.0
          @events << {
            day: elapsed_days,
            type: :atmosphere,
            description: "#{gas.name} levels changed significantly on #{@planet.name}"
          }
        end
      end
    end
    
    # Example: Temperature changes
    if @planet.previous_changes[:surface_temperature] && 
       (@planet.surface_temperature - @planet.previous_changes[:surface_temperature][0]).abs > 5.0
      @events << {
        day: elapsed_days,
        type: :climate,
        description: "Major temperature shift on #{@planet.name}"
      }
    end
    
    # You could add many more event types here
  end
  
  # The processing methods for each sphere
  def process_atmosphere(days = @time_skipped)
    return unless @planet.atmosphere
    
    service = TerraSim::AtmosphereSimulationService.new(@planet)
    service.simulate(days)
  end
  
  def process_geosphere(days = @time_skipped)
    return unless @planet.geosphere
    
    service = TerraSim::GeosphereSimulationService.new(@planet)
    service.simulate(days)
  end
  
  def process_hydrosphere(days = @time_skipped)
    return unless @planet.hydrosphere
    
    service = TerraSim::HydrosphereSimulationService.new(@planet)
    service.simulate(days)
  end
  
  def process_biosphere(days = @time_skipped)
    return unless @planet.biosphere
    
    service = TerraSim::BiosphereSimulationService.new(@planet)
    service.simulate(days)
  end
  
  def process_sphere_interfaces
    # Process interactions between spheres
    
    # Atmosphere-Hydrosphere interface
    if @planet.atmosphere && @planet.hydrosphere
      service = TerraSim::AtmosphereHydrosphereInterfaceService.new(@planet)
      service.simulate
    end
    
    # Biosphere-Geosphere interface
    if @planet.biosphere && @planet.geosphere
      service = TerraSim::BiosphereGeosphereInterfaceService.new(@planet)
      service.simulate
    end
    
    # Other interfaces as needed
  end
  
  def update_planet_properties
    # Update surface temperature based on atmosphere and insolation
    update_surface_temperature
    
    # Update other planet-wide properties
    update_magnetic_field if @planet.respond_to?(:magnetic_field)
  end
  
  def update_surface_temperature
    if @planet.atmosphere && @planet.atmosphere.pressure > 0
      # Get greenhouse gas concentrations
      co2_percentage = get_gas_percentage('CO2')
      ch4_percentage = get_gas_percentage('CH4')
      
      # Calculate greenhouse effect (simplified)
      greenhouse_effect = co2_percentage * 0.05 + ch4_percentage * 0.2
      
      # Base temperature from stellar input
      base_temp = @planet.insolation / (@planet.albedo * 4)
      
      # Apply greenhouse effect
      new_temp = base_temp * (1 + greenhouse_effect)
      
      # Update planet temperature
      @planet.update(surface_temperature: new_temp)
    end
  end
  
  def get_gas_percentage(gas_name)
    return 0 unless @planet.atmosphere
    
    gas = @planet.atmosphere.gases.find_by(name: gas_name)
    return 0 unless gas
    
    gas.percentage
  end
  
  def log_simulation_results
    Rails.logger.info "Planet #{@planet.name} simulated for #{@time_skipped} days"
    
    if @planet.atmosphere
      Rails.logger.info "  Atmosphere: #{@planet.atmosphere.pressure.round(4)} atm, " +
                        "#{@planet.atmosphere.gases.count} gases"
    end
    
    Rails.logger.info "  Surface temperature: #{@planet.surface_temperature}K"
    
    # Log interesting events
    @events.each do |event|
      Rails.logger.info "  Event on day #{event[:day]}: #{event[:description]}"
    end
  end
  
  def update_magnetic_field
    if @planet.geosphere && @planet.geosphere.has_attribute?(:core_activity)
      # Magnetic field strength correlates with core activity
      @planet.update(magnetic_field: @planet.geosphere.core_activity * 10)
    end
  end
end