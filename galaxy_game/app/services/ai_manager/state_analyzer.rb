# app/services/ai_manager/state_analyzer.rb
module AIManager
  class StateAnalyzer
    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Analyze current game state and return structured analysis
    def analyze_state(settlement)
      {
        resource_needs: analyze_resource_needs(settlement),
        scouting_opportunities: analyze_scouting_opportunities(settlement),
        expansion_readiness: calculate_expansion_readiness(settlement),
        infrastructure_needs: analyze_infrastructure_needs(settlement),
        acquisition_capability: assess_acquisition_capability(settlement),
        scouting_capability: assess_scouting_capability(settlement),
        building_resources: assess_building_resources(settlement),
        economic_health: assess_economic_health(settlement),
        strategic_position: assess_strategic_position(settlement)
      }
    end

    private

    # Analyze resource shortages and needs
    def analyze_resource_needs(settlement)
      critical_needs = []
      needed_resources = []

      # Check operational data for resource consumption vs. available
      operational_data = settlement.operational_data || {}

      consumption_rates = operational_data.dig('consumption_rates') || {}
      resource_management = operational_data.dig('resource_management') || {}

      # Check for critical shortages (energy, food, water)
      critical_resources = ['energy', 'food', 'water']
      critical_resources.each do |resource|
        current_rate = consumption_rates[resource].to_f
        if current_rate > 0
          # Check if current output meets consumption
          current_output = resource_management.dig('generated', "#{resource}_kwh", 'current_output').to_f
          if current_output < current_rate * 1.2 # 20% buffer
            critical_needs << resource
          end
        end
      end

      # Check for optimization opportunities (materials for building)
      building_materials = ['steel', 'titanium', 'aluminum', 'modular_structural_panel_base']
      building_materials.each do |material|
        # If we have building capacity but low material stocks, mark as needed
        if settlement.respond_to?(:inventory) && settlement.inventory
          current_stock = settlement.inventory.current_storage_of(material)
          if current_stock < 500 # Arbitrary threshold
            needed_resources << material
          end
        end
      end

      {
        critical: critical_needs,
        needed: needed_resources
      }
    end

    # Analyze potential scouting opportunities
    def analyze_scouting_opportunities(settlement)
      high_value_systems = []
      strategic_systems = []

      # Check for unexplored systems in range
      # This would typically check a system database or known systems
      # For now, return mock opportunities based on settlement state

      # If settlement is resource-rich, look for expansion opportunities
      if assess_economic_health(settlement) > 0.7
        strategic_systems << { id: 'nearby_system_1', estimated_value: :high }
      end

      # If settlement needs resources, look for resource-rich systems
      if analyze_resource_needs(settlement)[:critical].any?
        high_value_systems << { id: 'resource_system_1', resource_potential: :high }
      end

      {
        high_value: high_value_systems,
        strategic: strategic_systems
      }
    end

    # Calculate readiness for settlement expansion
    def calculate_expansion_readiness(settlement)
      score = 0.0

      # Population capacity check
      max_pop = settlement.respond_to?(:max_population_capacity) ? settlement.max_population_capacity : 1000
      current_pop = settlement.current_population
      pop_ratio = current_pop.to_f / max_pop
      score += [pop_ratio * 0.4, 0.4].min # Max 0.4 points

      # Resource surplus check
      operational_data = settlement.operational_data || {}
      generated = operational_data.dig('resource_management', 'generated') || {}
      energy_surplus = generated.dig('energy_kwh', 'current_output').to_f > 2000 ? 0.3 : 0.0
      score += energy_surplus

      # Economic stability
      economic_score = assess_economic_health(settlement)
      score += economic_score * 0.3

      [score, 1.0].min # Cap at 1.0
    end

    # Analyze infrastructure needs
    def analyze_infrastructure_needs(settlement)
      critical_needs = []
      needed_infrastructure = []

      # Check power systems
      power_status = settlement.operational_data.dig('power_grid', 'status')
      if power_status != 'online'
        critical_needs << 'power_grid'
      end

      # Check for expansion capacity
      if calculate_expansion_readiness(settlement) > 0.8
        needed_infrastructure << 'habitation_expansion'
      end

      {
        critical: critical_needs,
        needed: needed_infrastructure
      }
    end

    # Assess capability to acquire resources
    def assess_acquisition_capability(settlement)
      # Check for mining/extraction infrastructure
      # Check for transportation capacity
      # For now, return a basic assessment
      operational_data = settlement.operational_data || {}
      power_status = operational_data.dig('power_grid', 'status') == 'online' ? 1.0 : 0.0
      population_factor = [settlement.current_population / 100.0, 1.0].min

      (power_status + population_factor) / 2.0
    end

    # Assess scouting capability
    def assess_scouting_capability(settlement)
      # Check for probe deployment capability
      # Check for sensor infrastructure
      # For now, base on settlement development level
      population_factor = [settlement.current_population / 50.0, 1.0].min
      power_factor = settlement.operational_data.dig('power_grid', 'status') == 'online' ? 1.0 : 0.0

      (population_factor + power_factor) / 2.0
    end

    # Assess building resource availability
    def assess_building_resources(settlement)
      # Check for construction materials availability
      if settlement.respond_to?(:inventory)
        key_materials = ['steel', 'titanium', 'modular_structural_panel_base']
        available_count = key_materials.count do |material|
          settlement.inventory.current_storage_of(material) > 100
        end
        available_count.to_f / key_materials.length
      else
        0.5 # Default assumption
      end
    end

    # Assess economic health
    def assess_economic_health(settlement)
      operational_data = settlement.operational_data || {}

      # Check power surplus
      generated = operational_data.dig('resource_management', 'generated', 'energy_kwh', 'current_output').to_f
      consumed = operational_data.dig('resource_management', 'consumables', 'energy_kwh', 'current_usage').to_f

      power_ratio = consumed > 0 ? generated / consumed : 0
      power_score = [[power_ratio - 1.0, 0].max, 2.0].min / 2.0 # 0-1 scale

      # Population efficiency
      pop_score = [settlement.current_population / 200.0, 1.0].min

      (power_score + pop_score) / 2.0
    end

    # Assess strategic position
    def assess_strategic_position(settlement)
      # Check location advantages, nearby resources, expansion potential
      # For now, return basic assessment
      location_score = settlement.name.include?('Luna') ? 0.8 : 0.6
      development_score = assess_economic_health(settlement)

      (location_score + development_score) / 2.0
    end
  end
end