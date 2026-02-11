# app/services/ai_manager/pattern_loader.rb
module AIManager
  class PatternLoader
    def self.load_terraforming_patterns
      pattern_file = GalaxyGame::Paths::AI_MANAGER_PATH.join('terraforming_patterns.json')

      if File.exist?(pattern_file)
        JSON.parse(File.read(pattern_file))
      else
        Rails.logger.warn "[PatternLoader] Terraforming patterns file not found: #{pattern_file}"
        {}
      end
    end

    def self.load_corporate_patterns
      pattern_file = GalaxyGame::Paths::AI_MANAGER_PATH.join('corporate_patterns.json')

      if File.exist?(pattern_file)
        JSON.parse(File.read(pattern_file))
      else
        Rails.logger.warn "[PatternLoader] Corporate patterns file not found: #{pattern_file}"
        {}
      end
    end

    def self.load_construction_patterns
      pattern_file = GalaxyGame::Paths::AI_PATTERNS_PATH

      if File.exist?(pattern_file)
        JSON.parse(File.read(pattern_file))
      else
        Rails.logger.warn "[PatternLoader] Construction patterns file not found: #{pattern_file}"
        {}
      end
    end

    def self.load_learned_patterns_from_execution
      # Load patterns learned from actual AI execution
      execution_file = GalaxyGame::Paths::AI_EXECUTION_PATTERNS_PATH
      
      if File.exist?(execution_file)
        JSON.parse(File.read(execution_file))
      else
        Rails.logger.info "[PatternLoader] No execution patterns found - all patterns are theoretical"
        {}
      end
    end

    def self.load_freeciv_geographical_patterns
      # Load geographical patterns extracted from FreeCiv/Civ4 maps for AI training
      pattern_file = GalaxyGame::Paths::DOCS_PATH.join('developer', 'freeciv_geographical_patterns.json')

      if File.exist?(pattern_file)
        JSON.parse(File.read(pattern_file))
      else
        Rails.logger.info "[PatternLoader] FreeCiv geographical patterns not found - using default patterns"
        default_freeciv_patterns
      end
    end

    def self.default_freeciv_patterns
      # Default geographical patterns based on analyzed FreeCiv/Civ4 maps
      {
        "archipelago_world" => {
          "ocean_coverage" => 0.479,
          "landmass_distribution" => "scattered_islands",
          "coastal_complexity" => "high",
          "exploration_focus" => "water_based",
          "learned_from" => ["Dark Tower Beta"],
          "applications" => ["island_hopping_civilizations", "water_trade_routes"]
        },
        "corrupted_fantasy" => {
          "custom_terrains" => ["chaos_waste", "boneplains", "lava", "marsh", "scorched_earth"],
          "corruption_percentage" => 0.053,
          "terrain_variety" => "high",
          "learned_from" => ["Warhammer Map"],
          "applications" => ["magical_corruption_mechanics", "post_apocalyptic_worlds"]
        },
        "water_rich_moon" => {
          "ocean_coverage" => 0.272,
          "habitable_zones" => "mixed",
          "cryogenic_features" => true,
          "learned_from" => ["Dione (Saturn)"],
          "applications" => ["subsurface_ocean_planets", "icy_moon_colonization"]
        },
        "hydrocentric_world" => {
          "ocean_coverage" => 0.555,
          "shallow_sea_percentage" => 0.70,
          "continental_shelves" => "extensive",
          "learned_from" => ["Jurassic Map"],
          "applications" => ["ancient_sea_worlds", "marine_ecosystems"]
        }
      }
    end

    # Get specific terraforming pattern
    def self.terraforming_pattern(pattern_name)
      patterns = load_terraforming_patterns
      pattern_data = patterns[pattern_name]

      if pattern_data
        pattern_data['data']
      else
        Rails.logger.warn "[PatternLoader] Terraforming pattern not found: #{pattern_name}"
        nil
      end
    end

    # Apply biosphere engineering pattern from Mars demo
    def self.apply_biosphere_engineering_pattern(world)
      pattern = terraforming_pattern('biosphere_engineering')

      return {} unless pattern

      # Extract key parameters from the pattern
      readiness_conditions = pattern['readiness_conditions'] || {}
      seeding_strategy = pattern['seeding_strategy'] || {}
      ecosystem_phases = pattern['ecosystem_phases'] || []

      # Assess current world conditions against pattern requirements
      current_conditions = assess_world_readiness(world, readiness_conditions)

      # Determine appropriate seeding strategy based on pattern
      seeding_recommendations = determine_seeding_strategy(world, seeding_strategy, current_conditions)

      # Calculate ecosystem development timeline
      development_timeline = calculate_ecosystem_timeline(ecosystem_phases, current_conditions)

      {
        readiness_assessment: current_conditions,
        seeding_strategy: seeding_recommendations,
        development_timeline: development_timeline,
        success_indicators: pattern['success_indicators'] || []
      }
    end

    # Apply atmospheric transfer pattern
    def self.apply_atmospheric_transfer_pattern(world, available_resources)
      pattern = terraforming_pattern('atmospheric_transfer')

      return {} unless pattern

      transfer_modes = pattern['transfer_modes'] || {}
      transfer_windows = pattern['transfer_windows'] || {}
      efficiency_factors = pattern['efficiency_factors'] || {}

      # Determine optimal transfer mode based on world conditions
      optimal_mode = determine_optimal_transfer_mode(world, transfer_modes)

      # Calculate transfer windows and efficiency
      transfer_schedule = calculate_transfer_schedule(world, transfer_windows, available_resources)

      # Apply efficiency factors
      efficiency_adjustments = apply_efficiency_factors(efficiency_factors, world)

      {
        optimal_transfer_mode: optimal_mode,
        transfer_schedule: transfer_schedule,
        efficiency_adjustments: efficiency_adjustments,
        key_principles: pattern['key_principles'] || []
      }
    end

    private

    def self.assess_world_readiness(world, readiness_conditions)
      results = {}

      readiness_conditions.each do |condition, requirement|
        case condition
        when 'temperature'
          current_temp = world.surface_temperature
          target_temp = 273.15 # Freezing point
          results[condition] = {
            current: current_temp,
            target: target_temp,
            status: current_temp >= target_temp ? 'met' : 'not_met',
            requirement: requirement
          }
        when 'pressure'
          current_pressure = world.atmosphere&.pressure || 0
          min_pressure = 0.01 # Minimum viable pressure
          results[condition] = {
            current: current_pressure,
            target: min_pressure,
            status: current_pressure >= min_pressure ? 'met' : 'not_met',
            requirement: requirement
          }
        when 'oxygen'
          current_o2 = world.atmosphere&.o2_percentage || 0
          max_safe_o2 = 22.0 # Max safe O2 percentage
          results[condition] = {
            current: current_o2,
            target: max_safe_o2,
            status: current_o2 <= max_safe_o2 ? 'met' : 'not_met',
            requirement: requirement
          }
        when 'water'
          liquid_water = world.hydrosphere&.state_distribution&.dig('liquid').to_f || 0
          min_liquid = 0.1 # Minimum liquid water percentage
          results[condition] = {
            current: liquid_water,
            target: min_liquid,
            status: liquid_water >= min_liquid ? 'met' : 'not_met',
            requirement: requirement
          }
        when 'radiation'
          # Simplified radiation assessment - assume magnetosphere provides protection
          has_protection = world.magnetosphere_protection?
          results[condition] = {
            current: has_protection,
            target: true,
            status: has_protection ? 'met' : 'not_met',
            requirement: requirement
          }
        end
      end

      results
    end

    def self.determine_seeding_strategy(world, seeding_strategy, current_conditions)
      # Base strategy from pattern
      strategy = seeding_strategy.dup

      # Adjust based on current conditions
      unmet_conditions = current_conditions.select { |_, data| data['status'] == 'not_met' }

      if unmet_conditions.any?
        strategy['timing'] = 'Delayed - address readiness conditions first'
        strategy['priority_actions'] = unmet_conditions.keys
      else
        strategy['timing'] = seeding_strategy['timing'] || 'After maintenance phase begins'
        strategy['priority_actions'] = ['proceed_with_seeding']
      end

      # Scale population based on world size (simplified)
      base_population = 1_000_000_000 # 1 billion base
      world_size_factor = world.size || 1.0
      strategy['recommended_population'] = (base_population * world_size_factor).to_i

      strategy
    end

    def self.calculate_ecosystem_timeline(ecosystem_phases, current_conditions)
      timeline = {}
      base_timeline = {
        'Microbial colonization' => 100, # days
        'Primary producer establishment' => 500,
        'Nutrient cycling development' => 2000,
        'Complex organism introduction' => 5000,
        'Ecosystem stabilization' => 10000
      }

      current_year = 0
      ecosystem_phases.each do |phase|
        duration = base_timeline[phase] || 1000
        timeline[phase] = {
          start_year: current_year,
          duration_days: duration,
          end_year: current_year + (duration / 365.25).round(1)
        }
        current_year += (duration / 365.25).round(1)
      end

      timeline
    end

    def self.determine_optimal_transfer_mode(world, transfer_modes)
      # Simplified logic - prioritize based on world conditions
      current_pressure = world.atmosphere&.pressure || 0
      target_pressure = 0.81 # Earth-like pressure

      if current_pressure < target_pressure * 0.6
        # Early warming phase - use raw transfer for greenhouse building
        transfer_modes['raw'] || 'Direct atmospheric transfer'
      else
        # Later phase - use processed transfer for composition control
        transfer_modes['processed'] || 'Processed gas transfer'
      end
    end

    def self.calculate_transfer_schedule(world, transfer_windows, available_resources)
      schedule = {}

      transfer_windows.each do |route, data|
        period_days = data['period'] || 365
        purpose = data['purpose'] || 'General transfer'

        # Check if resources are available for this route
        route_available = check_resource_availability(route, available_resources)

        schedule[route] = {
          period_days: period_days,
          purpose: purpose,
          available: route_available,
          next_window_days: calculate_next_window(world, route, period_days)
        }
      end

      schedule
    end

    def self.check_resource_availability(route, available_resources)
      # Simplified resource checking
      case route.downcase
      when /venus/
        available_resources.include?('CO2') || available_resources.include?('venus_atmosphere')
      when /titan/
        available_resources.include?('CH4') || available_resources.include?('titan_atmosphere')
      when /saturn/
        available_resources.include?('H2') || available_resources.include?('saturn_atmosphere')
      else
        false
      end
    end

    def self.calculate_next_window(world, route, period_days)
      # Simplified - return next window in days
      # In reality, this would calculate based on orbital mechanics
      rand(period_days / 4..period_days / 2) # Random window within quarter to half period
    end

    def self.apply_efficiency_factors(efficiency_factors, world)
      adjustments = {}

      efficiency_factors.each do |factor, base_value|
        # Adjust based on world conditions
        adjustment = case factor.to_s
        when 'transport_loss'
          # Higher loss for distant worlds
          world.name.include?('Mars') ? base_value : base_value * 1.2
        when 'co2_to_o2_efficiency'
          # Better efficiency with technological advancement
          base_value * 1.1
        when 'magnetosphere_retention'
          # Depends on magnetosphere strength
          world.magnetosphere_protection? ? base_value : base_value * 0.8
        else
          base_value
        end

        adjustments[factor] = adjustment
      end

      adjustments
    end
  end
end