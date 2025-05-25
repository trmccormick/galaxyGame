module TerraSim
  class BiosphereSimulationService
    # Remove the class-level configuration method as we'll use planet-specific configs
    def initialize(celestial_body, config = {})
      @celestial_body = celestial_body
      @biosphere = celestial_body.biosphere
      @simulation_in_progress = false
      
      # Start with base defaults from GameConstants
      @config = GameConstants::BIOSPHERE_SIMULATION.dup
      
      # Then adjust based on planet properties
      configure_for_planet
      
      # Finally, allow any explicit overrides
      @config.merge!(config)
    end
    
    def simulate
      return if @simulation_in_progress
      @simulation_in_progress = true
      
      return unless @biosphere
      calculate_biosphere_conditions
      simulate_ecosystem_interactions
      track_species_population
      manage_food_web
      balance_biomes 
      influence_atmosphere

      @simulation_in_progress = false
    end
    
    # Make the methods that tests access directly public
    def influence_atmosphere
      return unless @biosphere && @celestial_body.atmosphere
      
      atmosphere = @celestial_body.atmosphere
      
      # Ensure there's some atmospheric mass to work with
      if atmosphere.total_atmospheric_mass <= 0
        # Set a small default mass if none exists
        atmosphere.update(total_atmospheric_mass: 100.0)
      end
      
      # Start with base atmospheric changes
      o2_change = 0.01
      co2_change = -0.01
      methane_change = 0.001
      
      # Instead of trying to sum vegetation_cover, use a more generic approach
      # that works without specific schema requirements
      has_vegetation = false
      total_biomes = 0
      
      # Try to access planet_biomes, but don't assume a specific schema
      begin
        if @biosphere.respond_to?(:planet_biomes) && @biosphere.planet_biomes.any?
          total_biomes = @biosphere.planet_biomes.count
          has_vegetation = true
        end
      rescue => e
        puts "WARNING: Error accessing biome data: #{e.message}"
      end
      
      # Scale changes based on biosphere complexity
      if has_vegetation
        # Simple scaling factor based on number of biomes
        vegetation_factor = (total_biomes / 5.0).clamp(0.1, 2.0)
        o2_change *= vegetation_factor
        co2_change *= vegetation_factor
      end
      
      # Get current percentages using our new methods
      initial_o2 = atmosphere.o2_percentage
      initial_co2 = atmosphere.co2_percentage
      initial_ch4 = atmosphere.ch4_percentage
      
      # Calculate new values, ensuring they stay non-negative
      new_o2 = [initial_o2 + o2_change, 0.0].max
      new_co2 = [initial_co2 + co2_change, 0.0].max
      new_ch4 = [initial_ch4 + methane_change, 0.0].max
      
      # Log the changes for debugging
      puts "Atmosphere gas changes:"
      puts "  O2: #{initial_o2} → #{new_o2} (change: #{o2_change.round(4)})"
      puts "  CO2: #{initial_co2} → #{new_co2} (change: #{co2_change.round(4)})"
      puts "  CH4: #{initial_ch4} → #{new_ch4} (change: #{methane_change.round(4)})"
      
      # Use direct SQL to confirm the initial count
      puts "BEFORE: Gas count in DB = #{atmosphere.gases.count}"
      
      # Create gas records - using add_gas properly
      total_mass = atmosphere.total_atmospheric_mass
      
      # IMPORTANT: Convert percentage values to mass values for add_gas
      o2_mass = (new_o2 * total_mass) / 100.0
      co2_mass = (new_co2 * total_mass) / 100.0
      ch4_mass = (new_ch4 * total_mass) / 100.0
      
      puts "Adding gases with masses: O2=#{o2_mass}, CO2=#{co2_mass}, CH4=#{ch4_mass}"
      
      # Delete existing gases to avoid accumulation
      atmosphere.gases.where(name: ['O2', 'CO2', 'CH4']).destroy_all
      
      # Add gases - make sure we're making actual database changes
      atmosphere.add_gas('O2', o2_mass) if o2_mass > 0
      atmosphere.add_gas('CO2', co2_mass) if co2_mass > 0
      atmosphere.add_gas('CH4', ch4_mass) if ch4_mass > 0
      
      # Confirm the database changes took place
      atmosphere.reload
      puts "AFTER: Gas count in DB = #{atmosphere.gases.count}"
      puts "AFTER: O2 gas record = #{atmosphere.gases.find_by(name: 'O2')&.attributes}"
      puts "AFTER: o2_percentage = #{atmosphere.o2_percentage}"
      
      # View the actual gas records in the database
      atmosphere.gases.each do |gas|
        puts "Gas record: #{gas.name} - Mass: #{gas.mass}, Percentage: #{gas.percentage}"
      end

      true
    end

    def update_biodiversity
      @biosphere.biodiversity_index = calculate_biodiversity
      @biosphere.save!
    end
    
    # Move this method OUTSIDE of the private section
    def simulate_ecosystem_interactions
      begin
        return unless @biosphere && @biosphere.planet_biomes.any?
        
        @biosphere.planet_biomes.each do |pb|
          begin
            biome = pb.biome
            puts "  Simulating interactions in #{biome.name} (Vegetation Cover: #{pb.vegetation_cover.round(2)})"
            
            # PLANT GROWTH - Add this section!
            # Increase vegetation cover based on light, moisture, and temperature suitability
            light_available = calculate_light_availability
            temp_suitability = calculate_temperature_suitability(biome.temperature_range)
            moisture_factor = pb.moisture_level.to_f.clamp(0.1, 1.0)
            
            # Calculate growth potential (0-1 scale)
            # Use the configurable growth factor
            growth_potential = light_available * temp_suitability * moisture_factor * @config[:plant_growth_factor]
            
            # Apply growth factor, with diminishing returns as we approach max vegetation
            current_vegetation = pb.vegetation_cover || 0.5
            max_vegetation = 1.0
            room_for_growth = max_vegetation - current_vegetation
            
            # More room to grow = faster growth
            actual_growth = growth_potential * room_for_growth
            
            # Update vegetation cover with the new growth
            new_vegetation_cover = [current_vegetation + actual_growth, max_vegetation].min
            pb.update(vegetation_cover: new_vegetation_cover)
            
            puts "    Plant growth: #{current_vegetation.round(2)} → #{new_vegetation_cover.round(2)} " +
                 "(Light: #{light_available.round(2)}, Temp: #{temp_suitability.round(2)}, Moisture: #{moisture_factor.round(2)})"
            
            # Process alien life forms if they exist
            begin
              if ActiveRecord::Base.connection.table_exists?('celestial_bodies_alien_life_forms')
                if @biosphere.respond_to?(:alien_life_forms) && @biosphere.alien_life_forms.any?
                  @biosphere.alien_life_forms.where(preferred_biome: biome.name).each do |life_form|
                    # Process alien life forms...
                    puts "    Simulating #{life_form.name} activity in biome"
                  end
                end
              end
            rescue => e
              puts "Warning: Skipping alien life form processing: #{e.message}"
            end
          rescue => e
            puts "WARNING: Error processing biome #{pb.id}: #{e.message}"
          end
        end
      rescue => e
        puts "WARNING: Error in ecosystem simulation: #{e.message}"
      end
    end

    # Move this method OUTSIDE of the private section
    def calculate_biosphere_conditions
      tropical_temp = @biosphere.tropical_temperature
      polar_temp = @biosphere.polar_temperature

      if tropical_temp > 273 && polar_temp < 273
        habitable_ratio = ((tropical_temp - 273) / (tropical_temp - polar_temp))**0.666667
        ice_latitude = Math.asin(habitable_ratio)
      elsif tropical_temp < 273
        habitable_ratio = 0
        ice_latitude = 0
      elsif polar_temp > 273
        habitable_ratio = 1
        ice_latitude = Math.asin(1)
      else
        habitable_ratio = 0
        ice_latitude = 0
      end

      # Update the habitable ratio and ice latitude in the biosphere
      @biosphere.update(
        habitable_ratio: habitable_ratio,
        ice_latitude: ice_latitude
      )

      update_biodiversity
      influence_atmosphere
    end

    private 
    
    # Methods that are only used internally and shouldn't be tested directly
    def track_species_population
      puts "Tracking species population in #{@biosphere}"

      @biosphere.alien_life_forms.each do |life_form|
        biome = @biosphere.biomes.find_by(name: life_form.preferred_biome)
        next unless biome

        carrying_capacity = biome.area_percentage * life_form.size_modifier.to_f # Smaller size = more can fit

        birth_rate = life_form.reproduction_rate.to_f * life_form.health_modifier
        death_rate = life_form.mortality_rate.to_f * (2.0 - life_form.health_modifier).clamp(0.1, 2.0) # Lower health = higher death

        population_change = (birth_rate - death_rate) * life_form.population * 0.01 # Scaling

        new_population = (life_form.population + population_change).floor
        life_form.update(population: [new_population, 0].max)
        puts "  #{life_form.name} population: #{life_form.population} in #{biome.name}, Change: #{population_change.round(2)}"
      end
    end

    def manage_food_web
      puts "Managing food web dynamics in #{@biosphere}"

      @biosphere.alien_life_forms.each do |consumer|
        biome = @biosphere.biomes.find_by(name: consumer.preferred_biome)
        next unless biome

        food_needed = consumer.population * consumer.consumption_rate.to_f

        food_obtained = 0

        if consumer.diet == 'herbivore'
          available_plants = (biome.vegetation_cover || 0.0) * biome.area_percentage * 1000 # Arbitrary scaling
          amount_eaten = [food_needed, available_plants * 0.1].min # Eat up to 10% of available plants
          food_obtained = amount_eaten / consumer.population.to_f if consumer.population > 0
          biome.update(vegetation_cover: [(biome.vegetation_cover || 0.0) - (amount_eaten / biome.area_percentage / 1000.0), 0].clamp(0, 1))
        elsif consumer.diet == 'carnivore'
          prey_species = @biosphere.alien_life_forms.where(name: consumer.prey_for, preferred_biome: biome.name)
          available_prey_mass = prey_species.sum { |prey| prey.population * prey.mass }

          if available_prey_mass > 0 && consumer.population > 0
            consumption_capacity = consumer.population * consumer.size_modifier.to_f * 100 # Rough capacity
            amount_eaten_mass = [food_needed * consumer.mass, available_prey_mass * 0.2].min # Eat up to 20% of prey mass

            prey_species.sort_by(&:mass).each do |prey|
              eat_this_round = (amount_eaten_mass / prey.mass).floor
              amount_to_eat = [eat_this_round, prey.population].min
              prey.update(population: [prey.population - amount_to_eat, 0].max)
              amount_eaten_mass -= (amount_to_eat * prey.mass)
              break if amount_eaten_mass <= 0
            end
            food_obtained = (food_needed * consumer.mass - amount_eaten_mass) / consumer.population.to_f if consumer.population > 0
          end
        end

        food_ratio = (food_obtained / [consumer.consumption_rate, 1e-6].max).clamp(0, 2) # Avoid division by zero
        consumer.update(health_modifier: (consumer.health_modifier * 0.9 + food_ratio * 0.1).clamp(0.1, 2.0)) # Smooth health change
        puts "  #{consumer.name} in #{biome.name} got food ratio: #{food_ratio.round(2)}"
      end
    end

    def balance_biomes
      puts "Balancing biomes based on climate and ecosystem conditions"

      # Get global water availability from hydrosphere (properly accessing liquid water)
      global_water_availability = @celestial_body.hydrosphere&.state_distribution&.dig('liquid').to_f || 0.0
      puts "Global liquid water availability: #{global_water_availability}"
      
      # Calculate total suitability and optimal temperatures
      total_suitability = 0.0
      suitability_map = {}
      weighted_temp_sum = 0.0
      
      # First pass: calculate suitability values for each biome
      @biosphere.planet_biomes.each do |pb|
        biome = pb.biome
        suitability = calculate_biome_suitability(biome)
        suitability_map[pb.id] = suitability
        total_suitability += suitability
        
        # Get the biome's optimal temperature (center of its temperature range)
        biome_temp_range = biome.temperature_range
        optimal_temp = biome_temp_range.min + ((biome_temp_range.max - biome_temp_range.min) / 2.0)
        
        # Add to weighted temperature sum (weighted by suitability)
        weighted_temp_sum += optimal_temp * suitability
      end
      
      # Calculate the target global temperature (weighted average of optimal temps)
      if total_suitability > 0
        target_global_temp = weighted_temp_sum / total_suitability
      else
        # Default to current temperature if no suitable biomes
        target_global_temp = @biosphere.tropical_temperature
      end
      
      # Get current temperatures
      current_tropical = @biosphere.tropical_temperature
      current_polar = @biosphere.polar_temperature
      
      # Calculate temperature changes (slow adjustment of 0.1K per cycle)
      tropical_change = (target_global_temp - current_tropical) * @config[:temperature_adjustment_rate]
      polar_change = (target_global_temp - current_polar) * @config[:temperature_adjustment_rate] * @config[:polar_adjustment_factor]
      
      # Update atmosphere's temperature data
      @celestial_body.atmosphere.update!(
        temperature_data: {
          'tropical_temperature' => current_tropical + tropical_change,
          'polar_temperature' => current_polar + polar_change
        }
      )
      
      puts "  Adjusting global temperatures:"
      puts "  - Tropical: #{current_tropical} → #{current_tropical + tropical_change}"
      puts "  - Polar: #{current_polar} → #{current_polar + polar_change}"
      puts "  - Target: #{target_global_temp} (based on biome optima)"
      
      # Now process the individual biomes (your existing code)
      @biosphere.planet_biomes.each do |pb|
        biome = pb.biome
        
        # Moisture level adjustments based on climate type and global water
        if biome.climate_type == 'tropical' || biome.climate_type == 'temperate_wet'
          target_moisture = global_water_availability * 0.9  # Wet biomes get more moisture
        elsif biome.climate_type == 'arid' || biome.climate_type == 'desert'
          target_moisture = global_water_availability * 0.2  # Dry biomes get less moisture 
        else
          target_moisture = global_water_availability * 0.5  # Default biomes get moderate moisture
        end
        
        current_moisture = pb.moisture_level || 0.5
        moisture_change = (target_moisture - current_moisture) * @config[:biome_moisture_adjustment_rate]
        new_moisture = [current_moisture + moisture_change, 0.0].max.clamp(0, 1)
        
        # Calculate new area percentage based on biome suitability
        current_area = pb.area_percentage || 50.0
        
        # Biome area adjustment - distribute area based on suitability
        if total_suitability > 0
          target_area = (suitability_map[pb.id] / total_suitability) * 100.0
          area_change = (target_area - current_area) * @config[:biome_area_adjustment_rate]
          new_area = current_area + area_change
        else
          # Equal distribution if no biome is particularly suitable
          new_area = 100.0 / @biosphere.planet_biomes.count
        end
        
        # Make sure areas will sum to 100%
        new_area = new_area.clamp(5.0, 95.0)
        
        # Update moisture and area
        pb.update(
          moisture_level: new_moisture,
          area_percentage: new_area
        )
        
        puts "  Biome #{biome.name}: moisture #{new_moisture.round(2)}, area #{new_area.round(2)}%"
      end
      
      # Final normalization to ensure areas sum to 100%
      total_area = @biosphere.planet_biomes.sum(:area_percentage)
      if total_area > 0 && (total_area < 99.0 || total_area > 101.0)  # Allow small rounding errors
        scaling_factor = 100.0 / total_area
        @biosphere.planet_biomes.each do |pb|
          normalized_area = pb.area_percentage * scaling_factor
          pb.update(area_percentage: normalized_area)
        end
      end
    end

    def calculate_biodiversity
      total_biomes = @biosphere.biomes.count
      max_possible_biomes = @config[:max_biomes]
      (total_biomes.to_f / max_possible_biomes)
    end

    # Calculates how suitable the current biosphere conditions are for a given biome.
    # This method takes into account the biome's temperature and humidity requirements.
    #
    # @param biome [Biome] The biome type to calculate suitability for.
    # @return [Float] A suitability score between 0.0 and 1.0.
    def calculate_biome_suitability(biome)
      # Get current biosphere conditions from instance variables
      current_surface_temp = @celestial_body.surface_temperature
      
      # CORRECTED LINE: Directly get the liquid percentage from Hydrosphere.
      # This value is assumed to be a percentage (0-100) from the Hydrosphere model.
      current_humidity_percent = @celestial_body.hydrosphere&.state_distribution&.dig('liquid').to_f || 0.0

      # --- Temperature Suitability ---
      temp_suitability = 0.0
      if biome.temperature_range.is_a?(Range)
        if biome.temperature_range.cover?(current_surface_temp)
          temp_suitability = 1.0
        else
          dist_to_min = (current_surface_temp - biome.temperature_range.min).abs
          dist_to_max = (current_surface_temp - biome.temperature_range.max).abs
          closest_dist = [dist_to_min, dist_to_max].min
          temp_suitability = [1.0 - (closest_dist / @config[:temperature_suitability_falloff]), 0.0].max
        end
      end

      # --- Humidity Suitability ---
      humidity_suitability = 0.0
      if biome.humidity_range.is_a?(Range)
        # current_humidity_percent is already 0-100 from hydrosphere.state_distribution['liquid']
        # No need to multiply by 100.0 here, as it's already a percentage.
        if biome.humidity_range.cover?(current_humidity_percent)
          humidity_suitability = 1.0
        else
          dist_to_min = (current_humidity_percent - biome.humidity_range.min).abs
          dist_to_max = (current_humidity_percent - biome.humidity_range.max).abs
          closest_dist = [dist_to_min, dist_to_max].min
          humidity_suitability = [1.0 - (closest_dist / 30.0), 0.0].max
        end
      end

      overall_suitability = (temp_suitability + humidity_suitability) / 2.0
      [overall_suitability, 0.0].max
    end

    def calculate_light_availability
      # Find the nearest star to get its luminosity
      star_distance_record = CelestialBodies::StarDistance.where(celestial_body: @celestial_body).order(:distance).first
      
      # Get the star's luminosity and distance (in AU)
      raw_luminosity = star_distance_record&.star&.luminosity || 1.0
      distance_au = star_distance_record&.distance || 1.0  # Default to 1 AU if not specified
      
      # Normalize the luminosity value if needed
      if raw_luminosity > 1000
        # Normalize to Sun = 1.0 scale
        normalized_luminosity = raw_luminosity / 3.828e26
        puts "DEBUG: Normalizing large luminosity value #{raw_luminosity} to #{normalized_luminosity}"
      else
        # Already normalized
        normalized_luminosity = raw_luminosity
      end
      
      # Apply inverse square law for distance
      # At 1 AU from a Sun-like star (luminosity=1.0), light_intensity = 1.0
      light_intensity = normalized_luminosity / (distance_au ** 2)
      
      # Get planet's albedo (reflectivity) - default to Earth-like value if not available
      # Albedo of 0 means all light is absorbed, 1 means all light is reflected
      albedo = @celestial_body.respond_to?(:albedo) ? @celestial_body.albedo : 0.3  # Earth's albedo ≈ 0.3
      
      # Calculate absorbed light (what actually reaches the surface)
      absorbed_light = light_intensity * (1.0 - albedo)
      
      # Apply atmospheric effects (dust, clouds, etc.)
      dust_factor = 1.0
      if @celestial_body.atmosphere&.dust.present?
        dust_factor = 1.0 - (@celestial_body.atmosphere.dust['concentration'].to_f / 100.0).clamp(0, 1)
      end
      
      # Atmospheric scattering can also affect light distribution 
      # (simplified here, but could be expanded)
      
      puts "DEBUG: Light calculation components:"
      puts "  Star luminosity (normalized): #{normalized_luminosity}"
      puts "  Distance (AU): #{distance_au}"
      puts "  Light intensity at planet: #{light_intensity}"
      puts "  Planet albedo: #{albedo}"
      puts "  Absorbed light: #{absorbed_light}"
      puts "  Dust factor: #{dust_factor}"
      puts "  Final light availability: #{absorbed_light * dust_factor}"
      
      # Return final light availability value
      absorbed_light * dust_factor
    end

    def calculate_temperature_suitability(temp_range)
      # All temperatures expected in Kelvin
      tropical_temp = @biosphere.tropical_temperature
      polar_temp = @biosphere.polar_temperature
      
      # Ensure temperatures are in Kelvin (simplifying the previous code)
      tropical_temp_k = ensure_kelvin(tropical_temp)
      polar_temp_k = ensure_kelvin(polar_temp)
      
      # Use the Kelvin values for the calculation
      current_temp = (tropical_temp_k + polar_temp_k) / 2.0
      
      puts "Calculated average temperature (K): #{current_temp}"
      puts "Temperature range to check against (K): #{temp_range}"
      
      # Check if current temperature is outside the range
      if current_temp < temp_range.min || current_temp > temp_range.max
        puts "Condition met: current_temp (#{current_temp}) is outside temp_range (#{temp_range}). Returning 0.0"
        return 0.0
      end
      
      # If within range, calculate how close to ideal middle point
      range = temp_range.max - temp_range.min
      middle_point = temp_range.min + (range / 2.0)
      distance_from_middle = (current_temp - middle_point).abs
      
      # Calculate suitability (1.0 at middle, decreasing toward edges)
      suitability = 1.0 - (distance_from_middle / (range / 2.0))
      puts "Temperature is within range. Suitability: #{suitability}"
      
      return suitability.clamp(0, 1)
    end

    # Helper method to ensure temperature is in Kelvin
    def ensure_kelvin(temp)
      # If temperature is likely in Celsius (below 100), convert to Kelvin
      if temp < 100
        temp + 273.15
      else
        temp
      end
    end

    def calculate_energy_obtained(life_form, biome)
      if life_form.diet == 'photosynthetic'
        # Use hardcoded values based on biome type instead of accessing non-existent fields
        photosynthetic_efficiency = biome.name == 'Tropical Forest' ? 0.5 : 0.2
        calculate_light_availability * photosynthetic_efficiency
      elsif life_form.diet == 'herbivore'
        # Get vegetation cover from the planet_biome join model, not the biome itself
        planet_biome = @biosphere.planet_biomes.find_by(biome: biome)
        vegetation_cover = planet_biome&.vegetation_cover || 0.0
        primary_productivity = biome.name == 'Tropical Forest' ? 100 : 20
        vegetation_cover * primary_productivity * life_form.foraging_efficiency.to_f
      elsif life_form.diet == 'carnivore'
        prey = @biosphere.alien_life_forms.where(name: life_form.prey_for, preferred_biome: biome.name).first
        prey&.mass.to_f * life_form.hunting_efficiency.to_f if prey
      else
        0
      end
    end

    # Helper method to check if the table exists without raising errors
    def alien_life_form_table_exists?
      begin
        CelestialBodies::AlienLifeForm.connection
        CelestialBodies::AlienLifeForm.table_exists?
      rescue => e
        puts "Warning: AlienLifeForm table check failed: #{e.message}"
        false
      end
    end
    
    # Configure simulation parameters based on planet properties
    def configure_for_planet
      # Get planet properties
      gravity = @celestial_body.gravity || 1.0
      radius = @celestial_body.radius || 6371000.0 # Default in meters
      atmospheric_density = @celestial_body.atmosphere&.density || 1.0
      
      # Get Earth reference values
      earth_reference = Lookup::EarthReferenceService.new
      earth_radius = earth_reference.radius * 1000.0 # Convert to meters to match your DB
      
      # 1. Plant growth factor calculation
      @config[:plant_growth_factor] = base_value(:plant_growth_factor) * 
                                   (0.8 + (0.4 * (1.0 - gravity.clamp(0.2, 2.0) / 2.0))) *
                                   (0.5 + (0.5 * atmospheric_density.clamp(0.1, 2.0)))
      
      # 2. Biome moisture adjustment
      size_factor = (earth_radius / radius.to_f).clamp(0.1, 10.0)
      @config[:biome_moisture_adjustment_rate] = base_value(:biome_moisture_adjustment_rate) * 
                                               (0.5 + (0.5 * size_factor))
      
      # 3. Temperature adjustment - affected by planet mass and atmospheric density
      # FIXED: Use earth_radius instead of Earth::RADIUS
      thermal_inertia = (radius / earth_radius) * atmospheric_density
      @config[:temperature_adjustment_rate] = base_value(:temperature_adjustment_rate) / 
                                              thermal_inertia.clamp(0.2, 5.0)
      
      # 4. Polar adjustment factor - affected by axial tilt
      # More tilt = less difference between poles and tropics
      axial_tilt = @celestial_body.axial_tilt || earth_reference.axial_tilt # Use reference service instead of hardcoded value
      @config[:polar_adjustment_factor] = base_value(:polar_adjustment_factor) * 
                                          (1.0 + (axial_tilt / 90.0))
      
      # Keep the debugging output
      puts "Planet-specific simulation configuration:"
      puts "  Plant growth factor: #{@config[:plant_growth_factor].round(4)}"
      puts "  Moisture adjustment rate: #{@config[:biome_moisture_adjustment_rate].round(4)}"
      puts "  Temperature adjustment rate: #{@config[:temperature_adjustment_rate].round(4)}"
      puts "  Polar adjustment factor: #{@config[:polar_adjustment_factor].round(4)}"
    end
    
    # Helper to get base value from GameConstants
    def base_value(key)
      GameConstants::BIOSPHERE_SIMULATION[key]
    end
  end
end