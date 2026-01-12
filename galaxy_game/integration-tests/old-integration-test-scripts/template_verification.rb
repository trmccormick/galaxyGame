#!/usr/bin/env ruby
# template_verification.rb

require 'json'
require 'pathname'

puts "=== Galaxy Game Template Verification Tool ==="


require_relative '../../../../config/initializers/game_data_paths'
# Configuration
@data_root = GalaxyGame::Paths::JSON_DATA
@template_root = GalaxyGame::Paths::TEMPLATE_PATH

@files_validated = 0
@errors_found = 0
@warnings_found = 0
@templates = {}

# Load templates
def load_templates
  puts "Loading templates from #{@template_root}..."
  
  Dir.glob(File.join(@template_root, '*.json')).each do |path|
    begin
      template_data = JSON.parse(File.read(path))
      template_name = template_data['template'] || File.basename(path, '.json')
      @templates[template_name] = template_data
      puts "  Loaded template: #{template_name}"
    rescue JSON::ParserError => e
      puts "ERROR: Invalid template JSON in #{path}: #{e.message}"
    end
  end
  
  puts "Loaded #{@templates.size} templates."
end

# Guess the appropriate template for a file
def guess_template(file_path, json_data)
  filename = File.basename(file_path, '.json')
  
  if json_data.key?('template')
    return json_data['template']
  end
  
  if json_data.key?('type')
    case json_data['type']
    when 'unit'
      return 'base_unit'
    when 'module'
      return 'base_module'
    when 'craft'
      return 'base_craft'
    when 'celestial_body'
      return 'base_celestial_body'
    end
  end
  
  if file_path.include?('/materials/')
    return 'base_material'
  elsif file_path.include?('/units/')
    return 'base_unit'
  elsif file_path.include?('/modules/')
    return 'base_module'
  elsif file_path.include?('/craft/')
    return 'base_craft'
  elsif file_path.include?('/missions/')
    return 'base_mission_manifest'
  end
  
  nil
end

# Check if a file conforms to a template
def validate_against_template(file_path, json_data, template_name)
  return false unless @templates.key?(template_name)
  
  template = @templates[template_name]
  missing_fields = []
  
  # Simple recursive field checker
  def check_fields(template_obj, data_obj, path, missing_fields)
    template_obj.each do |key, value|
      current_path = path.empty? ? key : "#{path}.#{key}"
      
      # Skip the template key itself
      next if key == 'template'
      
      if value.is_a?(Hash) && !value.empty?
        # Check if the corresponding structure exists
        if !data_obj.key?(key) || !data_obj[key].is_a?(Hash)
          missing_fields << "#{current_path} (structure)"
        else
          # Recursively check nested fields
          check_fields(value, data_obj[key], current_path, missing_fields)
        end
      else
        # Check if basic field exists
        missing_fields << current_path unless data_obj.key?(key)
      end
    end
  end
  
  check_fields(template, json_data, '', missing_fields)
  
  if missing_fields.empty?
    puts "  File conforms to template '#{template_name}'"
    true
  else
    puts "  WARNING: File missing fields from template '#{template_name}':"
    missing_fields.each do |field|
      puts "    - #{field}"
    end
    @warnings_found += missing_fields.size
    false
  end
end

# Process a single file
def process_file(file_path)
  return unless file_path.end_with?('.json')
  return if file_path.include?('/templates/') # Skip template files themselves
  
  @files_validated += 1
  
  begin
    # Parse JSON
    json_data = JSON.parse(File.read(file_path))
    
    puts "Validating #{file_path}"
    
    # Determine template
    template_name = guess_template(file_path, json_data)
    
    if template_name.nil?
      puts "  WARNING: Could not determine template for #{file_path}"
      @warnings_found += 1
      return
    end
    
    validate_against_template(file_path, json_data, template_name)
    
  rescue JSON::ParserError => e
    puts "ERROR: Invalid JSON in #{file_path}: #{e.message}"
    @errors_found += 1
  rescue => e
    puts "ERROR: Validation failed for #{file_path}: #{e.message}"
    @errors_found += 1
  end
end

# Process files in a directory
def process_directory(dir_path)
  Dir.glob(File.join(dir_path, '*')).each do |path|
    if File.directory?(path)
      process_directory(path)
    else
      process_file(path)
    end
  end
end

# Main execution
begin
  # Load templates first
  load_templates
  
  if @templates.empty?
    puts "ERROR: No templates found. Cannot proceed with validation."
    exit 1
  end
  
  # Process data files
  process_directory(@data_root)
  
  # Summary
  puts "\n=== Template Verification Summary ==="
  puts "Files validated: #{@files_validated}"
  puts "Errors found: #{@errors_found}"
  puts "Warnings found: #{@warnings_found}"
  
  if @errors_found > 0
    puts "\nWARNING: #{@errors_found} errors were found during validation."
    puts "Please review the output above and fix these issues."
    exit 1
  elsif @warnings_found > 0
    puts "\nNote: #{@warnings_found} warnings were found during validation."
    puts "These are missing fields compared to templates, which may be intentional."
    exit 0
  else
    puts "\nSuccess! All files validated successfully against templates."
    exit 0
  end
rescue => e
  puts "ERROR: Validation failed: #{e.message}"
  puts e.backtrace
  exit 1
end