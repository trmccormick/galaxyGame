# galaxy_game/app/services/star_sim/automatic_terrain_generator.rb
# Automatic terrain generation for new star systems based on planetary properties
# Integrates AI-learned patterns with realistic planet characteristics

require 'import/freeciv_map_processor'
require 'import/civ4_map_processor'
require 'terrain/multi_body_terrain_generator'
require_relative '../../../lib/geotiff_reader'

module StarSim
  class AutomaticTerrainGenerator
    def initialize
      # Lazy initialization of services to avoid autoload issues
    end

    def has_populated_terrain_data?(celestial_body)
      return false unless celestial_body.geosphere&.terrain_map.present?
      
      terrain_map = celestial_body.geosphere.terrain_map
      
      # Handle different storage formats
      if terrain_map.is_a?(String)
        begin
          terrain_map = JSON.parse(terrain_map)
        rescue JSON::ParserError
          return false
        end
      end
      
      # Check if it's a populated hash with terrain data
      return true if terrain_map.is_a?(Hash) && (
        terrain_map['elevation'].present? || 
        terrain_map['grid'].present? || 
        terrain_map['biomes'].present?
      )
      
      # Check if it's a 2D array (legacy format)
      return true if terrain_map.is_a?(Array) && terrain_map.first.is_a?(Array)
      
      false
    end

    def earth_processor
      @earth_processor ||= Import::EarthMapProcessor.new
    end

    def quality_assessor
      @quality_assessor ||= TerrainAnalysis::TerrainQualityAssessor.new
    end

    def planetary_map_generator
      @planetary_map_generator ||= AIManager::PlanetaryMapGenerator.new
    end

    # Generate terrain for a newly created celestial body
    def generate_terrain_for_body(celestial_body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating terrain for #{celestial_body.name}"

      # Skip if body already has populated terrain data or isn't a planet/moon
      return if has_populated_terrain_data?(celestial_body)
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
      # Calculate diameter-based grid dimensions for proper scaling
      grid_dimensions = calculate_diameter_based_grid_size(body)

      params = {
        terrain_complexity: calculate_terrain_complexity(body),
        biome_density: calculate_biome_density(body),
        elevation_scale: calculate_elevation_scale(body),
        water_coverage: body.hydrosphere&.water_coverage || 0,
        atmospheric_pressure: body.atmosphere&.pressure || 0,
        surface_temperature: body.surface_temperature || 288,
        grid_width: grid_dimensions[:width],
        grid_height: grid_dimensions[:height]
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

    # Calculate diameter-based grid dimensions using FreeCiv Earth map as reference
    def calculate_diameter_based_grid_size(body)
      # Use FreeCiv Earth map dimensions as reference (180x90 tiles for Earth-sized planets)
      earth_diameter_km = 12742.0  # Earth's diameter in km
      freeciv_earth_width = 180
      freeciv_earth_height = 90

      # Calculate planet's diameter
      planet_diameter_km = (body.radius.to_f / 1000) * 2  # Convert radius to diameter

      # Scale proportionally to Earth's FreeCiv map size
      scale_factor = planet_diameter_km / earth_diameter_km

      # Apply scaling with minimum and maximum bounds for FreeCiv compatibility
      scaled_width = (freeciv_earth_width * scale_factor).round
      scaled_height = (freeciv_earth_height * scale_factor).round

      # Ensure minimum viable size for FreeCiv gameplay (at least 40x20)
      final_width = [scaled_width, 40].max
      final_height = [scaled_height, 20].max

      # Cap at reasonable maximum for performance (max 720x360, 4x Earth size)
      final_width = [final_width, 720].min
      final_height = [final_height, 360].min

      Rails.logger.info "[AutomaticTerrainGenerator] Calculated grid size for #{body.name}: " \
                       "#{final_width}x#{final_height} (diameter: #{planet_diameter_km.round}km, " \
                       "scale_factor: #{scale_factor.round(3)} vs FreeCiv Earth reference)"

      { width: final_width, height: final_height }
    end

    # Generate base terrain using PlanetaryMapGenerator
    def generate_base_terrain(body, params)
      generator_params = {
        radius: body.radius,
        planet_name: body.name,
        complexity: params[:terrain_complexity],
        elevation_scale: params[:elevation_scale],
        water_coverage: params[:water_coverage],
        temperature: params[:surface_temperature],
        width: params[:grid_width],
        height: params[:grid_height]
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
      sol_worlds = ['earth', 'mars', 'luna', 'moon', 'venus', 'mercury']
      sol_worlds.include?(body.name.downcase)
    end

    # Generate terrain for Sol system worlds using known data sources
    def generate_sol_world_terrain(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating terrain for Sol world: #{body.name}"

      case body.name.downcase
      when 'earth'
        generate_earth_terrain(body)
      when 'mars'
        Rails.logger.info "[AutomaticTerrainGenerator] Calling generate_mars_terrain for #{body.name}"
        result = generate_mars_terrain(body)
        Rails.logger.info "[AutomaticTerrainGenerator] generate_mars_terrain returned: #{result ? 'Hash' : 'nil'}"
        result
      when 'venus'
        generate_venus_terrain(body)
      when 'mercury'
        generate_mercury_terrain(body)
      when 'luna', 'moon'
        generate_luna_terrain(body)
      else
        # Fallback to procedural generation
        terrain_params = analyze_planet_properties(body)
        generate_base_terrain(body, terrain_params)
      end
    end

    # Generate Earth terrain using NASA terrain hierarchy
    def generate_earth_terrain(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating Earth terrain using NASA hierarchy"

      # Priority 1: NASA GeoTIFF (Ground Truth for current 2026 Earth state)
      if nasa_geotiff_available?('earth')
        Rails.logger.info "[AutomaticTerrainGenerator] Using NASA GeoTIFF for Earth current state"
        terrain_data = load_nasa_terrain('earth', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Civ4/FreeCiv maps are guides for biosphere patterns, not used for current Earth terrain
      Rails.logger.warn "[AutomaticTerrainGenerator] No NASA data found for Earth, using AI generation"
      terrain_params = analyze_planet_properties(body)
      base_terrain = generate_base_terrain(body, terrain_params)
      store_generated_terrain(body, base_terrain)
    end

    # Generate realistic elevation from FreeCiv terrain structure
    # Converts terrain types (ocean, mountains, plains) to elevation values in meters
    def generate_elevation_from_freeciv_structure(terrain_grid)
      return nil unless terrain_grid

      height = terrain_grid.size
      width = terrain_grid.first.size

      # Elevation values in meters based on terrain type
      terrain_elevation_map = {
        ocean: -4000,      # Average ocean depth
        deep_sea: -5500,   # Deep ocean
        coast: -50,        # Shallow coastal waters
        swamp: 10,         # Just above sea level
        grasslands: 200,   # Low plains
        plains: 300,       # Moderate elevation
        desert: 500,       # Often on plateaus
        forest: 400,       # Moderate elevation
        jungle: 150,       # Usually lowlands
        tundra: 800,       # High latitude, moderate elevation
        boreal: 600,       # Northern forests
        arctic: 1500,      # Ice caps often on elevated terrain
        rocky: 2000,       # Hills
        mountains: 3500    # Mountain ranges
      }

      elevation_grid = Array.new(height) do |y|
        Array.new(width) do |x|
          terrain_type = terrain_grid[y][x]
          base_elevation = terrain_elevation_map[terrain_type] || terrain_elevation_map[:plains]

          # Add some natural variation (+/- 15% of base value)
          variation = base_elevation * (rand * 0.3 - 0.15)
          (base_elevation + variation).round(0)
        end
      end

      # Smooth the elevation grid for more natural transitions
      smooth_elevation_grid(elevation_grid, passes: 2)
    end

    # Smooth elevation grid to create natural transitions
    def smooth_elevation_grid(grid, passes: 1)
      height = grid.size
      width = grid.first.size

      passes.times do
        smoothed = Array.new(height) { Array.new(width, 0) }

        height.times do |y|
          width.times do |x|
            neighbors = []
            [-1, 0, 1].each do |dy|
              [-1, 0, 1].each do |dx|
                ny = (y + dy) % height
                nx = (x + dx) % width
                neighbors << grid[ny][nx]
              end
            end
            smoothed[y][x] = (neighbors.sum / neighbors.size.to_f).round(0)
          end
        end

        grid = smoothed
      end

      grid
    end

    # Generate Earth biomes from elevation data when FreeCiv/Civ4 data is unavailable
    def generate_earth_biomes_from_elevation(elevation_grid)
      return nil unless elevation_grid

      height = elevation_grid.size
      width = elevation_grid.first.size

      # Classify biomes based on elevation (simplified Earth-like classification)
      biomes = Array.new(height) do |y|
        Array.new(width) do |x|
          elevation = elevation_grid[y][x]

          # Earth biome classification based on elevation
          case elevation
          when -10000..-200
            'ocean'  # Deep ocean
          when -200..0
            'coast'  # Coastal/shallow water
          when 0..500
            'plains' # Lowlands
          when 500..1500
            'hills'  # Hills
          when 1500..3000
            'mountains' # Mountains
          else
            'peaks' # High peaks
          end
        end
      end

      biomes
    end

    # Generate Mars terrain using NASA terrain hierarchy
    def generate_mars_terrain(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating Mars terrain using NASA hierarchy"

      # Priority 1: NASA GeoTIFF (Ground Truth for current Mars state)
      if nasa_geotiff_available?('mars')
        Rails.logger.info "[AutomaticTerrainGenerator] Using NASA GeoTIFF for Mars current state"
        terrain_data = load_nasa_terrain('mars', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Priority 2: Civ4 maps (elevation + land shape, adjusted for bathtub)
      if generate_terrain_from_civ4('mars', body)
        Rails.logger.info "[AutomaticTerrainGenerator] Using Civ4-adjusted terrain for Mars"
        terrain_data = generate_terrain_from_civ4('mars', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Priority 2b: FreeCiv patterns (generate elevation with bathtub)
      if generate_terrain_from_freeciv_patterns('mars', body)
        Rails.logger.info "[AutomaticTerrainGenerator] Using FreeCiv pattern terrain for Mars"
        terrain_data = generate_terrain_from_freeciv_patterns('mars', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Fallback to AI generation
      Rails.logger.warn "[AutomaticTerrainGenerator] No data sources found for Mars, using AI generation"
      terrain_params = analyze_planet_properties(body)
      base_terrain = generate_base_terrain(body, terrain_params)
      store_generated_terrain(body, base_terrain)
    end

    # Generate NASA base elevation using MultiBodyTerrainGenerator
    def generate_nasa_base_elevation(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating NASA base elevation for #{body.name}"

      # Calculate appropriate grid size based on planet diameter
      grid_size = calculate_diameter_based_grid_size(body)

      # Use MultiBodyTerrainGenerator for NASA patterns - NO blueprint constraints
      generator = Terrain::MultiBodyTerrainGenerator.new
      nasa_data = generator.generate_terrain(body.name.downcase.to_sym,
                                           width: grid_size[:width],
                                           height: grid_size[:height],
                                           options: {})

      nasa_data[:elevation]
    end

    # Generate Civ4 terraforming scenario (partially habitable Mars future state)
    def generate_civ4_terraforming_scenario(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating Civ4 terraforming scenario for #{body.name}"

      civ4_path = find_civ4_map_for_body(body)
      return nil unless civ4_path

      begin
        processor = Import::Civ4MapProcessor.new
        civ4_data = processor.process(civ4_path, mode: :terrain)

        # Calculate target grid size based on planet diameter
        target_size = calculate_diameter_based_grid_size(body)

        # Scale Civ4 elevation to target grid size
        scaled_elevation = scale_grid_to_target(
          civ4_data[:lithosphere][:elevation],
          civ4_data[:lithosphere][:width],
          civ4_data[:lithosphere][:height],
          target_size[:width],
          target_size[:height]
        )

        Rails.logger.info "[AutomaticTerrainGenerator] Scaled Civ4 elevation from #{civ4_data[:lithosphere][:width]}x#{civ4_data[:lithosphere][:height]} to #{target_size[:width]}x#{target_size[:height]}"
        scaled_elevation
      rescue => e
        Rails.logger.warn "[AutomaticTerrainGenerator] Failed to process Civ4 data for #{body.name}: #{e.message}"
        nil
      end
    end

    # Generate FreeCiv complete terraforming targets (fully terraformed future state)
    def generate_freeciv_complete_targets(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating FreeCiv complete terraforming targets for #{body.name}"

      freeciv_path = find_freeciv_map_for_body(body)
      return nil unless freeciv_path

      begin
        processor = Import::FreecivMapProcessor.new
        freeciv_data = processor.process(freeciv_path)

        # Calculate target grid size based on planet diameter
        target_size = calculate_diameter_based_grid_size(body)

        # Scale FreeCiv data to target grid size
        scaled_elevation = scale_grid_to_target(
          freeciv_data[:lithosphere][:elevation],
          freeciv_data[:lithosphere][:width],
          freeciv_data[:lithosphere][:height],
          target_size[:width],
          target_size[:height]
        )

        # Return complete terraforming targets data structure for TerraSim
        {
          elevation: scaled_elevation,
          biomes: freeciv_data[:biomes],
          strategic_markers: freeciv_data[:strategic_markers],
          source_file: freeciv_path,
          scaling_info: {
            original_size: "#{freeciv_data[:lithosphere][:width]}x#{freeciv_data[:lithosphere][:height]}",
            scaled_size: "#{target_size[:width]}x#{target_size[:height]}"
          },
          terraforming_state: 'complete_40_percent_oceans'
        }
      rescue => e
        Rails.logger.warn "[AutomaticTerrainGenerator] Failed to process FreeCiv data for #{body.name}: #{e.message}"
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

    # Generate Luna terrain using NASA elevation base and Civ4 colonization scenario
    # Generate Luna terrain using NASA terrain hierarchy
    def generate_luna_terrain(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating Luna terrain using NASA hierarchy"

      # Priority 1: NASA GeoTIFF (Ground Truth for current Luna state)
      if nasa_geotiff_available?('luna')
        Rails.logger.info "[AutomaticTerrainGenerator] Using NASA GeoTIFF for Luna current state"
        terrain_data = load_nasa_terrain('luna', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Priority 2: Civ4 maps (elevation + land shape, adjusted for bathtub)
      if generate_terrain_from_civ4('luna', body)
        Rails.logger.info "[AutomaticTerrainGenerator] Using Civ4-adjusted terrain for Luna"
        terrain_data = generate_terrain_from_civ4('luna', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Priority 2b: FreeCiv patterns (generate elevation with bathtub)
      if generate_terrain_from_freeciv_patterns('luna', body)
        Rails.logger.info "[AutomaticTerrainGenerator] Using FreeCiv pattern terrain for Luna"
        terrain_data = generate_terrain_from_freeciv_patterns('luna', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Fallback to AI generation
      Rails.logger.warn "[AutomaticTerrainGenerator] No data sources found for Luna, using AI generation"
      terrain_params = analyze_planet_properties(body)
      base_terrain = generate_base_terrain(body, terrain_params)
      store_generated_terrain(body, base_terrain)
    end

    # Generate Venus terrain using NASA terrain hierarchy
    def generate_venus_terrain(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating Venus terrain using NASA hierarchy"

      # Priority 1: NASA GeoTIFF (Ground Truth for current Venus state)
      if nasa_geotiff_available?('venus')
        Rails.logger.info "[AutomaticTerrainGenerator] Using NASA GeoTIFF for Venus current state"
        terrain_data = load_nasa_terrain('venus', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Priority 2: Civ4 maps (elevation + land shape, adjusted for bathtub)
      if generate_terrain_from_civ4('venus', body)
        Rails.logger.info "[AutomaticTerrainGenerator] Using Civ4-adjusted terrain for Venus"
        terrain_data = generate_terrain_from_civ4('venus', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Priority 2b: FreeCiv patterns (generate elevation with bathtub)
      if generate_terrain_from_freeciv_patterns('venus', body)
        Rails.logger.info "[AutomaticTerrainGenerator] Using FreeCiv pattern terrain for Venus"
        terrain_data = generate_terrain_from_freeciv_patterns('venus', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Fallback to AI generation
      Rails.logger.warn "[AutomaticTerrainGenerator] No data sources found for Venus, using AI generation"
      terrain_params = analyze_planet_properties(body)
      base_terrain = generate_base_terrain(body, terrain_params)
      store_generated_terrain(body, base_terrain)
    end

    # Generate Mercury terrain using NASA terrain hierarchy
    def generate_mercury_terrain(body)
      Rails.logger.info "[AutomaticTerrainGenerator] Generating Mercury terrain using NASA hierarchy"

      # Priority 1: NASA GeoTIFF (Ground Truth for current Mercury state)
      if nasa_geotiff_available?('mercury')
        Rails.logger.info "[AutomaticTerrainGenerator] Using NASA GeoTIFF for Mercury current state"
        terrain_data = load_nasa_terrain('mercury', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Priority 2: Civ4 maps (elevation + land shape, adjusted for bathtub)
      if generate_terrain_from_civ4('mercury', body)
        Rails.logger.info "[AutomaticTerrainGenerator] Using Civ4-adjusted terrain for Mercury"
        terrain_data = generate_terrain_from_civ4('mercury', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Priority 2b: FreeCiv patterns (generate elevation with bathtub)
      if generate_terrain_from_freeciv_patterns('mercury', body)
        Rails.logger.info "[AutomaticTerrainGenerator] Using FreeCiv pattern terrain for Mercury"
        terrain_data = generate_terrain_from_freeciv_patterns('mercury', body)
        return store_generated_terrain(body, terrain_data) if terrain_data
      end

      # Fallback to AI generation
      Rails.logger.warn "[AutomaticTerrainGenerator] No data sources found for Mercury, using AI generation"
      terrain_params = analyze_planet_properties(body)
      base_terrain = generate_base_terrain(body, terrain_params)
      store_generated_terrain(body, base_terrain)
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

    # Find Civ4 map for any celestial body
    def find_civ4_map_for_body(body)
      body_name = body.name.downcase
      map_dir = File.join(Rails.root, 'data', 'maps', 'civ4', body_name)

      return nil unless Dir.exist?(map_dir)

      # Find the largest map file (by grid size in filename if available)
      candidates = Dir.glob(File.join(map_dir, '*.Civ4WorldBuilderSave'))
      candidates.max_by { |path| File.basename(path).match(/(\d+)x(\d+)/)&.captures&.map(&:to_i)&.inject(:*) || 0 }
    end

    # Find FreeCiv map for any celestial body
    def find_freeciv_map_for_body(body)
      body_name = body.name.downcase
      map_dir = File.join(Rails.root, 'data', 'maps', 'freeciv', body_name)

      return nil unless Dir.exist?(map_dir)

      # Find the most recent .sav file
      candidates = Dir.glob(File.join(map_dir, '*.sav'))
      candidates.max_by { |path| File.mtime(path) }
    end

    # Legacy methods for backward compatibility
    def find_mars_civ4_map
      find_civ4_map_for_body(OpenStruct.new(name: 'mars'))
    end

    def find_mars_freeciv_map
      find_freeciv_map_for_body(OpenStruct.new(name: 'mars'))
    end

    # Check if planet is Earth-like based on properties
    def earth_like_planet?(body)
      return true if body.name.downcase == 'earth'

      temp = body.surface_temperature || 288
      water = body.hydrosphere&.water_coverage || 0
      pressure = body.atmosphere&.pressure || 0

      temp.between?(273, 373) && water > 50 && pressure.between?(0.5, 2.0)
    end

    # NASA Terrain Hierarchy Implementation
    # Priority 1: NASA GeoTIFF (Ground Truth)
    def load_nasa_terrain(body_name, celestial_body)
      geotiff_path = find_geotiff_path(body_name)
      return nil unless geotiff_path && File.exist?(geotiff_path)

      # Use existing GeoTIFFReader
      raw_data = GeoTIFFReader.read_elevation(geotiff_path)

      # Downsample to game grid size
      grid_dims = calculate_diameter_based_grid_size(celestial_body)
      elevation = downsample_elevation(raw_data[:elevation], grid_dims[:width], grid_dims[:height])

      {
        elevation: elevation,
        biomes: generate_biomes_from_elevation(elevation, celestial_body),
        resource_grid: generate_resource_grid_from_nasa_data(celestial_body),
        strategic_markers: generate_strategic_markers_from_nasa_data(celestial_body),
        resource_counts: generate_resource_counts_from_nasa_data(celestial_body),
        generation_metadata: {
          source: 'nasa_geotiff',
          file_path: geotiff_path,
          grid_dimensions: { width: grid_dims[:width], height: grid_dims[:height] },
          elevation_range: [elevation.flatten.min, elevation.flatten.max]
        }
      }
    end

    def find_geotiff_path(body_name)
      name = body_name.downcase
      name = 'luna' if name == 'moon'

      paths = [
        Rails.root.join('data', 'geotiff', 'processed', "#{name}_1800x900.tif"),
        Rails.root.join('data', 'geotiff', 'temp', "#{name}_900x450.tif")
      ]

      paths.find { |p| File.exist?(p) }
    end

    def nasa_geotiff_available?(body_name)
      find_geotiff_path(body_name).present?
    end

    # Priority 2: Civ4 maps (elevation + land shape, adjusted for bathtub)
    def generate_terrain_from_civ4(body_name, celestial_body)
      # Load Civ4 data
      civ4_path = find_civ4_map(body_name)
      return nil unless civ4_path

      processor = Import::Civ4MapProcessor.new(civ4_path)
      civ4_data = processor.parse

      # Extract elevation using existing Civ4ElevationExtractor
      extractor = Import::Civ4ElevationExtractor.new
      elevation_data = extractor.extract(civ4_data)

      # Extract water mask from PlotType=3 (Civ4 water guide)
      water_mask = extract_civ4_water_mask(civ4_data)

      # Get target water coverage from hydrosphere mass
      target_water_mass = celestial_body.hydrosphere&.total_hydrosphere_mass || 0

      # Adjust elevation so Civ4 water areas stay underwater, fill additional areas based on water mass
      adjusted_elevation = adjust_elevation_for_bathtub(
        elevation_data[:elevation],
        water_mask,
        target_water_mass,
        celestial_body
      )

      {
        elevation: adjusted_elevation,
        biomes: generate_biomes_from_civ4_data(civ4_data, adjusted_elevation),
        resource_grid: generate_resource_grid_from_civ4_data(civ4_data),
        strategic_markers: generate_strategic_markers_from_civ4_data(civ4_data),
        resource_counts: generate_resource_counts_from_civ4_data(civ4_data),
        generation_metadata: {
          source: 'civ4_adjusted',
          water_guide: 'civ4_plottype',
          bathtub_adjusted: true,
          grid_dimensions: { width: adjusted_elevation.first.size, height: adjusted_elevation.size }
        }
      }
    end

    def extract_civ4_water_mask(civ4_data)
      width = civ4_data[:width]
      height = civ4_data[:height]
      mask = Array.new(height) { Array.new(width, false) }

      civ4_data[:plots].each do |plot|
        x, y = plot[:x], plot[:y]
        next if x >= width || y >= height || x < 0 || y < 0

        # Civ4 PlotType=3 is water - use as guide for where water should be
        mask[y][x] = true if plot[:plot_type] == 3
      end

      mask
    end

    # Priority 2b: FreeCiv maps (patterns only, generate elevation with bathtub)
    def generate_terrain_from_freeciv_patterns(body_name, celestial_body)
      # Load FreeCiv pattern data
      processor = Import::FreecivMapProcessor.new
      freeciv_data = processor.load_map(body_name)
      return nil unless freeciv_data

      # Extract terrain pattern (land vs water guides)
      terrain_grid = freeciv_data[:grid]
      water_mask = extract_freeciv_water_mask(terrain_grid)

      # Get target water coverage from hydrosphere mass
      target_water_mass = celestial_body.hydrosphere&.total_hydrosphere_mass || 0

      # Generate base elevation using NASA-learned patterns
      base_elevation = generate_nasa_base_elevation(celestial_body)

      # Adjust elevation to honor FreeCiv water guides and fill based on water mass
      adjusted_elevation = adjust_elevation_for_bathtub(
        base_elevation,
        water_mask,
        target_water_mass,
        celestial_body
      )

      {
        elevation: adjusted_elevation,
        biomes: generate_biomes_from_freeciv_patterns(terrain_grid, adjusted_elevation),
        resource_grid: generate_resource_grid_from_freeciv_data(freeciv_data),
        strategic_markers: generate_strategic_markers_from_freeciv_data(freeciv_data),
        resource_counts: generate_resource_counts_from_freeciv_data(freeciv_data),
        generation_metadata: {
          source: 'freeciv_patterns_adjusted',
          water_guide: 'freeciv_terrain_chars',
          bathtub_adjusted: true,
          grid_dimensions: { width: adjusted_elevation.first.size, height: adjusted_elevation.size }
        }
      }
    end

    def extract_freeciv_water_mask(terrain_grid)
      water_types = ['o', ' ', 'ocean', 'deep_sea', 'coast']
      height = terrain_grid.size
      width = terrain_grid.first.size
      mask = Array.new(height) { Array.new(width, false) }

      height.times do |y|
        width.times do |x|
          terrain_char = terrain_grid[y][x]
          mask[y][x] = true if water_types.include?(terrain_char)
        end
      end

      mask
    end

    # Core bathtub logic: Use water mass to determine sea level and adjust elevations
    def adjust_elevation_for_bathtub(elevation, water_mask, target_water_mass, body)
      return elevation if target_water_mass <= 0

      height = elevation.size
      width = elevation.first.size

      # Calculate grid cell area (approximate for spherical body)
      radius = body.radius
      cell_area = (4 * Math::PI * radius**2) / (width * height)

      # Calculate water volume needed (assume average depth for simplicity)
      # This is a simplified model - real bathtub would use depression filling
      avg_water_depth = 100.0  # meters - typical ocean depth
      volume_needed = target_water_mass / 1000.0  # convert kg to m³ (water density ~1000 kg/m³)
      area_to_flood = volume_needed / avg_water_depth

      # Convert to percentage of grid cells
      total_cells = width * height
      flood_percentage = (area_to_flood / (cell_area * total_cells)) * 100

      # Find sea level that would flood the required percentage
      flat_elevation = elevation.flatten.sort
      sea_level_idx = (flat_elevation.size * flood_percentage / 100.0).floor
      sea_level = flat_elevation[sea_level_idx] || flat_elevation.last

      # Ensure all guided water areas are below sea level
      height.times do |y|
        width.times do |x|
          if water_mask[y][x]  # Civ4/FreeCiv says this should be water
            elevation[y][x] = [elevation[y][x], sea_level - 1].min  # Ensure underwater
          end
        end
      end

      # For areas that get flooded but weren't guided as water, slightly lower them
      # This represents the bathtub filling additional depressions
      flood_threshold = sea_level + 50  # Areas within 50m of sea level get adjusted
      height.times do |y|
        width.times do |x|
          if elevation[y][x] > sea_level && elevation[y][x] < flood_threshold && !water_mask[y][x]
            # Lower these areas so they flood properly
            elevation[y][x] = sea_level - 10
          end
        end
      end

      elevation
    end

    # Helper methods for NASA data processing
    def downsample_elevation(elevation_data, target_width, target_height)
      # Simple downsampling - in production would use proper interpolation
      source_height = elevation_data.size
      source_width = elevation_data.first.size

      result = Array.new(target_height) { Array.new(target_width, 0.0) }

      scale_y = source_height.to_f / target_height
      scale_x = source_width.to_f / target_width

      target_height.times do |y|
        source_y = (y * scale_y).to_i
        target_width.times do |x|
          source_x = (x * scale_x).to_i
          result[y][x] = elevation_data[source_y][source_x] if source_y < source_height && source_x < source_width
        end
      end

      result
    end

    def generate_nasa_base_elevation(body)
      # Generate base elevation using NASA-learned patterns when no GeoTIFF available
      # This would use the MultiBodyTerrainGenerator with NASA pattern data
      grid_dims = calculate_diameter_based_grid_size(body)

      # For now, return a simple gradient - would be replaced with NASA pattern generation
      elevation = Array.new(grid_dims[:height]) { |y| Array.new(grid_dims[:width]) { |x| (y - grid_dims[:height]/2) * 10 } }
      elevation
    end

    # Placeholder methods for data generation - would be implemented based on source data
    def generate_biomes_from_elevation(elevation, body)
      # Generate biomes based on elevation and body characteristics
      height = elevation.size
      width = elevation.first.size

      biomes = Array.new(height) { Array.new(width, 'plains') }

      elevation.each_with_index do |row, y|
        latitude = 90.0 - (y.to_f / height) * 180.0  # Calculate latitude from y position
        row.each_with_index do |elev, x|
          biomes[y][x] = classify_earth_biome_realistic(elev, latitude, body)
        end
      end

      biomes
    end

    def classify_earth_biome_realistic(elevation, latitude, body)
      # Normalize elevation to 0-1 range for classification
      min_elev = -10000  # Deep ocean
      max_elev = 8000    # High mountains
      normalized_elev = (elevation - min_elev) / (max_elev - min_elev).to_f
      normalized_elev = [[normalized_elev, 0.0].max, 1.0].min

      abs_latitude = latitude.abs

      # Water bodies
      if normalized_elev < 0.1
        return 'ocean'
      elsif normalized_elev < 0.15
        return 'coast'
      end

      # Polar regions
      if abs_latitude > 66
        if normalized_elev > 0.8
          return 'polar_mountains'
        elsif normalized_elev > 0.6
          return 'tundra'
        else
          return 'polar_desert'
        end
      end

      # Temperate zones (23.5° to 66°)
      if abs_latitude > 23.5
        if normalized_elev > 0.8
          return 'mountains'
        elsif normalized_elev > 0.6
          return 'hills'
        elsif abs_latitude > 45  # Higher latitudes in temperate zone
          if body.surface_temperature && body.surface_temperature < 280
            return 'boreal_forest'
          else
            return 'temperate_forest'
          end
        else
          return 'temperate_grassland'
        end
      end

      # Tropical/Subtropical zones (0° to 23.5°)
      if normalized_elev > 0.8
        return 'tropical_mountains'
      elsif normalized_elev > 0.6
        return 'hills'
      elsif abs_latitude < 10  # Equatorial
        if body.surface_temperature && body.surface_temperature > 298
          return 'tropical_rainforest'
        else
          return 'tropical_seasonal_forest'
        end
      else
        return 'tropical_grassland'
      end
    end

    def generate_resource_grid_from_nasa_data(body)
      {}
    end

    def generate_strategic_markers_from_nasa_data(body)
      []
    end

    def generate_resource_counts_from_nasa_data(body)
      {}
    end

    def find_civ4_map(body_name)
      # Find Civ4 map file for the body
      name = body_name.downcase
      paths = [
        Rails.root.join('data', 'maps', 'civ4', name, "#{name.capitalize}*.CivBeyondSwordWBSave"),
        Rails.root.join('data', 'maps', 'civ4', name, "*.CivBeyondSwordWBSave"),
        Rails.root.join('data', 'Civ4_Maps', "#{name}.CivBeyondSwordWBSave"),
        Rails.root.join('data', 'Civ4_Maps', "#{name}_civ4.CivBeyondSwordWBSave")
      ]
      
      # Find the first existing file
      paths.each do |pattern|
        if pattern.to_s.include?('*')
          Dir.glob(pattern.to_s).first
        elsif File.exist?(pattern)
          return pattern
        end
      end
      nil
    end

    def civ4_map_available?(body_name)
      find_civ4_map(body_name).present?
    end

    def freeciv_map_available?(body_name)
      # Check if FreeCiv map exists for the body
      name = body_name.downcase
      paths = [
        Rails.root.join('..', 'data', 'maps', "#{name}.sav"),
        Rails.root.join('..', 'data', 'maps', "#{name}_freeciv.sav")
      ]
      paths.find { |p| File.exist?(p) }.present?
    end

    # Civ4/FreeCiv data generation methods (placeholders)
    def generate_biomes_from_civ4_data(civ4_data, elevation)
      []
    end

    def generate_resource_grid_from_civ4_data(civ4_data)
      {}
    end

    def generate_strategic_markers_from_civ4_data(civ4_data)
      []
    end

    def generate_resource_counts_from_civ4_data(civ4_data)
      {}
    end

    def generate_biomes_from_freeciv_patterns(terrain_grid, elevation)
      []
    end

    def generate_resource_grid_from_freeciv_data(freeciv_data)
      {}
    end

    def generate_strategic_markers_from_freeciv_data(freeciv_data)
      []
    end

    def generate_resource_counts_from_freeciv_data(freeciv_data)
      {}
    end
  end
end