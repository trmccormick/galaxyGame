require 'json'
require 'fileutils'

# Directory containing unit JSON files
unit_json_directory = File.join('app', 'data', 'units')

# Directory to save blueprint JSON files
blueprint_directory = File.join('app', 'data', 'blueprints')
FileUtils.mkdir_p(blueprint_directory) unless Dir.exist?(blueprint_directory)

# Helper method to format names as lowercase snake_case for filenames
def snake_case(name)
  name.downcase.gsub(/\s|-/, '_').gsub(/[^a-z0-9_]/, '')
end

# Generate blueprint structure from a unit JSON file
def generate_blueprint(unit_data)
  {
    name: "#{unit_data['name']} Blueprint",
    description: "Blueprint to construct the #{unit_data['name']}.",
    required_materials: unit_data.fetch('construction_materials', []).map do |material|
      {
        material: material['material'].downcase,
        quantity: material['quantity']
      }
    end,
    construction_time: unit_data['construction_time'] || 0,
    required_power: unit_data['power_requirement'] || 0
  }.compact
end

# Iterate over each unit JSON file
Dir.glob(File.join(unit_json_directory, '**', '*.json')).each do |unit_file|
  unit_data = JSON.parse(File.read(unit_file))
  blueprint_data = generate_blueprint(unit_data)

  blueprint_file_name = snake_case(unit_data['name']) + '_blueprint.json'
  File.write(File.join(blueprint_directory, blueprint_file_name), JSON.pretty_generate(blueprint_data))
end

puts "Blueprint generation complete. JSON files saved to #{blueprint_directory}"