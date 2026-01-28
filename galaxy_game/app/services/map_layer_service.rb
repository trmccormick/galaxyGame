# app/services/map_layer_service.rb
class MapLayerService
  # Service for extracting and generating terrain layers from map data
  # Handles both Civ4 and FreeCiv formats, providing elevation and terrain data

  def initialize
    @civ4_extractor = Import::Civ4ElevationExtractor.new
    @freeciv_generator = Import::FreecivElevationGenerator.new
  end

  # Process map data and extract/generate layers
  # @param map_data [Hash] Map data with format type and content
  # @return [Hash] Processed layers with elevation, terrain, etc.
  def process_map_layers(map_data)
    return {} unless map_data.is_a?(Hash)

    format = map_data[:format] || detect_format(map_data)

    case format
    when :civ4
      process_civ4_map(map_data)
    when :freeciv
      process_freeciv_map(map_data)
    else
      { error: "Unknown map format: #{format}" }
    end
  end

  # Store processed layers in geosphere
  # @param celestial_body [CelestialBody] The planet to update
  # @param layers [Hash] Processed layer data
  def store_in_geosphere(celestial_body, layers)
    return false unless celestial_body&.geosphere

    terrain_map = {
      elevation: layers[:elevation],
      terrain: layers[:terrain],
      biomes: layers[:biomes],
      quality: layers[:quality],
      method: layers[:method],
      processed_at: Time.current
    }

    celestial_body.geosphere.update(terrain_map: terrain_map)
  end

  private

  # Detect map format from data structure
  def detect_format(map_data)
    if map_data[:plots]&.first&.is_a?(Hash) && map_data[:plots].first.key?(:plot_type)
      :civ4
    elsif map_data[:terrain]&.first&.is_a?(String)
      :freeciv
    else
      :unknown
    end
  end

  # Process Civ4 WorldBuilder save data
  def process_civ4_map(map_data)
    plots = map_data[:plots] || []
    width = map_data[:width] || plots.first&.length || 0
    height = map_data[:height] || plots.length

    elevation_map = []
    terrain_map = []
    biome_map = []

    plots.each_with_index do |row, y|
      elevation_row = []
      terrain_row = []
      biome_row = []

      row.each_with_index do |plot, x|
        # Extract elevation from Civ4 data
        elevation_data = @civ4_extractor.extract(plot)
        elevation_row << elevation_data[:height_value]

        # Map Civ4 terrain to our system
        terrain_type = map_civ4_terrain(plot)
        terrain_row << terrain_type

        # Map to biome for consistency
        biome = map_civ4_to_biome(plot)
        biome_row << biome
      end

      elevation_map << elevation_row
      terrain_map << terrain_row
      biome_map << biome_row
    end

    {
      elevation: elevation_map,
      terrain: terrain_map,
      biomes: biome_map,
      quality: 'high_70_80_percent',
      method: 'civ4_extraction',
      width: width,
      height: height
    }
  end

  # Process FreeCiv save data
  def process_freeciv_map(map_data)
    terrain_grid = map_data[:terrain] || []
    return {} if terrain_grid.empty?

    # Generate elevation from biomes
    elevation_result = @freeciv_generator.generate_elevation(terrain_grid)
    elevation_map = elevation_result[:elevation]

    # Convert terrain characters to our terrain types
    terrain_map = terrain_grid.map do |row|
      row.map { |char| map_freeciv_terrain(char) }
    end

    # Biomes are the original characters
    biome_map = terrain_grid

    {
      elevation: elevation_map,
      terrain: terrain_map,
      biomes: biome_map,
      quality: elevation_result[:quality],
      method: elevation_result[:method],
      width: terrain_grid.first.length,
      height: terrain_grid.length
    }
  end

  # Map Civ4 terrain types to our system
  def map_civ4_terrain(plot)
    terrain_type = plot[:terrain_type]
    feature_type = plot[:feature_type]

    # Primary mapping
    base_terrain = case terrain_type
    when 'TERRAIN_GRASS' then :grasslands
    when 'TERRAIN_PLAINS' then :plains
    when 'TERRAIN_DESERT' then :desert
    when 'TERRAIN_TUNDRA' then :tundra
    when 'TERRAIN_SNOW' then :arctic
    when 'TERRAIN_OCEAN' then :ocean
    when 'TERRAIN_COAST' then :coastal
    else :plains
    end

    # Feature overrides
    case feature_type
    when 'FEATURE_FOREST' then :forest
    when 'FEATURE_JUNGLE' then :jungle
    when 'FEATURE_MARSH' then :swamp
    else base_terrain
    end
  end

  # Map Civ4 data to biome characters for consistency
  def map_civ4_to_biome(plot)
    terrain_type = plot[:terrain_type]
    feature_type = plot[:feature_type]

    case terrain_type
    when 'TERRAIN_GRASS'
      feature_type == 'FEATURE_FOREST' ? 'f' : 'g'
    when 'TERRAIN_PLAINS' then 'p'
    when 'TERRAIN_DESERT' then 'd'
    when 'TERRAIN_TUNDRA' then 't'
    when 'TERRAIN_SNOW' then 'a'
    when 'TERRAIN_OCEAN' then ' '
    when 'TERRAIN_COAST' then '+'
    else 'g'
    end
  end

  # Map FreeCiv terrain characters to our terrain types
  def map_freeciv_terrain(char)
    case char
    when 'a' then :arctic
    when ':' then :deep_sea
    when 'd' then :desert
    when 'f' then :forest
    when 'p' then :plains
    when 'g' then :grasslands
    when 'h' then :boreal  # hills
    when 'j' then :jungle
    when '+' then :ocean   # lake
    when 'm' then :boreal  # mountain
    when ' ' then :ocean
    when 's' then :swamp
    when 't' then :tundra
    else :plains
    end
  end
end