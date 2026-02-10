# lib/ai_manager/planetary_map_generator.rb
# AI-powered planetary map generation from FreeCiv/Civ4 sources

module AIManager
  class PlanetaryMapGenerator
    def initialize
      # Initialize AI map generation service
    end

    def generate_planetary_map(planet:, sources:, options: {})
      Rails.logger.info "[PlanetaryMapGenerator] Generating map for #{planet.name} using #{sources.size} source maps"

      if sources.empty?
        # Generate pattern-based map using NASA patterns + Earth landmass shapes
        return generate_planetary_map_with_patterns(planet: planet, sources: sources, options: options)
      end

      # Combine source maps into a planetary map
      combined_data = combine_source_maps(sources, planet, options)

      # Return comprehensive map data structure
      {
        terrain_grid: combined_data[:terrain_grid],
        biome_counts: combined_data[:biome_counts],
        elevation_data: combined_data[:elevation_data],
        strategic_markers: combined_data[:strategic_markers],
        planet_name: planet.name,
        planet_type: planet.type,
        metadata: {
          generated_at: Time.current.iso8601,
          source_maps: sources.map { |s| { type: s[:type], filename: s[:filename] } },
          generation_options: options,
          width: combined_data[:width],
          height: combined_data[:height],
          quality: combined_data[:quality]
        }
      }
    end

    private

    def combine_source_maps(sources, planet, options)
      Rails.logger.info "[PlanetaryMapGenerator] Combining #{sources.size} source maps"

      # Use the first source as base and combine others
      base_source = sources.first
      base_data = base_source[:data]

      width = base_data.dig(:lithosphere, :width) || 80
      height = base_data.dig(:lithosphere, :height) || 50

      # Initialize combined grid
      terrain_grid = Array.new(height) { Array.new(width, 'p') } # default to plains
      elevation_grid = Array.new(height) { Array.new(width, 0.5) }
      biome_counts = Hash.new(0)

      # Process each source map
      sources.each_with_index do |source, index|
        source_data = source[:data]

        # Extract biomes and elevation from source
        if source_data[:biomes].is_a?(Array)
          source_biomes = source_data[:biomes]
          source_elevation = source_data.dig(:lithosphere, :elevation)

          # Apply source data to combined grid (with some randomization for variety)
          apply_source_to_grid(terrain_grid, elevation_grid, source_biomes, source_elevation, index, sources.size)
        end
      end

      # Count biomes
      terrain_grid.flatten.each { |biome| biome_counts[biome] += 1 }

      # Extract strategic markers (simplified)
      strategic_markers = extract_strategic_markers(terrain_grid)

      {
        terrain_grid: terrain_grid,
        elevation_data: elevation_grid,
        biome_counts: biome_counts,
        strategic_markers: strategic_markers,
        width: width,
        height: height,
        quality: 'combined_ai_generated'
      }
    end

    def apply_source_to_grid(terrain_grid, elevation_grid, source_biomes, source_elevation, source_index, total_sources)
      return unless source_biomes.is_a?(Array)

      height = terrain_grid.size
      width = terrain_grid.first.size

      # Apply with some offset/variation based on source index
      offset_x = (source_index * width / total_sources) % width
      offset_y = (source_index * height / total_sources) % height

      source_biomes.each_with_index do |row, y|
        next unless row.is_a?(Array)
        row.each_with_index do |biome, x|
          target_y = (y + offset_y) % height
          target_x = (x + offset_x) % width

          # Blend biomes (simplified - could be more sophisticated)
          if source_index == 0 || rand < 0.7 # Prefer first source, blend others
            terrain_grid[target_y][target_x] = biome
          end

          # Apply elevation if available
          if source_elevation && source_elevation[y] && source_elevation[y][x]
            elevation_grid[target_y][target_x] = source_elevation[y][x]
          end
        end
      end
    end

    def extract_strategic_markers(terrain_grid)
      markers = []
      height = terrain_grid.size
      width = terrain_grid.first.size

      # Simple strategic marker extraction
      height.times do |y|
        width.times do |x|
          biome = terrain_grid[y][x]
          # Mark coastal areas, mountains, etc. as strategic
          if biome == 'h' || biome == 'm' # hills/mountains
            markers << { type: 'high_ground', x: x, y: y, value: 8 }
          elsif biome == 'o' # ocean
            markers << { type: 'water_access', x: x, y: y, value: 6 }
          end
        end
      end

      markers
    end

    # Generate planetary map using NASA patterns + Earth landmass shapes
    def generate_planetary_map_with_patterns(planet:, sources:, options: {})
      Rails.logger.info "[PlanetaryMapGenerator] Generating pattern-based map for #{planet.name}"

      width = options[:width] || 80
      height = options[:height] || 50

      # Step 1: Get landmass reference (where continents should be)
      landmass_mask = load_earth_landmass_reference(target_width: width, target_height: height)

      # Step 2: Get NASA patterns for this planet type
      nasa_patterns = select_nasa_patterns_for_planet(planet)

      # Step 3: Generate elevation grid using patterns + landmass
      elevation_grid = generate_elevation_from_patterns(
        landmass_mask: landmass_mask,
        patterns: nasa_patterns,
        width: width,
        height: height
      )

      # Step 4: Generate biomes (barren by default, can be terraformed later)
      biome_grid = generate_barren_biomes(
        elevation_grid: elevation_grid,
        planet: planet
      )

      # Step 5: Add resource markers and strategic locations
      resources = generate_resource_locations(elevation_grid, planet)
      strategic_markers = generate_strategic_markers_from_elevation(elevation_grid)

      # Step 6: Count biomes
      biome_counts = Hash.new(0)
      biome_grid.flatten.each { |biome| biome_counts[biome] += 1 }

      {
        terrain_grid: biome_grid,
        biome_counts: biome_counts,
        elevation_data: elevation_grid,
        strategic_markers: strategic_markers,
        planet_name: planet.name,
        planet_type: planet.type,
        metadata: {
          generated_at: Time.current.iso8601,
          source_maps: [],
          generation_options: options,
          width: width,
          height: height,
          quality: 'pattern_based_realistic',
          patterns_used: nasa_patterns.keys,
          landmass_source: 'earth_reference'
        }
      }
    end

    def select_nasa_patterns_for_planet(planet)
      patterns = {}

      # Temperature-based pattern selection
      temp = planet.surface_temperature || 288

      if temp < 100
        # Icy world - use Luna patterns
        patterns.merge!(load_pattern_file('luna'))
      elsif temp < 200
        # Cold/airless - use Luna + Mars patterns
        patterns.merge!(load_pattern_file('luna'))
        patterns.merge!(load_pattern_file('mars'))
      elsif temp < 300
        # Temperate - use Earth + Mars patterns
        patterns.merge!(load_pattern_file('earth'))
        patterns.merge!(load_pattern_file('mars'))
      elsif temp < 400
        # Hot - use Venus patterns
        patterns.merge!(load_pattern_file('venus'))
      else
        # Very hot/volcanic - use Venus + Mercury patterns
        patterns.merge!(load_pattern_file('venus'))
        patterns.merge!(load_pattern_file('mercury'))
      end

      # Combine patterns (average the statistics)
      combine_patterns(patterns)
    end

    def load_pattern_file(body_name)
      pattern_file = Rails.root.join('data', 'json-data', 'ai_manager', "geotiff_patterns_#{body_name}.json")

      return {} unless File.exist?(pattern_file)

      JSON.parse(File.read(pattern_file))
    rescue JSON::ParserError => e
      Rails.logger.warn "[PlanetaryMapGenerator] Failed to parse pattern file #{pattern_file}: #{e.message}"
      {}
    end

    def combine_patterns(pattern_files)
      return {} if pattern_files.empty?

      # Average the statistical patterns
      combined = {
        'elevation_stats' => {},
        'crater_patterns' => {},
        'terrain_roughness' => {}
      }

      # Simple averaging of statistics
      count = pattern_files.size

      pattern_files.each do |file_patterns|
        if file_patterns['patterns'] && file_patterns['patterns']['elevation'] && file_patterns['patterns']['elevation']['statistics']
          stats = file_patterns['patterns']['elevation']['statistics']

          combined['elevation_stats']['mean'] ||= 0
          combined['elevation_stats']['std_dev'] ||= 0

          combined['elevation_stats']['mean'] += stats['mean'] || 0
          combined['elevation_stats']['std_dev'] += stats['std_dev'] || 0
        end
      end

      # Average by count
      if count > 0
        combined['elevation_stats']['mean'] /= count
        combined['elevation_stats']['std_dev'] /= count
      end

      combined
    end

    def load_earth_landmass_reference(target_width: 80, target_height: 50)
      # Try Civ4 Earth map first
      civ4_path = Rails.root.join('data', 'maps', 'civ4', 'earth', 'Earth.Civ4WorldBuilderSave')

      if File.exist?(civ4_path)
        return extract_landmass_from_civ4(civ4_path, target_width, target_height)
      end

      # Fall back to FreeCiv Earth map
      freeciv_path = Rails.root.join('data', 'maps', 'freeciv', 'earth', 'earth-180x90-v1-3.sav')

      if File.exist?(freeciv_path)
        return extract_landmass_from_freeciv(freeciv_path, target_width, target_height)
      end

      # Last resort: generate simple landmass pattern
      Rails.logger.warn "[PlanetaryMapGenerator] No Earth reference maps found, using simple landmass generation"
      generate_simple_landmass(target_width, target_height)
    end

    def extract_landmass_from_civ4(file_path, width, height)
      # Read Civ4 file and extract land/water mask
      # This is a simplified implementation - in production would parse Civ4 format
      content = File.read(file_path)

      # Extract plot types (PlotType 0-3: peak/hills/plains/ocean)
      # We just need land (0,1,2) vs water (3) distinction
      landmass = []

      # Simplified: assume first part of file contains plot data
      # In reality, would need proper Civ4 parsing
      plot_data = content.scan(/PlotType=(\d+)/).flatten

      plot_data.each do |plot_type|
        # 0,1,2 = land, 3 = ocean
        is_land = plot_type.to_i < 3
        landmass << is_land
      end

      # Reshape to 2D grid and resample to target size
      # (Simplified - implement proper resampling)
      reshape_and_resample_landmass(landmass, width, height)
    end

    def extract_landmass_from_freeciv(file_path, width, height)
      # Read FreeCiv .sav file and extract terrain patterns
      content = File.read(file_path)

      # Extract terrain characters (t0="...", t1="...", etc.)
      terrain_lines = content.scan(/t\d+="([^"]+)"/).flatten

      landmass = []
      terrain_lines.each do |line|
        line.chars.each do |char|
          # FreeCiv terrain codes: o=ocean, d=desert, p=plains, g=grassland, f=forest, etc.
          # Water tiles: o (ocean), c (coast), a (arctic)
          is_land = !['o', 'c', 'a'].include?(char)
          landmass << is_land
        end
      end

      # Resample to target size
      reshape_and_resample_landmass(landmass, width, height)
    end

    def reshape_and_resample_landmass(flat_landmass, target_width, target_height)
      # Convert flat array to 2D and resample
      # Simplified implementation
      landmass_2d = []

      # Assume source is roughly square, estimate dimensions
      source_size = Math.sqrt(flat_landmass.size).to_i
      source_width = source_height = source_size

      # Create 2D grid
      (0...source_height).each do |y|
        row = []
        (0...source_width).each do |x|
          index = y * source_width + x
          row << (flat_landmass[index] || false)
        end
        landmass_2d << row
      end

      # Simple resampling to target size
      resampled = Array.new(target_height) { Array.new(target_width, false) }

      scale_x = source_width.to_f / target_width
      scale_y = source_height.to_f / target_height

      (0...target_height).each do |y|
        (0...target_width).each do |x|
          source_x = (x * scale_x).to_i
          source_y = (y * scale_y).to_i

          if source_y < landmass_2d.size && source_x < landmass_2d[source_y].size
            resampled[y][x] = landmass_2d[source_y][source_x]
          end
        end
      end

      resampled
    end

    def generate_simple_landmass(width, height)
      # Fallback: create simple continent pattern using Perlin-like noise
      landmass = []

      (0...height).each do |y|
        row = []
        (0...width).each do |x|
          # Simple noise-based landmass generation
          noise = perlin_noise(x * 0.02, y * 0.02) +
                  perlin_noise(x * 0.1, y * 0.1) * 0.5

          # 40% land, 60% water
          is_land = noise > 0.2
          row << is_land
        end
        landmass << row
      end

      landmass
    end

    def perlin_noise(x, y)
      # Simplified Perlin noise implementation
      Math.sin(x) * Math.cos(y) +
        Math.sin(x * 2.3) * Math.cos(y * 1.7) * 0.5 +
        Math.sin(x * 5.1) * Math.cos(y * 4.8) * 0.25
    end

    def generate_elevation_from_patterns(landmass_mask:, patterns:, width:, height:)
      elevation_grid = Array.new(height) { Array.new(width, 0) }

      # Get elevation statistics from patterns
      land_mean = patterns.dig('elevation_stats', 'mean') || 0.5
      land_variance = patterns.dig('elevation_stats', 'std_dev') || 0.1
      ocean_mean = 0.0  # Sea level
      ocean_variance = 0.05

      (0...height).each do |y|
        (0...width).each do |x|
          is_land = landmass_mask[y] && landmass_mask[y][x]

          if is_land
            # Land elevation with Gaussian variation
            elevation = gaussian_random(land_mean, land_variance)
            # Clamp to reasonable range
            elevation = [[elevation, 0.0].max, 1.0].min
          else
            # Ocean depth with less variation
            elevation = gaussian_random(ocean_mean, ocean_variance)
            # Clamp to negative values for ocean
            elevation = [[elevation, -0.5].max, 0.1].min
          end

          elevation_grid[y][x] = elevation
        end
      end

      # Apply smoothing to remove sharp edges
      smooth_elevation_grid(elevation_grid)
    end

    def gaussian_random(mean, variance)
      # Box-Muller transform for Gaussian distribution
      u1 = rand
      u2 = rand

      z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math::PI * u2)

      mean + z * Math.sqrt(variance)
    end

    def smooth_elevation_grid(grid)
      # Apply 3x3 smoothing kernel to remove sharp transitions
      height = grid.size
      width = grid[0].size
      smoothed = Array.new(height) { Array.new(width, 0) }

      (0...height).each do |y|
        (0...width).each do |x|
          sum = 0
          count = 0

          # 3x3 kernel
          (-1..1).each do |dy|
            (-1..1).each do |dx|
              ny, nx = y + dy, x + dx
              if ny >= 0 && ny < height && nx >= 0 && nx < width
                sum += grid[ny][nx]
                count += 1
              end
            end
          end

          smoothed[y][x] = sum / count.to_f
        end
      end

      smoothed
    end

    def generate_barren_biomes(elevation_grid:, planet:)
      # For barren worlds, biomes based on elevation only
      # (No vegetation, just terrain types)

      height = elevation_grid.size
      width = elevation_grid[0].size

      biome_grid = Array.new(height) { Array.new(width) }

      (0...height).each do |y|
        (0...width).each do |x|
          elevation = elevation_grid[y][x]

          biome = if elevation < 0.0
                    'o'  # ocean (below sea level)
                  elsif elevation < 0.2
                    'c'  # coast (near sea level)
                  elsif elevation < 0.4
                    'p'  # plains (low elevation)
                  elsif elevation < 0.7
                    'h'  # hills (medium elevation)
                  elsif elevation < 0.9
                    'm'  # mountains (high elevation)
                  else
                    'k'  # peaks (very high elevation)
                  end

          biome_grid[y][x] = biome
        end
      end

      biome_grid
    end

    def generate_resource_locations(elevation_grid, planet)
      # Generate resource markers based on elevation patterns
      # Simplified implementation
      []
    end

    def generate_strategic_markers_from_elevation(elevation_grid)
      # Generate strategic markers based on elevation
      markers = []
      height = elevation_grid.size
      width = elevation_grid[0].size

      height.times do |y|
        width.times do |x|
          elevation = elevation_grid[y][x]

          # Mark high ground and coastal areas
          if elevation > 0.8
            markers << { type: 'high_ground', x: x, y: y, value: 8 }
          elsif elevation >= 0.0 && elevation <= 0.1
            markers << { type: 'coastal', x: x, y: y, value: 6 }
          end
        end
      end

      markers
    end

    def generate_procedural_map(planet, options)
      Rails.logger.info "[PlanetaryMapGenerator] Generating procedural map for #{planet.name}"

      # Generate a simple procedural map when no sources available
      width = options[:width] || 80
      height = options[:height] || 50

      terrain_grid = Array.new(height) { Array.new(width) }
      biome_counts = Hash.new(0)

      # Simple procedural generation
      height.times do |y|
        width.times do |x|
          # Simple noise-based biome selection
          noise = Math.sin(x * 0.1) * Math.cos(y * 0.1) + rand * 0.5

          biome = case noise
          when -2.0..-0.5 then 'o'  # ocean
          when -0.5..0.0 then 'g'  # grasslands
          when 0.0..0.5 then 'p'   # plains
          when 0.5..1.0 then 'f'   # forest
          else 'd'  # desert
          end

          terrain_grid[y][x] = biome
          biome_counts[biome] += 1
        end
      end

      {
        terrain_grid: terrain_grid,
        biome_counts: biome_counts,
        elevation_data: Array.new(height) { Array.new(width, 0.5) },
        strategic_markers: [],
        planet_name: planet.name,
        planet_type: planet.type,
        metadata: {
          generated_at: Time.current.iso8601,
          source_maps: [],
          generation_options: options,
          width: width,
          height: height,
          quality: 'procedural_generated'
        }
      }
    end
  end
end