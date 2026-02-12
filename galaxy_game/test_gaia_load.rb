#!/usr/bin/env ruby
# Test script to load the Gaia system (aol-732356.json)

require_relative 'config/environment'

puts "Testing Gaia system load..."

begin
  builder = StarSim::SystemBuilderService.new(name: 'gaia', debug_mode: true)
  solar_system = builder.build!
  puts "SUCCESS: Gaia system loaded successfully!"
  puts "Solar system: #{solar_system.name}"
  puts "Celestial bodies count: #{solar_system.celestial_bodies.count}"
rescue => e
  puts "ERROR: Failed to load Gaia system: #{e.class}: #{e.message}"
  puts e.backtrace.join("\n")
end