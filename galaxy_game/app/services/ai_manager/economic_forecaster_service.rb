module AIManager
  class EconomicForecasterService
    attr_reader :planner_results, :analysis
    
    def initialize(planner_results)
      @planner_results = planner_results
      @analysis = {}
    end
    
    def analyze
      @analysis = {
        demand_forecast: forecast_resource_demand,
        gcc_distribution: analyze_gcc_flow,
        bottlenecks: identify_bottlenecks,
        opportunities: identify_opportunities,
        risk_assessment: assess_risks,
        transport_analysis: analyze_transport_costs,
        cost_optimization: suggest_cost_optimizations
      }
      
      @analysis
    end
    
    def compare_scenarios(scenarios)
      # Compare multiple simulation results side-by-side
      comparison = {
        total_costs: {},
        player_revenue: {},
        efficiency_scores: {},
        recommendations: []
      }
      
      scenarios.each do |name, results|
        comparison[:total_costs][name] = results[:costs][:grand_total]
        comparison[:player_revenue][name] = results[:player_revenue][:total_opportunity_gcc]
        comparison[:efficiency_scores][name] = calculate_efficiency_score(results)
      end
      
      # Recommend best scenario
      best = comparison[:efficiency_scores].max_by { |_, score| score }
      comparison[:recommendations] << "#{best[0]} offers best overall efficiency (#{best[1].round(2)})"
      
      comparison
    end
    
    private
    
    def forecast_resource_demand
      resources = @planner_results[:resources]
      
      {
        total_demand: resources[:total],
        peak_demand: resources[:peak_demand],
        demand_curve: calculate_demand_curve(resources[:by_year]),
        critical_resources: identify_critical_resources(resources[:total])
      }
    end
    
    def analyze_gcc_flow
      costs = @planner_results[:costs]
      revenue = @planner_results[:player_revenue]
      
      total_gcc = costs[:grand_total]
      player_gcc = revenue[:total_opportunity_gcc]
      dc_gcc = total_gcc - player_gcc
      
      {
        total_project_cost: total_gcc,
        dc_expenditure: dc_gcc,
        player_earnings: player_gcc,
        dc_percentage: (dc_gcc / total_gcc * 100).round(2),
        player_percentage: (player_gcc / total_gcc * 100).round(2),
        economic_velocity: estimate_economic_velocity(total_gcc)
      }
    end
    
    def identify_bottlenecks
      resources = @planner_results[:resources]
      bottlenecks = []
      
      # Check for resource spikes
      resources[:by_year].each do |year, year_resources|
        year_resources.each do |resource, quantity|
          if quantity > (resources[:total][resource] / resources[:by_year].size) * 2
            bottlenecks << {
              resource: resource,
              year: year,
              quantity: quantity,
              severity: 'high',
              recommendation: "Consider spreading #{resource} demand across more years"
            }
          end
        end
      end
      
      # Check for concentrated demand periods
      if resources[:peak_demand][:total_units] > calculate_average_demand(resources) * 1.5
        bottlenecks << {
          year: resources[:peak_demand][:year],
          severity: 'medium',
          recommendation: "Year #{resources[:peak_demand][:year]} has very high total demand - consider timeline adjustment"
        }
      end
      
      bottlenecks
    end
    
    def identify_opportunities
      revenue = @planner_results[:player_revenue]
      resources = @planner_results[:resources]
      opportunities = []
      
      # High-value contract opportunities
      revenue[:revenue_timeline].each do |year, year_revenue|
        if year_revenue > revenue[:total_opportunity_gcc] / @planner_results[:timeline][:total_years] * 1.3
          opportunities << {
            type: 'high_revenue_year',
            year: year,
            value: year_revenue,
            description: "Year #{year} offers #{(year_revenue / 1000).round(1)}K GCC in contract opportunities"
          }
        end
      end
      
      # Resource arbitrage opportunities
      critical_resources = resources[:total].select { |_, qty| qty > 50_000 }
      critical_resources.each do |resource, quantity|
        opportunities << {
          type: 'bulk_discount',
          resource: resource,
          quantity: quantity,
          description: "Large #{resource} order (#{quantity} units) - negotiate bulk pricing"
        }
      end
      
      opportunities
    end
    
    def assess_risks
      costs = @planner_results[:costs]
      timeline = @planner_results[:timeline]
      
      risks = []
      
      # Cost overrun risk
      if costs[:contingency] < costs[:total_gcc] * 0.2
        risks << {
          category: 'financial',
          severity: 'medium',
          description: 'Contingency below 20% - risk of budget overrun',
          mitigation: 'Increase contingency to 20-25%'
        }
      end
      
      # Timeline risk
      if timeline[:total_years] < 5
        risks << {
          category: 'schedule',
          severity: 'high',
          description: 'Aggressive timeline may cause delays',
          mitigation: 'Add 2-3 years buffer for unforeseen challenges'
        }
      end
      
      # Resource concentration risk
      resources = @planner_results[:resources]
      if resources[:peak_demand][:total_units] > calculate_average_demand(resources) * 2
        risks << {
          category: 'logistics',
          severity: 'high',
          description: 'Peak demand spike in year ' + resources[:peak_demand][:year].to_s,
          mitigation: 'Stockpile resources in advance or spread demand'
        }
      end
      
      risks
    end
    
    def calculate_demand_curve(by_year_data)
      # Calculate trend: ramping up, steady, or declining
      years = by_year_data.keys.sort
      totals = years.map { |year| by_year_data[year].values.sum }
      
      # Simple linear regression to determine trend
      trend = if totals.last > totals.first * 1.2
        'increasing'
      elsif totals.last < totals.first * 0.8
        'decreasing'
      else
        'steady'
      end
      
      {
        trend: trend,
        start_demand: totals.first,
        end_demand: totals.last,
        average_demand: totals.sum / totals.size
      }
    end
    
    def identify_critical_resources(total_resources)
      # Resources in top 20% by quantity are critical
      threshold = total_resources.values.sort[-[total_resources.size / 5, 1].max]
      total_resources.select { |_, qty| qty >= threshold }
    end
    
    def calculate_efficiency_score(results)
      # Higher score = better value
      # Score based on: player revenue / total cost, timeline efficiency, risk level
      
      revenue_ratio = results[:player_revenue][:total_opportunity_gcc] / results[:costs][:grand_total]
      timeline_score = [10.0 / results[:timeline][:total_years], 1.0].min
      
      (revenue_ratio * 100) + (timeline_score * 10)
    end
    
    def estimate_economic_velocity(total_gcc)
      # How quickly GCC flows through the economy
      years = @planner_results[:timeline][:total_years]
      total_gcc / years # GCC per year
    end
    
    def calculate_average_demand(resources)
      total_units = resources[:total].values.sum
      total_units / resources[:by_year].size
    end
  end
