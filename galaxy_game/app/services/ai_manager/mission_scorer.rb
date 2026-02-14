# app/services/ai_manager/mission_scorer.rb
module AIManager
  class MissionScorer
    SCORING_WEIGHTS = {
      priority_multipliers: {
        critical: 3.0,
        high: 2.0,
        medium: 1.5,
        low: 1.0
      },
      resource_value: 1.0,
      strategic_value: 1.2,
      risk_penalty: 0.8,
      urgency_bonus: 1.5,
      capability_bonus: 1.1
    }.freeze

    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Calculate overall score for a mission option
    def calculate_score(mission_option, state_analysis)
      base_score = calculate_base_score(mission_option)
      priority_multiplier = calculate_priority_multiplier(mission_option)
      strategic_modifier = calculate_strategic_modifier(mission_option, state_analysis)
      risk_modifier = calculate_risk_modifier(mission_option, state_analysis)
      capability_modifier = calculate_capability_modifier(mission_option, state_analysis)
      urgency_modifier = calculate_urgency_modifier(mission_option, state_analysis)

      score = base_score * priority_multiplier * strategic_modifier * risk_modifier * capability_modifier * urgency_modifier

      # Ensure score is within reasonable bounds
      [[score, 0].max, 100].min
    end

    private

    # Calculate base score based on mission type
    def calculate_base_score(option)
      case option[:type]
      when :resource_acquisition
        40.0 # Base resource value
      when :system_scouting
        35.0 # Base exploration value
      when :settlement_expansion
        50.0 # High value for expansion
      when :infrastructure_building
        45.0 # High value for infrastructure
      else
        10.0 # Default low value
      end
    end

    # Apply priority multiplier
    def calculate_priority_multiplier(option)
      SCORING_WEIGHTS[:priority_multipliers][option[:priority]] || 1.0
    end

    # Calculate strategic value modifier
    def calculate_strategic_modifier(option, state_analysis)
      modifier = 1.0

      case option[:type]
      when :resource_acquisition
        # Higher value if resources are critical
        if option[:priority] == :critical
          modifier *= 1.5
        end
        # Lower value if we have surplus
        if state_analysis[:economic_health] > 0.8
          modifier *= 0.8
        end

      when :system_scouting
        # Higher value for strategic systems
        if option[:priority] == :high
          modifier *= 1.3
        end
        # Higher value if we have expansion capability
        if state_analysis[:expansion_readiness] > 0.7
          modifier *= 1.2
        end

      when :settlement_expansion
        # Higher value if we're ready to expand
        modifier *= state_analysis[:expansion_readiness] + 0.5

      when :infrastructure_building
        # Higher value if infrastructure is critical
        if option[:priority] == :critical
          modifier *= 1.4
        end
      end

      modifier
    end

    # Calculate risk modifier (penalize high-risk options)
    def calculate_risk_modifier(option, state_analysis)
      case option[:type]
      when :system_scouting
        # Scouting has some risk but generally safe
        0.95
      when :settlement_expansion
        # Expansion has moderate risk
        state_analysis[:economic_health] > 0.6 ? 0.9 : 0.7
      when :infrastructure_building
        # Building has low risk if resources available
        state_analysis[:building_resources] > 0.5 ? 0.95 : 0.8
      else
        1.0 # Resource acquisition generally safe
      end
    end

    # Calculate capability modifier (bonus for high capability)
    def calculate_capability_modifier(option, state_analysis)
      case option[:type]
      when :resource_acquisition
        capability = state_analysis[:acquisition_capability]
      when :system_scouting
        capability = state_analysis[:scouting_capability]
      when :settlement_expansion
        capability = state_analysis[:expansion_readiness]
      when :infrastructure_building
        capability = state_analysis[:building_resources]
      else
        capability = 0.5
      end

      # Bonus for high capability, penalty for low
      capability > 0.7 ? 1.1 : (capability > 0.3 ? 1.0 : 0.9)
    end

    # Calculate urgency modifier based on current needs
    def calculate_urgency_modifier(option, state_analysis)
      modifier = 1.0

      case option[:type]
      when :resource_acquisition
        # Urgent if we have critical resource needs
        critical_needs = state_analysis[:resource_needs][:critical]
        if critical_needs.any?
          modifier *= 1.3
        end

        # Less urgent if we have general needs but not critical
        general_needs = state_analysis[:resource_needs][:needed]
        if general_needs.any? && critical_needs.empty?
          modifier *= 1.1
        end

      when :infrastructure_building
        # Urgent if critical infrastructure needed
        if state_analysis[:infrastructure_needs][:critical].any?
          modifier *= 1.4
        end

      when :system_scouting
        # More urgent if we have strategic opportunities
        if state_analysis[:scouting_opportunities][:high_value].any?
          modifier *= 1.2
        end

      when :settlement_expansion
        # More urgent if we're highly ready
        if state_analysis[:expansion_readiness] > 0.9
          modifier *= 1.2
        end
      end

      modifier
    end
  end
end