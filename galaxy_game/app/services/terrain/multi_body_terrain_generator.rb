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
        elevation_grid = apply_mars_characteristics(elevation_grid, pattern_data['patterns'], width, height)
      when 'earth'
        elevation_grid = apply_earth_characteristics(elevation_grid, width, height)
      end

      # Convert elevation to terrain types
      terrain_grid = elevation_to_terrain_types(elevation_grid, body_type)

      # Generate comprehensive terrain data
      terrain_data = {
        grid: terrain_grid,
        elevation: elevation_grid,
        width: width,
        height: height,
        body_type: body_type,
        generated_at: Time.current.iso8601,
        generator: 'MultiBodyTerrainGenerator',
        source: 'NASA_DEM_patterns',
        characteristics: pattern_data['characteristics']
      }

      puts "✅ Generated #{body_type.upcase} terrain: #{width}x#{height} with #{terrain_grid.flatten.uniq.size} terrain types"
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

    def apply_mars_characteristics(elevation_grid, patterns, width, height)
      # Apply Mars-specific features: volcanoes, dichotomy, craters
      grid = elevation_grid.map(&:dup)

      # Add volcanic features
      add_volcanic_terrain(grid, patterns['volcanoes'], width, height)

      # Add hemispheric dichotomy
      add_mars_dichotomy(grid, width, height)

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

    def elevation_to_terrain_types(elevation_grid, body_type)
      # Convert elevation values to terrain type symbols
      grid = elevation_grid.map do |row|
        row.map do |elev|
          case body_type.to_s
          when 'luna'
            lunar_elevation_to_terrain(elev)
          when 'mars'
            mars_elevation_to_terrain(elev)
          when 'earth'
            earth_elevation_to_terrain(elev)
          else
            :plains  # Default
          end
        end
      end

      grid
    end

    def lunar_elevation_to_terrain(elevation)
      # Lunar terrain based on elevation
      case elevation
      when -2000..-500 then :maria      # Low-lying lava plains
      when -500..1000 then :highlands  # Lunar highlands
      else :mountains  # Peaks and crater rims
      end
    end

    def mars_elevation_to_terrain(elevation)
      # Martian terrain based on elevation
      case elevation
      when -8000..-2000 then :lowlands   # Vast northern plains
      when -2000..2000 then :plains     # Mid-elevation plains
      when 2000..8000 then :highlands   # Southern highlands
      else :mountains  # Volcanic peaks
      end
    end

    def earth_elevation_to_terrain(elevation)
      # Earth-like terrain based on elevation
      case elevation
      when -10000..-100 then :ocean
      when -100..0 then :coast
      when 0..500 then :plains
      when 500..1500 then :grasslands
      when 1500..3000 then :mountains
      else :arctic
      end
    end

    def generate_fallback_terrain(body_type, width, height)
      puts "⚠️  Using fallback terrain generation for #{body_type}"

      # Simple procedural generation as fallback
      grid = Array.new(height) do |y|
        Array.new(width) do |x|
          case body_type.to_s
          when 'luna' then [:maria, :highlands, :mountains].sample
          when 'mars' then [:lowlands, :plains, :highlands, :mountains].sample
          when 'earth' then [:ocean, :plains, :mountains].sample
          else :plains
          end
        end
      end

      {
        grid: grid,
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