# galaxy_game/app/services/star_sim/automatic_terrain_generator.rb
# Automatic terrain generation for new star systems based on planetary properties
# Integrates AI-learned patterns with realistic planet characteristics

require 'import/freeciv_map_processor'
require 'import/civ4_map_processor'
require 'terrain/multi_body_terrain_generator'

module StarSim
  class AutomaticTerrainGenerator
    def initialize
      # Lazy initialization of services to avoid autoload issues
    end

    def planetary_map_generator
      @planetary_map_generator ||= AIManager::PlanetaryMapGenerator.new
    end

    def earth_processor
      @earth_processor ||= Import::EarthMapProcessor.new
    end

    def quality_assessor
      @quality_assessor ||= TerrainAnalysis::TerrainQualityAssessor.new
    end

    # Generate terrain for a newly created celestial body
    def generate_terrain_for_body(celestial_body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating terrain for #{celestial_body.name}"

      # Skip if body already has terrain or isn't a planet/moon
      return if celestial_body.geosphere&.terrain_map.present?
      return unless should_generate_terrain?(celestial_body)

      # Special handling for Sol system worlds with known data
      if sol_system_world?(celestial_body)
        return generate_sol_world_terrain(celestial_body)
      end

      # Analyze planet properties to determine terrain parameters
      terrain_params = analyze_planet_properties(celestial_body)

      # Generate base terrain using NASA data and radius-based scaling
      base_terrain = generate_base_terrain(celestial_body, terrain_params)

      # Special handling for Earth-like planets
      if earth_like_planet?(celestial_body)
        base_terrain = apply_earth_specific_processing(base_terrain, celestial_body)
      end

      # Store the generated terrain
      store_generated_terrain(celestial_body, base_terrain)

      Rails.logger.info "[AutomaticTerrainGenerator] Terrain generation complete for #{celestial_body.name}"
      base_terrain
    end

    # Determine if this body should get automatic terrain generation
    def should_generate_terrain?(body)
      # Generate terrain for terrestrial planets and major moons
      case body.class.name
      when /TerrestrialPlanet/, /SuperEarth/, /CarbonPlanet/
        true
      when /Moon/
        # Only major moons get detailed terrain
        major_moons = ['Luna', 'Titan', 'Ganymede', 'Callisto', 'Io', 'Europa']
        major_moons.include?(body.name) || body.mass.to_f > 1e20
      else
        false
      end
    end

    # Analyze planet properties to determine terrain generation parameters
    def analyze_planet_properties(body)
      params = {
        terrain_complexity: calculate_terrain_complexity(body),
        biome_density: calculate_biome_density(body),
        elevation_scale: calculate_elevation_scale(body),
        water_coverage: body.hydrosphere&.water_coverage || 0,
        atmospheric_pressure: body.atmosphere&.pressure || 0,
        surface_temperature: body.surface_temperature || 288
      }

      # Adjust for planet type
      case body.class.name
      when /LavaWorld/
        params[:volcanic_activity] = 'high'
        params[:biome_density] *= 0.3  # Reduced biomes on lava worlds
      when /OceanPlanet/
        params[:water_coverage] = [params[:water_coverage], 80].max
        params[:biome_density] *= 0.7  # Some biomes underwater
      end

      params
    end

    private

    # Calculate terrain complexity based on planet characteristics
    def calculate_terrain_complexity(body)
      complexity = 0.5  # Base complexity

      # Size factor
      radius_km = body.radius.to_f / 1000
      if radius_km > 10000  # Super Earth
        complexity += 0.3
      elsif radius_km < 5000  # Small planet
        complexity -= 0.2
      end

      # Geological activity
      if body.properties['volcanic_activity'] == 'high'
        complexity += 0.2
      end

      # Atmospheric effects
      if body.atmosphere&.pressure.to_f > 1.0
        complexity += 0.1  # Weathering and erosion
      end

      # Age factor (older planets have more complex geology)
      # This would need age data from the planet properties

      complexity.clamp(0.1, 1.0)
    end

    # Calculate biome density based on habitability
    def calculate_biome_density(body)
      # Earth gets full biome density
      return 1.0 if body.name.downcase == 'earth'

      density = 0.0

      # Temperature factor
      temp = body.surface_temperature || 288
      if temp.between?(273, 373)  # Liquid water range
        density += 0.4
      elsif temp.between?(200, 400)  # Extended habitable range
        density += 0.2
      end

      # Water factor
      water = body.hydrosphere&.water_coverage || 0
      density += (water / 100.0) * 0.3

      # Atmospheric factor
      pressure = body.atmosphere&.pressure || 0
      if pressure.between?(0.1, 10.0)  # Reasonable pressure range
        density += 0.2
      end

      # Magnetic field protection
      if body.magnetic_field.to_f > 10
        density += 0.1
      end

      density.clamp(0.0, 0.8)  # Cap at 0.8, Earth gets 1.0
    end

    # Calculate elevation scale based on planet size and composition
    def calculate_elevation_scale(body)
      radius_km = body.radius.to_f / 1000
      density = body.density || 5.5  # g/cm³

      # Larger, less dense planets have more varied elevation
      scale = Math.log10(radius_km) * (6.0 / density)

      scale.clamp(0.5, 2.0)
    end

    # Generate base terrain using PlanetaryMapGenerator
    def generate_base_terrain(body, params)
      generator_params = {
        radius: body.radius,
        planet_name: body.name,
        complexity: params[:terrain_complexity],
        elevation_scale: params[:elevation_scale],
        water_coverage: params[:water_coverage],
        temperature: params[:surface_temperature]
      }

      # Use NASA data if available for this planet
      if nasa_data_available?(body.name)
        generator_params[:nasa_data_source] = find_nasa_data(body.name)
      end

      # Get raw terrain data from PlanetaryMapGenerator
      raw_terrain = planetary_map_generator.generate_planetary_map(
        planet: body,
        sources: generator_params[:sources] || [],
        options: generator_params
      )

      # Transform into expected format
      {
        grid: raw_terrain[:terrain_grid],  # The terrain grid with biome letters
        elevation: generate_elevation_data_from_grid(raw_terrain[:terrain_grid]),  # Elevation values (2D)
        biomes: raw_terrain[:biome_counts],  # Biome counts
        resource_grid: generate_resource_grid(body, raw_terrain),
        strategic_markers: generate_strategic_markers(body, raw_terrain),
        resource_counts: generate_resource_counts(raw_terrain)
      }
    end

    # Generate elevation data from biome grid
    def generate_elevation_data(biome_grid)
      # Convert biome letters to elevation values
      # This is a simplified mapping - in reality this would be more complex
      elevation_map = {
        'd' => 0,    # desert - low elevation
        'f' => 500,  # forest - medium elevation
        'g' => 1000, # grassland - medium-high
        'o' => -200, # ocean - below sea level
        'p' => 800   # plains - medium elevation
      }

      # Assume a roughly square grid for 2D conversion
      grid_size = biome_grid.size
      side_length = Math.sqrt(grid_size).ceil
      elevation_grid = Array.new(side_length) { Array.new(side_length) }

      biome_grid.each_with_index do |biome, index|
        row = index / side_length
        col = index % side_length
        next if row >= side_length || col >= side_length

        base_elevation = elevation_map[biome] || 0
        # Add some random variation to avoid NaN in statistical calculations
        elevation_grid[row][col] = base_elevation + rand(-50..50)
      end

      elevation_grid
    end

    # Generate elevation data from 2D terrain grid
    def generate_elevation_data_from_grid(terrain_grid_2d)
      return [] unless terrain_grid_2d.is_a?(Array) && terrain_grid_2d.first.is_a?(Array)

      height = terrain_grid_2d.size
      width = terrain_grid_2d.first.size

      # Elevation mapping for different terrain types
      elevation_map = {
        'o' => -200,  # ocean - below sea level
        'd' => 0,     # desert - low elevation
        'p' => 800,   # plains - medium elevation
        'g' => 1000,  # grassland - medium-high
        'f' => 500,   # forest - medium elevation
        'j' => 600,   # jungle - medium elevation
        'm' => 1500,  # mountains - high elevation
        'h' => 1200,  # hills - medium-high
        'a' => 800,   # arctic - medium (ice caps)
        't' => 900,   # tundra - medium-high
        's' => 100,   # swamp - low elevation
        'r' => 1100,  # rock - medium-high
        'b' => 700    # boreal - medium
      }

      elevation_grid = Array.new(height) { Array.new(width) }

      height.times do |y|
        width.times do |x|
          biome = terrain_grid_2d[y][x]
          base_elevation = elevation_map[biome] || 0
          # Add random variation for realism
          elevation_grid[y][x] = base_elevation + rand(-50..50)
        end
      end

      elevation_grid
    end

    # Convert 1D array to 2D grid
    def convert_to_2d_grid(data_1d)
      return data_1d if data_1d.first.is_a?(Array) # Already 2D

      grid_size = data_1d.size
      side_length = Math.sqrt(grid_size).ceil
      grid_2d = Array.new(side_length) { Array.new(side_length) }

      data_1d.each_with_index do |value, index|
        row = index / side_length
        col = index % side_length
        next if row >= side_length || col >= side_length
        grid_2d[row][col] = value
      end

      grid_2d
    end

    # Generate resource grid based on terrain
    def generate_resource_grid(body, raw_terrain)
      # Create a 2D grid for resources
      grid_size = raw_terrain[:elevation_data].size
      # Assume a roughly square grid
      side_length = Math.sqrt(grid_size).ceil
      total_cells = side_length * side_length

      # Create 2D array
      grid = Array.new(side_length) { Array.new(side_length) }

      # Fill with resources randomly
      raw_terrain[:elevation_data].each_with_index do |biome, index|
        row = index / side_length
        col = index % side_length
        next if row >= side_length || col >= side_length

        # 10% chance of minerals, higher in certain biomes
        chance = case biome
                 when 'd', 'g' then 0.15  # Desert and grassland have more minerals
                 when 'f' then 0.05      # Forest has fewer
                 else 0.08               # Default
                 end

        grid[row][col] = rand < chance ? 'mineral' : nil
      end

      grid
    end

    # Generate strategic markers
    def generate_strategic_markers(body, raw_terrain)
      # Generate some strategic locations
      markers = []
      grid_size = raw_terrain[:elevation_data].size
      side_length = Math.sqrt(grid_size).ceil

      # Add a few random strategic markers
      3.times do
        x = rand(side_length)
        y = rand(side_length)
        markers << {
          x: x,
          y: y,
          type: ['landing_site', 'resource_rich', 'strategic'].sample,
          value: rand(1..10)
        }
      end

      markers
    end

    # Generate resource counts
    def generate_resource_counts(raw_terrain)
      # Simple resource counts based on terrain
      {
        minerals: raw_terrain[:elevation_data].count { |b| ['d', 'g'].include?(b) } / 10,
        water: raw_terrain[:elevation_data].count { |b| b == 'o' } / 5,
        organics: raw_terrain[:elevation_data].count { |b| ['f', 'p'].include?(b) } / 8
      }
    end

    # Apply Earth-specific processing for highly habitable planets
    def apply_earth_specific_processing(terrain_data, body)
      # For now, return terrain data as-is
      # Earth-specific processing would require different implementation
      terrain_data
    end

    # Check if NASA data is available for this planet
    def nasa_data_available?(planet_name)
      # For now, return false - NASA data integration would be implemented separately
      false
    end

    # Find NASA data source for planet
    def find_nasa_data(planet_name)
      # Placeholder for NASA data lookup
      nil
    end

    private

    # Store generated terrain in the geosphere
    def store_generated_terrain(body, terrain_data)
      geosphere = body.geosphere || body.create_geosphere!

      # Assess terrain quality
      planet_properties = {
        radius: body.radius,
        surface_temperature: body.surface_temperature,
        mass: body.mass
      }
      quality_scores = quality_assessor.assess_terrain_quality(terrain_data, planet_properties)

      geosphere.update!(
        terrain_map: {
          grid: terrain_data[:grid],
          elevation: terrain_data[:elevation],
          biomes: terrain_data[:biomes],
          resource_grid: terrain_data[:resource_grid],
          strategic_markers: terrain_data[:strategic_markers],
          resource_counts: terrain_data[:resource_counts],
          generation_method: 'automatic_ai_driven',
          generation_date: Time.current,
          source: 'planetary_properties_analysis',
          quality_score: calculate_terrain_quality(terrain_data),
          quality_assessment: quality_scores,
          planet_properties: planet_properties
        }
      )
    end

    # Calculate overall terrain quality score
    def calculate_terrain_quality(terrain_data)
      score = 0.5  # Base score

      # Resource diversity
      resource_types = terrain_data[:resource_counts]&.keys&.size || 0
      score += [resource_types * 0.05, 0.2].min

      # Strategic markers
      markers = terrain_data[:strategic_markers]&.size || 0
      score += [markers * 0.02, 0.2].min

      # Terrain variety (would need analysis of elevation/biome variance)

      score.clamp(0.0, 1.0)
    end

    # Check if NASA data is available for this planet
    def nasa_data_available?(planet_name)
      # For now, return false - NASA data integration would be implemented separately
      false
    end

    # Find NASA data source for planet
    def find_nasa_data(planet_name)
      # Placeholder for NASA data lookup
      nil
    end

    # Check if this is a Sol system world with known data sources
    def sol_system_world?(body)
      sol_worlds = ['earth', 'mars', 'luna', 'moon']
      sol_worlds.include?(body.name.downcase)
    end

    # Generate terrain for Sol system worlds using known data sources
    def generate_sol_world_terrain(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating terrain for Sol world: #{body.name}"

      case body.name.downcase
      when 'earth'
        generate_earth_terrain(body)
      when 'mars'
        generate_mars_terrain(body)
      when 'luna', 'moon'
        generate_luna_terrain(body)
      else
        # Fallback to procedural generation
        terrain_params = analyze_planet_properties(body)
        generate_base_terrain(body, terrain_params)
      end
    end

    # Generate Earth terrain using FreeCiv/Civ4 data
    def generate_earth_terrain(body)
      processor = Import::EarthMapProcessor.new
      earth_data = processor.process

      # Convert to terrain format - elevation only, no biome classification
      terrain_data = {
        grid: nil,  # No biome grid for terrain generation layer
        elevation: earth_data[:lithosphere][:elevation],
        biomes: {},  # Empty - biomes handled in rendering layer
        resource_grid: generate_resource_grid_from_earth_data(earth_data),
        strategic_markers: generate_strategic_markers_from_earth_data(earth_data),
        resource_counts: generate_resource_counts_from_earth_data(earth_data)
      }

      store_generated_terrain(body, terrain_data)
      terrain_data
    end

    # Generate Mars terrain using FreeCiv/Civ4 and NASA data
    def generate_mars_terrain(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating Mars terrain using three-layer system"

      # Layer 1: NASA elevation base (1800x900) - pure topographic data
      nasa_elevation = generate_nasa_base_elevation(body)

      # Layer 2: Civ4 terraforming scenario overlay (scaled to 1800x900)
      # This represents "Mars After Terraforming" - a habitable future state
      civ4_terraforming_scenario = generate_civ4_terraforming_scenario(body)

      # Layer 3: FreeCiv full terraforming target storage (scaled to 1800x900)
      # This represents complete terraforming with 40% ocean coverage
      freeciv_complete_targets = generate_freeciv_complete_targets(body)

      # Combine layers: NASA base with Civ4 scenario overlay for current representation
      combined_elevation = combine_elevation_layers(nasa_elevation, civ4_terraforming_scenario)

      terrain_data = {
        grid: nil,  # No biome grid - handled in rendering layer
        elevation: combined_elevation,
        biomes: {},  # Empty - biomes handled in rendering layer
        resource_grid: generate_mars_resource_grid(combined_elevation),
        strategic_markers: generate_mars_strategic_markers(combined_elevation),
        resource_counts: generate_mars_resource_counts(combined_elevation),
        # Store future terraforming possibilities for AI Manager/TerraSim planning
        terraforming_scenarios: {
          civ4_partial_habitable: civ4_terraforming_scenario,  # Partially terraformed Mars
          freeciv_complete_terraformed: freeciv_complete_targets  # Fully terraformed Mars
        },
        generation_metadata: {
          layers_used: [:nasa_base, :civ4_scenario_overlay, :freeciv_targets_storage],
          nasa_source: 'geotiff_patterns_mars.json',
          civ4_source: find_mars_civ4_map,
          freeciv_source: find_mars_freeciv_map,
          architecture: 'future_possibility_spaces'
        }
      }

      store_generated_terrain(body, terrain_data)
      terrain_data
    end

    # Generate NASA base elevation using MultiBodyTerrainGenerator
    def generate_nasa_base_elevation(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating NASA base elevation for Mars"

      # Use MultiBodyTerrainGenerator for NASA patterns - NO blueprint constraints
      generator = Terrain::MultiBodyTerrainGenerator.new
      mars_data = generator.generate_terrain('mars', width: 1800, height: 900, options: {})

      mars_data[:elevation]
    end

    # Generate Civ4 current-state overlay
    # Generate Civ4 terraforming scenario (partially habitable Mars future state)
    def generate_civ4_terraforming_scenario(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating Civ4 terraforming scenario"

      civ4_path = find_mars_civ4_map
      return nil unless civ4_path

      begin
        processor = Import::Civ4MapProcessor.new
        civ4_data = processor.process(civ4_path, mode: :terrain)

        # Scale Civ4 elevation (typically 80x57) to 1800x900 grid
        scaled_elevation = scale_grid_to_target(
          civ4_data[:lithosphere][:elevation],
          civ4_data[:lithosphere][:width],
          civ4_data[:lithosphere][:height],
          1800, 900
        )

        Rails.logger.info "[AutomaticTerrainGenerator] Scaled Civ4 elevation from #{civ4_data[:lithosphere][:width]}x#{civ4_data[:lithosphere][:height]} to 1800x900"
        scaled_elevation
      rescue => e
        Rails.logger.warn "[AutomaticTerrainGenerator] Failed to process Civ4 data: #{e.message}"
        nil
      end
    end

    # Generate FreeCiv complete terraforming targets (fully terraformed Mars with 40% oceans)
    def generate_freeciv_complete_targets(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating FreeCiv complete terraforming targets"

      freeciv_path = find_mars_freeciv_map
      return nil unless freeciv_path

      begin
        processor = Import::FreecivMapProcessor.new
        freeciv_data = processor.process(freeciv_path)

        # Scale FreeCiv data (typically 133x64) to 1800x900 grid
        scaled_elevation = scale_grid_to_target(
          freeciv_data[:lithosphere][:elevation],
          freeciv_data[:lithosphere][:width],
          freeciv_data[:lithosphere][:height],
          1800, 900
        )

        # Return complete terraforming targets data structure for TerraSim
        {
          elevation: scaled_elevation,
          biomes: freeciv_data[:biomes],
          strategic_markers: freeciv_data[:strategic_markers],
          source_file: freeciv_path,
          scaling_info: {
            original_size: "#{freeciv_data[:lithosphere][:width]}x#{freeciv_data[:lithosphere][:height]}",
            scaled_size: "1800x900"
          },
          terraforming_state: 'complete_40_percent_oceans'
        }
      rescue => e
        Rails.logger.warn "[AutomaticTerrainGenerator] Failed to process FreeCiv data: #{e.message}"
        nil
      end
    end

    # Combine NASA base elevation with Civ4 terraforming scenario overlay
    def combine_elevation_layers(nasa_base, civ4_scenario)
      return nasa_base unless civ4_scenario

      Rails.logger.info "[AutomaticTerrainGenerator] Combining elevation layers"

      height = nasa_base.size
      width = nasa_base.first.size

      combined = Array.new(height) do |y|
        Array.new(width) do |x|
          nasa_elev = nasa_base[y][x]
          civ4_elev = civ4_scenario[y][x]

          # Blend NASA base with Civ4 scenario overlay (70% NASA, 30% Civ4 for future terraforming representation)
          # This preserves NASA realism while incorporating Civ4 terraforming possibilities
          (nasa_elev * 0.7) + (civ4_elev * 0.3)
        end
      end

      combined
    end

    # Scale a grid from source dimensions to target dimensions using nearest neighbor
    def scale_grid_to_target(source_grid, source_width, source_height, target_width, target_height)
      return source_grid if source_width == target_width && source_height == target_height

      Rails.logger.info "[AutomaticTerrainGenerator] Scaling grid from #{source_width}x#{source_height} to #{target_width}x#{target_height}"

      scaled_grid = Array.new(target_height) do |target_y|
        Array.new(target_width) do |target_x|
          # Map target coordinates to source coordinates
          source_x = (target_x.to_f / (target_width - 1)) * (source_width - 1)
          source_y = (target_y.to_f / (target_height - 1)) * (source_height - 1)

          # Use nearest neighbor interpolation
          nearest_x = source_x.round.clamp(0, source_width - 1)
          nearest_y = source_y.round.clamp(0, source_height - 1)

          source_grid[nearest_y][nearest_x]
        end
      end

      scaled_grid
    end

    # Generate Luna terrain using Civ4 and NASA data
    def generate_luna_terrain(body)
      # Use Civ4 Luna map as primary source
      civ4_path = find_luna_civ4_map
      nasa_path = find_luna_nasa_data

      elevation_data = nil

      if civ4_path
        civ4_data = Civ4WbsImportService.new(civ4_path).import
        elevation_extractor = Civ4ElevationExtractor.new
        elevation_data = elevation_extractor.extract(civ4_data) if civ4_data
      end

      # Use NASA data if available and no Civ4 elevation
      if nasa_path && elevation_data.nil?
        elevation_data = load_nasa_elevation_data(nasa_path)
      end

      # Fallback to procedural if no data
      elevation_data ||= generate_procedural_elevation(body, 80, 50)

      terrain_data = {
        grid: nil,  # No biome grid
        elevation: elevation_data,
        biomes: {},  # Empty
        resource_grid: generate_luna_resource_grid(elevation_data),
        strategic_markers: generate_luna_strategic_markers(elevation_data),
        resource_counts: generate_luna_resource_counts(elevation_data)
      }

      store_generated_terrain(body, terrain_data)
      terrain_data
    end

    # Helper methods for finding Sol world data sources
    def find_mars_freeciv_map
      Dir.glob(File.join(Rails.root, 'data', 'maps', 'freeciv', 'mars', '*.sav')).first
    end

    def find_mars_civ4_map
      Dir.glob(File.join(Rails.root, 'data', 'maps', 'civ4', 'mars', '*.Civ4WorldBuilderSave')).first
    end

    def find_mars_nasa_data
      File.join(Rails.root, 'data', 'geotiff', 'processed', 'mars_1800x900.tif')
    end

    def find_luna_civ4_map
      candidates = Dir.glob(File.join(Rails.root, 'data', 'maps', 'civ4', 'luna', '*.Civ4WorldBuilderSave'))
      candidates.max_by { |path| File.basename(path).match(/(\d+)x(\d+)/)&.captures&.map(&:to_i)&.inject(:*) || 0 }
    end

    def find_luna_nasa_data
      File.join(Rails.root, 'data', 'geotiff', 'processed', 'luna_1800x900.tif')
    end

    # Resource and strategic marker generation for Sol worlds
    def generate_resource_grid_from_earth_data(earth_data)
      # Generate resource grid based on Earth data
      # Simplified implementation
      {}
    end

    def generate_strategic_markers_from_earth_data(earth_data)
      # Generate strategic markers for Earth
      []
    end

    def generate_resource_counts_from_earth_data(earth_data)
      # Generate resource counts for Earth
      {}
    end

    def generate_mars_resource_grid(elevation_data)
      # Generate resource grid for Mars based on elevation
      {}
    end

    def generate_mars_strategic_markers(elevation_data)
      # Generate strategic markers for Mars
      []
    end

    def generate_mars_resource_counts(elevation_data)
      # Generate resource counts for Mars
      {}
    end

    def generate_luna_resource_grid(elevation_data)
      # Generate resource grid for Luna based on elevation
      {}
    end

    def generate_luna_strategic_markers(elevation_data)
      # Generate strategic markers for Luna
      []
    end

    def generate_luna_resource_counts(elevation_data)
      # Generate resource counts for Luna
      {}
    end

    # Check if planet is Earth-like based on properties
    def earth_like_planet?(body)
      return true if body.name.downcase == 'earth'

      temp = body.surface_temperature || 288
      water = body.hydrosphere&.water_coverage || 0
      pressure = body.atmosphere&.pressure || 0

      temp.between?(273, 373) && water > 50 && pressure.between?(0.5, 2.0)
    end
  end
end