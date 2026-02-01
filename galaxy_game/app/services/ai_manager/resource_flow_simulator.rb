# app/services/ai_manager/resource_flow_simulator.rb
#
# Resource Flow Simulator - Models resource dependencies and production timelines
# Optimizes Luna base development sequencing based on resource availability

class AIManager::ResourceFlowSimulator
  # Resource dependency chains for Luna base development
  RESOURCE_CHAINS = {
    # Bootstrap sequence dependencies
    'gcc_satellite' => {
      inputs: { 'aluminum' => 50, 'solar_panels' => 10, 'communication_equipment' => 5 },
      outputs: { 'gcc_satellite' => 1 },
      build_time_days: 7,
      power_requirement_kw: 5.0
    },
    'titan_harvester' => {
      inputs: { 'titanium' => 200, 'solar_panels' => 20, 'drilling_equipment' => 5 },
      outputs: { 'titan_harvester' => 1 },
      build_time_days: 14,
      power_requirement_kw: 15.0,
      requires: ['gcc_satellite'] # Must have comms for remote operation
    },
    'venus_harvester' => {
      inputs: { 'heat_shield_tiles' => 100, 'co2_scrubbers' => 10, 'atmospheric_processors' => 5 },
      outputs: { 'venus_harvester' => 1 },
      build_time_days: 21,
      power_requirement_kw: 25.0,
      requires: ['gcc_satellite', 'titan_harvester'] # Needs comms and some resources
    },
    'lava_tube_base' => {
      inputs: {
        'processed_regolith' => 1000,
        'structural_beams' => 50,
        'life_support_modules' => 10,
        'power_reactors' => 5
      },
      outputs: { 'lava_tube_base' => 1 },
      build_time_days: 30,
      power_requirement_kw: 50.0,
      requires: ['venus_harvester'] # Needs Venus resources for construction
    },

    # ISRU production chains
    'teu_unit' => {
      inputs: { 'titanium' => 100, 'electronics' => 20, 'solar_panels' => 5 },
      outputs: { 'teu_unit' => 1 },
      build_time_days: 10,
      power_requirement_kw: 15.0
    },
    'pve_unit' => {
      inputs: { 'aluminum' => 200, 'heat_exchangers' => 10, 'vacuum_pumps' => 5 },
      outputs: { 'pve_unit' => 1 },
      build_time_days: 12,
      power_requirement_kw: 25.0
    },
    'co2_splitter' => {
      inputs: { 'titanium' => 150, 'catalysts' => 20, 'heat_shield_tiles' => 30 },
      outputs: { 'co2_splitter' => 1 },
      build_time_days: 18,
      power_requirement_kw: 30.0
    },
    'sabatier_reactor' => {
      inputs: { 'nickel' => 100, 'catalysts' => 15, 'heat_exchangers' => 8 },
      outputs: { 'sabatier_reactor' => 1 },
      build_time_days: 15,
      power_requirement_kw: 20.0
    },

    # Resource production from ISRU
    'processed_regolith_production' => {
      inputs: { 'raw_regolith' => 10 },
      outputs: { 'processed_regolith' => 9.95 },
      build_time_days: 0, # Continuous production
      power_requirement_kw: 15.0,
      requires: ['teu_unit']
    },
    'water_production' => {
      inputs: { 'processed_regolith' => 5 },
      outputs: { 'water' => 0.1, 'gases' => 0.05, 'inert_waste' => 4.85 },
      build_time_days: 0, # Continuous production
      power_requirement_kw: 25.0,
      requires: ['pve_unit']
    },
    'oxygen_production' => {
      inputs: { 'venus_atmosphere' => 50 },
      outputs: { 'liquid_oxygen' => 11.5, 'carbon_monoxide' => 21.0 },
      build_time_days: 0, # Continuous production
      power_requirement_kw: 30.0,
      requires: ['co2_splitter']
    },
    'methane_production' => {
      inputs: { 'carbon_dioxide' => 1, 'hydrogen' => 4 },
      outputs: { 'methane' => 0.67, 'water' => 1.43 },
      build_time_days: 0, # Continuous production
      power_requirement_kw: 20.0,
      requires: ['sabatier_reactor']
    }
  }.freeze

  # Mission profiles for resource acquisition
  MISSION_PROFILES = {
    'titan_harvester' => {
      duration_days: 90,
      resources_per_mission: { 'titanium' => 500, 'nitrogen' => 100, 'methane' => 50 },
      fuel_required: 200, # kg methane
      crew_required: 2,
      risk_level: 'medium'
    },
    'venus_harvester' => {
      duration_days: 60,
      resources_per_mission: { 'carbon_dioxide' => 2000, 'sulfur' => 100, 'heat_shield_tiles' => 20 },
      fuel_required: 300, # kg methane
      crew_required: 3,
      risk_level: 'high'
    }
  }.freeze

  def initialize(settlement)
    @settlement = settlement
    @current_inventory = build_current_inventory
    @active_missions = settlement.missions.where(status: ['active', 'en_route'])
    @production_units = settlement.units.where(unit_type: RESOURCE_CHAINS.keys)
  end

  # Simulate resource flow for a development plan
  def simulate_plan(plan_phases, simulation_days = 365)
    timeline = []
    inventory = @current_inventory.dup
    active_productions = []
    active_missions = []

    plan_phases.each do |phase|
      phase_start_day = phase[:start_day] || 0

      # Start new productions for this phase
      phase[:productions].each do |production|
        start_production(production, phase_start_day, active_productions)
      end

      # Start new missions for this phase
      phase[:missions].each do |mission|
        start_mission(mission, phase_start_day, active_missions)
      end
    end

    # Simulate day by day
    (0..simulation_days).each do |day|
      daily_events = {
        day: day,
        productions_completed: [],
        missions_completed: [],
        inventory_changes: {},
        bottlenecks: []
      }

      # Process active productions
      active_productions.each do |production|
        if production[:completion_day] == day
          complete_production(production, inventory, daily_events)
        end
      end

      # Process active missions
      active_missions.each do |mission|
        if mission[:completion_day] == day
          complete_mission(mission, inventory, daily_events)
        end
      end

      # Check for bottlenecks
      daily_events[:bottlenecks] = identify_bottlenecks(inventory, active_productions, active_missions)

      timeline << daily_events unless daily_events[:productions_completed].empty? && daily_events[:missions_completed].empty?
    end

    {
      timeline: timeline,
      final_inventory: inventory,
      bottlenecks_identified: timeline.flat_map { |t| t[:bottlenecks] }.uniq,
      completion_time_days: calculate_completion_time(plan_phases, timeline)
    }
  end

  # Optimize resource flow by adjusting timing and priorities
  def optimize_flow(plan_phases)
    optimized_phases = plan_phases.dup

    # Identify critical path dependencies
    critical_path = identify_critical_path(optimized_phases)

    # Adjust timing to minimize bottlenecks
    optimized_phases = adjust_timing_for_dependencies(optimized_phases, critical_path)

    # Balance resource production vs consumption
    optimized_phases = balance_resource_flow(optimized_phases)

    # Optimize mission scheduling
    optimized_phases = optimize_mission_scheduling(optimized_phases)

    optimized_phases
  end

  # Calculate resource availability timeline
  def calculate_resource_availability(resource_type, days_ahead = 90)
    availability = []

    (0..days_ahead).each do |day|
      available = @current_inventory[resource_type] || 0

      # Add expected production
      @production_units.each do |unit|
        chain = RESOURCE_CHAINS[unit.unit_type]
        next unless chain && chain[:outputs].key?(resource_type)

        # Simple linear production estimate
        daily_production = chain[:outputs][resource_type] * 24.0 # Assume continuous operation
        available += daily_production * day
      end

      # Add expected mission returns
      @active_missions.each do |mission|
        profile = MISSION_PROFILES[mission.mission_type]
        next unless profile && profile[:resources_per_mission].key?(resource_type)

        if mission.estimated_completion > day.days.from_now
          available += profile[:resources_per_mission][resource_type]
        end
      end

      availability << { day: day, available: available }
    end

    availability
  end

  # Identify resource bottlenecks in a plan
  def identify_bottlenecks(plan_inventory, active_productions, active_missions)
    bottlenecks = []

    # Check for resource shortages
    RESOURCE_CHAINS.each do |chain_name, chain|
      next unless chain[:inputs]

      chain[:inputs].each do |resource, required_amount|
        available = plan_inventory[resource] || 0
        if available < required_amount * 0.1 # Less than 10% of required
          bottlenecks << "Critical shortage of #{resource} for #{chain_name}"
        elsif available < required_amount * 0.5 # Less than 50% of required
          bottlenecks << "Low availability of #{resource} for #{chain_name}"
        end
      end
    end

    # Check for power constraints
    total_power_required = active_productions.sum do |prod|
      RESOURCE_CHAINS[prod[:type]][:power_requirement_kw]
    end

    available_power = calculate_available_power
    if total_power_required > available_power * 1.2 # 20% buffer
      bottlenecks << "Power constraint: #{total_power_required}kW required, #{available_power}kW available"
    end

    # Check for mission capacity limits
    active_mission_count = active_missions.size
    if active_mission_count > 3 # Assume max 3 concurrent missions
      bottlenecks << "Mission capacity exceeded: #{active_mission_count} active missions"
    end

    bottlenecks.uniq
  end

  private

  # Build current inventory snapshot
  def build_current_inventory
    inventory = Hash.new(0)

    # Add settlement inventory
    @settlement.inventory.items.each do |item|
      inventory[item.name] = item.amount.to_f
    end

    # Add surface storage
    @settlement.inventory.surface_storage&.material_piles&.each do |pile|
      inventory[pile.material_type] = pile.amount.to_f
    end

    inventory
  end

  # Start a production process
  def start_production(production, start_day, active_productions)
    chain = RESOURCE_CHAINS[production[:type]]
    return unless chain

    active_productions << {
      type: production[:type],
      start_day: start_day,
      completion_day: start_day + chain[:build_time_days],
      inputs: chain[:inputs] || {},
      outputs: chain[:outputs] || {},
      quantity: production[:quantity] || 1
    }
  end

  # Start a mission
  def start_mission(mission, start_day, active_missions)
    profile = MISSION_PROFILES[mission[:type]]
    return unless profile

    active_missions << {
      type: mission[:type],
      start_day: start_day,
      completion_day: start_day + profile[:duration_days],
      resources: profile[:resources_per_mission],
      fuel_required: profile[:fuel_required],
      crew_required: profile[:crew_required]
    }
  end

  # Complete a production process
  def complete_production(production, inventory, daily_events)
    # Check if inputs are available
    inputs_available = production[:inputs].all? do |resource, amount|
      (inventory[resource] || 0) >= amount * production[:quantity]
    end

    if inputs_available
      # Consume inputs
      production[:inputs].each do |resource, amount|
        inventory[resource] = (inventory[resource] || 0) - amount * production[:quantity]
      end

      # Produce outputs
      production[:outputs].each do |resource, amount|
        inventory[resource] = (inventory[resource] || 0) + amount * production[:quantity]
      end

      daily_events[:productions_completed] << production[:type]
      daily_events[:inventory_changes][production[:type]] = production[:outputs]
    else
      daily_events[:bottlenecks] << "Cannot complete #{production[:type]} - insufficient inputs"
    end
  end

  # Complete a mission
  def complete_mission(mission, inventory, daily_events)
    # Check fuel availability
    fuel_available = (inventory['methane'] || 0) >= mission[:fuel_required]

    if fuel_available
      # Consume fuel
      inventory['methane'] = (inventory['methane'] || 0) - mission[:fuel_required]

      # Add mission resources
      mission[:resources].each do |resource, amount|
        inventory[resource] = (inventory[resource] || 0) + amount
      end

      daily_events[:missions_completed] << mission[:type]
      daily_events[:inventory_changes][mission[:type]] = mission[:resources]
    else
      daily_events[:bottlenecks] << "Cannot complete #{mission[:type]} mission - insufficient fuel"
    end
  end

  # Identify critical path dependencies
  def identify_critical_path(phases)
    critical_items = []

    phases.each do |phase|
      phase[:productions].each do |production|
        chain = RESOURCE_CHAINS[production[:type]]
        next unless chain

        critical_items << production[:type] if chain[:requires]
      end
    end

    critical_items.uniq
  end

  # Adjust timing based on dependencies
  def adjust_timing_for_dependencies(phases, critical_path)
    adjusted_phases = phases.dup

    # Ensure prerequisites are completed before dependents
    adjusted_phases.each_with_index do |phase, index|
      phase[:productions].each do |production|
        chain = RESOURCE_CHAINS[production[:type]]
        next unless chain && chain[:requires]

        # Find prerequisite phases
        chain[:requires].each do |prereq|
          prereq_phase_index = find_phase_with_production(adjusted_phases, prereq)
          next unless prereq_phase_index

          # Ensure this phase starts after prereq completion
          prereq_completion = adjusted_phases[prereq_phase_index][:start_day] +
                             RESOURCE_CHAINS[prereq][:build_time_days]

          if phase[:start_day] < prereq_completion
            phase[:start_day] = prereq_completion
          end
        end
      end
    end

    adjusted_phases
  end

  # Balance resource production and consumption
  def balance_resource_flow(phases)
    balanced_phases = phases.dup

    # Analyze resource flow
    resource_flow = analyze_resource_flow(balanced_phases)

    # Adjust production quantities to prevent shortages
    resource_flow.each do |resource, flow|
      if flow[:shortage_days] > 0
        # Increase production of this resource
        increase_production_for_resource(balanced_phases, resource, flow[:shortage_amount])
      end
    end

    balanced_phases
  end

  # Optimize mission scheduling to minimize downtime
  def optimize_mission_scheduling(phases)
    optimized_phases = phases.dup

    # Group missions by type
    titan_missions = []
    venus_missions = []

    optimized_phases.each do |phase|
      phase[:missions].each do |mission|
        case mission[:type]
        when 'titan_harvester'
          titan_missions << mission
        when 'venus_harvester'
          venus_missions << mission
        end
      end
    end

    # Stagger missions to maintain continuous resource flow
    stagger_missions(titan_missions, 30) # 30 day intervals
    stagger_missions(venus_missions, 45) # 45 day intervals

    optimized_phases
  end

  # Helper methods
  def find_phase_with_production(phases, production_type)
    phases.find_index do |phase|
      phase[:productions].any? { |p| p[:type] == production_type }
    end
  end

  def calculate_completion_time(phases, timeline)
    last_completion = 0

    phases.each do |phase|
      phase_completion = phase[:start_day]
      phase[:productions].each do |prod|
        chain = RESOURCE_CHAINS[prod[:type]]
        next unless chain
        completion = phase[:start_day] + chain[:build_time_days]
        phase_completion = [phase_completion, completion].max
      end

      last_completion = [last_completion, phase_completion].max
    end

    last_completion
  end

  def calculate_available_power
    power_units = @settlement.units.where(unit_type: ['SOLAR_ARRAY_MK1', 'NUCLEAR_REACTOR_MK1', 'RTG_MK1'])

    power_units.sum do |unit|
      case unit.unit_type
      when 'SOLAR_ARRAY_MK1'
        10.0 # kW - lunar average
      when 'NUCLEAR_REACTOR_MK1'
        100.0 # kW
      when 'RTG_MK1'
        0.125 # kW
      else
        0.0
      end
    end
  end

  def analyze_resource_flow(phases)
    flow_analysis = {}

    # This would be a complex analysis of resource consumption vs production
    # For now, return a simple structure
    RESOURCE_CHAINS.values.flat_map { |c| c[:inputs]&.keys || [] }.uniq.each do |resource|
      flow_analysis[resource] = {
        shortage_days: 0,
        shortage_amount: 0,
        overproduction: 0
      }
    end

    flow_analysis
  end

  def increase_production_for_resource(phases, resource, shortage_amount)
    # Find production chains that produce this resource
    producer_chains = RESOURCE_CHAINS.select do |name, chain|
      chain[:outputs]&.key?(resource)
    end

    return if producer_chains.empty?

    # Add production to earliest phase
    earliest_phase = phases.min_by { |p| p[:start_day] }
    producer_chains.each_key do |chain_name|
      earliest_phase[:productions] << {
        type: chain_name,
        quantity: 1
      }
    end
  end

  def stagger_missions(missions, interval_days)
    missions.each_with_index do |mission, index|
      mission[:start_day] = index * interval_days
    end
  end
end