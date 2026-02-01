module Economics
  class InfrastructureCostCalculator
    class << self

      # Calculate infrastructure cost using blueprint data + dynamic transport costs
      def calculate_cost(infrastructure_type, location, options = {})
        blueprint = find_infrastructure_blueprint(infrastructure_type)
        return 0 unless blueprint

        destination = find_celestial_body(location)
        return 0 unless destination

        # Get Earth manufacturing cost from blueprint
        earth_cost = blueprint_earth_cost(blueprint)

        # Calculate transport cost using Logistics service
        transport_cost = calculate_transport_cost(blueprint, destination, options)

        # Apply local production discounts if available
        local_discount = calculate_local_production_discount(blueprint, destination)

        total_cost = (earth_cost + transport_cost) * (1.0 - local_discount)

        # Apply complexity and scale factors
        total_cost *= complexity_multiplier(options[:complexity] || :medium_risk)
        total_cost *= scale_factor(options[:scale] || :medium)

        # Round to nearest billion GCC
        (total_cost / 1_000_000_000.0).round * 1_000_000_000
      end

      # Calculate mission costs using blueprint phases
      def calculate_mission_cost(mission_type, destination, phases = [])
        destination_body = find_celestial_body(destination)
        return 0 unless destination_body

        total_cost = 0

        phases.each do |phase|
          phase_blueprints = find_phase_blueprints(phase)
          phase_blueprints.each do |blueprint|
            earth_cost = blueprint_earth_cost(blueprint)
            transport_cost = calculate_transport_cost(blueprint, destination_body)
            total_cost += earth_cost + transport_cost
          end
        end

        (total_cost / 1_000_000_000.0).round * 1_000_000_000
      end

      private

      def find_infrastructure_blueprint(infrastructure_type)
        # Look up blueprint by infrastructure type
        service = Lookup::BlueprintLookupService.new
        
        # Map common infrastructure types to actual blueprint names
        blueprint_name = case infrastructure_type.to_s
        when 'basic_orbital_station' then 'orbital_depot_mk1'
        when 'orbital_foundry' then 'artificial_wormhole_station_mk1'
        when 'medium_surface_base' then 'metal_smelter_facility_bp'
        when 'industrial_processing_plant' then 'nuclear_fuel_reprocessing_facility_bp'
        else infrastructure_type.to_s
        end
        
        # Try infrastructure category first, then structure
        service.find_blueprint(blueprint_name, 'infrastructure') || 
        service.find_blueprint(blueprint_name, 'structure') ||
        service.find_blueprint(blueprint_name) # Fallback to any category
      end

      def find_celestial_body(location)
        # Support both string identifiers and CelestialBody objects
        if location.is_a?(String) || location.is_a?(Symbol)
          CelestialBodies::CelestialBody.find_by(identifier: location.to_s)
        else
          location
        end
      end

      def blueprint_earth_cost(blueprint)
        # Extract EAP from blueprint cost_schema
        cost_schema = blueprint.dig('cost_schema') || blueprint.dig('blueprint_data', 'cost_schema')
        return 0 unless cost_schema

        # Use earth_anchor_price if available, otherwise calculate from material costs
        if cost_schema['earth_anchor_price']
          cost_schema['earth_anchor_price']
        else
          calculate_from_material_costs(blueprint)
        end
      end

      def calculate_from_material_costs(blueprint)
        # Fallback: calculate from material requirements
        materials = blueprint.dig('blueprint_data', 'material_requirements') || []
        total_cost = 0

        materials.each do |req|
          material = Lookup::MaterialLookupService.find_by_name(req['material'])
          next unless material

          # Get current market price or fallback to base price
          unit_price = Market::NpcPriceCalculator.calculate_ask(material) rescue material.base_price
          total_cost += unit_price * req['amount']
        end

        total_cost
      end

      def calculate_transport_cost(blueprint, destination, options = {})
        # Calculate total mass of blueprint
        total_mass = blueprint_total_mass(blueprint)

        # Use Logistics service for dynamic transport cost
        Logistics::TransportCostService.calculate_cost_per_kg(
          from: 'earth',
          to: destination.identifier,
          resource: blueprint['primary_material'] || 'manufactured_goods'
        ) * total_mass
      rescue
        # Fallback to simplified calculation if service unavailable
        base_transport_rate = 150 # GCC/kg for manufactured goods
        distance_modifier = distance_modifier_for_body(destination)
        base_transport_rate * total_mass * distance_modifier
      end

      def blueprint_total_mass(blueprint)
        materials = blueprint.dig('blueprint_data', 'material_requirements') || []
        total_mass = 0

        materials.each do |req|
          material = Lookup::MaterialLookupService.find_by_name(req['material'])
          density = material&.density || 1000 # kg/m³ fallback
          volume = req['amount'] / density
          total_mass += volume
        end

        total_mass
      end

      def calculate_local_production_discount(blueprint, destination)
        # Check if destination can produce required materials locally
        materials = blueprint.dig('blueprint_data', 'material_requirements') || []
        producible_materials = 0

        materials.each do |req|
          material = Lookup::MaterialLookupService.find_by_name(req['material'])
          next unless material

          # Check if destination has ISRU capability for this material
          if AIManager::PrecursorCapabilityService.can_produce?(destination, material.chemical_formula)
            producible_materials += 1
          end
        end

        # Discount based on percentage of materials that can be produced locally
        local_production_ratio = producible_materials.to_f / materials.length
        local_production_ratio * 0.3 # Up to 30% discount for full local production
      end

      def distance_modifier_for_body(body)
        case body.identifier
        when 'luna' then 1.0
        when 'mars', 'phobos', 'deimos' then 1.5
        when 'venus' then 2.0
        when 'ceres', 'vesta' then 2.5
        when 'jupiter', 'io', 'europa', 'ganymede', 'callisto' then 4.0
        when 'saturn', 'titan', 'rhea', 'iapetus' then 5.0
        when 'uranus', 'neptune' then 6.0
        else 3.0 # Default for unknown bodies
        end
      end

      def find_phase_blueprints(phase)
        # This would need to be implemented based on mission phase data
        # For now, return empty array
        []
      end

      def complexity_multiplier(complexity)
        case complexity
        when :low_risk then 1.0
        when :medium_risk then 1.2
        when :high_risk then 1.5
        when :extreme_risk then 2.0
        else 1.2
        end
      end

      def scale_factor(scale)
        case scale
        when :small then 0.5
        when :medium then 1.0
        when :large then 2.0
        when :massive then 5.0
        else 1.0
        end
      end

    end
  end
end