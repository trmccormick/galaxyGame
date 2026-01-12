# app/services/ai_manager/wormhole_placement_service.rb
module AIManager
  class WormholePlacementService
    GRAVITATIONAL_CONSTANT = 6.67430e-11  # m³ kg⁻¹ s⁻²

    def initialize
      @game_constants = GameConstants::GRAVITATIONAL_CONSTANT rescue 6.67430e-11
    end

    # Calculate optimal wormhole station placement based on gravitational influences
    def calculate_optimal_placement(wormhole:, target_system:)
      return nil unless wormhole && target_system

      # Get celestial bodies in the target system
      celestial_bodies = target_system.celestial_bodies

      # Calculate gravitational potential field
      potential_field = calculate_gravitational_potential(celestial_bodies)

      # Find Lagrange points for major gravitational influences
      lagrange_points = calculate_system_lagrange_points(celestial_bodies)

      # Evaluate placement options
      placement_options = evaluate_placement_options(
        potential_field,
        lagrange_points,
        wormhole,
        target_system
      )

      # Return optimal placement
      placement_options.min_by { |option| option[:stability_risk] + option[:construction_cost] }
    end

    private

    def calculate_gravitational_potential(celestial_bodies)
      # Create a 3D grid of gravitational potential
      grid_resolution = 10000000  # 10 million km per grid point
      system_radius = calculate_system_radius(celestial_bodies)

      potential_grid = {}

      # Sample points in a spherical volume around the system
      (-system_radius..system_radius).step(grid_resolution).each do |x|
        (-system_radius..system_radius).step(grid_resolution).each do |y|
          (-system_radius..system_radius).step(grid_resolution).each do |z|
            position = [x, y, z]
            potential = calculate_potential_at_position(position, celestial_bodies)
            potential_grid[position] = potential
          end
        end
      end

      potential_grid
    end

    def calculate_potential_at_position(position, celestial_bodies)
      total_potential = 0

      celestial_bodies.each do |body|
        # Handle both database objects and procedural hashes
        if body.respond_to?(:spatial_location) && body.spatial_location
          body_position = body.spatial_location.coordinates
          mass = body.mass
        elsif body.is_a?(Hash) && body["orbits"]&.first
          # For procedural bodies, approximate position as distance along x-axis
          orbit = body["orbits"].first
          distance_au = orbit["distance"] || orbit["semi_major_axis_au"] || 1.0
          # Convert AU to km (1 AU = 149,597,870.7 km)
          distance_km = distance_au * 149597870.7
          body_position = [distance_km, 0, 0] # Assume along x-axis for simplicity
          mass = body["mass"]
        else
          next # Skip bodies without position/mass data
        end

        next unless body_position && mass

        distance = calculate_distance(position, body_position)
        next if distance == 0

        # Gravitational potential: Φ = -GM/r
        potential = -(@game_constants * mass) / distance
        total_potential += potential
      end

      total_potential
    end

    def calculate_system_lagrange_points(celestial_bodies)
      lagrange_points = []

      # Find major gravitational pairs (star-planet, planet-moon, etc.)
      gravitational_pairs = identify_gravitational_pairs(celestial_bodies)

      gravitational_pairs.each do |primary, secondary|
        # Handle both database objects and procedural hashes
        if primary.respond_to?(:spatial_location) && primary.spatial_location && secondary.respond_to?(:spatial_location) && secondary.spatial_location
          distance = primary.spatial_location.distance_to(secondary.spatial_location)
        elsif primary.is_a?(Hash) && secondary.is_a?(Hash)
          # For procedural bodies, calculate distance from orbital data
          primary_orbit = primary["orbits"]&.first
          secondary_orbit = secondary["orbits"]&.first
          if primary_orbit && secondary_orbit
            primary_dist = primary_orbit["distance"] || primary_orbit["semi_major_axis_au"] || 1.0
            secondary_dist = secondary_orbit["distance"] || secondary_orbit["semi_major_axis_au"] || 1.0
            distance = (primary_dist - secondary_dist).abs * 149597870.7 # Convert AU to km
          else
            distance = 1000000 # Default 1 million km if no orbit data
          end
        else
          next # Skip pairs without position data
        end

        # Calculate L1-L5 points (simplified 2D calculation)
        l1 = calculate_l1_point(primary, secondary, distance)
        l2 = calculate_l2_point(primary, secondary, distance)
        l3 = calculate_l3_point(primary, secondary, distance)
        l4 = calculate_l4_point(primary, secondary, distance)
        l5 = calculate_l5_point(primary, secondary, distance)

        lagrange_points.concat([l1, l2, l3, l4, l5].compact)
      end

      lagrange_points
    end

    def identify_gravitational_pairs(celestial_bodies)
      pairs = []

      # Sort by mass descending
      sorted_bodies = celestial_bodies.sort_by { |b| -(b.respond_to?(:mass) ? b.mass : b["mass"] || 0).to_f }

      sorted_bodies.each_with_index do |primary, index|
        # Consider the next few most massive bodies as potential secondary bodies
        secondary_candidates = sorted_bodies[(index + 1)..(index + 3)] || []

        secondary_candidates.each do |secondary|
          # Handle both database objects and procedural hashes
          if (primary.respond_to?(:spatial_location) && primary.spatial_location && secondary.respond_to?(:spatial_location) && secondary.spatial_location)
            distance = primary.spatial_location.distance_to(secondary.spatial_location)
            primary_mass = primary.mass
            secondary_mass = secondary.mass
          elsif primary.is_a?(Hash) && secondary.is_a?(Hash)
            # For procedural bodies, calculate distance from orbital data
            primary_orbit = primary["orbits"]&.first
            secondary_orbit = secondary["orbits"]&.first
            if primary_orbit && secondary_orbit
              primary_dist = primary_orbit["distance"] || primary_orbit["semi_major_axis_au"] || 1.0
              secondary_dist = secondary_orbit["distance"] || secondary_orbit["semi_major_axis_au"] || 1.0
              distance = (primary_dist - secondary_dist).abs * 149597870.7 # Convert AU to km
            else
              distance = 1000000 # Default 1 million km if no orbit data
            end
            primary_mass = primary["mass"]
            secondary_mass = secondary["mass"]
          else
            next # Skip pairs without position data
          end

          mass_ratio = secondary_mass.to_f / primary_mass.to_f

          # Only consider pairs where the secondary is significantly less massive
          # and they're at a reasonable orbital distance
          if mass_ratio < 0.1 && distance > 0
            pairs << [primary, secondary]
          end
        end
      end

      pairs
    end

    def calculate_l1_point(primary, secondary, distance)
      # L1 point calculation (simplified)
      mass_ratio = secondary.mass.to_f / (primary.mass.to_f + secondary.mass.to_f)
      l1_distance = distance * (1 - mass_ratio**(2.0/5.0))

      # Position along the line connecting primary and secondary
      primary_pos = primary.spatial_location.coordinates
      secondary_pos = secondary.spatial_location.coordinates

      direction = vector_subtract(secondary_pos, primary_pos)
      unit_direction = vector_normalize(direction)

      l1_position = vector_add(primary_pos, vector_multiply(unit_direction, l1_distance))

      {
        position: l1_position,
        type: :l1,
        primary_body: primary,
        secondary_body: secondary,
        stability: :unstable,
        gravitational_influence: calculate_influence_at_point(l1_position, [primary, secondary])
      }
    end

    def calculate_l2_point(primary, secondary, distance)
      # L2 point calculation
      mass_ratio = secondary.mass.to_f / (primary.mass.to_f + secondary.mass.to_f)
      l2_distance = distance * (1 + mass_ratio**(2.0/5.0))

      primary_pos = primary.spatial_location.coordinates
      secondary_pos = secondary.spatial_location.coordinates

      direction = vector_subtract(secondary_pos, primary_pos)
      unit_direction = vector_normalize(direction)

      l2_position = vector_add(primary_pos, vector_multiply(unit_direction, l2_distance))

      {
        position: l2_position,
        type: :l2,
        primary_body: primary,
        secondary_body: secondary,
        stability: :unstable,
        gravitational_influence: calculate_influence_at_point(l2_position, [primary, secondary])
      }
    end

    def calculate_l3_point(primary, secondary, distance)
      # L3 point calculation
      mass_ratio = secondary.mass.to_f / (primary.mass.to_f + secondary.mass.to_f)
      l3_distance = distance * (1 + (5.0/12.0) * mass_ratio)

      primary_pos = primary.spatial_location.coordinates
      secondary_pos = secondary.spatial_location.coordinates

      direction = vector_subtract(primary_pos, secondary_pos)  # Opposite direction
      unit_direction = vector_normalize(direction)

      l3_position = vector_add(secondary_pos, vector_multiply(unit_direction, l3_distance))

      {
        position: l3_position,
        type: :l3,
        primary_body: primary,
        secondary_body: secondary,
        stability: :unstable,
        gravitational_influence: calculate_influence_at_point(l3_position, [primary, secondary])
      }
    end

    def calculate_l4_point(primary, secondary, distance)
      # L4 point calculation (equilateral triangle)
      angle = 60 * Math::PI / 180  # 60 degrees

      primary_pos = primary.spatial_location.coordinates
      secondary_pos = secondary.spatial_location.coordinates

      # Vector from primary to secondary
      primary_to_secondary = vector_subtract(secondary_pos, primary_pos)

      # Rotate 60 degrees around the axis perpendicular to the orbital plane
      rotation_matrix = rotation_matrix_z(angle)
      rotated_vector = matrix_vector_multiply(rotation_matrix, primary_to_secondary)

      l4_position = vector_add(primary_pos, vector_multiply(rotated_vector, 1))

      {
        position: l4_position,
        type: :l4,
        primary_body: primary,
        secondary_body: secondary,
        stability: :stable,
        gravitational_influence: calculate_influence_at_point(l4_position, [primary, secondary])
      }
    end

    def calculate_l5_point(primary, secondary, distance)
      # L5 point calculation (equilateral triangle, opposite side)
      angle = -60 * Math::PI / 180  # -60 degrees

      primary_pos = primary.spatial_location.coordinates
      secondary_pos = secondary.spatial_location.coordinates

      primary_to_secondary = vector_subtract(secondary_pos, primary_pos)

      rotation_matrix = rotation_matrix_z(angle)
      rotated_vector = matrix_vector_multiply(rotation_matrix, primary_to_secondary)

      l5_position = vector_add(primary_pos, vector_multiply(rotated_vector, 1))

      {
        position: l5_position,
        type: :l5,
        primary_body: primary,
        secondary_body: secondary,
        stability: :stable,
        gravitational_influence: calculate_influence_at_point(l5_position, [primary, secondary])
      }
    end

    def calculate_influence_at_point(position, bodies)
      total_influence = 0

      bodies.each do |body|
        next unless body.spatial_location && body.mass

        distance = calculate_distance(position, body.spatial_location.coordinates)
        next if distance == 0

        influence = (@game_constants * body.mass) / (distance ** 2)
        total_influence += influence
      end

      total_influence
    end

    def evaluate_placement_options(potential_field, lagrange_points, wormhole, target_system)
      options = []

      # Evaluate Lagrange points
      lagrange_points.each do |point|
        stability_risk = point[:stability] == :stable ? 0.1 : 0.8
        construction_cost = calculate_construction_cost(point, wormhole)
        operational_efficiency = calculate_operational_efficiency(point)

        options << {
          position: point[:position],
          type: :lagrange_point,
          lagrange_type: point[:type],
          stability_risk: stability_risk,
          construction_cost: construction_cost,
          operational_efficiency: operational_efficiency,
          gravitational_influence: point[:gravitational_influence],
          bodies_influencing: [point[:primary_body], point[:secondary_body]].map(&:name)
        }
      end

      # Evaluate other potential locations based on gravitational potential
      potential_field.each do |position, potential|
        next if potential > -1e10  # Skip high-potential areas (too energetic)

        # Check if this position is reasonably stable
        stability = assess_stability(position, potential_field)
        next unless stability > 0.3  # Minimum stability threshold

        construction_cost = calculate_construction_cost({position: position}, wormhole)
        operational_efficiency = calculate_operational_efficiency({position: position})

        options << {
          position: position,
          type: :gravitational_well,
          stability_risk: 1.0 - stability,
          construction_cost: construction_cost,
          operational_efficiency: operational_efficiency,
          gravitational_potential: potential
        }
      end

      options
    end

    def assess_stability(position, potential_field)
      # Simplified stability assessment based on local potential gradient
      # In a real implementation, this would analyze the potential field more thoroughly

      # Check neighboring points for potential gradients
      neighbors = get_neighboring_positions(position)
      gradients = []

      neighbors.each do |neighbor|
        neighbor_potential = potential_field[neighbor]
        next unless neighbor_potential

        distance = calculate_distance(position, neighbor)
        gradient = (neighbor_potential - potential_field[position]) / distance
        gradients << gradient.abs
      end

      return 0 if gradients.empty?

      # Lower average gradient indicates more stable region
      avg_gradient = gradients.sum / gradients.size
      stability = 1.0 / (1.0 + avg_gradient)

      [stability, 1.0].min  # Cap at 1.0
    end

    def calculate_construction_cost(location_data, wormhole)
      base_cost = 1000000  # Base construction cost in GCC

      # Adjust for distance from celestial bodies (logistics cost)
      # Adjust for gravitational environment (stabilization requirements)

      if location_data[:type] == :l4 || location_data[:type] == :l5
        base_cost *= 0.8  # Stable Lagrange points are cheaper
      elsif location_data[:type] == :l1 || location_data[:type] == :l2 || location_data[:type] == :l3
        base_cost *= 1.3  # Unstable points require more stabilization
      end

      base_cost
    end

    def calculate_operational_efficiency(location_data)
      efficiency = 0.8  # Base efficiency

      if location_data[:type] == :l4 || location_data[:type] == :l5
        efficiency *= 1.2  # Stable points allow for more efficient operations
      end

      efficiency
    end

    def calculate_system_radius(celestial_bodies)
      return 1000000 unless celestial_bodies.any?  # Default 1 million km

      max_distance = 0
      center = calculate_system_center(celestial_bodies)

      celestial_bodies.each do |body|
        next unless body.spatial_location

        distance = calculate_distance(center, body.spatial_location.coordinates)
        max_distance = [max_distance, distance].max
      end

      max_distance * 1.5  # Add 50% buffer
    end

    def calculate_system_center(celestial_bodies)
      return [0, 0, 0] unless celestial_bodies.any?

      total_mass = 0
      weighted_position = [0, 0, 0]

      celestial_bodies.each do |body|
        next unless body.spatial_location && body.mass

        mass = body.mass
        position = body.spatial_location.coordinates

        total_mass += mass
        weighted_position = vector_add(weighted_position, vector_multiply(position, mass))
      end

      return [0, 0, 0] if total_mass == 0

      vector_divide(weighted_position, total_mass)
    end

    # Vector math utilities
    def calculate_distance(pos1, pos2)
      Math.sqrt((pos1[0] - pos2[0])**2 + (pos1[1] - pos2[1])**2 + (pos1[2] - pos2[2])**2)
    end

    def vector_add(v1, v2)
      [v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2]]
    end

    def vector_subtract(v1, v2)
      [v1[0] - v2[0], v1[1] - v2[1], v1[2] - v2[2]]
    end

    def vector_multiply(v, scalar)
      [v[0] * scalar, v[1] * scalar, v[2] * scalar]
    end

    def vector_divide(v, scalar)
      return [0, 0, 0] if scalar == 0
      [v[0] / scalar, v[1] / scalar, v[2] / scalar]
    end

    def vector_normalize(v)
      magnitude = Math.sqrt(v[0]**2 + v[1]**2 + v[2]**2)
      return [0, 0, 0] if magnitude == 0
      vector_divide(v, magnitude)
    end

    def matrix_vector_multiply(matrix, vector)
      # Simple 2D rotation matrix multiplication (assuming rotation in xy-plane)
      [
        matrix[0][0] * vector[0] + matrix[0][1] * vector[1],
        matrix[1][0] * vector[0] + matrix[1][1] * vector[1],
        vector[2]  # z-coordinate unchanged
      ]
    end

    def rotation_matrix_z(angle)
      cos = Math.cos(angle)
      sin = Math.sin(angle)
      [
        [cos, -sin],
        [sin, cos]
      ]
    end

    def get_neighboring_positions(position)
      # Get 6 neighboring positions (up, down, left, right, forward, back)
      offset = 10000  # 10 km offset
      [
        [position[0] + offset, position[1], position[2]],
        [position[0] - offset, position[1], position[2]],
        [position[0], position[1] + offset, position[2]],
        [position[0], position[1] - offset, position[2]],
        [position[0], position[1], position[2] + offset],
        [position[0], position[1], position[2] - offset]
      ]
    end
  end
end