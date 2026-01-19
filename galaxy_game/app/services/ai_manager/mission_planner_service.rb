module AIManager
  class MissionPlannerService
    attr_reader :pattern, :parameters, :results
    
    def initialize(pattern_name, parameters = {})
      @pattern = pattern_name
      @parameters = default_parameters.merge(parameters)
      @results = {}
      @target_location = AIManager::PatternTargetMapper.target_location(pattern_name)
      @earth = CelestialBodies::CelestialBody.where('LOWER(name) = ?', 'earth').first
      
      Rails.logger.info "[MissionPlanner] Pattern: #{pattern_name}"
      Rails.logger.info "[MissionPlanner] Target location: #{@target_location&.name || 'NONE'}"
      
      # Handle case where Earth doesn't exist in database
      unless @earth
        Rails.logger.warn "MissionPlannerService: Earth celestial body not found, using default values"
        @earth = OpenStruct.new(
          name: 'Earth',
          identifier: 'earth',
          distance_from_sun: 1.0,
          orbital_period: 365.25
        )
      end
      
      # Handle case where target location doesn't exist in database
      unless @target_location
        target_identifier = AIManager::PatternTargetMapper.target_identifier(pattern_name)
        Rails.logger.warn "MissionPlannerService: Target location '#{target_identifier}' not found, using default values"
        @target_location = OpenStruct.new(
          name: target_identifier&.titleize || 'Unknown',
          identifier: target_identifier || 'unknown',
          id: nil,
          distance_from_sun: 1.5, # Default distance
          orbital_period: 687 # Default period (Mars-like)
        )
      end
      
      # Initialize services
      @material_lookup = Lookup::MaterialLookupService.new
      Rails.logger.info "[MissionPlanner] MaterialLookupService initialized"
      
      @capability_service = if @target_location
        service = AIManager::PrecursorCapabilityService.new(@target_location)
        Rails.logger.info "[MissionPlanner] PrecursorCapabilityService initialized for #{@target_location.name}"
        Rails.logger.info "[MissionPlanner] Local resources: #{service.local_resources.inspect}"
        service
      else
        Rails.logger.warn "[MissionPlanner] No target location - capability service disabled"
        nil
      end
    end
    
    def simulate
      # Run accelerated simulation
      @results = {
        timeline: calculate_timeline,
        resources: calculate_resource_requirements,
        costs: calculate_costs,
        sourcing_strategy: calculate_sourcing_strategy,
        player_revenue: calculate_player_revenue,
        planetary_changes: simulate_planetary_changes,
        local_capabilities: summarize_local_capabilities  # NEW
      }
      
      Rails.logger.info "[MissionPlanner] Simulation complete"
      Rails.logger.info "[MissionPlanner] Local capabilities present: #{@results[:local_capabilities].present?}"
      
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
      precursor_total_savings = 0
      
      resources[:total].each do |resource, quantity|
        # Use real market pricing with transport costs
        costing = calculate_total_delivered_cost(resource, quantity)
        
        cost_breakdown[resource] = {
          quantity: quantity,
          source: costing[:source],
          source_type: costing[:source_type],
          chemical_formula: costing[:chemical_formula],
          unit_cost: costing[:unit_cost],
          transport_cost_per_unit: costing[:transport_cost_per_unit],
          total_material_cost: costing[:total_material_cost],
          total_transport_cost: costing[:total_transport_cost],
          total: costing[:total],
          alternatives: costing[:alternatives]
        }
        
        total_cost += costing[:total]
        total_transport_cost += costing[:total_transport_cost]
        precursor_total_savings += costing[:precursor_savings] || 0
      end
      
      {
        total_gcc: total_cost,
        breakdown: cost_breakdown,
        transport_cost_total: total_transport_cost,
        transport_cost_ratio: total_cost > 0 ? (total_transport_cost / total_cost * 100).round(2) : 0,
        contingency: total_cost * 0.15, # 15% contingency
        grand_total: total_cost * 1.15,
        precursor_total_savings: precursor_total_savings
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
      # Integrate with existing TerraSim system for realistic planetary modeling
      target_location = @target_location

      unless target_location
        Rails.logger.warn "[MissionPlanner] No target location found for pattern #{@pattern}, using default planetary changes"
        return default_planetary_changes
      end

      # Use TerraSim services for actual planetary simulation
      begin
        simulate_with_terrasim(target_location)
      rescue => e
        Rails.logger.error "[MissionPlanner] TerraSim integration failed: #{e.message}, falling back to estimates"
        default_planetary_changes
      end
    end

    private

    def simulate_with_terrasim(target_location)
      # Run accelerated TerraSim simulation for the mission duration
      simulation_years = @parameters[:timeline_years]

      # Create a temporary simulation context
      initial_state = capture_initial_state(target_location)
      final_state = run_terrasim_simulation(target_location, simulation_years)

      # Calculate changes
      calculate_state_changes(initial_state, final_state, simulation_years)
    end

    def capture_initial_state(celestial_body)
      return {} unless celestial_body

      state = {}
      if celestial_body.atmosphere
        state[:atmosphere] = {
          pressure: celestial_body.atmosphere.pressure,
          temperature: celestial_body.atmosphere.temperature,
          composition: celestial_body.atmosphere.gases.map { |g| [g.name, g.percentage] }.to_h
        }
      end

      if celestial_body.hydrosphere
        state[:hydrosphere] = {
          total_mass: celestial_body.hydrosphere.total_hydrosphere_mass,
          state_distribution: celestial_body.hydrosphere.state_distribution
        }
      end

      if celestial_body.biosphere
        state[:biosphere] = {
          habitable_ratio: celestial_body.biosphere.habitable_ratio,
          biodiversity_index: celestial_body.biosphere.biodiversity_index,
          life_forms_count: celestial_body.biosphere.life_forms.count
        }
      end

      state
    end

    def run_terrasim_simulation(celestial_body, years)
      return {} unless celestial_body

      # Use existing TerraSim BiosphereSimulationService
      service = TerraSim::BiosphereSimulationService.new(celestial_body)

      # Run simulation for equivalent days (simplified - real missions would have complex timelines)
      total_days = years * 365
      service.simulate(total_days)

      # Return final state
      capture_initial_state(celestial_body.reload)
    end

    def calculate_state_changes(initial_state, final_state, years)
      changes = {}

      # Atmospheric changes
      if initial_state[:atmosphere] && final_state[:atmosphere]
        initial_atm = initial_state[:atmosphere]
        final_atm = final_state[:atmosphere]

        changes[:atmosphere] = {
          pressure_change: format_change(final_atm[:pressure] - initial_atm[:pressure], 'bar', years),
          temperature_change: format_change(final_atm[:temperature] - initial_atm[:temperature], 'K', years),
          composition_changes: calculate_gas_changes(initial_atm[:composition], final_atm[:composition])
        }
      end

      # Hydrosphere changes
      if initial_state[:hydrosphere] && final_state[:hydrosphere]
        initial_hydro = initial_state[:hydrosphere]
        final_hydro = final_state[:hydrosphere]

        changes[:hydrosphere] = {
          mass_change: format_change(final_hydro[:total_mass] - initial_hydro[:total_mass], 'kg', years),
          state_distribution_changes: calculate_state_changes_hash(initial_hydro[:state_distribution], final_hydro[:state_distribution])
        }
      end

      # Biosphere changes
      if initial_state[:biosphere] && final_state[:biosphere]
        initial_bio = initial_state[:biosphere]
        final_bio = final_state[:biosphere]

        changes[:biosphere] = {
          habitability_change: format_change(final_bio[:habitable_ratio] - initial_bio[:habitable_ratio], '', years),
          biodiversity_change: format_change(final_bio[:biodiversity_index] - initial_bio[:biodiversity_index], '', years),
          species_count_change: final_bio[:life_forms_count] - initial_bio[:life_forms_count]
        }
      end

      changes
    end

    def calculate_gas_changes(initial_composition, final_composition)
      changes = {}
      all_gases = (initial_composition.keys + final_composition.keys).uniq

      all_gases.each do |gas|
        initial_pct = initial_composition[gas] || 0.0
        final_pct = final_composition[gas] || 0.0
        change = final_pct - initial_pct

        if change.abs > 0.001  # Only report significant changes
          changes[gas] = format_change(change, '%', @parameters[:timeline_years])
        end
      end

      changes
    end

    def calculate_state_changes_hash(initial_dist, final_dist)
      changes = {}
      all_states = (initial_dist.keys + final_dist.keys).uniq

      all_states.each do |state|
        initial_pct = initial_dist[state] || 0.0
        final_pct = final_dist[state] || 0.0
        change = final_pct - initial_pct

        if change.abs > 0.1  # Only report significant changes
          changes[state] = format_change(change, '%', @parameters[:timeline_years])
        end
      end

      changes
    end

    def format_change(delta, unit, years)
      if delta.abs < 0.001
        "No significant change"
      else
        sign = delta > 0 ? '+' : ''
        "#{sign}#{delta.round(3)}#{unit} over #{years} years"
      end
    end

    def default_planetary_changes
      # Fallback estimates when TerraSim integration fails
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
      Rails.logger.info "[MissionPlanner] Calculating cost for #{resource} (#{quantity} units)"
      
      # Get material data to determine actual chemical formula
      material_data = @material_lookup.find_material(resource)
      Rails.logger.info "[MissionPlanner] Material data found: #{material_data ? 'YES' : 'NO'}"
      
      chemical_formula = if material_data
        formula = @material_lookup.get_material_property(material_data, 'chemical_formula') || material_data['id']
        Rails.logger.info "[MissionPlanner] Chemical formula: #{formula}"
        formula
      else
        Rails.logger.warn "[MissionPlanner] No material data for #{resource}, using raw name"
        resource
      end
      
      # PRIORITY 1: Local production check
      if @capability_service
        can_produce = @capability_service.can_produce_locally?(chemical_formula)
        Rails.logger.info "[MissionPlanner] Can produce locally: #{can_produce}"
        
        if can_produce
          local_cost = calculate_local_production_cost(chemical_formula, material_data)
          Rails.logger.info "[MissionPlanner] Local cost: #{local_cost} GCC/kg"
          
          import_cost_for_comparison = calculate_earth_anchor_price(resource)[:total]
          
          return {
            source: "Local ISRU (#{@target_location.name})",
            source_type: 'local',
            chemical_formula: chemical_formula,
            unit_cost: local_cost,
            transport_cost_per_unit: 0.0,
            total_material_cost: local_cost * quantity,
            total_transport_cost: 0.0,
            total: local_cost * quantity,
            alternatives: [],
            precursor_savings: (import_cost_for_comparison - local_cost) * quantity,
            production_method: determine_production_method(chemical_formula)
          }
        end
      else
        Rails.logger.warn "[MissionPlanner] No capability service - skipping local check"
      end
      
      # PRIORITY 2: Regional NPC sources
      regional = find_best_regional_source(resource, quantity)
      if regional && regional[:total] < calculate_earth_anchor_price(resource)[:total] * quantity * 0.9
        return regional
      end
      
      # PRIORITY 3: Earth import
      Rails.logger.info "[MissionPlanner] Using Earth import for #{resource}"
      eap = calculate_earth_anchor_price(resource)
      Rails.logger.info "[MissionPlanner] EAP: material=#{eap[:material_cost]}, transport=#{eap[:transport_cost]}, total=#{eap[:total]}"
      
      total_import_cost = eap[:total] * quantity
      
      {
        source: 'Earth Import',
        source_type: 'import',
        chemical_formula: chemical_formula,
        unit_cost: eap[:material_cost],
        transport_cost_per_unit: eap[:transport_cost],
        total_material_cost: eap[:material_cost] * quantity,
        total_transport_cost: eap[:transport_cost] * quantity,
        total: total_import_cost,
        alternatives: find_alternative_sources(resource, quantity, total_import_cost),
        precursor_note: suggest_precursor_if_beneficial(chemical_formula, quantity, total_import_cost)
      }
    end
    
    def calculate_local_production_cost(resource, material_data = nil)
      # Get material data if not provided
      material_data ||= @material_lookup.find_material(resource)
      chemical_formula = if material_data
        @material_lookup.get_material_property(material_data, 'chemical_formula') || material_data['id']
      else
        resource
      end
      
      # Try EconomicConfig first
      maturity = :mature
      config_cost = EconomicConfig.local_production_cost(chemical_formula, maturity)
      return config_cost if config_cost
      
      # Use capability service to determine extraction complexity
      if @capability_service
        if @capability_service.precursor_enables?(:oxygen) && chemical_formula == 'O2'
          return 3.0
        elsif @capability_service.precursor_enables?(:water) && chemical_formula == 'H2O'
          return 10.0
        elsif @capability_service.precursor_enables?(:fuel) && ['CH4', 'H2'].include?(chemical_formula)
          return 8.0
        elsif @capability_service.precursor_enables?(:regolith_processing) && material_data
          return estimate_regolith_extraction_cost(chemical_formula, material_data)
        end
      end
      
      # Fallback estimates by formula
      case chemical_formula
      when 'CO2' then 0.5
      when 'H2O' then 10.0
      when 'O2' then 3.0
      when 'N2' then 2.0
      when 'CH4' then 8.0
      when 'H2' then 5.0
      when 'He3' then 50.0
      else 20.0
      end
    end
    
    def estimate_regolith_extraction_cost(formula, material_data)
      # Regolith composition varies by world
      # Cost depends on concentration and extraction complexity
      
      # Check material properties for extraction difficulty
      extraction_complexity = @material_lookup.get_material_property(material_data, 'extraction_complexity')
      energy_requirement = @material_lookup.get_material_property(material_data, 'energy_requirement')
      
      base_cost = case formula
      when 'SiO2' then 15.0
      when 'Al2O3' then 30.0
      when 'FeO', 'Fe2O3' then 25.0
      when 'TiO2' then 45.0
      when 'He3' then 50.0
      else 5.0
      end
      
      # Adjust for extraction complexity if available
      if extraction_complexity
        multiplier = case extraction_complexity.downcase
        when 'low' then 0.7
        when 'medium' then 1.0
        when 'high' then 1.5
        when 'extreme' then 2.0
        else 1.0
        end
        base_cost *= multiplier
      end
      
      base_cost
    end
    
    def determine_production_method(chemical_formula)
      return nil unless @capability_service
      
      capabilities = @capability_service.production_capabilities
      
      if capabilities[:atmosphere].include?(chemical_formula)
        'Atmospheric Processing'
      elsif capabilities[:surface].include?(chemical_formula)
        'Surface Extraction'
      elsif capabilities[:subsurface].include?(chemical_formula)
        'Subsurface Mining'
      elsif capabilities[:regolith].any? { |compound| compound.include?(chemical_formula) }
        'Regolith Processing'
      else
        'ISRU'
      end
    end
    
    def suggest_precursor_if_beneficial(resource, quantity, import_cost)
      return nil unless @target_location
      return nil if @capability_service  # Already has precursor
      
      # Create temporary capability service to check potential
      temp_service = AIManager::PrecursorCapabilityService.new(@target_location)
      
      if temp_service.can_produce_locally?(resource)
        estimated_local_cost = calculate_local_production_cost(resource) * quantity
        savings = import_cost - estimated_local_cost
        
        if savings > 100_000  # Significant savings threshold
          return {
            deployable: true,
            estimated_savings: savings.round(2),
            message: "Precursor deployment could save #{(savings / 1_000_000).round(1)}M GCC"
          }
        end
      end
      
      nil
    end
    
    def find_nearby_settlements(target_location, resource)
      return [] unless target_location
      
      # Find settlements within reasonable transport distance
      # For simulation purposes, consider settlements on same body or nearby bodies
      Settlement::BaseSettlement.joins(:location)
        .where.not(celestial_locations: { celestial_body_id: nil })
        .limit(3)
    end
    
    def find_best_regional_source(resource, quantity)
      # Find nearby settlements that might supply
      nearby = find_nearby_settlements(@target_location, resource)
      return nil if nearby.empty?
      
      settlement = nearby.first
      unit_cost = get_market_price(resource, settlement)
      transport_cost = calculate_transport_cost(settlement, resource)
      total_cost = (unit_cost + transport_cost) * quantity
      
      {
        source: settlement.name || "Regional Supply",
        source_type: 'regional',
        unit_cost: unit_cost,
        transport_cost_per_unit: transport_cost,
        total_material_cost: unit_cost * quantity,
        total_transport_cost: transport_cost * quantity,
        total: total_cost,
        alternatives: []
      }
    end
    
    def calculate_earth_anchor_price(resource)
      # Get Earth spot price from config
      earth_price = EconomicConfig.earth_spot_price(resource)
      
      unless earth_price
        earth_price = estimate_unit_cost(resource)
        Rails.logger.info "[MissionPlanner] Using estimated Earth price: #{earth_price} USD/kg"
      end
      
      # Apply refining factor
      refining_factor = EconomicConfig.refining_factor('default') || 1.0
      material_cost = earth_price * refining_factor
      
      # Calculate transport cost
      transport_cost = if @target_location
        begin
          cost = Logistics::TransportCostService.calculate_cost_per_kg(
            from: 'earth',
            to: @target_location.identifier,
            resource: resource
          )
          Rails.logger.info "[MissionPlanner] Transport cost calculated: #{cost} GCC/kg"
          cost
        rescue => e
          Rails.logger.error "[MissionPlanner] Transport calculation failed: #{e.message}"
          fallback = estimate_transport_cost_fallback(resource)
          Rails.logger.info "[MissionPlanner] Using fallback transport: #{fallback} GCC/kg"
          fallback
        end
      else
        # Fallback to game constant if no target location
        Rails.logger.warn "[MissionPlanner] No target location - using initial transport cost"
        GameConstants::INITIAL_TRANSPORTATION_COST_PER_KG
      end
      
      result = {
        material_cost: material_cost.round(2),
        transport_cost: transport_cost.round(2),
        total: (material_cost + transport_cost).round(2)
      }
      
      Rails.logger.info "[MissionPlanner] EAP result: #{result.inspect}"
      result
    rescue => e
      Rails.logger.error "[MissionPlanner] EAP calculation failed: #{e.message}"
      estimated = estimate_unit_cost(resource)
      {
        material_cost: estimated * 0.3,
        transport_cost: estimated * 0.7,
        total: estimated
      }
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
      return 0.0 if from_settlement.location.celestial_body_id == @target_location.id
      
      begin
        from_body = from_settlement.location.celestial_body&.identifier || 'earth'
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
      from_body = from_settlement.location.celestial_body
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
      possible_sources = Settlement::BaseSettlement.joins(location: :celestial_body)
        .where.not(celestial_locations: { celestial_body_id: nil })
        .limit(5)
      
      possible_sources.each do |settlement|
        next if settlement.location.celestial_body_id == @target_location&.id
        
        unit_cost = get_market_price(resource, settlement)
        transport_cost = calculate_transport_cost(settlement, resource)
        alt_total = (unit_cost + transport_cost) * quantity
        
        if alt_total < current_total_cost
          savings = current_total_cost - alt_total
          alternatives << {
            source: settlement.name || settlement.location.celestial_body.name,
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
      
      precursor_recommendation = if local_cost == 0 && @capability_service
        potential_savings = costs[:precursor_total_savings] || 0
        payback_years = potential_savings > 0 ? (100_000_000 / potential_savings.to_f).round(1) : nil # Rough estimate
        
        {
          payback_analysis: {
            recommendation: "Establish precursor infrastructure for #{payback_years} year payback",
            potential_savings: potential_savings,
            estimated_savings: potential_savings
          }
        }
      end
      
      {
        local_production: total_cost > 0 ? (local_cost / total_cost * 100).round(2) : 0,
        regional_supply: total_cost > 0 ? (regional_cost / total_cost * 100).round(2) : 0,
        earth_import: total_cost > 0 ? (import_cost / total_cost * 100).round(2) : 0,
        transport_cost_ratio: costs[:transport_cost_ratio],
        infrastructure_note: local_cost == 0 ? "No local infrastructure - all materials imported" : "Local ISRU active",
        precursor_recommendation: precursor_recommendation
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
    
    def summarize_local_capabilities
      return { available: false } unless @capability_service
      
      capabilities = @capability_service.production_capabilities
      
      {
        available: true,
        location: @target_location.name,
        atmosphere: capabilities[:atmosphere],
        surface: capabilities[:surface],
        subsurface: capabilities[:subsurface],
        regolith: capabilities[:regolith],
        precursor_enables: {
          oxygen: @capability_service.precursor_enables?(:oxygen),
          water: @capability_service.precursor_enables?(:water),
          fuel: @capability_service.precursor_enables?(:fuel),
          metals: @capability_service.precursor_enables?(:metals),
          regolith_processing: @capability_service.precursor_enables?(:regolith_processing)
        }
      }
    end
  end
end
