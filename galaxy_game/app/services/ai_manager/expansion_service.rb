module AIManager
  class ExpansionService
    def self.expand_with_pattern(settlement, pattern)
      Rails.logger.info "[ExpansionService] Expanding settlement #{settlement.id} with pattern #{pattern[:pattern_id]}"

      # Validate pattern suitability
      return { status: :failed, reason: :pattern_not_suitable } unless pattern_suitable?(settlement, pattern)

      # Execute expansion phases
      execute_expansion_phases(settlement, pattern)

      { status: :success, pattern: pattern[:pattern_id] }
    end

    # Enhanced expansion with probe deployment and asteroid tug integration
    def self.expand_with_intelligence(target_system, settlement = nil)
      Rails.logger.info "[ExpansionService] Starting intelligent expansion for system #{target_system[:identifier]}"

      # Phase 0: Deploy probes for intelligence gathering
      probe_data = deploy_probes_and_analyze(target_system)

      # Phase 1: Generate settlement plan with asteroid tug integration
      settlement_plan = generate_enhanced_settlement_plan(probe_data, target_system)

      # Phase 2: Execute expansion if settlement exists, or prepare for new settlement
      if settlement
        execute_expansion_phases(settlement, settlement_plan)
      else
        prepare_new_settlement(settlement_plan)
      end

      { status: :success, plan: settlement_plan, probe_data: probe_data }
    end

    private

    def self.deploy_probes_and_analyze(target_system)
      probe_service = ProbeDeploymentService.new(target_system)
      probe_data = probe_service.deploy_scout_probes

      Rails.logger.info "[ExpansionService] Probe deployment complete. Data collected: #{probe_data[:data_types].join(', ')}"
      probe_data
    end

    def self.generate_enhanced_settlement_plan(probe_data, target_system)
      # Use probe data to inform settlement planning
      analysis = analyze_probe_data(probe_data, target_system)

      plan_generator = SettlementPlanGenerator.new(analysis, target_system)
      settlement_plan = plan_generator.generate_settlement_plan

      Rails.logger.info "[ExpansionService] Settlement plan generated: #{settlement_plan[:mission_type]} for #{settlement_plan[:target_body]}"
      settlement_plan
    end

    def self.analyze_probe_data(probe_data, target_system)
      # Analyze probe data to determine optimal settlement strategy
      findings = probe_data[:findings] || {}

      {
        target_body: determine_optimal_target(findings, target_system),
        strategy: determine_settlement_strategy(findings),
        roi_years: calculate_roi(findings),
        success_probability: calculate_success_probability(findings),
        economic_model: build_economic_model(findings),
        primary_characteristic: classify_system_characteristic(findings, target_system)
      }
    end

    def self.determine_optimal_target(findings, target_system)
      # Find the most promising target based on probe data and system data
      resource_data = findings[:resource_assessment] || {}
      threat_data = findings[:threat_assessment] || {}

      # Get all celestial bodies from the system, including nested moons
      all_bodies = []
      celestial_bodies = target_system['celestial_bodies'] || target_system[:celestial_bodies] || {}

      celestial_bodies.each do |category, bodies|
        if bodies.is_a?(Array)
          bodies.each do |body|
            all_bodies << body
            # Include moons from gas giants and ice giants
            moons = body['moons'] || body[:moons]
            if moons.is_a?(Array)
              moons.each { |moon| all_bodies << moon }
            end
          end
        end
      end

      # Prioritize based on resource availability and accessibility
      optimal = all_bodies.max_by do |body|
        score = 0
        # High value resources get highest priority
        score += 10 if (resource_data[:high_value_resources] || []).any? { |r| (body['resources'] || body[:resources] || []).include?(r) }
        # Any resources are valuable
        score += 5 if (body['resources'] || body[:resources])&.any?
        score += 5 if body['atmosphere'] || body[:atmosphere]
        score += 3 if (body['water_ice'] || body[:water_ice])&.positive?
        # Strongly prioritize moons and asteroids for tug operations
        score += 20 if (body['type'] || body[:type]) == 'moon'
        score += 15 if (body['type'] || body[:type]) == 'asteroid'
        score -= 2 if (threat_data[:radiation_levels] == 'high')
        score
      end

      system_id = target_system['identifier'] || target_system[:identifier] || 'UNKNOWN'
      optimal || all_bodies.first || { identifier: "#{system_id}-I", type: 'planet' }
    end

    def self.determine_settlement_strategy(findings)
      survey = findings[:system_survey] || {}
      resources = findings[:resource_assessment] || {}

      if (resources[:high_value_resources] || []).include?('rare_metals')
        'mining_outpost'
      elsif survey[:habitability_index].to_f > 0.7
        'terraforming_base'
      elsif survey[:terraformable_bodies].to_i > 0
        'research_station'
      elsif (resources[:high_value_resources] || []).include?('helium-3')
        'orbital_harvesting'
      else
        'general_settlement'
      end
    end

    def self.calculate_roi(findings)
      # Estimate ROI based on resource potential
      resources = findings[:resource_assessment] || {}
      survey = findings[:system_survey] || {}

      base_years = 15
      resource_bonus = resources[:total_resource_bodies].to_i * 2
      habitability_bonus = (survey[:habitability_index].to_f * 5).to_i
      base_years - [resource_bonus + habitability_bonus, 8].min
    end

    def self.calculate_success_probability(findings)
      # Calculate success probability based on various factors
      survey = findings[:system_survey] || {}
      threat = findings[:threat_assessment] || {}

      base_probability = 0.7

      # Adjust based on habitability and threats
      habitability_bonus = survey[:habitability_index].to_f * 0.2
      threat_penalty = threat[:overall_threat_level] == 'significant' ? 0.2 : 0.0

      [base_probability + habitability_bonus - threat_penalty, 0.95].min
    end

    def self.build_economic_model(findings)
      resources = findings[:resource_assessment] || {}
      survey = findings[:system_survey] || {}

      # Estimate costs and revenue based on findings
      base_cost = 50000
      resource_multiplier = resources[:total_resource_bodies].to_i + 1
      estimated_cost = base_cost * resource_multiplier

      annual_yield = survey[:habitability_index].to_f * 100000 + resources[:total_resource_bodies].to_i * 50000

      {
        estimated_cost: estimated_cost,
        projected_revenue: annual_yield,
        break_even_years: calculate_roi(findings)
      }
    end

    def self.classify_system_characteristic(findings, target_system)
      survey = findings[:system_survey] || {}

      terraformable = survey[:terraformable_bodies].to_i
      resource_rich = survey[:resource_rich_bodies].to_i

      if terraformable > 0 && resource_rich > 2
        :large_moon_with_resources
      elsif terraformable > 3
        :small_moons_with_belt
      elsif survey[:habitability_index].to_f > 0.8
        :atmospheric_planet_no_surface_access
      elsif resource_rich > 1
        :gas_giant_with_moons
      elsif survey[:total_bodies].to_i > 5
        :icy_moon_system
      else
        :standard_system
      end
    end

    def self.prepare_new_settlement(plan)
      Rails.logger.info "[ExpansionService] Preparing new settlement plan: #{plan[:mission_type]}"
      # Logic for preparing new settlement would go here
      { status: :prepared, plan: plan }
    end

    def self.pattern_suitable?(settlement, pattern)
      # Check if settlement capabilities match pattern requirements
      equipment = pattern[:equipment_requirements] || {}
      economic = pattern[:economic_model] || {}

      equipment[:total_unit_count].to_i > 0 &&
      economic[:estimated_gcc_cost].present? &&
      settlement_can_afford_expansion?(settlement, economic[:estimated_gcc_cost])
    end

    def self.execute_expansion_phases(settlement, pattern)
      # Execute deployment sequence from pattern
      sequence = pattern[:deployment_sequence] || []

      sequence.each do |phase|
        execute_phase(settlement, phase)
      end
    end

    def self.execute_phase(settlement, phase)
      Rails.logger.info "[ExpansionService] Executing phase: #{phase[:phase_name]}"
      # Phase execution logic would go here
    end

    def self.settlement_can_afford_expansion?(settlement, cost)
      settlement_funds(settlement) >= cost
    end

    def self.settlement_funds(settlement)
      100000 # Placeholder
    end
  end
end