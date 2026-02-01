#!/usr/bin/env ruby
# scripts/test_multi_body_terrain.rb
# Test the new multi-body terrain generator with NASA-derived patterns

require_relative '../galaxy_game/config/environment'

puts "🌍 Testing Multi-Body Terrain Generator"
puts "=" * 50

generator = Terrain::MultiBodyTerrainGenerator.new

# Test each body type
bodies = ['luna', 'mars', 'earth']

bodies.each do |body|
  puts "\n🧪 Testing #{body.upcase} terrain generation..."

  begin
    # Generate small test terrain
    terrain_data = generator.generate_terrain(body, width: 100, height: 50)

    # Validate the result
    grid = terrain_data[:grid]
    elevation = terrain_data[:elevation]

    puts "  ✅ Generated #{grid.size}x#{grid.first.size} terrain grid"
    puts "  ✅ Generated #{elevation.size}x#{elevation.first.size} elevation grid"
    puts "  📊 Terrain types: #{grid.flatten.uniq.sort.join(', ')}"
    puts "  📊 Elevation range: #{elevation.flatten.min.round(1)} - #{elevation.flatten.max.round(1)}"
    puts "  🏷️  Body type: #{terrain_data[:body_type]}"
    puts "  🔧 Generator: #{terrain_data[:generator]}"
    puts "  📁 Source: #{terrain_data[:source]}"

    if terrain_data[:characteristics]
      puts "  🌟 Characteristics: #{terrain_data[:characteristics]['features']&.join(', ')}"
    end

  rescue => e
    puts "  ❌ Error generating #{body} terrain: #{e.message}"
    puts "  📋 Backtrace: #{e.backtrace.first(3).join(' | ')}"
  end
end

puts "\n" + "=" * 50
puts "🎯 Multi-Body Terrain Generator Test Complete!"
puts "Ready for integration into the planetary map generation system."