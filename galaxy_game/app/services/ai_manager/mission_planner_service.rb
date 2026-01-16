module AIManager
  class MissionPlannerService
    attr_reader :pattern, :parameters, :results
    
    def initialize(pattern_name, parameters = {})
      @pattern = pattern_name
      @parameters = default_parameters.merge(parameters)
      @results = {}
      @target_location = AIManager::PatternTargetMapper.target_location(pattern_name)
      @earth = CelestialBodies::CelestialBody.find_by(identifier: 'earth')
    end
    
    def simulate
      # Run accelerated simulation
      @results = {
        timeline: calculate_timeline,
        resources: calculate_resource_requirements,
        costs: calculate_costs,
        sourcing_strategy: calculate_sourcing_strategy,
        player_revenue: calculate_player_revenue,
        planetary_changes: simulate_planetary_changes
      }
      
      @results
    end
    
    def create_contracts
      # Generate PlayerContract records from simulation results
      contracts = []
      
      @results[:resources][:by_year].each do |year, resources|
        resources.each do |resource_name, quantity|
          contracts << create_supply_contract(resource_name, quantity, year)
        end
      end
      
      contracts
    end
    
    def export_plan
      {
        pattern: @pattern,
        parameters: @parameters,
        results: @results,
        generated_at: Time.current,
        version: '1.0'
      }.to_json
    end
    
    private
    
    def default_parameters
      {
        tech_level: 'standard',
        timeline_years: 10,
        budget_gcc: 1_000_000,
        priority: 'balanced'
      }
    end
    
    def calculate_timeline
      base_years = @parameters[:timeline_years]
      
      {
        total_years: base_years,
        phases: estimate_phases(base_years),
        milestones: estimate_milestones(base_years)
      }
    end
    
    def calculate_resource_requirements
      # Load pattern-specific requirements
      pattern_data = load_pattern_data
      
      resources_by_year = {}
      total_resources = Hash.new(0)
      
      (1..@parameters[:timeline_years]).each do |year|
        year_resources = estimate_year_resources(year, pattern_data)
        resources_by_year[year] = year_resources
        
        year_resources.each do |resource, quantity|
          total_resources[resource] += quantity
        end
      end
      
      {
        by_year: resources_by_year,
        total: total_resources,
        peak_demand: calculate_peak_demand(resources_by_year)
      }
    end
    
    def calculate_costs
      resources = @results[:resources] || calculate_resource_requirements
      
      total_cost = 0
      cost_breakdown = {}
      total_transport_cost = 0
      
      resources[:total].each do |resource, quantity|
        # Use real market pricing with transport costs
        costing = calculate_total_delivered_cost(resource, quantity)
        
        cost_breakdown[resource] = {
          quantity: quantity,
          source: costing[:source],
          unit_cost: costing[:unit_cost],
          transport_cost_per_unit: costing[:transport_cost_per_unit],
          total_material_cost: costing[:total_material_cost],
          total_transport_cost: costing[:total_transport_cost],
          total: costing[:total],
          alternatives: costing[:alternatives]
        }
        
        total_cost += costing[:total]
        total_transport_cost += costing[:total_transport_cost]
      end
      
      {
        total_gcc: total_cost,
        breakdown: cost_breakdown,
        transport_cost_total: total_transport_cost,
        transport_cost_ratio: total_cost > 0 ? (total_transport_cost / total_cost * 100).round(2) : 0,
        contingency: total_cost * 0.15, # 15% contingency
        grand_total: total_cost * 1.15
      }
    end
    
    def calculate_player_revenue
      costs = @results[:costs] || calculate_costs
      
      # Player can earn 20-30% of total costs through supply contracts
      total_costs = costs[:grand_total]
      player_percentage = 0.25
      
      {
        total_opportunity_gcc: total_costs * player_percentage,
        contract_count: estimate_contract_count,
        average_contract_value: (total_costs * player_percentage) / estimate_contract_count,
        revenue_timeline: distribute_revenue_over_time(total_costs * player_percentage)
      }
    end
    
    def simulate_planetary_changes
      # This would integrate with TerraSim for actual calculations
      # For now, return estimated changes based on pattern
      
      case @pattern
      when 'mars-terraforming'
        {
          atmosphere: {
            pressure_change: '+15 kPa over 10 years',
            composition_change: 'CO2: -5%, N2: +3%, O2: +2%'
          },
          temperature: {
            average_change: '+5°C over 10 years',
            polar_change: '+8°C over 10 years'
          },
          water: {
            liquid_increase: '1.2 million cubic km released',
            ice_decrease: '800k cubic km melted'
          }
        }
      when 'venus-industrial'
        {
          cloud_layer: {
            extraction_rate: '10 million kg CO2/year',
            altitude_processing: '50-55km layer optimal'
          },
          production: {
            structural_carbon: '5 million kg/year',
            sulfuric_acid: '2 million kg/year'
          }
        }
      when 'titan-fuel'
        {
          methane_harvest: {
            rate: '50 million kg/year',
            lakes_tapped: 3
          },
          refining: {
            lh2_production: '10 million kg/year',
            carbon_byproduct: '40 million kg/year'
          }
        }
      else
        { note: 'Pattern-specific changes not available' }
      end
    end
    
    def load_pattern_data
      # Would load from app/data/missions/patterns/
      # For now, return basic structure
      {
        infrastructure: ['habitats', 'power', 'life_support'],
        materials: ['regolith', 'water_ice', 'metals'],
        equipment: ['excavators', 'refineries', 'transporters']
      }
    end
    
    def estimate_year_resources(year, pattern_data)
      # Simplified resource estimation - ramps up in early years, stabilizes later
      multiplier = [year * 0.5, 2.0].min
      
      {
        'regolith' => (10_000 * multiplier).to_i,
        'water_ice' => (5_000 * multiplier).to_i,
        'structural_panels' => (500 * multiplier).to_i,
        'power_modules' => (50 * multiplier).to_i
      }
    end
    
    def estimate_phases(years)
      [
        { name: 'Initial Landing', duration: (years * 0.1).ceil },
        { name: 'Base Establishment', duration: (years * 0.3).ceil },
        { name: 'Expansion', duration: (years * 0.4).ceil },
        { name: 'Production', duration: (years * 0.2).ceil }
      ]
    end
    
    def estimate_milestones(years)
      [
        { year: 1, milestone: 'First habitat operational' },
        { year: (years * 0.3).ceil, milestone: 'ISRU facility online' },
        { year: (years * 0.6).ceil, milestone: 'Production targets met' },
        { year: years, milestone: 'Mission complete' }
      ]
    end
    
    def calculate_peak_demand(resources_by_year)
      peak_year = nil
      peak_total = 0
      
      resources_by_year.each do |year, resources|
        year_total = resources.values.sum
        if year_total > peak_total
          peak_total = year_total
          peak_year = year
        end
      end
      
      { year: peak_year, total_units: peak_total }
    end
    
    def estimate_unit_cost(resource)
      # Fallback simplified pricing when market data unavailable
      case resource.downcase
      when /regolith/ then 10
      when /water/ then 50
      when /panel/ then 1000
      when /module/ then 5000
      else 100
      end
    end
    
    # ========== REAL MARKET PRICING METHODS ==========
    
    def calculate_total_delivered_cost(resource, quantity)
      source = determine_resource_source(resource)
      
      # Get base market price
      unit_cost = get_market_price(resource, source[:settlement])
      
      # Calculate transport cost
      transport_cost_per_unit = if source[:settlement]
        calculate_transport_cost(source[:settlement], resource)
      else
        0.0
      end
      
      total_material_cost = unit_cost * quantity
      total_transport_cost = transport_cost_per_unit * quantity
      total_cost = total_material_cost + total_transport_cost
      
      # Find alternatives
      alternatives = find_alternative_sources(resource, quantity, total_cost)
      
      {
        source: source[:name],
        source_type: source[:type],
        unit_cost: unit_cost.round(2),
        transport_cost_per_unit: transport_cost_per_unit.round(2),
        total_material_cost: total_material_cost.round(2),
        total_transport_cost: total_transport_cost.round(2),
        total: total_cost.round(2),
        alternatives: alternatives
      }
    end
    
    def determine_resource_source(resource)
      # Check if we can produce locally (ISRU)
      if can_produce_locally?(@target_location, resource)
        return {
          name: 'Local ISRU',
          type: 'local',
          settlement: nil,
          location: @target_location
        }
      end
      
      # Find nearby settlements that might supply
      nearby = find_nearby_settlements(@target_location, resource)
      if nearby.any?
        return {
          name: nearby.first.name || "Regional Supply",
          type: 'regional',
          settlement: nearby.first,
          location: nearby.first.celestial_body
        }
      end
      
      # Default to Earth import
      earth_settlement = Settlement::BaseSettlement.find_by(celestial_body: @earth)
      {
        name: 'Earth Import',
        type: 'import',
        settlement: earth_settlement,
        location: @earth
      }
    end
    
    def can_produce_locally?(location, resource)
      return false unless location
      
      # ISRU-capable resources based on location
      case location.identifier
      when 'mars'
        ['regolith', 'water_ice', 'co2', 'iron_oxide'].any? { |r| resource.downcase.include?(r) }
      when 'luna', 'moon'
        ['regolith', 'he3', 'oxygen'].any? { |r| resource.downcase.include?(r) }
      when 'titan'
        ['methane', 'ethane', 'nitrogen'].any? { |r| resource.downcase.include?(r) }
      when 'europa'
        ['water_ice', 'oxygen', 'hydrogen'].any? { |r| resource.downcase.include?(r) }
      when 'ceres'
        ['water_ice', 'regolith', 'carbonates'].any? { |r| resource.downcase.include?(r) }
      else
        false
      end
    end
    
    def find_nearby_settlements(target_location, resource)
      return [] unless target_location
      
      # Find settlements within reasonable transport distance
      # For simulation purposes, consider settlements on same body or nearby bodies
      Settlement::BaseSettlement.joins(:celestial_body)
        .where.not(celestial_body_id: nil)
        .limit(3)
    end
    
    def get_market_price(resource, settlement)
      # Try to get real market price
      if settlement
        begin
          price = Market::NpcPriceCalculator.calculate_ask(settlement, resource)
          return price if price && price > 0
        rescue => e
          Rails.logger.warn("Failed to calculate market price for #{resource}: #{e.message}")
        end
      end
      
      # Fallback to estimated cost
      estimate_unit_cost(resource)
    end
    
    def calculate_transport_cost(from_settlement, resource)
      return 0.0 unless from_settlement && @target_location
      return 0.0 if from_settlement.celestial_body_id == @target_location.id
      
      begin
        from_body = from_settlement.celestial_body&.identifier || 'earth'
        to_body = @target_location.identifier
        
        Logistics::TransportCostService.calculate_cost_per_kg(
          from: from_body,
          to: to_body,
          resource: resource
        )
      rescue => e
        Rails.logger.warn("Failed to calculate transport cost: #{e.message}")
        # Fallback: estimate based on distance
        estimate_transport_cost(from_settlement, @target_location)
      end
    end
    
    def estimate_transport_cost(from_settlement, to_location)
      # Simple distance-based estimate if service fails
      from_body = from_settlement.celestial_body
      return 100.0 unless from_body && to_location
      
      # Very rough estimate based on orbital relationships
      if from_body.identifier == 'earth'
        case to_location.identifier
        when 'luna', 'moon' then 50.0
        when 'mars' then 500.0
        when 'jupiter', 'europa' then 2000.0
        when 'saturn', 'titan' then 3000.0
        else 1000.0
        end
      else
        200.0 # Inter-planetary default
      end
    end
    
    def find_alternative_sources(resource, quantity, current_total_cost)
      alternatives = []
      
      # Try finding other settlements that could supply
      possible_sources = Settlement::BaseSettlement.joins(:celestial_body)
        .where.not(celestial_body_id: nil)
        .limit(5)
      
      possible_sources.each do |settlement|
        next if settlement.celestial_body_id == @target_location&.id
        
        unit_cost = get_market_price(resource, settlement)
        transport_cost = calculate_transport_cost(settlement, resource)
        alt_total = (unit_cost + transport_cost) * quantity
        
        if alt_total < current_total_cost
          savings = current_total_cost - alt_total
          alternatives << {
            source: settlement.name || settlement.celestial_body.name,
            total: alt_total.round(2),
            savings: savings.round(2),
            savings_percent: ((savings / current_total_cost) * 100).round(1)
          }
        end
      end
      
      alternatives.sort_by { |a| -a[:savings] }.first(3)
    end
    
    def calculate_sourcing_strategy
      costs = @results[:costs] || calculate_costs
      breakdown = costs[:breakdown]
      
      local_cost = 0.0
      regional_cost = 0.0
      import_cost = 0.0
      total_cost = costs[:total_gcc]
      
      breakdown.each do |resource, details|
        case details[:source_type] || details[:source]
        when 'local', 'Local ISRU'
          local_cost += details[:total]
        when 'regional', /Regional/
          regional_cost += details[:total]
        else
          import_cost += details[:total]
        end
      end
      
      {
        local_production: total_cost > 0 ? (local_cost / total_cost * 100).round(2) : 0,
        regional_supply: total_cost > 0 ? (regional_cost / total_cost * 100).round(2) : 0,
        earth_import: total_cost > 0 ? (import_cost / total_cost * 100).round(2) : 0,
        transport_cost_ratio: costs[:transport_cost_ratio],
        infrastructure_note: local_cost == 0 ? "No local infrastructure - all materials imported" : "Local ISRU active"
      }
    end
    
    def estimate_contract_count
      # Estimate based on timeline
      @parameters[:timeline_years] * 12 # Monthly contracts
    end
    
    def distribute_revenue_over_time(total_revenue)
      years = @parameters[:timeline_years]
      revenue_by_year = {}
      
      (1..years).each do |year|
        # Revenue ramps up over time
        multiplier = [year * 0.3, 1.0].min
        revenue_by_year[year] = (total_revenue / years) * multiplier
      end
      
      revenue_by_year
    end
    
    def create_supply_contract(resource_name, quantity, year)
      # This would create actual PlayerContract records
      # For now, return contract data structure
      {
        resource: resource_name,
        quantity: quantity,
        delivery_year: year,
        reward_gcc: quantity * estimate_unit_cost(resource_name) * 0.25
      }
    end
  end
end
