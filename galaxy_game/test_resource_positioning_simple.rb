#!/usr/bin/env ruby
# test_resource_positioning_simple.rb
# Simple test of the AI resource positioning service without Rails

require 'pp'

# Mock Rails logger
class MockRails
  class Logger
    def info(msg); puts "[INFO] #{msg}"; end
    def debug(msg); puts "[DEBUG] #{msg}"; end
    def warn(msg); puts "[WARN] #{msg}"; end
    def error(msg); puts "[ERROR] #{msg}"; end
  end

  def self.logger
    @logger ||= Logger.new
  end
end

# Mock Time
class MockTime
  def self.current
    Time.now
  end
end

# Define mock Rails and Time
Object.const_set(:Rails, MockRails)
Object.const_set(:Time, MockTime)

# Load the resource positioning service
require_relative 'app/services/ai_manager/resource_positioning_service'

puts "Testing AI Resource Positioning Service (Standalone)..."

# Test 1: Direct service test
puts "\n=== Test 1: Direct Resource Positioning Service ==="
service = AIManager::ResourcePositioningService.new

# Create test map data
test_map = {
  elevation: Array.new(10) { Array.new(10) { 0.5 } },  # 10x10 grid at mid elevation
  terrain: Array.new(10) { Array.new(10) { 'plains' } }  # All plains
}

# Add some variation
test_map[:elevation][2][3] = 0.8  # Mountain
test_map[:elevation][7][8] = 0.2  # Lowland
test_map[:terrain][2][3] = 'mountains'
test_map[:terrain][7][8] = 'lowlands'

puts "Test map created: #{test_map[:terrain].size}x#{test_map[:terrain].first.size}"
puts "Terrain variation added"

enhanced_map = service.place_resources_on_map(test_map, planet_name: 'TestPlanet')

puts "Enhanced map results:"
puts "- Resource grid present: #{enhanced_map[:resource_grid] ? 'YES' : 'NO'}"
puts "- Resource grid size: #{enhanced_map[:resource_grid]&.size}x#{enhanced_map[:resource_grid]&.first&.size}"
puts "- Resource counts: #{enhanced_map[:resource_counts] || 'None'}"
puts "- Strategic markers: #{enhanced_map[:strategic_markers]&.size || 0}"

# Test 2: Different planet types
puts "\n=== Test 2: Mars-specific Resources ==="
mars_map = {
  elevation: Array.new(8) { Array.new(8) { 0.6 } },
  terrain: Array.new(8) { Array.new(8) { 'hills' } }
}

# Add Mars-like features
mars_map[:elevation][1][2] = 0.9  # High mountain
mars_map[:elevation][6][7] = 0.1  # Low basin
mars_map[:terrain][1][2] = 'mountains'
mars_map[:terrain][6][7] = 'lowlands'

mars_enhanced = service.place_resources_on_map(mars_map, planet_name: 'Mars')
puts "Mars map resources: #{mars_enhanced[:resource_counts]}"
puts "Mars strategic markers: #{mars_enhanced[:strategic_markers]&.size}"

# Test 3: Earth-like resources
puts "\n=== Test 3: Earth-specific Resources ==="
earth_map = {
  elevation: Array.new(6) { Array.new(6) { 0.5 } },
  terrain: Array.new(6) { Array.new(6) { 'plains' } }
}

# Add Earth-like features
earth_map[:elevation][0][0] = 0.1  # Ocean/coast
earth_map[:elevation][5][5] = 0.8  # Mountain
earth_map[:terrain][0][0] = 'ocean'
earth_map[:terrain][5][5] = 'mountains'

earth_enhanced = service.place_resources_on_map(earth_map, planet_name: 'Earth')
puts "Earth map resources: #{earth_enhanced[:resource_counts]}"
puts "Earth strategic markers: #{earth_enhanced[:strategic_markers]&.size}"

puts "\n=== Resource Positioning Tests Complete ==="