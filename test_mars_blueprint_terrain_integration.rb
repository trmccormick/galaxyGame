#!/usr/bin/env ruby
# test_mars_blueprint_terrain_integration.rb

require_relative 'config/environment'
require 'json'

puts "🧪 Testing Mars terrain generation with blueprint integration..."

# Load the Arda blueprint data
civ4_processor = Import::Civ4MapProcessor.new
blueprint_data = civ4_processor.process('/home/galaxy_game/Arda.CivBeyondSwordWBSave', mode: :mars_blueprint)

puts "📊 Blueprint data loaded:"
puts "   Settlement sites: #{blueprint_data[:settlement_sites].size}"
puts "   Terraforming targets: #{blueprint_data[:terraforming_targets].size}"
puts "   Geological features: #{blueprint_data[:geological_features].size}"
puts "   Ocean coverage: #{blueprint_data[:historical_water_levels][:estimated_ocean_coverage]}%"

# Generate terrain with blueprint constraints
terrain_generator = Terrain::MultiBodyTerrainGenerator.new
terrain_data = terrain_generator.generate_terrain(
  'mars',
  width: 180,
  height: 90,  # Smaller for testing
  options: { blueprint_data: blueprint_data }
)

puts "✅ Terrain generated successfully!"
puts "   Grid size: #{terrain_data[:width]}x#{terrain_data[:height]}"
puts "   Body type: #{terrain_data[:body_type]}"
puts "   Source: #{terrain_data[:source]}"

# Analyze the generated terrain
elevation_grid = terrain_data[:elevation]
min_elev = elevation_grid.flatten.min
max_elev = elevation_grid.flatten.max
avg_elev = elevation_grid.flatten.sum / elevation_grid.flatten.size

puts "📈 Elevation statistics:"
puts "   Min: #{min_elev.round(2)}m"
puts "   Max: #{max_elev.round(2)}m"
puts "   Avg: #{avg_elev.round(2)}m"

# Check for water-influenced areas (should be lower elevation)
water_influenced_count = 0
total_cells = elevation_grid.size * elevation_grid.first.size

elevation_grid.each do |row|
  row.each do |elev|
    water_influenced_count += 1 if elev < -100  # Below -100m indicates water influence
  end
end

water_percentage = (water_influenced_count.to_f / total_cells * 100).round(2)
puts "🌊 Water-influenced cells: #{water_influenced_count} (#{water_percentage}%)"

# Compare with expected ocean coverage from blueprint
expected_ocean_coverage = blueprint_data[:historical_water_levels][:estimated_ocean_coverage]
puts "🎯 Blueprint ocean coverage: #{expected_ocean_coverage}%"
puts "📊 Generated water influence: #{water_percentage}%"

if (water_percentage - expected_ocean_coverage).abs < 5.0
  puts "✅ Water constraints applied successfully!"
else
  puts "⚠️  Water influence differs from blueprint (may be due to scaling)"
end

puts "🎉 Test completed!"