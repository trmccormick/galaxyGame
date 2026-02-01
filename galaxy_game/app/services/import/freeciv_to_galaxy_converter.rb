# app/services/import/freeciv_to_galaxy_converter.rb
module Import
  class FreecivToGalaxyConverter
    # Map FreeCiv terrain types to Galaxy Game terrain classifications
    TERRAIN_CLASSIFICATIONS = {
      arctic: :arctic,
      deep_sea: :deep_sea,
      desert: :desert,
      forest: :forest,
      plains: :plains,
      grasslands: :grasslands,
      boreal: :boreal_forest,  # hills/mountains become boreal forest
      jungle: :jungle,
      ocean: :ocean,
      swamp: :swamp,
      tundra: :tundra,
      rock: :rocky  # default rock terrain
    }.freeze

    # Terrain type properties for planetary classification
    TERRAIN_PROPERTIES = {
      arctic: { temperature: :very_cold, water: :frozen, vegetation: :minimal },
      deep_sea: { temperature: :cold, water: :abundant, vegetation: :marine },
      desert: { temperature: :hot, water: :scarce, vegetation: :minimal },
      forest: { temperature: :temperate, water: :moderate, vegetation: :dense },
      plains: { temperature: :temperate, water: :moderate, vegetation: :moderate },
      grasslands: { temperature: :temperate, water: :moderate, vegetation: :moderate },
      boreal_forest: { temperature: :cold, water: :moderate, vegetation: :moderate },
      jungle: { temperature: :hot, water: :abundant, vegetation: :dense },
      ocean: { temperature: :temperate, water: :abundant, vegetation: :marine },
      swamp: { temperature: :warm, water: :abundant, vegetation: :moderate },
      tundra: { temperature: :cold, water: :frozen, vegetation: :minimal },
      rocky: { temperature: :variable, water: :scarce, vegetation: :minimal }
    }.freeze

    attr_reader :freeciv_data, :errors

    def initialize(freeciv_data)
      @freeciv_data = freeciv_data
      @errors = []
    end

    # Convert FreeCiv terrain data to Galaxy Game planetary data
    def convert_to_planetary_body(name: "Imported World", solar_system: nil)
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
        terrain_grid: @freeciv_data[:grid],
        terrain_analysis: terrain_analysis,
        properties: {
          'source' => 'freeciv_import',
          'original_format' => 'sav',
          'grid_width' => @freeciv_data[:width],
          'grid_height' => @freeciv_data[:height],
          'biome_counts' => @freeciv_data[:biome_counts]
        }
      }
    end

    private

    def valid_data?
      unless @freeciv_data.is_a?(Hash) && @freeciv_data[:grid]
        @errors << "Invalid FreeCiv data structure"
        return false
      end

      unless @freeciv_data[:grid].is_a?(Array) && @freeciv_data[:grid].any?
        @errors << "No terrain grid data found"
        return false
      end

      true
    end

    # Analyze the composition of terrain types
    def analyze_terrain_composition
      grid = @freeciv_data[:grid]
      total_cells = grid.flatten.size

      # Count terrain types
      terrain_counts = Hash.new(0)
      grid.flatten.each do |terrain_type|
        terrain_counts[terrain_type] += 1
      end

      # Calculate percentages
      terrain_percentages = {}
      terrain_counts.each do |type, count|
        terrain_percentages[type] = (count.to_f / total_cells * 100).round(2)
      end

      # Determine dominant terrain types
      sorted_terrain = terrain_percentages.sort_by { |_, pct| -pct }

      {
        total_cells: total_cells,
        terrain_counts: terrain_counts,
        terrain_percentages: terrain_percentages,
        dominant_terrain: sorted_terrain.first&.first,
        secondary_terrain: sorted_terrain[1]&.first,
        terrain_diversity: terrain_counts.size
      }
    end

    # Determine planet type based on terrain composition
    def determine_planet_type(analysis)
      dominant = analysis[:dominant_terrain]
      percentages = analysis[:terrain_percentages]

      # Ocean-dominated world
      if percentages[:ocean].to_f > 70
        return 'ocean_planet'
      end

      # Desert world
      if percentages[:desert].to_f > 50
        return 'terrestrial'
      end

      # Ice world
      if percentages[:arctic].to_f + percentages[:tundra].to_f > 60
        return 'terrestrial'
      end

      # Forest/jungle world
      if percentages[:forest].to_f + percentages[:jungle].to_f > 40
        return 'terrestrial'
      end

      # Default terrestrial planet
      'terrestrial'
    end

    # Generate atmosphere composition based on terrain
    def generate_atmosphere(analysis)
      percentages = analysis[:terrain_percentages]

      # Base atmosphere composition
      composition = { 'N2' => 78.0, 'O2' => 21.0, 'Ar' => 0.9, 'CO2' => 0.1 }

      # Adjust based on terrain types
      if percentages[:desert].to_f > 30
        composition['CO2'] += 0.5  # More CO2 in deserts
      end

      if percentages[:ocean].to_f > 50
        composition['H2O'] = 2.0  # Higher water vapor over oceans
      end

      if percentages[:arctic].to_f + percentages[:tundra].to_f > 40
        composition['CH4'] = 0.01  # Trace methane in cold regions
      end

      # Normalize percentages
      total = composition.values.sum
      composition.transform_values { |v| (v / total * 100).round(2) }

      {
        composition: composition,
        pressure: estimate_atmospheric_pressure(analysis),
        total_atmospheric_mass: estimate_atmospheric_mass(analysis)
      }
    end

    # Generate hydrosphere data
    def generate_hydrosphere(analysis)
      percentages = analysis[:terrain_percentages]

      # Calculate water coverage
      ocean_coverage = percentages[:ocean].to_f + percentages[:deep_sea].to_f
      ice_coverage = percentages[:arctic].to_f + percentages[:tundra].to_f

      # Estimate total water
      total_water_coverage = ocean_coverage + ice_coverage * 0.5  # Ice contains water

      {
        water_coverage: total_water_coverage.round(2),
        ice_coverage: ice_coverage.round(2),
        ocean_coverage: ocean_coverage.round(2),
        composition: { 'H2O' => 100.0 },
        state_distribution: {
          'liquid' => ocean_coverage.round(2),
          'solid' => ice_coverage.round(2),
          'gas' => 0.1
        }
      }
    end

    # Estimate surface temperature based on terrain
    def estimate_temperature(analysis)
      percentages = analysis[:terrain_percentages]

      # Base temperature calculation
      base_temp = 15.0  # Earth-like base

      # Adjust for terrain types
      temp_adjustments = {
        arctic: -30,
        tundra: -15,
        desert: +20,
        jungle: +10,
        ocean: -5,
        forest: 0,
        plains: 0,
        grasslands: 0,
        boreal: -10,
        swamp: +5,
        deep_sea: -10,
        rock: 0
      }

      weighted_adjustment = 0.0
      percentages.each do |terrain, pct|
        adjustment = temp_adjustments[terrain] || 0
        weighted_adjustment += adjustment * (pct / 100.0)
      end

      (base_temp + weighted_adjustment).round(1)
    end

    # Estimate planetary radius based on terrain diversity and size
    def estimate_radius(analysis)
      grid_size = @freeciv_data[:width] * @freeciv_data[:height]

      # Base radius for Earth-like planet
      base_radius = 6_371_000  # Earth radius in meters

      # Adjust based on grid size (larger maps = larger planets)
      size_factor = Math.sqrt(grid_size / 10_000.0)  # Normalize to 100x100 grid

      # Adjust based on terrain diversity (more diverse = more complex geology)
      diversity_factor = analysis[:terrain_diversity] / 10.0

      (base_radius * size_factor * diversity_factor).round(0)
    end

    # Estimate planetary mass
    def estimate_mass(analysis)
      radius = estimate_radius(analysis)

      # Assume Earth-like density
      density = 5514  # kg/m³ (Earth average)
      volume = (4.0/3.0) * Math::PI * (radius ** 3)

      (density * volume).round(0)
    end

    # Estimate atmospheric pressure
    def estimate_atmospheric_pressure(analysis)
      # Base pressure similar to Earth
      base_pressure = 101_325  # Pa

      # Adjust based on terrain (oceans suggest higher pressure, deserts lower)
      percentages = analysis[:terrain_percentages]
      ocean_factor = percentages[:ocean].to_f / 50.0  # Normalize
      desert_factor = percentages[:desert].to_f / 50.0

      pressure_factor = 1.0 + (ocean_factor * 0.2) - (desert_factor * 0.3)

      (base_pressure * pressure_factor).round(0)
    end

    # Estimate atmospheric mass
    def estimate_atmospheric_mass(analysis)
      pressure = estimate_atmospheric_pressure(analysis)
      radius = estimate_radius(analysis)

      # Rough calculation: mass = pressure * surface_area / g
      surface_area = 4 * Math::PI * (radius ** 2)
      gravity = 9.8  # m/s²

      (pressure * surface_area / gravity).round(0)
    end

    # Generate unique identifier for the planetary body
    def generate_identifier(name)
      "#{name.downcase.gsub(/\s+/, '_')}_#{Time.now.to_i}"
    end
  end
end