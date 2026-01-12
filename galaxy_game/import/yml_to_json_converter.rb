require 'yaml'
require 'json'
require 'fileutils'

PROJECT_ROOT = File.expand_path('../..', __FILE__)

def convert_yml_to_json(input_file, output_dir)
  puts "\nProcessing:"
  puts "Input file: #{input_file}"
  puts "Output dir: #{output_dir}"
  
  yaml_data = YAML.load_file(input_file)
  
  FileUtils.mkdir_p(output_dir)
  
  base_name = File.basename(input_file, '.*')
  output_file = File.join(output_dir, "#{base_name}.json")
  
  File.write(output_file, JSON.pretty_generate(yaml_data))
  puts "✓ Created: #{output_file}"
  puts "----------------------------------------"
end

# List all found YAML files
input_files = Dir.glob(File.join(PROJECT_ROOT, 'config/raw_materials/**/*.yml'))
puts "\nFound YAML files:"
input_files.each { |f| puts "- #{f}" }

output_dir = File.join(PROJECT_ROOT, 'app/data/materials')

input_files.each do |file|
  convert_yml_to_json(file, output_dir)
end

puts "\nConversion complete!"

# Add to bottom of yml_to_json_converter.rb to check results
puts "\nChecking converted JSON files:"
json_files = Dir.glob(File.join(PROJECT_ROOT, 'app/data/materials/**/*.json'))
json_files.each { |f| puts "- #{f}" }

puts "\nTotal files converted: #{json_files.size}"