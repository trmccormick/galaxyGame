# app/services/ai_manager/strategy_selector.rb
require_relative 'state_analyzer'
require_relative 'mission_scorer'

module AIManager
  class StrategySelector
    attr_reader :shared_context, :service_coordinator, :state_analyzer, :mission_scorer

    def initialize(shared_context, service_coordinator)
      @shared_context = shared_context
      @service_coordinator = service_coordinator
      @state_analyzer = StateAnalyzer.new(shared_context)
      @mission_scorer = MissionScorer.new(shared_context)
    end

    # Main decision-making method - evaluates current state and recommends next action
    def evaluate_next_action(settlement)
      Rails.logger.info "[StrategySelector] Evaluating next action for #{settlement.name}"

      # Analyze current state
      state_analysis = @state_analyzer.analyze_state(settlement)

      # Generate available mission options
      mission_options = generate_mission_options(settlement, state_analysis)

      # Score and prioritize options
      scored_options = score_mission_options(mission_options, state_analysis)

      # Select best action
      best_action = select_optimal_action(scored_options, state_analysis)

      Rails.logger.info "[StrategySelector] Selected action: #{best_action[:type]} (score: #{best_action[:score]})"

      best_action
    end

    # Execute the selected action
    def execute_action(action, settlement)
      case action[:type]
      when :resource_acquisition
        execute_resource_acquisition(action, settlement)
      when :system_scouting
        execute_system_scouting(action, settlement)
      when :settlement_expansion
        execute_settlement_expansion(action, settlement)
      when :infrastructure_building
        execute_infrastructure_building(action, settlement)
      else
        Rails.logger.warn "[StrategySelector] Unknown action type: #{action[:type]}"
        false
      end
    end

    private

    # Generate available mission options based on current state
    def generate_mission_options(settlement, state_analysis)
      options = []

      # Resource acquisition options
      if state_analysis[:resource_needs][:critical].any?
        options << {
          type: :resource_acquisition,
          priority: :critical,
          resources: state_analysis[:resource_needs][:critical],
          rationale: "Critical resource shortage"
        }
      end

      if state_analysis[:resource_needs][:needed].any?
        options << {
          type: :resource_acquisition,
          priority: :high,
          resources: state_analysis[:resource_needs][:needed],
          rationale: "Resource optimization"
        }
      end

      # System scouting options
      if state_analysis[:scouting_opportunities][:high_value].any?
        options << {
          type: :system_scouting,
          priority: :high,
          systems: state_analysis[:scouting_opportunities][:high_value],
          rationale: "High-value exploration opportunity"
        }
      end

      if state_analysis[:scouting_opportunities][:strategic].any?
        options << {
          type: :system_scouting,
          priority: :medium,
          systems: state_analysis[:scouting_opportunities][:strategic],
          rationale: "Strategic expansion planning"
        }
      end

      # Settlement expansion options
      if state_analysis[:expansion_readiness] >= 0.8
        options << {
          type: :settlement_expansion,
          priority: :high,
          rationale: "Settlement ready for expansion"
        }
      end

      # Infrastructure building options
      if state_analysis[:infrastructure_needs][:critical].any?
        options << {
          type: :infrastructure_building,
          priority: :critical,
          infrastructure: state_analysis[:infrastructure_needs][:critical],
          rationale: "Critical infrastructure required"
        }
      end

      options
    end

    # Score mission options based on strategic value
    def score_mission_options(options, state_analysis)
      options.map do |option|
        score = @mission_scorer.calculate_score(option, state_analysis)
        option.merge(score: score)
      end.sort_by { |opt| -opt[:score] } # Sort by score descending
    end

    # Select the optimal action considering current constraints
    def select_optimal_action(scored_options, state_analysis)
      return { type: :wait, score: 0, rationale: "No viable actions available" } if scored_options.empty?

      # Apply strategic constraints
      viable_options = scored_options.select do |option|
        viable_action?(option, state_analysis)
      end

      return scored_options.first.merge(rationale: "Best available option") if viable_options.empty?

      # Return highest scoring viable option
      viable_options.first
    end

    # Check if an action is viable given current constraints
    def viable_action?(option, state_analysis)
      case option[:type]
      when :resource_acquisition
        # Check if we have the capability to acquire these resources
        state_analysis[:acquisition_capability] >= 0.3
      when :system_scouting
        # Check if we have scouting capability
        state_analysis[:scouting_capability] >= 0.5
      when :settlement_expansion
        # Check if expansion is feasible
        state_analysis[:expansion_readiness] >= 0.7
      when :infrastructure_building
        # Check if we have building resources
        state_analysis[:building_resources] >= 0.4
      else
        true
      end
    end

    # Execute specific action types
    def execute_resource_acquisition(action, settlement)
      action[:resources].each do |resource|
        @service_coordinator.acquire_resource(resource, 100, settlement) # Default quantity
      end
      true
    end

    def execute_system_scouting(action, settlement)
      action[:systems].each do |system_data|
        @service_coordinator.scout_system(system_data)
      end
      true
    end

    def execute_settlement_expansion(action, settlement)
      # This would trigger expansion planning logic
      Rails.logger.info "[StrategySelector] Initiating settlement expansion for #{settlement.name}"
      # For now, just log - expansion logic would be implemented in a separate service
      true
    end

    def execute_infrastructure_building(action, settlement)
      # This would trigger building mission creation
      Rails.logger.info "[StrategySelector] Initiating infrastructure building for #{settlement.name}"
      # For now, just log - building logic would be implemented in a separate service
      true
    end
  end
end