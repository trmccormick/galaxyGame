require 'yaml'
require 'json'
require 'fileutils'

# Load YAML file
yaml_file = File.join('config', 'units', 'production.yml')
production_data = YAML.load_file(yaml_file)['units']

# Directories to save JSON files
blueprint_directory = File.join('app', 'data', 'blueprints', 'units', 'production')
data_directory = File.join('app', 'data', 'units', 'production')
FileUtils.mkdir_p(blueprint_directory) unless Dir.exist?(blueprint_directory)
FileUtils.mkdir_p(data_directory) unless Dir.exist?(data_directory)

# Helper method to format names as lowercase snake_case for filenames
def snake_case(name)
  name.downcase.gsub(/\s|-/, '_').gsub(/[^a-z0-9_]/, '')
end

if production_data.nil?
  puts "No production data found in #{yaml_file}"
  exit
end

production_data.each do |unit|
  # Convert YAML to JSON structure for blueprint
  blueprint_json_data = {
    name: "#{unit['name']} Blueprint",
    description: "Blueprint to construct the #{unit['name']}.",
    material_efficiency: 0,
    materials: unit['build_materials'],
    outcome: unit['name'],
    time_efficiency: 0,
    time_to_build: 0,
    cost_gcc: 0,
    byproducts: unit['byproducts'] || {}
  }.compact

  operating_json_data = {
    name: unit['name'],
    capacity: unit['capacity'],
    energy_usage: unit['energy_usage'],
    aliases: unit['aliases'],
    # build_materials: unit['build_materials'],
    consumables: unit['consumables'],
    generated: unit['generated'],
    description: unit['description'],
    operating_parameters: unit['operating_parameters'],
    maintenance_schedule: unit['maintenance_schedule']
  }.compact

  # Save blueprint JSON file
  blueprint_file_name = snake_case(unit['name']) + '_blueprint.json'
  File.write(File.join(blueprint_directory, blueprint_file_name), JSON.pretty_generate(blueprint_json_data))

  # Save operating data JSON file
  operating_file_name = snake_case(unit['name']) + '_data.json'
  File.write(File.join(data_directory, operating_file_name), JSON.pretty_generate(operating_json_data))
end

puts "Conversion complete. JSON files saved to #{blueprint_directory} and #{data_directory}"
