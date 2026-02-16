# app/services/ai_manager/network_optimizer.rb
module AIManager
  class NetworkOptimizer
    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Identify strategic wormhole development priorities
    def identify_network_priorities(current_network, expansion_targets, economic_constraints)
      Rails.logger.info "[NetworkOptimizer] Identifying network priorities for #{expansion_targets.length} targets"

      # Analyze current network gaps
      network_gaps = analyze_network_gaps(current_network, expansion_targets)

      # Calculate development priorities
      development_priorities = calculate_development_priorities(network_gaps, economic_constraints)

      # Optimize development sequence
      optimized_sequence = optimize_development_sequence(development_priorities, economic_constraints)

      # Calculate economic impact
      economic_impact = calculate_economic_impact(optimized_sequence, current_network)

      {
        network_gaps: network_gaps,
        development_priorities: development_priorities,
        optimized_sequence: optimized_sequence,
        economic_impact: economic_impact,
        implementation_roadmap: generate_implementation_roadmap(optimized_sequence)
      }
    end

    # Optimize wormhole network for maximum economic benefit
    def optimize_network_economics(wormhole_network, settlement_projects, time_horizon)
      Rails.logger.info "[NetworkOptimizer] Optimizing network economics for #{time_horizon} year horizon"

      # Model network evolution
      network_evolution = model_network_evolution(wormhole_network, settlement_projects, time_horizon)

      # Calculate economic scenarios
      economic_scenarios = calculate_economic_scenarios(network_evolution)

      # Find optimal development path
      optimal_path = find_optimal_development_path(economic_scenarios, time_horizon)

      # Generate investment recommendations
      investment_recommendations = generate_investment_recommendations(optimal_path)

      {
        network_evolution: network_evolution,
        economic_scenarios: economic_scenarios,
        optimal_path: optimal_path,
        investment_recommendations: investment_recommendations,
        risk_analysis: analyze_network_risks(optimal_path, wormhole_network)
      }
    end

    private

    def analyze_network_gaps(current_network, expansion_targets)
      gaps = []

      expansion_targets.each do |target|
        # Check if target is accessible via current network
        accessibility = check_network_accessibility(current_network, target)

        if accessibility[:accessible] == false
          gap_analysis = analyze_accessibility_gap(current_network, target, accessibility)

          gaps << {
            target_system: target,
            gap_type: gap_analysis[:gap_type],
            missing_connections: gap_analysis[:missing_connections],
            economic_impact: calculate_gap_economic_impact(target, gap_analysis),
            development_cost: estimate_development_cost(gap_analysis),
          }.tap do |gap|
            gap[:priority_score] = calculate_gap_priority(target, gap[:economic_impact], gap[:development_cost])
          end
        end
      end

      gaps.sort_by { |gap| -gap[:priority_score] }
    end

    def check_network_accessibility(network, target_system)
      target_id = target_system[:identifier]

      # Check if target is already in network
      if network[:nodes][target_id]
        return { accessible: true, path_length: 0, connection_type: :direct }
      end

      # Find shortest path to network
      shortest_path = find_shortest_path_to_network(network, target_id)

      if shortest_path
        {
          accessible: false,
          path_length: shortest_path[:length],
          nearest_node: shortest_path[:nearest_node],
          connection_type: :indirect,
          required_hops: shortest_path[:hops]
        }
      else
        {
          accessible: false,
          path_length: Float::INFINITY,
          connection_type: :isolated
        }
      end
    end

    def analyze_accessibility_gap(network, target, accessibility)
      case accessibility[:connection_type]
      when :indirect
        {
          gap_type: :missing_intermediate_connections,
          missing_connections: [accessibility[:required_hops]].compact, # Make it an array
          development_approach: :build_chain,
          complexity: :medium
        }
      when :isolated
        {
          gap_type: :complete_isolation,
          missing_connections: [{ from: accessibility[:nearest_node], to: target[:identifier] }],
          development_approach: :direct_artificial_wormhole,
          complexity: :high
        }
      else
        {
          gap_type: :unknown,
          missing_connections: [],
          development_approach: :analyze_further,
          complexity: :unknown
        }
      end
    end

    def calculate_gap_economic_impact(target, gap_analysis)
      base_value = target[:economic_value] || 100000

      # Impact multipliers based on gap type
      impact_multiplier = case gap_analysis[:gap_type]
                         when :missing_intermediate_connections then 0.7
                         when :complete_isolation then 0.3
                         else 0.5
                         end

      # Complexity penalty
      complexity_penalty = case gap_analysis[:complexity]
                          when :high then 0.8
                          when :medium then 0.9
                          else 1.0
                          end

      {
        potential_value: base_value,
        accessible_value: base_value * impact_multiplier * complexity_penalty,
        value_loss: base_value * (1 - impact_multiplier * complexity_penalty),
        annual_impact: base_value * (1 - impact_multiplier * complexity_penalty) * 0.1 # 10% annual return
      }
    end

    def estimate_development_cost(gap_analysis)
      base_cost = 50000000 # 50M GCC base cost for artificial wormhole

      # Adjust for complexity
      complexity_multiplier = case gap_analysis[:complexity]
                             when :high then 2.0
                             when :medium then 1.5
                             else 1.0
                             end

      # Adjust for connection count
      connection_multiplier = gap_analysis[:missing_connections].length

      total_cost = base_cost * complexity_multiplier * connection_multiplier

      {
        base_cost: base_cost,
        complexity_multiplier: complexity_multiplier,
        connection_multiplier: connection_multiplier,
        total_cost: total_cost,
        annual_maintenance: total_cost * 0.05 # 5% annual maintenance
      }
    end

    def calculate_gap_priority(target, economic_impact, development_cost)
      # Priority based on benefit-cost ratio and urgency
      benefit_cost_ratio = economic_impact[:annual_impact] / development_cost[:annual_maintenance]

      # Urgency based on target's strategic value
      strategic_value = target[:strategic_value] || 1.0

      # Time sensitivity
      time_sensitivity = target[:time_sensitive] ? 2.0 : 1.0

      benefit_cost_ratio * strategic_value * time_sensitivity
    end

    def calculate_development_priorities(gaps, economic_constraints)
      available_budget = economic_constraints[:available_budget] || 100000000
      max_annual_investment = economic_constraints[:max_annual_investment] || 20000000

      prioritized_gaps = gaps.map do |gap|
        # Calculate ROI and payback period
        development_cost = gap[:development_cost][:total_cost]
        annual_benefit = gap[:economic_impact][:annual_impact]
        annual_maintenance = gap[:development_cost][:annual_maintenance]

        net_annual_benefit = annual_benefit - annual_maintenance
        payback_years = development_cost / net_annual_benefit.to_f
        roi_percentage = (net_annual_benefit / development_cost) * 100

        # Budget feasibility
        budget_feasible = development_cost <= available_budget
        annual_feasible = annual_maintenance <= max_annual_investment

        gap.merge({
          payback_years: payback_years,
          roi_percentage: roi_percentage,
          net_annual_benefit: net_annual_benefit,
          budget_feasible: budget_feasible,
          annual_feasible: annual_feasible,
          overall_feasibility: budget_feasible && annual_feasible && payback_years < 10
        })
      end

      prioritized_gaps.sort_by do |gap|
        # Sort by feasibility first, then by ROI
        feasibility_score = gap[:overall_feasibility] ? 1000 : 0
        feasibility_score += gap[:budget_feasible] ? 100 : 0
        feasibility_score += gap[:annual_feasible] ? 10 : 0

        -(feasibility_score + gap[:roi_percentage])
      end
    end

    def optimize_development_sequence(priorities, economic_constraints)
      sequence = []
      remaining_budget = economic_constraints[:available_budget] || 100000000
      current_year = 0
      max_years = economic_constraints[:planning_horizon] || 5

      # Phase 1: High feasibility, high ROI projects
      high_priority = priorities.select { |p| p[:overall_feasibility] && p[:payback_years] < 5 }

      high_priority.each do |priority|
        break if current_year >= max_years || priority[:development_cost][:total_cost] > remaining_budget

        sequence << {
          project: priority,
          phase: 1,
          scheduled_year: current_year,
          funding_allocated: priority[:development_cost][:total_cost]
        }

        remaining_budget -= priority[:development_cost][:total_cost]
        current_year += 1
      end

      # Phase 2: Medium feasibility projects
      medium_priority = priorities.select { |p| p[:budget_feasible] && !p[:overall_feasibility] }

      medium_priority.each do |priority|
        break if current_year >= max_years || priority[:development_cost][:total_cost] > remaining_budget

        sequence << {
          project: priority,
          phase: 2,
          scheduled_year: current_year,
          funding_allocated: priority[:development_cost][:total_cost]
        }

        remaining_budget -= priority[:development_cost][:total_cost]
        current_year += 1
      end

      # Phase 3: Long-term strategic projects
      long_term = priorities.reject { |p| p[:budget_feasible] }

      long_term.each do |priority|
        break if current_year >= max_years

        sequence << {
          project: priority,
          phase: 3,
          scheduled_year: current_year,
          funding_allocated: 0, # Requires additional funding
          funding_gap: priority[:development_cost][:total_cost]
        }

        current_year += 1
      end

      sequence
    end

    def calculate_economic_impact(sequence, current_network)
      total_investment = sequence.sum { |item| item[:funding_allocated] }
      total_funding_gap = sequence.sum { |item| item[:funding_gap] || 0 }

      # Calculate annual benefits
      annual_benefits = sequence.map do |item|
        next 0 unless item[:funding_allocated] > 0

        project = item[:project]
        annual_benefit = project[:net_annual_benefit]
        # Benefits start after completion (assume 1 year development)
        start_year = (item[:scheduled_year] || 0) + 1

        { start_year: start_year, annual_benefit: annual_benefit }
      end

      # Calculate NPV over 10 years
      discount_rate = 0.08 # 8% discount rate
      npv = 0
      total_annual_benefit = 0

      (0..9).each do |year|
        year_benefit = annual_benefits.sum do |benefit|
          benefit[:start_year] <= year ? benefit[:annual_benefit] : 0
        end

        total_annual_benefit += year_benefit
        npv += year_benefit / ((1 + discount_rate) ** year)
      end

      npv -= total_investment

      {
        total_investment: total_investment,
        total_funding_gap: total_funding_gap,
        net_present_value: npv,
        total_annual_benefit: total_annual_benefit,
        benefit_cost_ratio: total_annual_benefit / total_investment.to_f,
        roi_percentage: (npv / total_investment) * 100,
        payback_period_years: calculate_payback_period(sequence)
      }
    end

    def generate_implementation_roadmap(sequence)
      roadmap = { phases: {}, milestones: [], risks: [] }

      # Group by phases
      sequence.group_by { |item| item[:phase] }.each do |phase, items|
        roadmap[:phases][phase] = {
          name: phase_name(phase),
          duration_years: items.last[:scheduled_year] - items.first[:scheduled_year] + 1,
          projects: items.length,
          total_investment: items.sum { |item| item[:funding_allocated] },
          expected_benefits: items.sum { |item| item[:project][:net_annual_benefit] }
        }
      end

      # Generate milestones
      sequence.each do |item|
        roadmap[:milestones] << {
          year: item[:scheduled_year],
          project: item[:project][:target_system][:name] || item[:project][:target_system][:identifier],
          type: item[:phase] == 1 ? :high_priority : :standard,
          investment: item[:funding_allocated],
          expected_completion: item[:scheduled_year] + 1
        }
      end

      # Identify risks
      roadmap[:risks] = identify_implementation_risks(sequence)

      roadmap
    end

    def model_network_evolution(network, settlement_projects, time_horizon)
      evolution = []

      (0..time_horizon).each do |year|
        year_state = {
          year: year,
          active_wormholes: network[:edges].length,
          connected_systems: network[:nodes].length,
          operational_settlements: 0,
          network_capacity: calculate_network_capacity(network),
          economic_output: 0
        }

        # Add settlements that come online this year
        settlement_projects.each do |project|
          if project[:completion_year] <= year
            year_state[:operational_settlements] += 1
            year_state[:economic_output] += project[:annual_economic_output] || 50000
          end
        end

        # Add network improvements planned for this year
        network_improvements = settlement_projects.count { |p| p[:network_upgrade_year] == year }
        year_state[:active_wormholes] += network_improvements

        evolution << year_state
      end

      evolution
    end

    def calculate_economic_scenarios(evolution)
      scenarios = {
        baseline: calculate_scenario_metrics(evolution, 1.0),
        optimistic: calculate_scenario_metrics(evolution, 1.3),
        pessimistic: calculate_scenario_metrics(evolution, 0.7)
      }

      scenarios
    end

    def calculate_scenario_metrics(evolution, multiplier)
      total_output = evolution.sum { |year| year[:economic_output] * multiplier }
      peak_capacity = evolution.map { |year| year[:network_capacity] }.max
      settlement_growth_rate = calculate_growth_rate(evolution.map { |y| y[:operational_settlements] })

      {
        total_economic_output: total_output,
        peak_network_capacity: peak_capacity,
        settlement_growth_rate: settlement_growth_rate,
        average_annual_output: total_output / evolution.length.to_f
      }
    end

    def find_optimal_development_path(scenarios, time_horizon)
      # Compare scenarios and find optimal investment strategy
      baseline_npv = scenarios[:baseline][:total_economic_output] * 0.8 # Simplified NPV calculation
      optimistic_npv = scenarios[:optimistic][:total_economic_output] * 0.8
      pessimistic_npv = scenarios[:pessimistic][:total_economic_output] * 0.8

      expected_npv = (baseline_npv * 0.5) + (optimistic_npv * 0.3) + (pessimistic_npv * 0.2)

      {
        recommended_approach: expected_npv > baseline_npv ? :aggressive : :conservative,
        expected_npv: expected_npv,
        risk_adjusted_npv: expected_npv * 0.9, # Risk adjustment
        confidence_interval: {
          low: pessimistic_npv,
          expected: expected_npv,
          high: optimistic_npv
        }
      }
    end

    def generate_investment_recommendations(optimal_path)
      recommendations = []

      if optimal_path[:recommended_approach] == :aggressive
        recommendations << {
          type: :expansion_accelerator,
          priority: :high,
          description: "Accelerate wormhole development to capture optimistic scenario benefits",
          investment_increase: 50000000,
          expected_roi: 25
        }
      end

      recommendations << {
        type: :risk_mitigation,
        priority: :medium,
        description: "Invest in stabilization technology to reduce wormhole failure risks",
        investment_increase: 20000000,
        expected_roi: 15
      }

      recommendations << {
        type: :capacity_expansion,
        priority: :high,
        description: "Increase network capacity to support projected settlement growth",
        investment_increase: 30000000,
        expected_roi: 20
      }

      recommendations
    end

    def analyze_network_risks(optimal_path, network)
      risks = []

      # Capacity risk
      current_capacity = calculate_network_capacity(network)
      projected_demand = optimal_path[:expected_npv] * 0.001 # Simplified demand calculation

      if projected_demand > current_capacity * 1.5
        risks << {
          type: :capacity_constraint,
          severity: :high,
          description: "Network capacity may limit economic growth",
          mitigation_cost: 10000000,
          impact_probability: 0.7
        }
      end

      # Stability risk
      unstable_wormholes = network[:edges].count { |edge| edge[:stability] != 'stable' }

      if unstable_wormholes > network[:edges].length * 0.3
        risks << {
          type: :stability_risk,
          severity: :medium,
          description: "High proportion of unstable wormholes increases failure risk",
          mitigation_cost: 15000000,
          impact_probability: 0.5
        }
      end

      # Isolation risk
      isolated_nodes = network[:nodes].count { |id, node| node[:connected_systems].empty? }

      if isolated_nodes > 0
        risks << {
          type: :isolation_risk,
          severity: :low,
          description: "#{isolated_nodes} systems remain isolated from network",
          mitigation_cost: isolated_nodes * 25000000,
          impact_probability: 0.3
        }
      end

      risks
    end

    # Helper methods
    def find_shortest_path_to_network(network, target_id)
      # Simplified implementation - in reality would use proper graph algorithms
      nearest_node = network[:nodes].keys.first
      { nearest_node: nearest_node, length: 1, hops: 1 }
    end

    def calculate_growth_rate(values)
      return 0 if values.length < 2

      initial = values.first.to_f
      final = values.last.to_f

      return 0 if initial == 0

      ((final / initial) ** (1.0 / (values.length - 1))) - 1
    end

    def calculate_payback_period(sequence)
      cumulative_investment = 0
      cumulative_benefit = 0

      sequence.each do |item|
        cumulative_investment += item[:funding_allocated]
        annual_benefit = item[:project][:net_annual_benefit]

        years_to_payback = cumulative_investment / annual_benefit.to_f
        return years_to_payback if years_to_payback <= 1

        cumulative_benefit += annual_benefit
      end

      # If not paid back within sequence, estimate
      (cumulative_investment - cumulative_benefit) / sequence.last[:project][:net_annual_benefit].to_f + sequence.length
    end

    def phase_name(phase)
      case phase
      when 1 then "High Priority Development"
      when 2 then "Medium Priority Development"
      when 3 then "Long-term Strategic Planning"
      else "Unknown Phase"
      end
    end

    def identify_implementation_risks(sequence)
      risks = []

      # Check for over-concentration in single year
      yearly_investment = sequence.group_by { |item| item[:scheduled_year] }
      yearly_investment.each do |year, items|
        total_investment = items.sum { |item| item[:funding_allocated] }
        if total_investment > 100000000 # 100M GCC limit
          risks << {
            type: :budget_overload,
            year: year,
            description: "Year #{year} investment exceeds recommended limit",
            severity: :medium
          }
        end
      end

      # Check for technology dependencies
      tech_dependent_projects = sequence.count { |item| item[:project][:gap_analysis]&.[](:complexity) == :high }
      if tech_dependent_projects > sequence.length * 0.5
        risks << {
          type: :technology_dependency,
          description: "High proportion of technology-dependent projects increases failure risk",
          severity: :high
        }
      end

      risks
    end

    def calculate_network_capacity(network)
      # Simplified capacity calculation
      network[:edges].sum { |edge| edge[:capacity] || 1000000 }
    end
  end
end