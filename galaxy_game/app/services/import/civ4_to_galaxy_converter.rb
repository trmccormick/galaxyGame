# app/services/import/civ4_to_galaxy_converter.rb
module Import
  class Civ4ToGalaxyConverter
    # Map Civ4 terrain types to Galaxy Game terrain classifications
    TERRAIN_CLASSIFICATIONS = {
      grasslands: :grasslands,
      plains: :plains,
      desert: :desert,
      tundra: :tundra,
      arctic: :arctic,
      ocean: :ocean,
      deep_sea: :deep_sea,
      boreal: :boreal_forest,  # hills/mountains become boreal forest
      rocky: :rocky  # default rock terrain
    }.freeze

    # Terrain type properties for planetary classification
    TERRAIN_PROPERTIES = {
      grasslands: { temperature: :temperate, water: :moderate, vegetation: :moderate },
      plains: { temperature: :temperate, water: :moderate, vegetation: :moderate },
      desert: { temperature: :hot, water: :scarce, vegetation: :minimal },
      tundra: { temperature: :cold, water: :frozen, vegetation: :minimal },
      arctic: { temperature: :very_cold, water: :frozen, vegetation: :minimal },
      ocean: { temperature: :temperate, water: :abundant, vegetation: :marine },
      deep_sea: { temperature: :cold, water: :abundant, vegetation: :marine },
      boreal_forest: { temperature: :cold, water: :moderate, vegetation: :moderate },
      rocky: { temperature: :variable, water: :scarce, vegetation: :minimal }
    }.freeze

    attr_reader :civ4_data, :errors

    def initialize(civ4_data)
      @civ4_data = civ4_data
      @errors = []
    end

    # Validate that the Civ4 data has the required structure
    def valid_data?
      unless @civ4_data && @civ4_data[:grid] && @civ4_data[:width] && @civ4_data[:height]
        @errors << "Invalid Civ4 data structure"
        return false
      end

      unless @civ4_data[:grid].is_a?(Array) && @civ4_data[:grid].all? { |row| row.is_a?(Array) }
        @errors << "Terrain grid must be a 2D array"
        return false
      end

      true
    end

    # Convert Civ4 terrain data to Galaxy Game planetary data
    def convert_to_planetary_body(name: "Imported Civ4 World", solar_system: nil)
      return nil unless valid_data?

      # Analyze terrain composition
      terrain_analysis = analyze_terrain_composition

      # Determine planetary characteristics
      planet_type = determine_planet_type(terrain_analysis)
      atmosphere_composition = generate_atmosphere(terrain_analysis)
      hydrosphere_data = generate_hydrosphere(terrain_analysis)
      surface_temperature = estimate_temperature(terrain_analysis)

      # Create planetary body data structure
      {
        name: name,
        identifier: generate_identifier(name),
        type: planet_type,
        solar_system: solar_system,
        radius: estimate_radius(terrain_analysis),
        mass: estimate_mass(terrain_analysis),
        surface_temperature: surface_temperature,
        atmosphere: atmosphere_composition,
        hydrosphere: hydrosphere_data,
        terrain_grid: @civ4_data[:grid],
        terrain_analysis: terrain_analysis,
        properties: {
          'source' => 'civ4_import',
          'original_format' => 'wbs',
          'grid_width' => @civ4_data[:width],
          'grid_height' => @civ4_data[:height],
          'biome_counts' => @civ4_data[:biome_counts]
        }
      }
    end

    # Analyze the terrain composition for planetary classification
    def analyze_terrain_composition
      total_tiles = @civ4_data[:width] * @civ4_data[:height]
      biome_counts = @civ4_data[:biome_counts]

      # Calculate percentages
      terrain_percentages = {}
      biome_counts.each do |terrain_type, count|
        terrain_percentages[terrain_type] = (count.to_f / total_tiles * 100).round(2)
      end

      # Determine dominant terrain types
      water_tiles = (biome_counts[:ocean] || 0) + (biome_counts[:deep_sea] || 0)
      land_tiles = total_tiles - water_tiles

      {
        total_tiles: total_tiles,
        water_tiles: water_tiles,
        land_tiles: land_tiles,
        water_percentage: (water_tiles.to_f / total_tiles * 100).round(2),
        land_percentage: (land_tiles.to_f / total_tiles * 100).round(2),
        biome_counts: biome_counts,
        terrain_percentages: terrain_percentages,
        dominant_terrain: biome_counts.max_by { |_, count| count }&.first
      }
    end

    # Determine planet type based on terrain composition
    def determine_planet_type(analysis)
      water_pct = analysis[:water_percentage]

      if water_pct > 80
        :ocean_world
      elsif water_pct > 50
        :terrestrial
      elsif water_pct > 20
        :arid
      else
        :desert_world
      end
    end

    # Generate atmosphere composition based on terrain
    def generate_atmosphere(analysis)
      base_pressure = 1.0 # Earth-like base
      base_composition = {
        nitrogen: 78.0,
        oxygen: 21.0,
        argon: 0.9,
        carbon_dioxide: 0.04
      }

      # Adjust based on terrain composition
      if analysis[:terrain_percentages][:desert].to_f > 30
        # Desert world - thinner atmosphere, more CO2
        base_pressure *= 0.7
        base_composition[:carbon_dioxide] += 0.5
        base_composition[:oxygen] -= 0.3
      elsif analysis[:terrain_percentages][:arctic].to_f > 40
        # Cold world - thicker atmosphere, more CO2
        base_pressure *= 1.2
        base_composition[:carbon_dioxide] += 0.2
      end

      {
        pressure: base_pressure,
        composition: base_composition,
        temperature: estimate_temperature(analysis)
      }
    end

    # Generate hydrosphere data
    def generate_hydrosphere(analysis)
      water_percentage = analysis[:water_percentage]

      # Estimate ocean mass based on water percentage
      # Earth has ~1.4 × 10^21 kg of water
      earth_ocean_mass = 1.4e21
      ocean_mass = earth_ocean_mass * (water_percentage / 71.0) # Earth has ~71% water

      # Ice mass for cold worlds
      ice_percentage = (analysis[:terrain_percentages][:arctic] || 0) +
                      (analysis[:terrain_percentages][:tundra] || 0)
      ice_mass = ocean_mass * (ice_percentage / 100.0) * 0.3

      {
        oceans: water_percentage > 10 ? 1 : 0, # Major ocean if >10% water
        ocean_mass: ocean_mass,
        ice_mass: ice_mass,
        total_water: ocean_mass + ice_mass
      }
    end

    # Estimate surface temperature
    def estimate_temperature(analysis)
      # Base temperature influenced by terrain types
      temp_modifiers = {
        arctic: -20,
        tundra: -10,
        desert: 15,
        grasslands: 10,
        plains: 5,
        ocean: 0,
        deep_sea: -5,
        boreal: -5,
        rocky: 0
      }

      weighted_temp = 0
      total_weight = 0

      analysis[:terrain_percentages].each do |terrain_type, percentage|
        modifier = temp_modifiers[terrain_type] || 0
        weighted_temp += modifier * percentage
        total_weight += percentage
      end

      # Earth average surface temperature is ~15°C (288K)
      288 + (weighted_temp / 100.0 * 20) # ±20K variation
    end

    # Estimate planetary radius based on terrain (rough approximation)
    def estimate_radius(analysis)
      # Earth radius is ~6,371 km
      earth_radius = 6_371_000

      # Rocky worlds are smaller, ocean worlds larger
      if analysis[:terrain_percentages][:rocky].to_f > 50
        earth_radius * 0.8
      elsif analysis[:water_percentage] > 70
        earth_radius * 1.1
      else
        earth_radius * 0.95
      end
    end

    # Estimate planetary mass
    def estimate_mass(analysis)
      # Earth mass is ~5.97 × 10^24 kg
      earth_mass = 5.97e24

      # Adjust based on composition
      radius_factor = estimate_radius(analysis) / 6_371_000.0
      density_factor = if analysis[:water_percentage] > 60
                        0.9  # Less dense with lots of water
                       elsif analysis[:terrain_percentages][:rocky].to_f > 40
                        1.2  # More dense with rocky terrain
                       else
                        1.0  # Earth-like
                       end

      earth_mass * radius_factor**3 * density_factor
    end

    # Generate unique identifier
    def generate_identifier(name)
      "#{name.downcase.gsub(/[^a-z0-9]/, '_')}_#{Time.now.to_i}"
    end
  end
end