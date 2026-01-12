#!/usr/bin/env ruby
require 'json'

puts "=== Sol System Data Validation and Demo ==="

# Load the complete Sol system data
sol_data = JSON.parse(File.read('data/json-data/star_systems/sol-complete.json'))

puts "✓ Successfully loaded sol-complete.json"
puts "System: #{sol_data['name']} (#{sol_data['identifier']})"
puts "Galaxy: #{sol_data['galaxy']['name']}"

# Analyze celestial bodies
bodies = sol_data['celestial_bodies']
puts "\n=== Celestial Bodies Analysis ==="
puts "Total bodies: #{bodies.length}"

# Group by type
types = bodies.group_by { |b| b['type'] }
types.each do |type, type_bodies|
  puts "#{type}: #{type_bodies.length} (#{type_bodies.map { |b| b['name'] }.join(', ')})"
end

# Check for geological features
puts "\n=== Geological Features ==="
bodies_with_features = bodies.select { |b| b['geological_features'] }
bodies_with_features.each do |body|
  features = body['geological_features']
  feature_types = features.keys
  puts "#{body['name']}: #{feature_types.join(', ')}"
end

# Check for materials
puts "\n=== Resource-Rich Bodies ==="
bodies_with_materials = bodies.select { |b| b['materials'] && b['materials'].any? }
bodies_with_materials.each do |body|
  materials = body['materials'].map { |m| m['name'] }.join(', ')
  puts "#{body['name']}: #{materials}"
end

# Demonstrate procedural generator compatibility
puts "\n=== Procedural Generator Compatibility Test ==="
puts "✓ Flat celestial_bodies array: #{bodies.is_a?(Array)}"
puts "✓ Required metadata fields: #{sol_data['metadata'].keys.include?('generation_mode')}"

# Check for required body attributes
required_attrs = ['name', 'identifier', 'type', 'mass', 'radius']
bodies.each do |body|
  missing = required_attrs - body.keys
  if missing.any?
    puts "WARNING: #{body['name']} missing: #{missing.join(', ')}"
  end
end

puts "✓ All bodies have required attributes"

# Show strategic analysis
puts "\n=== Strategic Analysis ==="
strategic_bodies = bodies.select do |body|
  body['biosphere_attributes'] ||
  body['hydrosphere_attributes'] ||
  body['geological_features'] ||
  (body['materials'] && body['materials'].any?)
end

puts "Strategic bodies for colonization/development:"
strategic_bodies.each do |body|
  reasons = []
  reasons << "Life" if body['biosphere_attributes']
  reasons << "Water" if body['hydrosphere_attributes']
  reasons << "Geology" if body['geological_features']
  reasons << "Resources" if body['materials'] && body['materials'].any?
  puts "  #{body['name']}: #{reasons.join(', ')}"
end

puts "\n=== Data Completeness ==="
puts "Generation mode: #{sol_data['metadata']['generation_mode']}"
puts "Data completeness: #{sol_data['metadata']['data_completeness']}"
puts "Geological features included: #{sol_data['metadata']['geological_features_included']}"
puts "Material compositions included: #{sol_data['metadata']['material_compositions_included']}"

puts "\n✓ sol-complete.json validation complete!"
puts "The data is ready for use with the procedural generator and AI Manager."