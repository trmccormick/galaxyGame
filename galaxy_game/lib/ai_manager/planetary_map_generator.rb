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
        # Generate a basic procedural map if no sources
        return generate_procedural_map(planet, options)
      end

      # Combine source maps into a planetary map
      combined_data = combine_source_maps(sources, planet, options)

      # Return comprehensive map data structure
      # Include BOTH old format (terrain_grid) AND new format (elevation, biomes) for compatibility
      {
        # Original format (for JSON storage)
        terrain_grid: combined_data[:terrain_grid],
        biome_counts: combined_data[:biome_counts],
        elevation_data: combined_data[:elevation_data],
        strategic_markers: combined_data[:strategic_markers],
        
        # Monitor-compatible format (aliases)
        elevation: combined_data[:elevation_data],  # Monitor expects this name
        terrain: combined_data[:terrain_grid],      # Could be different from biomes later
        biomes: combined_data[:terrain_grid],       # Same for now
        
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
          planet_id: planet.id
        }
      }
    end

    private

    def combine_source_maps(sources, planet, options)
      Rails.logger.info "[PlanetaryMapGenerator] Combining #{sources.size} source maps"

      # === EMERGENCY DEBUG: Check source biome variety ===
      Rails.logger.info "=== SOURCE MAP BIOME DEBUG ==="
      sources.each_with_index do |source, i|
        source_biomes = source.dig(:data, :biomes)
        
        if source_biomes
          sample = source_biomes[0].first(10) rescue []
          unique = source_biomes.flatten.uniq rescue []
          
          Rails.logger.info "Source #{i}: #{source[:filename]}"
          Rails.logger.info "  Sample row: #{sample.inspect}"
          Rails.logger.info "  Unique biomes: #{unique.inspect} (#{unique.size} types)"
        else
          Rails.logger.warn "Source #{i}: No biomes data found!"
        end
      end
      Rails.logger.info "=== END SOURCE DEBUG ==="

      # Use the first source as base and combine others
      base_source = sources.first
      base_data = base_source[:data]

      # Get dimensions (check multiple locations)
      width = options[:width] ||
              base_data[:width] || 
              base_data.dig(:lithosphere, :width) || 
              base_data[:biomes]&.first&.size || 
              80
              
      height = options[:height] ||
               base_data[:height] || 
               base_data.dig(:lithosphere, :height) || 
               base_data[:biomes]&.size || 
               50

      Rails.logger.info "[PlanetaryMapGenerator] Target dimensions: #{width}x#{height}"

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

      # === EMERGENCY DEBUG: Final terrain grid analysis ===
      sample_row = terrain_grid[0].first(20) rescue []
      unique_codes = terrain_grid.flatten.uniq rescue []
      Rails.logger.info "=== FINAL TERRAIN GRID DEBUG ==="
      Rails.logger.info "Sample first row: #{sample_row.inspect}"
      Rails.logger.info "Unique terrain codes: #{unique_codes.inspect} (#{unique_codes.size} types)"
      Rails.logger.info "Biome counts: #{biome_counts.inspect}"
      Rails.logger.info "=== END FINAL DEBUG ==="

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
          
          # === EMERGENCY DEBUG: Log biome conversion ===
          if target_y == 0 && target_x < 10  # First 10 cells of first row
            Rails.logger.info "[BIOME CONVERSION] Cell [#{target_y},#{target_x}]: #{biome.inspect} (#{biome.class}) → #{biome_code.inspect}"
          end
          
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