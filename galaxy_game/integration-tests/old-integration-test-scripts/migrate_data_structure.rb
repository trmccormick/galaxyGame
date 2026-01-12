#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require 'pathname'

puts "=== Galaxy Game Data Migration Tool ==="

# Configuration
SOURCE_PATH = ENV['SOURCE_PATH'] || '/home/galaxy_game/app/data/json-data-old'
TARGET_PATH = ENV['TARGET_PATH'] || '/home/galaxy_game/app/data'
DRY_RUN = ENV['DRY_RUN'] == 'true'

@source_root = Pathname.new(SOURCE_PATH)
@target_root = Pathname.new(TARGET_PATH)

@files_processed = 0
@files_migrated = 0
@errors_found = 0
@type_counts = Hash.new(0)

# Directories to exclude from migration (preserve in original location)
EXCLUDED_DIRECTORIES = [
  'star_systems',  # System generation data
  # Add other directories that should be preserved
]

# Check if a path should be excluded
def should_exclude?(path)
  relative_path = Pathname.new(path).relative_path_from(@source_root).to_s
  EXCLUDED_DIRECTORIES.any? { |dir| relative_path.start_with?(dir) }
end

# Ensure target directories exist
def ensure_directory(path)
  return if DRY_RUN
  FileUtils.mkdir_p(path) unless File.directory?(path)
end

# Create the base directory structure
def create_directory_structure
  puts "Creating directory structure..."
  
  [
    'manifests/cargo',
    'manifests/missions',
    'blueprints/units/propulsion',
    'blueprints/units/power',
    'blueprints/units/life_support',
    'blueprints/units/housing',
    'blueprints/modules/storage',
    'blueprints/modules/science',
    'blueprints/modules/control',
    'blueprints/craft/spaceships',
    'blueprints/craft/rovers',
    'blueprints/craft/habitats',
    'materials/raw/ores',
    'materials/raw/gases',
    'materials/raw/organics',
    'materials/processed/refined_metals',
    'materials/processed/alloys',
    'materials/processed/polymers',
    'materials/processed/components',
    'operational_data/units',
    'operational_data/modules',
    'operational_data/craft'
  ].each do |dir|
    ensure_directory(File.join(@target_root, dir))
  end
end

# Check if JSON is valid
def valid_json?(file_path)
  begin
    JSON.parse(File.read(file_path))
    true
  rescue JSON::ParserError => e
    puts "ERROR: Invalid JSON in #{file_path}: #{e.message}"
    @errors_found += 1
    false
  end
end

# Determine file type and target location
def determine_file_type(file_path, json_data)
  filename = File.basename(file_path, '.json')
  
  # Extract key indicators from the file content
  file_type = json_data['type'] rescue nil
  category = json_data['category'] rescue nil
  id = json_data['id'] rescue nil
  
  # Make a decision based on file path and content
  if file_path.include?('/blueprints/')
    @type_counts['blueprint'] += 1
    if file_path.include?('/units/')
      return ['blueprints/units', determine_unit_subtype(json_data)]
    elsif file_path.include?('/modules/')
      return ['blueprints/modules', determine_module_subtype(json_data)]
    elsif file_path.include?('/craft/')
      return ['blueprints/craft', determine_craft_subtype(json_data)]
    end
  elsif file_path.include?('/materials/')
    @type_counts['material'] += 1
    if file_path.include?('/raw/')
      return ['materials/raw', determine_raw_material_subtype(json_data)]
    elsif file_path.include?('/processed/')
      return ['materials/processed', determine_processed_material_subtype(json_data)]
    end
  elsif file_path.include?('_data.json') || filename.end_with?('_data')
    @type_counts['operational_data'] += 1
    if filename.include?('engine') || filename.include?('thruster')
      return ['operational_data/units', 'propulsion']
    elsif filename.include?('tank') || filename.include?('storage')
      return ['operational_data/units', 'storage']
    elsif filename.include?('habitat') || filename.include?('living')
      return ['operational_data/units', 'housing']
    else
      return ['operational_data/units', '']
    end
  elsif file_path.include?('/starship-cargo-manifest/')
    @type_counts['manifest'] += 1
    return ['manifests/cargo', '']
  elsif file_path.include?('/missions/')
    @type_counts['mission'] += 1
    return ['manifests/missions', '']
  end
  
  # Default fallback
  puts "WARNING: Could not determine type for #{file_path}"
  ['unknown', '']
end

# Helper methods for determining subtypes
def determine_unit_subtype(json_data)
  # Try to infer from unit type, function, or id
  type = json_data['unit_type'] || json_data['type'] || ''
  id = json_data['id'] || ''
  
  return 'propulsion' if type.include?('engine') || type.include?('thruster') || id.include?('engine') || id.include?('thruster')
  return 'power' if type.include?('power') || type.include?('generator') || id.include?('power') || id.include?('generator')
  return 'life_support' if type.include?('life_support') || id.include?('life_support') || id.include?('oxygen')
  return 'housing' if type.include?('habitat') || type.include?('living') || id.include?('habitat') || id.include?('living')
  
  # Default fallback for units
  ''
