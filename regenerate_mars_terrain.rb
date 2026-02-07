# Regenerate Mars terrain with barren biomes
require_relative 'config/environment'

body = CelestialBody.find_by(name: 'Mars')
if body
  generator = StarSim::AutomaticTerrainGenerator.new
  generator.generate_terrain_for_body(body)
  puts "Regenerated terrain for Mars"
else
  puts "Mars not found"
end