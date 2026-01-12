module AIManager
  class TerraformingManager
    attr_reader :worlds, :simulation_params

    def initialize(worlds:, simulation_params: {})
      @worlds = worlds # Hash: { mars:, venus:, titan:, saturn: }
      @simulation_params = default_params.merge(simulation_params)
      @orbital_depots = {}
      @patterns = AIManager::PatternLoader.load_terraforming_patterns
      initialize_depots
    end

    # Main decision-making methods

    def determine_terraforming_phase(world_key)
      world = @worlds[world_key]
      return :inactive unless world

      # Use learned terraforming phases pattern
      # phase_pattern = @patterns.dig('terraforming_phases', 'data', 'phase_definitions')
      # target_params = @patterns.dig('terraforming_phases', 'data', 'target_parameters')
      phase_pattern = nil # TODO: Implement determine_phase_from_pattern method
      target_params = nil

      if phase_pattern && target_params && respond_to?(:determine_phase_from_pattern)
        return determine_phase_from_pattern(world, phase_pattern, target_params)
      end

      # Fallback to original logic if pattern not available
      temp = world.surface_temperature
      liquid_water = world.hydrosphere&.state_distribution&.dig('liquid').to_f || 0.0
      threshold = @simulation_params[:mars_liquid_water_threshold]

      if temp < 273.0 || liquid_water < threshold
        :warming
      else
        :maintenance
      end
    end

    def calculate_gas_needs(world_key)
      world = @worlds[world_key]
      return {} unless world&.atmosphere

      # SHIELD-FIRST CONSTRAINT: No atmospheric modifications without magnetosphere protection
      unless has_magnetosphere_protection?(world)
        Rails.logger.info "[TerraformingManager] #{world.name}: Atmospheric modifications locked - no magnetosphere protection"
        return {}
      end

      # PLANETARY PRESERVATION: Check 5% atmospheric mass reduction cap
      if world.preservation_mode && atmospheric_reduction_exceeded?(world)
        Rails.logger.warn "[TerraformingManager] #{world.name}: Atmospheric extraction disabled (5% preservation cap reached)"
        return {}
      end

      phase = determine_terraforming_phase(world_key)

      # Use learned atmospheric transfer pattern for gas calculations
      available_resources = identify_available_resources(world_key)
      # transfer_pattern = AIManager::PatternLoader.apply_atmospheric_transfer_pattern(world, available_resources)
      transfer_pattern = {} # TODO: Implement pattern loading

      if transfer_pattern.any?
        return calculate_gas_needs_from_pattern(world, phase, transfer_pattern)
      end

      # Fallback to original logic
      case phase
      when :warming
        calculate_warming_phase_needs(world)
      when :maintenance
        calculate_maintenance_phase_needs(world)
      else
        {}
      end
    end

    def calculate_warming_phase_needs(world)
      # Basic CO2 needs for greenhouse warming
      { co2: 1000 }
    end

    def calculate_maintenance_phase_needs(world)
      # Minimal maintenance needs
      {}
    end

    def should_seed_biosphere?(world_key)
      world = @worlds[world_key]
      return false unless world&.hydrosphere

      # Already has biosphere
      return false if world.biosphere&.life_forms&.count.to_i > 0

      # Use learned biosphere engineering pattern
      # biosphere_pattern = AIManager::PatternLoader.apply_biosphere_engineering_pattern(world)
      biosphere_pattern = {} # TODO: Implement pattern loading

      if biosphere_pattern.any?
        readiness = biosphere_pattern[:readiness_assessment]
        return readiness.all? { |_, data| data['status'] == 'met' }
      end

      # Fallback to original logic
      liquid_water = world.hydrosphere.state_distribution&.dig('liquid').to_f || 0.0
      threshold = @simulation_params[:mars_liquid_water_threshold]
      temp = world.surface_temperature

      liquid_water >= threshold && temp >= 273.0
    end

    def seed_biosphere(world_key)
      world = @worlds[world_key]
      return false unless should_seed_biosphere?(world_key)

      # Use learned biosphere engineering pattern
      biosphere_pattern = AIManager::PatternLoader.apply_biosphere_engineering_pattern(world)

      if biosphere_pattern.any?
        return seed_biosphere_from_pattern(world, biosphere_pattern)
      end

      # Fallback to original logic
      biosphere = world.biosphere || world.create_biosphere!(
        habitable_ratio: 0.01,
        biodiversity_index: 0.0
      )

      create_starter_organisms(biosphere)

      true
    end

    def manage_oxygen_levels(world_key)
      world = @worlds[world_key]
      return unless world&.atmosphere

      o2_gas = world.atmosphere.gases.find_by(name: 'O2')
      return unless o2_gas

      o2_pct = o2_gas.percentage.to_f
      safe_threshold = @simulation_params[:safe_o2_threshold]

      return if o2_pct <= safe_threshold

      # Calculate excess O2 that needs removal
      excess_o2_mass = calculate_excess_o2(o2_gas, o2_pct, safe_threshold)
      return if excess_o2_mass <= 0

      # Calculate H2 needed for reaction
      h2_needed = excess_o2_mass * (2.0 / 32.0) # 2H2 + O2 -> 2H2O

      {
        action: :remove_o2_via_h2,
        o2_to_remove: excess_o2_mass,
        h2_needed: h2_needed,
        h2o_produced: h2_needed * (18.0 / 2.0)
      }
    end

    def execute_o2_management(world_key)
      plan = manage_oxygen_levels(world_key)
      return false unless plan

      world = @worlds[world_key]
      depot = @orbital_depots[world_key]

      h2_available = depot.get_gas('H2')
      h2_to_use = [plan[:h2_needed], h2_available].min
      return false if h2_to_use <= 0

      # Execute reaction
      depot.remove_gas('H2', h2_to_use)
      o2_to_consume = h2_to_use * (32.0 / 2.0)
      o2_to_consume = [o2_to_consume, plan[:o2_to_remove]].min
      
      world.atmosphere.remove_gas('O2', o2_to_consume)
      
      # Add water to hydrosphere
      h2o_produced = h2_to_use * (18.0 / 2.0)
      world.hydrosphere&.add_liquid('H2O', h2o_produced) if world.hydrosphere&.respond_to?(:add_liquid)

      {
        h2_consumed: h2_to_use,
        o2_consumed: o2_to_consume,
        h2o_produced: h2o_produced
      }
    end

    def calculate_methane_needs(world_key)
      world = @worlds[world_key]
      return nil unless world&.atmosphere

      ch4_gas = world.atmosphere.gases.find_by(name: 'CH4')
      ch4_pct = ch4_gas&.percentage.to_f || 0.0
      target_ch4 = @simulation_params[:target_ch4_pct]

      # Only synthesize if below threshold
      return nil if ch4_pct >= 0.5

      ch4_needed_mass = ((target_ch4 - ch4_pct) / 100.0) * world.atmosphere.total_atmospheric_mass
      capacity_limit = @simulation_params[:titan_capacity] || 1.0e13
      ch4_to_make = [ch4_needed_mass, capacity_limit].min

      {
        ch4_needed: ch4_to_make,
        co2_needed: ch4_to_make * (44.0 / 16.0),
        h2_needed: ch4_to_make * (8.0 / 16.0),
        h2o_produced: ch4_to_make * (36.0 / 16.0)
      }
    end

    def synthesize_methane(world_key, co2_source_key = nil)
      plan = calculate_methane_needs(world_key)
      return false unless plan

      world = @worlds[world_key]
      depot = @orbital_depots[world_key]

      # Try Mars CO2 first, then Venus if needed
      sources = [
        { key: world_key, world: world },
        { key: co2_source_key, world: @worlds[co2_source_key] }
      ].compact.select { |s| s[:world]&.atmosphere }

      sources.each do |source|
        co2_gas = source[:world].atmosphere.gases.find_by(name: 'CO2')
        next unless co2_gas

        co2_available = co2_gas.mass
        h2_available = depot.get_gas('H2')

        # Check if we have enough resources
        next if co2_available < plan[:co2_needed]
        next if h2_available < plan[:h2_needed]

        # Execute Sabatier reaction
        source[:world].atmosphere.remove_gas('CO2', plan[:co2_needed])
        depot.remove_gas('H2', plan[:h2_needed])
        world.atmosphere.add_gas('CH4', plan[:ch4_needed])

        # Add H2O to source world's hydrosphere
        if source[:world].hydrosphere&.respond_to?(:add_liquid)
          source[:world].hydrosphere.add_liquid('H2O', plan[:h2o_produced])
        end

        return {
          source: source[:key],
          co2_consumed: plan[:co2_needed],
          h2_consumed: plan[:h2_needed],
          ch4_produced: plan[:ch4_needed],
          h2o_produced: plan[:h2o_produced]
        }
      end

      false
    end

    def plan_h2_imports(world_key)
      h2_for_o2 = calculate_h2_for_o2_management(world_key)
      h2_for_ch4 = calculate_h2_for_sabatier(world_key)
      
      total_needed = h2_for_o2 + h2_for_ch4
      
      return nil if total_needed <= 0

      {
        total_h2_needed: total_needed,
        for_o2_management: h2_for_o2,
        for_methane_synthesis: h2_for_ch4
      }
    end

    def import_h2_from_gas_giant(source_key, dest_key, amount)
      source = @worlds[source_key]
      depot = @orbital_depots[dest_key]

      return false unless source&.atmosphere

      h2_gas = source.atmosphere.gases.find_by(name: 'H2')
      return false unless h2_gas

      available_h2 = h2_gas.mass
      h2_to_import = [amount, available_h2].min
      return false if h2_to_import <= 0

      source.atmosphere.remove_gas('H2', h2_to_import)
      depot.add_gas('H2', h2_to_import)

      h2_to_import
    end

    # Pattern-based helper methods

    def determine_phase_from_pattern(world, phase_pattern, target_params)
      current_pressure = world.atmosphere&.pressure || 0
      target_pressure = target_params['total_pressure']&.gsub(' bar', '')&.to_f || 0.81

      warming_threshold = target_pressure * 0.6 # 60% as per pattern

      if current_pressure < warming_threshold
        :warming
      else
        :maintenance
      end
    end

    def identify_available_resources(world_key)
      # Simplified resource identification - in real implementation would check orbital depots, nearby bodies, etc.
      world = @worlds[world_key]
      return [] unless world

      resources = []
      resources << 'venus_atmosphere' if @worlds[:venus]&.atmosphere&.co2_percentage.to_f > 90
      resources << 'titan_atmosphere' if @worlds[:titan]&.atmosphere&.ch4_percentage.to_f > 1
      resources << 'saturn_atmosphere' if @worlds[:saturn]&.atmosphere&.h2_percentage.to_f > 80
      resources << 'CO2' if world.atmosphere&.co2_percentage.to_f > 50
      resources << 'CH4' if world.atmosphere&.ch4_percentage.to_f > 0.1
      resources << 'H2' if world.atmosphere&.h2_percentage.to_f > 0.1

      resources
    end

    def calculate_gas_needs_from_pattern(world, phase, transfer_pattern)
      optimal_mode = transfer_pattern[:optimal_transfer_mode]
      transfer_schedule = transfer_pattern[:transfer_schedule]
      efficiency_adjustments = transfer_pattern[:efficiency_adjustments]

      gas_needs = {}

      case phase
      when :warming
        # Focus on CO2 for greenhouse effect
        target_co2 = 95.0
        current_co2 = world.atmosphere&.co2_percentage || 0
        if current_co2 < target_co2
          co2_needed = (target_co2 - current_co2) * world.atmosphere.total_atmospheric_mass * efficiency_adjustments['co2_to_o2_efficiency'].to_f
          gas_needs['CO2'] = co2_needed if co2_needed > 0
        end
      when :maintenance
        # Fine-tune composition
        target_params = @patterns.dig('terraforming_phases', 'data', 'target_parameters') || {}

        target_o2 = target_params['o2_percentage']&.gsub('%', '')&.to_f || 18.0
        current_o2 = world.atmosphere&.o2_percentage || 0

        if current_o2 < target_o2
          o2_needed = (target_o2 - current_o2) * world.atmosphere.total_atmospheric_mass * efficiency_adjustments['co2_to_o2_efficiency'].to_f
          gas_needs['O2'] = o2_needed if o2_needed > 0
        end

        target_ch4 = target_params['ch4_percentage']&.gsub('%', '')&.to_f || 1.0
        current_ch4 = world.atmosphere&.ch4_percentage || 0

        if current_ch4 < target_ch4
          ch4_needed = (target_ch4 - current_ch4) * world.atmosphere.total_atmospheric_mass
          gas_needs['CH4'] = ch4_needed if ch4_needed > 0
        end
      end

      gas_needs
    end

    def seed_biosphere_from_pattern(world, biosphere_pattern)
      seeding_strategy = biosphere_pattern[:seeding_strategy]
      development_timeline = biosphere_pattern[:development_timeline]

      biosphere = world.biosphere || world.create_biosphere!(
        habitable_ratio: 0.001,
        biodiversity_index: 0.0
      )

      # Use pattern-based seeding strategy
      recommended_population = seeding_strategy['recommended_population'] || 1_000_000_000

      # Create optimized starter organisms based on pattern
      create_optimized_starter_organisms(biosphere, recommended_population)

      Rails.logger.info "[TerraformingManager] #{world.name}: Biosphere seeded using learned patterns - #{recommended_population} initial organisms"

      true
    end

    def create_optimized_starter_organisms(biosphere, total_population)
      # Distribute population across optimized species from Mars demo pattern
      species_distribution = {
        'Extremophile Cyanobacteria' => 0.5,  # 50%
        'Cold-Adapted Green Algae' => 0.3,    # 30%
        'Methanogenic Archaea' => 0.2         # 20%
      }

      species_distribution.each do |species_name, proportion|
        population = (total_population * proportion).to_i

        properties = case species_name
        when 'Extremophile Cyanobacteria'
          {
            'oxygen_production_rate' => 0.001,
            'co2_consumption_rate' => 0.0012,
            'nitrogen_fixation_rate' => 0.0001,
            'preferred_biome' => 'Regolith',
            'min_temperature' => 170.0,
            'max_temperature' => 320.0
          }
        when 'Cold-Adapted Green Algae'
          {
            'oxygen_production_rate' => 0.0015,
            'co2_consumption_rate' => 0.0018,
            'preferred_biome' => 'Polar Cap',
            'min_temperature' => 180.0,
            'max_temperature' => 310.0
          }
        when 'Methanogenic Archaea'
          {
            'methane_production_rate' => 0.0008,
            'co2_consumption_rate' => 0.0005,
            'preferred_biome' => 'Subsurface',
            'min_temperature' => 160.0,
            'max_temperature' => 330.0
          }
        end

        Biology::LifeForm.create!(
          biosphere: biosphere,
          name: species_name,
          complexity: :simple,
          population: population,
          diet: species_name.include?('Methanogenic') ? 'chemosynthetic' : 'photosynthetic',
          properties: properties
        )
      end
    end

    private

    def default_params
      {
        safe_o2_threshold: 22.0,
        target_ch4_pct: 1.0,
        target_n2_pct: 70.0,
        target_o2_pct: 18.0,
        target_co2_pct: 0.04,
        target_total_pressure_bar: 0.81,
        mars_liquid_water_threshold: 1.0,
        cycler_capacity: 1.0e13,
        titan_capacity: 1.0e13
      }
    end

    def initialize_depots
      @worlds.each_key do |key|
        @orbital_depots[key] = OrbitalDepot.new
      end
    end

    def calculate_warming_phase_needs(world)
      # During warming, need lots of CO2 for greenhouse effect
      # Plus some N2 for atmospheric mass
      # BUT: Stop raw imports early (60-70% of target) to leave room for selective tuning
      pressure = world.atmosphere.pressure
      target_pressure = @simulation_params[:target_total_pressure_bar]
      
      # Stop raw imports at 60% of target to allow selective import headroom
      raw_import_cutoff = target_pressure * 0.6
      
      # Check if we should stop raw imports
      should_stop_raw = pressure >= raw_import_cutoff
      
      needs = {}
      unless should_stop_raw
        needs['CO2'] = :high
        needs['N2'] = :medium
      end
      
      {
        priority: :co2_greenhouse,
        pressure_met: should_stop_raw,
        current_pressure_pct: (pressure / target_pressure * 100).round(1),
        gases_needed: needs
      }
    end

    def calculate_maintenance_phase_needs(world)
      pressure = world.atmosphere.pressure
      target_pressure = @simulation_params[:target_total_pressure_bar]

      mars_n2_pct = get_gas_percentage(world, 'N2')
      mars_o2_pct = get_gas_percentage(world, 'O2')
      mars_co2_pct = get_gas_percentage(world, 'CO2')
      mars_ch4_pct = get_gas_percentage(world, 'CH4')

      target_n2 = @simulation_params[:target_n2_pct]
      target_o2 = @simulation_params[:target_o2_pct]
      target_co2 = @simulation_params[:target_co2_pct]
      target_ch4 = @simulation_params[:target_ch4_pct]

      # Check if we're at or above target pressure
      at_or_above_target = pressure >= target_pressure
      
      needs = {}
      # Only import gas if we're below target pressure AND composition needs adjustment
      unless at_or_above_target
        needs['N2'] = :high if mars_n2_pct < (target_n2 - 2.0)
        needs['O2'] = :high if mars_o2_pct < (target_o2 - 0.5)
        needs['CO2'] = :low if mars_co2_pct < target_co2
        needs['CH4'] = :medium if mars_ch4_pct < (target_ch4 - 0.1)
      end

      {
        priority: :composition_tuning,
        pressure_met: at_or_above_target,
        gases_needed: needs
      }
    end

    def calculate_h2_for_o2_management(world_key)
      world = @worlds[world_key]
      return 0.0 unless world&.atmosphere

      plan = manage_oxygen_levels(world_key)
      plan ? plan[:h2_needed] : 0.0
    end

    def calculate_h2_for_sabatier(world_key)
      plan = calculate_methane_needs(world_key)
      plan ? plan[:h2_needed] : 0.0
    end

    def calculate_excess_o2(o2_gas, o2_pct, safe_threshold)
      excess_o2_mass = o2_gas.mass * ((o2_pct - 21.0) / o2_pct)
      return 0.0 if excess_o2_mass.nan? || excess_o2_mass.infinite? || excess_o2_mass < 0
      
      [excess_o2_mass, o2_gas.mass].min
    end

    def get_gas_percentage(world, gas_name)
      gas = world.atmosphere.gases.find_by(name: gas_name)
      gas&.percentage.to_f || 0.0
    end

    def create_starter_organisms(biosphere)
      Biology::LifeForm.create!(
        biosphere: biosphere,
        name: "Extremophile Cyanobacteria",
        complexity: :simple,
        population: 1_000_000_000,
        diet: "photosynthetic",
        properties: {
          'oxygen_production_rate' => 0.00005,
          'co2_consumption_rate' => 0.00006,
          'nitrogen_fixation_rate' => 0.00001,
          'preferred_biome' => 'Regolith',
          'min_temperature' => 170.0,
          'max_temperature' => 320.0
        }
      )

      Biology::LifeForm.create!(
        biosphere: biosphere,
        name: "Cold-Adapted Green Algae",
        complexity: :simple,
        population: 500_000_000,
        diet: "photosynthetic",
        properties: {
          'oxygen_production_rate' => 0.00007,
          'co2_consumption_rate' => 0.00008,
          'preferred_biome' => 'Polar Cap',
          'min_temperature' => 180.0,
          'max_temperature' => 310.0
        }
      )

      Biology::LifeForm.create!(
        biosphere: biosphere,
        name: "Methanogenic Archaea",
        complexity: :simple,
        population: 800_000_000,
        diet: "chemosynthetic",
        properties: {
          'methane_production_rate' => 0.00003,
          'co2_consumption_rate' => 0.00002,
          'preferred_biome' => 'Subsurface',
          'min_temperature' => 160.0,
          'max_temperature' => 330.0
        }
      )
    end

    private

    def default_params
      {
        mars_liquid_water_threshold: 1.0
      }
    end

    def has_magnetosphere_protection?(world)
      world.magnetosphere_protection?
    end

    def atmospheric_reduction_exceeded?(world)
      current_mass = world.atmosphere.total_atmospheric_mass
      original_mass = world.atmosphere.base_values&.dig('total_atmospheric_mass') || current_mass

      reduction_pct = ((original_mass - current_mass) / original_mass) * 100
      reduction_pct >= 5.0
    end
  end
end