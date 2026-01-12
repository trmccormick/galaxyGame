#!/usr/bin/env ruby

require 'json'
require 'pathname'

puts "=== Galaxy Game Data Validation Tool ==="

# Configuration
DATA_PATH = ENV['DATA_PATH'] || '/home/galaxy_game/app/data_new'
@data_root = Pathname.new(DATA_PATH)

@files_validated = 0
@errors_found = 0
@warnings_found = 0

# Define validation rules for different types
VALIDATION_RULES = {
  'blueprints/units' => {
    required_fields: ['id', 'name', 'type', 'physical_properties'],
    physical_properties: ['length_m', 'width_m', 'height_m', 'empty_mass_kg']
  },
  'blueprints/modules' => {
    required_fields: ['id', 'name', 'type', 'physical_properties'],
    physical_properties: ['length_m', 'width_m', 'height_m', 'empty_mass_kg']
  },
  'blueprints/craft' => {
    required_fields: ['id', 'name', 'type', 'physical_properties', 'compatible_units'],
    physical_properties: ['length_m', 'width_m', 'height_m', 'empty_mass_kg']
  },
  'materials/raw' => {
    required_fields: ['id', 'name', 'type', 'properties'],
    properties: ['state_at_room_temp', 'melting_point', 'density']
  },
  'materials/processed' => {
    required_fields: ['id', 'name', 'type', 'properties'],
    properties: ['state_at_room_temp', 'density']
  },
  'operational_data/units' => {
    required_fields: ['id', 'name', 'operational_characteristics'],
    operational_characteristics: ['power_consumption', 'failure_rate']
  },
  'manifests/cargo' => {
    required_fields: ['description', 'craft', 'installed_units', 'stowed_units']
  },
  'manifests/missions' => {
    required_fields: ['description', 'mission_id', 'objectives']
  },
  'star_systems' => {
    required_fields: ['name', 'celestial_bodies'],
    celestial_bodies: ['stars', 'planets']
  }
}

# Validate a single file
def validate_file(file_path)
  return unless file_path.end_with?('.json')
  
  @files_validated += 1
  
  begin
    # Parse JSON
    json_data = JSON.parse(File.read(file_path))
    
    # Determine file type from path
    file_type = nil
    VALIDATION_RULES.keys.each do |type|
      if file_path.include?(type)
        file_type = type
        break
      end
    end
    
    # Skip if no validation rules found
    if file_type.nil?
      puts "WARNING: No validation rules found for #{file_path}"
      @warnings_found += 1
      return
    end
    
    # Get validation rules
    rules = VALIDATION_RULES[file_type]
    
    # Check required fields
    rules[:required_fields].each do |field|
      unless json_data.key?(field)
        puts "ERROR: Missing required field '#{field}' in #{file_path}"
        @errors_found += 1
      end
    end
    
    # Check nested required fields
    rules.each do |key, value|
      next if key == :required_fields
      
      if json_data.key?(key) && json_data[key].is_a?(Hash)
        value.each do |nested_field|
          unless json_data[key].key?(nested_field)
            puts "ERROR: Missing nested field '#{key}.#{nested_field}' in #{file_path}"
            @errors_found += 1
          end
        end
      elsif rules[:required_fields].include?(key)
        puts "ERROR: Missing or invalid required section '#{key}' in #{file_path}"
        @errors_found += 1
      end
    end
    
    # Check for non-empty ID and name
    ['id', 'name'].each do |field|
      if json_data.key?(field) && (json_data[field].nil? || json_data[field].to_s.strip.empty?)
        puts "ERROR: Empty #{field} in #{file_path}"
        @errors_found += 1
      end
    end
    
    puts "Validated: #{file_path}"
  rescue JSON::ParserError => e
    puts "ERROR: Invalid JSON in #{file_path}: #{e.message}"
    @errors_found += 1
  rescue => e
    puts "ERROR: Validation failed for #{file_path}: #{e.message}"
    @errors_found += 1
  end
end

# Process all files in a directory recursively
def validate_directory(dir_path)
  Dir.glob(File.join(dir_path, '*')).each do |path|
    if File.directory?(path)
      validate_directory(path)
    else
      validate_file(path)
    end
  end
end

# Main execution
begin
  # Validate all data
  validate_directory(@data_root)
  
  # Summary
  puts "\n=== Validation Summary ==="
  puts "Files validated: #{@files_validated}"
  puts "Errors found: #{@errors_found}"
  puts "Warnings found: #{@warnings_found}"
  
  if @errors_found > 0
    puts "\nWARNING: #{@errors_found} errors were found during validation."
    puts "Please review the output above and fix these issues."
    exit 1
  elsif @warnings_found > 0
    puts "\nNote: #{@warnings_found} warnings were found during validation."
    puts "Review the output above for potential improvements."
    exit 0
  else
    puts "\nSuccess! All files validated successfully."
    exit 0
  end
rescue => e
  puts "ERROR: Validation failed: #{e.message}"
  puts e.backtrace
  exit 1
end