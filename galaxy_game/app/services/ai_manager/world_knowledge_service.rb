# app/services/ai_manager/world_knowledge_service.rb
module AIManager
  class WorldKnowledgeService
    # Universal ISRU technologies and their capabilities
    ISRU_TECHNOLOGIES = {
      atmospheric_processor: {
        inputs: [:co2, :nitrogen, :methane],
        outputs: [:oxygen, :fuel, :chemicals],
        efficiency: 0.7,
        power_requirement: 50
      },

      water_extractor: {
        inputs: [:water_ice, :atmospheric_water, :regolith_water],
        outputs: [:water, :oxygen, :hydrogen],
        efficiency: 0.85,
        power_requirement: 25
      },

      mineral_processor: {
        inputs: [:regolith, :ore_deposits],
        outputs: [:metals, :silicates, :oxygen],
        efficiency: 0.6,
        power_requirement: 75
      },

      solar_farm: {
        inputs: [:solar_energy],
        outputs: [:electricity],
        efficiency: 0.22,
        power_output: 1000
      },

      nuclear_reactor: {
        inputs: [:uranium, :thorium],
        outputs: [:electricity, :heat],
        efficiency: 0.35,
        power_output: 100
      }
    }.freeze

    def initialize(celestial_body_data = nil)
      @celestial_body = celestial_body_data
    end

    def celestial_body=(data)
      @celestial_body = data
    end

    # Assess what resources are locally available based on actual celestial body data
    def assess_local_resources
      return {} unless @celestial_body

      available_resources = {}

      # Analyze atmospheric composition
      if @celestial_body['atmosphere_attributes']
        atmosphere = @celestial_body['atmosphere_attributes']
        atmosphere.each do |gas, data|
          next unless data.is_a?(Hash) && data['percentage'].to_f > 0.001

          available_resources[gas.downcase.to_sym] = {
            source: :atmosphere,
            abundance: data['percentage'].to_f,
            ease_of_extraction: calculate_atmospheric_extraction_difficulty(gas, data['percentage'].to_f)
          }
        end
      end

      # Analyze surface materials
      if @celestial_body['materials']
        @celestial_body['materials'].each do |material|
          material_name = material['name']&.downcase&.gsub(/\s+/, '_')&.to_sym
          abundance = material['abundance'] || material['percentage'] || 0.1

          available_resources[material_name] = {
            source: :surface,
            abundance: abundance.to_f,
            ease_of_extraction: calculate_surface_extraction_difficulty(material)
          }
        end
      end

      # Check for water ice (common on many bodies)
      if has_water_ice?
        available_resources[:water_ice] = {
          source: detect_water_ice_location,
          abundance: estimate_water_ice_abundance,
          ease_of_extraction: calculate_water_extraction_difficulty
        }
      end

      # Check geological features for additional resources
      if @celestial_body['geological_features']
        @celestial_body['geological_features'].each do |feature|
          resources_from_feature = analyze_geological_feature(feature)
          available_resources.merge!(resources_from_feature)
        end
      end

      available_resources
    end

    # Determine what can be produced locally based on equipment and available resources
    def assess_production_capabilities(equipment_list = [])
      return {
        oxygen_production_rate: 0,
        water_production_rate: 0,
        fuel_production_rate: 0,
        food_production_rate: 0
      } unless @celestial_body

      local_resources = assess_local_resources

      capabilities = {
        oxygen_production_rate: calculate_production_rate(:oxygen, equipment_list, local_resources),
        water_production_rate: calculate_production_rate(:water, equipment_list, local_resources),
        fuel_production_rate: calculate_production_rate(:fuel, equipment_list, local_resources),
        food_production_rate: calculate_production_rate(:food, equipment_list, local_resources)
      }

      capabilities
    end

    def calculate_production_rate(resource_type, equipment_list, local_resources)
      return 0 unless equipment_list && local_resources.any?

      rate = 0
      base_rate = 50 # kg/day per unit base rate

      equipment_list.each do |category, items|
        next unless items.is_a?(Array)

        items.each do |item|
          item_name = item.to_s.downcase
          multiplier = 1.0

          case resource_type
          when :oxygen
            if item_name.include?('oxygen_generator') || item_name.include?('electrolysis')
              multiplier = 1.0 if local_resources[:water_ice] || local_resources[:co2]
            elsif item_name.include?('sabathier')
              multiplier = 2.0 if local_resources[:co2] && local_resources[:h2]
            end
          when :water
            if item_name.include?('water_extractor') || item_name.include?('ice_mining')
              multiplier = 1.0 if local_resources[:water_ice]
            elsif item_name.include?('atmospheric_processor')
              multiplier = 0.5 if local_resources[:h2o]
            end
          when :fuel
            if item_name.include?('methane_processor') || item_name.include?('fuel_synthesis')
              multiplier = 1.0 if local_resources[:co2] || local_resources[:methane]
            end
          when :food
            if item_name.include?('hydroponics') || item_name.include?('food_synthesis')
              multiplier = 1.0 # Food production is more equipment-limited than resource-limited
            end
          end

          rate += base_rate * multiplier if multiplier > 0
        end
      end

      rate
    end

    # Augment incomplete patterns with world-specific knowledge
    def augment_pattern(pattern)
      return pattern unless @celestial_body

      augmented = pattern.deep_dup

      # Add local resource availability
      local_resources = assess_local_resources
      augmented[:world_context] = {
        world_name: @celestial_body['name'],
        world_type: @celestial_body['type'],
        local_resources: local_resources,
        production_capabilities: assess_production_capabilities(extract_equipment_list(pattern)),
        challenges: identify_challenges,
        natural_resources: identify_natural_resources
      }

      # Enhance resource dependencies with local production estimates
      if augmented[:resource_dependencies]
        augmented[:resource_dependencies][:local_production_potential] = estimate_local_production(pattern)
        augmented[:resource_dependencies][:import_requirements] = calculate_import_needs(pattern)
      end

      # Adjust economic model based on local resources
      if augmented[:economic_model]
        augmented[:economic_model][:local_resource_benefits] = calculate_local_benefits(pattern)
        augmented[:economic_model][:adjusted_import_ratio] = recalculate_import_ratio(pattern)
      end

      augmented
    end

    def suggest_isru_equipment(world_type, validation_errors)
      return [] unless @celestial_body

      suggestions = []

      validation_errors.each do |error|
        case error[:message]
        when /oxygen/i
          if @celestial_body['atmosphere_attributes']&.dig('co2', 'percentage')&.to_f&.> 0.01
            suggestions << 'oxygen_generator'
            suggestions << 'sabathier_reactor' if @celestial_body['atmosphere_attributes']&.dig('h2', 'percentage')&.to_f&.> 0.001
          end
        when /water/i
          if has_water_ice?
            suggestions << 'water_extractor'
          end
        when /food/i
          suggestions << 'hydroponics_module'
        end
      end

      suggestions.uniq
    end

    # Helper methods for analyzing celestial body data
    def has_water_ice?
      return false unless @celestial_body

      # Check surface temperature (water ice exists below ~200K)
      temp = @celestial_body['surface_temperature'].to_f
      return true if temp < 200

      # Check for polar regions or permanently shadowed areas
      if @celestial_body['geological_features']
        @celestial_body['geological_features'].any? do |feature|
          if feature.is_a?(Hash)
            feature['type']&.include?('polar') || feature['type']&.include?('crater')
          elsif feature.is_a?(String)
            feature.include?('polar') || feature.include?('crater')
          else
            false
          end
        end
      end

      false
    end

    def detect_water_ice_location
      return :unknown unless @celestial_body

      # Check geological features for clues
      if @celestial_body['geological_features']
        polar_features = @celestial_body['geological_features'].select do |feature|
          if feature.is_a?(Hash)
            feature['type']&.include?('polar')
          elsif feature.is_a?(String)
            feature.include?('polar')
          else
            false
          end
        end
        return :polar_caps if polar_features.any?

        crater_features = @celestial_body['geological_features'].select do |feature|
          if feature.is_a?(Hash)
            feature['type']&.include?('crater')
          elsif feature.is_a?(String)
            feature.include?('crater')
          else
            false
          end
        end
        return :craters if crater_features.any?
      end

      :surface
    end

    def estimate_water_ice_abundance
      return 0.0 unless @celestial_body

      # Base estimate based on temperature
      temp = @celestial_body['surface_temperature'].to_f
      base_abundance = case temp
                       when 0..150 then 0.8   # Very cold, likely lots of ice
                       when 151..200 then 0.3 # Cold, some ice possible
                       else 0.0               # Too warm for surface ice
                       end

      # Adjust based on geological features
      if @celestial_body['geological_features']
        polar_bonus = @celestial_body['geological_features'].count do |f|
          if f.is_a?(Hash)
            f['type']&.include?('polar')
          elsif f.is_a?(String)
            f.include?('polar')
          else
            false
          end
        end * 0.2
        crater_bonus = @celestial_body['geological_features'].count do |f|
          if f.is_a?(Hash)
            f['type']&.include?('crater')
          elsif f.is_a?(String)
            f.include?('crater')
          else
            false
          end
        end * 0.1
        base_abundance += polar_bonus + crater_bonus
      end

      [base_abundance, 1.0].min
    end

    def calculate_atmospheric_extraction_difficulty(gas, percentage)
      # Higher percentage = easier extraction
      base_difficulty = 5.0
      percentage_modifier = (1.0 - percentage) * 3.0  # Higher percentage = lower difficulty
      pressure_modifier = @celestial_body['known_pressure'].to_f < 1.0 ? 2.0 : 0.0  # Low pressure = harder

      [base_difficulty + percentage_modifier + pressure_modifier, 10.0].min
    end

    def calculate_surface_extraction_difficulty(material)
      base_difficulty = 3.0

      # Mining difficulty based on material properties
      if material['hardness'] || material['type']&.include?('ore')
        base_difficulty += 2.0
      end

      # Location affects difficulty
      if material['locations']&.include?('subsurface')
        base_difficulty += 1.0
      end

      [base_difficulty, 10.0].min
    end

    def calculate_water_extraction_difficulty
      return 10.0 unless @celestial_body

      base_difficulty = 5.0
      location = detect_water_ice_location

      case location
      when :polar_caps then base_difficulty += 1.0  # Accessible but cold
      when :craters then base_difficulty += 2.0     # Permanently shadowed, harder access
      when :subsurface then base_difficulty += 3.0  # Drilling required
      else base_difficulty += 1.0
      end

      [base_difficulty, 10.0].min
    end

    def analyze_geological_feature(feature)
      resources = {}

      feature_type = if feature.is_a?(Hash)
                       feature['type']
                     elsif feature.is_a?(String)
                       feature
                     else
                       nil
                     end

      case feature_type
      when /volcanic|volcano/i
        resources[:volcanic_glass] = {
          source: :surface,
          abundance: 0.3,
          ease_of_extraction: 4.0
        }
      when /impact|crater/i
        resources[:impact_glass] = {
          source: :surface,
          abundance: 0.2,
          ease_of_extraction: 3.0
        }
      when /ice|polar/i
        resources[:water_ice] = {
          source: :surface,
          abundance: 0.6,
          ease_of_extraction: 6.0  # Cold temperatures make extraction harder
        }
      end

      resources
    end

    def identify_challenges
      return [] unless @celestial_body

      challenges = []

      # Temperature challenges
      temp = @celestial_body['surface_temperature'].to_f
      if temp < 200
        challenges << :extreme_cold
      elsif temp > 400
        challenges << :extreme_heat
      end

      # Pressure challenges
      pressure = @celestial_body['known_pressure'].to_f
      if pressure < 0.01
        challenges << :near_vacuum
      elsif pressure > 10
        challenges << :high_pressure
      end

      # Gravity challenges
      gravity = @celestial_body['gravity'].to_f
      if gravity < 0.3
        challenges << :low_gravity
      elsif gravity > 3.0
        challenges << :high_gravity
      end

      # Radiation (all bodies without magnetic field or atmosphere)
      if @celestial_body['magnetosphere'].nil? && pressure < 0.1
        challenges << :radiation
      end

      challenges
    end

    def identify_natural_resources
      resources = [:solar_energy] # Most bodies have access to solar energy

      # Geothermal energy for geologically active bodies
      if @celestial_body['geological_activity'].to_i > 50
        resources << :geothermal_energy
      end

      # Wind energy for bodies with atmosphere
      if @celestial_body['known_pressure'].to_f > 0.1
        resources << :wind_energy
      end

      resources
    end

    private

    def extract_equipment_list(pattern)
      equipment = []

      # From craft fit
      craft_fit = pattern.dig(:equipment_requirements, :craft_fit) || {}
      equipment.concat(craft_fit[:modules] || [])
      equipment.concat(craft_fit[:units] || [])

      # From inventory
      inventory = pattern.dig(:equipment_requirements, :inventory) || {}
      equipment.concat(inventory[:deployable_units] || [])

      equipment
    end

    def estimate_local_production(pattern)
      return {} unless @celestial_body

      production = {}
      equipment_list = extract_equipment_list(pattern)
      capabilities = assess_production_capabilities(equipment_list)

      # Estimate crew size for consumption calculations
      crew_size = estimate_crew_from_pattern(pattern)

      if crew_size > 0
        # Oxygen production estimate
        daily_oxygen_need = crew_size * 0.84
        if capabilities[:oxygen_production_rate] > 0
          production[:oxygen] = {
            daily_production: [capabilities[:oxygen_production_rate], daily_oxygen_need].min,
            coverage_percentage: [(capabilities[:oxygen_production_rate] / daily_oxygen_need * 100), 100].min,
            remaining_import: [daily_oxygen_need - capabilities[:oxygen_production_rate], 0].max
          }
        end

        # Water production estimate
        daily_water_need = crew_size * 3.0
        if capabilities[:water_production_rate] > 0
          production[:water] = {
            daily_production: [capabilities[:water_production_rate], daily_water_need].min,
            coverage_percentage: [(capabilities[:water_production_rate] / daily_water_need * 100), 100].min,
            remaining_import: [daily_water_need - capabilities[:water_production_rate], 0].max
          }
        end
      end

      production
    end

    def calculate_import_needs(pattern)
      local_production = estimate_local_production(pattern)
      imports = {}

      # Calculate what still needs to be imported
      local_production.each do |resource, data|
        if data[:remaining_import] && data[:remaining_import] > 0
          imports[resource] = {
            amount_needed: data[:remaining_import],
            timeframe: pattern.dig(:phase_structure, :estimated_total_duration) || 720,
            priority: resource == :oxygen ? :critical : :standard
          }
        end
      end

      imports
    end

    def calculate_local_benefits(pattern)
      local_production = estimate_local_production(pattern)
      benefits = {}

      # Calculate cost savings from local production
      local_production.each do |resource, data|
        coverage = data[:coverage_percentage] || 0
        if coverage > 0
          benefits[resource] = {
            coverage_percentage: coverage,
            cost_savings: coverage * 0.01  # Simplified cost factor
          }
        end
      end

      benefits
    end

    def recalculate_import_ratio(pattern)
      original_ratio = pattern.dig(:economic_model, :import_ratio) || 0.5
      local_production = estimate_local_production(pattern)

      return original_ratio if local_production.empty?

      # Reduce import ratio based on local production capabilities
      reduction = local_production.values.sum { |data| (data[:coverage_percentage] || 0) / 100.0 } / local_production.size

      [original_ratio * (1 - reduction), 0.1].max # Minimum 10% imports for redundancy
    end

    def estimate_crew_from_pattern(pattern)
      habitat_count = 0

      # Count habitats from equipment
      craft_fit = pattern.dig(:equipment_requirements, :craft_fit) || {}
      units = craft_fit[:units] || []

      units.each do |unit|
        if unit.to_s.downcase.include?('habitat') || unit.to_s.downcase.include?('habitation')
          habitat_count += 1
        end
      end

      # Estimate 4-6 people per habitat module
      habitat_count * 5
    end

    def count_equipment_items(pattern)
      craft_fit = pattern.dig(:equipment_requirements, :craft_fit) || {}
      units = craft_fit[:units] || []
      modules = craft_fit[:modules] || []

      units.length + modules.length
    end

    def recommend_isru_equipment(pattern)
      return [] unless @celestial_body

      recommendations = []
      local_resources = assess_local_resources

      # Always recommend atmospheric processor if world has useful atmosphere
      if local_resources.any? { |_, data| data[:source] == :atmosphere && data[:abundance] > 0.01 }
        recommendations << 'atmospheric_processor'
      end

      # Recommend water extractor if water sources exist
      water_sources = local_resources.select { |resource, _| resource.to_s.include?('water') }
      if water_sources.any? { |_, data| data[:source] != :atmosphere }
        recommendations << 'water_extractor'
      end

      # Recommend mineral processor for most worlds
      if local_resources.any? { |_, data| data[:source] == :surface }
        recommendations << 'mineral_processor'
      end

      recommendations
    end

    # Comprehensive world analysis for settlement planning
    def analyze_world_for_settlement
      return default_world_analysis unless @celestial_body

      {
        world_type: determine_world_type,
        atmospheric_resources: assess_atmospheric_resources,
        surface_resources: assess_surface_resources,
        geological_features: assess_geological_features,
        environmental_challenges: assess_environmental_challenges,
        settlement_potential: calculate_settlement_potential,
        recommended_approach: determine_settlement_approach,
        dc_alignment: suggest_dc_alignment
      }
    end

    private

    def determine_world_type
      return :unknown unless @celestial_body

      name = @celestial_body['name']&.downcase

      # Gas giant moons
      return :gas_giant_moon if ['titan', 'europa', 'ganymede', 'callisto', 'io'].include?(name)

      # Ice giant moons
      return :ice_giant_moon if ['triton', 'nereid'].include?(name)

      # Terrestrial planets
      return :terrestrial_planet if ['mars', 'venus'].include?(name)

      # Other classifications
      return :venus_like if @celestial_body['atmosphere_attributes']&.dig('co2', 'percentage')&.to_f&.> 90
      return :icy_body if has_water_ice? && (@celestial_body['temperature']&.to_f || 0) < 200
      return :airless_body if @celestial_body['atmosphere_attributes'].nil? || @celestial_body['atmosphere_attributes'].empty?

      :unknown
    end

    def assess_atmospheric_resources
      resources = {}

      if @celestial_body['atmosphere_attributes']
        @celestial_body['atmosphere_attributes'].each do |gas, data|
          percentage = data['percentage'].to_f
          next if percentage < 0.001

          resources[gas.downcase.to_sym] = {
            abundance: percentage,
            extraction_difficulty: calculate_atmospheric_extraction_difficulty(gas, percentage),
            economic_value: assess_gas_value(gas, percentage)
          }
        end
      end

      resources
    end

    def assess_surface_resources
      resources = {}

      if @celestial_body['materials']
        @celestial_body['materials'].each do |material|
          name = material['name']&.downcase&.gsub(/\s+/, '_')&.to_sym
          abundance = material['abundance']&.to_f || 0.1

          resources[name] = {
            abundance: abundance,
            extraction_difficulty: calculate_surface_extraction_difficulty(material),
            economic_value: assess_material_value(material)
          }
        end
      end

      # Add water ice if present
      if has_water_ice?
        resources[:water_ice] = {
          abundance: estimate_water_ice_abundance,
          extraction_difficulty: calculate_water_extraction_difficulty,
          economic_value: :high
        }
      end

      resources
    end

    def assess_geological_features
      features = []

      if @celestial_body['geological_features']
        @celestial_body['geological_features'].each do |feature|
          features << {
            type: feature['type'],
            significance: feature['significance'] || 'unknown',
            resources: analyze_geological_feature(feature)
          }
        end
      end

      features
    end

    def assess_environmental_challenges
      challenges = []

      # Temperature challenges
      temp = @celestial_body['temperature']&.to_f
      if temp && temp < 200
        challenges << { type: :extreme_cold, severity: :high }
      elsif temp && temp > 400
        challenges << { type: :extreme_heat, severity: :high }
      end

      # Radiation
      if @celestial_body['radiation_level']&.to_f&. > 0.1
        challenges << { type: :radiation, severity: :high }
      end

      # Atmospheric pressure
      pressure = @celestial_body['atmospheric_pressure']&.to_f
      if pressure && pressure < 0.01
        challenges << { type: :low_pressure, severity: :high }
      elsif pressure && pressure > 10
        challenges << { type: :high_pressure, severity: :high }
      end

      challenges
    end

    def calculate_settlement_potential
      score = 50 # Base score

      # Atmospheric resources add points
      atmospheric_count = assess_atmospheric_resources.keys.count
      score += atmospheric_count * 10

      # Surface resources add points
      surface_count = assess_surface_resources.keys.count
      score += surface_count * 5

      # Water ice is highly valuable
      score += 20 if has_water_ice?

      # Environmental challenges subtract points
      challenges = assess_environmental_challenges
      challenge_penalty = challenges.sum { |c| c[:severity] == :high ? 15 : 5 }
      score -= challenge_penalty

      [score, 100].min # Cap at 100
    end

    def determine_settlement_approach
      world_type = determine_world_type
      challenges = assess_environmental_challenges

      if challenges.any? { |c| c[:severity] == :high }
        return :specialized_approach
      end

      case world_type
      when :gas_giant_moon
        :orbital_preference
      when :terrestrial_planet
        :surface_focus
      when :venus_like
        :atmospheric_focus
      else
        :balanced_approach
      end
    end

    def suggest_dc_alignment
      world_type = determine_world_type

      case world_type
      when :gas_giant_moon
        'Saturn Development Corporation (SDC)'
      when :ice_giant_moon
        'Neptune Development Corporation (NDC)'
      when :terrestrial_planet
        'Mars Development Corporation (MDC)'
      when :venus_like
        'Venus Development Corporation (VDC)'
      else
        'Independent Development Corporation (IDC)'
      end
    end

    def default_world_analysis
      {
        world_type: :unknown,
        atmospheric_resources: {},
        surface_resources: {},
        geological_features: [],
        environmental_challenges: [{ type: :unknown_conditions, severity: :unknown }],
        settlement_potential: 25,
        recommended_approach: :cautious_exploration,
        dc_alignment: 'Independent Development Corporation (IDC)'
      }
    end

    def assess_gas_value(gas, percentage)
      case gas.downcase
      when 'oxygen'
        :critical
      when 'co2'
        :high
      when 'nitrogen'
        :medium
      when 'methane', 'ethane'
        :high
      else
        :low
      end
    end

    def assess_material_value(material)
      name = material['name']&.downcase

      case name
      when /water|ice/
        :critical
      when /metal|iron|nickel|copper/
        :high
      when /silicon|carbon/
        :medium
      else
        :low
      end
    end

    # Generate subtle sci-fi Easter Egg based on world characteristics
    # Returns hash with flavor_text, easter_egg_id, and naming_description for JSON inclusion
    def generate_sci_fi_easter_egg
      return { flavor_text: nil, easter_egg_id: nil, naming_description: nil } unless @celestial_body

      temp = @celestial_body['surface_temperature'].to_f
      pressure = @celestial_body['known_pressure'].to_f
      has_ice = has_water_ice?
      has_atmosphere = pressure > 0.1
      world_type = determine_world_type

      # Load available Easter Eggs
      easter_eggs = load_easter_eggs

      # Find matching Easter Egg based on world characteristics
      matching_egg = find_matching_easter_egg(easter_eggs, world_type, temp, pressure, has_ice, has_atmosphere, false)

      if matching_egg
        {
          flavor_text: matching_egg['flavor_text'],
          easter_egg_id: matching_egg['easter_egg_id'],
          naming_description: matching_egg['naming_description'] || "A world that evokes the spirit of classic science fiction exploration."
        }
      else
        # Fallback to generic descriptions
        generate_generic_easter_egg(world_type, temp, pressure, has_ice, has_atmosphere)
      end
    end

    public

    # Generate easter egg for systems (e.g., wormhole systems)
    def generate_system_easter_egg(has_wormhole = false)
      return nil unless has_wormhole

      easter_eggs = load_easter_eggs

      # Find matching Easter Egg based on system characteristics
      matching_egg = find_matching_easter_egg(easter_eggs, nil, 0, 0, false, false, has_wormhole)

      if matching_egg
        {
          flavor_text: matching_egg['flavor_text'],
          easter_egg_id: matching_egg['easter_egg_id'],
          manifest_entry: matching_egg['manifest_entry']
        }
      else
        nil
      end
    end

    private

    def load_easter_eggs
      # Cache Easter Eggs to avoid repeated file I/O
      @easter_eggs_cache ||= begin
        easter_eggs_path = Rails.root.join('app', 'data', 'easter_eggs')
        return [] unless Dir.exist?(easter_eggs_path)

        Dir.glob("#{easter_eggs_path}/*.json").map do |file|
          begin
            data = JSON.parse(File.read(file))
            validate_easter_egg_data(data, file)
            data
          rescue JSON::ParserError => e
            Rails.logger.warn("Failed to parse Easter Egg file: #{file} - #{e.message}")
            nil
          rescue StandardError => e
            Rails.logger.warn("Error loading Easter Egg file: #{file} - #{e.message}")
            nil
          end
        end.compact
      end
    end

    def clear_easter_eggs_cache
      @easter_eggs_cache = nil
    end

    private

    def validate_easter_egg_data(data, file_path)
      required_fields = ['easter_egg_id', 'category', 'flavor_text']
      missing_fields = required_fields.select { |field| data[field].nil? }

      if missing_fields.any?
        Rails.logger.warn("Easter Egg file #{file_path} missing required fields: #{missing_fields.join(', ')}")
      end

      # Validate trigger conditions structure
      if data['trigger_conditions']
        triggers = data['trigger_conditions']
        if triggers['rarity'] && (triggers['rarity'] < 0.0 || triggers['rarity'] > 1.0)
          Rails.logger.warn("Easter Egg file #{file_path} has invalid rarity (must be 0.0-1.0): #{triggers['rarity']}")
        end
      end
    end

    def find_matching_easter_egg(easter_eggs, world_type, temp, pressure, has_ice, has_atmosphere, has_wormhole = false, location = nil)
      # Filter by world type and conditions
      candidates = easter_eggs.select do |egg|
        triggers = egg['trigger_conditions'] || {}
        next false unless triggers['rarity'].to_f > rand # Rarity check

        # Check specific conditions
        next false if triggers['has_ice'] && !has_ice
        next false if triggers['temperature_max'] && temp > triggers['temperature_max'].to_f
        next false if triggers['temperature_min'] && temp < triggers['temperature_min'].to_f
        next false if triggers['pressure_min'] && pressure < triggers['pressure_min'].to_f
        next false if triggers['pressure_max'] && pressure > triggers['pressure_max'].to_f
        next false if triggers['has_wormhole'] && !has_wormhole
        next false if triggers['location'] && triggers['location'] != location

        case triggers['world_type']
        when 'desert' then temp > 300 && pressure < 1.0 && !has_ice
        when 'icy' then has_ice && temp < 200
        when 'high_pressure' then pressure > 50 && temp > 400
        when 'gas_giant_moon' then world_type == :gas_giant_moon
        when 'terrestrial_planet' then world_type == :terrestrial_planet
        else true # No specific type requirement
        end
      end

      # Prefer more specific matches (those with specific conditions)
      specific_candidates = candidates.select do |egg|
        triggers = egg['trigger_conditions'] || {}
        triggers.key?('world_type') || triggers.key?('has_ice') || triggers.key?('temperature_max') || triggers.key?('temperature_min') || triggers.key?('has_wormhole') || triggers.key?('location')
      end
      return specific_candidates.sample if specific_candidates.any?

      # Fall back to general matches
      candidates.sample
    end

    def generate_generic_easter_egg(world_type, temp, pressure, has_ice, has_atmosphere)
      # Desert planet (Dune-like)
      if temp > 300 && pressure < 1.0 && !has_ice && world_type == :terrestrial_planet
        return {
          flavor_text: "A harsh world where the sands whisper secrets of ancient civilizations.",
          easter_egg_id: "desert_world_generic",
          naming_description: "This world's name draws inspiration from the unforgiving deserts of a renowned science fiction epic."
        }
      end

      # Icy moon (Europa-like, but with sci-fi nod)
      if has_ice && temp < 200 && world_type == :gas_giant_moon
        return {
          flavor_text: "Subsurface oceans hide mysteries beneath the frozen surface.",
          easter_egg_id: "icy_moon_generic",
          naming_description: "Named after the enigmatic icy worlds featured in classic space exploration tales."
        }
      end

      # Gas giant moon with atmosphere (Titan-like)
      if world_type == :gas_giant_moon && has_atmosphere
        return {
          flavor_text: "Thick atmosphere shrouds a world of hydrocarbon lakes and organic chemistry.",
          easter_egg_id: "methane_world_generic",
          naming_description: "This moon's designation echoes the hydrocarbon-rich worlds from interstellar adventure series."
        }
      end

      # High-pressure world (Venus-like)
      if pressure > 50 && temp > 400
        return {
          flavor_text: "Crushing pressures and searing heat forge a world of extreme conditions.",
          easter_egg_id: "pressure_world_generic",
          naming_description: "Inspired by the hellish, high-pressure planets depicted in pioneering science fiction works."
        }
      end

      # Default: no Easter Egg
      { flavor_text: nil, easter_egg_id: nil, naming_description: nil }
    end

    # Apply easter egg overlays to geological features
    def apply_easter_egg_overlays(geological_features)
      return geological_features unless @celestial_body

      # Load available Easter Eggs
      easter_eggs = load_easter_eggs

      # Find easter eggs with target_feature that could apply to this body
      applicable_eggs = easter_eggs.select do |egg|
        triggers = egg['trigger_conditions'] || {}
        target_feature = triggers['target_feature']
        target_feature && should_apply_easter_egg_overlay?(egg, @celestial_body)
      end

      # Apply overlays to matching features
      enhanced_features = geological_features.deep_dup

      applicable_eggs.each do |egg|
        target_id = egg['trigger_conditions']['target_feature']
        feature = find_feature_by_id(enhanced_features, target_id)

        if feature
          enhanced_features = apply_feature_overlay(enhanced_features, feature, egg)
        end
      end

      enhanced_features
    end

    private

    # Check if easter egg overlay should be applied based on conditions
    def should_apply_easter_egg_overlay?(egg, celestial_body)
      triggers = egg['trigger_conditions'] || {}
      rarity = triggers['rarity'].to_f

      # Rarity check
      return false if rarity > 0 && rand > rarity

      # Body type check
      body_name = celestial_body['name']&.downcase
      if triggers['body_name'] && body_name != triggers['body_name'].downcase
        return false
      end

      # System check
      system_id = celestial_body['identifier']&.split('-')&.first
      if triggers['system_template'] && !system_id&.include?(triggers['system_template'].split('-').first.downcase)
        return false
      end

      true
    end

    # Find feature by ID in nested feature structure
    def find_feature_by_id(features, target_id)
      # Handle nested structure: features[type][features]
      features.each do |type_key, type_data|
        next unless type_data.is_a?(Hash) && type_data['features'].is_a?(Array)

        type_data['features'].each do |feature|
          return feature if feature['id'] == target_id
        end
      end
      nil
    end

    # Apply easter egg overlay to a specific feature
    def apply_feature_overlay(features, feature, egg)
      overlay_data = egg['overlay'] || {}

      # Add easter egg metadata without modifying core scientific data
      feature['easter_egg_overlay'] = {
        easter_egg_id: egg['easter_egg_id'],
        category: egg['category'],
        flavor_text: egg['flavor_text'],
        applied_at: Time.current.iso8601
      }

      # Add overlay attributes if specified
      if overlay_data['additional_attributes']
        feature['additional_attributes'] ||= {}
        feature['additional_attributes'].merge!(overlay_data['additional_attributes'])
      end

      # Add gameplay enhancements if specified
      if overlay_data['gameplay_enhancements']
        feature['gameplay_enhancements'] ||= {}
        feature['gameplay_enhancements'].merge!(overlay_data['gameplay_enhancements'])
      end

      features
    end
  end
end