#!/usr/bin/env ruby
# process_initial_maps.rb
# Script to process initial game location maps and generate elevation data
# Processes Earth (FreeCiv + Civ4), Mars (FreeCiv), Venus (FreeCiv + Civ4), Luna (Civ4), Titan (Civ4)

require_relative 'config/environment'
require_relative 'app/services/map_layer_service'

class InitialMapProcessor
  def initialize
    @map_service = MapLayerService.new
    @logger = Logger.new(STDOUT)
  end

  def process_all_locations
    @logger.info("Starting initial map processing for game locations...")

    locations = [
      { name: 'Earth', freeciv_path: 'freeCiv_maps/earth-180x90-v1-3.sav' },
      { name: 'Mars', freeciv_path: 'freeCiv_maps/mars-terraformed-133x64-v2.0.sav' }
    ]

    locations.each do |location|
      process_location(location)
    end

    @logger.info("Initial map processing complete!")
  end

  private

  def process_location(location_config)
    name = location_config[:name]
    @logger.info("Processing #{name}...")

    # Find the celestial body
    celestial_body = CelestialBodies::CelestialBody.find_by(name: name)
    unless celestial_body
      @logger.warn("Celestial body '#{name}' not found, skipping...")
      return
    end

    # Load map data
    map_data = load_map_data(location_config)
    return if map_data.empty?

    # Process layers
    layers = @map_service.process_map_layers(map_data)
    return if layers.empty? || layers[:error]

    # Store in geosphere
    success = @map_service.store_in_geosphere(celestial_body, layers)

    if success
      @logger.info("Successfully processed #{name}: #{layers[:quality]} quality, #{layers[:method]} method")
    else
      @logger.error("Failed to store #{name} elevation data")
    end
  end

  def load_map_data(location_config)
    map_data = {}

    # Load FreeCiv data if available
    if location_config[:freeciv_path] && File.exist?(location_config[:freeciv_path])
      freeciv_data = load_freeciv_map(location_config[:freeciv_path])
      map_data.merge!(freeciv_data) if freeciv_data
    end

    # Load Civ4 data if available
    if location_config[:civ4_path] && File.exist?(location_config[:civ4_path])
      civ4_data = load_civ4_map(location_config[:civ4_path])
      map_data.merge!(civ4_data) if civ4_data
    end

    map_data
  end

  def load_freeciv_map(file_path)
    @logger.debug("Loading FreeCiv map: #{file_path}")

    # Use existing FreeCiv import service
    importer = Import::FreecivSavImportService.new(file_path)
    data = importer.import

    return nil unless data && data[:grid]

    {
      format: :freeciv,
      terrain: data[:grid],
      width: data[:width],
      height: data[:height]
    }
  rescue => e
    @logger.error("Failed to load FreeCiv map #{file_path}: #{e.message}")
    nil
  end

  def load_civ4_map(file_path)
    @logger.debug("Loading Civ4 map: #{file_path}")

    # Use existing Civ4 import service
    importer = Import::Civ4WbsImportService.new(file_path)
    data = importer.import

    return nil unless data && data[:plots]

    {
      format: :civ4,
      plots: data[:plots],
      width: data[:width],
      height: data[:height]
    }
  rescue => e
    @logger.error("Failed to load Civ4 map #{file_path}: #{e.message}")
    nil
  end
end

# Run the processor if called directly
if __FILE__ == $0
  processor = InitialMapProcessor.new
  processor.process_all_locations
end