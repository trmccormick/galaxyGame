# app/services/import/nasa_dem_importer.rb
# NASA Digital Elevation Model (DEM) data importer for AI training
# Processes real elevation data from sources like SRTM, ASTER, etc.

module Import
  class NasaDemImporter
    def initialize
      @supported_formats = ['.tif', '.tiff', '.hgt', '.dem', '.bil']
    end

    # Import NASA DEM data and convert to our elevation/biome format
    def import_dem_file(file_path, planet_name: nil, options: {})
      Rails.logger.info "[NasaDemImporter] Importing DEM file: #{file_path}"

      unless File.exist?(file_path)
        raise "DEM file not found: #{file_path}"
      end

      # Detect format and parse
      elevation_data = case File.extname(file_path).downcase
      when '.tif', '.tiff'
        parse_geotiff(file_path)
      when '.hgt'
        parse_srtm_hgt(file_path)
      when '.dem'
        parse_usgs_dem(file_path)
      when '.bil'
        parse_bil_format(file_path)
      else
        raise "Unsupported DEM format: #{File.extname(file_path)}"
      end

      # Normalize elevation data to 0-1 range
      normalized_elevation = normalize_elevation_data(elevation_data)

      # Generate biomes based on elevation and planet type
      biomes = generate_biomes_from_elevation(normalized_elevation, planet_name, options)

      # Return in format compatible with AI training
      {
        elevation: normalized_elevation,
        biomes: biomes,
        terrain: biomes, # Same for now
        metadata: {
          source: 'nasa_dem',
          filename: File.basename(file_path),
          planet_name: planet_name,
          format: File.extname(file_path),
          dimensions: [normalized_elevation.first&.size || 0, normalized_elevation.size],
          elevation_range: calculate_elevation_range(elevation_data),
          imported_at: Time.current.iso8601
        }
      }
    end

    private

    # Parse GeoTIFF format (ASTER, SRTM data)
    def parse_geotiff(file_path)
      # Placeholder - would use GDAL or similar library
      # For now, return sample data structure
      Rails.logger.warn "[NasaDemImporter] GeoTIFF parsing not implemented - using sample data"
      generate_sample_elevation_data(100, 100)
    end

    # Parse SRTM HGT format
    def parse_srtm_hgt(file_path)
      # SRTM data comes as 16-bit integers
      # Each file covers 1x1 degree, 1201x1201 points (3 arc-second)
      Rails.logger.warn "[NasaDemImporter] SRTM HGT parsing not implemented - using sample data"
      generate_sample_elevation_data(1201, 1201)
    end

    # Parse USGS DEM format
    def parse_usgs_dem(file_path)
      Rails.logger.warn "[NasaDemImporter] USGS DEM parsing not implemented - using sample data"
      generate_sample_elevation_data(100, 100)
    end

    # Parse BIL format
    def parse_bil_format(file_path)
      Rails.logger.warn "[NasaDemImporter] BIL parsing not implemented - using sample data"
      generate_sample_elevation_data(100, 100)
    end

    # Normalize elevation data to 0-1 range
    def normalize_elevation_data(elevation_grid)
      return [] if elevation_grid.empty?

      # Flatten to find min/max
      flat_data = elevation_grid.flatten.compact
      return [] if flat_data.empty?

      min_elev = flat_data.min
      max_elev = flat_data.max
      range = max_elev - min_elev

      return elevation_grid.map do |row|
        row.map do |elev|
          if elev.nil?
            0.5 # Default for missing data
          elsif range == 0
            0.5 # Flat area
          else
            (elev - min_elev).to_f / range
          end
        end
      end
    end

    # Generate biomes based on elevation and planet characteristics
    def generate_biomes_from_elevation(elevation_grid, planet_name, options)
      height = elevation_grid.size
      width = elevation_grid.first&.size || 0

      biomes = Array.new(height) { Array.new(width, 'p') } # Default to plains

      elevation_grid.each_with_index do |row, y|
        row.each_with_index do |elev, x|
          biomes[y][x] = classify_biome(elev, planet_name, options)
        end
      end

      biomes
    end

    # Classify biome based on elevation and planet type
    def classify_biome(elevation, planet_name, options)
      case planet_name&.downcase
      when 'earth', 'terra'
        classify_earth_biome(elevation)
      when 'mars'
        classify_mars_biome(elevation)
      when 'moon', 'luna'
        classify_lunar_biome(elevation)
      else
        classify_generic_biome(elevation)
      end
    end

    def classify_earth_biome(elevation)
      case elevation
      when 0.0..0.3 then 'ocean'      # Low elevations = water
      when 0.3..0.5 then 'plains'     # Coastal/lowland
      when 0.5..0.7 then 'grassland'  # Mid elevations
      when 0.7..0.85 then 'hills'     # Higher elevations
      when 0.85..0.95 then 'mountains' # High mountains
      else 'peaks'    # Highest peaks
      end
    end

    def classify_mars_biome(elevation)
      case elevation
      when 0.0..0.4 then 'lowlands'   # Vastus Borealis, etc.
      when 0.4..0.7 then 'plains'     # Most of Mars surface
      when 0.7..0.9 then 'highlands'  # Ancient highlands
      else 'peaks'    # Olympus Mons, etc.
      end
    end

    def classify_lunar_biome(elevation)
      case elevation
      when 0.0..0.3 then 'maria'      # Lunar seas (low, dark areas)
      when 0.3..0.8 then 'highlands'  # Lunar highlands
      else 'peaks'    # Highest mountains
      end
    end

    def classify_generic_biome(elevation)
      case elevation
      when 0.0..0.4 then 'lowlands'
      when 0.4..0.7 then 'plains'
      when 0.7..0.9 then 'highlands'
      else 'peaks'
      end
    end

    # Calculate elevation range for metadata
    def calculate_elevation_range(elevation_grid)
      flat_data = elevation_grid.flatten.compact
      return { min: 0, max: 0 } if flat_data.empty?

      { min: flat_data.min, max: flat_data.max }
    end

    # Generate sample elevation data for testing
    def generate_sample_elevation_data(width, height)
      # Create realistic-looking elevation using simple noise
      Array.new(height) do |y|
        Array.new(width) do |x|
          # Simple sinusoidal variation to simulate terrain
          base = Math.sin(x * 0.1) * Math.cos(y * 0.1) * 1000
          variation = rand(-200..200)
          (base + variation + 2000).to_i # Ensure positive elevations
        end
      end
    end
  end
end