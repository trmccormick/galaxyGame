#!/usr/bin/env ruby
# Simple test script for ProceduralGenerator

require_relative '../../config/environment'

puts "Testing ProceduralGenerator..."

# Create a simple generator instance
generator = StarSim::ProceduralGenerator.new

# Test basic system generation
puts "Generating a test system..."
result = generator.generate_system_seed(num_stars: 1, num_planets: 3)

puts "System generated successfully!"
puts "Stars: #{result['stars'].length}"
puts "Terrestrial planets: #{result['celestial_bodies']['terrestrial_planets'].length}"

# Check if templates are loaded
templates = generator.instance_variable_get(:@terraformable_templates)
puts "Templates loaded: #{templates.length}"

# Test template-based generation
if templates.length > 0
  puts "Testing template-based planet generation..."
  planet = generator.send(:generate_from_template, templates.first, 'Test Planet', 'TEST-001', 0)
  puts "Template planet generated: #{planet['name']}"
  puts "Has geosphere_attributes: #{planet.key?('geosphere_attributes')}"
end

# Test orbital optimization
puts "Testing orbital optimization..."
mock_star = OpenStruct.new(luminosity: 1.0)
orbit = generator.send(:generate_optimized_orbital_parameters, 0, mock_star)
puts "Optimized orbit distance: #{orbit[:semi_major_axis_au]} AU"

puts "All tests passed!"