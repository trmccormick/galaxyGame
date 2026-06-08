# app/services/ai_manager/strategy_selector.rb
require_relative 'state_analyzer'
require_relative 'mission_scorer'

module AIManager
  class StrategySelector
    attr_reader :shared_context, :service_coordinator, :state_analyzer, :mission_scorer

    def initialize(shared_context, service_coordinator)
      @shared_context = shared_context
      @service_coordinator = service_coordinator
      @state_analyzer = StateAnalyzer.new
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

      # Perform strategic trade-off analysis
      strategic_analysis = perform_strategic_tradeoff_analysis(state_analysis)

      # Apply strategic adjustments to scored options
      adjusted_options = apply_strategic_adjustments(scored_options, strategic_analysis, state_analysis)

      # Select best action with strategic considerations
      best_action = select_optimal_action_with_strategy(adjusted_options, strategic_analysis, state_analysis)

      Rails.logger.info "[StrategySelector] Selected action: #{best_action[:type]} (score: #{best_action[:score]}) - Strategic focus: #{best_action[:strategic_focus]}"

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
      when :cost_reduction
        execute_cost_reduction(action, settlement)
      else
        Rails.logger.warn "[StrategySelector] Unknown action type: #{action[:type]}"
        false
      end
    end

    private

    def find_source_settlement
      Settlement::BaseSettlement.find_by(name: 'Cape Canaveral Spaceport')
    end

    # Generate available mission options based on current state
    def generate_mission_options(settlement, state_analysis)
      options = []

      # Resource acquisition options
      if (state_analysis&.dig(:resource_needs, :critical) || []).any?
        options << {
          type: :resource_acquisition,
          priority: :critical,
          resources: state_analysis&.dig(:resource_needs, :critical) || [],
          rationale: "Critical resource shortage"
        }
      end

      if (state_analysis&.dig(:resource_needs, :needed) || []).any?
        options << {
          type: :resource_acquisition,
          priority: :high,
          resources: state_analysis&.dig(:resource_needs, :needed) || [],
          rationale: "Resource optimization"
        }
      end

      # System scouting options
      if (state_analysis&.dig(:scouting_opportunities, :high_value) || []).any?
        options << {
          type: :system_scouting,
          priority: :high,
          systems: state_analysis&.dig(:scouting_opportunities, :high_value) || [],
          rationale: "High-value exploration opportunity"
        }
      end

      if (state_analysis&.dig(:scouting_opportunities, :strategic) || []).any?
        options << {
          type: :system_scouting,
          priority: :medium,
          systems: state_analysis&.dig(:scouting_opportunities, :strategic) || [],
          rationale: "Strategic expansion planning"
        }
      end

      # Settlement expansion options
      if (state_analysis&.dig(:expansion_readiness) || 0) >= 0.8
        options << {
          type: :settlement_expansion,
          priority: :high,
          rationale: "Settlement ready for expansion"
        }
      end

      # Infrastructure building options
      if (state_analysis&.dig(:infrastructure_needs, :critical) || []).any?
        options << {
          type: :infrastructure_building,
          priority: :critical,
          infrastructure: state_analysis&.dig(:infrastructure_needs, :critical) || [],
          rationale: "Critical infrastructure required"
        }
      end

      # Cost reduction options — Phase 1 of Luna autonomous management
      if state_analysis&.dig(:cost_analysis, :cost_pressure) && 
         state_analysis[:cost_analysis][:cost_pressure] >= 0.6
        options << {
          type: :cost_reduction,
          priority: :high,
          resources: state_analysis[:cost_analysis][:recommendations],
          rationale: "High cost pressure — optimize local production"
        }
      end

      options
    end

    # Score mission options based on strategic value
    def score_mission_options(options, state_analysis)
      prioritized_missions = @mission_scorer.prioritize_missions(options, state_analysis)
      boosted = prioritized_missions.map do |mission_data|
        original_mission = mission_data[:mission]
        score = mission_data[:score]
        # Boost settlement_expansion when readiness is high
        if original_mission[:type] == :settlement_expansion && 
          state_analysis[:expansion_readiness].to_f >= 0.8
          score *= 1.3
        end
        original_mission.merge(
          score: score,
          analysis: mission_data[:analysis],
          priority_level: mission_data[:priority_level],
          sequencing_info: mission_data[:sequencing_info]
        )
      end
      boosted.sort_by { |o| -o[:score] }
    end

    # Select the optimal action considering current constraints
    def select_optimal_action(scored_options, state_analysis)
      return { type: :wait, score: 0, rationale: "No viable actions available" } if scored_options.empty?

      # First, try to find actions that can be executed immediately
      executable_now = scored_options.select do |option|
        option[:sequencing_info][:can_execute_now] && viable_action?(option, state_analysis)
      end

      unless executable_now.empty?
        best_executable = executable_now.first
        return best_executable.merge(
          rationale: "#{best_executable[:rationale]} - Can execute immediately"
        )
      end

      # If no actions can execute immediately, check for viable actions that might need preparation
      viable_options = scored_options.select do |option|
        viable_action?(option, state_analysis)
      end

      unless viable_options.empty?
        best_viable = viable_options.first
        blocking_deps = best_viable[:sequencing_info][:blocking_dependencies]
        return best_viable.merge(
          rationale: "#{best_viable[:rationale]} - Requires preparation (#{blocking_deps.map { |d| d[:name] }.join(', ')})"
        )
      end

      # Fallback to highest priority option even if not viable
      fallback_option = scored_options.first
      return fallback_option.merge(
        rationale: "#{fallback_option[:rationale]} - Best available despite constraints"
      )
    end

    # Check if an action is viable given current constraints
    def viable_action?(option, state_analysis)
      case option[:type]
      when :resource_acquisition
        # Check if we have the capability to acquire these resources
        state_analysis[:acquisition_capability] >= 0.3
      when :system_scouting
        # Don't scout when expansion readiness is high — expand instead
        state_analysis[:scouting_capability] >= 0.5 &&
          (state_analysis[:expansion_readiness] || 0) < 0.8
      when :settlement_expansion
        # Check if expansion is feasible
        state_analysis[:expansion_readiness] >= 0.7
      when :infrastructure_building
        # Check if we have building resources
        state_analysis[:building_resources] >= 0.4
      when :cost_reduction
        # Check if cost reduction is viable
        state_analysis.dig(:cost_analysis, :viable) == true
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

    # === KNOWN LIMITATIONS (Phase 3) ===
    # - Transit Consumption Blindness: Does not factor consumption rate during transit time; 
    #   import quantity = current deficit only, may be understated for long transits.
    # - Single-Source Routing: All imports default to Cape Canaveral Spaceport via AstroLift;
    #   LEO depot routing and multi-source selection are Phase 4+ concerns.
    # - Skimmer Supply Chain Not Yet Available: Gas shortages (Methane, Hydrogen) routed to 
    #   Earth imports via AstroLift. This is correct for early game — Titan/Venus skimmers have 
    #   multi-year transit times and cannot respond to critical shortages. Once ISRU fuel production
    #   matures AND skimmer logistics are operational (late-game), resource→supply_chain routing can
    #   optimize gas sourcing in Phase 4+. For now, all survival shortages use Earth import path.
    # - HLT Fuel Consumption Uncertainty: Liquid Oxygen and Methane requirements for Heavy Lift 
    #   Transport round-trip operations not yet calibrated through simulation testing. ISRU LOX 
    #   production comes online first; methane reserves built via resupply manifests until local 
    #   fuel production is validated.
    # === END LIMITATIONS ===

    def execute_cost_reduction(action, settlement)
      # Call ShortageDetector to get real shortage quantities (Phase 3 integration)
      shortage_report = Logistics::ShortageDetector.detect_shortages(settlement)
      
      # Handle viable: false — ISRU not basic yet, cannot detect shortages
      unless shortage_report[:viable]
        Rails.logger.warn "[StrategySelector] #{settlement.name} ISRU not viable — cannot detect shortages"
        return false
      end
      
      # Handle empty survival_shortages — no critical imports needed
      if shortage_report[:survival_shortages].empty?
        Rails.logger.info "[StrategySelector] #{settlement.name} has no critical shortages — imports not needed"
        return false
      end
      
      # Get source settlement (Cape Canaveral for Earth imports)
      source = find_source_settlement
      unless source
        Rails.logger.warn "[StrategySelector] No Earth import source available for #{settlement.name}"
        return false
      end
      
      # Process each survival shortage individually with error handling per item
      success_count = 0
      
      shortage_report[:survival_shortages].each do |shortage|
        # Calculate deficit quantity (need - have), clamped to prevent negative quantities
        deficit = [0, shortage[:need] - shortage[:have]].max
        
        # Skip zero-deficit items (stock already meets or exceeds target)
        next if deficit == 0
        
        begin
          import_req = Logistics::ImportRequestGenerator.generate_import_request(
            source: source,
            destination: settlement,
            shortage: { material: shortage[:material], need: deficit }
          )
          
          success_count += 1 if import_req
          Rails.logger.info "[StrategySelector] Import request created for #{shortage[:material]} (#{deficit} units)"
        rescue Logistics::ImportRequestGenerator::ImportRequestError => e
          Rails.logger.warn "[StrategySelector] Failed to create import for #{shortage[:material]}: #{e.message}"
          # Continue processing remaining shortages — don't abort full batch on single failure
        end
      end
      
      # Return true if at least one ImportRequest created successfully; false only if all fail or no shortages detected
      success_count > 0
    end

    # === STRATEGIC DECISION LOGIC ===

    # Perform comprehensive trade-off analysis
    def perform_strategic_tradeoff_analysis(state_analysis)
      resource_vs_scouting = @mission_scorer.analyze_resource_vs_scouting_tradeoffs(state_analysis)
      resource_vs_building = @mission_scorer.analyze_resource_vs_building_tradeoffs(state_analysis)
      scouting_vs_building = @mission_scorer.analyze_scouting_vs_building_tradeoffs(state_analysis)

      # Determine overall strategic focus
      overall_focus = determine_overall_strategic_focus(
        resource_vs_scouting,
        resource_vs_building,
        scouting_vs_building,
        state_analysis
      )

      {
        resource_vs_scouting: resource_vs_scouting,
        resource_vs_building: resource_vs_building,
        scouting_vs_building: scouting_vs_building,
        overall_focus: overall_focus,
        risk_tolerance: resource_vs_scouting[:risk_adjustment],
        long_term_value: resource_vs_scouting[:long_term_value]
      }
    end

    # Apply strategic adjustments to mission scores
    def apply_strategic_adjustments(scored_options, strategic_analysis, state_analysis)
      focus = strategic_analysis[:overall_focus]

      scored_options.map do |option|
        adjusted_score = option[:score]
        strategic_multiplier = 1.0

        case focus
        when :resource_focus
          strategic_multiplier = option[:type] == :resource_acquisition ? 1.3 : 0.8
        when :scouting_focus
          strategic_multiplier = option[:type] == :system_scouting ? 1.3 : 0.8
        when :building_focus
          strategic_multiplier = [:settlement_expansion, :infrastructure_building].include?(option[:type]) ? 1.3 : 0.8
        when :cost_focus
          strategic_multiplier = option[:type] == :cost_reduction ? 1.3 : 0.8
        when :balanced_approach
          strategic_multiplier = 1.0
        end

        # Apply risk adjustment
        risk_multiplier = case strategic_analysis[:risk_tolerance]
                         when 0.1..0.3 then 0.9  # Conservative - favor safer options
                         when 0.7..0.9 then 1.1  # Aggressive - favor riskier options
                         else 1.0
                         end

        # Apply long-term value bonus
        long_term_bonus = strategic_analysis[:long_term_value] * 0.1

        adjusted_score = (adjusted_score * strategic_multiplier * risk_multiplier) + long_term_bonus

        option.merge(
          adjusted_score: adjusted_score,
          strategic_multiplier: strategic_multiplier,
          risk_multiplier: risk_multiplier,
          long_term_bonus: long_term_bonus
        )
      end.sort_by { |option| -option[:adjusted_score] }
    end

    # Select optimal action with strategic considerations
    def select_optimal_action_with_strategy(adjusted_options, strategic_analysis, state_analysis)
      return { type: :wait, score: 0, rationale: "No viable actions available", strategic_focus: strategic_analysis[:overall_focus] } if adjusted_options.empty?

      # First, try to find actions that can be executed immediately
      executable_now = adjusted_options.select do |option|
        option[:sequencing_info][:can_execute_now] && viable_action?(option, state_analysis)
      end

      unless executable_now.empty?
        best_executable = executable_now.first
        return best_executable.merge(
          score: best_executable[:adjusted_score],
          rationale: "#{best_executable[:rationale]} - Strategic focus: #{strategic_analysis[:overall_focus]}",
          strategic_focus: strategic_analysis[:overall_focus]
        )
      end

      # If no actions can execute immediately, check for viable actions that might need preparation
      viable_options = adjusted_options.select do |option|
        viable_action?(option, state_analysis)
      end

      unless viable_options.empty?
        best_viable = viable_options.first
        blocking_deps = best_viable[:sequencing_info][:blocking_dependencies]
        return best_viable.merge(
          score: best_viable[:adjusted_score],
          rationale: "#{best_viable[:rationale]} - Requires preparation (#{blocking_deps.map { |d| d[:name] }.join(', ')}) - Strategic focus: #{strategic_analysis[:overall_focus]}",
          strategic_focus: strategic_analysis[:overall_focus]
        )
      end

      # Fallback to highest priority option even if not viable
      fallback_option = adjusted_options.first
      return fallback_option.merge(
        score: fallback_option[:adjusted_score],
        rationale: "#{fallback_option[:rationale]} - Best available despite constraints - Strategic focus: #{strategic_analysis[:overall_focus]}",
        strategic_focus: strategic_analysis[:overall_focus]
      )
    end

    # Determine overall strategic focus from trade-off analyses
    def determine_overall_strategic_focus(resource_vs_scouting, resource_vs_building, scouting_vs_building, state_analysis)
      # Count recommendations for each focus area
      focus_counts = {
        resource_focus: 0,
        scouting_focus: 0,
        building_focus: 0,
        cost_focus: 0,
        balanced_approach: 0
      }

      # Analyze each trade-off
      analyses = [resource_vs_scouting, resource_vs_building, scouting_vs_building]

      analyses.each do |analysis|
        recommendation = analysis[:recommended_focus]
        focus_counts[recommendation] += 1 if focus_counts.key?(recommendation)
      end

      # Determine dominant focus
      max_count = focus_counts.values.max
      dominant_focuses = focus_counts.select { |_, count| count == max_count }.keys

      if dominant_focuses.length == 1
        dominant_focuses.first
      else
        # Tie - use current state to break it
        break_tie_with_state(dominant_focuses, state_analysis)
      end
    end

    # Break ties in strategic focus using current state
    def break_tie_with_state(tied_focuses, state_analysis)
      # Check critical needs first
      critical_resources = state_analysis.dig(:resource_needs, :critical) || []
      critical_infrastructure = state_analysis.dig(:infrastructure_needs, :critical) || []

      if critical_resources.any? && tied_focuses.include?(:resource_focus)
        return :resource_focus
      end

      if critical_infrastructure.any? && tied_focuses.include?(:building_focus)
        return :building_focus
      end

      # Check high-value opportunities
      high_value_systems = state_analysis.dig(:scouting_opportunities, :high_value) || []
      if high_value_systems.any? && tied_focuses.include?(:scouting_focus)
        return :scouting_focus
      end

      # Default to balanced approach if tie persists
      :balanced_approach
    end
  end
end