# app/services/ai_manager/strategic_evaluator.rb
module AIManager
  class StrategicEvaluator
    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Main evaluation method - comprehensive strategic analysis
    def evaluate_system(system_data, settlement_context = nil)
      {
        system_classification: classify_system(system_data),
        strategic_value: calculate_strategic_value(system_data, settlement_context),
        risk_assessment: assess_colonization_risks(system_data),
        economic_forecast: forecast_economic_potential(system_data, settlement_context),
        expansion_priority: calculate_expansion_priority(system_data, settlement_context),
        development_timeline: estimate_development_timeline(system_data),
        resource_synergies: analyze_resource_synergies(system_data, settlement_context)
      }
    end

    # Classify systems into strategic categories
    def classify_system(system_data)
      tei_score = system_data[:tei_score] || 0
      resource_profile = system_data[:resource_profile] || {}
      wormhole_data = system_data[:wormhole_data] || {}

      # Prize World: TEI > 80%
      if tei_score > 80
        return {
          category: :prize_world,
          confidence: 0.95,
          description: "Exceptional terraformability with minimal development requirements",
          priority: :critical
        }
      end

      # Brown Dwarf Hub: Systems with brown dwarfs (high energy potential)
      star_data = system_data[:star_data] || {}
      if star_data[:primary_star]&.dig(:type_of_star)&.downcase&.include?('brown')
        return {
          category: :brown_dwarf_hub,
          confidence: 0.85,
          description: "Brown dwarf system offering unique energy and research opportunities",
          priority: :high
        }
      end

      # Wormhole Nexus: High connectivity
      if wormhole_data[:network_centrality].to_f > 0.7
        return {
          category: :wormhole_nexus,
          confidence: 0.8,
          description: "Strategic wormhole hub for interstellar logistics",
          priority: :high
        }
      end

      # Resource World: High resource scores
      resource_score = (resource_profile[:metal_richness] || 0) +
                      (resource_profile[:volatile_availability] || 0) +
                      (resource_profile[:rare_earth_potential] || 0)

      if resource_score > 1.5
        return {
          category: :resource_world,
          confidence: 0.9,
          description: "Rich in critical resources for industrial development",
          priority: :high
        }
      end

      # Frontier World: Moderate potential
      if tei_score > 40 || resource_score > 0.8
        return {
          category: :frontier_world,
          confidence: 0.6,
          description: "Moderate development potential with reasonable investment",
          priority: :medium
        }
      end

      # Marginal World: Low potential
      {
        category: :marginal_world,
        confidence: 0.4,
        description: "Limited strategic value, high development costs",
        priority: :low
      }
    end

    # Calculate comprehensive strategic value
    def calculate_strategic_value(system_data, settlement_context = nil)
      base_score = 0.0

      # TEI contribution (40%)
      tei_score = system_data[:tei_score] || 0
      base_score += (tei_score / 100.0) * 0.4

      # Resource richness (30%)
      resource_profile = system_data[:resource_profile] || {}
      resource_score = (resource_profile[:metal_richness] || 0) +
                      (resource_profile[:volatile_availability] || 0) +
                      (resource_profile[:rare_earth_potential] || 0)
      base_score += [resource_score / 3.0, 1.0].min * 0.3

      # Connectivity bonus (15%)
      wormhole_data = system_data[:wormhole_data] || {}
      connectivity_score = wormhole_data[:network_centrality] || 0
      base_score += connectivity_score * 0.15

      # Energy potential (10%)
      energy_profile = resource_profile[:energy_potential] || {}
      energy_score = (energy_profile[:solar] || 0) +
                    (energy_profile[:geothermal] || 0) +
                    (energy_profile[:fusion_fuel] || 0)
      base_score += [energy_score / 3.0, 1.0].min * 0.1

      # Settlement context modifiers
      if settlement_context
        base_score += apply_settlement_context_modifiers(system_data, settlement_context)
      end

      [base_score, 1.0].min
    end

    # Assess colonization risks
    def assess_colonization_risks(system_data)
      risks = []
      risk_score = 0.0

      tei_score = system_data[:tei_score] || 0
      resource_profile = system_data[:resource_profile] || {}

      # Low TEI risk
      if tei_score < 30
        risks << {
          type: :terraforming_difficulty,
          severity: :high,
          description: "Extreme terraforming challenges, high failure risk",
          mitigation_cost: :very_high
        }
        risk_score += 0.4
      elsif tei_score < 60
        risks << {
          type: :terraforming_difficulty,
          severity: :medium,
          description: "Significant terraforming investment required",
          mitigation_cost: :high
        }
        risk_score += 0.2
      end

      # Resource scarcity risk
      resource_score = (resource_profile[:metal_richness] || 0) +
                      (resource_profile[:volatile_availability] || 0)
      if resource_score < 0.5
        risks << {
          type: :resource_scarcity,
          severity: :medium,
          description: "Limited local resources, high import dependency",
          mitigation_cost: :medium
        }
        risk_score += 0.2
      end

      # Distance/connectivity risk
      wormhole_distance = system_data[:wormhole_distance] || 1
      if wormhole_distance > 2
        risks << {
          type: :logistical_challenge,
          severity: :medium,
          description: "Extended supply lines increase operational costs",
          mitigation_cost: :medium
        }
        risk_score += 0.15
      end

      {
        overall_risk: [risk_score, 1.0].min,
        risk_factors: risks,
        risk_mitigation_cost: calculate_risk_mitigation_cost(risks)
      }
    end

    # Forecast economic potential
    def forecast_economic_potential(system_data, settlement_context = nil)
      base_revenue = 0
      development_costs = 0
      timeline_years = 0

      classification = classify_system(system_data)
      tei_score = system_data[:tei_score] || 0
      resource_profile = system_data[:resource_profile] || {}

      case classification[:category]
      when :prize_world
        base_revenue = 500_000_000  # 500M GCC/year
        development_costs = 100_000_000  # 100M GCC initial
        timeline_years = 2
      when :resource_world
        base_revenue = 300_000_000  # 300M GCC/year
        development_costs = 150_000_000  # 150M GCC initial
        timeline_years = 3
      when :brown_dwarf_hub
        base_revenue = 400_000_000  # 400M GCC/year
        development_costs = 200_000_000  # 200M GCC initial
        timeline_years = 4
      when :wormhole_nexus
        base_revenue = 350_000_000  # 350M GCC/year
        development_costs = 120_000_000  # 120M GCC initial
        timeline_years = 3
      when :frontier_world
        base_revenue = 150_000_000  # 150M GCC/year
        development_costs = 80_000_000  # 80M GCC initial
        timeline_years = 5
      else # marginal_world
        base_revenue = 50_000_000  # 50M GCC/year
        development_costs = 50_000_000  # 50M GCC initial
        timeline_years = 7
      end

      # Apply settlement context modifiers
      if settlement_context
        base_revenue, development_costs = apply_economic_context_modifiers(
          base_revenue, development_costs, system_data, settlement_context
        )
      end

      # Calculate ROI
      annual_profit = base_revenue - (development_costs / timeline_years)
      roi_years = development_costs / base_revenue.to_f

      {
        projected_revenue: base_revenue,
        development_costs: development_costs,
        annual_profit: annual_profit,
        roi_timeline: roi_years,
        break_even_year: timeline_years,
        profitability_score: calculate_profitability_score(annual_profit, development_costs, timeline_years)
      }
    end

    # Calculate expansion priority
    def calculate_expansion_priority(system_data, settlement_context = nil)
      strategic_value = calculate_strategic_value(system_data, settlement_context)
      risk_assessment = assess_colonization_risks(system_data)
      economic_forecast = forecast_economic_potential(system_data, settlement_context)

      # Base priority from strategic value
      priority_score = strategic_value * 0.5

      # Economic potential modifier
      profitability = economic_forecast[:profitability_score]
      priority_score += profitability * 0.3

      # Risk penalty
      risk_penalty = risk_assessment[:overall_risk] * 0.2
      priority_score -= risk_penalty

      # Settlement context urgency
      if settlement_context
        urgency_modifier = calculate_urgency_modifier(system_data, settlement_context)
        priority_score += urgency_modifier
      end

      [priority_score, 1.0].min
    end

    private

    def apply_settlement_context_modifiers(system_data, settlement_context)
      modifier = 0.0

      # Resource complementarity
      settlement_resources = settlement_context[:resource_needs] || []
      system_resources = system_data[:resource_profile] || {}

      if settlement_resources[:critical]&.include?('energy') && system_resources[:energy_potential]
        modifier += 0.1
      end

      if settlement_resources[:needed]&.any? && system_resources[:metal_richness].to_f > 0.7
        modifier += 0.05
      end

      modifier
    end

    def calculate_risk_mitigation_cost(risks)
      total_cost = 0

      risks.each do |risk|
        case risk[:mitigation_cost]
        when :very_high
          total_cost += 100_000_000
        when :high
          total_cost += 50_000_000
        when :medium
          total_cost += 25_000_000
        when :low
          total_cost += 10_000_000
        end
      end

      total_cost
    end

    def apply_economic_context_modifiers(revenue, costs, system_data, settlement_context)
      # Apply synergies with existing settlements
      synergy_bonus = 0.1 # 10% bonus for network effects

      revenue = (revenue * (1 + synergy_bonus)).to_i
      costs = (costs * (1 - synergy_bonus)).to_i # Cost reduction

      [revenue, costs]
    end

    def calculate_profitability_score(annual_profit, development_costs, timeline_years)
      return 0 if annual_profit <= 0

      # Score based on profit margin and timeline
      profit_margin = annual_profit / development_costs.to_f
      timeline_penalty = [timeline_years / 10.0, 1.0].min

      score = profit_margin * (1 - timeline_penalty)
      [score, 1.0].min
    end

    def estimate_development_timeline(system_data)
      classification = classify_system(system_data)

      case classification[:category]
      when :prize_world
        { years: 2, phases: [:initial_survey, :terraforming, :settlement] }
      when :resource_world
        { years: 3, phases: [:resource_assessment, :infrastructure, :industrial_setup] }
      when :brown_dwarf_hub
        { years: 4, phases: [:energy_infrastructure, :research_setup, :specialized_development] }
      when :wormhole_nexus
        { years: 3, phases: [:connectivity_setup, :logistics_hub, :trade_network] }
      when :frontier_world
        { years: 5, phases: [:basic_infrastructure, :resource_development, :population_growth] }
      else
        { years: 7, phases: [:survival_setup, :minimal_development, :long_term_sustainability] }
      end
    end

    def analyze_resource_synergies(system_data, settlement_context)
      return [] unless settlement_context

      synergies = []
      settlement_needs = settlement_context[:resource_needs] || {}

      # Energy synergy
      if settlement_needs[:critical]&.include?('energy')
        energy_potential = system_data.dig(:resource_profile, :energy_potential)
        if energy_potential&.dig(:solar).to_f > 0.7
          synergies << {
            type: :energy_independence,
            benefit: :high,
            description: "Solar potential can eliminate energy dependency"
          }
        end
      end

      # Resource synergy
      if settlement_needs[:needed]&.any?
        metal_richness = system_data.dig(:resource_profile, :metal_richness).to_f
        if metal_richness > 0.8
          synergies << {
            type: :industrial_capacity,
            benefit: :high,
            description: "Rich metal deposits support industrial expansion"
          }
        end
      end

      synergies
    end

    def calculate_urgency_modifier(system_data, settlement_context)
      modifier = 0.0

      # Critical resource shortage increases urgency
      critical_needs = settlement_context.dig(:resource_needs, :critical) || []
      if critical_needs.any?
        resource_profile = system_data[:resource_profile] || {}
        if critical_needs.include?('energy') && resource_profile[:energy_potential]
          modifier += 0.2
        end
        if critical_needs.include?('water') && resource_profile[:volatile_availability].to_f > 0.6
          modifier += 0.15
        end
      end

      # Population pressure
      expansion_readiness = settlement_context[:expansion_readiness] || 0
      if expansion_readiness > 0.8
        modifier += 0.1
      end

      modifier
    end
  end
end
