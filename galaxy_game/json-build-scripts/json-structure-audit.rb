# Migration audit script
require 'json'
require 'fileutils'
require 'pathname'


require_relative '../../config/initializers/game_data_paths'
# Configure paths based on environment
OLD_DATA_ROOT_3 = GalaxyGame::Paths::JSON_DATA.join('old-json-data', 'production_old3').to_s

# Analyze old3 blueprint structures
structure_blueprints = []
old3_structure_blueprints_path = File.join(OLD_DATA_ROOT_3, 'blueprints', 'structures')

if File.directory?(old3_structure_blueprints_path)
  puts "Scanning #{old3_structure_blueprints_path}..."
  Dir.glob(File.join(old3_structure_blueprints_path, '**', '*.json')).each do |file|
    begin
      data = JSON.parse(File.read(file))
      # Extract the subdirectory as category
      category = File.basename(File.dirname(file))
      
      # Determine new classification based on name and category
      name = data['name'] || ""
      is_module = name.include?('module') || name.include?('Module') || file.include?('module')
      is_unit = name.include?('unit') || name.include?('Unit') || 
                category == 'life_support' || category == 'power_generation' ||
                name.include?('control') || name.include?('recycling')
      
      new_classification = if is_module
                            "MODULE"
                          elsif is_unit
                            "UNIT"
                          else
                            "STRUCTURE"
                          end
      
      structure_blueprints << {
        id: data['id'],
        name: name,
        category: category,
        file: file,
        new_classification: new_classification
      }
    rescue => e
      puts "Error processing #{file}: #{e.message}"
    end
  end
end

# Output results by category
puts "\n===== Production_old3 Structures Analysis ====="
by_category = structure_blueprints.group_by { |bp| bp[:category] }

by_category.each do |category, blueprints|
  puts "\nCategory: #{category} (#{blueprints.size} blueprints)"
  
  # Group by new classification within each category
  by_classification = blueprints.group_by { |bp| bp[:new_classification] }
  
  by_classification.each do |classification, items|
    puts "  #{classification}: #{items.size} items"
    items.each do |item|
      puts "    - #{item[:id]} (#{item[:name]})"
    end
  end
end

# Summary counts
module_count = structure_blueprints.count { |bp| bp[:new_classification] == "MODULE" }
unit_count = structure_blueprints.count { |bp| bp[:new_classification] == "UNIT" }
structure_count = structure_blueprints.count { |bp| bp[:new_classification] == "STRUCTURE" }

puts "\n===== Summary ====="
puts "Total items: #{structure_blueprints.size}"
puts "Should be modules: #{module_count}"
puts "Should be units: #{unit_count}" 
puts "Should be structures: #{structure_count}"

# Create migration plan
puts "\n===== Migration Plan ====="
puts "1. Modules (#{module_count} items):"
puts "   - Move to: app/data/blueprints/modules/"
puts "   - Template: module_blueprint.json"

puts "\n2. Units (#{unit_count} items):"
puts "   - Move to: app/data/blueprints/units/<category>/"
puts "   - Template: unit_blueprint.json"

puts "\n3. Structures (#{structure_count} items):"
puts "   - Move to: app/data/blueprints/structures/<category>/"
puts "   - Template: structure_blueprint.json"
puts "   - Create matching operational_data files"

# Migration audit script
require 'json'
require 'fileutils'

# Paths
OLD_DATA_ROOT = '/home/galaxy_game/app/data/old-json-data/production_old4'
STRUCTURE_UNITS_PATH = File.join(OLD_DATA_ROOT, 'units', 'structure')
STRUCTURES_PATH = File.join(Rails.root.to_s, 'app', 'data', 'operational_data', 'structures')
STRUCTURE_BLUEPRINTS_PATH = File.join(Rails.root.to_s, 'app', 'data', 'blueprints', 'structures')

# Analyze structure units
structure_units = Dir.glob(File.join(STRUCTURE_UNITS_PATH, "*_data.json")).map do |file|
  data = JSON.parse(File.read(file))
  {
    id: data['id'],
    name: data['name'],
    file: file,
    # Determine if this should be a structure
    should_be_structure: data['footprint_m'].present? || 
                          data['construction_time_hours'].present? || 
                          data.dig('blueprint_data', 'material_requirements').present?
  }
end

# Output results
puts "===== Structure Units Analysis ====="
structure_units.each do |unit|
  action = unit[:should_be_structure] ? "MOVE TO STRUCTURES" : "KEEP AS UNIT"
  puts "#{unit[:id]} (#{unit[:name]}): #{action}"
end