# app/services/import/terrain_seeder.rb

require_relative 'civ4_wbs_import_service'
require_relative 'freeciv_sav_import_service'
require_relative '../terrain_analysis/terrain_decomposition_service'

module Import
  class TerrainSeeder
    # Automatic terrain seeding during database setup
    # Discovers and imports Civ4/FreeCiv maps, decomposes them into layers
    # Makes terrain import turnkey without manual intervention

    MAP_DIRECTORIES = [
      GalaxyGame::Paths::FREECIV_MAPS_PATH.to_s,
      GalaxyGame::Paths::PARTIAL_PLANETARY_MAPS_PATH.to_s,
      GalaxyGame::Paths::CIV4_MAPS_PATH.to_s,
      GalaxyGame::Paths::TOPOLOGY_MAPS_PATH.to_s,
      'data/freeCiv\ Maps',
      GalaxyGame::Paths::MAPS_PATH.to_s,
      'data/tilesets'
    ].freeze

    SUPPORTED_EXTENSIONS = {
      '.Civ4WorldBuilderSave' => :civ4,
      '.sav' => :freeciv
    }.freeze

    attr_reader :imported_maps, :errors

    def initialize
      @imported_maps = []
      @errors = []
    end

    # Discover and import all available terrain maps
    def seed_all_maps
      Rails.logger.info "Starting automatic terrain seeding..."

      discover_map_files.each do |file_path, format|
        begin
          Rails.logger.info "Importing #{format} map: #{file_path}"

          # Import raw terrain data
          raw_data = import_map_file(file_path, format)
          next unless raw_data

          # Decompose into layers
          decomposed_data = decompose_terrain(raw_data)

          # Store in database (this would integrate with your planet creation logic)
          store_decomposed_terrain(decomposed_data, file_path)

          @imported_maps << {
            file: file_path,
            format: format,
            dimensions: "#{decomposed_data['width']}x#{decomposed_data['height']}",
            water_volume: decomposed_data['water_volume']
          }

        rescue => e
          error_msg = "Failed to import #{file_path}: #{e.message}"
          Rails.logger.error error_msg
          @errors << error_msg
        end
      end

      Rails.logger.info "Terrain seeding complete. Imported #{@imported_maps.size} maps with #{@errors.size} errors."
      { imported: @imported_maps, errors: @errors }
    end

    private

    # Discover all map files in configured directories
    def discover_map_files
      map_files = {}

      MAP_DIRECTORIES.each do |dir|
        dir_path = Rails.root.join(dir)
        next unless Dir.exist?(dir_path)

        Dir.glob("#{dir_path}/**/*").each do |file_path|
          next unless File.file?(file_path)

          extension = File.extname(file_path)
          format = SUPPORTED_EXTENSIONS[extension]

          next unless format

          # Use filename as key to avoid duplicates
          filename = File.basename(file_path)
          map_files[filename] ||= [file_path, format]
        end
      end

      map_files.values
    end

    # Import map file using appropriate service
    def import_map_file(file_path, format)
      case format
      when :civ4
        service = Civ4WbsImportService.new(file_path)
        service.import
      when :freeciv
        service = FreecivSavImportService.new(file_path)
        service.import
      else
        raise "Unsupported format: #{format}"
      end
    end

    # Decompose terrain into layers using TerrainDecompositionService
    def decompose_terrain(raw_data)
      service = TerrainAnalysis::TerrainDecompositionService.new(raw_data)
      service.decompose
    end

    # Store decomposed terrain data (placeholder - integrate with your planet model)
    def store_decomposed_terrain(decomposed_data, file_path)
      # This would integrate with your CelestialBody/Geosphere creation logic
      # For now, just log what would be stored
      Rails.logger.info "Would store decomposed terrain for #{File.basename(file_path)}: " \
                       "#{decomposed_data['width']}x#{decomposed_data['height']}, " \
                       "water_volume: #{decomposed_data['water_volume']&.round(3)}"

      # Example integration (uncomment when ready):
      # planet = CelestialBody.create!(
      #   name: File.basename(file_path, '.*').humanize,
      #   body_type: 'terrestrial_planet',
      #   properties: { terrain_source: file_path }
      # )
      #
      # planet.create_geosphere!(
      #   terrain_map: decomposed_data,
      #   # ... other geosphere attributes
      # )
    end
  end
end