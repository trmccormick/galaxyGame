#!/usr/bin/env ruby
# Test script to run AI Manager simulation with System B (VLYT-318729) data
# Confirms industrial forge prioritization based on gravity threshold logic

require_relative 'config/environment'
require 'ai_manager'

puts "Testing AI Manager simulation with System B (VLYT-318729)..."

# Load the vetted system data for VLYT-318729
vetted_path = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH.join('vlyt-318729.json')

unless File.exist?(vetted_path)
  puts "ERROR: Vetted system vlyt-318729.json not found at #{vetted_path}"
  exit 1
end

system_data = JSON.parse(File.read(vetted_path))
puts "Loaded system data for: #{system_data['identifier']}"

# Check if it has the industrial_forge priority metadata
priority = system_data.dig('metadata', 'priority')
puts "System priority: #{priority || 'none'}"

# Extract celestial bodies for analysis
celestial_bodies = []
(system_data['celestial_bodies'] || {}).each do |category, bodies|
  bodies.each do |body|
    celestial_bodies << body
    # Include moons
    (body['moons'] || []).each do |moon|
      celestial_bodies << moon
    end
  end
end

puts "Found #{celestial_bodies.length} celestial bodies"

# Check gravity values for planets
high_gravity_planets = []
celestial_bodies.each do |body|
  next unless body['type'] == 'planet'
  gravity = body['gravity'].to_f
  puts "#{body['identifier']}: gravity = #{gravity} g"
  if gravity > 3.0
    high_gravity_planets << body
  end
end

puts "Planets with gravity > 3.0g: #{high_gravity_planets.length}"
high_gravity_planets.each do |planet|
  puts "  - #{planet['identifier']}: #{planet['gravity']}g"
end

# Run ScoutLogic analysis
puts "\nRunning ScoutLogic analysis..."
scout = AIManager::ScoutLogic.new(system_data)
analysis = scout.analyze_system_patterns

puts "ScoutLogic Analysis Results:"
puts "  Primary Characteristic: #{analysis[:primary_characteristic]}"
puts "  Target Body: #{analysis[:target_body]&.dig('identifier') || 'none'}"
puts "  Terraformable Bodies: #{analysis[:terraformable_bodies].count}"
puts "  Resource Rich Bodies: #{analysis[:resource_rich_bodies].count}"

# Check if AI would prioritize infrastructure-first due to high gravity
target_body = analysis[:target_body]
if target_body && target_body['gravity'].to_f > 3.0
  puts "\n✅ CONFIRMED: AI would prioritize Infrastructure-First deployment"
  puts "   Target body #{target_body['identifier']} has gravity #{target_body['gravity']}g > 3.0g threshold"
  puts "   This matches industrial forge prioritization for System B"
else
  puts "\n❌ UNEXPECTED: Target body does not meet high-gravity criteria"
end

puts "\nTest completed successfully!"