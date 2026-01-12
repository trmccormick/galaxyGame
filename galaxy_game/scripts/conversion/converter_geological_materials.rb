require 'yaml'
require 'json'
require 'fileutils'

# Load YAML file
yaml_file = File.join('config', 'raw_materials', 'geological_materials.yml')
geological_data = YAML.load_file(yaml_file)['geological_materials']

# Directory to save JSON files
output_directory = File.join('app', 'data', 'materials', 'raw', 'geological')
FileUtils.mkdir_p(output_directory) unless Dir.exist?(output_directory)

# Helper method to format names as lowercase snake_case for filenames
def snake_case(name)
  name.downcase.gsub(/\s|-/, '_').gsub(/[^a-z0-9_]/, '')
end

geological_data.each do |material|
  # Convert YAML to JSON structure
  json_data = {
    name: material['name'],
    type: material['type'],
    description: material['description'],
    use_cases: material['use_cases'],
    smelting_output: material['smelting_output']&.map do |output|
      {
        material: output['material'].downcase,
        percentage: output['percentage']
      }
    end,
    waste_material: material['waste_material']&.map do |waste|
      {
        type: waste['type'].downcase.gsub(/\s|-/, '_'),
        percentage: waste['percentage']
      }
    end
  }.compact

  # Save to JSON file
  file_name = snake_case(material['name']) + '.json'
  File.write(File.join(output_directory, file_name), JSON.pretty_generate(json_data))
end

puts "Conversion complete. JSON files saved to #{output_directory}"


