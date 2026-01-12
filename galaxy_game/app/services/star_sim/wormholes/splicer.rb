# app/services/star_sim/wormholes/splicer.rb
module StarSim::Wormholes
  class Splicer
    attr_reader :random

    def initialize(random: Random.new)
      @random = random
    end

    # Create an artificial wormhole between two solar systems
    def create_artificial_wormhole(source_system:, target_system:, target_coordinates: nil)
      raise ArgumentError, "Target system must be different from source" if source_system == target_system

      wormhole = Wormhole.create!(
        solar_system_a: source_system,
        solar_system_b: target_system,
        wormhole_type: :traversable, # Assuming artificial ones are traversable by default
        stability: :stabilizing,     # Artificial ones might start in a stabilizing state
        power_requirement: generate_power_requirement,
        formation_date: Time.current,
        mass_limit: generate_mass_limit # Initial mass limit
      )

      create_artificial_endpoints(wormhole: wormhole, source_system: source_system, target_system: target_system, target_coordinates: target_coordinates)

      wormhole
    end

    private

    def create_artificial_endpoints(wormhole:, source_system:, target_system:, target_coordinates:)
      # Endpoint in the source system (near the generator - needs a defined location for generators)
      source_location = find_artificial_wormhole_origin(source_system)
      create_endpoint(wormhole: wormhole, solar_system: source_system, coordinates: source_location)

      # Endpoint in the target system (either safe deep space or specific coordinates)
      target_coords = target_coordinates || WormholeGenerator.send(:calculate_safe_coordinates, target_system)
      create_endpoint(wormhole: wormhole, solar_system: target_system, coordinates: target_coords)
    end

    def create_endpoint(wormhole:, solar_system:, coordinates:)
      SpatialLocation.create!(
        name: "Artificial Wormhole Point #{solar_system.name} (#{wormhole.id})",
        x_coordinate: coordinates[:x],
        y_coordinate: coordinates[:y],
        z_coordinate: coordinates[:z],
        spatial_context: wormhole # Associate with the Wormhole
      )
    end

    def find_artificial_wormhole_origin(solar_system)
      # Logic to find the spatial location of a wormhole generator in the system
      # This would depend on how generators are implemented (e.g., a specific structure type)
      settlement = solar_system.base_settlement # Example: generator at the base settlement
      if settlement&.spatial_location
        return settlement.spatial_location.attributes.slice(:x_coordinate, :y_coordinate, :z_coordinate).symbolize_keys
      else
        # Fallback to a safe deep space coordinate if no generator found
        WormholeGenerator.send(:calculate_safe_coordinates, solar_system)
      end
    end

    def generate_power_requirement
      rand(100..1000) # Higher power requirement for artificial ones
    end

    def generate_mass_limit
      base = 5_000 + random.rand(20_000) # Artificial ones might have higher base limit
      (base * random.rand(0.8..1.2)).to_i
    end

    def initial_stability
      # No longer used directly, the Wormhole model enum will handle this
      # We set it directly to :stabilizing in create_artificial_wormhole
    end

    def expiration_time
      # Artificial wormholes are likely permanent unless disrupted
      nil
    end

    def determine_size(mass_limit)
      case mass_limit
      when 0..10_000 then :small
      when 10_001..50_000 then :medium
      else :large
      end
    end

    def random_location_excluding(location)
      # No longer used as we are working with SolarSystems
      nil
    end
  end
end
  