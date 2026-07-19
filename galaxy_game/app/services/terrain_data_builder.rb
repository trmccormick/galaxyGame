# app/services/terrain_data_builder.rb
class TerrainDataBuilder
  # Unit-to-sprite mapping (16 sprites, 4x4 grid)
  # Maps unit/craft class name to sprite index in the sprite sheet
  UNIT_SPRITE_MAP = {
    'Units::Extractor' => 0,   # mining/drilling unit
    'Units::Habitat' => 1,     # habitation dome
    'Units::Fabricator' => 2,  # manufacturing facility
    'Units::Computer' => 3,    # command center
    'Units::Battery' => 4,     # power storage unit
    'Units::Propulsion' => 5,  # engine/thruster
    'Units::Storage' => 6,     # storage tank
    'Units::Robot' => 7,       # exploration robot
    'Craft::Rover' => 8,       # surface rover
    'Craft::Harvester' => 9,   # atmospheric harvester
    'Craft::Ship' => 10,       # orbital ship
    'Craft::Spaceship' => 11,  # deep space vessel
    'Craft::Satellite' => 12,  # orbital satellite
    'Structures::PlanetaryUmbilicalHub' => 13, # planetary hub
    'Units::BaseUnit' => 14,   # generic structure
    'Craft::BaseCraft' => 15   # generic vehicle
  }.freeze

  def initialize(celestial_body)
    @celestial_body = celestial_body
  end

  # Build complete terrain data with unit grid
  def build(terrain_map_data = nil, planet_data = nil)
    {
      elevation: extract_elevation(terrain_map_data),
      biomes: extract_biomes(terrain_map_data),
      resources: extract_resources(terrain_map_data),
      width: extract_width(terrain_map_data),
      height: extract_height(terrain_map_data),
      quality_score: terrain_map_data&.dig('quality_score'),
      generation_method: terrain_map_data&.dig('generation_method'),
      unit_grid: extract_unit_grid
    }
  end

  # Get sprite index for a given unit/craft class
  def self.sprite_index_for(unit)
    return nil unless unit

    # Check exact class first, then ancestors
    UNIT_SPRITE_MAP.each do |klass_name, index|
      if unit.class.name == klass_name || unit.class.included_modules.any? { |m| m.to_s == klass_name }
        return index
      end
    end

    # Fallback to last resort: generic structure
    14
  end

  private

  attr_reader :celestial_body

  def extract_elevation(terrain_map_data)
    return nil unless terrain_map_data

    elevation = terrain_map_data['elevation'] || terrain_map_data[:elevation]
    return elevation if elevation.is_a?(Array) && elevation.length > 0

    grid = terrain_map_data['grid'] || terrain_map_data[:grid]
    return grid if grid.is_a?(Array) && grid.length > 0
    nil
  end

  def extract_biomes(terrain_map_data)
    return nil unless terrain_map_data
    biomes = terrain_map_data['biomes'] || terrain_map_data[:biomes]
    return biomes if biomes.is_a?(Array) && biomes.length > 0
    nil
  end

  def extract_resources(terrain_map_data)
    return nil unless terrain_map_data
    resources = terrain_map_data['resource_grid'] || terrain_map_data[:resource_grid]
    return resources if resources.is_a?(Array) && resources.length > 0
    nil
  end

  def extract_width(terrain_map_data)
    return nil unless terrain_map_data
    terrain_map_data['width'] || terrain_map_data[:width] || (extract_elevation(terrain_map_data)&.first&.length || 0)
  end

  def extract_height(terrain_map_data)
    return nil unless terrain_map_data
    terrain_map_data['height'] || terrain_map_data[:height] || (extract_elevation(terrain_map_data)&.length || 0)
  end

  def extract_unit_grid
    # Get all craft attached to this celestial body (orbiting or landed)
    craft = celestial_body.orbiting_craft.to_a

    # Get all locations on this celestial body (for settled units)
    locations = celestial_body.locations.to_a

    # Build grid dimensions from elevation if available, otherwise use default
    width = 100
    height = 100

    # Initialize empty grid with nil
    grid = Array.new(height) { Array.new(width, nil) }

    # Process each craft/unit and place on grid
    (craft + locations).each do |entity|
      position = get_grid_position(entity)
      next unless position

      x, y = position
      next if x < 0 || x >= width || y < 0 || y >= height

      sprite_index = self.class.sprite_index_for(entity)
      next unless sprite_index

      # Store unit data at grid position
      grid[y][x] = {
        sprite_index: sprite_index,
        entity_id: entity.id,
        entity_type: entity.class.name,
        name: entity.respond_to?(:name) ? entity.name : 'Unknown',
        identifier: entity.respond_to?(:identifier) ? entity.identifier : nil,
        owner_faction: extract_owner_faction(entity)
      }
    end

    grid
  end

  def get_grid_position(entity)
    # Try direct spatial_location association first
    if entity.respond_to?(:spatial_location) && entity.spatial_location
      loc = entity.spatial_location
      return [loc.x_coordinate.to_i, loc.y_coordinate.to_i] if loc.respond_to?(:x_coordinate)
    end

    # Try finding spatial_location through spatial_context (for entities like base_craft)
    if entity.respond_to?(:id) && entity.respond_to?(:class)
      spatial_loc = Location::SpatialLocation.find_by(
        spatial_context_type: entity.class.name,
        spatial_context_id: entity.id
      )
      return [spatial_loc.x_coordinate.to_i, spatial_loc.y_coordinate.to_i] if spatial_loc
    end

    # For celestial location (uses coordinates string like "45.00°N 90.00°E")
    # Convert to grid position using lat/lng as y/x
    if entity.respond_to?(:celestial_location) && entity.celestial_location
      loc = entity.celestial_location
      coords = loc.coordinates
      return nil unless coords && coords.include?('°')

      # Parse "45.00°N 90.00°E" format
      parts = coords.split('°').map(&:strip)
      return nil if parts.length < 2

      lat_str = parts[0].gsub(/[NS]/, '').to_f
      lng_str = parts[1].gsub(/[EW]/, '').to_f

      # Convert to grid position (lat -> y, lng -> x)
      # Use a simple mapping: lat 0-90 -> y 0-100, lng 0-180 -> x 0-100
      y = (lat_str / 90.0 * 100).to_i
      x = (lng_str / 180.0 * 100).to_i

      return [x, y]
    end

    nil
  end

  def extract_owner_faction(entity)
    return nil unless entity.respond_to?(:owner) && entity.owner

    # Handle polymorphic owner
    if entity.owner.is_a?(String)
      entity.owner
    elsif entity.owner.respond_to?(:name)
      entity.owner.name
    elsif entity.owner.respond_to?(:identifier)
      entity.owner.identifier
    else
      entity.owner.to_s
    end
  end
end
