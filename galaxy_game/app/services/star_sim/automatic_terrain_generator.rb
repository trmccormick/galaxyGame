# galaxy_game/app/services/star_sim/automatic_terrain_generator.rb
# Automatic terrain generation for new star systems based on planetary properties
# Integrates AI-learned patterns with realistic planet characteristics

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
        grid: raw_terrain[:elevation_data],  # The biome grid
        elevation: generate_elevation_data(raw_terrain[:elevation_data]),  # Elevation values
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

      biome_grid.map do |biome|
        base_elevation = elevation_map[biome] || 0
        # Add some random variation to avoid NaN in statistical calculations
        base_elevation + rand(-50..50)
      end
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
        terrain_map: terrain_data[:grid],
        elevation_data: terrain_data[:elevation],
        biome_data: terrain_data[:biomes],
        resource_data: terrain_data[:resource_grid],
        strategic_markers: terrain_data[:strategic_markers],
        terrain_metadata: {
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