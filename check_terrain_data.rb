#!/usr/bin/env ruby
require 'json'
require 'net/http'

# Fetch the admin page
uri = URI('http://localhost:3000/admin/celestial_bodies/11/monitor')
response = Net::HTTP.get(uri)

# Extract JSON from the HTML
start_marker = '<script type="application/json" id="monitor-data">'
end_marker = '</script>'

start_idx = response.index(start_marker)
end_idx = response.index(end_marker, start_idx)

if start_idx && end_idx
  json_start = start_idx + start_marker.length
  json_str = response[json_start...end_idx].strip

  begin
    data = JSON.parse(json_str)
    terrain = data['terrain_data'] || {}

    puts "=== TERRAIN DATA ANALYSIS ==="

    # Check elevation data
    elevation = terrain['elevation']
    if elevation && elevation.is_a?(Array) && elevation.size > 0
      puts "✅ Elevation data: PRESENT"
      puts "   Dimensions: #{elevation.size} x #{elevation.first&.size || 0}"
      puts "   Sample (first row, first 10): #{elevation.first&.first(10)&.inspect}"
      flat = elevation.flatten.compact
      puts "   Range: #{flat.min&.round(3)} - #{flat.max&.round(3)}" if flat.size > 0
    else
      puts "❌ Elevation data: MISSING"
    end

    # Check grid data
    grid = terrain['grid']
    if grid && grid.is_a?(Array) && grid.size > 0
      puts "✅ Grid data: PRESENT"
      puts "   Dimensions: #{grid.size} x #{grid.first&.size || 0}"
      puts "   Sample (first row, first 10): #{grid.first&.first(10)&.inspect}"
    else
      puts "❌ Grid data: MISSING"
    end

  rescue JSON::ParserError => e
    puts "JSON parse error: #{e.message}"
  end
else
  puts "Could not find monitor data in HTML"
end