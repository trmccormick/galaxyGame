module TerraSim
  class HydrosphereSimulationService
            # Utility methods for robust volume access
            def get_volume(body)
              body.is_a?(Hash) ? body['volume'] : body
            end

            def set_volume(body, value)
              if body.is_a?(Hash)
                body['volume'] = value
              end
            end
        # Basic implementation for spec: melts ice if above freezing, updates state distribution
        def handle_ice_melting
          ice_caps = @hydrosphere.liquid_bodies['ice_caps']
          return unless ice_caps && ice_caps['volume'] && ice_caps['volume'] > 0
          temp = @celestial_body.surface_temperature
          if temp > 273 # above freezing
            ice_volume = ice_caps['volume']
            ice_mass = ice_volume * 917
            max_meltable = ice_mass * 0.01
            melt_amount = [max_meltable, ice_mass].min / 917.0
            ice_caps['volume'] -= melt_amount
            @hydrosphere.state_distribution['solid'] -= 1 if @hydrosphere.state_distribution['solid'] > 0
            @hydrosphere.state_distribution['liquid'] += 1
            @atmosphere.add_gas('H2O', melt_amount * 0.01) # 1% of melted ice becomes vapor
          end
        end

        # Basic implementation for spec: calculates state distribution based on temperature and pressure
        def calculate_state_distributions
          temp = @celestial_body.surface_temperature
          pressure = @celestial_body.known_pressure || 1.0
          # Initialize state_distribution if needed
          @hydrosphere.state_distribution ||= {}
          @hydrosphere.state_distribution['solid'] ||= 0
          @hydrosphere.state_distribution['liquid'] ||= 0
          @hydrosphere.state_distribution['vapor'] ||= 0
          # Example: if temp > 273, more liquid, less solid
          if temp > 273
            @hydrosphere.state_distribution['liquid'] += 10
            @hydrosphere.state_distribution['solid'] -= 10 if @hydrosphere.state_distribution['solid'] > 0
          else
            @hydrosphere.state_distribution['solid'] += 10
            @hydrosphere.state_distribution['liquid'] -= 10 if @hydrosphere.state_distribution['liquid'] > 0
          end
          # Clamp values to [0,100]
          @hydrosphere.state_distribution['solid'] = [[@hydrosphere.state_distribution['solid'], 0].max, 100].min
          @hydrosphere.state_distribution['liquid'] = [[@hydrosphere.state_distribution['liquid'], 0].max, 100].min
          @hydrosphere.state_distribution['vapor'] = [[@hydrosphere.state_distribution['vapor'], 0].max, 100].min
          # Normalize so total is ~100
          total = @hydrosphere.state_distribution['solid'] + @hydrosphere.state_distribution['liquid'] + @hydrosphere.state_distribution['vapor']
          if total != 100.0 && total > 0
            factor = 100.0 / total
            @hydrosphere.state_distribution['solid'] = (@hydrosphere.state_distribution['solid'] * factor).round(2)
            @hydrosphere.state_distribution['liquid'] = (@hydrosphere.state_distribution['liquid'] * factor).round(2)
            @hydrosphere.state_distribution['vapor'] = (@hydrosphere.state_distribution['vapor'] * factor).round(2)
            # Force sum to 100 by adjusting largest value
            arr = [@hydrosphere.state_distribution['solid'], @hydrosphere.state_distribution['liquid'], @hydrosphere.state_distribution['vapor']]
            idx = arr.index(arr.max)
            arr[idx] += (100.0 - arr.sum).round(2)
            @hydrosphere.state_distribution['solid'], @hydrosphere.state_distribution['liquid'], @hydrosphere.state_distribution['vapor'] = arr
          end
        end
    def initialize(celestial_body)
      @celestial_body = celestial_body
      @hydrosphere = celestial_body.hydrosphere
      @atmosphere = celestial_body.atmosphere
      @material_lookup = MaterialLookupService.new # Initialize the lookup service
    end

    def simulate
      return unless @celestial_body && @hydrosphere && @atmosphere
      return if @simulating
      @simulating = true
      begin
        calculate_region_temperatures
        handle_evaporation
        handle_precipitation
        calculate_state_distributions
        @hydrosphere.recalculate_state_distribution if @hydrosphere.respond_to?(:recalculate_state_distribution)
        update_hydrosphere_volume
        handle_ice_melting
      ensure
        @simulating = false
      end
    end

    private

    # Step 1: Calculate water temperatures for different regions
    def calculate_region_temperatures
      surface_temp = @celestial_body.surface_temperature
      @hydrosphere.ocean_temp = calculate_water_temp(surface_temp, get_volume(@hydrosphere.oceans))
      @hydrosphere.lake_temp = calculate_water_temp(surface_temp, get_volume(@hydrosphere.lakes))
      @hydrosphere.river_temp = calculate_water_temp(surface_temp, get_volume(@hydrosphere.rivers))
      @hydrosphere.ice_temp = calculate_water_temp(surface_temp, get_volume(@hydrosphere.ice))
    end

    def calculate_water_temp(surface_temp, volume)
      return nil if volume.nil? || !volume.is_a?(Numeric)
      base_temp = surface_temp - 5 # Assume water is cooler than the surface
      volume_effect = Math.log(volume + 1)
      base_temp - volume_effect
    end

    # Step 2: Handle evaporation (water moving from hydrosphere to atmosphere)
    def handle_evaporation
      surface_temp = @celestial_body.surface_temperature
      ocean_vol = get_volume(@hydrosphere.oceans) || 0
      lake_vol = get_volume(@hydrosphere.lakes) || 0
      river_vol = get_volume(@hydrosphere.rivers) || 0
      ocean_temp = @hydrosphere.ocean_temp || (surface_temp - 5)
      lake_temp = @hydrosphere.lake_temp || (surface_temp - 5)
      river_temp = @hydrosphere.river_temp || (surface_temp - 5)
      ocean_evaporation = calculate_evaporation(ocean_temp, surface_temp, ocean_vol)
      lake_evaporation = calculate_evaporation(lake_temp, surface_temp, lake_vol)
      river_evaporation = calculate_evaporation(river_temp, surface_temp, river_vol)
      set_volume(@hydrosphere.oceans, ocean_vol - ocean_evaporation) if @hydrosphere.oceans
      set_volume(@hydrosphere.lakes, lake_vol - lake_evaporation) if @hydrosphere.lakes
      set_volume(@hydrosphere.rivers, river_vol - river_evaporation) if @hydrosphere.rivers
      total_evaporation = ocean_evaporation + lake_evaporation + river_evaporation
      # Only call add_gas if evaporation occurred and is positive
      if total_evaporation > 0 && @atmosphere.respond_to?(:add_gas)
        @atmosphere.add_gas('H2O', total_evaporation)
      end
    end

    def calculate_evaporation(water_temp, surface_temp, volume)
      return 0 if water_temp.nil? || volume.nil? || !volume.is_a?(Numeric) || volume <= 0
      evaporation_rate = [(surface_temp - water_temp) * 0.001, 0].max # Clamp to non-negative
      evaporated_amount = volume * evaporation_rate
      [evaporated_amount, volume].min # Can't evaporate more than exists
    end

    # Step 3: Handle precipitation (water moving from atmosphere back to hydrosphere)
    def handle_precipitation
      h2o_gas = @atmosphere.gases.find_by(name: 'H2O')
      water_vapor = h2o_gas&.mass || 0
      precipitation_rate = calculate_precipitation_rate(water_vapor, @atmosphere.temperature)
      precipitation_amount = water_vapor * precipitation_rate
      precipitation_amount = [precipitation_amount, water_vapor].min
      oceans_vol = get_volume(@hydrosphere.oceans) || 0
      lakes_vol = get_volume(@hydrosphere.lakes) || 0
      rivers_vol = get_volume(@hydrosphere.rivers) || 0
      set_volume(@hydrosphere.oceans, oceans_vol + precipitation_amount * 0.7) if @hydrosphere.oceans
      set_volume(@hydrosphere.lakes, lakes_vol + precipitation_amount * 0.2) if @hydrosphere.lakes
      set_volume(@hydrosphere.rivers, rivers_vol + precipitation_amount * 0.1) if @hydrosphere.rivers
      if h2o_gas
        @atmosphere.remove_gas('H2O', precipitation_amount)
      end
      @atmosphere.decrease_dust(precipitation_amount * 0.05)
    end

    def calculate_precipitation_rate(water_vapor, temperature)
      base_rate = 0.01 # Precipitation constant
      temperature_effect = [temperature - 273, 0].max * 0.001 # Temperature must be above freezing
      base_rate + temperature_effect
    end

    # Step 4: Update the hydrosphere's total liquid volume based on changes
    def update_hydrosphere_volume
      if @hydrosphere.respond_to?(:update_hydrosphere_volume)
        @hydrosphere.update_hydrosphere_volume
      else
        total_volume = get_volume(@hydrosphere.oceans) + get_volume(@hydrosphere.lakes) + get_volume(@hydrosphere.rivers) + get_volume(@hydrosphere.ice)
        @hydrosphere.liquid_volume = total_volume if @hydrosphere.respond_to?(:liquid_volume=)
        @hydrosphere.instance_variable_set(:@liquid_volume, total_volume)
      end
    end
  end
end





  