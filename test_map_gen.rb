#!/usr/bin/env ruby

require_relative 'config/environment'
require './lib/ai_manager/planetary_map_generator'

puts "Testing PlanetaryMapGenerator..."

planet = CelestialBodies::CelestialBody.find_or_create_by!(name: "TestPlanet", identifier: "TEST-001")
generator = AIManager::PlanetaryMapGenerator.new
sources = []
map = generator.generate_planetary_map(planet: planet, sources: sources, options: {width: 10, height: 5})

puts "Generated map keys: #{map.keys.join(', ')}"
puts "Has terrain_grid: #{!map[:terrain_grid].nil?}"
puts "Has biome_counts: #{!map[:biome_counts].nil?}"
puts "Terrain grid size: #{map[:terrain_grid]&.size}x#{map[:terrain_grid]&.first&.size}" if map[:terrain_grid]
puts "Biome counts: #{map[:biome_counts]}" if map[:biome_counts]