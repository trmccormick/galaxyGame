#!/usr/bin/env ruby
# Debug script for PrecursorCapabilityService
require_relative 'config/environment'

# Create test data similar to the spec
solar_system = FactoryBot.create(:solar_system)
mars = FactoryBot.create(:terrestrial_planet, :mars, solar_system: solar_system)
luna = FactoryBot.create(:celestial_body, :luna, solar_system: solar_system)

puts "=== Mars Debug ==="
puts "Mars geosphere crust_composition: #{mars.geosphere.crust_composition.inspect}"
puts "Mars atmosphere gases: #{mars.atmosphere.gases.pluck(:name, :percentage)}"
puts "Mars has_solid_surface?: #{mars.has_solid_surface?}"

service = AIManager::PrecursorCapabilityService.new(mars)
puts "Mars local_resources: #{service.local_resources.inspect}"
puts "Mars can_produce_locally?('regolith'): #{service.can_produce_locally?('regolith')}"
puts "Mars can_produce_locally?('co2'): #{service.can_produce_locally?('co2')}"
puts "Mars can_produce_locally?('water_ice'): #{service.can_produce_locally?('water_ice')}"

puts "\n=== Luna Debug ==="
puts "Luna geosphere crust_composition: #{luna.geosphere.crust_composition.inspect}"
puts "Luna atmosphere gases: #{luna.atmosphere.gases.pluck(:name, :percentage)}"
puts "Luna has_solid_surface?: #{luna.has_solid_surface?}"

service_luna = AIManager::PrecursorCapabilityService.new(luna)
puts "Luna local_resources: #{service_luna.local_resources.inspect}"
puts "Luna can_produce_locally?('regolith'): #{service_luna.can_produce_locally?('regolith')}"
puts "Luna can_produce_locally?('oxygen'): #{service_luna.can_produce_locally?('oxygen')}"