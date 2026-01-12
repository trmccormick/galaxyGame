#!/usr/bin/env ruby
# Test script for regolith panel skylight covering

require_relative '../config/environment'

puts "Testing regolith panel implementation..."

# Test blueprint lookup
lookup_service = Lookup::BlueprintLookupService.new
blueprint = lookup_service.find_blueprint('basic_regolith_panel_mk1')

if blueprint
  puts "✅ Blueprint found"
  puts "ID: #{blueprint['id']}"
  puts "Name: #{blueprint['name']}"

  materials = blueprint.dig('blueprint_data', 'material_requirements')
  puts "Material requirements:"
  materials.each do |req|
    puts "  - #{req['material']}: #{req['amount']} #{req['unit']}"
  end
else
  puts "❌ Blueprint not found"
end

puts "\nTest complete."