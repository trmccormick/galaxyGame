module Logistics
  class RouteCostCalculator
    def initialize
      @gravity_wells = calculate_gravity_wells
    end

    def calculate_gravity_wells
      wells = {}
      CelestialBodies::CelestialBody.find_each do |body|
        next unless body.gravity.present?
        
        wells[body.identifier.downcase] = {
          escape_cost: body.gravity,  # m/s²
          parent_body: body.parent_body&.identifier&.downcase,
          type: body.type || 'celestial_body'
        }
      end

      # Add Lagrange points
      add_lagrange_points(wells)
      
      wells
    end

    def calculate_route_cost(from:, to:, distance:, mass:)
      from_well = @gravity_wells[from.downcase]
      to_well = @gravity_wells[to.downcase]
      
      return 0 unless from_well && to_well

      # Calculate escape cost based on planetary system
      escape_cost = calculate_escape_cost(from_well)
      destination_cost = calculate_escape_cost(to_well)
      
      # Transit cost based on distance and orbital mechanics
      transit_cost = calculate_transit_cost(distance, from_well, to_well)

      total_delta_v = escape_cost + transit_cost + destination_cost
      
      # Convert delta-v to GCC cost
      (total_delta_v * mass * 100).round(2)
    end

    def find_best_route(item_id:, quantity:, source_locations:, destination:)
      item = Lookup::ItemLookupService.new.find_item(item_id)
      return nil unless item

      total_mass = item['weight'] * quantity
      
      routes = source_locations.map do |location|
        {
          from: location,
          to: destination,
          base_cost: item['base_price'] * quantity,
          shipping_cost: calculate_route_cost(
            from: location,
            to: destination,
            distance: get_distance(location, destination),
            mass: total_mass
          )
        }
      end

      routes.min_by { |route| route[:base_cost] + route[:shipping_cost] }
    end

    private

    def add_lagrange_points(wells)
      CelestialBodies::CelestialBody.where.not(parent_body: nil).find_each do |body|
        parent = body.parent_body
        next unless parent && wells[parent.identifier.downcase]

        # Add L1-L5 points
        (1..5).each do |point|
          wells["#{body.identifier.downcase}_l#{point}"] = {
            escape_cost: 0,  # Negligible gravity at Lagrange points
            parent_body: body.identifier.downcase,
            type: 'lagrange_point',
            point: point
          }
        end
      end
    end

    def calculate_escape_cost(well)
      return 0 if well[:type] == 'lagrange_point'
      
      cost = well[:escape_cost]
      
      # Add parent body escape costs if needed
      if well[:parent_body] && @gravity_wells[well[:parent_body]]
        cost += calculate_escape_cost(@gravity_wells[well[:parent_body]]) * 0.3
      end
      
      cost
    end

    def calculate_transit_cost(distance, from_well, to_well)
      base_cost = distance * 0.001
      
      # Adjust for orbital mechanics
      if from_well[:type] == 'lagrange_point' || to_well[:type] == 'lagrange_point'
        base_cost *= 0.7  # Lagrange points provide efficient transit paths
      end
      
      base_cost
    end

    def get_distance(from, to)
      # This would actually use celestial body data to calculate real distances
      # Placeholder for now
      case [from, to].sort.join('_to_')
      when 'earth_to_luna' then 384_400
      when 'earth_to_l1' then 1_500_000
      when 'luna_to_l1' then 1_115_600
      else 1_000_000 # Default distance
      end
    end
  end
end