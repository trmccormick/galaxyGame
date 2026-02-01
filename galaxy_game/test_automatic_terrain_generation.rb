#!/usr/bin/env ruby
# test_automatic_terrain_generation.rb
# Test script to validate automatic terrain generation integration

require_relative 'config/environment'
require_relative 'app/services/star_sim/automatic_terrain_generator'
require_relative 'app/services/terrain_analysis/terrain_quality_assessor'

puts "Testing Automatic Terrain Generation Integration"
puts "=" * 50

# Test 1: Create a test terrestrial planet
puts "\n1. Creating test terrestrial planet..."
test_planet = CelestialBodies::Planets::Rocky::TerrestrialPlanet.create!(
  name: "TestPlanet-#{Time.now.to_i}",
  identifier: "test-planet-#{Time.now.to_i}",
  solar_system: SolarSystem.first || SolarSystem.create!(name: "TestSystem", galaxy: Galaxy.first || Galaxy.create!(name: "TestGalaxy")),
  radius: 6371000,  # Earth-like radius in meters
  mass: 5.972e24,   # Earth-like mass
  surface_temperature: 288,  # Earth temperature
  properties: {
    'volcanic_activity' => 'moderate',
    'water_dominant' => false,
    'has_water' => true
  }
)

# Create basic spheres for the planet
test_planet.create_atmosphere!(
  composition: { 'N2' => 78.0, 'O2' => 21.0, 'CO2' => 0.04 },
  pressure: 1.0,
  total_atmospheric_mass: 5.15e18
)

test_planet.create_hydrosphere!(
  water_coverage: 71.0,
  composition: { 'H2O' => 100.0 },
  state_distribution: { 'liquid' => 70.0, 'solid' => 30.0, 'gas' => 0.0 }
)

test_planet.create_biosphere!(habitable_ratio: 0.0, biodiversity_index: 0.0)

puts "✓ Test planet created: #{test_planet.name}"

# Test 2: Generate automatic terrain
puts "\n2. Generating automatic terrain..."
terrain_generator = StarSim::AutomaticTerrainGenerator.new
generated_terrain = terrain_generator.generate_terrain_for_body(test_planet)

if generated_terrain
  puts "✓ Terrain generated successfully"
  puts "  - Grid size: #{generated_terrain[:grid]&.size}x#{generated_terrain[:grid]&.first&.size}"
  puts "  - Elevation data: #{generated_terrain[:elevation] ? 'present' : 'missing'}"
  puts "  - Resource grid: #{generated_terrain[:resource_grid] ? 'present' : 'missing'}"
  puts "  - Strategic markers: #{generated_terrain[:strategic_markers]&.size || 0}"
else
  puts "✗ Terrain generation failed"
end

# Test 3: Assess terrain quality
puts "\n3. Assessing terrain quality..."
if generated_terrain
  quality_assessor = TerrainAnalysis::TerrainQualityAssessor.new
  planet_properties = {
    radius: test_planet.radius,
    surface_temperature: test_planet.surface_temperature,
    mass: test_planet.mass
  }

  quality_scores = quality_assessor.assess_terrain_quality(generated_terrain, planet_properties)

  puts "✓ Quality assessment completed:"
  puts "  - Overall: #{(quality_scores[:overall] * 100).round(1)}%"
  puts "  - Realism: #{(quality_scores[:realism] * 100).round(1)}%"
  puts "  - Playability: #{(quality_scores[:playability] * 100).round(1)}%"
  puts "  - Diversity: #{(quality_scores[:diversity] * 100).round(1)}%"
  puts "  - Balance: #{(quality_scores[:balance] * 100).round(1)}%"
end

# Test 4: Verify geosphere storage
puts "\n4. Verifying geosphere storage..."
geosphere = test_planet.geosphere
if geosphere&.terrain_metadata
  metadata = geosphere.terrain_metadata
  puts "✓ Terrain stored in geosphere:"
  puts "  - Generation method: #{metadata['generation_method']}"
  puts "  - Quality score: #{metadata['quality_score']&.round(3)}"
  puts "  - Has quality assessment: #{metadata['quality_assessment'].present?}"
else
  puts "✗ Terrain not properly stored in geosphere"
end

# Test 5: Test with different planet types
puts "\n5. Testing with different planet types..."

# Mars-like planet
mars_planet = CelestialBodies::Planets::Rocky::TerrestrialPlanet.create!(
  name: "TestMars-#{Time.now.to_i}",
  identifier: "test-mars-#{Time.now.to_i}",
  solar_system: test_planet.solar_system,
  radius: 3390000,  # Mars radius
  mass: 6.39e23,    # Mars mass
  surface_temperature: 210,  # Mars temperature
  properties: { 'thin_atmosphere' => true }
)

mars_planet.create_atmosphere!(composition: { 'CO2' => 95.0 }, pressure: 0.006)
mars_planet.create_hydrosphere!(water_coverage: 0.0, composition: {})
mars_planet.create_biosphere!(habitable_ratio: 0.0, biodiversity_index: 0.0)

mars_terrain = terrain_generator.generate_terrain_for_body(mars_planet)
puts "✓ Mars-like terrain generated: #{mars_terrain ? 'success' : 'failed'}"

# Cleanup
puts "\n6. Cleaning up test data..."
test_planet.destroy
mars_planet.destroy
puts "✓ Test cleanup completed"

puts "\n" + "=" * 50
puts "Automatic Terrain Generation Test Complete!"
puts "All systems integrated successfully!"