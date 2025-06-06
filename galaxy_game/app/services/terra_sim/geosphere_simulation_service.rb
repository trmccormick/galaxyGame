module TerraSim
  class GeosphereSimulationService
    # Class variables to track eruptions across all instances
    @@eruption_mutex = Mutex.new
    @@eruptions_in_progress = {}
    attr_accessor :eruption_in_progress

    def self.reset_locks!
      @@eruptions_in_progress = {}
    end

    def initialize(celestial_body, options = {})
      @celestial_body = celestial_body
      @geosphere = celestial_body.geosphere
      @options = options
      @simulation_already_running = false  # Add this flag
      
      # Use safe navigation and default values
      @plate_tectonics_enabled = @geosphere&.tectonic_activity || false
      @geological_activity = @geosphere&.geological_activity || 0

      # Reset locks for testing
      self.class.reset_locks! if Rails.env.test?
    end

    def simulate
      return if @simulation_already_running  # Prevent recursive calls
      @simulation_already_running = true
      
      return unless @geosphere
      
      simulate_tectonic_activity
      manage_regolith_properties
      simulate_erosion
      simulate_geological_events
      simulate_volatile_phase_transitions
      update_geosphere_state
      
      @simulation_already_running = false
    end

    private

    def simulate_tectonic_activity
      return unless @geosphere.tectonic_activity
      
      # Call without arguments if method doesn't take any
      @geosphere.update_plate_positions
      
      # Change this line to use @geological_activity instead of activity_level
      if @geological_activity > 70 && rand(100) < @geological_activity / 10
        eruption
      end
      
      # If ice tectonics are enabled, simulate ice-specific processes
      if @geosphere.ice_tectonic_enabled
        simulate_ice_tectonics
      end
    end

    def manage_regolith_properties
      # Update regolith properties based on various factors
      weathering_rate = calculate_weathering_rate
      
      # Update regolith depth and particle size
      current_depth = @geosphere.regolith_depth || 0.0
      current_size = @geosphere.regolith_particle_size || 1.0
      
      new_depth = current_depth + (weathering_rate * 0.01)
      new_size = [current_size * (1 - weathering_rate * 0.001), 0.01].max
      
      # Update properties if the fields exist
      attributes_to_update = {}
      
      attributes_to_update[:regolith_depth] = new_depth if @geosphere.respond_to?(:regolith_depth)
      attributes_to_update[:regolith_particle_size] = new_size if @geosphere.respond_to?(:regolith_particle_size) 
      attributes_to_update[:weathering_rate] = weathering_rate if @geosphere.respond_to?(:weathering_rate)
      
      @geosphere.update(attributes_to_update) unless attributes_to_update.empty?
    end
    
    def calculate_weathering_rate
      # Base rate depends on atmosphere presence
      base_rate = 0.1
      
      # Factors affecting weathering
      atmosphere = @celestial_body.atmosphere
      hydrosphere = @celestial_body.hydrosphere
      
      # Atmospheric factors
      if atmosphere
        pressure_factor = atmosphere.pressure * 0.5
        temp_factor = (atmosphere.temperature - 273) * 0.01 # Higher temps increase weathering
      else
        pressure_factor = 0
        temp_factor = -0.5 # Very slow weathering with no atmosphere
      end
      
      # Water factors - safely check for method existence
      if hydrosphere && hydrosphere.respond_to?(:surface_water_percentage)
        water_factor = hydrosphere.surface_water_percentage * 0.01
      elsif hydrosphere && hydrosphere.respond_to?(:water_coverage_percent)
        water_factor = hydrosphere.water_coverage_percent * 0.01
      else
        water_factor = 0
      end
      
      # Calculate final rate
      rate = base_rate * (1 + pressure_factor) * (1 + temp_factor) * (1 + water_factor) * activity_multiplier
      [rate, 0.0].max # Ensure non-negative
    end

    def simulate_erosion
      # Get relevant properties, using safe navigation and defaults
      rainfall = @geosphere.average_rainfall || 0
      vegetation_cover = @geosphere.vegetation_cover || 0
      
      # Calculate erosion rate
      erosion_rate = calculate_erosion_rate(rainfall, vegetation_cover)
      puts "Simulating erosion for #{@geosphere}, erosion rate: #{erosion_rate} cm/year"
      
      # Update via the geosphere method
      if @geosphere.respond_to?(:update_erosion)
        @geosphere.update_erosion(erosion_rate)
      end
    end

    def simulate_geological_events
      case @celestial_body.planet_type
      when 'carbon_planet'
        simulate_diamond_formation if rand < diamond_formation_chance
        simulate_carbide_volcanism if rand < volcanic_activity_chance
      when 'ice_giant'
        simulate_cryovolcanism if rand < cryovolcanic_activity_chance
        simulate_methane_cycle
      when 'hot_jupiter'
        simulate_metallic_hydrogen_dynamics
        simulate_silicate_cloud_formation if @celestial_body.altitude > 100000
      when 'tidally_locked'
        simulate_substellar_volcanism if rand < volcanic_activity_chance * 3
        simulate_terminator_storms
      else
        # Default Earth-like behavior
        simulate_volcanic_activity if rand < volcanic_activity_chance
      end
    end

    def simulate_volcanic_activity
      eruption if rand < eruption_chance
    end

    # Create a new method for safe gas emissions
    def add_gas_safely(gas_id, mass)
      # Generate unique emission ID for tracking
      emission_id = "#{gas_id}_#{SecureRandom.hex(2)}"
      
      # Check if this exact emission has already been processed
      emission_key = "#{@celestial_body.id}_#{emission_id}"
      
      if @@eruptions_in_progress[emission_key]
        puts "⚠️ Skipping duplicate gas emission: #{gas_id} (#{mass})"
        return
      end
      
      @@eruptions_in_progress[emission_key] = true
      
      # Process the gas emission
      material_service = Lookup::MaterialLookupService.new
      material_data = material_service.find_material(gas_id)
      return unless material_data
      
      gas_name = material_data['name']
      puts "Adding #{mass} kg of #{gas_name} to atmosphere [Emission: #{emission_id}]"
      
      @celestial_body.atmosphere.add_gas(gas_name, mass)
      
      # Release this specific emission lock
      @@eruptions_in_progress.delete(emission_key)
    end

    # Update the eruption method
    def eruption
      # Generate a unique key for this specific eruption
      eruption_key = "#{@celestial_body.id}-#{Time.now.to_i}-#{rand(1000)}"
      
      # Skip if no atmosphere
      return false unless @celestial_body.atmosphere
      
      # Use a mutex for thread safety
      @@eruption_mutex.synchronize do
        # Skip if another eruption is in progress for this body
        if @@eruptions_in_progress[@celestial_body.id.to_s]
          puts "⚠️⚠️ SKIPPING duplicate eruption for celestial body #{@celestial_body.id}"
          return false
        end
        
        # Set the flag to block other eruptions
        @@eruptions_in_progress[@celestial_body.id.to_s] = eruption_key
      end
      
      begin
        # Execute eruption code
        puts "💥 EXECUTING eruption #{eruption_key} for body #{@celestial_body.id}"
        
        # Determine which gases to emit based on planet type
        volcanic_composition = determine_volcanic_composition
        
        # Emit each gas
        volcanic_composition.each do |gas_id, weight|
          # Calculate amount based on geological activity and random factor
          amount = rand(100..500) * weight * activity_multiplier
          
          # Add the gas to the atmosphere
          add_gas_safely(gas_id, amount)
        end
        
        # Add dust to the atmosphere
        increase_dust(rand(10..50) * activity_multiplier)
        
        # Other effects
        decrease_sunlight_effects
        
        # If near ocean, additional effects
        if @celestial_body.hydrosphere && rand < 0.5
          handle_oceanic_eruption
        end
        
      ensure
        # Always clear the flag, even if an error occurs
        @@eruption_mutex.synchronize do
          if @@eruptions_in_progress[@celestial_body.id.to_s] == eruption_key
            @@eruptions_in_progress.delete(@celestial_body.id.to_s)
          end
        end
      end
      
      true # Return true to indicate success
    end

    def determine_volcanic_composition
      # Default weights
      weights = {
        'carbon_dioxide' => 1.0,
        'sulfur_dioxide' => 0.9,
        'water' => 1.5,
        'hydrogen_chloride' => 0.7
      }
      
      # In future: modify weights based on planet properties
      # if @celestial_body.geosphere.crust_composition['Silicon'] > 50
      #   weights['sulfur_dioxide'] *= 1.5
      # end
      
      # if @celestial_body.is_a?(CelestialBodies::Planets::Rocky::CarbonPlanet)
      #   weights['carbon_dioxide'] *= 3.0
      # end
      
      weights
    end

    def increase_dust(amount)
      atmosphere = @celestial_body.atmosphere
      return unless atmosphere
      
      # Initialize dust structure if nil
      atmosphere.dust ||= {}
      atmosphere.dust['concentration'] ||= 0.0
      atmosphere.dust['properties'] ||= "Mainly composed of silicates and sulfates."
      
      # Now safely increment
      atmosphere.dust['concentration'] += amount
      atmosphere.save!
    end

    def decrease_sunlight_effects
      sunlight_reduction = rand(5..20) * activity_multiplier
      puts "Sunlight reduced by #{sunlight_reduction}% due to volcanic dust."
    end

    def handle_oceanic_eruption
      puts "Eruption occurred near the ocean, triggering evaporation."
    end

    def update_geosphere_state
      puts "Updating geosphere state for #{@geosphere}."
    end

    def calculate_soil_degradation
      population_pressure = @celestial_body.population_density || 0
      degradation = population_pressure * 0.05 * activity_multiplier
      puts "Calculated soil degradation factor: #{degradation}%"
      degradation
    end

    def calculate_erosion_rate(rainfall, vegetation_cover)
      base_erosion_rate = 0.1
      # Higher rainfall increases erosion, higher vegetation decreases it
      erosion_rate = base_erosion_rate * (rainfall / 100.0) * (1 - vegetation_cover / 100.0)
      erosion_rate * activity_multiplier
    end

    def log_earthquake
      puts "Earthquake event logged for #{@geosphere}!"
    end

    # Determines the multiplier based on geological_activity
    def activity_multiplier
      1 + (@geological_activity / 10.0)
    end

    # Adjusts earthquake probability based on geological_activity
    def earthquake_chance
      @geological_activity / 50.0
    end

    # Adjusts volcanic eruption chance based on geological_activity
    def volcanic_activity_chance
      [@geological_activity * 0.05, 1].min
    end

    def eruption_chance
      [@geological_activity * 0.05, 1].min
    end

    def simulate_diamond_formation
      puts "Diamond formation process occurring in high pressure zones..."
      carbon_amount = @geosphere.geological_materials.find_by(name: 'Carbon')&.mass || 0
      
      if carbon_amount > 0
        conversion_amount = carbon_amount * 0.001 * activity_multiplier
        diamond = @geosphere.geological_materials.find_or_create_by!(
          name: 'Diamond',
          layer: 'mantle'
        )
        
        diamond.update!(
          mass: diamond.mass + conversion_amount,
          state: 'solid',
          percentage: (diamond.percentage || 0) + 0.01
        )
        
        puts "#{conversion_amount} mass of Carbon converted to Diamond"
      end
    end

    def simulate_cryovolcanism
      puts "Cryovolcanic eruption occurred! Ejecting frozen materials..."
      released_materials = [
        { name: 'Methane Ice', molar_mass: 16.04, state: 'solid' },
        { name: 'Ammonia Water', molar_mass: 35.04, state: 'liquid' },
        { name: 'Nitrogen', molar_mass: 28.01, state: 'gas' }
      ]
      
      released_materials.each do |material|
        mass_released = rand(10..100) * activity_multiplier
        
        case material[:state]
        when 'gas'
          handle_gas_emission(material, mass_released)
        when 'liquid'
          add_liquid_to_hydrosphere(material, mass_released)
        when 'solid'
          add_exotic_material_to_surface(material, mass_released)
        end
      end
    end

    def simulate_volatile_phase_transitions
      volatile_service = TerraSim::VolatilePhaseTransitionService.new(@celestial_body)
      volatile_service.simulate
    end
  end
end