end
    
    # ========== TRANSPORT COST ANALYSIS ==========
    
    def analyze_transport_costs
      costs = @planner_results[:costs]
      breakdown = costs[:breakdown] || {}
      
      high_transport_resources = []
      total_material_cost = 0.0
      total_transport_cost = 0.0
      
      breakdown.each do |resource, details|
        material_cost = details[:total_material_cost] || (details[:unit_cost] * details[:quantity])
        transport_cost = details[:total_transport_cost] || 0
        
        total_material_cost += material_cost
        total_transport_cost += transport_cost
        
        # Flag resources where transport > 50% of total cost
        resource_total = material_cost + transport_cost
        if resource_total > 0 && (transport_cost / resource_total) > 0.5
          high_transport_resources << {
            resource: resource,
            transport_percentage: ((transport_cost / resource_total) * 100).round(1),
            transport_cost: transport_cost.round(2),
            total_cost: resource_total.round(2),
            recommendation: "Consider local production or alternative sourcing"
          }
        end
      end
      
      {
        total_transport_cost: total_transport_cost.round(2),
        total_material_cost: total_material_cost.round(2),
        transport_percentage: total_material_cost > 0 ? 
          ((total_transport_cost / (total_material_cost + total_transport_cost)) * 100).round(2) : 0,
        high_transport_resources: high_transport_resources.sort_by { |r| -r[:transport_cost] },
        recommendation: transport_percentage_recommendation(total_transport_cost, total_material_cost + total_transport_cost)
      }
    end
    
    def transport_percentage_recommendation(transport_cost, total_cost)
      return "No transport costs" if transport_cost == 0
      
      percentage = (transport_cost / total_cost) * 100
      
      if percentage > 40
        "CRITICAL: Transport costs exceed 40% of total. Strong ROI for local infrastructure investment."
      elsif percentage > 25
        "HIGH: Consider building local production facilities to reduce transport burden."
      elsif percentage > 15
        "MODERATE: Transport costs are significant. Evaluate local production opportunities."
      else
        "LOW: Transport costs are reasonable for this mission profile."
      end
    end
    
    def suggest_cost_optimizations
      costs = @planner_results[:costs]
      breakdown = costs[:breakdown] || {}
      sourcing = @planner_results[:sourcing_strategy] || {}
      
      suggestions = []
      total_potential_savings = 0.0
      
      # Check for alternatives with savings
      breakdown.each do |resource, details|
        next unless details[:alternatives] && details[:alternatives].any?
        
        best_alternative = details[:alternatives].first
        suggestions << {
          resource: resource,
          current_cost: details[:total],
          alternative: best_alternative[:source],
          alternative_cost: best_alternative[:total],
          savings: best_alternative[:savings],
          savings_percent: best_alternative[:savings_percent],
          recommendation: "Switch to #{best_alternative[:source]} for #{best_alternative[:savings].round(0)} GCC savings"
        }
        
        total_potential_savings += best_alternative[:savings]
      end
      
      # Infrastructure investment recommendations
      infrastructure_suggestions = calculate_infrastructure_roi(breakdown, sourcing)
      
      {
        alternative_sourcing: suggestions.sort_by { |s| -s[:savings] }.first(5),
        total_potential_savings: total_potential_savings.round(2),
        infrastructure_investments: infrastructure_suggestions,
        optimization_priority: determine_optimization_priority(total_potential_savings, costs[:grand_total])
      }
    end
    
    def calculate_infrastructure_roi(breakdown, sourcing)
      suggestions = []
      
      # Calculate potential savings if local production was available
      import_cost = 0.0
      transport_cost = 0.0
      
      breakdown.each do |resource, details|
        if details[:source_type] == 'import' || details[:source]&.include?('Earth')
          import_cost += details[:total_material_cost] || 0
          transport_cost += details[:total_transport_cost] || 0
        end
      end
      
      if import_cost > 100_000 # Significant import costs
        # Estimate infrastructure build cost (rough approximation)
        infrastructure_cost = import_cost * 0.3 # 30% of import cost to build facility
        annual_savings = (import_cost + transport_cost) * 0.7 # 70% savings on materials
        
        if annual_savings > 0
          payback_years = (infrastructure_cost / annual_savings).round(1)
          
          suggestions << {
            type: 'local_production_facility',
            investment_required: infrastructure_cost.round(2),
            annual_savings: annual_savings.round(2),
            payback_period_years: payback_years,
            roi_percentage: ((annual_savings / infrastructure_cost) * 100).round(1),
            recommendation: payback_years < 5 ? 
              "STRONG ROI: Build local production (#{payback_years}yr payback)" :
              "Consider local production if mission extends beyond #{payback_years} years"
          }
        end
      end
      
      suggestions
    end
    
    def determine_optimization_priority(potential_savings, total_cost)
      savings_percentage = (potential_savings / total_cost) * 100
      
      if savings_percentage > 20
        "HIGH: Potential savings exceed 20% of total cost. Immediate optimization recommended."
      elsif savings_percentage > 10
        "MEDIUM: Notable optimization opportunities available. Review alternatives."
      elsif savings_percentage > 5
        "LOW: Minor optimization opportunities. Optional to pursue."
      else
        "MINIMAL: Current sourcing strategy appears optimal."
      end
    end
