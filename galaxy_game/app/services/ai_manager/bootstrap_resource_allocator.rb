# app/services/ai_manager/bootstrap_resource_allocator.rb
module AIManager
  class BootstrapResourceAllocator
    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Calculate bootstrap resource requirements for new settlement
    def calculate_bootstrap_requirements(settlement_plan, target_system)
      Rails.logger.info "[BootstrapResourceAllocator] Calculating bootstrap requirements for #{target_system[:identifier]}"

      # Base requirements for minimal viable settlement
      base_requirements = calculate_base_requirements(settlement_plan)

      # ISRU potential adjustments
      isru_adjustments = calculate_isru_adjustments(target_system, settlement_plan)

      # Transport and logistics requirements
      logistics_requirements = calculate_logistics_requirements(settlement_plan, target_system)

      # Economic startup planning
      startup_budget = calculate_startup_budget(base_requirements, isru_adjustments, logistics_requirements)

      {
        base_requirements: base_requirements,
        isru_adjustments: isru_adjustments,
        logistics_requirements: logistics_requirements,
        startup_budget: startup_budget,
        timeline: estimate_bootstrap_timeline(settlement_plan, isru_adjustments),
        risk_factors: assess_bootstrap_risks(settlement_plan, target_system)
      }
    end

    # Allocate initial resources for settlement establishment
    def allocate_initial_resources(settlement, bootstrap_requirements)
      Rails.logger.info "[BootstrapResourceAllocator] Allocating initial resources for settlement #{settlement.id}"

      allocations = []

      # Allocate critical path resources first
      critical_resources = allocate_critical_resources(settlement, bootstrap_requirements)
      allocations.concat(critical_resources)

      # Allocate infrastructure resources
      infrastructure_resources = allocate_infrastructure_resources(settlement, bootstrap_requirements)
      allocations.concat(infrastructure_resources)

      # Allocate operational resources
      operational_resources = allocate_operational_resources(settlement, bootstrap_requirements)
      allocations.concat(operational_resources)

      allocations
    end

    private

    def calculate_base_requirements(settlement_plan)
      mission_type = settlement_plan[:mission_type] || 'general_settlement'

      base_requirements = {
        'structural_materials' => 1000,  # kg
        'life_support_supplies' => 500,  # kg
        'power_systems' => 200,          # kg
        'communication_equipment' => 50, # kg
        'scientific_instruments' => 100, # kg
        'personnel' => 6                 # people
      }

      # Adjust based on mission type
      case mission_type
      when 'mining_outpost'
        base_requirements.merge!(
          'mining_equipment' => 500,
          'processing_facilities' => 300,
          'personnel' => 12
        )
      when 'terraforming_base'
        base_requirements.merge!(
          'atmospheric_processors' => 400,
          'habitat_modules' => 800,
          'personnel' => 15
        )
      when 'research_station'
        base_requirements.merge!(
          'laboratory_equipment' => 200,
          'data_systems' => 100,
          'personnel' => 8
        )
      when 'orbital_harvesting'
        base_requirements.merge!(
          'orbital_collectors' => 300,
          'processing_facilities' => 200,
          'personnel' => 10
        )
      end

      base_requirements
    end

    def calculate_isru_adjustments(target_system, settlement_plan)
      adjustments = {
        reduced_imports: {},
        local_production_potential: {},
        timeline_acceleration: 0
      }

      # Analyze local resources that can reduce import requirements
      local_resources = analyze_local_resources(target_system)

      # Water ice reduces life support import needs
      if local_resources[:water_ice_available]
        water_savings = calculate_water_savings(settlement_plan)
        adjustments[:reduced_imports]['life_support_supplies'] = water_savings
        adjustments[:timeline_acceleration] += 30 # days
      end

      # Regolith processing reduces structural material imports
      if local_resources[:regolith_available]
        material_savings = calculate_material_savings(settlement_plan)
        adjustments[:reduced_imports]['structural_materials'] = material_savings
        adjustments[:timeline_acceleration] += 45 # days
      end

      # Atmospheric resources for gas production
      if local_resources[:atmosphere_available]
        gas_savings = calculate_gas_savings(settlement_plan)
        adjustments[:reduced_imports]['life_support_supplies'] = (adjustments[:reduced_imports]['life_support_supplies'] || 0) + gas_savings
        adjustments[:timeline_acceleration] += 20 # days
      end

      adjustments[:local_production_potential] = local_resources
      adjustments
    end

    def calculate_logistics_requirements(settlement_plan, target_system)
      requirements = {
        transport_capacity: 0,
        fuel_requirements: 0,
        mission_duration: 0,
        contingency_margin: 0.15 # 15% contingency
      }

      # Calculate transport needs based on total mass
      total_mass = calculate_total_mass(settlement_plan)
      requirements[:transport_capacity] = total_mass * (1 + requirements[:contingency_margin])

      # Fuel calculations based on distance and delta-v requirements
      distance = calculate_transport_distance(target_system)
      requirements[:fuel_requirements] = calculate_fuel_needs(total_mass, distance)

      # Mission duration estimates
      requirements[:mission_duration] = estimate_mission_duration(distance, settlement_plan)

      requirements
    end

    def calculate_startup_budget(base_requirements, isru_adjustments, logistics_requirements)
      budget = {
        capital_expenditure: 0,
        operational_expenditure: 0,
        total_budget: 0,
        funding_sources: [],
        payback_period: 0
      }

      # Capital costs for equipment and infrastructure
      budget[:capital_expenditure] = calculate_capital_costs(base_requirements)

      # Operational costs for first year
      budget[:operational_expenditure] = calculate_operational_costs(base_requirements, logistics_requirements)

      # Apply ISRU savings
      isru_savings = calculate_isru_savings(isru_adjustments)
      budget[:capital_expenditure] *= (1 - isru_savings[:capital_reduction])
      budget[:operational_expenditure] *= (1 - isru_savings[:operational_reduction])

      budget[:total_budget] = budget[:capital_expenditure] + budget[:operational_expenditure]

      # Estimate payback period
      budget[:payback_period] = estimate_payback_period(budget, isru_adjustments)

      budget
    end

    def estimate_bootstrap_timeline(settlement_plan, isru_adjustments)
      base_timeline = {
        planning_phase: 90,    # days
        procurement_phase: 60, # days
        transport_phase: 30,   # days
        establishment_phase: 45, # days
        operational_readiness: 30 # days
      }

      # Apply ISRU acceleration
      acceleration = isru_adjustments[:timeline_acceleration] || 0
      accelerated_timeline = base_timeline.transform_values { |days| [days - acceleration, days * 0.7].max }

      {
        base_timeline: base_timeline,
        accelerated_timeline: accelerated_timeline,
        total_duration: accelerated_timeline.values.sum,
        critical_path: identify_critical_path(accelerated_timeline)
      }
    end

    def assess_bootstrap_risks(settlement_plan, target_system)
      risks = {
        technical_risks: [],
        logistical_risks: [],
        environmental_risks: [],
        overall_risk_level: :medium,
        mitigation_strategies: []
      }

      # Technical risks
      if settlement_plan[:mission_type] == 'terraforming_base'
        risks[:technical_risks] << 'atmospheric_processing_complexity'
        risks[:mitigation_strategies] << 'redundant_processing_systems'
      end

      # Logistical risks based on distance
      distance = calculate_transport_distance(target_system)
      if distance > 2.0 # AU
        risks[:logistical_risks] << 'extended_communication_delay'
        risks[:mitigation_strategies] << 'autonomous_systems'
      end

      # Environmental risks
      if target_system.dig(:environmental_data, :radiation_levels) == 'high'
        risks[:environmental_risks] << 'radiation_exposure'
        risks[:mitigation_strategies] << 'shielded_habitats'
      end

      # Overall risk assessment
      risk_count = risks[:technical_risks].size + risks[:logistical_risks].size + risks[:environmental_risks].size
      risks[:overall_risk_level] = case risk_count
                                   when 0..1 then :low
                                   when 2..3 then :medium
                                   else :high
                                   end

      risks
    end

    # Helper methods
    def analyze_local_resources(target_system)
      resources = target_system[:resource_profile] || {}
      environmental = target_system[:environmental_data] || {}

      {
        water_ice_available: (resources[:water_ice] || 0) > 100,
        regolith_available: (resources[:regolith] || 0) > 500,
        atmosphere_available: environmental[:atmosphere_composition].present?,
        mineral_deposits: resources[:minerals] || [],
        energy_potential: resources[:energy_potential] || {}
      }
    end

    def calculate_water_savings(settlement_plan)
      base_water_need = 200 # kg for 6 months
      isru_efficiency = 0.8
      base_water_need * isru_efficiency
    end

    def calculate_material_savings(settlement_plan)
      base_material_need = 500 # kg
      isru_efficiency = 0.6
      base_material_need * isru_efficiency
    end

    def calculate_gas_savings(settlement_plan)
      base_gas_need = 100 # kg
      isru_efficiency = 0.7
      base_gas_need * isru_efficiency
    end

    def calculate_total_mass(settlement_plan)
      # Simplified mass calculation
      2000 # kg - would be calculated from actual requirements
    end

    def calculate_transport_distance(target_system)
      # Simplified distance calculation
      1.5 # AU - would use actual astronomical calculations
    end

    def calculate_fuel_needs(mass, distance)
      # Simplified fuel calculation
      mass * distance * 0.1 # kg
    end

    def estimate_mission_duration(distance, settlement_plan)
      base_duration = 180 # days
      distance_penalty = distance * 30 # days per AU
      base_duration + distance_penalty
    end

    def calculate_capital_costs(requirements)
      # Cost per kg estimates
      cost_per_kg = {
        'structural_materials' => 100,  # GCC per kg
        'life_support_supplies' => 500,
        'power_systems' => 1000,
        'mining_equipment' => 800,
        'atmospheric_processors' => 2000
      }

      total_cost = 0
      requirements.each do |resource, quantity|
        cost_per_unit = cost_per_kg[resource] || 200
        total_cost += quantity * cost_per_unit
      end

      total_cost
    end

    def calculate_operational_costs(requirements, logistics)
      # Annual operational costs
      personnel_cost = (requirements['personnel'] || 6) * 50000 # GCC per person per year
      logistics_cost = logistics[:fuel_requirements] * 50 # GCC per kg fuel
      maintenance_cost = calculate_capital_costs(requirements) * 0.1 # 10% annual maintenance

      personnel_cost + logistics_cost + maintenance_cost
    end

    def calculate_isru_savings(isru_adjustments)
      reduced_imports = isru_adjustments[:reduced_imports] || {}
      total_reduction = reduced_imports.values.sum
      total_base_imports = 2000 # kg - baseline

      reduction_percentage = total_reduction.to_f / total_base_imports

      {
        capital_reduction: [reduction_percentage * 0.4, 0.3].min, # Max 30% reduction
        operational_reduction: [reduction_percentage * 0.6, 0.4].min # Max 40% reduction
      }
    end

    def estimate_payback_period(budget, isru_adjustments)
      annual_revenue = calculate_projected_revenue(isru_adjustments)
      annual_costs = budget[:operational_expenditure]

      return 99 if annual_revenue <= annual_costs # No payback

      capital_investment = budget[:capital_expenditure]
      net_annual_benefit = annual_revenue - annual_costs

      (capital_investment / net_annual_benefit).ceil
    end

    def calculate_projected_revenue(isru_adjustments)
      base_revenue = 200000 # GCC per year
      isru_bonus = isru_adjustments[:timeline_acceleration] * 1000 # Revenue bonus per day saved
      base_revenue + isru_bonus
    end

    def identify_critical_path(timeline)
      # Find the longest path through the phases
      [:planning_phase, :procurement_phase, :transport_phase, :establishment_phase, :operational_readiness]
    end

    def allocate_critical_resources(settlement, requirements)
      # Allocate life support and power systems first
      [
        {
          settlement: settlement,
          resource: 'life_support_supplies',
          quantity: requirements.dig(:base_requirements, 'life_support_supplies') || 0,
          priority: :critical,
          allocation_type: :bootstrap
        },
        {
          settlement: settlement,
          resource: 'power_systems',
          quantity: requirements.dig(:base_requirements, 'power_systems') || 0,
          priority: :critical,
          allocation_type: :bootstrap
        }
      ]
    end

    def allocate_infrastructure_resources(settlement, requirements)
      [
        {
          settlement: settlement,
          resource: 'structural_materials',
          quantity: requirements.dig(:base_requirements, 'structural_materials') || 0,
          priority: :high,
          allocation_type: :bootstrap
        },
        {
          settlement: settlement,
          resource: 'habitat_modules',
          quantity: requirements.dig(:base_requirements, 'habitat_modules') || 0,
          priority: :high,
          allocation_type: :bootstrap
        }
      ]
    end

    def allocate_operational_resources(settlement, requirements)
      [
        {
          settlement: settlement,
          resource: 'scientific_instruments',
          quantity: requirements.dig(:base_requirements, 'scientific_instruments') || 0,
          priority: :medium,
          allocation_type: :bootstrap
        },
        {
          settlement: settlement,
          resource: 'communication_equipment',
          quantity: requirements.dig(:base_requirements, 'communication_equipment') || 0,
          priority: :medium,
          allocation_type: :bootstrap
        }
      ]
    end
  end
end