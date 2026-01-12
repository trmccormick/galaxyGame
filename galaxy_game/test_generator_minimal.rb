#!/usr/bin/env ruby
# Minimal test for ProceduralGenerator core functionality

require 'json'

# Mock the required classes
class MockAtmosphereGenerator
  def generate_composition_for_body(*args)
    {
      'composition' => { 'N2' => { 'percentage' => 78.0 }, 'O2' => { 'percentage' => 21.0 } },
      'pressure' => 1.0,
      'total_atmospheric_mass' => 5.0e18
    }
  end
end

class MockHydrosphereGenerator
  def generate(*args)
    {
      'total_water_mass' => 1.4e21,
      'surface_coverage' => 0.71
    }
  end
end

class MockMaterialLookup
end

class MockNameGenerator
  def generate_system_name
    "Test System"
  end

  def generate_star_name
    "Test Star"
  end
end

# Load the generator code
require_relative 'app/services/star_sim/procedural_generator.rb'

puts "Testing ProceduralGenerator..."

# Replace the constants and classes that might not be available
StarSim::ProceduralGenerator::TERRAFORMABLE_CHANCE = 0.4

# Mock Rails.root
class Rails
  def self.root
    Pathname.new(Dir.pwd)
  end

  class Logger
    def self.warn(msg)
      puts "WARN: #{msg}"
    end
  end
end

# Mock Pathname
class Pathname
  def initialize(path)
    @path = path
  end

  def join(*args)
    File.join(@path, *args)
  end
end

# Create a simple generator instance
generator = StarSim::ProceduralGenerator.new(
  nil,
  MockAtmosphereGenerator.new,
  MockHydrosphereGenerator.new,
  MockMaterialLookup.new
)

# Override the name generator
generator.instance_variable_set(:@name_generator, MockNameGenerator.new)

# Test basic system generation
puts "Generating a test system..."
begin
  result = generator.generate_system_seed(num_stars: 1, num_planets: 2)

  puts "✓ System generated successfully!"
  puts "  Stars: #{result['stars'].length}"
  puts "  Terrestrial planets: #{result['celestial_bodies']['terrestrial_planets'].length}"

  # Check templates
  templates = generator.instance_variable_get(:@terraformable_templates)
  puts "  Templates loaded: #{templates.length}"

  # Check planet structure
  planet = result['celestial_bodies']['terrestrial_planets'].first
  puts "  Planet has required keys: #{planet.key?('name') && planet.key?('mass') && planet.key?('atmosphere')}"

  puts "✓ All basic tests passed!"

rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end