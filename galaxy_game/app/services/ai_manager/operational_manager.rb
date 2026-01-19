module AIManager
  require_relative 'ai_priority_system'
require_relative 'scout_logic'
  require_relative 'emergency_mission_service'
  require_relative 'procurement_service'
  require_relative 'construction_service'
  require_relative 'expansion_service'
  require_relative 'financial_service'
  require_relative 'performance_tracker'
  require_relative 'world_knowledge_service'
  require_relative 'market_stabilization_service'

  class OperationalManager
    attr_reader :settlement, :patterns, :priorities, :last_decision

    def initialize(settlement)
      @settlement = settlement
      @patterns = load_trained_patterns
      @priorities = AiPrioritySystem.new
      @world_knowledge = WorldKnowledgeService.new(settlement.celestial_body&.data || settlement.celestial_body)
      @last_decision = nil
      @decision_log = []
      @performance_tracker = PerformanceTracker.new(settlement.id)
    end

    def make_decision
      Rails.logger.info "[OperationalManager] Making decision for settlement #{settlement.id}"

      current_context = capture_settlement_context

      # Get adaptation recommendations
      adaptation = @performance_tracker.get_adapted_decision_recommendation(current_context)

      if adaptation
        Rails.logger.info "[OperationalManager] Using adaptation: #{adaptation[:recommended_action]} (confidence: #{adaptation[:confidence].round(2)})"
      end

      # Check critical priorities first
      critical_issues = check_critical_priorities
      if critical_issues.any?
        decision = handle_critical_issues(critical_issues)
        record_decision_with_context(decision, current_context, :critical)
        return decision
      end

      # Check operational priorities
      operational_needs = assess_operational_state
      if operational_needs.any?
        decision = handle_operational_needs(operational_needs)

        # Apply adaptation if available and confident
        if adaptation && adaptation[:confidence] > 0.6
          decision = apply_adaptation_to_decision(decision, adaptation)
        end

        record_decision_with_context(decision, current_context, :operational)
        return decision
      end

      # Consider expansion if stable
      if settlement_stable?
        # First check if scouting new systems would be beneficial
        scouting_decision = consider_scouting
        if scouting_decision
          # Apply adaptation for scouting decisions
          if adaptation && adaptation[:recommended_action] == :scouting && adaptation[:confidence] > 0.5
            scouting_decision[:adaptation_applied] = true
          end

          record_decision_with_context(scouting_decision, current_context, :scouting)
          return scouting_decision
        end

        # Otherwise consider local expansion
        decision = consider_expansion

        # Apply adaptation for expansion decisions
        if adaptation && adaptation[:recommended_action] == :expansion && adaptation[:confidence] > 0.5
          decision[:adaptation_applied] = true
        end

        record_decision_with_context(decision, current_context, :expansion)
        return decision
      end

      # Default: maintain current operations
      decision = { action: :maintain, reason: "settlement_stable" }
      record_decision_with_context(decision, current_context, :maintenance)
      decision
    end

    def execute_decision(decision)
      case decision[:action]
      when :emergency_procurement
        handle_emergency_procurement(decision)
      when :resource_procurement
        handle_resource_procurement(decision)
      when :construction
        handle_construction(decision)
      when :expansion
        handle_expansion(decision)
      when :scouting
        handle_scouting(decision)
      when :debt_repayment
        handle_debt_repayment(decision)
      else
        Rails.logger.info "[OperationalManager] No action needed for decision: #{decision[:action]}"
      end
    end

    def record_decision_outcome(success_score, outcome_details = {})
      if @last_decision
        @performance_tracker.record_outcome(@last_decision, outcome_details, success_score)
        Rails.logger.info "[OperationalManager] Recorded decision outcome: #{success_score} - #{outcome_details}"
      end
    end

    def get_performance_report
      @performance_tracker.get_performance_report
    end

    def tune_behavior
      @performance_tracker.tune_pattern_weights
      Rails.logger.info "[OperationalManager] Behavior tuning applied based on performance data"
    end

    # New methods for system analysis and settlement planning
    def analyze_system_for_expansion(system_seed, celestial_bodies, probe_data = nil)
      # Use ScoutLogic for system-agnostic analysis
      scout = AIManager::ScoutLogic.new(system_seed, probe_data)
      scouting_analysis = scout.analyze_system_patterns

      # Map scouting analysis to expected format for SettlementPlanGenerator
      recommended_target = scouting_analysis[:target_body]&.dig('name') || 'primary_body'
      settlement_strategy = case scouting_analysis[:primary_characteristic]
                           when :large_moon_with_resources then 'terraforming_colony'
                           when :small_moons_with_belt then 'mining_outpost'
                           when :atmospheric_planet_no_surface_access then 'orbital_colony'
                           when :gas_giant_with_moons then 'resource_extraction'
                           else 'resource_extraction'
                           end

      # Priority resources from resource-rich bodies
      priority_resources = scouting_analysis[:resource_rich_bodies].flat_map do |body|
        body['resources'] || []
      end.uniq.first(3)

      # Risk assessment based on primary characteristic and threat level
      base_risk = case scouting_analysis[:primary_characteristic]
                 when :large_moon_with_resources then 'moderate'
                 when :small_moons_with_belt then 'low'
                 when :atmospheric_planet_no_surface_access then 'high'
                 when :gas_giant_with_moons then 'moderate'
                 else 'low'
                 end

      # Adjust risk based on probe threat assessment
      risk_assessment = if scouting_analysis[:threat_level] == 'high'
                         'high'
                       elsif scouting_analysis[:threat_level] == 'moderate'
                         base_risk == 'low' ? 'moderate' : base_risk
                       else
                         base_risk
                       end

      # ROI timeline
      roi_timeline = case scouting_analysis[:primary_characteristic]
                    when :large_moon_with_resources then '5-10 years'
                    when :small_moons_with_belt then '2-5 years'
                    when :atmospheric_planet_no_surface_access then '10-20 years'
                    when :gas_giant_with_moons then '3-7 years'
                    else '2-5 years'
                    end

      {
        recommended_target: recommended_target,
        settlement_strategy: settlement_strategy,
        priority_resources: priority_resources,
        risk_assessment: risk_assessment,
        roi_timeline: roi_timeline,
        terraformable_count: scouting_analysis[:terraformable_bodies].count,
        resource_rich_count: scouting_analysis[:resource_rich_bodies].count,
        # Include scouting analysis for additional context
        scouting_analysis: scouting_analysis
      }
    end

    def generate_settlement_plan(system_seed, analysis)
      # Generate a detailed settlement plan based on analysis
      target_body = analysis[:recommended_target] || 'primary_body'
      mission_type = analysis[:settlement_strategy] == 'terraforming_colony' ? 'full_colonization' : 'resource_extraction'

      # Infrastructure requirements
      infrastructure = case analysis[:settlement_strategy]
                       when 'terraforming_colony'
                         ['habitats', 'life_support', 'terraforming_equipment', 'power_generation']
                       when 'mining_outpost'
                         ['mining_equipment', 'processing_facility', 'power_generation']
                       else
                         ['basic_habitat', 'power_generation']
                       end

      # Procurement strategy
      procurement_strategy = analysis[:terraformable_count] > 0 ? 'hybrid_isru_import' : 'isru_focused'

      # Challenges
      challenges = []
      challenges << 'extreme_environment' if analysis[:risk_assessment] == 'high'
      challenges << 'resource_transport' if analysis[:resource_rich_count] > 3
      challenges << 'terraforming_complexity' if analysis[:settlement_strategy] == 'terraforming_colony'

      # Success probability
      base_probability = analysis[:recommended_target] ? 0.8 : 0.5
      success_probability = [base_probability - (challenges.count * 0.1), 0.1].max

      {
        mission_type: mission_type,
        target_body: target_body,
        infrastructure: infrastructure,
        procurement_strategy: procurement_strategy,
        challenges: challenges,
        success_probability: success_probability,
        estimated_cost: analysis[:settlement_strategy] == 'terraforming_colony' ? 50000 : 25000,
        estimated_duration_months: analysis[:settlement_strategy] == 'terraforming_colony' ? 24 : 12
      }
    end

    private

    def check_critical_priorities
      issues = []

      # Life support check
      if life_support_critical?
        issues << { type: :life_support, severity: :critical, resources: critical_resources }
      end

      # Atmospheric maintenance
      if atmospheric_critical?
        issues << { type: :atmospheric, severity: :critical }
      end

      # Debt repayment
      if debt_critical?
        issues << { type: :debt, severity: :critical, amount: outstanding_debt }
      end

      issues
    end

    def assess_operational_state
      needs = []

      # Resource procurement
      shortage = resource_shortage
      if shortage
        needs << { type: :resource_procurement, resource: shortage[:resource], amount: shortage[:amount] }
      end

      # Construction needs
      construction = construction_needs
      if construction
        needs << { type: :construction, facility: construction[:facility], priority: construction[:priority] }
      end

      # Market stabilization
      market_needs = assess_market_stability
      if market_needs.any?
        needs.concat(market_needs)
      end

      needs
    end

    def assess_market_stability
      needs = []

      # Check for market imbalances that require NPC intervention
      market_imbalances = MarketStabilizationService.stabilize_market(@settlement)

      market_imbalances.each do |imbalance|
        case imbalance[:action]
        when :new_player_support
          if imbalance[:item]
            needs << { type: :market_stabilization, action: :provide_essential, item: imbalance[:item], amount: imbalance[:amount], reason: imbalance[:reason] }
          end
        when :producer_of_last_resort
          if imbalance[:item]
            needs << { type: :market_stabilization, action: :produce_item, item: imbalance[:item], amount: imbalance[:amount_produced] }
          end
        when :importer_of_last_resort
          if imbalance[:item]
            needs << { type: :market_stabilization, action: :import_item, item: imbalance[:item], amount: imbalance[:amount], source: imbalance[:source] }
          end
        end
      end

      needs
    end

    def consider_scouting
      # Evaluate if scouting new systems for wormhole investment is worthwhile
      scouting_service = AIManager::WormholeScoutingService.new(current_system: 'sol')
      opportunities = scouting_service.evaluate_scouting_opportunities

      # Only scout if we have good opportunities and resources allow it
      if opportunities.any? && opportunities.first[:scouting_score] > 30 && scouting_feasible?
        best_opportunity = opportunities.first

        {
          action: :scouting,
          target_system: best_opportunity[:system_name],
          scouting_score: best_opportunity[:scouting_score],
          reason: "high_potential_scouting_opportunity",
          estimated_cost: 10000  # Cost of creating temporary scouting wormhole
        }
      else
        nil
      end
    end

    def determine_dc_type(world_analysis)
      # Hierarchical DC formation: Major worlds get their own DCs, aligned with regional powers
      world_name = world_analysis[:world_name] || @settlement.celestial_body&.name || "unknown"

      # Major worlds get their own Development Corporations
      case world_name.downcase
      when "mars"
        { dc_type: :mars_development_corporation, alignment: :independent, region: :inner_solar }
      when "venus"
        { dc_type: :venus_development_corporation, alignment: :independent, region: :inner_solar }
      when "earth", "luna"
        { dc_type: :earth_development_corporation, alignment: :independent, region: :inner_solar }
      when "ceres"
        { dc_type: :ceres_development_corporation, alignment: :mars_development_corporation, region: :asteroid_belt }
      when "vesta", "pallas"
        { dc_type: :vesta_development_corporation, alignment: :mars_development_corporation, region: :asteroid_belt }
      when "titan"
        { dc_type: :titan_development_corporation, alignment: :saturn_development_corporation, region: :saturn_system }
      when "enceladus", "iapetus"
        { dc_type: :enceladus_development_corporation, alignment: :saturn_development_corporation, region: :saturn_system }
      when "triton"
        { dc_type: :triton_development_corporation, alignment: :neptune_development_corporation, region: :neptune_system }
      when "europa", "ganymede", "callisto", "io"
        { dc_type: :jupiter_development_corporation, alignment: :independent, region: :jupiter_system }
      else
        # Fallback to world type-based classification for unknown worlds
        case world_analysis[:world_type]
        when :gas_giant_moon
          { dc_type: :saturn_development_corporation, alignment: :regional_coordination, region: :outer_solar }
        when :ice_giant_moon
          { dc_type: :neptune_development_corporation, alignment: :regional_coordination, region: :outer_solar }
        when :terrestrial_planet
          { dc_type: :mars_development_corporation, alignment: :regional_coordination, region: :inner_solar }
        when :venus_like
          { dc_type: :venus_development_corporation, alignment: :regional_coordination, region: :inner_solar }
        else
          { dc_type: :independent_development_corporation, alignment: :independent, region: :unknown }
        end
      end
    end

    def generate_adaptive_strategy(world_analysis, dc_info)
      dc_type = dc_info.is_a?(Hash) ? dc_info[:dc_type] : dc_info
      alignment = dc_info.is_a?(Hash) ? dc_info[:alignment] : :independent
      region = dc_info.is_a?(Hash) ? dc_info[:region] : :unknown

      # Determine settlement focus based on DC type and world analysis
      settlement_focus = determine_settlement_focus(dc_type, world_analysis)

      strategy = {
        phases: [],
        resource_focus: [],
        infrastructure_priorities: [],
        npc_trade_opportunities: [],
        dc_alignment: alignment,
        regional_focus: region,
        settlement_type: settlement_focus,
        naming_category: settlement_focus,
        feasible: true
      }

      # Phase 1: Always establish basic foothold
      strategy[:phases] << {
        name: "foothold_establishment",
        duration: 90,
        focus: :basic_survival,
        equipment: [:habitation, :power_generation, :life_support]
      }

      # Adapt phases based on world analysis
      if world_analysis[:atmospheric_resources][:co2][:abundance] > 0.5
        strategy[:phases] << {
          name: "atmospheric_processing",
          duration: 120,
          focus: :co2_utilization,
          equipment: [:sabatier_reactor, :atmospheric_processor]
        }
        strategy[:resource_focus] << :oxygen_production
      end

      if world_analysis[:surface_resources][:water_ice][:abundance] > 0.1
        strategy[:phases] << {
          name: "ice_mining",
          duration: 100,
          focus: :water_extraction,
          equipment: [:ice_drilling_rig, :water_purification]
        }
        strategy[:resource_focus] << :water_independence
      end

      # Add DC-specific trade opportunities
      strategy[:npc_trade_opportunities] = generate_trade_opportunities(dc_type, world_analysis)

      strategy
    end

    def generate_trade_opportunities(dc_info, world_analysis)
      dc_type = dc_info.is_a?(Hash) ? dc_info[:dc_type] : dc_info
      alignment = dc_info.is_a?(Hash) ? dc_info[:alignment] : :independent
      region = dc_info.is_a?(Hash) ? dc_info[:region] : :unknown

      opportunities = []

      case dc_type
      when :ceres_development_corporation
        # Ceres: Water ice, nickel-iron ore, asteroid belt coordination
        opportunities << {
          resource: :water_ice,
          partners: [:mars_development_corporation, :vesta_development_corporation],
          volume: :high,
          priority: :primary,
          region: :asteroid_belt
        }
        opportunities << {
          resource: :nickel_iron_ore,
          partners: [:mars_development_corporation, :earth_development_corporation],
          volume: :high,
          priority: :primary,
          region: :asteroid_belt
        }
      when :vesta_development_corporation
        # Vesta: Basaltic materials, rare earth elements
        opportunities << {
          resource: :basalt,
          partners: [:mars_development_corporation, :luna_development_corporation],
          volume: :medium,
          priority: :primary,
          region: :asteroid_belt
        }
        opportunities << {
          resource: :rare_earth_elements,
          partners: [:earth_development_corporation, :mars_development_corporation],
          volume: :low,
          priority: :secondary,
          region: :asteroid_belt
        }
      when :mars_development_corporation
        # Mars: Oxygen, water, regolith processing
        opportunities << {
          resource: :oxygen,
          partners: [:venus_development_corporation, :ceres_development_corporation, :vesta_development_corporation],
          volume: :high,
          priority: :primary,
          region: :inner_solar
        }
        opportunities << {
          resource: :processed_regolith,
          partners: [:luna_development_corporation, :earth_development_corporation],
          volume: :medium,
          priority: :secondary,
          region: :inner_solar
        }
      when :saturn_development_corporation
        # Saturn system: Hydrocarbons, water ice
        opportunities << {
          resource: :methane,
          partners: [:titan_development_corporation, :enceladus_development_corporation],
          volume: :high,
          priority: :primary,
          region: :saturn_system
        }
        opportunities << {
          resource: :water_ice,
          partners: [:neptune_development_corporation, :mars_development_corporation],
          volume: :medium,
          priority: :secondary,
          region: :saturn_system
        }
      when :titan_development_corporation
        # Titan: Methane lakes, hydrocarbon products
        opportunities << {
          resource: :liquid_methane,
          partners: [:saturn_development_corporation, :enceladus_development_corporation],
          volume: :high,
          priority: :primary,
          region: :saturn_system
        }
      when :neptune_development_corporation
        # Neptune system: Nitrogen, methane
        opportunities << {
          resource: :nitrogen,
          partners: [:triton_development_corporation, :saturn_development_corporation],
          volume: :medium,
          priority: :primary,
          region: :neptune_system
        }
      when :venus_development_corporation
        # Venus: Sulfuric acid, CO2 processing
        opportunities << {
          resource: :sulfuric_acid,
          partners: [:earth_development_corporation, :mars_development_corporation],
          volume: :low,
          priority: :secondary,
          region: :inner_solar
        }
      when :jupiter_development_corporation
        # Jupiter system: Metallic hydrogen, helium-3
        opportunities << {
          resource: :helium_3,
          partners: [:earth_development_corporation, :mars_development_corporation],
          volume: :low,
          priority: :primary,
          region: :jupiter_system
        }
      end

      # Add regional coordination opportunities based on alignment
      if alignment != :independent
        opportunities << {
          resource: :regional_coordination,
          partners: [alignment],
          volume: :variable,
          priority: :strategic,
          region: region
        }
      end

      opportunities
    end

    def determine_settlement_focus(dc_type, world_analysis)
      # Map DC types to settlement focus for naming and planning
      case dc_type.to_s
      when /industrial|manufacturing/
        :industrial
      when /mining|extraction|resource/
        :mining
      when /research|science|laboratory/
        :research
      when /military|defense|security/
        :military
      when /corporate|trade|commerce/
        :corporate
      when /ceres|pallas|vesta|hygiea/
        :asteroid
      when /titan|europa|ganymede|callisto|io|rhea|iapetus|dione|tethys|enceladus|mimas/
        :gas_giant_moon
      when /triton|nereid|proteus|larissa|galatea|despina|thalassa|naiad/
        :ice_giant_moon
      else
        # Default based on world analysis
        if world_analysis[:atmospheric_resources]&.dig(:co2, :abundance).to_f > 0.3
          :industrial # Good for CO2-based industries
        elsif world_analysis[:surface_resources]&.dig(:water_ice, :abundance).to_f > 0.2
          :mining # Good for ice mining
        else
          :neutral
        end
      end
    end

    def handle_critical_issues(issues)
      # Handle most critical issue first
      critical_issue = issues.max_by { |i| priority_score(i) }

      case critical_issue[:type]
      when :life_support
        { action: :emergency_procurement, resource: critical_issue[:resources].first, reason: "life_support_critical" }
      when :atmospheric
        { action: :atmospheric_maintenance, reason: "atmospheric_critical" }
      when :debt
        { action: :debt_repayment, amount: critical_issue[:amount], reason: "debt_critical" }
      end
    end

    def handle_operational_needs(needs)
      # Handle highest priority operational need
      need = needs.max_by { |n| operational_priority_score(n) }

      case need[:type]
      when :resource_procurement
        { action: :resource_procurement, resource: need[:resource], amount: need[:amount], reason: "resource_shortage" }
      when :construction
        { action: :construction, facility: need[:facility], reason: "infrastructure_needed" }
      when :market_stabilization
        case need[:action]
        when :provide_essential
          { action: :market_stabilization, subaction: :provide_essential, item: need[:item], amount: need[:amount], reason: need[:reason] }
        when :produce_item
          { action: :market_stabilization, subaction: :produce_item, item: need[:item], amount: need[:amount], reason: "market_shortage" }
        when :import_item
          { action: :market_stabilization, subaction: :import_item, item: need[:item], amount: need[:amount], source: need[:source], reason: "market_shortage" }
        end
      end
    end

    def load_trained_patterns
      patterns_dir = GalaxyGame::Paths::AI_SETTLEMENT_PATTERNS_PATH
      patterns = {}

      if Dir.exist?(patterns_dir)
        Dir.glob("#{patterns_dir}/*.json").each do |pattern_file|
          begin
            pattern_data = JSON.parse(File.read(pattern_file)).deep_symbolize_keys
            pattern_key = File.basename(pattern_file, '.json').to_sym
            patterns[pattern_key] = pattern_data
          rescue JSON::ParserError => e
            Rails.logger.warn "[OperationalManager] Failed to parse pattern file #{pattern_file}: #{e.message}"
          end
        end
      else
        Rails.logger.warn "[OperationalManager] No settlement patterns directory found"
      end

      Rails.logger.info "[OperationalManager] Loaded #{patterns.keys.count} settlement patterns"
      patterns
    end

    def find_expansion_pattern
      return nil if @patterns.empty?

      # Find patterns that match current settlement capabilities
      suitable_patterns = @patterns.select do |id, pattern|
        pattern_suitable_for_expansion?(pattern)
      end

      # Return highest-scoring pattern
      suitable_patterns.max_by { |id, pattern| pattern_score(pattern) }
    end

    def pattern_suitable_for_expansion?(pattern)
      # Check if settlement has required capabilities
      economic_model = pattern[:economic_model] || {}
      equipment = pattern[:equipment_requirements] || {}

      # Must have positive economic model and equipment requirements
      economic_model[:estimated_gcc_cost].present? && equipment[:total_unit_count].to_i > 0
    end

    def pattern_score(pattern)
      # Score based on ISRU ratio, equipment completeness, and world compatibility
      economic_model = pattern[:economic_model] || {}
      equipment = pattern[:equipment_requirements] || {}

      isru_score = economic_model[:local_production_ratio].to_f * 50
      equipment_score = [equipment[:total_unit_count].to_i, 50].min

      # Add world compatibility score
      validator = AIManager::PatternValidator.new(@settlement.celestial_body&.data || @settlement.celestial_body)
      world_compatibility = validator.assess_world_compatibility(pattern)
      world_score = world_compatibility[:score] * 30

      isru_score + equipment_score + world_score
    end

    # Helper methods for critical checks
    def life_support_critical?
      # Check oxygen, water, food levels
      critical_resources = [:oxygen, :water, :food]
      critical_resources.any? { |resource| resource_level(resource) < critical_threshold(resource) }
    end

    def atmospheric_critical?
      # Check atmospheric stability
      atmospheric_stability < 0.8
    end

    def debt_critical?
      outstanding_debt > settlement_funds * 0.5
    end

    def settlement_stable?
      !life_support_critical? && !debt_critical? && resource_levels_adequate?
    end

    def expansion_feasible?
      settlement_stable? && funds_available_for_expansion?
    end

    def scouting_feasible?
      # Scouting requires fewer resources than full expansion
      settlement_stable? && funds_available_for_scouting?
    end

    # Priority scoring
    def priority_score(issue)
      case issue[:type]
      when :life_support then 1000
      when :atmospheric then 900
      when :debt then 800
      else 0
      end
    end

    def operational_priority_score(need)
      case need[:type]
      when :resource_procurement then 500
      when :construction then 300
      else 0
      end
    end

    # Logging
    def log_decision(decision, category)
      @decision_log << {
        timestamp: Time.current,
        category: category,
        decision: decision
      }

      Rails.logger.info "[OperationalManager] Decision made: #{decision[:action]} (#{decision[:reason]})"
    end

    # Placeholder methods - would be implemented based on actual settlement model
    def critical_resources
      [:oxygen, :water, :food].select { |r| resource_level(r) < critical_threshold(r) }
    end

    def resource_level(resource)
      # Placeholder - actual implementation would check settlement resources
      50 # Default adequate level
    end

    def critical_threshold(resource)
      20 # 20% is critical
    end

    def atmospheric_stability
      0.9 # Placeholder
    end

    def outstanding_debt
      0 # Placeholder
    end

    def settlement_funds
      100000 # Placeholder
    end

    def resource_shortage
      nil # Placeholder
    end

    def construction_needs
      nil # Placeholder
    end

    def resource_levels_adequate?
      true # Placeholder
    end

    def funds_available_for_expansion?
      true # Placeholder
    end

    # Action handlers
    def handle_emergency_procurement(decision)
      # Create emergency mission for players
      EmergencyMissionService.create_emergency_mission(
        settlement,
        decision[:resource]
      )
    end

    def handle_resource_procurement(decision)
      # Use procurement service
      ProcurementService.procure_resource(
        settlement,
        decision[:resource],
        decision[:amount]
      )
    end

    def handle_construction(decision)
      # Use construction service
      ConstructionService.build_facility(
        settlement,
        decision[:facility]
      )
    end

    def handle_expansion(decision)
      # Use pattern to guide expansion
      pattern = @patterns[decision[:pattern].to_sym]
      ExpansionService.expand_with_pattern(settlement, pattern)
    end

    def handle_scouting(decision)
      # Execute wormhole scouting mission
      scouting_service = AIManager::WormholeScoutingService.new(current_system: 'sol')
      result = scouting_service.execute_scouting_mission(decision[:target_system])

      if result[:status] == :success
        Rails.logger.info "[OperationalManager] Scouting mission to #{decision[:target_system]} completed successfully"

        # Record the scouting results for future decision making
        record_scouting_results(result)

        # If the system warrants investment, this will inform future expansion decisions
        if result[:recommendation][:invest]
          Rails.logger.info "[OperationalManager] System #{decision[:target_system]} recommended for investment: #{result[:recommendation][:reason]}"
        end
      else
        Rails.logger.error "[OperationalManager] Scouting mission to #{decision[:target_system]} failed: #{result[:reason]}"
      end

      result
    end

    def handle_debt_repayment(decision)
      # Use financial service
      FinancialService.repay_debt(settlement, decision[:amount])
    end

    def capture_settlement_context
      # Capture current settlement state for learning
      {
        oxygen_level: settlement_oxygen_level,
        water_level: settlement_water_level,
        food_level: settlement_food_level,
        debt_level: settlement_debt_level,
        construction_queue_size: settlement_construction_queue_size,
        available_resources: settlement_available_resources,
        isru_capability: settlement_isru_capability,
        timestamp: Time.current
      }
    rescue
      # Fallback if settlement methods don't exist yet
      {}
    end

    def record_decision_with_context(decision, context, category)
      decision_record = @performance_tracker.record_decision(decision, context)
      @last_decision = decision_record
      log_decision(decision, category)
      decision_record
    end

    def apply_adaptation_to_decision(decision, adaptation)
      adapted_decision = decision.dup
      adapted_decision[:adapted_from] = adaptation[:recommended_action]
      adapted_decision[:adaptation_confidence] = adaptation[:confidence]
      adapted_decision[:adaptation_reason] = adaptation[:adaptation_reason]

      # Apply specific adaptations based on learned rules
      case adaptation[:recommended_action]
      when :increase_resource_buffers
        adapted_decision[:amount] = (adapted_decision[:amount] * 1.5).round if adapted_decision[:amount]
      when :prefer_alternative_procurement
        adapted_decision[:use_emergency_mission] = true
      end

      adapted_decision
    end

    # Placeholder methods for settlement state - these would be replaced with real settlement model calls
    def settlement_oxygen_level
      75 # Placeholder
    end

    def settlement_water_level
      80 # Placeholder
    end

    def settlement_food_level
      85 # Placeholder
    end

    def settlement_debt_level
      10000 # Placeholder
    end

    def settlement_construction_queue_size
      0 # Placeholder
    end

    def settlement_available_resources
      { oxygen: 200, water: 300, food: 400 } # Placeholder
    end

    def settlement_isru_capability
      0.7 # Placeholder
    end

    def funds_available_for_scouting?
      # Scouting costs less than full expansion
      settlement_funds > 10000  # 10k GCC for scouting wormhole
    end

    def record_scouting_results(scouting_result)
      # Record scouting results for future decision making
      # This could be stored in a database or used for learning
      Rails.logger.info "[OperationalManager] Recorded scouting results for #{scouting_result[:system_data]['name']}: #{scouting_result[:recommendation]}"

      # Store in performance tracker for learning
      @performance_tracker.record_scouting_outcome(scouting_result) if @performance_tracker.respond_to?(:record_scouting_outcome)
    end
  end
end