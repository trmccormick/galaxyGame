# config/initializers/raw_materials.rb
require 'yaml'

RAW_MATERIALS_PATH = Rails.root.join('config', 'raw_materials')

# Load all YAML files
RAW_MATERIALS = Dir[RAW_MATERIALS_PATH.join('*.yml')].each_with_object({}) do |file, hash|
  file_data = YAML.load_file(file)
  hash.merge!(file_data) # Merging each file data into the main hash
end
