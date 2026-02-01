# app/services/tileset/freeciv_tileset_service.rb
module Tileset
  class FreecivTilesetService
    # Default FreeCiv tileset path (can be configured)
    DEFAULT_TILESET_PATH = Rails.root.join('public', 'tilesets')

    attr_reader :tileset_path, :tilespec_data, :tile_images, :errors

    def initialize(tileset_name = 'trident')
      @tileset_name = tileset_name
      @tileset_path = DEFAULT_TILESET_PATH.join(tileset_name)
      @tilespec_data = {}
      @tile_images = {}
      @errors = []
      @loaded = false
    end

    # Load a FreeCiv tileset
    def load_tileset
      return true if @loaded

      unless tileset_exists?
        @errors << "Tileset '#{@tileset_name}' not found at #{@tileset_path}"
        return false
      end

      # Load tilespec file
      unless load_tilespec
        @errors << "Failed to load tilespec file"
        return false
      end

      # Load tile images
      unless load_tile_images
        @errors << "Failed to load tile images"
        return false
      end

      @loaded = true
      true
    end

    # Get tile image for a specific terrain type
    def get_terrain_tile(terrain_type, variation = 0)
      return nil unless @loaded

      # Map Galaxy Game terrain types to FreeCiv terrain names
      freeciv_terrain = map_galaxy_to_freeciv_terrain(terrain_type)
      return nil unless freeciv_terrain

      # Get tile definition from tilespec
      tile_def = @tilespec_data.dig('tiles', freeciv_terrain)
      return nil unless tile_def

      # Get the image and coordinates
      image_name = tile_def['file']
      return nil unless @tile_images[image_name]

      # Return tile data for rendering
      {
        image: @tile_images[image_name],
        x: tile_def['x'] || 0,
        y: tile_def['y'] || 0,
        width: @tilespec_data['tile_width'] || 64,
        height: @tilespec_data['tile_height'] || 64,
        terrain_type: terrain_type
      }
    end

    # Check if tileset directory exists
    def tileset_exists?
      @tileset_path.directory?
    end

    # Get list of available tilesets
    def self.available_tilesets
      return [] unless DEFAULT_TILESET_PATH.directory?

      DEFAULT_TILESET_PATH.children.select(&:directory?).map(&:basename).map(&:to_s)
    end

    private

    # Load tilespec file (.tilespec)
    def load_tilespec
      tilespec_file = @tileset_path.join("#{@tileset_name}.tilespec")

      unless tilespec_file.file?
        @errors << "Tilespec file not found: #{tilespec_file}"
        return false
      end

      begin
        content = tilespec_file.read

        # Parse basic tilespec format (simplified)
        @tilespec_data = parse_tilespec(content)

        # Set defaults if not specified
        @tilespec_data['tile_width'] ||= 64
        @tilespec_data['tile_height'] ||= 64

        true
      rescue => e
        @errors << "Error parsing tilespec: #{e.message}"
        false
      end
    end

    # Parse tilespec content (simplified parser)
    def parse_tilespec(content)
      data = {}
      current_section = nil

      content.each_line do |line|
        line = line.strip

        # Skip comments and empty lines
        next if line.start_with?('#') || line.empty?

        if line.match?(/^\[([^\]]+)\]$/)
          # Section header
          current_section = $1
          data[current_section] = {}
        elsif current_section && line.include?('=')
          # Key-value pair
          key, value = line.split('=', 2).map(&:strip)
          data[current_section][key] = parse_value(value)
        end
      end

      data
    end

    # Parse tilespec values
    def parse_value(value)
      return value.to_i if value.match?(/^\d+$/)
      return value.to_f if value.match?(/^\d+\.\d+$/)
      return true if value.downcase == 'true'
      return false if value.downcase == 'false'
      value.gsub(/^"|"$/, '') # Remove quotes
    end

    # Load tile images
    def load_tile_images
      return false unless @tilespec_data['files']

      @tilespec_data['files'].each do |file_info|
        next unless file_info.is_a?(Hash) && file_info['file']

        image_path = @tileset_path.join(file_info['file'])
        next unless image_path.file?

        # In a real implementation, you'd load the image here
        # For now, we'll just store the path
        @tile_images[file_info['file']] = {
          path: image_path.to_s,
          width: file_info['width'] || @tilespec_data['tile_width'],
          height: file_info['height'] || @tilespec_data['tile_height']
        }
      end

      @tile_images.any?
    end

    # Map Galaxy Game terrain types to FreeCiv terrain names
    def map_galaxy_to_freeciv_terrain(galaxy_terrain)
      mapping = {
        arctic: 'arctic',
        deep_sea: 'deep_ocean',
        desert: 'desert',
        forest: 'forest',
        plains: 'plains',
        grasslands: 'grassland',
        boreal: 'tundra',  # boreal forest maps to tundra
        jungle: 'jungle',
        ocean: 'ocean',
        swamp: 'swamp',
        tundra: 'tundra',
        rock: 'mountains'  # rock maps to mountains
      }

      mapping[galaxy_terrain.to_sym] || 'grassland' # default fallback
    end
  end
end