#!/usr/bin/env ruby
# Economic Data Injection Script v1.6
# Adds base_cost_eap and usd_import_fee to unit JSON files

require 'json'
require 'pathname'

# Load Rails environment
require_relative '../config/environment'

class EconomicInjector
  def initialize
    @units_path = GalaxyGame::Paths::UNITS_PATH
    @updated_count = 0
  end

  def inject_economic_data
    puts "Starting economic data injection for units in #{@units_path}"

    # Find all JSON files recursively
    json_files = Dir.glob(File.join(@units_path.to_s, "**", "*.json"))

    puts "Found #{json_files.size} JSON files to process"

    json_files.each do |file_path|
      process_file(file_path)
    end

    puts "Economic data injection complete. Updated #{@updated_count} files."
  end

  private

  def process_file(file_path)
    begin
      # Read and parse JSON
      content = File.read(file_path)
      data = JSON.parse(content)

      # Check if fields are missing
      needs_update = false

      unless data.key?('base_cost_eap')
        data['base_cost_eap'] = calculate_base_cost_eap(data)
        needs_update = true
      end

      unless data.key?('usd_import_fee')
        data['usd_import_fee'] = 1000.0
        needs_update = true
      end

      # Write back if updated
      if needs_update
        File.write(file_path, JSON.pretty_generate(data))
        puts "Updated: #{file_path}"
        @updated_count += 1
      end

    rescue JSON::ParserError => e
      puts "Error parsing #{file_path}: #{e.message}"
    rescue StandardError => e
      puts "Error processing #{file_path}: #{e.message}"
    end
  end

  def calculate_base_cost_eap(unit_data)
    # Calculate based on unit mass/complexity
    mass = unit_data['mass'] || unit_data['operational_data']&.dig('mass') || 1000.0
    complexity_factor = calculate_complexity_factor(unit_data)

    # Base formula: mass * complexity * EAP multiplier
    base_cost = mass * complexity_factor * 0.001

    # Round to 2 decimal places
    base_cost.round(2)
  end

  def calculate_complexity_factor(unit_data)
    factor = 1.0

    # Increase based on unit type complexity
    case unit_data['unit_type']
    when 'computer'
      factor *= 2.0
    when 'propulsion'
      factor *= 3.0
    when 'life_support'
      factor *= 2.5
    when 'production'
      factor *= 1.8
    end

    # Increase for specialized features
    if unit_data['processing_capabilities']
      factor *= 1.5
    end

    if unit_data['resource_management']
      factor *= 1.2
    end

    factor
  end
end

# Run the injector
if __FILE__ == $0
  injector = EconomicInjector.new
  injector.inject_economic_data
end