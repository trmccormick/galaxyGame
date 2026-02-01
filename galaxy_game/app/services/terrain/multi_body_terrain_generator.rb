# app/services/terrain/multi_body_terrain_generator.rb

require 'json'

module Terrain
  class MultiBodyTerrainGenerator
    # Generates realistic terrain for different planetary bodies using NASA-derived patterns

    def initialize
      @patterns = load_body_patterns
    end

    def generate_terrain(body_type, width: 1800, height: 900, options: {})
      puts "🌍 Generating #{body_type.upcase} terrain (#{width}x#{height}) using NASA patterns..."

      unless @patterns[body_type.to_s]
        puts "❌ No patterns available for body type: #{body_type}"
        return generate_fallback_terrain(body_type, width, height)
      end

      pattern_data = @patterns[body_type.to_s]
      elevation_patterns = pattern_data['patterns']['elevation']
      crater_patterns = pattern_data['patterns']['craters'] if pattern_data['patterns']['craters']

      # Generate elevation grid using patterns
      elevation_grid = generate_elevation_from_patterns(elevation_patterns, width, height)

      # Apply body-specific modifications
      case body_type.to_s
      when 'luna'
        elevation_grid = apply_lunar_characteristics(elevation_grid, crater_patterns, width, height)
      when 'mars'
        elevation_grid = apply_mars_characteristics(elevation_grid, pattern_data['patterns'], width, height, options[:blueprint_data])
      when 'earth'
        elevation_grid = apply_earth_characteristics(elevation_grid, width, height)
      end

      # Generate comprehensive terrain data (elevation only)
      terrain_data = {
        grid: nil,  # No biome grid - handled in rendering layer
        elevation: elevation_grid,
        width: width,
        height: height,
        body_type: body_type,
        generated_at: Time.current.iso8601,
        generator: 'MultiBodyTerrainGenerator',
        source: 'NASA_DEM_patterns',
        characteristics: pattern_data['characteristics']
      }

      puts "✅ Generated #{body_type.upcase} terrain: #{width}x#{height} with #{elevation_grid.flatten.uniq.size} elevation values"
      terrain_data
    end

    private

    def load_body_patterns
      patterns = {}
      pattern_dir = GalaxyGame::Paths::AI_MANAGER_PATH

      ['earth', 'luna', 'mars'].each do |body|
        pattern_file = pattern_dir.join("geotiff_patterns_#{body}.json")
        if File.exist?(pattern_file)
          patterns[body] = JSON.parse(File.read(pattern_file))
          puts "✓ Loaded #{body} patterns from #{pattern_file.basename}"
        else
          puts "⚠️  No pattern file found for #{body}: #{pattern_file}"
        end
      end

      patterns
    end

    def generate_elevation_from_patterns(elevation_patterns, width, height)
      # Use the empirical distribution from NASA data to generate realistic elevation
      histogram = elevation_patterns['distribution']['histogram']
      bins = elevation_patterns['distribution']['bins']

      # Create elevation grid using the distribution
      grid = Array.new(height) do |y|
        Array.new(width) do |x|
          # Sample from the empirical distribution
          sample_from_distribution(histogram, bins)
        end
      end

      grid
    end

    def sample_from_distribution(histogram, bins)
      # Simple sampling from empirical distribution
      # In a real implementation, you'd use inverse transform sampling
      total = histogram.sum
      rand_val = rand * total

      cumulative = 0
      histogram.each_with_index do |count, index|
        cumulative += count
        if rand_val <= cumulative
          # Return elevation value for this bin
          bin_start = bins[index]
          bin_end = bins[index + 1] || bins[index] + (bins[1] - bins[0])
          return bin_start + rand * (bin_end - bin_start)
        end
      end

      # Fallback
      bins.first
    end

    def apply_lunar_characteristics(elevation_grid, crater_patterns, width, height)
      # Apply lunar-specific features: craters, maria, highlands
      grid = elevation_grid.map(&:dup)

      # Add large impact basins (maria)
      add_lunar_maria(grid, width, height)

      # Add cratering effects
      add_crater_terrain(grid, crater_patterns, width, height)

      grid
    end

    def apply_mars_characteristics(elevation_grid, patterns, width, height, blueprint_data = nil)
      # Apply Mars-specific features: volcanoes, dichotomy, craters, and blueprint constraints
      grid = elevation_grid.map(&:dup)

      # Add volcanic features
      add_volcanic_terrain(grid, patterns['volcanoes'], width, height)

      # Add hemispheric dichotomy
      add_mars_dichotomy(grid, width, height)

      # Apply blueprint water level constraints if available
      if blueprint_data && blueprint_data[:historical_water_levels]
        apply_blueprint_water_constraints(grid, blueprint_data[:historical_water_levels], width, height)
      end

      grid
    end

    def apply_earth_characteristics(elevation_grid, width, height)
      # Apply Earth-specific features: oceans, continents, varied biomes
      grid = elevation_grid.map(&:dup)

      # Normalize to Earth's elevation ranges
      min_elev = grid.flatten.min
      max_elev = grid.flatten.max
      range = max_elev - min_elev

      grid.map! do |row|
        row.map! do |elev|
          # Scale to Earth's typical elevation range (-10000 to 8000 meters)
          ((elev - min_elev) / range) * 18000 - 10000
        end
      end

      grid
    end

    def add_lunar_maria(grid, width, height)
      # Add large, flat maria (lava-filled impact basins)
      # Maria are typically at lower elevations
      maria_centers = [
        [width * 0.3, height * 0.4],  # Mare Tranquillitatis area
        [width * 0.7, height * 0.6],  # Mare Serenitatis area
        [width * 0.5, height * 0.8]   # Mare Crisium area
      ]

      maria_centers.each do |cx, cy|
        radius = (width * 0.15).to_i  # Large maria
        cy_int = cy.to_i
        cx_int = cx.to_i

        ((cy_int - radius)..(cy_int + radius)).each do |y|
          next if y < 0 || y >= height
          ((cx_int - radius)..(cx_int + radius)).each do |x|
            next if x < 0 || x >= width
            distance = Math.sqrt((x - cx)**2 + (y - cy)**2)
            if distance <= radius
              # Lower elevation for maria
              grid[y][x] *= 0.7
            end
          end
        end
      end
    end

    def add_crater_terrain(grid, crater_patterns, width, height)
      # Add crater topography using pattern data
      num_craters = width * height / 10000  # Density-based cratering

      num_craters.times do
        cx = rand(width)
        cy = rand(height)
        radius = rand(5..50)  # Various crater sizes

        # Create crater bowl shape
        cy_int = cy.to_i
        cx_int = cx.to_i
        radius_int = radius.to_i

        ((cy_int - radius_int)..(cy_int + radius_int)).each do |y|
          next if y < 0 || y >= height
          ((cx_int - radius_int)..(cx_int + radius_int)).each do |x|
            next if x < 0 || x >= width
            distance = Math.sqrt((x - cx)**2 + (y - cy)**2)
            if distance <= radius
              # Crater bowl: lower elevation toward center
              depth_factor = 1 - (distance / radius)**2
              grid[y][x] -= depth_factor * 1000  # Significant depth
            end
          end
        end
      end
    end

    def add_volcanic_terrain(grid, volcano_patterns, width, height)
      # Add volcanic features like Olympus Mons, Tharsis volcanoes
      volcano_centers = [
        [width * 0.4, height * 0.3],  # Tharsis region
        [width * 0.6, height * 0.2],  # Additional volcanoes
      ]

      volcano_centers.each do |cx, cy|
        radius = (width * 0.08).to_i
        height_gain = 20000  # Very tall volcanoes
        cy_int = cy.to_i
        cx_int = cx.to_i

        ((cy_int - radius)..(cy_int + radius)).each do |y|
          next if y < 0 || y >= height
          ((cx_int - radius)..(cx_int + radius)).each do |x|
            next if x < 0 || x >= width
            distance = Math.sqrt((x - cx)**2 + (y - cy)**2)
            if distance <= radius
              # Volcanic cone shape
              elevation_factor = 1 - (distance / radius)**2
              grid[y][x] += elevation_factor * height_gain
            end
          end
        end
      end
    end

    def add_mars_dichotomy(grid, width, height)
      # Mars has a hemispheric dichotomy: northern lowlands, southern highlands
      grid.each_with_index do |row, y|
        lat_factor = (y.to_f / height - 0.5) * 2  # -1 to 1
        dichotomy_offset = lat_factor * 3000  # Northern hemisphere lower

        row.each_with_index do |elev, x|
          grid[y][x] = elev + dichotomy_offset
        end
      end
    end

    def apply_blueprint_water_constraints(grid, historical_water_levels, width, height)
      puts "🌊 Applying blueprint water level constraints from historical shorelines..."

      water_features = historical_water_levels[:features] || []
      ocean_coverage = historical_water_levels[:estimated_ocean_coverage] || 0

      puts "   Found #{water_features.size} water features with #{ocean_coverage}% ocean coverage"

      # Scale blueprint coordinates to match grid dimensions
      # Assume blueprint uses Civ4 coordinate system (typically smaller than our grid)
      blueprint_width = water_features.map { |f| f[:x] }.max || 100
      blueprint_height = water_features.map { |f| f[:y] }.max || 100

      scale_x = width.to_f / blueprint_width
      scale_y = height.to_f / blueprint_height

      # Apply water level constraints
      water_features.each do |feature|
        # Scale coordinates to our grid
        grid_x = (feature[:x] * scale_x).to_i
        grid_y = (feature[:y] * scale_y).to_i

        next unless grid_x >= 0 && grid_x < width && grid_y >= 0 && grid_y < height

        # Apply elevation constraint based on water type
        elevation_adjustment = feature[:elevation_adjustment] || -0.2

        # Convert normalized elevation adjustment to actual elevation change
        # Assuming grid elevations are in meters, water should be at ~0 elevation
        current_elev = grid[grid_y][grid_x]
        target_elev = elevation_adjustment * 1000  # Convert to meters (assuming -200m for ancient shorelines)

        # Blend current elevation with water-constrained elevation
        blend_factor = 0.7  # Strong influence from blueprint
        constrained_elev = current_elev * (1 - blend_factor) + target_elev * blend_factor

        grid[grid_y][grid_x] = constrained_elev

        # Also affect neighboring cells for shoreline smoothing
        apply_shoreline_smoothing(grid, grid_x, grid_y, target_elev, width, height)
      end

      puts "   Applied water constraints to #{water_features.size} locations"
    end

    def apply_shoreline_smoothing(grid, center_x, center_y, target_elev, width, height)
      # Smooth shoreline transitions over neighboring cells
      radius = 3  # Affect nearby cells

      ((center_y - radius)..(center_y + radius)).each do |y|
        next if y < 0 || y >= height
        ((center_x - radius)..(center_x + radius)).each do |x|
          next if x < 0 || x >= width
          next if x == center_x && y == center_y  # Skip center

          distance = Math.sqrt((x - center_x)**2 + (y - center_y)**2)
          next if distance > radius

          # Apply diminishing influence with distance
          influence = (radius - distance) / radius * 0.3  # Max 30% influence
          current_elev = grid[y][x]
          smoothed_elev = current_elev * (1 - influence) + target_elev * influence

          grid[y][x] = smoothed_elev
        end
      end
    end

    def generate_fallback_terrain(body_type, width, height)
      puts "⚠️  Using fallback terrain generation for #{body_type}"

      # Simple procedural elevation generation as fallback
      elevation_grid = Array.new(height) do |y|
        Array.new(width) do |x|
          # Simple noise-based elevation
          base_elevation = Math.sin(x * 0.01) * Math.cos(y * 0.01) * 1000
          base_elevation.round(2)
        end
      end

      {
        grid: nil,  # No biome grid
        elevation: elevation_grid,
        width: width,
        height: height,
        body_type: body_type,
        generated_at: Time.current.iso8601,
        generator: 'MultiBodyTerrainGenerator',
        source: 'fallback_procedural',
        warning: 'No NASA patterns available'
      }
    end
  end
end