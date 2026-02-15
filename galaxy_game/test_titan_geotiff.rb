#!/usr/bin/env ruby
# test_titan_geotiff.rb
# Test script to verify Titan uses GeoTIFF data instead of procedural terrain

require_relative 'config/environment'

puts "Testing Titan GeoTIFF Usage"
puts "=" * 30

# Find Titan
titan = CelestialBody.find_by(name: 'Titan')
unless titan
  puts "❌ Titan not found in database"
  exit 1
end

puts "Found Titan: #{titan.name} (#{titan.class.name})"

# Check current terrain status
if titan.geosphere&.terrain_map
  puts "Current terrain data present: #{titan.geosphere.terrain_map.keys.join(', ')}"
else
  puts "No terrain data present"
end

# Clear existing terrain data
if titan.geosphere
  titan.geosphere.update!(terrain_map: nil)
  puts "✓ Cleared existing terrain data"
end

# Test GeoTIFF availability
generator = StarSim::AutomaticTerrainGenerator.new

# We need to make the private method accessible for testing
class << generator
  public :nasa_geotiff_available?, :find_geotiff_path
end

geotiff_available = generator.nasa_geotiff_available?('titan')
geotiff_path = generator.find_geotiff_path('titan')

puts "GeoTIFF available for Titan: #{geotiff_available}"
puts "GeoTIFF path: #{geotiff_path || 'NOT FOUND'}"

if geotiff_available
  puts "✓ Titan should use GeoTIFF data"
else
  puts "❌ Titan GeoTIFF not detected - check file paths"
  exit 1
end

# Regenerate terrain
puts "\nRegenerating terrain for Titan..."
result = generator.generate_terrain_for_body(titan)

if result
  puts "✓ Terrain generation completed"
  puts "Result keys: #{result.keys.join(', ')}"

  # Verify terrain was stored
  titan.reload
  if titan.geosphere&.terrain_map
    puts "✓ Terrain stored in database"
    puts "Stored terrain keys: #{titan.geosphere.terrain_map.keys.join(', ')}"
  else
    puts "❌ Terrain not stored in database"
  end
else
  puts "❌ Terrain generation failed"
end

puts "\nTest completed."