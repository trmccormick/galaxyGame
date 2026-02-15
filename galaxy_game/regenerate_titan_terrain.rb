#!/usr/bin/env ruby
# regenerate_titan_terrain.rb
# Script to clear Titan's existing terrain and regenerate it using GeoTIFF data

require_relative 'config/environment'

puts "Regenerating Titan Terrain"
puts "=" * 30

# Find Titan
titan = CelestialBodies::Moon.find_by(name: 'Titan')
unless titan
  puts "❌ Titan not found in database"
  exit 1
end

puts "Found Titan: #{titan.name} (#{titan.class.name})"

# Check current terrain status
if titan.geosphere&.terrain_map
  puts "Current terrain data present: #{titan.geosphere.terrain_map.keys.join(', ')}"
  puts "Clearing existing terrain data..."
  titan.geosphere.update!(terrain_map: nil)
  puts "✓ Cleared existing terrain data"
else
  puts "No existing terrain data found"
end

# Regenerate terrain
puts "\nRegenerating terrain for Titan..."
generator = StarSim::AutomaticTerrainGenerator.new
result = generator.generate_terrain_for_body(titan)

if result
  puts "✓ Terrain generation completed"
  puts "Result keys: #{result.keys.join(', ')}"

  # Verify terrain was stored
  titan.reload
  if titan.geosphere&.terrain_map
    puts "✓ Terrain stored in database"
    puts "Stored terrain keys: #{titan.geosphere.terrain_map.keys.join(', ')}"

    # Check if it used GeoTIFF
    if titan.geosphere.terrain_map['generation_metadata']&.dig('source')&.include?('nasa')
      puts "✓ Terrain used NASA GeoTIFF data"
    else
      puts "⚠ Terrain did not use GeoTIFF - check logs for details"
    end
  else
    puts "❌ Terrain not stored in database"
  end
else
  puts "❌ Terrain generation failed or returned nil"
end

puts "\nRegeneration completed."