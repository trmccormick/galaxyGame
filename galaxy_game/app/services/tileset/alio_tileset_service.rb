# app/services/tileset/alio_tileset_service.rb
# Parser and renderer for FreeCiv Alio tileset (Alien World)
# GPL-2.0+ licensed assets from FreeCiv project
#
# Tile grid: 126x64 pixels (hex-compatible)
# Artists: GriffonSpade, Peter Arbor, amplio2 team, Wesnoth team
#
module Tileset
  class AlioTilesetService
    TILESET_PATH = Rails.root.join('public', 'tilesets', 'alio')
    TILE_WIDTH = 126
    TILE_HEIGHT = 64
    GRID_BORDER = 1
    GRID_OFFSET_X = 1
    GRID_OFFSET_Y = 1

    # Direction constants for adjacency encoding
    DIRECTIONS = %w[n e se s w nw].freeze

    attr_reader :tiles, :errors

    def initialize
      @tiles = {}
      @errors = []
      @loaded = false
    end

    # Load all spec files and build tile index
    def load
      return true if @loaded

      spec_files = TILESET_PATH.glob('*.spec')
      if spec_files.empty?
        @errors << "No spec files found in #{TILESET_PATH}"
        return false
      end

      spec_files.each do |spec_file|
        parse_spec_file(spec_file)
      end

      @loaded = @tiles.any?
      @loaded
    end

    # Get tile coordinates for a terrain type
    # Returns: { image: 'terrain.png', x: pixel_x, y: pixel_y, width: 126, height: 64 }
    def get_tile(tag)
      load unless @loaded
      @tiles[tag]
    end

    # Get burrow tube tile based on adjacent connections
    # neighbors: Hash with keys :n, :e, :se, :s, :w, :nw (boolean values)
    def get_burrow_tube_tile(neighbors = {})
      load unless @loaded
      pattern = encode_adjacency(neighbors)
      tag = "road.burrow_tube_#{pattern}:0"
      @tiles[tag]
    end

    # Get hill tile based on adjacent hill cells
    def get_hill_tile(neighbors = {})
      load unless @loaded
      pattern = encode_adjacency(neighbors)
      # Hills use l2 layer prefix
      tag = "t.l2.hills_#{pattern}"
      @tiles[tag]
    end

    # Get tunnel tile based on adjacent tunnel cells
    def get_tunnel_tile(neighbors = {})
      load unless @loaded
      pattern = encode_adjacency(neighbors)
      tag = "road.tunnel_#{pattern}:0"
      @tiles[tag]
    end

    # Get road tile based on adjacent road cells
    def get_road_tile(neighbors = {})
      load unless @loaded
      pattern = encode_adjacency(neighbors)
      tag = "road.road_#{pattern}:0"
      @tiles[tag]
    end

    # Get terrain feature tiles (thermal vent, glowing rocks, etc.)
    def get_feature_tile(feature_type)
      load unless @loaded
      tag = case feature_type.to_s
            when 'thermal_vent', 'geothermal' then 'ts.thermal_vent:0'
            when 'glowing_rocks', 'radioactive' then 'ts.glowing_rocks:0'
            when 'huge_plant', 'alien_flora' then 'ts.huge_plant:0'
            when 'alien_mine', 'mine' then 'ts.alien_mine:0'
            else nil
            end
      tag ? @tiles[tag] : nil
    end

    # Get base terrain tile (radiating rocks, alien forest)
    def get_terrain_base(terrain_type, layer = 0)
      load unless @loaded
      tag = "t.l#{layer}.#{terrain_type}1"
      @tiles[tag]
    end

    # List all available tiles
    def available_tiles
      load unless @loaded
      @tiles.keys.sort
    end

    # List tiles by category
    def tiles_by_category
      load unless @loaded
      {
        terrain: @tiles.keys.select { |k| k.start_with?('t.') },
        roads: @tiles.keys.select { |k| k.start_with?('road.road_') },
        burrow_tubes: @tiles.keys.select { |k| k.include?('burrow_tube') },
        tunnels: @tiles.keys.select { |k| k.start_with?('road.tunnel_') },
        features: @tiles.keys.select { |k| k.start_with?('ts.') },
        hills: @tiles.keys.select { |k| k.include?('hills_') }
      }
    end

    # Map Galaxy Game body/terrain to Alio terrain
    # Returns hash with recommended tiles for a celestial body
    def tiles_for_body(body_name)
      case body_name.to_s.downcase
      when 'luna', 'moon'
        {
          base: 'radiating_rocks',
          elevation: 'hills',
          underground: 'burrow_tube',
          features: %w[glowing_rocks]
        }
      when 'mars'
        {
          base: 'radiating_rocks',
          elevation: 'hills',
          underground: 'burrow_tube',
          features: %w[thermal_vent glowing_rocks]
        }
      when 'earth'
        {
          base: 'alien_forest', # Will need palette shift to green
          elevation: 'hills',
          underground: 'tunnel',
          features: %w[huge_plant]
        }
      when 'titan'
        {
          base: 'alien_forest',
          elevation: 'hills',
          underground: 'tunnel',
          features: %w[huge_plant alien_mine]
        }
      when 'europa'
        {
          base: 'radiating_rocks', # Ice = white/grey rocks
          elevation: 'hills',
          underground: 'tunnel',
          features: %w[thermal_vent]
        }
      when 'mercury', 'venus'
        {
          base: 'radiating_rocks',
          elevation: 'hills',
          underground: nil,
          features: %w[thermal_vent glowing_rocks]
        }
      else
        {
          base: 'radiating_rocks',
          elevation: 'hills',
          underground: 'burrow_tube',
          features: []
        }
      end
    end

    # Generate CSS for tile rendering (for use in views)
    def tile_css(tag)
      tile = get_tile(tag)
      return nil unless tile

      "background-image: url('/tilesets/alio/#{tile[:image]}'); " \
        "background-position: -#{tile[:x]}px -#{tile[:y]}px; " \
        "width: #{tile[:width]}px; height: #{tile[:height]}px;"
    end

    # Generate data attributes for JavaScript rendering
    def tile_data(tag)
      tile = get_tile(tag)
      return {} unless tile

      {
        'tile-image' => "/tilesets/alio/#{tile[:image]}",
        'tile-x' => tile[:x],
        'tile-y' => tile[:y],
        'tile-width' => tile[:width],
        'tile-height' => tile[:height]
      }
    end

    private

    # Parse a FreeCiv .spec file
    def parse_spec_file(spec_file)
      content = spec_file.read
      current_grid = nil
      image_file = nil

      content.each_line do |line|
        line = line.strip

        # Skip comments and empty lines
        next if line.start_with?(';') || line.start_with?('#') || line.empty?

        # Parse gfx = "alio/terrain" to get image filename
        if line =~ /^gfx\s*=\s*"([^"]+)"/
          # Convert "alio/terrain" to "terrain.png"
          image_file = "#{$1.split('/').last}.png"
        end

        # Parse grid dimensions
        if line =~ /^dx\s*=\s*(\d+)/
          current_grid ||= {}
          current_grid[:dx] = $1.to_i
        end

        if line =~ /^dy\s*=\s*(\d+)/
          current_grid ||= {}
          current_grid[:dy] = $1.to_i
        end

        if line =~ /^x_top_left\s*=\s*(\d+)/
          current_grid ||= {}
          current_grid[:x_offset] = $1.to_i
        end

        if line =~ /^y_top_left\s*=\s*(\d+)/
          current_grid ||= {}
          current_grid[:y_offset] = $1.to_i
        end

        if line =~ /^pixel_border\s*=\s*(\d+)/
          current_grid ||= {}
          current_grid[:border] = $1.to_i
        end

        # Parse tile definitions: row, column, "tag"
        # Format: 0, 0, "ts.thermal_vent:0"
        # Or multiple tags: 0, 0, "tag1", "tag2", "tag3"
        if line =~ /^\s*(\d+),\s*(\d+),\s*(.+)$/
          row = $1.to_i
          col = $2.to_i
          tags_str = $3

          # Extract all quoted tags from the line
          tags = tags_str.scan(/"([^"]+)"/).flatten

          tags.each do |tag|
            next if tag.empty?

            # Use current grid or defaults
            grid = current_grid || {}
            dx = grid[:dx] || TILE_WIDTH
            dy = grid[:dy] || TILE_HEIGHT
            x_offset = grid[:x_offset] || GRID_OFFSET_X
            y_offset = grid[:y_offset] || GRID_OFFSET_Y
            border = grid[:border] || GRID_BORDER

            # Calculate pixel position
            x = x_offset + col * (dx + border)
            y = y_offset + row * (dy + border)

            @tiles[tag] = {
              image: image_file || 'terrain.png',
              x: x,
              y: y,
              width: dx,
              height: dy,
              row: row,
              col: col
            }
          end
        end
      end
    end

    # Encode adjacency as FreeCiv pattern string
    # e.g., { n: true, e: false, se: true, s: false, w: false, nw: false }
    # becomes "n1e0se1s0w0nw0"
    def encode_adjacency(neighbors)
      DIRECTIONS.map do |dir|
        value = neighbors[dir.to_sym] || neighbors[dir] ? 1 : 0
        "#{dir}#{value}"
      end.join
    end

    # Decode adjacency pattern back to hash
    def decode_adjacency(pattern)
      result = {}
      DIRECTIONS.each do |dir|
        if pattern =~ /#{dir}(\d)/
          result[dir.to_sym] = $1 == '1'
        end
      end
      result
    end
  end
end
