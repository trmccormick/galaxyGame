module TerraSim
  class HydrosphereSimulationService
    def initialize(celestial_body)
      @celestial_body = celestial_body
      @hydrosphere = celestial_body.hydrosphere
      @atmosphere = celestial_body.atmosphere
      @material_lookup = MaterialLookupService.new # Initialize the lookup service
    end

    def simulate
      return unless @celestial_body && @hydrosphere && @atmosphere

      # Step 1: Calculate region temperatures
      calculate_region_temperatures
      
      # Step 2: Handle water movement
      handle_evaporation
      handle_precipitation

      # Step 3: Update the hydrosphere's total liquid volume once, after all changes
      update_hydrosphere_volume
    end

    private

    # Step 1: Calculate water temperatures for different regions
    def calculate_region_temperatures
      surface_temp = @celestial_body.surface_temperature

      @hydrosphere.ocean_temp = calculate_water_temp(surface_temp, @hydrosphere.oceans)
      @hydrosphere.lake_temp = calculate_water_temp(surface_temp, @hydrosphere.lakes)
      @hydrosphere.river_temp = calculate_water_temp(surface_temp, @hydrosphere.rivers)
      @hydrosphere.ice_temp = calculate_water_temp(surface_temp, @hydrosphere.ice)
    end

    def calculate_water_temp(surface_temp, volume)
      base_temp = surface_temp - 5 # Assume water is cooler than the surface
      volume_effect = Math.log(volume + 1) # Larger volumes retain more cold temperature
      base_temp - volume_effect
    end

    # Step 2: Handle evaporation (water moving from hydrosphere to atmosphere)
    def handle_evaporation
      surface_temp = @celestial_body.surface_temperature

      # Calculate evaporation for different bodies of water
      ocean_evaporation = calculate_evaporation(@hydrosphere.ocean_temp, surface_temp, @hydrosphere.oceans)
      lake_evaporation = calculate_evaporation(@hydrosphere.lake_temp, surface_temp, @hydrosphere.lakes)
      river_evaporation = calculate_evaporation(@hydrosphere.river_temp, surface_temp, @hydrosphere.rivers)

      # Decrease hydrosphere volumes due to evaporation
      @hydrosphere.oceans -= ocean_evaporation
      @hydrosphere.lakes -= lake_evaporation
      @hydrosphere.rivers -= river_evaporation

      # Total evaporation
      total_evaporation = ocean_evaporation + lake_evaporation + river_evaporation

      # Look up material information for water
      water_material = @material_lookup.find_material("Water")
      unless water_material
        Rails.logger.error("Water material not found in MaterialLookupService")
        return
      end

      if water_material && total_evaporation > 0
        # show celestial body name
        puts "Evaporation occurred on #{@celestial_body.name}"
        puts "Adding #{total_evaporation} kg of water vapor to the atmosphere"
        # Only pass gas name and total evaporation mass to add_gas
        @atmosphere.add_gas('Water', total_evaporation)
      else
        # Handle the case where water material is not found
        Rails.logger.error("Water material not found in MaterialLookupService")
      end
    end

    def calculate_evaporation(water_temp, surface_temp, volume)
      evaporation_rate = (surface_temp - water_temp) * 0.001 # Basic evaporation constant factor
      evaporated_amount = volume * evaporation_rate
      [evaporated_amount, volume].min # Can't evaporate more than exists
    end

    # Step 3: Handle precipitation (water moving from atmosphere back to hydrosphere)
    def handle_precipitation
      # Retrieve the current amount of water vapor in the atmosphere
      water_vapor = @atmosphere.gases.find_by(name: 'Water')&.mass || 0

      # Calculate precipitation rate based on water vapor and atmospheric temperature
      precipitation_rate = calculate_precipitation_rate(water_vapor, @atmosphere.temperature)

      # Calculate the amount of precipitation
      precipitation_amount = water_vapor * precipitation_rate

      # Ensure precipitation amount does not exceed available water vapor
      precipitation_amount = [precipitation_amount, water_vapor].min

      # Distribute precipitation to various water bodies (oceans, lakes, rivers)
      @hydrosphere.oceans += precipitation_amount * 0.7 # Most water goes to oceans
      @hydrosphere.lakes += precipitation_amount * 0.2
      @hydrosphere.rivers += precipitation_amount * 0.1

      # Remove the precipitated water from the atmosphere
      @atmosphere.remove_gas('Water', precipitation_amount)

      # Decrease dust concentration in the atmosphere due to precipitation
      decrease_dust(precipitation_amount * 0.05) # Example factor for dust reduction
    end

    def decrease_dust(amount)
      atmosphere = @celestial_body.atmosphere
      atmosphere.dust ||= { concentration: 0.0, properties: "Mainly composed of silicates and sulfates." }
      atmosphere.dust['concentration'] -= amount
      atmosphere.dust['concentration'] = 0.0 if atmosphere.dust['concentration'] < 0.0
      atmosphere.save!
    end

    def calculate_precipitation_rate(water_vapor, temperature)
      base_rate = 0.01 # Precipitation constant
      temperature_effect = [temperature - 273, 0].max * 0.001 # Temperature must be above freezing
      base_rate + temperature_effect
    end

    # Step 4: Update the hydrosphere's total liquid volume based on changes
    def update_hydrosphere_volume
      total_volume = @hydrosphere.oceans + @hydrosphere.lakes + @hydrosphere.rivers + @hydrosphere.ice
      @hydrosphere.update(liquid_volume: total_volume)
    end
  end
end





  