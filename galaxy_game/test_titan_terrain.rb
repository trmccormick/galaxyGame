#!/usr/bin/env ruby
# test_titan_terrain.rb
# Test script to check Titan's terrain generation and GeoTIFF usage

require_relative 'config/environment'

puts "Testing Titan Terrain Generation"
puts "=" * 40

# Find Titan
titan = CelestialBodies::CelestialBody.find_by(name: 'Titan')
unless titan
  puts "❌ Titan not found in database"
  puts "Available celestial bodies:"
  CelestialBodies::CelestialBody.all.each do |body|
    puts "  - #{body.name} (#{body.class.name})"
  end
  exit 1
end

puts "✓ Found Titan: #{titan.name} (#{titan.class.name})"

# Check if Titan has terrain data
if titan.geosphere&.terrain_map.present?
  terrain_keys = titan.geosphere.terrain_map.keys.join(', ')
  puts "⚠️  Titan already has terrain data: #{terrain_keys}"

  # Check if it's populated
  generator = StarSim::AutomaticTerrainGenerator.new
  has_populated = generator.send(:has_populated_terrain_data?, titan)
  puts "Has populated terrain data: #{has_populated}"

  if has_populated
    puts "Clearing existing terrain data..."
    titan.geosphere.update!(terrain_map: nil)
    puts "✓ Terrain data cleared"
  end
else
  puts "ℹ️  Titan has no terrain data"
end

# Check GeoTIFF availability (using send to access private method)
generator = StarSim::AutomaticTerrainGenerator.new
geotiff_available = generator.send(:nasa_geotiff_available?, 'titan')
geotiff_path = generator.send(:find_geotiff_path, 'titan')

puts "GeoTIFF available for Titan: #{geotiff_available}"
puts "GeoTIFF path: #{geotiff_path || 'NOT FOUND'}"

# Check if Titan should get terrain generation
should_generate = generator.send(:should_generate_terrain?, titan)
is_sol_world = generator.send(:sol_system_world?, titan)

puts "Should generate terrain: #{should_generate}"
puts "Is Sol system world: #{is_sol_world}"

# Generate terrain
puts "\nGenerating terrain for Titan..."
result = generator.generate_terrain_for_body(titan)

if result
  puts "✓ Terrain generation completed"
  puts "Result keys: #{result.keys.join(', ')}"

  # Check if terrain was stored
  titan.reload
  if titan.geosphere&.terrain_map.present?
    stored_keys = titan.geosphere.terrain_map.keys.join(', ')
    puts "✓ Terrain stored in database: #{stored_keys}"

    # Check elevation dimensions
    if result['elevation']&.is_a?(Array) && result['elevation'].size > 0
      elevation = result['elevation']
      puts "Elevation grid: #{elevation.size}x#{elevation.first&.size || 0}"
    end
  else
    puts "❌ Terrain not stored in database"
  end
else
  puts "❌ Terrain generation failed or returned nil"
end

puts "\nTest completed."