end

def determine_module_subtype(json_data)
  type = json_data['module_type'] || json_data['type'] || ''
  id = json_data['id'] || ''
  
  return 'storage' if type.include?('storage') || id.include?('storage') || id.include?('container')
  return 'science' if type.include?('science') || type.include?('lab') || id.include?('science') || id.include?('lab')
  return 'control' if type.include?('control') || type.include?('navigation') || id.include?('control')
  
  ''
end

def determine_craft_subtype(json_data)
  type = json_data['craft_type'] || json_data['type'] || ''
  id = json_data['id'] || ''
  
  return 'spaceships' if type.include?('spaceship') || type.include?('starship') || id.include?('ship')
  return 'rovers' if type.include?('rover') || id.include?('rover')
  return 'habitats' if type.include?('habitat') || type.include?('base') || id.include?('habitat') || id.include?('base')
  
  'spaceships' # Default for craft
end

def determine_raw_material_subtype(json_data)
  material_type = json_data['material_type'] || json_data['type'] || ''
  category = json_data['category'] || ''
  id = json_data['id'] || ''
  
  return 'ores' if material_type.include?('ore') || category.include?('ore') || id.include?('ore')
  return 'gases' if material_type.include?('gas') || category.include?('gas') || id.include?('gas')
  return 'organics' if material_type.include?('organic') || category.include?('organic') || id.include?('organic')
  
  'ores' # Default for raw materials
end

def determine_processed_material_subtype(json_data)
  material_type = json_data['material_type'] || json_data['type'] || ''
  category = json_data['category'] || ''
  id = json_data['id'] || ''
  
  return 'refined_metals' if material_type.include?('metal') || category.include?('metal') || id.include?('metal')
  return 'alloys' if material_type.include?('alloy') || category.include?('alloy') || id.include?('alloy')
  return 'polymers' if material_type.include?('polymer') || category.include?('polymer') || id.include?('polymer')
  return 'components' if material_type.include?('component') || category.include?('component') || id.include?('component')
  
  'refined_metals' # Default for processed materials
end

# Process a single file
def process_file(file_path)
  return unless file_path.end_with?('.json')
  
  @files_processed += 1
  
  # First check if JSON is valid
  return unless valid_json?(file_path)
  
  # Load the JSON data
  json_data = JSON.parse(File.read(file_path))
  
  # Determine where this file should go
  main_type, subtype = determine_file_type(file_path, json_data)
  
  # Skip unknown files
  if main_type == 'unknown'
    puts "Skipping #{file_path} (unknown type)"
    return
  end
  
  # Create target path
  target_dir = File.join(@target_root, main_type)
  target_dir = File.join(target_dir, subtype) unless subtype.empty?
  ensure_directory(target_dir)
  
  # Create target filename (preserve original name)
  target_file = File.join(target_dir, File.basename(file_path))
  
  # Copy the file
  if DRY_RUN
    puts "Would migrate: #{file_path} → #{target_file}"
  else
    FileUtils.cp(file_path, target_file)
    @files_migrated += 1
    puts "Migrated: #{file_path} → #{target_file}"
  end
end

# Process all files in a directory recursively
def process_directory(dir_path)
  Dir.glob(File.join(dir_path, '*')).each do |path|
    if should_exclude?(path)
      puts "Skipping excluded path: #{path}"
      next
    end
    
    if File.directory?(path)
      process_directory(path)
    else
      process_file(path)
    end
  end
end

# Main execution
begin
  puts DRY_RUN ? "Running in DRY RUN mode - no files will be modified" : "Running in LIVE mode - files will be migrated"
  
  # Create the directory structure
  create_directory_structure
  
  # Process all data
  process_directory(@source_root)
  
  # Summary
  puts "\n=== Migration Summary ==="
  puts "Files processed: #{@files_processed}"
  puts "Files migrated: #{@files_migrated}" unless DRY_RUN
  puts "Files that would be migrated: #{@files_processed - @errors_found}" if DRY_RUN
  puts "Errors found: #{@errors_found}"
  puts "\nFile type counts:"
  @type_counts.each do |type, count|
    puts "  #{type}: #{count}"
  end
  
  if @errors_found > 0
    puts "\nWARNING: #{@errors_found} errors were found during migration."
    puts "Please review the output above and fix these issues."
  else
    if DRY_RUN
      puts "\nDry run successful! No actual changes were made."
      puts "Run again without DRY_RUN=true to perform the actual migration."
    else
      puts "\nSuccess! All files migrated successfully."
    end
  end
rescue => e
  puts "ERROR: Migration failed: #{e.message}"
  puts e.backtrace
  exit 1
end