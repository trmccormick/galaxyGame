#!/usr/bin/env ruby
# Test Mars blueprint extraction from Civ4 map

require './config/environment'

mars_map_path = Rails.root.join('app/data/maps/civ4/custom_worlds/fantasy_realm/Arda.CivBeyondSwordWBSave')

puts "Testing Mars blueprint extraction..."
puts "Map path: #{mars_map_path}"
puts "Map exists: #{File.exist?(mars_map_path)}"

if File.exist?(mars_map_path)
  processor = Import::Civ4MapProcessor.new

  begin
    # Debug the import
    raw_data = Import::Civ4WbsImportService.new(mars_map_path.to_s).import
    puts "Raw data: #{raw_data.inspect[0..200]}..."

    # Test blueprint extraction
    blueprint_data = processor.process(mars_map_path.to_s, mode: :mars_blueprint)

    puts "\n✅ Blueprint extraction successful!"
    puts "Settlement sites found: #{blueprint_data[:settlement_sites].size}"
    puts "Terraforming targets found: #{blueprint_data[:terraforming_targets].size}"
    puts "Geological features found: #{blueprint_data[:geological_features].size}"
    puts "Historical water features: #{blueprint_data[:historical_water_levels][:features].size}"
    puts "Estimated ocean coverage: #{blueprint_data[:historical_water_levels][:estimated_ocean_coverage]}%"

    # Show sample data
    if blueprint_data[:settlement_sites].any?
      puts "\nSample settlement sites:"
      blueprint_data[:settlement_sites].first(3).each do |site|
        puts "  - #{site[:type]} at (#{site[:x]}, #{site[:y]}) - #{site[:suitability]}"
      end
    end

    if blueprint_data[:terraforming_targets].any?
      puts "\nSample terraforming targets:"
      blueprint_data[:terraforming_targets].first(3).each do |target|
        puts "  - #{target[:target_biome]} at (#{target[:x]}, #{target[:y]}) - priority #{target[:priority]}"
      end
    end

  rescue => e
    puts "❌ Error during blueprint extraction: #{e.message}"
    puts e.backtrace.first(5)
  end
else
  puts "❌ Mars map file not found"
end