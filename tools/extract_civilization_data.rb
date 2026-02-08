#!/usr/bin/env ruby
# tools/extract_civilization_data.rb
# Extract civilization layer data from Freeciv and Civ4 maps

require 'json'
require 'pathname'

class CivilizationDataExtractor
  def initialize
    @earth_data_path = Pathname.new('data/json-data/star_systems/sol/celestial_bodies/earth')
    @maps_path = Pathname.new('data/maps')
  end

  def extract_all
    puts "🔍 EXTRACTING CIVILIZATION DATA FROM EARTH MAPS"

    # Extract strategic locations from terrain analysis
    extract_strategic_locations_from_terrain

    # Extract resource hubs from Civ4 bonus data
    extract_resource_hubs_from_civ4

    # Generate major cities from real-world data
    generate_major_cities

    puts "✅ Civilization data extraction complete"
  end

  private

  def extract_strategic_locations_from_terrain
    puts "📍 Analyzing terrain for strategic locations..."

    # Load Freeciv terrain data
    freeciv_data = load_freeciv_terrain
    civ4_data = load_civ4_terrain

    strategic_locations = []

    # Find coastal cities (trade hubs)
    coastal_positions = find_coastal_positions(freeciv_data)
    coastal_positions.first(10).each do |pos|
      strategic_locations << {
        id: "earth_strategic_coastal_#{pos[:x]}_#{pos[:y]}",
        name: generate_coastal_name(pos),
        coordinates: grid_to_lat_lon(pos[:x], pos[:y], freeciv_data[:width], freeciv_data[:height]),
        strategic_value: ["coastal_trade", "port_facility"],
        gameplay_data: {
          settlement_bonus: ["maritime_trade", "fishing"],
          terrain_advantage: "coastal_access"
        }
      }
    end

    # Find river junctions (trade hubs)
    river_junctions = find_river_junctions(freeciv_data)
    river_junctions.first(5).each do |pos|
      strategic_locations << {
        id: "earth_strategic_river_#{pos[:x]}_#{pos[:y]}",
        name: generate_river_name(pos),
        coordinates: grid_to_lat_lon(pos[:x], pos[:y], freeciv_data[:width], freeciv_data[:height]),
        strategic_value: ["river_trade", "water_transport"],
        gameplay_data: {
          settlement_bonus: ["inland_trade", "irrigation"],
          terrain_advantage: "river_access"
        }
      }
    end

    save_strategic_locations(strategic_locations)
  end

  def extract_resource_hubs_from_civ4
    puts "⛏️ Analyzing Civ4 map for resource deposits..."

    civ4_data = load_civ4_terrain
    resource_hubs = []

    # Process plots with bonus resources
    civ4_data[:plots].each do |plot|
      next unless plot[:bonus_type]

      resource_info = map_civ4_bonus_to_resource(plot[:bonus_type])
      next unless resource_info

      resource_hubs << {
        id: "earth_resource_#{plot[:x]}_#{plot[:y]}",
        name: generate_resource_name(resource_info[:type], plot),
        coordinates: grid_to_lat_lon(plot[:x], plot[:y], civ4_data[:width], civ4_data[:height]),
        resource_type: resource_info[:category],
        resource_data: resource_info,
        gameplay_data: {
          extraction_bonus: resource_info[:extraction_bonus] || 1.0,
          settlement_type: resource_info[:settlement_type] || "mining_outpost"
        }
      }
    end

    save_resource_hubs(resource_hubs)
  end

  def generate_major_cities
    puts "🏙️ Generating major cities from historical data..."

    # This would be expanded with real research
    major_cities = [
      {
        name: "New Babylon",
        original_name: "Baghdad",
        coordinates: { latitude: 33.3152, longitude: 44.3661 },
        historical_context: {
          founding_civilization: "Mesopotamian",
          strategic_importance: "Tigris-Euphrates rivers, trade crossroads"
        }
      },
      # Add more cities...
    ]

    save_major_cities(major_cities)
  end

  def load_freeciv_terrain
    # Load processed Freeciv data
    freeciv_path = @maps_path.join('freeciv/earth/earth-180x90-v1-3.sav')
    # Parse the SAV file (simplified)
    { width: 180, height: 90, grid: [] } # Placeholder
  end

  def load_civ4_terrain
    # Load processed Civ4 data
    civ4_path = @maps_path.join('civ4/earth/Earth.Civ4WorldBuilderSave')
    # Parse the WBS file (simplified)
    { width: 180, height: 90, plots: [] } # Placeholder
  end

  def find_coastal_positions(data)
    # Analyze terrain for coastal positions
    []
  end

  def find_river_junctions(data)
    # Analyze terrain for river junctions
    []
  end

  def grid_to_lat_lon(x, y, width, height)
    # Convert grid coordinates to lat/lon
    latitude = 90 - (y.to_f / height) * 180
    longitude = (x.to_f / width) * 360 - 180
    { latitude: latitude.round(4), longitude: longitude.round(4) }
  end

  def map_civ4_bonus_to_resource(bonus_type)
    mapping = {
      'BONUS_IRON' => { type: 'iron_ore', category: 'metal_ore', extraction_bonus: 1.5 },
      'BONUS_OIL' => { type: 'crude_oil', category: 'hydrocarbons', extraction_bonus: 2.0 },
      'BONUS_COAL' => { type: 'coal', category: 'carbon', extraction_bonus: 1.3 }
    }
    mapping[bonus_type]
  end

  def generate_coastal_name(pos)
    names = ["Port", "Harbor", "Bay", "Coast", "Maritime"]
    "#{names.sample} #{pos[:x] % 100}"
  end

  def generate_river_name(pos)
    names = ["Riverbend", "Crossing", "Ford", "Junction", "Confluence"]
    "#{names.sample} #{pos[:y] % 100}"
  end

  def generate_resource_name(resource_type, plot)
    "#{resource_type.titleize} Field #{plot[:x]}_#{plot[:y]}"
  end

  def save_strategic_locations(locations)
    output_path = @earth_data_path.join('geological_features/strategic_locations_extracted.json')
    output_path.parent.mkpath

    data = {
      celestial_body: "earth",
      feature_type: "strategic_location",
      tier: "extracted",
      last_updated: Time.now.strftime('%Y-%m-%d'),
      total_features: locations.size,
      features: locations
    }

    File.write(output_path, JSON.pretty_generate(data))
    puts "💾 Saved #{locations.size} strategic locations to #{output_path}"
  end

  def save_resource_hubs(hubs)
    output_path = @earth_data_path.join('geological_features/resource_hubs_extracted.json')
    output_path.parent.mkpath

    data = {
      celestial_body: "earth",
      feature_type: "resource_hub",
      tier: "extracted",
      last_updated: Time.now.strftime('%Y-%m-%d'),
      total_features: hubs.size,
      features: hubs
    }

    File.write(output_path, JSON.pretty_generate(data))
    puts "💾 Saved #{hubs.size} resource hubs to #{output_path}"
  end

  def save_major_cities(cities)
    output_path = @earth_data_path.join('geological_features/major_cities_extracted.json')
    output_path.parent.mkpath

    data = {
      celestial_body: "earth",
      feature_type: "major_city",
      tier: "extracted",
      last_updated: Time.now.strftime('%Y-%m-%d'),
      total_features: cities.size,
      features: cities
    }

    File.write(output_path, JSON.pretty_generate(data))
    puts "💾 Saved #{cities.size} major cities to #{output_path}"
  end
end

# Run extraction if called directly
if __FILE__ == $0
  extractor = CivilizationDataExtractor.new
  extractor.extract_all
end