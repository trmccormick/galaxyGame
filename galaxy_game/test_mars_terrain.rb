require_relative 'config/environment'

# Wipe any existing Mars terrain so it regenerates
mars = CelestialBody.find_by(name: 'Mars')
if mars&.geosphere
  mars.geosphere.update!(terrain_map: nil)
  puts 'Cleared existing Mars terrain'
end

# Re-trigger terrain generation the same way a reseed does
generator = StarSim::AutomaticTerrainGenerator.new
result = generator.generate_terrain_for_body(mars)

# Verify the three layers
puts '=== RESULTS ==='
puts "Elevation present: #{result[:elevation].is_a?(Array) && result[:elevation].size > 0}"
puts "Elevation dimensions: #{result[:elevation].size}x#{result[:elevation].first&.size}"
puts "Biomes format: #{result[:biomes].class} — #{result[:biomes]}"
puts "Civ4 current_state loaded: #{!result[:civ4_current_state][:biomes].nil?}"
puts "FreeCiv target loaded: #{!result[:freeciv_terraforming_target].nil?}"
puts "Generation metadata: #{result[:generation_metadata]}"
puts "Stored in DB: #{mars.reload.geosphere.terrain_map['elevation'].size rescue 'FAILED'}"