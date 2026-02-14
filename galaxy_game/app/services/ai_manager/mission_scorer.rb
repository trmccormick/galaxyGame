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
      # Use the detailed analysis for scoring
      analysis = analyze_mission_value_cost_risk(mission_option, state_analysis)

      # Return the final score from the detailed analysis
      analysis[:final_score]
    end

    # Prioritize missions using a priority queue approach
    def prioritize_missions(mission_options, state_analysis)
      # Analyze each mission option
      analyzed_missions = mission_options.map do |mission|
        analysis = analyze_mission_value_cost_risk(mission, state_analysis)
        score = calculate_score(mission, state_analysis)

        {
          mission: mission,
          analysis: analysis,
          score: score,
          priority_level: determine_priority_level(analysis, score),
          sequencing_info: determine_sequencing_info(mission, state_analysis)
        }
      end

      # Sort by priority level and score
      prioritized_missions = analyzed_missions.sort_by do |mission_data|
        [-priority_level_value(mission_data[:priority_level]), -mission_data[:score]]
      end

      # Apply dependency-based sequencing
      sequenced_missions = apply_dependency_sequencing(prioritized_missions, state_analysis)

      sequenced_missions
    end

    # Determine priority level based on analysis and score
    def determine_priority_level(analysis, score)
      if analysis[:recommendation] == :high_priority && score > 70
        :critical
      elsif analysis[:recommendation] == :high_priority || score > 60
        :high
      elsif analysis[:recommendation] == :medium_priority || score > 40
        :medium
      else
        :low
      end
    end

    # Get numeric value for priority level (for sorting)
    def priority_level_value(level)
      case level
      when :critical then 4
      when :high then 3
      when :medium then 2
      when :low then 1
      else 0
      end
    end

    # Determine sequencing information for mission
    def determine_sequencing_info(mission, state_analysis)
      dependencies = identify_dependencies(mission, state_analysis)

      {
        can_execute_now: dependencies[:unmet_dependencies].empty?,
        blocking_dependencies: dependencies[:blocking_dependencies],
        estimated_duration: estimate_mission_duration(mission),
        resource_requirements: extract_resource_requirements(mission)
      }
    end

    # Apply dependency-based sequencing to prioritized missions
    def apply_dependency_sequencing(prioritized_missions, state_analysis)
      sequenced = []
      remaining = prioritized_missions.dup

      max_iterations = remaining.length * 2 # Prevent infinite loops

      max_iterations.times do
        break if remaining.empty?

        # Find missions that can be executed now
        executable_now = remaining.select { |m| m[:sequencing_info][:can_execute_now] }

        if executable_now.empty?
          # If no missions can execute, take the highest priority one anyway
          # (this handles circular dependencies or incomplete state analysis)
          highest_priority = remaining.first
          sequenced << highest_priority
          remaining.delete(highest_priority)

          # Update remaining missions' dependency status after this mission
          update_dependency_status(remaining, highest_priority[:mission], state_analysis)
        else
          # Take the highest priority executable mission
          highest_executable = executable_now.first
          sequenced << highest_executable
          remaining.delete(highest_executable)

          # Update remaining missions' dependency status
          update_dependency_status(remaining, highest_executable[:mission], state_analysis)
        end
      end

      # Add any remaining missions at the end
      sequenced + remaining
    end

    # Update dependency status of remaining missions after a mission is selected
    def update_dependency_status(remaining_missions, completed_mission, state_analysis)
      # This is a simplified implementation - in a real system, this would
      # update the state analysis to reflect the completion of the mission
      # For now, we'll assume missions don't unblock other missions
      # A more sophisticated implementation would track which dependencies are satisfied
    end

    # Estimate mission duration
    def estimate_mission_duration(mission)
      case mission[:type]
      when :resource_acquisition
        resources = mission[:resources] || []
        5 + (resources.length * 2) # Base 5 days + 2 per resource
      when :system_scouting
        systems = mission[:systems] || []
        10 + (systems.length * 5) # Base 10 days + 5 per system
      when :settlement_expansion
        30 # Major undertaking
      when :infrastructure_building
        infrastructure = mission[:infrastructure] || []
        15 + (infrastructure.length * 10) # Base 15 days + 10 per item
      else
        10 # Default
      end
    end

    # Extract resource requirements from mission
    def extract_resource_requirements(mission)
      case mission[:type]
      when :resource_acquisition
        { energy: 10, personnel: 5 }
      when :system_scouting
        { energy: 20, fuel: 15, personnel: 3 }
      when :settlement_expansion
        { energy: 50, food: 30, water: 25, personnel: 20, materials: 40 }
      when :infrastructure_building
        { energy: 30, materials: 50, personnel: 8, tools: 10 }
      else
        {}
      end
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

    # Calculate detailed value analysis
    def calculate_value_analysis(mission_option, state_analysis)
      case mission_option[:type]
      when :resource_acquisition
        resources = mission_option[:resources] || []
        total_value = resources.sum do |resource|
          case resource
          when 'energy' then 100
          when 'food', 'water' then 80
          when 'steel', 'titanium' then 60
          else 40
          end
        end
        { total_value: total_value, breakdown: resources.map { |r| [r, calculate_resource_value(r)] }.to_h }

      when :system_scouting
        systems = mission_option[:systems] || []
        total_value = systems.sum do |system|
          # Default to low value if estimated_value not specified
          case system[:estimated_value]
          when :high then 150
          when :medium then 120
          else 50  # Lower default for unknown systems
          end
        end
        { total_value: total_value, systems_count: systems.length, high_value_systems: systems.count { |s| s[:estimated_value] == :high } }

      when :settlement_expansion
        base_value = 200
        readiness_bonus = state_analysis[:expansion_readiness] * 50
        { total_value: base_value + readiness_bonus, base_value: base_value, readiness_bonus: readiness_bonus }

      when :infrastructure_building
        infrastructure = mission_option[:infrastructure] || []
        total_value = infrastructure.sum do |infra|
          case infra
          when 'power_grid' then 120
          when 'habitation_expansion' then 100
          else 80
          end
        end
        { total_value: total_value, infrastructure_count: infrastructure.length }

      else
        { total_value: 0 }
      end
    end

    # Calculate cost analysis
    def calculate_cost_analysis(mission_option, state_analysis)
      case mission_option[:type]
      when :resource_acquisition
        resources = mission_option[:resources] || []
        acquisition_cost = resources.length * 20 # Base acquisition cost per resource
        opportunity_cost = 10 # Time spent on acquisition
        { total_cost: acquisition_cost + opportunity_cost, acquisition_cost: acquisition_cost, opportunity_cost: opportunity_cost }

      when :system_scouting
        systems = mission_option[:systems] || []
        scouting_cost = systems.length * 30 # Cost per system scouted
        opportunity_cost = 15 # Time spent scouting
        { total_cost: scouting_cost + opportunity_cost, scouting_cost: scouting_cost, opportunity_cost: opportunity_cost }

      when :settlement_expansion
        expansion_cost = 80 # Base expansion cost
        resource_cost = 40 # Resources needed for expansion
        opportunity_cost = 25 # Time and focus required
        { total_cost: expansion_cost + resource_cost + opportunity_cost, expansion_cost: expansion_cost, resource_cost: resource_cost, opportunity_cost: opportunity_cost }

      when :infrastructure_building
        infrastructure = mission_option[:infrastructure] || []
        building_cost = infrastructure.length * 50 # Cost per infrastructure item
        material_cost = infrastructure.length * 30 # Materials required
        opportunity_cost = 20 # Construction time
        { total_cost: building_cost + material_cost + opportunity_cost, building_cost: building_cost, material_cost: material_cost, opportunity_cost: opportunity_cost }

      else
        { total_cost: 0 }
      end
    end

    # Calculate risk analysis
    def calculate_risk_analysis(mission_option, state_analysis)
      case mission_option[:type]
      when :resource_acquisition
        failure_probability = state_analysis[:acquisition_capability] < 0.5 ? 0.3 : 0.1
        consequence_severity = 0.6 # Moderate consequences for resource acquisition failure
        { failure_probability: failure_probability, consequence_severity: consequence_severity, risk_score: failure_probability * consequence_severity }

      when :system_scouting
        failure_probability = state_analysis[:scouting_capability] < 0.6 ? 0.4 : 0.15
        consequence_severity = 0.4 # Lower consequences for scouting failure
        { failure_probability: failure_probability, consequence_severity: consequence_severity, risk_score: failure_probability * consequence_severity }

      when :settlement_expansion
        failure_probability = state_analysis[:expansion_readiness] < 0.7 ? 0.5 : 0.2
        consequence_severity = 0.8 # High consequences for expansion failure
        { failure_probability: failure_probability, consequence_severity: consequence_severity, risk_score: failure_probability * consequence_severity }

      when :infrastructure_building
        failure_probability = state_analysis[:building_resources] < 0.6 ? 0.35 : 0.1
        consequence_severity = 0.7 # Significant consequences for building failure
        { failure_probability: failure_probability, consequence_severity: consequence_severity, risk_score: failure_probability * consequence_severity }

      else
        { failure_probability: 0.5, consequence_severity: 0.5, risk_score: 0.25 }
      end
    end

    # Calculate base success probability
    def calculate_base_success_probability(mission_option)
      case mission_option[:type]
      when :resource_acquisition
        0.85 # Generally reliable
      when :system_scouting
        0.75 # Depends on technology and conditions
      when :settlement_expansion
        0.70 # Complex but achievable
      when :infrastructure_building
        0.80 # Technical but manageable
      else
        0.50 # Default
      end
    end

    # Calculate capability success factor
    def calculate_capability_success_factor(mission_option, state_analysis)
      case mission_option[:type]
      when :resource_acquisition
        [state_analysis[:acquisition_capability], 0.1].max
      when :system_scouting
        [state_analysis[:scouting_capability], 0.1].max
      when :settlement_expansion
        [state_analysis[:expansion_readiness], 0.1].max
      when :infrastructure_building
        [state_analysis[:building_resources], 0.1].max
      else
        0.5
      end
    end

    # Calculate resource success factor
    def calculate_resource_success_factor(mission_option, state_analysis)
      case mission_option[:type]
      when :resource_acquisition
        # Resource acquisition needs some capability but not full resources
        state_analysis[:economic_health] > 0.3 ? 1.0 : 0.6
      when :system_scouting
        # Scouting needs basic operational capacity
        state_analysis[:economic_health] > 0.4 ? 1.0 : 0.7
      when :settlement_expansion
        # Expansion needs resource surplus
        state_analysis[:economic_health] > 0.6 ? 1.0 : 0.5
      when :infrastructure_building
        # Building needs construction resources
        state_analysis[:building_resources] > 0.5 ? 1.0 : 0.6
      else
        0.8
      end
    end

    # Calculate complexity success factor
    def calculate_complexity_success_factor(mission_option)
      case mission_option[:type]
      when :resource_acquisition
        0.95 # Relatively simple
      when :system_scouting
        0.90 # Moderate complexity
      when :settlement_expansion
        0.85 # High complexity
      when :infrastructure_building
        0.88 # Technical complexity
      else
        0.80
      end
    end

    # Predict success probability for a mission
    def predict_success_probability(mission_option, state_analysis)
      base_probability = calculate_base_success_probability(mission_option)
      capability_factor = calculate_capability_success_factor(mission_option, state_analysis)
      resource_factor = calculate_resource_success_factor(mission_option, state_analysis)
      complexity_factor = calculate_complexity_success_factor(mission_option)

      # Dependencies affect success probability
      dependency_analysis = identify_dependencies(mission_option, state_analysis)
      dependency_factor = dependency_analysis[:dependency_satisfaction]

      # Calculate final probability
      success_probability = base_probability * capability_factor * resource_factor * complexity_factor * dependency_factor

      # Ensure probability is within reasonable bounds
      success_probability = [0.05, success_probability, 0.95].sort[1]

      {
        success_probability: success_probability,
        base_probability: base_probability,
        capability_factor: capability_factor,
        resource_factor: resource_factor,
        complexity_factor: complexity_factor,
        dependency_factor: dependency_factor,
        confidence_level: calculate_confidence_level(success_probability, state_analysis)
      }
    end

    # Calculate confidence level in the prediction
    def calculate_confidence_level(success_probability, state_analysis)
      # Confidence based on data quality and historical performance
      data_quality = state_analysis[:data_quality] || 0.7
      historical_accuracy = state_analysis[:historical_accuracy] || 0.8

      # Higher confidence for extreme probabilities (very likely or unlikely)
      probability_confidence = if success_probability > 0.8 || success_probability < 0.2
                                0.9
                              elsif success_probability > 0.6 || success_probability < 0.4
                                0.7
                              else
                                0.5
                              end

      [data_quality, historical_accuracy, probability_confidence].min
    end

    # Calculate net benefit (value - cost, adjusted for risk and probability)
    def calculate_net_benefit(mission_option, state_analysis)
      value_analysis = calculate_value_analysis(mission_option, state_analysis)
      cost_analysis = calculate_cost_analysis(mission_option, state_analysis)
      risk_analysis = calculate_risk_analysis(mission_option, state_analysis)
      success_prediction = predict_success_probability(mission_option, state_analysis)

      expected_value = value_analysis[:total_value] * success_prediction[:success_probability]
      adjusted_cost = cost_analysis[:total_cost] * (1 + risk_analysis[:risk_score])

      expected_value - adjusted_cost
    end

    # Helper method for resource value calculation
    def calculate_resource_value(resource)
      case resource
      when 'energy' then 100
      when 'food', 'water' then 80
      when 'steel', 'titanium' then 60
      else 40
      end
    end

    # Identify mission dependencies
    def identify_dependencies(mission_option, state_analysis)
      dependencies = []

      case mission_option[:type]
      when :resource_acquisition
        # Resource acquisition depends on basic operational capacity
        dependencies << { type: :capability, name: :basic_operations, required_level: 0.3, current_level: state_analysis[:economic_health] }
        if mission_option[:resources]&.include?('titanium')
          dependencies << { type: :technology, name: :mining_tech, required_level: 0.5, current_level: state_analysis[:acquisition_capability] }
        end

      when :system_scouting
        # Scouting depends on exploration technology and resources
        dependencies << { type: :capability, name: :scouting_capability, required_level: 0.4, current_level: state_analysis[:scouting_capability] }
        dependencies << { type: :resource, name: :energy, required_amount: 20, current_amount: state_analysis[:energy_reserves] || 0 }

      when :settlement_expansion
        # Expansion depends on multiple factors
        dependencies << { type: :capability, name: :expansion_readiness, required_level: 0.6, current_level: state_analysis[:expansion_readiness] }
        dependencies << { type: :resource, name: :food, required_amount: 50, current_amount: state_analysis[:food_reserves] || 0 }
        dependencies << { type: :resource, name: :water, required_amount: 40, current_amount: state_analysis[:water_reserves] || 0 }
        dependencies << { type: :infrastructure, name: :habitation_capacity, required_level: 0.7, current_level: state_analysis[:habitation_capacity] || 0.5 }

      when :infrastructure_building
        # Building depends on construction resources and technology
        dependencies << { type: :capability, name: :building_resources, required_level: 0.5, current_level: state_analysis[:building_resources] }
        dependencies << { type: :resource, name: :steel, required_amount: 30, current_amount: state_analysis[:steel_reserves] || 0 }
        dependencies << { type: :technology, name: :construction_tech, required_level: 0.6, current_level: state_analysis[:building_capability] || 0.5 }
      end

      # Check if all dependencies are met
      unmet_dependencies = dependencies.reject do |dep|
        case dep[:type]
        when :capability, :infrastructure, :technology
          dep[:current_level] >= dep[:required_level]
        when :resource
          dep[:current_amount] >= dep[:required_amount]
        else
          false
        end
      end

      {
        dependencies: dependencies,
        unmet_dependencies: unmet_dependencies,
        dependency_satisfaction: unmet_dependencies.empty? ? 1.0 : 0.0,
        blocking_dependencies: unmet_dependencies.select { |dep| dep[:type] == :capability || dep[:type] == :infrastructure }
      }
    end

    # Analyze mission value, cost, and risk
    def analyze_mission_value_cost_risk(mission_option, state_analysis)
      value_analysis = calculate_value_analysis(mission_option, state_analysis)
      cost_analysis = calculate_cost_analysis(mission_option, state_analysis)
      risk_analysis = calculate_risk_analysis(mission_option, state_analysis)
      success_prediction = predict_success_probability(mission_option, state_analysis)
      dependency_analysis = identify_dependencies(mission_option, state_analysis)

      # Calculate overall mission score
      net_benefit = calculate_net_benefit(mission_option, state_analysis)
      risk_adjusted_score = net_benefit * (1 - risk_analysis[:risk_score] * 0.3)  # Reduce risk penalty further

      # Ensure final score is always positive and favors high-value missions
      # Use a logarithmic scale to prevent high costs from dominating high values
      base_score = [net_benefit + 150, 10].max  # Shift so minimum is 10, give more buffer
      risk_adjusted_base = base_score * (1 - risk_analysis[:risk_score] * 0.3)  # Reduce risk penalty impact
      final_score = risk_adjusted_base * success_prediction[:success_probability]

      # Add priority bonus
      priority_bonus = case mission_option[:priority]
                       when :critical then 50
                       when :high then 30  # Increase high priority bonus
                       when :medium then 10
                       else 0
                       end

      final_score + priority_bonus

      {
        mission_type: mission_option[:type],
        value_analysis: value_analysis,
        cost_analysis: cost_analysis,
        risk_analysis: risk_analysis,
        success_probability: success_prediction[:success_probability],
        dependency_analysis: dependency_analysis,
        net_benefit: net_benefit,
        risk_adjusted_score: risk_adjusted_score,
        final_score: final_score + priority_bonus,
        recommendation: (final_score + priority_bonus) > 25 ? :high_priority : (final_score + priority_bonus) > 10 ? :medium_priority : :low_priority
      }
    end

    # Calculate confidence level in the prediction
    def calculate_confidence_level(success_probability, state_analysis)
      # Confidence based on data quality and historical performance
      data_quality = state_analysis[:data_quality] || 0.7
      historical_accuracy = state_analysis[:historical_accuracy] || 0.8

      # Higher confidence for extreme probabilities (very likely or unlikely)
      probability_confidence = if success_probability > 0.8 || success_probability < 0.2
                                0.9
                              elsif success_probability > 0.6 || success_probability < 0.4
                                0.7
                              else
                                0.5
                              end

      [data_quality, historical_accuracy, probability_confidence].min
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