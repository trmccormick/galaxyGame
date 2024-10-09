module TerraSim
  class GeosphereSimulationService
    def initialize(celestial_body)
      @celestial_body = celestial_body
      @geosphere = celestial_body.geosphere
      @plate_tectonics_enabled = true # Example flag for tectonics simulation
      @soil_health = @geosphere.initial_soil_health || 100 # Assuming soil health is a percentage
    end

    def simulate
      simulate_tectonic_activity
      manage_soil_properties
      simulate_erosion
      volcanic_activity # New method for volcanic eruptions
      update_geosphere_state
    end

    private

    def simulate_tectonic_activity
      return unless @plate_tectonics_enabled

      movement_distance = rand(-5.0..5.0) # Movement in centimeters
      puts "Simulating tectonic activity for #{@geosphere}, movement distance: #{movement_distance} cm"
      @geosphere.update_plate_positions(movement_distance)
      log_earthquake if rand < 0.1 # 10% chance of an earthquake
    end

    def manage_soil_properties
      degradation_factor = calculate_soil_degradation
      @soil_health -= degradation_factor
      @soil_health = [@soil_health, 0].max
      puts "Managing soil properties for #{@geosphere}, current soil health: #{@soil_health}%"
      @geosphere.update_soil_health(@soil_health)
    end

    def simulate_erosion
      rainfall = @geosphere.average_rainfall
      vegetation_cover = @geosphere.vegetation_cover
      erosion_rate = calculate_erosion_rate(rainfall, vegetation_cover)
      puts "Simulating erosion for #{@geosphere}, erosion rate: #{erosion_rate} cm/year"
      @geosphere.update_erosion(erosion_rate)
    end

    def volcanic_activity
      if rand < 0.1 # 10% chance of volcanic eruption
        eruption
      end
    end

    def eruption
      puts "Volcanic eruption occurred! Ejecting materials..."
      released_gases = [
        { name: 'CO2', molar_mass: 44.01, melting_point: -78.5, boiling_point: -56.6, vapor_pressure: 0.0 },
        { name: 'SO2', molar_mass: 64.07, melting_point: -72.0, boiling_point: -10.0, vapor_pressure: 1.67 },
        { name: 'Water', molar_mass: 18.015, melting_point: 0, boiling_point: 100, vapor_pressure: 23.8 },
        { name: 'HCl', molar_mass: 36.46, melting_point: -114.2, boiling_point: -85.1, vapor_pressure: 2.16 }
      ]

      released_gases.each do |gas|
        mass_released = rand(10..100)
        add_gas_to_atmosphere(gas, mass_released)
        update_material_for_gas(gas[:name], mass_released)
      end

      increase_dust(rand(10..50))
      decrease_sunlight_effects

      handle_oceanic_eruption if @celestial_body.in_ocean?
    end

    def add_gas_to_atmosphere(gas, mass_released)
      @celestial_body.atmosphere.add_gas(
        gas[:name],
        mass_released
      )
    end

    def update_material_for_gas(gas_name, mass_released)
      material = @celestial_body.materials.find_or_create_by!(name: gas_name)
      material.update!(
        amount: material.amount + mass_released,
        state: 'gas'
      )
    end

    def increase_dust(amount)
      atmosphere = @celestial_body.atmosphere
      atmosphere.dust ||= { concentration: 0.0, properties: "Mainly composed of silicates and sulfates." }
      atmosphere.dust['concentration'] += amount
      atmosphere.save!
    end

    def decrease_sunlight_effects
      sunlight_reduction = rand(5..20)
      puts "Sunlight reduced by #{sunlight_reduction}% due to volcanic dust."
      # Implement additional logic if needed to apply reduction over time
    end

    def handle_oceanic_eruption
      puts "Eruption occurred near the ocean, triggering evaporation."
      # Additional effects related to water vapor or other interactions
    end

    def update_geosphere_state
      puts "Updating geosphere state for #{@geosphere}."
      # Additional state updates can go here
    end

    def calculate_soil_degradation
      population_pressure = @celestial_body.population_density || 0
      degradation = population_pressure * 0.05
      puts "Calculated soil degradation factor: #{degradation}%"
      degradation
    end

    def calculate_erosion_rate(rainfall, vegetation_cover)
      base_erosion_rate = 0.1
      erosion_rate = base_erosion_rate * (1 - vegetation_cover / 100) * (rainfall / 100)
      erosion_rate
    end

    def log_earthquake
      puts "Earthquake event logged for #{@geosphere}!"
    end
  end
end




  