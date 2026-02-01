# app/services/import/map_layer_service.rb
module Import
  class MapLayerService
    # Unified interface for processing map data from different sources
    # Handles Earth specially (full habitable rendering) vs other planets (bare + AI hints)

    def self.generate_layers(source: nil, planetary_conditions: {})
      planet_name = planetary_conditions[:name]&.downcase
      is_earth = planet_name&.include?('earth')

      if is_earth
        generate_earth_layers(source, planetary_conditions)
      else
        generate_planetary_layers(source, planetary_conditions)
      end
    end

    # Earth: Apply full map data directly (already habitable)
    def self.generate_earth_layers(source, conditions)
      processor = EarthMapProcessor.new

      # Try to find both FreeCiv and Civ4 Earth maps
      freeciv_path = find_earth_freeciv_map
      civ4_path = find_earth_civ4_map

      processor = EarthMapProcessor.new(
        freeciv_path: freeciv_path,
        civ4_path: civ4_path
      )

      earth_data = processor.process

      # Convert to standard layer format
      {
        lithosphere: {
          elevation: earth_data[:lithosphere][:elevation],
          structure: earth_data[:lithosphere][:structure]
        },
        hydrosphere: {
          water_mask: earth_data[:hydrosphere][:water_mask],
          current_coverage: earth_data[:hydrosphere][:current_coverage]
        },
        biosphere: {
          potential: earth_data[:biosphere][:potential],
          current_density: earth_data[:biosphere][:current_density] # 1.0 for Earth
        },
        metadata: {
          planet_type: 'earth',
          rendering_mode: 'full_habitable',
          sources_used: earth_data[:metadata][:sources_used]
        }
      }
    end

    # Other planets: Generate bare terrain + AI terraforming hints
    def self.generate_planetary_layers(source, conditions)
      case source
      when /\.sav$/i
        generate_from_freeciv(source, conditions)
      when /\.Civ4WorldBuilderSave$/i, /\.CivBeyondSwordWBSave$/i, /\.CivWarlordsWBSave$/i
        generate_from_civ4(source, conditions)
      else
        generate_procedural(conditions)
      end
    end

    private

    def self.find_earth_freeciv_map
      # Look for Earth FreeCiv maps
      Dir.glob(File.join(GalaxyGame::Paths::FREECIV_MAPS_PATH, 'earth*.sav')).first ||
      Dir.glob(File.join(GalaxyGame::Paths::PARTIAL_PLANETARY_MAPS_PATH, 'earth*.sav')).first ||
      Dir.glob(File.join(Rails.root, 'data', 'maps', 'freeciv', 'earth*.sav')).first ||
      Dir.glob(File.join(Rails.root, 'data', 'maps', 'partial_planetary', 'earth*.sav')).first
    end

    def self.find_earth_civ4_map
      # Look for Earth Civ4 maps (prefer larger/detailed ones)
      candidates = Dir.glob('data/Civ4_Maps/*earth*.Civ4WorldBuilderSave') +
                   Dir.glob('/Users/tam0013/Documents/git/galaxyGame/data/Civ4_Maps/*earth*.Civ4WorldBuilderSave')

      # Prefer larger maps
      candidates.max_by { |path| File.basename(path).match(/(\d+)x(\d+)/)&.captures&.map(&:to_i)&.inject(:*) || 0 }
    end

    def self.generate_from_civ4(file_path, conditions)
      civ4_data = Civ4WbsImportService.new(file_path).import

      unless civ4_data
        return generate_procedural(conditions)
      end

      # Generate elevation from Civ4 data
      elevation_extractor = Civ4ElevationExtractor.new
      elevation_data = elevation_extractor.extract(civ4_data)

      # Decompose into layers
      decomposer = TerrainDecompositionService.new({
        'grid' => civ4_data[:grid],
        'width' => civ4_data[:width],
        'height' => civ4_data[:height],
        'biome_counts' => civ4_data[:biome_counts]
      })

      decomposed = decomposer.decompose(conditions)

      # Extract AI hints for terraforming
      ai_hints = extract_ai_hints_from_civ4(civ4_data, conditions)

      {
        lithosphere: {
          elevation: elevation_data[:elevation],
          structure: decomposed['layers']['geological']
        },
        hydrosphere: {
          water_mask: decomposed['layers']['hydrological'],
          current_coverage: conditions[:water_percentage] || 0.0
        },
        biosphere: {
          potential: decomposed['layers']['biological'],
          current_density: 0.0  # Start bare
        },
        ai_terraforming_hints: ai_hints,
        metadata: {
          planet_type: 'planetary',
          rendering_mode: 'bare_terrain',
          source_type: 'civ4',
          elevation_quality: 'medium_70_80_percent'
        }
      }
    end

    def self.generate_from_freeciv(file_path, conditions)
      freeciv_data = FreecivSavImportService.new(file_path).import

      unless freeciv_data
        return generate_procedural(conditions)
      end

      # Generate elevation using constrained noise
      elevation = generate_freeciv_elevation(freeciv_data)

      # Decompose into layers
      decomposer = TerrainDecompositionService.new({
        'grid' => freeciv_data[:grid],
        'width' => freeciv_data[:width],
        'height' => freeciv_data[:height],
        'biome_counts' => freeciv_data[:biome_counts]
      })

      decomposed = decomposer.decompose(conditions)

      # Extract AI hints
      ai_hints = extract_ai_hints_from_freeciv(freeciv_data, conditions)

      {
        lithosphere: {
          elevation: elevation,
          structure: decomposed['layers']['geological']
        },
        hydrosphere: {
          water_mask: decomposed['layers']['hydrological'],
          current_coverage: conditions[:water_percentage] || 0.0
        },
        biosphere: {
          potential: decomposed['layers']['biological'],
          current_density: 0.0  # Start bare
        },
        ai_terraforming_hints: ai_hints,
        metadata: {
          planet_type: 'planetary',
          rendering_mode: 'bare_terrain',
          source_type: 'freeciv',
          elevation_quality: 'medium_60_70_percent'
        }
      }
    end

    def self.generate_procedural(conditions)
      width = conditions[:width] || 180
      height = conditions[:height] || 90
      seed = conditions[:seed] || conditions[:id] || rand(100000)

      # Generate pure elevation
      elevation = generate_perlin_elevation(width, height, seed)

      # Generate biome potential based on conditions
      biome_potential = generate_climate_based_biomes(elevation, conditions)

      {
        lithosphere: {
          elevation: elevation,
          structure: infer_structure_from_elevation(elevation)
        },
        hydrosphere: {
          water_mask: generate_water_zones(elevation, conditions),
          current_coverage: conditions[:water_percentage] || 0.0
        },
        biosphere: {
          potential: biome_potential,
          current_density: 0.0  # Start bare
        },
        metadata: {
          planet_type: 'planetary',
          rendering_mode: 'bare_terrain',
          source_type: 'procedural',
          elevation_quality: 'consistent_realistic'
        }
      }
    end

    # Helper methods for elevation generation
    def self.generate_freeciv_elevation(freeciv_data)
      # Use Perlin noise constrained to FreeCiv biome hints
      width = freeciv_data[:width]
      height = freeciv_data[:height]
      grid = freeciv_data[:grid]

      # Create base elevation map
      elevation_map = Array.new(height) do |y|
        Array.new(width) do |x|
          terrain_code = grid[y][x]
          base_elevation_for_freeciv_code(terrain_code)
        end
      end

      # Apply Perlin noise for realism
      add_perlin_noise(elevation_map)
    end

    def self.generate_perlin_elevation(width, height, seed)
      # Simple Perlin-like noise for elevation
      elevation_map = Array.new(height) do |y|
        Array.new(width) do |x|
          # Simple noise function (replace with proper Perlin if available)
          noise = Math.sin(x * 0.1 + seed) * Math.cos(y * 0.1 + seed) * 0.5 + 0.5
          noise * 0.8 + 0.1  # Scale to 0.1-0.9 range
        end
      end

      elevation_map
    end

    def self.base_elevation_for_freeciv_code(code)
      case code
      when ' ' then 0.1   # Ocean
      when ':' then 0.05  # Deep ocean
      when 'h' then 0.7   # Hills
      when 'm' then 0.9   # Mountains
      when 't' then 0.6   # Tundra
      when 'a' then 0.8   # Arctic
      else 0.4            # Default
      end
    end

    def self.add_perlin_noise(elevation_map)
      # Add some noise for realism
      height = elevation_map.length
      width = elevation_map.first.length

      height.times do |y|
        width.times do |x|
          noise = (rand - 0.5) * 0.2
          elevation_map[y][x] = [[elevation_map[y][x] + noise, 0.0].max, 1.0].min
        end
      end

      elevation_map
    end

    def self.generate_climate_based_biomes(elevation, conditions)
      # Generate biome potential based on elevation and planetary conditions
      temp = conditions[:temperature] || 288
      height = elevation.length
      width = elevation.first.length

      biome_map = Array.new(height) do |y|
        Array.new(width) do |x|
          elev = elevation[y][x]
          latitude_factor = (y.to_f / height - 0.5).abs * 2  # 0 at equator, 1 at poles

          # Simple biome determination
          if elev < 0.2
            0.0  # Water
          elsif elev > 0.8
            0.3  # Mountain tundra
          elsif latitude_factor > 0.7
            0.4  # Polar
          elsif temp < 273
            0.2  # Cold
          else
            0.8  # Temperate
          end
        end
      end

      biome_map
    end

    def self.generate_water_zones(elevation, conditions)
      water_percentage = conditions[:water_percentage] || 0.0
      return nil if water_percentage == 0.0

      # Simple water zone generation based on elevation
      height = elevation.length
      width = elevation.first.length

      # Find elevation threshold for water coverage
      all_elevations = elevation.flatten.sort
      water_threshold_index = (all_elevations.length * (1.0 - water_percentage)).to_i
      water_threshold = all_elevations[water_threshold_index] || 0.3

      water_mask = Array.new(height) do |y|
        Array.new(width) do |x|
          elevation[y][x] <= water_threshold ? 1.0 : 0.0
        end
      end

      water_mask
    end

    def self.infer_structure_from_elevation(elevation)
      # Infer geological structure from elevation patterns
      height = elevation.length
      width = elevation.first.length

      structure_map = Array.new(height) do |y|
        Array.new(width) do |x|
          elev = elevation[y][x]
          if elev < 0.2 then :ocean
          elsif elev < 0.4 then :plains
          elsif elev < 0.7 then :hills
          else :mountains
          end
        end
      end

      structure_map
    end

    # AI hint extraction methods
    def self.extract_ai_hints_from_civ4(civ4_data, conditions)
      {
        resource_potential: extract_resource_hints_civ4(civ4_data),
        settlement_candidates: extract_settlement_hints_civ4(civ4_data),
        infrastructure_patterns: extract_infrastructure_civ4(civ4_data),
        terraforming_difficulty: calculate_terraforming_difficulty_civ4(civ4_data, conditions)
      }
    end

    def self.extract_ai_hints_from_freeciv(freeciv_data, conditions)
      {
        resource_potential: extract_resource_hints_freeciv(freeciv_data),
        settlement_candidates: extract_settlement_hints_freeciv(freeciv_data),
        infrastructure_patterns: extract_infrastructure_freeciv(freeciv_data),
        terraforming_difficulty: calculate_terraforming_difficulty_freeciv(freeciv_data, conditions)
      }
    end

    # Placeholder methods for AI hints (to be implemented)
    def self.extract_resource_hints_civ4(data) { strategic: [], industrial: [], luxury: [] } end
    def self.extract_settlement_hints_civ4(data) [] end
    def self.extract_infrastructure_civ4(data) [] end
    def self.calculate_terraforming_difficulty_civ4(data, conditions) 1.0 end

    def self.extract_resource_hints_freeciv(data) { strategic: [], industrial: [], luxury: [] } end
    def self.extract_settlement_hints_freeciv(data) [] end
    def self.extract_infrastructure_freeciv(data) [] end
    def self.calculate_terraforming_difficulty_freeciv(data, conditions) 1.0 end
  end
end