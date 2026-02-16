# app/services/ai_manager/station_cost_benefit_analyzer.rb
module AIManager
  class StationCostBenefitAnalyzer
    attr_reader :shared_context

    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Main method to select optimal construction strategy based on cost-benefit analysis
    def select_optimal_strategy(construction_options, available_resources = {}, strategic_requirements = {})
      Rails.logger.info "[StationCostBenefitAnalyzer] Analyzing #{construction_options.length} construction options"

      # Analyze each option
      analyzed_options = construction_options.map do |option|
        analyze_construction_option(option, available_resources, strategic_requirements)
      end

      # Rank options by composite score
      ranked_options = rank_options_by_score(analyzed_options)

      # Select optimal strategy
      optimal_option = ranked_options.first

      Rails.logger.info "[StationCostBenefitAnalyzer] Selected optimal strategy: #{optimal_option[:option][:name]} with score #{optimal_option[:composite_score]}"

      {
        optimal_strategy: optimal_option[:option],
        analysis: optimal_option.except(:option),
        ranking: ranked_options.map { |ro| { name: ro[:option][:name], score: ro[:composite_score] } }
      }
    end

    # Analyze a single construction option
    def analyze_construction_option(option, available_resources, strategic_requirements)
      # Calculate financial metrics
      financial_analysis = calculate_financial_metrics(option, available_resources)

      # Calculate operational benefits
      operational_analysis = calculate_operational_benefits(option, strategic_requirements)

      # Calculate risk-adjusted returns
      risk_analysis = calculate_risk_adjustments(option, strategic_requirements)

      # Calculate strategic alignment
      strategic_analysis = calculate_strategic_alignment(option, strategic_requirements)

      # Calculate timeline efficiency
      timeline_analysis = calculate_timeline_efficiency(option, strategic_requirements)

      # Calculate composite score
      composite_score = calculate_composite_score(
        financial_analysis,
        operational_analysis,
        risk_analysis,
        strategic_analysis,
        timeline_analysis
      )

      {
        option: option,
        financial_analysis: financial_analysis,
        operational_analysis: operational_analysis,
        risk_analysis: risk_analysis,
        strategic_analysis: strategic_analysis,
        timeline_analysis: timeline_analysis,
        composite_score: composite_score,
        recommendation: generate_recommendation(composite_score, option)
      }
    end

    private

    # Financial analysis methods
    def calculate_financial_metrics(option, available_resources)
      capital_cost = option[:estimated_cost]
      construction_time = option[:construction_time]

      # Calculate net present value
      npv = calculate_npv(capital_cost, construction_time, option)

      # Calculate return on investment
      roi = calculate_roi(capital_cost, option)

      # Calculate break-even point
      break_even = calculate_break_even_point(capital_cost, option)

      # Calculate resource efficiency
      resource_efficiency = calculate_resource_efficiency(option, available_resources)

      # Calculate cost escalation risks
      cost_escalation = calculate_cost_escalation_risks(option)

      {
        capital_cost: capital_cost,
        npv: npv,
        roi: roi,
        break_even_months: break_even,
        resource_efficiency: resource_efficiency,
        cost_escalation_risk: cost_escalation,
        profitability_score: calculate_profitability_score(npv, roi, break_even)
      }
    end

    def calculate_npv(capital_cost, construction_time, option)
      # Simplified NPV calculation
      annual_benefits = estimate_annual_benefits(option)
      discount_rate = 0.08  # 8% discount rate
      construction_years = construction_time.to_f / 1.year.to_f

      npv = -capital_cost

      # Add benefits from year 1 onwards
      (1..20).each do |year|
        if year >= construction_years
          discounted_benefit = annual_benefits / ((1 + discount_rate) ** year)
          npv += discounted_benefit
        end
      end

      npv
    end

    def calculate_roi(capital_cost, option)
      annual_benefits = estimate_annual_benefits(option)
      roi = (annual_benefits / capital_cost) * 100 if capital_cost > 0

      roi || 0
    end

    def calculate_break_even_point(capital_cost, option)
      annual_benefits = estimate_annual_benefits(option)
      monthly_benefits = annual_benefits / 12.0

      break_even_months = capital_cost / monthly_benefits if monthly_benefits > 0
      break_even_months || Float::INFINITY
    end

    def calculate_resource_efficiency(option, available_resources)
      required_resources = option[:resource_requirements] || {}
      required_materials = required_resources[:materials] || {}

      efficiency_score = 1.0

      required_materials.each do |material, required_qty|
        available_qty = available_resources[material] || 0
        if available_qty > 0
          efficiency_ratio = [available_qty / required_qty.to_f, 2.0].min  # Cap at 200% efficiency
          efficiency_score *= efficiency_ratio
        else
          efficiency_score *= 0.1  # Penalty for unavailable resources
        end
      end

      efficiency_score
    end

    def calculate_cost_escalation_risks(option)
      base_risk = 0.05  # 5% base escalation risk

      # Adjust based on construction type
      case option[:construction_type]
      when :full_space_station
        base_risk *= 1.2  # Higher risk due to complexity
      when :asteroid_conversion
        base_risk *= 1.5  # Higher risk due to unknowns
      when :lunar_surface_station
        base_risk *= 1.1  # Moderate risk
      when :orbital_construction
        base_risk *= 1.3  # Orbital mechanics complexity
      when :hybrid_approach
        base_risk *= 1.4  # Coordination complexity
      end

      # Adjust based on construction time
      construction_months = option[:construction_time] / 1.month
      time_risk = construction_months / 12.0 * 0.1  # 10% additional risk per year

      base_risk + time_risk
    end

    def calculate_profitability_score(npv, roi, break_even_months)
      score = 0

      # NPV scoring
      if npv > 0
        score += 40
        score += 10 if npv > 100_000_000  # Bonus for highly profitable projects
      end

      # ROI scoring
      if roi > 10
        score += 30
        score += 10 if roi > 25  # Bonus for high ROI
      elsif roi > 5
        score += 15
      end

      # Break-even scoring
      if break_even_months < 24
        score += 30
        score += 10 if break_even_months < 12  # Bonus for quick break-even
      elsif break_even_months < 48
        score += 15
      end

      score
    end

    # Operational benefits analysis
    def calculate_operational_benefits(option, strategic_requirements)
      # Calculate capability fulfillment
      capability_fulfillment = calculate_capability_fulfillment(option, strategic_requirements)

      # Calculate operational efficiency
      operational_efficiency = calculate_operational_efficiency(option)

      # Calculate scalability potential
      scalability_potential = calculate_scalability_potential(option)

      # Calculate maintenance costs
      maintenance_costs = calculate_maintenance_costs(option)

      # Calculate operational lifetime
      operational_lifetime = calculate_operational_lifetime(option)

      {
        capability_fulfillment: capability_fulfillment,
        operational_efficiency: operational_efficiency,
        scalability_potential: scalability_potential,
        annual_maintenance_cost: maintenance_costs,
        operational_lifetime_years: operational_lifetime,
        net_operational_benefit: calculate_net_operational_benefit(option, maintenance_costs, operational_lifetime)
      }
    end

    def calculate_capability_fulfillment(option, strategic_requirements)
      required_capabilities = strategic_requirements[:capability_requirements] || []
      return 100 if required_capabilities.empty?

      fulfilled_count = required_capabilities.count do |capability|
        case option[:construction_type]
        when :full_space_station
          true  # Full stations can fulfill most capabilities
        when :asteroid_conversion
          [:isru_facilities, :storage_systems, :defensive_systems].include?(capability)
        when :lunar_surface_station
          [:isru_facilities, :research_facilities, :defensive_systems].include?(capability)
        when :orbital_construction
          [:defensive_systems, :sensor_arrays, :docking_facilities, :trade_facilities].include?(capability)
        when :hybrid_approach
          true  # Hybrid approaches can adapt
        end
      end

      (fulfilled_count / required_capabilities.length.to_f) * 100
    end

    def calculate_operational_efficiency(option)
      base_efficiency = 70  # Base efficiency score

      # Adjust based on construction type
      case option[:construction_type]
      when :full_space_station
        base_efficiency += 20  # Highly optimized systems
      when :asteroid_conversion
        base_efficiency += 5   # Some inefficiencies from conversion
      when :lunar_surface_station
        base_efficiency += 15  # Good resource access
      when :orbital_construction
        base_efficiency += 10  # Good logistics
      when :hybrid_approach
        base_efficiency += 25  # Best of multiple approaches
      end

      # Adjust based on scalability
      scalability_bonus = option[:scalability] == :high ? 10 : option[:scalability] == :medium ? 5 : 0
      base_efficiency += scalability_bonus

      base_efficiency.clamp(0, 100)
    end

    def calculate_scalability_potential(option)
      base_scalability = 50

      case option[:scalability]
      when :high
        base_scalability = 90
      when :medium
        base_scalability = 70
      when :low
        base_scalability = 40
      end

      # Adjust based on construction type
      case option[:construction_type]
      when :full_space_station
        base_scalability += 5
      when :hybrid_approach
        base_scalability += 10  # Can scale in multiple ways
      when :asteroid_conversion
        base_scalability -= 10  # Limited by asteroid size
      end

      base_scalability.clamp(0, 100)
    end

    def calculate_maintenance_costs(option)
      capital_cost = option[:estimated_cost]

      # Annual maintenance as percentage of capital cost
      maintenance_percentage = case option[:construction_type]
                              when :full_space_station
                                0.05  # 5% - well-designed systems
                              when :asteroid_conversion
                                0.08  # 8% - more complex maintenance
                              when :lunar_surface_station
                                0.06  # 6% - environmental factors
                              when :orbital_construction
                                0.04  # 4% - easier access
                              when :hybrid_approach
                                0.07  # 7% - multiple systems
                              else
                                0.06
                              end

      capital_cost * maintenance_percentage
    end

    def calculate_operational_lifetime(option)
      base_lifetime = 20  # Base 20 years

      # Adjust based on construction type
      case option[:construction_type]
      when :full_space_station
        base_lifetime += 10  # 30 years - designed for long life
      when :asteroid_conversion
        base_lifetime -= 5   # 15 years - structural concerns
      when :lunar_surface_station
        base_lifetime += 5   # 25 years - stable environment
      when :orbital_construction
        base_lifetime -= 2   # 18 years - orbital decay
      when :hybrid_approach
        base_lifetime += 8   # 28 years - redundant systems
      end

      # Adjust based on risk level
      case option[:risk_level]
      when :low
        base_lifetime += 5
      when :high
        base_lifetime -= 5
      end

      base_lifetime
    end

    def calculate_net_operational_benefit(option, maintenance_costs, operational_lifetime)
      annual_benefits = estimate_annual_benefits(option)
      total_maintenance = maintenance_costs * operational_lifetime

      (annual_benefits * operational_lifetime) - total_maintenance
    end

    # Risk analysis methods
    def calculate_risk_adjustments(option, strategic_requirements)
      risk_tolerance = strategic_requirements[:risk_tolerance] || :medium

      # Base risk score from option
      base_risk_score = case option[:risk_level]
                       when :low
                         20
                       when :medium
                         50
                       when :high
                         80
                       else
                         50
                       end

      # Adjust based on risk tolerance
      tolerance_adjustment = case risk_tolerance
                            when :low
                              1.5  # Increase risk penalty
                            when :medium
                              1.0  # No adjustment
                            when :high
                              0.7  # Reduce risk penalty
                            end

      adjusted_risk_score = base_risk_score * tolerance_adjustment

      # Calculate risk-adjusted NPV
      risk_adjusted_npv = calculate_risk_adjusted_npv(option, adjusted_risk_score)

      # Calculate risk mitigation costs
      risk_mitigation_costs = calculate_risk_mitigation_costs(option, adjusted_risk_score)

      {
        base_risk_score: base_risk_score,
        adjusted_risk_score: adjusted_risk_score,
        risk_tolerance: risk_tolerance,
        risk_adjusted_npv: risk_adjusted_npv,
        risk_mitigation_costs: risk_mitigation_costs,
        risk_adjusted_score: calculate_risk_adjusted_score(adjusted_risk_score, risk_adjusted_npv)
      }
    end

    def calculate_risk_adjusted_npv(option, risk_score)
      base_npv = calculate_npv(option[:estimated_cost], option[:construction_time], option)
      risk_penalty = (risk_score / 100.0) * base_npv * 0.3  # 30% penalty based on risk

      base_npv - risk_penalty
    end

    def calculate_risk_mitigation_costs(option, risk_score)
      capital_cost = option[:estimated_cost]
      mitigation_percentage = (risk_score / 100.0) * 0.15  # Up to 15% of capital cost

      capital_cost * mitigation_percentage
    end

    def calculate_risk_adjusted_score(risk_score, risk_adjusted_npv)
      # Convert risk score to 0-100 scale (lower risk is better)
      risk_penalty = risk_score

      # NPV bonus (higher NPV is better)
      npv_bonus = risk_adjusted_npv > 0 ? 50 : 0
      npv_bonus += 25 if risk_adjusted_npv > 50_000_000
      npv_bonus += 25 if risk_adjusted_npv > 100_000_000

      [100 - risk_penalty + npv_bonus, 0].max
    end

    # Strategic alignment analysis
    def calculate_strategic_alignment(option, strategic_requirements)
      purpose = strategic_requirements[:purpose]
      timeline_requirements = strategic_requirements[:timeline_requirements] || {}

      # Calculate purpose alignment
      purpose_alignment = calculate_purpose_alignment(option, purpose)

      # Calculate timeline alignment
      timeline_alignment = calculate_timeline_alignment(option, timeline_requirements)

      # Calculate capability alignment
      capability_alignment = calculate_capability_alignment(option, strategic_requirements)

      # Calculate overall strategic score
      strategic_score = (purpose_alignment + timeline_alignment + capability_alignment) / 3.0

      {
        purpose_alignment: purpose_alignment,
        timeline_alignment: timeline_alignment,
        capability_alignment: capability_alignment,
        strategic_score: strategic_score
      }
    end

    def calculate_purpose_alignment(option, purpose)
      # This would be calculated by the strategy service, but we'll use a simplified version
      case [option[:construction_type], purpose]
      when [:full_space_station, :wormhole_anchor]
        90
      when [:asteroid_conversion, :resource_processing]
        85
      when [:lunar_surface_station, :research_outpost]
        80
      when [:orbital_construction, :defensive_position]
        85
      when [:hybrid_approach, purpose]
        75  # Good general purpose alignment
      else
        60  # Moderate alignment for other combinations
      end
    end

    def calculate_timeline_alignment(option, timeline_requirements)
      construction_time = option[:construction_time]
      critical_timeline = timeline_requirements[:critical]
      optimal_timeline = timeline_requirements[:optimal]

      # Convert to comparable values (days)
      construction_days = construction_time.to_i / 86400.0
      critical_days = critical_timeline ? critical_timeline.to_i / 86400.0 : nil
      optimal_days = optimal_timeline ? optimal_timeline.to_i / 86400.0 : nil

      if critical_days && construction_days <= critical_days
        100
      elsif optimal_days && construction_days <= optimal_days
        80
      elsif critical_days && construction_days <= critical_days * 1.5
        60
      else
        40
      end
    end

    def calculate_capability_alignment(option, strategic_requirements)
      capability_fulfillment = calculate_capability_fulfillment(option, strategic_requirements)

      # Convert percentage to 0-100 score
      capability_fulfillment
    end

    # Timeline efficiency analysis
    def calculate_timeline_efficiency(option, strategic_requirements)
      construction_time = option[:construction_time]
      timeline_requirements = strategic_requirements[:timeline_requirements] || {}

      # Calculate efficiency relative to requirements
      optimal_time = timeline_requirements[:optimal] || construction_time
      critical_time = timeline_requirements[:critical] || (optimal_time * 1.5)

      if construction_time <= optimal_time
        efficiency = 100
      elsif construction_time <= critical_time
        # Linear interpolation between optimal and critical
        efficiency = 100 - ((construction_time - optimal_time) / (critical_time - optimal_time)) * 50
      else
        efficiency = 50 - ((construction_time - critical_time) / critical_time) * 50
      end

      efficiency = [efficiency, 0].max

      # Calculate time-value of benefits
      time_value_benefit = calculate_time_value_benefit(option, construction_time)

      {
        construction_efficiency: efficiency,
        time_value_benefit: time_value_benefit,
        overall_timeline_score: (efficiency + time_value_benefit) / 2.0
      }
    end

    def calculate_time_value_benefit(option, construction_time)
      # Benefits realized earlier are more valuable
      annual_benefits = estimate_annual_benefits(option)
      discount_rate = 0.08

      # Calculate present value of benefits starting at construction completion
      construction_years = construction_time.to_f / 1.year.to_f
      pv_benefits = 0

      (0..19).each do |year|
        benefit_year = construction_years + year
        discounted_benefit = annual_benefits / ((1 + discount_rate) ** benefit_year)
        pv_benefits += discounted_benefit
      end

      # Compare to benefits starting immediately
      immediate_pv = 0
      (0..19).each do |year|
        discounted_benefit = annual_benefits / ((1 + discount_rate) ** year)
        immediate_pv += discounted_benefit
      end

      # Return percentage of maximum possible value
      (pv_benefits / immediate_pv) * 100
    end

    # Composite scoring
    def calculate_composite_score(financial, operational, risk, strategic, timeline)
      weights = {
        financial: 0.30,    # 30% - Most important
        operational: 0.25,  # 25% - Very important
        risk: 0.20,         # 20% - Important
        strategic: 0.15,    # 15% - Moderately important
        timeline: 0.10      # 10% - Less important
      }

      # Extract and normalize relevant scores (ensure they're between 0-100)
      financial_score = [financial[:profitability_score] || 0, 100].min
      operational_score = [operational[:net_operational_benefit] > 0 ? 80 : 40, 100].min
      risk_score = [100 - (risk[:risk_adjusted_score] || 50), 100].min # Invert risk score
      strategic_score = [strategic[:strategic_score] || 50, 100].min
      timeline_score = [timeline[:overall_timeline_score] || 50, 100].min

      # Calculate weighted score
      composite = (
        financial_score * weights[:financial] +
        operational_score * weights[:operational] +
        risk_score * weights[:risk] +
        strategic_score * weights[:strategic] +
        timeline_score * weights[:timeline]
      )

      composite.round(2)
    end

    def rank_options_by_score(analyzed_options)
      analyzed_options.sort_by { |option| -option[:composite_score] }
    end

    def generate_recommendation(composite_score, option)
      if composite_score >= 80
        "Highly recommended - Excellent overall value"
      elsif composite_score >= 65
        "Recommended - Good balance of cost and benefits"
      elsif composite_score >= 50
        "Consider with modifications - Moderate value proposition"
      else
        "Not recommended - Poor cost-benefit ratio"
      end
    end

    # Helper methods
    def estimate_annual_benefits(option)
      # Simplified benefit estimation based on strategic purpose and construction type
      base_benefits = case option[:construction_type]
                     when :full_space_station
                       20_000_000  # High operational value
                     when :asteroid_conversion
                       15_000_000  # Resource processing value
                     when :lunar_surface_station
                       18_000_000  # Research and resource value
                     when :orbital_construction
                       22_000_000  # Strategic and trade value
                     when :hybrid_approach
                       25_000_000  # Combined benefits
                     else
                       10_000_000
                     end

      # Adjust based on capability score
      capability_multiplier = option[:capability_score] ? option[:capability_score] / 50.0 : 1.0
      base_benefits * capability_multiplier
    end
  end
end