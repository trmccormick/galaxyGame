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

      # ADAPTIVE GRID: Use provided dimensions or calculate based on planet size
      width = options[:width] || calculate_adaptive_grid_size(planet, options[:target_resolution] || 800)
      height = options[:height] || (width * 0.625).to_i # Maintain aspect ratio

      Rails.logger.info "[PlanetaryMapGenerator] Using adaptive grid: #{width}x#{height} for #{planet.name} (diameter: #{planet.respond_to?(:diameter) ? planet.diameter : (planet.radius * 2) rescue 'unknown'}km)"

      # FIX: Load planet-specific elevation data instead of generic Earth reference
      elevation_grid = load_planet_specific_elevation(planet, width, height)
      
      # Track whether we used GeoTIFF data
      used_geotiff = !elevation_grid.nil?
      
      # If no planet-specific data, fall back to pattern-based generation
      if elevation_grid.nil?
        # Step 1: Generate planet-specific landmass pattern (not Earth reference)
        landmass_mask = generate_planet_specific_landmass(planet, width, height)

        # Step 2: Get NASA patterns for this planet type
        nasa_patterns = select_nasa_patterns_for_planet(planet)

        # Step 3: Generate elevation grid using patterns + landmass
        elevation_grid = generate_elevation_from_patterns(
          landmass_mask: landmass_mask,
          patterns: nasa_patterns,
          width: width,
          height: height
        )
      end

      # Step 4: Generate biomes (barren by default, can be terraformed later)
      biome_grid = generate_barren_biomes(
        elevation_grid: elevation_grid,
        planet: planet
      )

      # Step 5: Add resource markers and strategic locations
      resources = generate_resource_locations(elevation_grid, planet)
      strategic_markers = generate_strategic_markers_from_elevation(elevation_grid)

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
          quality: used_geotiff ? 'geotiff_based_realistic' : 'pattern_based_realistic',
          patterns_used: nasa_patterns&.keys || [],
          landmass_source: used_geotiff ? "#{planet.name.downcase}_geotiff" : "planet_specific_#{planet.name.downcase}"
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

    def generate_planet_specific_landmass(planet, width, height)
      # Generate unique landmass patterns for each planet based on its properties
      # This ensures planets without GeoTIFF data still have unique terrain
      
      # Use planet name as seed for reproducible but unique patterns
      seed = planet.name.downcase.sum
      
      # Get planet properties for variation
      temp_factor = (planet.surface_temperature || 288) / 288.0  # normalized to Earth temp
      size_factor = Math.log(planet.radius || 6371) / Math.log(6371)  # normalized to Earth radius
      
      landmass = Array.new(height) { Array.new(width, false) }
      
      (0...height).each do |y|
        (0...width).each do |x|
          # Create multiple noise layers with different frequencies
          noise1 = perlin_noise(x * 0.03 + seed, y * 0.03 + seed)
          noise2 = perlin_noise(x * 0.08 + seed * 2, y * 0.08 + seed * 2) * 0.5
          noise3 = perlin_noise(x * 0.15 + seed * 3, y * 0.15 + seed * 3) * 0.25
          
          # Combine noises
          combined_noise = noise1 + noise2 + noise3
          
          # Adjust land/water ratio based on planet type
          base_threshold = 0.3  # 30% land by default
          
          # Hot planets (Venus-like) have less land
          if temp_factor > 1.5
            base_threshold -= 0.1
          # Cold planets (Mars-like) have moderate land
          elsif temp_factor < 0.8
            base_threshold -= 0.05
          end
          
          # Large planets have more landmass variation
          if size_factor > 1.2
            base_threshold += 0.05
          elsif size_factor < 0.8
            base_threshold -= 0.05
          end
          
          # Determine if this is land
          is_land = combined_noise > base_threshold
          
          landmass[y][x] = is_land
        end
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

    # ADD new method to load planet-specific elevation data
    def load_planet_specific_elevation(planet, target_width, target_height)
      planet_name = planet.name.downcase
      
      # Map planet names to GeoTIFF filenames
      geotiff_files = {
        'earth' => 'earth_1800x900.asc.gz',
        'mars' => 'mars_1800x900.asc.gz', 
        'luna' => 'luna_1800x900.asc.gz',
        'venus' => 'venus_1800x900.asc.gz',
        'mercury' => 'mercury_1800x900.asc.gz',
        'titan' => 'titan_1800x900_final.asc.gz'
      }
      
      filename = geotiff_files[planet_name]
      return nil unless filename
      
      filepath = Rails.root.join('app', 'data', 'geotiff', 'processed', filename)
      return nil unless File.exist?(filepath)
      
      Rails.logger.info "[PlanetaryMapGenerator] Loading GeoTIFF elevation data for #{planet.name}"
      
      begin
        # Load and resample elevation data
        elevation_data = load_ascii_grid(filepath.to_s)
        
        # Resample to target dimensions
        resample_elevation_grid(
          elevation_data[:elevation], 
          elevation_data[:width], 
          elevation_data[:height],
          target_width,
          target_height
        )
      rescue => e
        Rails.logger.error "[PlanetaryMapGenerator] Failed to load elevation data for #{planet.name}: #{e.message}"
        nil
      end
    end

    def resample_elevation_grid(elevation_data, source_width, source_height, target_width, target_height)
      return nil if elevation_data.nil? || elevation_data.empty?
      
      resampled = Array.new(target_height) { Array.new(target_width, 0.0) }
      
      scale_x = source_width.to_f / target_width
      scale_y = source_height.to_f / target_height
      
      target_height.times do |y|
        target_width.times do |x|
          # Use bilinear interpolation for smooth resampling
          source_x = x * scale_x
          source_y = y * scale_y
          
          resampled[y][x] = bilinear_interpolate(elevation_data, source_x, source_y, source_width, source_height)
        end
      end
      
      resampled
    end

    def bilinear_interpolate(data, x, y, width, height)
      x1 = x.floor
      y1 = y.floor
      x2 = [x1 + 1, width - 1].min
      y2 = [y1 + 1, height - 1].min
      
      # Get the four surrounding points
      q11 = data[y1][x1] rescue 0.0
      q12 = data[y2][x1] rescue 0.0
      q21 = data[y1][x2] rescue 0.0
      q22 = data[y2][x2] rescue 0.0
      
      # Bilinear interpolation formula
      x_frac = x - x1
      y_frac = y - y1
      
      # Interpolate in x direction first
      r1 = q11 * (1 - x_frac) + q21 * x_frac
      r2 = q12 * (1 - x_frac) + q22 * x_frac
      
      # Then interpolate in y direction
      r1 * (1 - y_frac) + r2 * y_frac
    end

    def load_ascii_grid(filepath)
      return nil unless File.exist?(filepath)
      
      # Read the compressed ASCII grid file
      Zlib::GzipReader.open(filepath) do |gz|
        lines = gz.readlines.map(&:strip)
        
        # Parse ESRI ASCII Grid header
        ncols = lines[0].split[1].to_i
        nrows = lines[1].split[1].to_i
        xllcorner = lines[2].split[1].to_f
        yllcorner = lines[3].split[1].to_f
        cellsize = lines[4].split[1].to_f
        nodata = lines[5].split[1]
        
        # Parse elevation data
        elevation_lines = lines[6..-1]
        elevation = elevation_lines.map do |line|
          line.split.map do |val|
            val == nodata ? nil : val.to_f
          end
        end
        
        # Normalize to 0-1 range
        flat = elevation.flatten.compact
        return nil if flat.empty?
        
        min_elev = flat.min
        max_elev = flat.max
        range = max_elev - min_elev
        
        normalized = elevation.map do |row|
          row.map do |v|
            if v.nil?
              0.0  # Use 0 for nodata values
            else
              range > 0 ? (v - min_elev) / range : 0.5
            end
          end
        end
        
        {
          width: ncols,
          height: nrows,
          elevation: normalized,
          bounds: { xll: xllcorner, yll: yllcorner, cellsize: cellsize },
          original_range: { min: min_elev, max: max_elev }
        }
      end
    rescue => e
      Rails.logger.error "[PlanetaryMapGenerator] Error loading ASCII grid #{filepath}: #{e.message}"
      nil
    end

    private

    # Calculate adaptive grid size based on planet characteristics
    # Returns width dimension, height is calculated as width * 0.625
    def calculate_adaptive_grid_size(planet, target_resolution = 800)
      diameter_km = planet.respond_to?(:diameter) ? planet.diameter : (planet.radius * 2) || 12742 # Earth default
      body_type = planet.type || planet.body_category || 'planet'
      name = planet.name&.downcase || ''

      # Earth reference for scaling
      earth_diameter = 12742.0
      diameter_ratio = [0.01, diameter_km / earth_diameter].max # Prevent division by zero

      # Scale grid size: smaller bodies get relatively larger grids for detail
      base_grid_size = if diameter_km < 100
        # Small asteroids: high detail relative to size
        [40, [120, (80 * Math.sqrt(1.0 / diameter_ratio))].min].max
      elsif diameter_km < 1000
        # Moons like Luna, Europa: medium-high detail
        [50, [100, (80 * Math.sqrt(1.0 / diameter_ratio))].min].max
      elsif diameter_km < 5000
        # Small planets like Mars: standard detail
        [60, [120, (80 * Math.sqrt(diameter_ratio))].min].max
      else
        # Large planets/gas giants: reduced detail for performance
        [70, [150, (80 * diameter_ratio)].min].max
      end

      # Special cases for known bodies
      if name == 'luna' || name == 'moon' || body_type.include?('moon')
        base_grid_size = 60 # Higher detail for lunar craters
      elsif name == 'mars' || body_type.include?('terrestrial')
        base_grid_size = 90 # Good detail for Mars features
      elsif body_type.include?('gas_giant') || body_type.include?('ice_giant')
        base_grid_size = [120, base_grid_size].min # Limit for performance
      end

      # Calculate tile size for minimum visible resolution
      tile_size = [4, [24, target_resolution / base_grid_size].min].max

      # Adjust tile size based on body type for optimal detail
      if diameter_km < 500
        # Small bodies: larger tiles for visibility
        tile_size = [12, tile_size].max
      elsif diameter_km > 10000
        # Large bodies: smaller tiles for detail
        tile_size = [8, tile_size].min
      end

      # Ensure we don't exceed reasonable canvas sizes (browser limit ~4096px)
      max_canvas_size = 4096
      total_width = base_grid_size * tile_size
      total_height = (base_grid_size * 0.625) * tile_size

      if total_width > max_canvas_size || total_height > max_canvas_size
        scale = [max_canvas_size / total_width, max_canvas_size / total_height].min
        tile_size = [4, (tile_size * scale).floor].max
      end

      Rails.logger.info "[PlanetaryMapGenerator] Adaptive grid for #{planet.name}: #{base_grid_size.floor}×#{(base_grid_size * 0.625).floor} grid, #{tile_size}px tiles (diameter: #{diameter_km}km)"

      base_grid_size.floor
    end
  end
end