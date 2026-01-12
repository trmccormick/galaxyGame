require 'yaml'
require 'json'
require 'fileutils'

# Load YAML file
yaml_file = File.join('config', 'raw_materials', 'materials.yml')
materials_data = YAML.load_file(yaml_file)['materials']

# Directory to save JSON files
output_directory = File.join('app', 'data', 'materials', 'raw')
FileUtils.mkdir_p(output_directory) unless Dir.exist?(output_directory)

# Helper method to format names as lowercase snake_case for filenames
def snake_case(name)
  name.downcase.gsub(/\s|-/, '_').gsub(/[^a-z0-9_]/, '')
end

materials_data.each do |material|
  # Convert YAML to JSON structure
  json_data = {
    name: material['name'],
    chemical_formula: material['chemical_formula'],
    aliases: material['aliases'],
    description: material['description'],
    boiling_point: material['boiling_point'],
    freezing_point: material['freezing_point'],
    vapor_point: material['vapor_point'],
    melting_point: material['melting_point'],
    molar_mass: material['molar_mass'],
    state_at_room_temp: material['state_at_room_temp'],
    color: material['color'],
    uses: material['uses']
  }.compact

  # Save to JSON file
  file_name = snake_case(material['name']) + '.json'
  File.write(File.join(output_directory, file_name), JSON.pretty_generate(json_data))
end

puts "Conversion complete. JSON files saved to #{output_directory}"


