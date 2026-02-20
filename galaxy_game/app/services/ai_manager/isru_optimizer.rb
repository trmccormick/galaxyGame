# app/services/ai_manager/isru_optimizer.rb
module AIManager
  class IsruOptimizer
    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Optimize ISRU (In-Situ Resource Utilization) priorities for settlement
    def optimize_isru_priorities(target_system, settlement_plan)
      Rails.logger.info "[ISRUOptimizer] Optimizing ISRU priorities for #{target_system[:identifier]}"

      # Analyze available local resources
      resource_analysis = analyze_local_resources(target_system)

      # Calculate ISRU opportunity scores
      opportunity_scores = calculate_opportunity_scores(resource_analysis, settlement_plan)

      # Generate prioritized ISRU roadmap
      isru_roadmap = generate_isru_roadmap(opportunity_scores, settlement_plan)

      # Calculate economic impact
      economic_impact = calculate_economic_impact(isru_roadmap, settlement_plan)

      {
        resource_analysis: resource_analysis,
        opportunity_scores: opportunity_scores,
        isru_roadmap: isru_roadmap,
        economic_impact: economic_impact,
        implementation_priority: determine_implementation_priority(isru_roadmap)
      }
    end

    # Prioritize ISRU opportunities based on value and feasibility
    def prioritize_isru_opportunities(target_system, settlement_requirements)
      Rails.logger.info "[ISRUOptimizer] Prioritizing ISRU opportunities"

      opportunities = identify_isru_opportunities(target_system)

      # Score each opportunity
      scored_opportunities = opportunities.map do |opportunity|
        score_opportunity(opportunity, settlement_requirements, target_system)
      end

      # Sort by priority score
      scored_opportunities.sort_by { |opp| -opp[:priority_score] }
    end

    private

    def analyze_local_resources(target_system)
      resources = target_system[:resource_profile] || {}
      environmental = target_system[:environmental_data] || {}

      analysis = {
        water_ice: {
          available: (resources[:water_ice] || 0) > 50,
          quantity: resources[:water_ice] || 0,
          accessibility: calculate_accessibility(resources, :water_ice),
          extraction_complexity: :medium
        },
        regolith: {
          available: (resources[:regolith] || 0) > 200,
          quantity: resources[:regolith] || 0,
          accessibility: calculate_accessibility(resources, :regolith),
          extraction_complexity: :low
        },
        atmosphere: {
          available: environmental[:atmosphere_composition].present?,
          composition: environmental[:atmosphere_composition] || {},
          density: environmental[:atmospheric_density] || 0,
          extraction_complexity: environmental[:atmosphere_composition]&.key?('CO2') ? :medium : :high
        },
        minerals: {
          available: (resources[:minerals] || []).any?,
          types: resources[:minerals] || [],
          concentrations: resources[:mineral_concentrations] || {},
          extraction_complexity: :high
        },
        energy_resources: {
          solar: resources.dig(:energy_potential, :solar) || 0,
          geothermal: resources.dig(:energy_potential, :geothermal) || 0,
          nuclear: resources.dig(:energy_potential, :nuclear) || 0
        }
      }

      # Calculate overall resource richness score
      analysis[:richness_score] = calculate_richness_score(analysis)
      analysis[:isru_potential] = determine_isru_potential(analysis)

      analysis
    end

    def calculate_opportunity_scores(resource_analysis, settlement_plan)
      scores = {}

      # Water extraction opportunity
      if resource_analysis[:water_ice][:available]
        scores[:water_extraction] = {
          value_score: calculate_value_score(:water, settlement_plan),
          feasibility_score: calculate_feasibility_score(resource_analysis[:water_ice]),
          timeline_score: calculate_timeline_score(:water_extraction),
          priority_score: 0 # calculated below
        }
      end

      # Oxygen generation opportunity
      if resource_analysis[:atmosphere][:available] && resource_analysis[:atmosphere][:composition]['CO2']
        scores[:oxygen_generation] = {
          value_score: calculate_value_score(:oxygen, settlement_plan),
          feasibility_score: calculate_feasibility_score(resource_analysis[:atmosphere]),
          timeline_score: calculate_timeline_score(:oxygen_generation),
          priority_score: 0
        }
      end

      # Fuel production opportunity
      if resource_analysis[:water_ice][:available] && resource_analysis[:atmosphere][:available]
        scores[:fuel_production] = {
          value_score: calculate_value_score(:fuel, settlement_plan),
          feasibility_score: calculate_feasibility_score_combined(resource_analysis[:water_ice], resource_analysis[:atmosphere]),
          timeline_score: calculate_timeline_score(:fuel_production),
          priority_score: 0
        }
      end

      # Construction material production
      if resource_analysis[:regolith][:available]
        scores[:material_production] = {
          value_score: calculate_value_score(:materials, settlement_plan),
          feasibility_score: calculate_feasibility_score(resource_analysis[:regolith]),
          timeline_score: calculate_timeline_score(:material_production),
          priority_score: 0
        }
      end

      # Calculate final priority scores
      scores.each do |opportunity, data|
        data[:priority_score] = (data[:value_score] * 0.5) + (data[:feasibility_score] * 0.3) + (data[:timeline_score] * 0.2)
      end

      scores
    end

    def generate_isru_roadmap(opportunity_scores, settlement_plan)
      roadmap = {
        phase_1: [], # Immediate (0-3 months)
        phase_2: [], # Short-term (3-6 months)
        phase_3: [], # Medium-term (6-12 months)
        phase_4: []  # Long-term (1-2 years)
      }

      # Sort opportunities by priority
      sorted_opportunities = opportunity_scores.sort_by { |_, data| -data[:priority_score] }

      sorted_opportunities.each do |opportunity, data|
        phase = determine_implementation_phase(opportunity, data, settlement_plan)
        roadmap[phase] << {
          opportunity: opportunity,
          priority_score: data[:priority_score],
          estimated_cost: estimate_implementation_cost(opportunity),
          expected_benefits: estimate_benefits(opportunity, settlement_plan),
          timeline: phase_timeline(phase)
        }
      end

      roadmap
    end

    def calculate_economic_impact(isru_roadmap, settlement_plan)
      impact = {
        total_capital_investment: 0,
        annual_operational_savings: 0,
        import_reduction_percentage: 0,
        payback_period_months: 0,
        roi_percentage: 0
      }

      # Calculate total investment
      isru_roadmap.each do |phase, opportunities|
        opportunities.each do |opp|
          impact[:total_capital_investment] += opp[:estimated_cost]
        end
      end

      # Calculate annual savings from reduced imports
      base_import_cost = calculate_base_import_cost(settlement_plan)
      import_reduction = calculate_import_reduction(isru_roadmap)
      impact[:annual_operational_savings] = base_import_cost * import_reduction
      impact[:import_reduction_percentage] = import_reduction

      # Calculate payback period
      if impact[:annual_operational_savings] > 0
        impact[:payback_period_months] = (impact[:total_capital_investment] / impact[:annual_operational_savings] * 12).ceil
      end

      # Calculate ROI
      annual_revenue = calculate_isru_revenue(isru_roadmap)
      annual_costs = impact[:annual_operational_savings] + (impact[:total_capital_investment] * 0.1) # 10% maintenance
      net_benefit = annual_revenue - annual_costs

      if impact[:total_capital_investment] > 0
        impact[:roi_percentage] = ((net_benefit / impact[:total_capital_investment]) * 100).round(1)
      end

      impact
    end

    def determine_implementation_priority(isru_roadmap)
      # Determine overall implementation priority based on roadmap
      phase_1_count = isru_roadmap[:phase_1].size
      total_opportunities = isru_roadmap.values.flatten.size

      if phase_1_count >= 2 || total_opportunities >= 4
        :high
      elsif phase_1_count >= 1 || total_opportunities >= 2
        :medium
      else
        :low
      end
    end

    # Helper methods
    def calculate_accessibility(resources, resource_type)
      # Simplified accessibility calculation
      case resource_type
      when :water_ice
        resources[:surface_accessibility] == 'high' ? 0.9 : 0.6
      when :regolith
        0.95 # Usually highly accessible
      else
        0.5
      end
    end

    def calculate_richness_score(analysis)
      score = 0
      score += 2 if analysis[:water_ice][:available]
      score += 1 if analysis[:regolith][:available]
      score += 2 if analysis[:atmosphere][:available]
      score += 1 if analysis[:minerals][:available]
      score += 1 if analysis[:energy_resources][:solar] > 0.7
      score
    end

    def determine_isru_potential(analysis)
      case analysis[:richness_score]
      when 0..1 then :low
      when 2..3 then :medium
      when 4..5 then :high
      else :excellent
      end
    end

    def calculate_value_score(resource_type, settlement_plan)
      # Value scores based on settlement needs
      base_scores = {
        water: 0.9,
        oxygen: 0.95,
        fuel: 0.85,
        materials: 0.7
      }

      mission_multiplier = case settlement_plan[:mission_type]
                           when 'mining_outpost' then 1.2
                           when 'terraforming_base' then 1.3
                           when 'research_station' then 0.8
                           when 'orbital_harvesting' then 1.1
                           else 1.0
                           end

      (base_scores[resource_type] || 0.5) * mission_multiplier
    end

    def calculate_feasibility_score(resource_data)
      accessibility = resource_data[:accessibility] || 0.5
      complexity_penalty = case resource_data[:extraction_complexity]
                           when :low then 0.1
                           when :medium then 0.2
                           when :high then 0.4
                           else 0.3
                           end

      [accessibility - complexity_penalty, 0.1].max
    end

    def calculate_feasibility_score_combined(resource1, resource2)
      score1 = calculate_feasibility_score(resource1)
      score2 = calculate_feasibility_score(resource2)
      (score1 + score2) / 2.0
    end

    def calculate_timeline_score(opportunity_type)
      # Timeline scores (higher is better - faster implementation)
      timeline_scores = {
        water_extraction: 0.8,    # Can be implemented relatively quickly
        oxygen_generation: 0.6,   # Moderate timeline
        material_production: 0.7, # Good timeline
        fuel_production: 0.5      # Complex, longer timeline
      }

      timeline_scores[opportunity_type] || 0.5
    end

    def determine_implementation_phase(opportunity, data, settlement_plan)
      # Determine which phase this opportunity should be implemented in
      priority = data[:priority_score]

      case opportunity
      when :water_extraction
        priority > 0.7 ? :phase_1 : :phase_2
      when :oxygen_generation
        priority > 0.75 ? :phase_1 : :phase_2
      when :material_production
        priority > 0.6 ? :phase_2 : :phase_3
      when :fuel_production
        priority > 0.65 ? :phase_2 : :phase_4
      else
        :phase_3
      end
    end

    def estimate_implementation_cost(opportunity)
      base_costs = {
        water_extraction: 50000,
        oxygen_generation: 75000,
        material_production: 30000,
        fuel_production: 100000
      }

      base_costs[opportunity] || 50000
    end

    def estimate_benefits(opportunity, settlement_plan)
      # Estimate annual benefits in GCC
      benefit_estimates = {
        water_extraction: 25000,
        oxygen_generation: 35000,
        material_production: 15000,
        fuel_production: 50000
      }

      benefit_estimates[opportunity] || 20000
    end

    def phase_timeline(phase)
      timelines = {
        phase_1: '0-3 months',
        phase_2: '3-6 months',
        phase_3: '6-12 months',
        phase_4: '1-2 years'
      }

      timelines[phase] || 'TBD'
    end

    def calculate_base_import_cost(settlement_plan)
      # Base annual import cost for settlement
      personnel = settlement_plan.dig(:requirements, :personnel) || 6
      personnel * 30000 # GCC per person for imports
    end

    def calculate_import_reduction(isru_roadmap)
      # Calculate percentage reduction in imports
      implemented_opportunities = isru_roadmap.values.flatten.size
      reduction_per_opportunity = 0.15 # 15% reduction per ISRU capability

      [implemented_opportunities * reduction_per_opportunity, 0.8].min # Max 80% reduction
    end

    def calculate_isru_revenue(isru_roadmap)
      # Calculate revenue from ISRU products
      total_revenue = 0
      isru_roadmap.each do |phase, opportunities|
        opportunities.each do |opp|
          total_revenue += opp[:expected_benefits]
        end
      end

      total_revenue
    end

    def identify_isru_opportunities(target_system)
      opportunities = []
      resources = target_system[:resource_profile] || {}

      # Water extraction
      if (resources[:water_ice] || 0) > 100
        opportunities << {
          type: :water_extraction,
          resource: :water_ice,
          potential_yield: resources[:water_ice] * 0.8,
          complexity: :medium
        }
      end

      # Atmospheric processing
      environmental = target_system[:environmental_data] || {}
      if environmental[:atmosphere_composition]&.key?('CO2')
        opportunities << {
          type: :atmospheric_processing,
          resource: :co2,
          potential_yield: environmental[:atmospheric_density].to_f * 1000,
          complexity: :high
        }
      end

      # Regolith processing
      if (resources[:regolith] || 0) > 500
        opportunities << {
          type: :regolith_processing,
          resource: :regolith,
          potential_yield: resources[:regolith] * 0.9,
          complexity: :low
        }
      end

      opportunities
    end

    def score_opportunity(opportunity, settlement_requirements, target_system)
      base_score = case opportunity[:complexity]
                   when :low then 0.8
                   when :medium then 0.6
                   when :high then 0.4
                   else 0.5
                   end

      # Adjust based on settlement needs
      need_multiplier = calculate_need_multiplier(opportunity, settlement_requirements)

      # Adjust based on resource abundance
      abundance_multiplier = opportunity[:potential_yield] > 1000 ? 1.2 : 1.0

      opportunity.merge(
        priority_score: base_score * need_multiplier * abundance_multiplier,
        need_multiplier: need_multiplier,
        abundance_multiplier: abundance_multiplier
      )
    end

    def calculate_need_multiplier(opportunity, settlement_requirements)
      # Calculate how much this opportunity addresses settlement needs
      needs = settlement_requirements[:critical_resources] || []

      case opportunity[:type]
      when :water_extraction
        needs.include?(:water) ? 1.5 : 1.0
      when :atmospheric_processing
        needs.include?(:oxygen) || needs.include?(:fuel) ? 1.4 : 1.0
      when :regolith_processing
        needs.include?(:materials) ? 1.3 : 1.0
      else
        1.0
      end
    end
  end
end