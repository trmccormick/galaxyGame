# scripts/generate_test_maps.rb

puts "=== Generating Test Maps ==="

# Generate Earth maps
earth = CelestialBody.find_by(name: 'Earth')

# Before (pure procedural)
before = AIManager::PlanetaryMapGenerator.new.generate_planet_map(
  earth,
  use_patterns: false
)

# After (with GeoTIFF patterns)
after = AIManager::PlanetaryMapGenerator.new.generate_planet_map(
  earth,
  use_patterns: true
)

# Save for comparison
FileUtils.mkdir_p('tmp/map_comparison')

File.write('tmp/map_comparison/earth_before.json', before.to_json)
File.write('tmp/map_comparison/earth_after.json', after.to_json)

puts "Maps saved to tmp/map_comparison/"
puts "Before: #{File.size('tmp/map_comparison/earth_before.json')} bytes"
puts "After: #{File.size('tmp/map_comparison/earth_after.json')} bytes"

# Generate visualizations
puts "Generating visualizations..."
# ... render both maps to PNG for visual comparison ...

puts "=== Complete ==="