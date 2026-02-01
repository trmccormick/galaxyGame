# app/services/import/freeciv_sav_import_service.rb
module Import
  class FreecivSavImportService
    # FreeCiv terrain character mappings to Galaxy Game terrain types
    TERRAIN_MAPPING = {
      'a' => :arctic,
      ':' => :deep_sea,
      'd' => :desert,
      'f' => :forest,
      'p' => :plains,
      'g' => :grasslands,
      'h' => :boreal,  # hills
      'j' => :jungle,
      '+' => :ocean,   # lake
      'm' => :boreal,  # mountain
      ' ' => :ocean,
      's' => :swamp,
      't' => :tundra
    }.freeze

    # Default terrain type for unrecognized characters
    DEFAULT_TERRAIN = :rock

    attr_reader :file_path, :errors

    def initialize(file_path)
      @file_path = file_path
      @errors = []
    end

    # Main import method - parses SAV file and returns terrain grid
    def import
      return false unless validate_file

      terrain_grid = []
      biome_counts = Hash.new(0)
      current_terrain_line = nil

      begin
        File.open(@file_path, 'r') do |file|
          file.each_line do |line|
            # Handle line continuation (backslash at end)
            if line.end_with?("\\\n") || line.end_with?("\\\r\n")
              current_terrain_line = (current_terrain_line || '') + line.chomp.chomp('\\')
              next
            end

            # If we have accumulated a multi-line terrain entry, complete it
            if current_terrain_line
              line = current_terrain_line + line.chomp
              current_terrain_line = nil
            end

            next unless terrain_line?(line)

            terrain_data = extract_terrain_data(line)
            next unless terrain_data

            row_data = parse_terrain_row(terrain_data, biome_counts)
            terrain_grid << row_data if row_data.any?
          end
        end

        # Validate we got some data
        if terrain_grid.empty?
          @errors << "No terrain data found in SAV file"
          return false
        end

        # Check grid consistency
        unless consistent_grid?(terrain_grid)
          @errors << "Inconsistent terrain grid dimensions"
          return false
        end

        {
          grid: terrain_grid,
          width: terrain_grid.first&.size || 0,
          height: terrain_grid.size,
          biome_counts: biome_counts,
          source_file: @file_path
        }

      rescue => e
        @errors << "Error parsing SAV file: #{e.message}"
        false
      end
    end

    private

    # Validate the file exists and is readable
    def validate_file
      unless File.exist?(@file_path)
        @errors << "SAV file not found: #{@file_path}"
        return false
      end

      unless File.readable?(@file_path)
        @errors << "SAV file not readable: #{@file_path}"
        return false
      end

      true
    end

    # Check if line contains terrain data (starts with 't' followed by digits and '=')
    def terrain_line?(line)
      line.strip.match?(/^t\d+=".*"$/)
    end

    # Extract terrain data from a line (content between quotes after '=')
    def extract_terrain_data(line)
      # Match the pattern tXXXX="terraindata"
      match = line.strip.match(/^t\d+="(.+)"$/)
      return nil unless match

      match[1]
    end

    # Parse a row of terrain characters
    def parse_terrain_row(terrain_string, biome_counts)
      terrain_string.chars.map do |char|
        terrain_type = TERRAIN_MAPPING[char] || DEFAULT_TERRAIN
        biome_counts[terrain_type] += 1
        terrain_type
      end
    end

    # Check if all rows have the same width
    def consistent_grid?(grid)
      return true if grid.empty?

      first_row_size = grid.first.size
      grid.all? { |row| row.size == first_row_size }
    end
  end
end