# app/services/ai_manager/luna_development_planner.rb
#
# Luna Development Planner - Teaches AI Manager the Luna base bootstrap sequence
# Priority: GCC Sat → Titan Harvesters → Venus Harvesters → Lava Tube Base
# Maximizes ISRU before imports, manages corporate coordination

class AIManager::LunaDevelopmentPlanner
  include AIManager::CorporateRoles

  # Luna bootstrap phases in priority order
  BOOTSTRAP_PHASES = [
    { phase: :gcc_satellite, priority: 1, dependencies: [], corporation: :zenith_orbital },
    { phase: :titan_harvesters, priority: 2, dependencies: [:gcc_satellite], corporation: :astrolift },
    { phase: :venus_harvesters, priority: 3, dependencies: [:titan_harvesters], corporation: :astrolift },
    { phase: :lava_tube_base, priority: 4, dependencies: [:venus_harvesters], corporation: :ldc }
  ].freeze

  # Resource requirements for each phase (kg)
  RESOURCE_REQUIREMENTS = {
    gcc_satellite: { usd: 50000, time_days: 30 },
    titan_harvesters: { usd: 200000, gcc: 10000, time_days: 270 }, # 9 months
    venus_harvesters: { usd: 150000, ch4: 60000, time_days: 120 }, # 4 months
    lava_tube_base: { usd: 500000, lox: 100000, ch4: 50000, time_days: 365 }
  }.freeze

  def initialize(settlement)
    @settlement = settlement
    @isru_evaluator = AIManager::ISRUEvaluator.new(settlement)
    @resource_simulator = AIManager::ResourceFlowSimulator.new
  end

  # Main planning method - returns prioritized action plan
  def generate_bootstrap_plan
    current_state = assess_current_state
    available_resources = assess_available_resources
    isru_capabilities = @isru_evaluator.assess_capabilities

    plan = {
      current_phase: determine_current_phase(current_state),
      immediate_actions: [],
      fleet_requirements: calculate_fleet_requirements,
      resource_priorities: prioritize_resource_sources(isru_capabilities),
      timeline: simulate_timeline,
      corporate_assignments: assign_corporate_roles,
      risk_factors: identify_risks
    }

    validate_plan(plan)
    plan
  end

  private

  # Assess current Luna development state
  def assess_current_state
    {
      gcc_generation: check_gcc_generation_rate,
      harvester_fleet: count_operational_harvesters,
      isru_capacity: @isru_evaluator.assess_capabilities,
      base_infrastructure: assess_base_readiness,
      corporate_setup: check_corporate_readiness
    }
  end

  # Determine which bootstrap phase we're currently in
  def determine_current_phase(state)
    return :gcc_satellite if state[:gcc_generation] <= 0
    return :titan_harvesters if state[:harvester_fleet][:titan] < 2
    return :venus_harvesters if state[:harvester_fleet][:venus] < 1
    return :lava_tube_base if state[:base_infrastructure][:lava_tube] == :not_started
    :expansion
  end

  # Calculate optimal harvester fleet composition
  def calculate_fleet_requirements
    base_demand = RESOURCE_REQUIREMENTS[:lava_tube_base]

    # Titan harvesters: Provide methane for Venus operations + base needs
    titan_methane_yearly = 3 * 10000 * 1.2  # 3 harvesters, 10k kg each, 20% reserve
    venus_methane_needed = 2 * 60000  # 2 Venus harvesters
    total_methane_needed = base_demand[:ch4] + venus_methane_needed

    titan_count = [(total_methane_needed / 10000.0).ceil, 2].max

    # Venus harvesters: Provide oxygen, scaled to methane availability
    venus_count = [(titan_count * 0.67).ceil, 1].max  # 2:3 Venus:Titan ratio

    {
      titan: titan_count,
      venus: venus_count,
      reasoning: "Titan:Venus ratio #{titan_count}:#{venus_count} for resource balance"
    }
  end

  # Prioritize ISRU over imports for each resource type
  def prioritize_resource_sources(isru_capabilities)
    {
      liquid_oxygen: prioritize_lox_sources(isru_capabilities),
      methane: prioritize_ch4_sources(isru_capabilities),
      electricity: [:isru_solar, :isru_nuclear, :import],
      structural_materials: [:isru_regolith, :asteroid_mining, :import]
    }
  end

  # LOX: Regolith ISRU > Venus processing > Earth import
  def prioritize_lox_sources(isru_capabilities)
    sources = [:isru_regolith]
    sources << :venus_processing if isru_capabilities[:venus_compatible]
    sources << :earth_import
    sources
  end

  # CH4: Local CO2+ice > Titan import > Earth import
  def prioritize_ch4_sources(isru_capabilities)
    sources = []
    sources << :isru_co2_ice if isru_capabilities[:co2_ice_available]
    sources << :titan_import
    sources << :earth_import
    sources
  end

  # Simulate development timeline with dependencies
  def simulate_timeline
    timeline = {}
    current_date = Date.today

    BOOTSTRAP_PHASES.each do |phase_config|
      phase_start = current_date
      dependencies_satisfied = dependencies_met?(phase_config[:dependencies], timeline)

      unless dependencies_satisfied
        # Delay until dependencies complete
        latest_dependency_end = phase_config[:dependencies].map { |dep|
          timeline[dep]&.dig(:end_date)
        }.compact.max
        phase_start = latest_dependency_end if latest_dependency_end
      end

      phase_end = phase_start + RESOURCE_REQUIREMENTS[phase_config[:phase]][:time_days].days

      timeline[phase_config[:phase]] = {
        start_date: phase_start,
        end_date: phase_end,
        duration_days: RESOURCE_REQUIREMENTS[phase_config[:phase]][:time_days],
        dependencies_satisfied: dependencies_satisfied
      }

      current_date = phase_end
    end

    timeline
  end

  # Check if phase dependencies are satisfied
  def dependencies_met?(dependencies, timeline)
    dependencies.all? { |dep| timeline[dep]&.dig(:end_date)&.past? }
  end

  # Assign corporate roles for each phase
  def assign_corporate_roles
    BOOTSTRAP_PHASES.each_with_object({}) do |phase_config, assignments|
      corporation = phase_config[:corporation]
      assignments[phase_config[:phase]] = {
        primary_corporation: corporation,
        supporting_corporations: supporting_corps_for_phase(phase_config[:phase]),
        responsibilities: corporate_responsibilities(phase_config[:phase])
      }
    end
  end

  # Identify potential risks and mitigation strategies
  def identify_risks
    risks = []

    # Resource dependency risks
    if calculate_fleet_requirements[:titan] > 3
      risks << {
        type: :resource_dependency,
        severity: :high,
        description: "High Titan harvester requirement creates methane supply risk",
        mitigation: "Implement local CH4 generation from CO2 + ice"
      }
    end

    # Timeline risks
    timeline = simulate_timeline
    total_duration = timeline.values.last[:end_date] - timeline.values.first[:start_date]
    if total_duration > 400.days
      risks << {
        type: :timeline_risk,
        severity: :medium,
        description: "Extended timeline increases cost and complexity",
        mitigation: "Parallelize harvester construction and launch operations"
      }
    end

    # ISRU readiness risks
    isru_status = @isru_evaluator.assess_capabilities
    if isru_status[:overall_readiness] < 0.7
      risks << {
        type: :isru_readiness,
        severity: :high,
        description: "Insufficient ISRU capacity will force expensive imports",
        mitigation: "Prioritize ISRU infrastructure in early construction phases"
      }
    end

    risks
  end

  # Validate plan completeness and feasibility
  def validate_plan(plan)
    errors = []

    # Check resource availability
    plan[:resource_priorities].each do |resource, sources|
      next if sources.include?(:isru_regolith) || sources.include?(:isru_co2_ice)
      errors << "No ISRU source available for #{resource}"
    end

    # Check timeline dependencies
    plan[:timeline].each do |phase, timing|
      unless timing[:dependencies_satisfied]
        errors << "Dependencies not satisfied for #{phase}"
      end
    end

    # Check corporate assignments
    plan[:corporate_assignments].each do |phase, assignment|
      if assignment[:primary_corporation].nil?
        errors << "No corporation assigned for #{phase}"
      end
    end

    raise "Plan validation failed: #{errors.join(', ')}" unless errors.empty?

    plan[:validation_status] = :passed
    plan
  end

  # Helper methods for state assessment
  def check_gcc_generation_rate
    # Check current GCC satellite deployment status
    gcc_satellites = @settlement.celestial_body.satellites.where(satellite_type: :gcc_mining)
    operational = gcc_satellites.select { |sat| sat.operational_data&.dig('status') == 'active' }
    operational.sum { |sat| sat.operational_data&.dig('generation_rate')&.to_f || 0 }
  end

  def count_operational_harvesters
    harvesters = @settlement.celestial_body.celestial_locations.flat_map(&:docked_craft)
    titan = harvesters.count { |craft| craft.craft_type == 'harvester' && craft.name.include?('Titan') }
    venus = harvesters.count { |craft| craft.craft_type == 'harvester' && craft.name.include?('Venus') }
    { titan: titan, venus: venus }
  end

  def assess_available_resources
    inventory = @settlement.inventory
    {
      usd: inventory.items.find_by(name: 'usd')&.amount&.to_f || 0,
      gcc: inventory.items.find_by(name: 'gcc')&.amount&.to_f || 0,
      lox: inventory.items.find_by(name: 'liquid_oxygen')&.amount&.to_f || 0,
      ch4: inventory.items.find_by(name: 'methane')&.amount&.to_f || 0
    }
  end

  def assess_base_readiness
    features = @settlement.celestial_body.celestial_body_features
    {
      lava_tube: features.where(feature_type: 'lava_tube').exists? ? :exists : :not_started,
      skylight: features.where(feature_type: 'skylight').exists? ? :covered : :not_started,
      power_grid: :operational, # Assume basic power available
      life_support: :operational # Assume basic life support
    }
  end

  def check_corporate_readiness
    corporations = Organizations::BaseOrganization.where(identifier: %w[LDC ASTROLIFT ZENITH VECTOR])
    corporations.each_with_object({}) do |corp, status|
      status[corp.identifier.downcase.to_sym] = corp.persisted?
    end
  end
end