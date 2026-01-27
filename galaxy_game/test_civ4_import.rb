#!/usr/bin/env ruby
# Test script to verify Civ4 import functionality
require 'bundler/setup'
require 'rails'
require 'active_record'
require_relative 'config/environment'

puts "Testing Civ4 WBS Import Service..."

# Test the Civ4 import service directly
# Use a test file path
test_file = './Civ4_Maps/12778-luna_100x50/Luna 100x50.CivBeyondSwordWBSave'
service = Import::Civ4WbsImportService.new(test_file)

# Look for a Luna WBS file
civ4_files = Dir.glob('./Civ4_Maps/**/*.wbs') + Dir.glob('./Civ4_Maps/**/*WBSave')
luna_file = civ4_files.find { |f| f =~ /luna/i }

if luna_file
  puts "Found Luna WBS file: #{luna_file}"

  result = service.import

  if result
    puts "SUCCESS: Civ4 import completed"
    puts "Grid dimensions: #{result[:width]}x#{result[:height]}"
    puts "Biome counts:"
    result[:biome_counts].each do |biome, count|
      puts "  #{biome}: #{count}"
    end
  else
    puts "FAILED: #{service.errors.join(', ')}"
  end
else
  puts "No Luna WBS file found in ./data/Civ4_Maps/"
  puts "Available WBS files:"
  civ4_files.each { |f| puts "  #{f}" }
end

# Test finding a celestial body for import
puts "\nTesting celestial body lookup..."
bodies = CelestialBodies::CelestialBody.where("name ILIKE ?", "%luna%").limit(5)
if bodies.any?
  puts "Found celestial bodies:"
  bodies.each { |b| puts "  #{b.name} (ID: #{b.id})" }
else
  puts "No celestial bodies found with 'luna' in name"
end