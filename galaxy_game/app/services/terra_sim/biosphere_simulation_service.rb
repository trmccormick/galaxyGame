# ==============================================================================
# FIXED: app/services/terra_sim/biosphere_simulation_service.rb
# ==============================================================================

module TerraSim
  class BiosphereSimulationService
    def initialize(celestial_body, config = {})
      @celestial_body = celestial_body
      @biosphere = celestial_body.biosphere
      @simulation_in_progress = false
      
      @config = GameConstants::BIOSPHERE_SIMULATION.dup
      configure_for_planet
      @config.merge!(config)
    end
    
    def simulate(time_skipped = 1)
      return if @simulation_in_progress
      @simulation_in_progress = true
      return unless @biosphere
      
      @time_skipped = time_skipped
      
      calculate_biosphere_conditions
      simulate_ecosystem_interactions
      track_species_population
      manage_food_web
      balance_biomes 
      influence_atmosphere(time_skipped)

      @simulation_in_progress = false
    end
    
    # FIXED: Preserve base atmosphere, don't destroy it
    def influence_atmosphere(time_skipped = 1)
      return unless @biosphere && @celestial_body.atmosphere
      
      atmosphere = @celestial_body.atmosphere
      
      if atmosphere.total_atmospheric_mass <= 0 || atmosphere.total_atmospheric_mass < 1
        atmosphere.update(total_atmospheric_mass: 100.0)
      end
      
      # Calculate gas changes from actual life forms
      life_effects = calculate_life_form_atmospheric_effects
      
      # Use life form effects if available, otherwise fall back to hardcoded
      if life_effects[:total_population] > 0
        puts "Using life form atmospheric effects (#{life_effects[:species_count]} species)"
        
        # Scale by time_skipped
        o2_change = life_effects[:o2_production] * time_skipped
        co2_change = -life_effects[:co2_consumption] * time_skipped  # Negative because consumed
        methane_change = life_effects[:ch4_production] * time_skipped
        
        puts "Life form contributions per day: O2=#{life_effects[:o2_production]}, CO2 consumed=#{life_effects[:co2_consumption]}, CH4=#{life_effects[:ch4_production]}"
      else
        puts "No life forms with terraforming effects, using default values"
        o2_change = 0.00001 * time_skipped      # Realistic: 0.001% per day
        co2_change = -0.00001 * time_skipped
        methane_change = 0.000001 * time_skipped
      end
      
      # Scale by vegetation (biome complexity)
      has_vegetation = false
      total_biomes = 0
      
      begin
        if @biosphere.respond_to?(:planet_biomes) && @biosphere.planet_biomes.any?
          total_biomes = @biosphere.planet_biomes.count
          has_vegetation = true
        end
      rescue => e
        puts "WARNING: Error accessing biome data: #{e.message}"
      end
      
      if has_vegetation
        vegetation_factor = (total_biomes / 5.0).clamp(0.1, 2.0)
        o2_change *= vegetation_factor
        co2_change *= vegetation_factor
        puts "Vegetation scaling factor: #{vegetation_factor}"
      end
      
      # Get current percentages (preserves existing atmosphere)
      initial_o2 = atmosphere.o2_percentage
      initial_co2 = atmosphere.co2_percentage
      initial_ch4 = atmosphere.ch4_percentage
      initial_n2 = atmosphere.gas_percentage('N2')
      initial_ar = atmosphere.gas_percentage('Ar')
      
      # Calculate new percentages
      new_o2 = [initial_o2 + o2_change, 0.0].max
      new_co2 = [initial_co2 + co2_change, 0.0].max
      new_ch4 = [initial_ch4 + methane_change, 0.0].max
      
      # Keep N2 and Ar constant (inert gases)
      new_n2 = initial_n2
      new_ar = initial_ar
      
      # Normalize if total exceeds 100%
      total = new_o2 + new_co2 + new_ch4 + new_n2 + new_ar
      if total > 100.0
        scale = 100.0 / total
        new_o2 *= scale
        new_co2 *= scale
        new_ch4 *= scale
        new_n2 *= scale
        new_ar *= scale
        puts "Normalizing atmosphere: total was #{total.round(2)}%, scaled to 100%"
      end
      
      puts "Atmosphere changes over #{time_skipped} days:"
      puts "  O2:  #{initial_o2.round(4)} → #{new_o2.round(4)} (#{o2_change >= 0 ? '+' : ''}#{o2_change.round(6)}%)"
      puts "  CO2: #{initial_co2.round(4)} → #{new_co2.round(4)} (#{co2_change >= 0 ? '+' : ''}#{co2_change.round(6)}%)"
      puts "  CH4: #{initial_ch4.round(4)} → #{new_ch4.round(4)} (#{methane_change >= 0 ? '+' : ''}#{methane_change.round(6)}%)"
      
      total_mass = atmosphere.total_atmospheric_mass
      
      # Calculate masses
      o2_mass = (new_o2 * total_mass) / 100.0
      co2_mass = (new_co2 * total_mass) / 100.0
      ch4_mass = (new_ch4 * total_mass) / 100.0
      n2_mass = (new_n2 * total_mass) / 100.0
      ar_mass = (new_ar * total_mass) / 100.0

      puts "Calculated gas masses: O2=#{o2_mass.round(2)}, CO2=#{co2_mass.round(2)}, CH4=#{ch4_mass.round(2)}"

      # Get current masses
      current_o2 = atmosphere.gases.find_by(name: 'O2')&.mass || 0.0
      current_co2 = atmosphere.gases.find_by(name: 'CO2')&.mass || 0.0
      current_ch4 = atmosphere.gases.find_by(name: 'CH4')&.mass || 0.0
      current_n2 = atmosphere.gases.find_by(name: 'N2')&.mass || 0.0
      current_ar = atmosphere.gases.find_by(name: 'Ar')&.mass || 0.0

      # Calculate deltas
      o2_delta = o2_mass - current_o2
      co2_delta = co2_mass - current_co2
      ch4_delta = ch4_mass - current_ch4
      n2_delta = n2_mass - current_n2
      ar_delta = ar_mass - current_ar

      # Apply changes
      atmosphere.add_gas('O2', o2_delta) if o2_delta > 0
      atmosphere.remove_gas('O2', o2_delta.abs) if o2_delta < 0

      atmosphere.add_gas('CO2', co2_delta) if co2_delta > 0
      atmosphere.remove_gas('CO2', co2_delta.abs) if co2_delta < 0

      atmosphere.add_gas('CH4', ch4_delta) if ch4_delta > 0
      atmosphere.remove_gas('CH4', ch4_delta.abs) if ch4_delta < 0

      atmosphere.add_gas('N2', n2_delta) if n2_delta > 0
      atmosphere.remove_gas('N2', n2_delta.abs) if n2_delta < 0

      atmosphere.add_gas('Ar', ar_delta) if ar_delta > 0
      atmosphere.remove_gas('Ar', ar_delta.abs) if ar_delta < 0

      # Recalculate percentages and update total mass
      atmosphere.recalculate_gas_percentages
      atmosphere.reload

      true
    end
    
    def calculate_life_form_atmospheric_effects
      effects = {
        o2_production: 0.0,
        co2_consumption: 0.0,
        ch4_production: 0.0,
        n2_fixation: 0.0,
        soil_improvement: 0.0,
        total_population: 0,
        species_count: 0
      }
      
      return effects unless @biosphere.respond_to?(:life_forms)
      
      @biosphere.life_forms.each do |life_form|
        next unless life_form.population && life_form.population > 0
        
        contribution = life_form.atmospheric_contribution
        effects[:o2_production] += contribution[:o2]
        effects[:co2_consumption] += contribution[:co2]
        effects[:ch4_production] += contribution[:ch4]
        effects[:n2_fixation] += contribution[:n2]
        effects[:soil_improvement] += contribution[:soil]
        effects[:total_population] += life_form.population
        effects[:species_count] += 1
      end
      
      effects
    end

    def update_biodiversity
      @biosphere.biodiversity_index = calculate_biodiversity
      @biosphere.save!
    end
    
    def simulate_ecosystem_interactions
      begin
        return unless @biosphere && @biosphere.planet_biomes.any?
        
        @biosphere.planet_biomes.each do |pb|
          begin
            biome = pb.biome
            puts "  Simulating interactions in #{biome.name} (Vegetation Cover: #{pb.vegetation_cover.round(2)})"
            
            light_available = calculate_light_availability
            temp_suitability = calculate_temperature_suitability(biome.temperature_range)
            moisture_factor = pb.moisture_level.to_f.clamp(0.1, 1.0)
            
            growth_potential = light_available * temp_suitability * moisture_factor * @config[:plant_growth_factor]
            
            current_vegetation = pb.vegetation_cover || 0.5
            max_vegetation = 1.0
            room_for_growth = max_vegetation - current_vegetation
            
            actual_growth = growth_potential * room_for_growth
            
            new_vegetation_cover = [current_vegetation + actual_growth, max_vegetation].min
            pb.update(vegetation_cover: new_vegetation_cover)
            
            puts "    Plant growth: #{current_vegetation.round(2)} → #{new_vegetation_cover.round(2)} " +
                 "(Light: #{light_available.round(2)}, Temp: #{temp_suitability.round(2)}, Moisture: #{moisture_factor.round(2)})"
            
            begin
              if ActiveRecord::Base.connection.table_exists?('biology_life_forms')
                if @biosphere.respond_to?(:life_forms) && @biosphere.life_forms.any?
                  @biosphere.life_forms.where(preferred_biome: biome.name).each do |life_form|
                    puts "    Simulating #{life_form.name} activity in biome"
                  end
                end
              end
            rescue => e
              puts "Warning: Skipping life form processing: #{e.message}"
            end
          rescue => e
            puts "WARNING: Error processing biome #{pb.id}: #{e.message}"
          end
        end
      rescue => e
        puts "WARNING: Error in ecosystem simulation: #{e.message}"
      end
    end

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

      @biosphere.update(
        habitable_ratio: habitable_ratio,
        ice_latitude: ice_latitude
      )

      update_biodiversity
    end

    private 
    
    def track_species_population
      return unless @biosphere.life_forms.any?
      
      puts "Tracking species population in #{@biosphere}"

      @biosphere.life_forms.each do |life_form|
        preferred_biome_name = life_form.properties['preferred_biome']
        next unless preferred_biome_name
        
        biome = @biosphere.biomes.find_by(name: preferred_biome_name)
        next unless biome

        carrying_capacity = biome.area_percentage * life_form.properties['size_modifier'].to_f

        birth_rate = life_form.properties['reproduction_rate'].to_f * life_form.properties['health_modifier'].to_f
        death_rate = life_form.properties['mortality_rate'].to_f * (2.0 - life_form.properties['health_modifier'].to_f).clamp(0.1, 2.0)

        population_change = (birth_rate - death_rate) * life_form.population * 0.01 * (@time_skipped || 1)

        new_population = (life_form.population + population_change).floor
        life_form.update(population: [new_population, 0].max)
        puts "  #{life_form.name} population: #{life_form.population} in #{biome.name}, Change: #{population_change.round(2)}"
      end
    end

    def manage_food_web
      return unless @biosphere.life_forms.any?
      
      puts "Managing food web dynamics in #{@biosphere}"

      @biosphere.life_forms.each do |consumer|
        preferred_biome_name = consumer.properties['diet']
        biome = @biosphere.biomes.find_by(name: preferred_biome_name)
        next unless biome

        food_needed = consumer.population * consumer.properties['consumption_rate'].to_f
        food_obtained = 0

        if consumer.properties['diet'] == 'herbivore'
          available_plants = (biome.vegetation_cover || 0.0) * biome.area_percentage * 1000
          amount_eaten = [food_needed, available_plants * 0.1].min
          food_obtained = amount_eaten / consumer.population.to_f if consumer.population > 0
          biome.update(vegetation_cover: [(biome.vegetation_cover || 0.0) - (amount_eaten / biome.area_percentage / 1000.0), 0].clamp(0, 1))
        elsif consumer.properties['diet'] == 'carnivore'
          prey_for_name = consumer.properties['prey_for']
          prey_species = @biosphere.life_forms.select { |lf| lf.properties['diet'] == prey_for_name && lf.properties['preferred_biome'] == biome.name }
          available_prey_mass = prey_species.sum { |prey| prey.population * prey.properties['mass'].to_f }

          if available_prey_mass > 0 && consumer.population > 0
            consumption_capacity = consumer.population * consumer.properties['size_modifier'].to_f * 100
            amount_eaten_mass = [food_needed * consumer.properties['mass'].to_f, available_prey_mass * 0.2].min

            prey_species.sort_by { |p| p.properties['mass'].to_f }.each do |prey|
              prey_mass = prey.properties['mass'].to_f
              next if prey_mass <= 0
              
              eat_this_round = (amount_eaten_mass / prey_mass).floor
              amount_to_eat = [eat_this_round, prey.population].min
              prey.update(population: [prey.population - amount_to_eat, 0].max)
              amount_eaten_mass -= (amount_to_eat * prey_mass)
              break if amount_eaten_mass <= 0
            end
            food_obtained = (food_needed * consumer.properties['mass'].to_f - amount_eaten_mass) / consumer.population.to_f if consumer.population > 0
          end
        end

        food_ratio = (food_obtained / [consumer.properties['consumption_rate'].to_f, 1e-6].max).clamp(0, 2)
        new_health = (consumer.properties['health_modifier'].to_f * 0.9 + food_ratio * 0.1).clamp(0.1, 2.0)
        consumer.properties['health_modifier'] = new_health
        consumer.save
        puts "  #{consumer.name} in #{biome.name} got food ratio: #{food_ratio.round(2)}"
      end
    end
    
    def balance_biomes
      puts "Balancing biomes based on climate and ecosystem conditions"

      global_water_availability = @celestial_body.hydrosphere&.state_distribution&.dig('liquid').to_f || 0.0
      puts "Global liquid water availability: #{global_water_availability}"
      
      total_suitability = 0.0
      suitability_map = {}
      weighted_temp_sum = 0.0
      
      @biosphere.planet_biomes.each do |pb|
        biome = pb.biome
        suitability = calculate_biome_suitability(biome)
        suitability_map[pb.id] = suitability
        total_suitability += suitability
        
        biome_temp_range = biome.temperature_range
        optimal_temp = biome_temp_range.min + ((biome_temp_range.max - biome_temp_range.min) / 2.0)
        
        weighted_temp_sum += optimal_temp * suitability
      end
      
      if total_suitability > 0
        target_global_temp = weighted_temp_sum / total_suitability
      else
        target_global_temp = @biosphere.tropical_temperature
      end
      
      current_tropical = @biosphere.tropical_temperature.to_f
      current_polar = @biosphere.polar_temperature.to_f
      
      tropical_change = (target_global_temp - current_tropical) * @config[:temperature_adjustment_rate]
      polar_change = (target_global_temp - current_polar) * @config[:temperature_adjustment_rate] * @config[:polar_adjustment_factor]
      
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
      
      @biosphere.planet_biomes.each do |pb|
        biome = pb.biome
        
        if biome.climate_type == 'tropical' || biome.climate_type == 'temperate_wet'
          target_moisture = global_water_availability * 0.9
        elsif biome.climate_type == 'arid' || biome.climate_type == 'desert'
          target_moisture = global_water_availability * 0.2
        else
          target_moisture = global_water_availability * 0.5
        end
        
        current_moisture = pb.moisture_level || 0.5
        moisture_change = (target_moisture - current_moisture) * @config[:biome_moisture_adjustment_rate]
        new_moisture = [current_moisture + moisture_change, 0.0].max.clamp(0, 1)
        
        current_area = pb.area_percentage || 50.0
        
        if total_suitability > 0
          target_area = (suitability_map[pb.id] / total_suitability) * 100.0
          area_change = (target_area - current_area) * @config[:biome_area_adjustment_rate]
          new_area = current_area + area_change
        else
          new_area = 100.0 / @biosphere.planet_biomes.count
        end
        
        new_area = new_area.clamp(5.0, 95.0)
        
        pb.update(
          moisture_level: new_moisture,
          area_percentage: new_area
        )
        
        puts "  Biome #{biome.name}: moisture #{new_moisture.round(2)}, area #{new_area.round(2)}%"
      end
      
      total_area = @biosphere.planet_biomes.sum(&:area_percentage)
      if total_area > 0 && (total_area < 99.0 || total_area > 101.0)
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

    def calculate_biome_suitability(biome)
      current_surface_temp = @celestial_body.surface_temperature
      current_humidity_percent = @celestial_body.hydrosphere&.state_distribution&.dig('liquid').to_f || 0.0

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

      humidity_suitability = 0.0
      if biome.humidity_range.is_a?(Range)
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
      star_distance_record = CelestialBodies::StarDistance.where(celestial_body: @celestial_body).order(:distance).first
      
      raw_luminosity = star_distance_record&.star&.luminosity || 1.0
      distance_au = star_distance_record&.distance || 1.0
      
      if raw_luminosity > 1000
        normalized_luminosity = raw_luminosity / 3.828e26
      else
        normalized_luminosity = raw_luminosity
      end
      
      light_intensity = normalized_luminosity / (distance_au ** 2)
      albedo = @celestial_body.respond_to?(:albedo) ? @celestial_body.albedo : 0.3
      absorbed_light = light_intensity * (1.0 - albedo)
      
      dust_factor = 1.0
      if @celestial_body.atmosphere&.dust.present?
        dust_factor = 1.0 - (@celestial_body.atmosphere.dust['concentration'].to_f / 100.0).clamp(0, 1)
      end
      
      absorbed_light * dust_factor
    end

    def calculate_temperature_suitability(temp_range)
      tropical_temp = @biosphere.tropical_temperature
      polar_temp = @biosphere.polar_temperature
      
      tropical_temp_k = ensure_kelvin(tropical_temp)
      polar_temp_k = ensure_kelvin(polar_temp)
      
      current_temp = (tropical_temp_k + polar_temp_k) / 2.0
      
      if current_temp < temp_range.min || current_temp > temp_range.max
        return 0.0
      end
      
      range = temp_range.max - temp_range.min
      middle_point = temp_range.min + (range / 2.0)
      distance_from_middle = (current_temp - middle_point).abs
      
      suitability = 1.0 - (distance_from_middle / (range / 2.0))
      
      suitability.clamp(0, 1)
    end

    def ensure_kelvin(temp)
      if temp < 100
        temp + 273.15
      else
        temp
      end
    end

    def calculate_energy_obtained(life_form, biome)
      if life_form.properties['diet'] == 'photosynthetic'
        photosynthetic_efficiency = biome.name == 'Tropical Forest' ? 0.5 : 0.2
        calculate_light_availability * photosynthetic_efficiency
      elsif life_form.properties['diet'] == 'herbivore'
        planet_biome = @biosphere.planet_biomes.find_by(biome: biome)
        vegetation_cover = planet_biome&.vegetation_cover || 0.0
        primary_productivity = biome.name == 'Tropical Forest' ? 100 : 20
        vegetation_cover * primary_productivity * life_form.properties['foraging_efficiency'].to_f
      elsif life_form.properties['diet'] == 'carnivore'
        prey = @biosphere.life_forms.find { |lf| lf.name == life_form.properties['prey_for'] && lf.properties['preferred_biome'] == biome.name }
        prey&.properties['mass'].to_f * life_form.properties['hunting_efficiency'].to_f if prey
      else
        0
      end
    end

    def life_form_table_exists?
      begin
        Biology::LifeForm.connection
        ActiveRecord::Base.connection.table_exists?('biology_life_forms')
      rescue => e
        puts "Warning: LifeForm table check failed: #{e.message}"
        false
      end
    end
    
    def configure_for_planet
      gravity = @celestial_body.gravity || 1.0
      radius = @celestial_body.radius || 6371000.0
      atmospheric_density = @celestial_body.atmosphere&.density || 1.0
      
      earth_reference = Lookup::EarthReferenceService.new
      earth_radius = earth_reference.radius * 1000.0
      
      @config[:plant_growth_factor] = base_value(:plant_growth_factor) * 
                                   (0.8 + (0.4 * (1.0 - gravity.clamp(0.2, 2.0) / 2.0))) *
                                   (0.5 + (0.5 * atmospheric_density.clamp(0.1, 2.0)))
      
      size_factor = (earth_radius / radius.to_f).clamp(0.1, 10.0)
      @config[:biome_moisture_adjustment_rate] = base_value(:biome_moisture_adjustment_rate) * 
                                               (0.5 + (0.5 * size_factor))
      
      thermal_inertia = (radius / earth_radius) * atmospheric_density
      @config[:temperature_adjustment_rate] = base_value(:temperature_adjustment_rate) / 
                                              thermal_inertia.clamp(0.2, 5.0)
      
      axial_tilt = @celestial_body.axial_tilt || earth_reference.axial_tilt
      @config[:polar_adjustment_factor] = base_value(:polar_adjustment_factor) * 
                                          (1.0 + (axial_tilt / 90.0))
    end
    
    def base_value(key)
      GameConstants::BIOSPHERE_SIMULATION[key]
    end
  end
end