# lib/ai_manager/planetary_map_generator.rb
# AI-powered planetary map generation from FreeCiv/Civ4 sources

module AIManager
  class PlanetaryMapGenerator
    def initialize
      # Initialize AI map generation service
    end

    def generate_planetary_map(planet:, sources:, options: {})
      Rails.logger.info "[PlanetaryMapGenerator] Generating map for #{planet.name} using #{sources.size} source maps"

      # Check if NASA data source is specified - use it preferentially
      if options[:nasa_data_source]
        Rails.logger.info "[PlanetaryMapGenerator] NASA data source specified: #{options[:nasa_data_source]}"
        return generate_nasa_based_map(planet, options)
      end

      if sources.empty?
        # Generate a basic procedural map if no sources
        return generate_procedural_map(planet, options)
      end

      # Combine source maps into a planetary map
      combined_data = combine_source_maps(sources, planet, options)

      # Apply AI-powered resource positioning using learned patterns
      resource_service = AIManager::ResourcePositioningService.new
      enhanced_data = resource_service.place_resources_on_map(
        combined_data,
        planet_name: planet.name,
        options: options
      )

      # Return comprehensive map data structure
      # Include BOTH old format (terrain_grid) AND new format (elevation, biomes) for compatibility
      {
        # Original format (for JSON storage)
        terrain_grid: enhanced_data[:terrain_grid] || combined_data[:terrain_grid],
        biome_counts: combined_data[:biome_counts],
        elevation_data: combined_data[:elevation_data],
        strategic_markers: enhanced_data[:strategic_markers] || combined_data[:strategic_markers],
        
        # Monitor-compatible format (aliases)
        elevation: combined_data[:elevation_data],  # Monitor expects this name
        terrain: combined_data[:terrain_grid],      # Could be different from biomes later
        biomes: combined_data[:terrain_grid],       # Same for now
        
        # Resource positioning data
        resource_grid: enhanced_data[:resource_grid],
        resource_counts: enhanced_data[:resource_counts],
        
        # Planet info
        planet_name: planet.name,
        planet_type: planet.type,
        
        # Metadata
        metadata: {
          generated_at: Time.current.iso8601,
          source_maps: sources.map { |s| { type: s[:type], filename: s[:filename] } },
          generation_options: options,
          width: combined_data[:width],
          height: combined_data[:height],
          quality: combined_data[:quality],
          planet_name: planet.name,
          planet_type: planet.type,
          planet_id: planet.id,
          resources_placed: enhanced_data[:resource_counts]&.keys&.any? || false
        }
      }
    end

    private

    def combine_source_maps(sources, planet, options)
      Rails.logger.info "[PlanetaryMapGenerator] Combining #{sources.size} source maps"

      # Use the first source as base and combine others
      base_source = sources.first
      base_data = base_source[:data]

      # Get base dimensions from source or options
      base_width = options[:width] ||
                   base_data[:width] || 
                   base_data.dig(:lithosphere, :width) || 
                   base_data[:biomes]&.first&.size || 
                   80
                   
      base_height = options[:height] ||
                    base_data[:height] || 
                    base_data.dig(:lithosphere, :height) || 
                    base_data[:biomes]&.size || 
                    50

      # Scale dimensions based on planetary radius (Earth = baseline)
      width, height = scale_dimensions_for_planet(base_width, base_height, planet)
      
      Rails.logger.info "[PlanetaryMapGenerator] Base dimensions: #{base_width}x#{base_height}, Scaled for #{planet.name}: #{width}x#{height}"

      # Initialize combined grid
      terrain_grid = Array.new(height) { Array.new(width, 'p') } # default to plains
      elevation_grid = Array.new(height) { Array.new(width, 0.5) }
      biome_counts = Hash.new(0)

      # Process each source map
      valid_sources = 0
      
      sources.each_with_index do |source, index|
        source_data = source[:data]
        
        # Validate source data
        unless source_data.is_a?(Hash)
          Rails.logger.warn "[PlanetaryMapGenerator] Invalid source data for #{source[:filename]}"
          next
        end

        # Extract biomes and elevation from source
        source_biomes = source_data[:biomes]
        source_elevation = source_data.dig(:lithosphere, :elevation)
        
        unless source_biomes.is_a?(Array) && source_biomes.any?
          Rails.logger.warn "[PlanetaryMapGenerator] No biomes in source #{source[:filename]}"
          next
        end

        # Apply source data to combined grid
        apply_source_to_grid(terrain_grid, elevation_grid, source_biomes, source_elevation, index, sources.size)
        valid_sources += 1
      end

      # Check if any sources were valid
      if valid_sources == 0
        Rails.logger.warn "[PlanetaryMapGenerator] No valid sources processed, using procedural fallback"
        return generate_procedural_map(planet, options.merge(width: width, height: height))
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
        quality: "combined_from_#{valid_sources}_sources"
      }
    end

    def apply_source_to_grid(terrain_grid, elevation_grid, source_biomes, source_elevation, source_index, total_sources)
      return unless source_biomes.is_a?(Array)

      target_height = terrain_grid.size
      target_width = terrain_grid.first.size
      
      source_height = source_biomes.size
      source_width = source_biomes.first&.size || 0
      
      if source_height == 0 || source_width == 0
        Rails.logger.warn "[PlanetaryMapGenerator] Source has invalid dimensions"
        return
      end
      
      Rails.logger.info "[PlanetaryMapGenerator] Scaling #{source_width}x#{source_height} → #{target_width}x#{target_height}"

      # Calculate scaling factors
      scale_x = source_width.to_f / target_width
      scale_y = source_height.to_f / target_height

      # Apply to each cell in target grid
      target_height.times do |target_y|
        target_width.times do |target_x|
          # Find corresponding source cell (scaled)
          source_y = (target_y * scale_y).to_i
          source_x = (target_x * scale_x).to_i
          
          # Bounds check
          next if source_y >= source_height || source_x >= source_width
          
          row = source_biomes[source_y]
          next unless row.is_a?(Array) && source_x < row.size
          
          biome = row[source_x]
          
          # Convert biome to code if it's a symbol
          biome_code = biome.is_a?(Symbol) ? convert_biome_to_code(biome) : biome
          
          # Blend biomes (prefer first source, blend others with probability)
          if source_index == 0 || rand < 0.7
            terrain_grid[target_y][target_x] = biome_code if biome_code
          end
          
          # Apply elevation if available
          if source_elevation && 
             source_elevation.is_a?(Array) &&
             source_elevation[source_y].is_a?(Array) &&
             source_elevation[source_y][source_x]
            elevation_grid[target_y][target_x] = source_elevation[source_y][source_x]
          end
        end
      end
    end

    def convert_biome_to_code(biome)
      biome_code_map[biome] || 'p'  # Default to plains
    end

    def biome_code_map
      {
        ocean: 'o',
        deep_sea: 'o',
        grasslands: 'g',
        plains: 'p',
        forest: 'f',
        desert: 'd',
        tundra: 't',
        arctic: 'a',
        swamp: 's',
        jungle: 'j',
        boreal: 'f',
        rocky: 'r',
        mountains: 'm',
        hills: 'h'
      }
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

    def generate_nasa_based_map(planet, options)
      Rails.logger.info "[PlanetaryMapGenerator] Generating NASA-based map for #{planet.name}"

      nasa_file = options[:nasa_data_source]
      base_width = options[:width] || 80
      base_height = options[:height] || 50

      # Scale dimensions based on planetary radius
      width, height = scale_dimensions_for_planet(base_width, base_height, planet)

      # Try to use NASA-derived multi-body terrain generator
      body_type = planet_body_type(planet)
      if body_type && defined?(Terrain::MultiBodyTerrainGenerator)
        begin
          Rails.logger.info "[PlanetaryMapGenerator] Using NASA terrain generator for #{body_type}"
          terrain_generator = Terrain::MultiBodyTerrainGenerator.new
          terrain_data = terrain_generator.generate_terrain(body_type, width: width, height: height)

          # Convert to expected format
          terrain_grid = terrain_data[:grid]
          elevation_grid = terrain_data[:elevation]
          biome_counts = count_biomes(terrain_grid)

          return {
            terrain_grid: terrain_grid,
            biome_counts: biome_counts,
            elevation_data: elevation_grid,
            strategic_markers: [],
            planet_name: planet.name,
            planet_type: planet.type,
            metadata: {
              generated_at: Time.current.iso8601,
              source_maps: [{ type: 'nasa_geotiff', filename: nasa_file }],
              generation_options: options,
              width: width,
              height: height,
              generator: 'MultiBodyTerrainGenerator',
              body_type: body_type,
              nasa_derived: true,
              source: 'nasa_geotiff'
            }
          }
        rescue => e
          Rails.logger.warn "[PlanetaryMapGenerator] NASA terrain generation failed: #{e.message}, falling back to procedural"
        end
      end

      # Fallback to procedural if NASA generation fails
      generate_procedural_map(planet, options)
    end

    def generate_procedural_map(planet, options)
      Rails.logger.info "[PlanetaryMapGenerator] Generating procedural map for #{planet.name}"

      # Generate a simple procedural map when no sources available
      base_width = options[:width] || 80
      base_height = options[:height] || 50

      # Scale dimensions based on planetary radius
      width, height = scale_dimensions_for_planet(base_width, base_height, planet)

      # Try to use NASA-derived multi-body terrain generator first
      body_type = planet_body_type(planet)
      if body_type && defined?(Terrain::MultiBodyTerrainGenerator)
        begin
          Rails.logger.info "[PlanetaryMapGenerator] Using NASA-derived terrain for #{body_type}"
          terrain_generator = Terrain::MultiBodyTerrainGenerator.new
          terrain_data = terrain_generator.generate_terrain(body_type, width: width, height: height)

          # Convert to expected format
          terrain_grid = terrain_data[:grid]
          elevation_grid = terrain_data[:elevation]
          biome_counts = count_biomes(terrain_grid)

          return {
            terrain_grid: terrain_grid,
            biome_counts: biome_counts,
            elevation_data: elevation_grid,
            strategic_markers: [],
            planet_name: planet.name,
            planet_type: planet.type,
            metadata: {
              generated_at: Time.current.iso8601,
              source_maps: [],
              generation_options: options,
              width: width,
              height: height,
              generator: 'MultiBodyTerrainGenerator',
              body_type: body_type,
              nasa_derived: true
            }
          }
        rescue => e
          Rails.logger.warn "[PlanetaryMapGenerator] NASA terrain generation failed: #{e.message}, falling back to procedural"
        end
      end

      # Fallback to simple procedural generation
      Rails.logger.info "[PlanetaryMapGenerator] Using fallback procedural terrain generation"
      terrain_grid = Array.new(height) { Array.new(width) }
      elevation_grid = Array.new(height) { Array.new(width) }
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

          # Generate corresponding elevation
          elevation_grid[y][x] = case biome
          when 'o' then 0.2 + rand * 0.2  # Ocean: 0.2-0.4
          when 'g' then 0.4 + rand * 0.2  # Grasslands: 0.4-0.6
          when 'p' then 0.5 + rand * 0.2  # Plains: 0.5-0.7
          when 'f' then 0.6 + rand * 0.2  # Forest: 0.6-0.8
          when 'd' then 0.3 + rand * 0.3  # Desert: 0.3-0.6
          else 0.5
          end
        end
      end

      # Create base map data
      base_data = {
        terrain_grid: terrain_grid,
        biome_counts: biome_counts,
        elevation_data: elevation_grid,
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

      # Apply resource positioning even to procedural maps
      resource_service = AIManager::ResourcePositioningService.new
      enhanced_data = resource_service.place_resources_on_map(
        base_data,
        planet_name: planet.name,
        options: options
      )

      # Return enhanced data
      base_data.merge(
        resource_grid: enhanced_data[:resource_grid],
        resource_counts: enhanced_data[:resource_counts],
        strategic_markers: enhanced_data[:strategic_markers],
        metadata: base_data[:metadata].merge(resources_placed: enhanced_data[:resource_counts]&.keys&.any? || false)
      )
    end

    # Add NASA DEM data as training source for realistic terrain generation
    def add_nasa_dem_training_source(dem_file_path, planet_name: nil, options: {})
      Rails.logger.info "[PlanetaryMapGenerator] Adding NASA DEM training source: #{dem_file_path}"

      begin
        dem_importer = Import::NasaDemImporter.new
        dem_data = dem_importer.import_dem_file(dem_file_path, planet_name: planet_name, options: options)

        # Return in format compatible with combine_source_maps
        {
          type: 'nasa_dem',
          filename: File.basename(dem_file_path),
          data: {
            biomes: dem_data[:biomes],
            lithosphere: {
              elevation: dem_data[:elevation]
            },
            metadata: dem_data[:metadata]
          }
        }
      rescue => e
        Rails.logger.error "[PlanetaryMapGenerator] Failed to import NASA DEM #{dem_file_path}: #{e.message}"
        nil
      end
    end

    # Enhanced generation with NASA DEM training data
    def generate_with_nasa_training(planet:, civ4_sources: [], freeciv_sources: [], nasa_dem_files: [], options: {})
      Rails.logger.info "[PlanetaryMapGenerator] Generating with NASA training data for #{planet.name}"

      # Combine all training sources
      all_sources = []

      # Add Civ4 sources
      civ4_sources.each do |source|
        all_sources << source.merge(type: 'civ4')
      end

      # Add FreeCiv sources
      freeciv_sources.each do |source|
        all_sources << source.merge(type: 'freeciv')
      end

      # Add NASA DEM sources
      nasa_dem_files.each do |dem_file|
        dem_source = add_nasa_dem_training_source(dem_file, planet_name: planet.name)
        all_sources << dem_source if dem_source
      end

      # Generate using combined training data
      generate_planetary_map(planet: planet, sources: all_sources, options: options)
    end

    # Scale map dimensions based on planetary radius for realistic proportions
    def scale_dimensions_for_planet(base_width, base_height, planet)
      return [base_width, base_height] unless planet.respond_to?(:radius) && planet.radius && planet.radius > 0

      # Earth's radius in meters (baseline for scaling)
      earth_radius = 6_371_000.0
      planet_radius = planet.radius.to_f

      # Calculate scaling factor based on planetary radius
      # Use square root of radius ratio for 2D map area scaling
      radius_ratio = planet_radius / earth_radius
      scaling_factor = Math.sqrt(radius_ratio)

      # Apply scaling with minimum size constraints
      scaled_width = (base_width * scaling_factor).round
      scaled_height = (base_height * scaling_factor).round

      # Ensure minimum viable map size
      min_dimension = 20
      scaled_width = [scaled_width, min_dimension].max
      scaled_height = [scaled_height, min_dimension].max

      Rails.logger.info "[PlanetaryMapGenerator] Planet #{planet.name}: radius #{planet_radius}m (#{radius_ratio.round(3)}x Earth), scaling factor #{scaling_factor.round(3)}"

      [scaled_width, scaled_height]
    end

    def planet_body_type(planet)
      # Map planet names/types to body types for terrain generation
      name = planet.name.downcase
      type = planet.type.to_s.downcase

      case name
      when /moon|luna/i then 'luna'
      when /mars/i then 'mars'
      when /earth|terra/i then 'earth'
      else
        case type
        when /terrestrial|rocky/i then 'mars'  # Default to Mars-like for terrestrial planets
        when /airless|cratered/i then 'luna'   # Default to Luna-like for airless bodies
        else nil
        end
      end
    end

    def count_biomes(terrain_grid)
      # Count occurrences of each biome type in the terrain grid
      counts = Hash.new(0)
      terrain_grid.each do |row|
        row.each do |biome|
          counts[biome] += 1
        end
      end
      counts
    end
  end
end