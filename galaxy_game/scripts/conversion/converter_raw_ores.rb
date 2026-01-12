require 'yaml'
require 'json'
require 'fileutils'

# Load YAML file
yaml_file = File.join('config', 'raw_materials', 'raw_ores.yml')
ores_data = YAML.load_file(yaml_file)['raw_ores']

# Directory to save JSON files
output_directory = File.join('app', 'data', 'materials', 'raw', 'ores')
FileUtils.mkdir_p(output_directory) unless Dir.exist?(output_directory)

# Helper method to format names as lowercase snake_case for filenames
def snake_case(name)
  name.downcase.gsub(/\s|-/, '_').gsub(/[^a-z0-9_]/, '')
end

ores_data.each do |ore|
  # Convert YAML to JSON structure
  json_data = {
    name: ore['name'],
    type: ore['type'],
    description: ore['description'],
    smelting_output: ore['smelting_output']&.map do |output|
      {
        material: output['material'].downcase,
        percentage: output['percentage']
      }
    end,
    waste_material: ore['waste_material']&.map do |waste|
      {
        type: waste['type'].downcase.gsub(/\s|-/, '_'),
        percentage: waste['percentage']
      }
    end
  }.compact

  # Save to JSON file
  file_name = snake_case(ore['name']) + '.json'
  File.write(File.join(output_directory, file_name), JSON.pretty_generate(json_data))
end

puts "Conversion complete. JSON files saved to #{output_directory}"


