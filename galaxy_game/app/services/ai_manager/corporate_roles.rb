# app/services/ai_manager/corporate_roles.rb
#
# Corporate Roles Module - Defines corporate responsibilities and coordination
# for AI Manager operations

module AIManager::CorporateRoles
  # Corporate assignments for different mission types
  CORPORATE_ASSIGNMENTS = {
    # Orbital and communication infrastructure
    gcc_satellite: :zenith_orbital,
    orbital_construction: :zenith_orbital,
    communication_network: :zenith_orbital,

    # Resource harvesting and ISRU
    titan_harvesters: :astrolift,
    venus_harvesters: :astrolift,
    asteroid_mining: :astrolift,
    isru_development: :astrolift,

    # Base construction and settlement
    lava_tube_base: :ldc,
    habitat_construction: :ldc,
    life_support_systems: :ldc,
    settlement_expansion: :ldc,

    # Transportation and logistics
    cargo_transport: :interstellar_shipping,
    fuel_logistics: :interstellar_shipping,
    supply_chain: :interstellar_shipping,

    # Research and development
    precursor_research: :precursor_industries,
    advanced_materials: :precursor_industries,
    technology_development: :precursor_industries
  }.freeze

  # Corporate capabilities and specializations
  CORPORATE_CAPABILITIES = {
    zenith_orbital: {
      specialties: [:orbital, :communication, :satellite],
      risk_tolerance: :medium,
      cost_efficiency: 0.9,
      schedule_reliability: 0.95
    },
    astrolift: {
      specialties: [:harvesting, :isru, :mining, :fuel_production],
      risk_tolerance: :high,
      cost_efficiency: 0.85,
      schedule_reliability: 0.85
    },
    ldc: {
      specialties: [:construction, :habitat, :life_support, :settlement],
      risk_tolerance: :low,
      cost_efficiency: 0.95,
      schedule_reliability: 0.90
    },
    interstellar_shipping: {
      specialties: [:transport, :logistics, :supply_chain],
      risk_tolerance: :medium,
      cost_efficiency: 0.8,
      schedule_reliability: 0.80
    },
    precursor_industries: {
      specialties: [:research, :advanced_materials, :technology],
      risk_tolerance: :high,
      cost_efficiency: 0.75,
      schedule_reliability: 0.70
    }
  }.freeze

  # Get the assigned corporation for a mission type
  def self.corporation_for_mission(mission_type)
    CORPORATE_ASSIGNMENTS[mission_type.to_sym]
  end

  # Get corporate capabilities for a given corporation
  def self.capabilities_for_corporation(corporation)
    CORPORATE_CAPABILITIES[corporation.to_sym] || {}
  end

  # Check if a corporation specializes in a particular mission type
  def self.corporation_specializes_in?(corporation, mission_type)
    capabilities = capabilities_for_corporation(corporation)
    specialties = capabilities[:specialties] || []
    specialties.include?(mission_type.to_sym)
  end

  # Calculate coordination efficiency between corporations
  def self.coordination_efficiency(corporation_a, corporation_b)
    return 1.0 if corporation_a == corporation_b

    # Corporations with complementary specialties coordinate better
    cap_a = capabilities_for_corporation(corporation_a)
    cap_b = capabilities_for_corporation(corporation_b)

    specialties_a = cap_a[:specialties] || []
    specialties_b = cap_b[:specialties] || []

    # Check for complementary relationships
    complementary_pairs = [
      [:orbital, :harvesting],
      [:harvesting, :construction],
      [:construction, :transport],
      [:transport, :research]
    ]

    complementary = complementary_pairs.any? do |pair|
      (specialties_a.include?(pair[0]) && specialties_b.include?(pair[1])) ||
      (specialties_a.include?(pair[1]) && specialties_b.include?(pair[0]))
    end

    complementary ? 0.9 : 0.7
  end

  # Get optimal corporation assignment for a mission type
  def self.optimal_corporation_for(mission_type, available_corporations = [])
    assigned = corporation_for_mission(mission_type)

    # If assigned corporation is available, use it
    return assigned if available_corporations.empty? || available_corporations.include?(assigned)

    # Otherwise, find best alternative based on specialization
    available_corporations.max_by do |corp|
      corporation_specializes_in?(corp, mission_type) ? 1 : 0
    end
  end

  # Calculate mission risk adjusted for corporate capabilities
  def self.adjust_risk_for_corporation(base_risk, corporation, mission_type)
    capabilities = capabilities_for_corporation(corporation)
    specializes = corporation_specializes_in?(corporation, mission_type)

    risk_multiplier = if specializes
                       0.8  # 20% risk reduction for specialists
                     else
                       1.2  # 20% risk increase for non-specialists
                     end

    risk_tolerance = capabilities[:risk_tolerance] || :medium
    tolerance_multiplier = case risk_tolerance
                          when :low then 0.9
                          when :high then 1.1
                          else 1.0
                          end

    base_risk * risk_multiplier * tolerance_multiplier
  end

  # Get corporate coordination requirements for multi-corporate operations
  def self.coordination_requirements(mission_phases)
    corporations_involved = mission_phases.map { |phase| corporation_for_mission(phase[:type]) }.uniq

    if corporations_involved.size <= 1
      { complexity: :single_corp, coordination_cost: 0, schedule_impact: 0 }
    elsif corporations_involved.size == 2
      efficiency = coordination_efficiency(corporations_involved[0], corporations_involved[1])
      { complexity: :dual_corp, coordination_cost: 0.1, schedule_impact: 0.05, efficiency: efficiency }
    else
      { complexity: :multi_corp, coordination_cost: 0.2, schedule_impact: 0.1, efficiency: 0.8 }
    end
  end
end