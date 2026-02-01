#!/usr/bin/env ruby
# scripts/generate_sol_planetary_maps.rb
# Generate and apply planetary maps for Sol system bodies (Earth, Mars)

require_relative '../config/environment'

puts "🌍 Generating Planetary Maps for Sol System Bodies"
puts "=" * 60

# Find Sol system celestial bodies
sol_system = ::CelestialBodies::Star.find_by(name: 'Sol')
if sol_system.nil?
  puts "❌ Could not find Sol star system"
  exit 1
end

earth = ::CelestialBodies::CelestialBody.find_by(name: 'Earth')
mars = ::CelestialBodies::CelestialBody.find_by(name: 'Mars')

bodies_to_process = [earth, mars].compact

if bodies_to_process.empty?
  puts "❌ No Sol system bodies found to process"
  exit 1
end

generator = AIManager::PlanetaryMapGenerator.new

bodies_to_process.each do |body|
  puts "\n🧪 Processing #{body.name}..."

  begin
    # Generate planetary map using NASA terrain (no sources needed)
    map_data = generator.generate_planetary_map(
      planet: body,
      sources: [],  # Use procedural/NASA terrain generation
      options: {
        width: 120,   # Reasonable size for planetary maps
        height: 60,
        quality: 'high'
      }
    )

    puts "  ✅ Generated #{map_data[:terrain_grid].size}x#{map_data[:terrain_grid].first.size} terrain grid"
    puts "  ✅ Generated #{map_data[:elevation_data].size}x#{map_data[:elevation_data].first.size} elevation grid"

    # Check terrain types
    terrain_types = map_data[:terrain_grid].flatten.uniq
    puts "  📊 Terrain types: #{terrain_types.sort.join(', ')}"

    # Check elevation range
    elevations = map_data[:elevation_data].flatten
    elev_min = elevations.min
    elev_max = elevations.max
    puts "  📊 Elevation range: #{elev_min.round(1)} - #{elev_max.round(1)} meters"

    # Apply the map to the celestial body
    puts "  📝 Applying map to #{body.name}..."

    # Ensure geosphere exists
    geosphere = body.geosphere || body.build_geosphere

    # Apply terrain map data
    terrain_map_data = {
      grid: map_data[:terrain_grid],
      width: map_data[:terrain_grid].first&.size || 0,
      height: map_data[:terrain_grid].size,
      elevation_data: map_data[:elevation_data],
      biome_counts: map_data[:biome_counts] || {},
      quality: map_data[:metadata]&.dig(:nasa_derived) ? 'nasa_derived' : 'procedural',
      method: map_data[:metadata]&.dig(:generator) || 'unknown',
      generated_at: Time.current.iso8601
    }

    geosphere.update!(terrain_map: terrain_map_data)

    # Update properties
    body.properties['applied_map'] = {
      generated_at: Time.current.iso8601,
      source: 'nasa_terrain_generation',
      quality: terrain_map_data[:quality],
      dimensions: "#{terrain_map_data[:width]}x#{terrain_map_data[:height]}"
    }
    body.properties['map_source'] = 'ai_generated'
    body.save!

    puts "  ✅ Successfully applied terrain map to #{body.name}"
    puts "  📍 Map dimensions: #{terrain_map_data[:width]}x#{terrain_map_data[:height]}"
    puts "  🏔️  Quality: #{terrain_map_data[:quality]}"

  rescue => e
    puts "  ❌ Error processing #{body.name}: #{e.message}"
    puts "  📋 Backtrace: #{e.backtrace.first(3).join(' | ')}"
  end
end

puts "\n" + "=" * 60
puts "🎯 Sol System Planetary Map Generation Complete!"
puts "The monitor page should now display terrain data for Earth and Mars."
puts "Visit: http://localhost:3000/admin/celestial_bodies to view the results."