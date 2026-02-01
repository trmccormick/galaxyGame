# galaxy_game/app/services/terrain_analysis/terrain_quality_assessor.rb
# Assesses the quality and realism of generated terrain
# Provides feedback for terrain generation improvements

module TerrainAnalysis
  class TerrainQualityAssessor
    # Assess overall terrain quality
    def assess_terrain_quality(terrain_data, planet_properties = {})
      scores = {
        realism: calculate_realism_score(terrain_data, planet_properties),
        playability: calculate_playability_score(terrain_data),
        diversity: calculate_diversity_score(terrain_data),
        balance: calculate_balance_score(terrain_data)
      }

      scores[:overall] = (scores[:realism] * 0.4 + scores[:playability] * 0.3 +
                         scores[:diversity] * 0.2 + scores[:balance] * 0.1)

      scores
    end

    private

    # Calculate how realistic the terrain is based on planet properties
    def calculate_realism_score(terrain_data, planet_properties)
      score = 0.5  # Base score

      elevation_data = terrain_data[:elevation] || terrain_data[:elevation_data]
      biome_data = terrain_data[:biomes] || terrain_data[:terrain] || terrain_data[:terrain_grid]

      if elevation_data && planet_properties[:radius]
        # Check if elevation scale matches planet size
        radius_km = planet_properties[:radius].to_f / 1000
        max_elevation = elevation_data.flatten.compact.max.to_f

        expected_max_elevation = case radius_km
        when 0..5000  # Small rocky bodies
          radius_km * 0.1  # ~10% of radius
        when 5000..10000  # Earth-sized
          radius_km * 0.05  # ~5% of radius
        else  # Large planets
          radius_km * 0.02  # ~2% of radius
        end

        if max_elevation.between?(expected_max_elevation * 0.5, expected_max_elevation * 1.5)
          score += 0.2
        end
      end

      if biome_data && planet_properties[:surface_temperature]
        temp = planet_properties[:surface_temperature].to_f

        # Check biome distribution matches temperature
        biome_counts = count_biomes(biome_data)

        if temp < 273  # Very cold
          ice_biomes = biome_counts.values_at('ice', 'tundra', 'snow').compact.sum
          if ice_biomes > biome_counts.values.sum * 0.7
            score += 0.15
          end
        elsif temp.between?(273, 373)  # Habitable range
          earth_like_biomes = biome_counts.values_at('grassland', 'forest', 'plains', 'desert').compact.sum
          if earth_like_biomes > biome_counts.values.sum * 0.5
            score += 0.15
          end
        end
      end

      score.clamp(0.0, 1.0)
    end

    # Calculate how playable the terrain is for gameplay purposes
    def calculate_playability_score(terrain_data)
      score = 0.5  # Base score

      resource_grid = terrain_data[:resource_grid]
      strategic_markers = terrain_data[:strategic_markers] || []

      if resource_grid
        # Check resource distribution
        total_cells = resource_grid.flatten.size
        resource_cells = resource_grid.flatten.compact.size
        resource_ratio = resource_cells.to_f / total_cells

        if resource_ratio.between?(0.05, 0.25)  # 5-25% resources
          score += 0.2
        end

        # Check for resource clustering (not too spread out or clumped)
        resource_clusters = analyze_resource_clustering(resource_grid)
        if resource_clusters[:average_cluster_size].between?(3, 15)
          score += 0.1
        end
      end

      # Check strategic markers
      if strategic_markers.size > 5
        score += 0.1
      end

      # Check terrain accessibility (not too much water blocking movement)
      if terrain_data[:biomes] || terrain_data[:terrain]
        water_ratio = calculate_water_ratio(terrain_data)
        if water_ratio < 0.8  # Less than 80% water
          score += 0.1
        end
      end

      score.clamp(0.0, 1.0)
    end

    # Calculate terrain diversity
    def calculate_diversity_score(terrain_data)
      score = 0.0

      # Elevation diversity
      if elevation_data = terrain_data[:elevation] || terrain_data[:elevation_data]
        elevations = elevation_data.flatten.compact
        if elevations.size > 10
          std_dev = calculate_standard_deviation(elevations)
          mean = elevations.sum.to_f / elevations.size
          cv = std_dev / mean  # Coefficient of variation

          score += [cv * 2, 0.3].min  # Up to 0.3 for elevation diversity
        end
      end

      # Biome diversity
      if biome_data = terrain_data[:biomes] || terrain_data[:terrain] || terrain_data[:terrain_grid]
        biome_counts = count_biomes(biome_data)
        total_biomes = biome_counts.values.sum

        if total_biomes > 0
          # Shannon diversity index
          diversity = -biome_counts.values.sum do |count|
            p = count.to_f / total_biomes
            p * Math.log(p) rescue 0
          end

          score += [diversity * 0.5, 0.4].min  # Up to 0.4 for biome diversity
        end
      end

      # Resource diversity
      if resource_counts = terrain_data[:resource_counts]
        resource_types = resource_counts.keys.size
        score += [resource_types * 0.05, 0.3].min  # Up to 0.3 for resource diversity
      end

      score.clamp(0.0, 1.0)
    end

    # Calculate balance (fair distribution of resources/opportunities)
    def calculate_balance_score(terrain_data)
      score = 0.5  # Base score

      # Check resource balance
      if resource_counts = terrain_data[:resource_counts]
        total_resources = resource_counts.values.sum
        if total_resources > 0
          # Check for resource scarcity (no single resource dominates)
          max_resource_ratio = resource_counts.values.max.to_f / total_resources
          if max_resource_ratio < 0.5  # No resource > 50% of total
            score += 0.2
          end

          # Check for minimum resource variety
          if resource_counts.keys.size >= 3
            score += 0.1
          end
        end
      end

      # Check strategic marker distribution
      if strategic_markers = terrain_data[:strategic_markers]
        # Should be spread out, not clustered
        marker_distribution = analyze_marker_distribution(strategic_markers)
        if marker_distribution[:spread_score] > 0.6
          score += 0.2
        end
      end

      score.clamp(0.0, 1.0)
    end

    # Helper methods
    def count_biomes(biome_data)
      return {} unless biome_data

      counts = Hash.new(0)
      biome_data.flatten.compact.each do |biome|
        counts[biome.to_s] += 1
      end
      counts
    end

    def calculate_water_ratio(terrain_data)
      biome_data = terrain_data[:biomes] || terrain_data[:terrain] || terrain_data[:terrain_grid]
      return 0.0 unless biome_data

      total_cells = biome_data.flatten.size
      water_cells = biome_data.flatten.count do |biome|
        biome.to_s.downcase.include?('water') || biome.to_s.downcase.include?('ocean')
      end

      water_cells.to_f / total_cells
    end

    def analyze_resource_clustering(resource_grid)
      # Simple clustering analysis - count connected resource groups
      clusters = []
      visited = Array.new(resource_grid.size) { Array.new(resource_grid.first.size, false) }

      resource_grid.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          next if visited[y][x] || cell.nil?

          cluster = find_cluster(resource_grid, visited, x, y)
          clusters << cluster.size if cluster.size > 1
        end
      end

      {
        cluster_count: clusters.size,
        average_cluster_size: clusters.empty? ? 0 : clusters.sum.to_f / clusters.size,
        max_cluster_size: clusters.max || 0
      }
    end

    def find_cluster(grid, visited, x, y)
      cluster = []
      queue = [[x, y]]

      while !queue.empty?
        cx, cy = queue.shift
        next if visited[cy][cx] || grid[cy][cx].nil?

        visited[cy][cx] = true
        cluster << [cx, cy]

        # Check adjacent cells
        [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |dx, dy|
          nx, ny = cx + dx, cy + dy
          if nx.between?(0, grid.first.size-1) && ny.between?(0, grid.size-1)
            queue << [nx, ny] if !visited[ny][nx] && grid[ny][nx]
          end
        end
      end

      cluster
    end

    def analyze_marker_distribution(markers)
      return { spread_score: 0.0 } if markers.empty?

      # Calculate spread based on marker positions
      positions = markers.map { |m| [m[:x], m[:y]] }.compact

      return { spread_score: 0.0 } if positions.empty?

      # Calculate average distance between markers
      total_distance = 0
      count = 0

      positions.each_with_index do |pos1, i|
        positions[i+1..-1].each do |pos2|
          distance = Math.sqrt((pos1[0] - pos2[0])**2 + (pos1[1] - pos2[1])**2)
          total_distance += distance
          count += 1
        end
      end

      avg_distance = count > 0 ? total_distance / count : 0

      # Normalize spread score (higher is better spread)
      max_possible_distance = Math.sqrt(2) * 100  # Assuming 100x100 grid
      spread_score = [avg_distance / max_possible_distance, 1.0].min

      { spread_score: spread_score, average_distance: avg_distance }
    end

    def calculate_standard_deviation(values)
      return 0.0 if values.empty?

      mean = values.sum.to_f / values.size
      variance = values.sum { |v| (v - mean)**2 } / values.size
      Math.sqrt(variance)
    end
  end
end