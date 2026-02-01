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