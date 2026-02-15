# app/services/ai_manager/system_state.rb
module AIManager
  class SystemState
    attr_accessor :total_resources, :settlement_states, :system_health,
                  :strategic_objectives, :dependencies, :economic_balance

    def initialize
      @total_resources = {}
      @settlement_states = {}
      @system_health = {}
      @strategic_objectives = []
      @dependencies = {}
      @economic_balance = {}
    end

    # Update system state from all settlement managers
    def update_from_settlements(settlement_managers)
      @total_resources = calculate_total_resources(settlement_managers)
      @settlement_states = collect_settlement_states(settlement_managers)
    end

    # Analyze overall system health
    def analyze_system_health
      @system_health = {
        resource_distribution: analyze_resource_distribution,
        settlement_viability: analyze_settlement_viability,
        economic_stability: analyze_economic_stability,
        logistical_efficiency: analyze_logistical_efficiency,
        overall_score: calculate_overall_health_score
      }
    end

    # Update strategic objectives based on current state
    def update_strategic_objectives(new_objectives = nil)
      if new_objectives
        @strategic_objectives = new_objectives
      else
        @strategic_objectives = generate_strategic_objectives
      end
    end

    # Update system dependencies
    def update_dependencies(new_dependencies)
      @dependencies = new_dependencies
    end

    # Coordinate expansion plans across the system
    def coordinate_expansion(body_opportunities)
      coordinated_plans = {}

      # Analyze opportunities for conflicts and synergies
      analyzed_opportunities = analyze_expansion_opportunities(body_opportunities)

      # Create coordinated plans that avoid conflicts and maximize synergies
      analyzed_opportunities.each do |body_id, opportunities|
        body_plans = create_body_expansion_plan(opportunities)
        coordinated_plans.merge!(body_plans)
      end

      coordinated_plans
    end

    private

    # Calculate total resources across all settlements
    def calculate_total_resources(settlement_managers)
      total = Hash.new(0)

      settlement_managers.each do |manager|
        manager.settlement_resources.each do |resource, quantity|
          total[resource] += quantity
        end
      end

      total
    end

    # Collect states from all settlements
    def collect_settlement_states(settlement_managers)
      states = {}

      settlement_managers.each do |manager|
        states[manager.settlement.id] = {
          resources: manager.settlement_resources,
          health: manager.settlement_health,
          priorities: manager.current_priorities,
          capabilities: manager.capabilities
        }
      end

      states
    end

    # Analyze resource distribution across the system
    def analyze_resource_distribution
      return :unknown if @total_resources.empty?

      # Calculate distribution metrics
      resource_types = @total_resources.keys
      distribution_scores = {}

      resource_types.each do |resource|
        distribution_scores[resource] = calculate_distribution_score(resource)
      end

      # Overall distribution health
      average_score = distribution_scores.values.sum / distribution_scores.size.to_f

      case average_score
      when 0.8..1.0 then :excellent
      when 0.6..0.8 then :good
      when 0.4..0.6 then :fair
      when 0.2..0.4 then :poor
      else :critical
      end
    end

    # Analyze viability of individual settlements
    def analyze_settlement_viability
      return :unknown if @settlement_states.empty?

      viable_count = 0
      critical_count = 0

      @settlement_states.each do |settlement_id, state|
        health_score = state[:health]

        if health_score > 0.7
          viable_count += 1
        elsif health_score < 0.3
          critical_count += 1
        end
      end

      total_settlements = @settlement_states.size
      viability_ratio = viable_count / total_settlements.to_f
      critical_ratio = critical_count / total_settlements.to_f

      if critical_ratio > 0.3
        :critical
      elsif viability_ratio > 0.7
        :healthy
      elsif viability_ratio > 0.5
        :concerning
      else
        :unhealthy
      end
    end

    # Analyze economic stability across the system
    def analyze_economic_stability
      # This would analyze economic metrics across settlements
      :stable # Placeholder
    end

    # Analyze logistical efficiency
    def analyze_logistical_efficiency
      # This would analyze transport and logistics efficiency
      :efficient # Placeholder
    end

    # Calculate overall health score
    def calculate_overall_health_score
      scores = {
        resource_distribution: distribution_score(@system_health[:resource_distribution]),
        settlement_viability: viability_score(@system_health[:settlement_viability]),
        economic_stability: economic_score(@system_health[:economic_stability]),
        logistical_efficiency: logistics_score(@system_health[:logistical_efficiency])
      }

      scores.values.sum / scores.size.to_f
    end

    # Generate strategic objectives based on current state
    def generate_strategic_objectives
      objectives = []

      # Resource balancing objectives
      if @system_health[:resource_distribution] == :poor || @system_health[:resource_distribution] == :critical
        objectives << {
          type: :resource_balancing,
          priority: :high,
          description: "Balance resource distribution across settlements"
        }
      end

      # Settlement health objectives
      if @system_health[:settlement_viability] == :critical || @system_health[:settlement_viability] == :unhealthy
        objectives << {
          type: :settlement_support,
          priority: :critical,
          description: "Support struggling settlements with resources and logistics"
        }
      end

      # Expansion objectives
      if @system_health[:overall_score] > 0.7
        objectives << {
          type: :system_expansion,
          priority: :medium,
          description: "Plan coordinated expansion to new celestial bodies"
        }
      end

      objectives
    end

    # Helper methods for scoring
    def distribution_score(level)
      case level
      when :excellent then 1.0
      when :good then 0.8
      when :fair then 0.6
      when :poor then 0.4
      when :critical then 0.2
      else 0.5
      end
    end

    def viability_score(level)
      case level
      when :healthy then 1.0
      when :concerning then 0.7
      when :unhealthy then 0.4
      when :critical then 0.2
      else 0.5
      end
    end

    def economic_score(level)
      case level
      when :excellent then 1.0
      when :stable then 0.8
      when :unstable then 0.4
      when :critical then 0.2
      else 0.5
      end
    end

    def logistics_score(level)
      case level
      when :excellent then 1.0
      when :efficient then 0.8
      when :adequate then 0.6
      when :poor then 0.4
      when :critical then 0.2
      else 0.5
      end
    end

    def calculate_distribution_score(resource)
      # Calculate how evenly distributed this resource is
      settlement_counts = @settlement_states.values.map { |state| state[:resources][resource] || 0 }
      return 0.5 if settlement_counts.empty?

      mean = settlement_counts.sum / settlement_counts.size.to_f
      return 1.0 if mean.zero? # All have zero, perfectly distributed

      variance = settlement_counts.map { |count| (count - mean) ** 2 }.sum / settlement_counts.size
      std_dev = Math.sqrt(variance)

      # Lower standard deviation means better distribution
      # Score from 0 (terrible distribution) to 1 (perfect distribution)
      max_reasonable_std_dev = mean * 2 # Assume 2x mean is very poor distribution
      score = 1.0 - (std_dev / max_reasonable_std_dev)
      [score, 0.0].max.clamp(0.0, 1.0)
    end

    def analyze_expansion_opportunities(body_opportunities)
      # Analyze opportunities for conflicts and synergies
      analyzed = {}

      body_opportunities.each do |body_id, opportunities|
        analyzed_opps = opportunities.map do |opp|
          opp.merge(conflict_potential: calculate_conflict_potential(opp, opportunities))
        end

        analyzed[body_id] = analyzed_opps
      end

      analyzed
    end

    def create_body_expansion_plan(opportunities)
      # Create expansion plan for a celestial body
      plans = {}

      # Sort by priority and conflict potential
      sorted_opportunities = opportunities.sort_by do |opp|
        [-priority_value(opp[:priority]), opp[:conflict_potential]]
      end

      # Select non-conflicting opportunities
      selected = []
      sorted_opportunities.each do |opp|
        if selected.none? { |selected_opp| conflicts_with?(opp, selected_opp) }
          selected << opp
        end
      end

      # Create plans for selected opportunities
      selected.each do |opp|
        settlement_id = opp[:settlement_id]
        plans[settlement_id] ||= []
        plans[settlement_id] << {
          type: opp[:type],
          priority: opp[:priority],
          resources_required: opp[:resources_required] || [],
          timeline: opp[:timeline] || :immediate
        }
      end

      plans
    end

    def calculate_conflict_potential(opportunity, all_opportunities)
      # Calculate how much this opportunity conflicts with others
      conflicts = 0

      all_opportunities.each do |other|
        next if other == opportunity
        conflicts += 1 if conflicts_with?(opportunity, other)
      end

      conflicts
    end

    def conflicts_with?(opp1, opp2)
      # Check if two opportunities conflict
      # This is a simplified check - in reality would be more complex
      opp1[:type] == opp2[:type] && opp1[:location] == opp2[:location]
    end

    def priority_value(priority)
      case priority
      when :critical then 4
      when :high then 3
      when :medium then 2
      when :low then 1
      else 0
      end
    end
  end
end