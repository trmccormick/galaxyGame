# tools/check_craft_fit.rb

# ===========================
# Usage:
#   rails runner tools/check_craft_fit.rb <craft_id> [--migrate]
#
# Example:
#   rails runner tools/check_craft_fit.rb starship_precursor_mission
#   rails runner tools/check_craft_fit.rb starship_precursor_mission --migrate
#
# This tool checks the recommended fit for a craft (units, modules and rigs)
# against available data files. If --migrate is provided, it will attempt to auto-generate or
# migrate missing components and items.
# ===========================

require 'json'
require 'securerandom'
require 'find'
require 'fileutils'

puts "\n🔍 Starting Recommended Fit Checker..."

# Parse arguments
craft_id = nil
auto_migrate = false

ARGV.each do |arg|
  if arg == '--migrate'
    auto_migrate = true
  else
    craft_id ||= arg
  end
end

if craft_id.nil?
  puts "❌ ERROR: Please provide a craft ID (e.g., crypto_mining_satellite)."
  exit 1
end

# Define paths - adjusted for Docker container
DATA_PATH = Rails.root.join('app', 'data').freeze
OLD_DATA_PATH = DATA_PATH.join('old-json-data').freeze  # Inside container, old data should be in app/data/old-json-data
BACKUP_PATH = DATA_PATH.join('backups', Time.now.strftime('%Y%m%d_%H%M%S')).freeze

puts "Using data paths:"
puts "- Current data: #{DATA_PATH}"
puts "- Old data: #{OLD_DATA_PATH}"
puts "- Backups: #{BACKUP_PATH}"

# Helper method to search ID inside JSON files (both new and old)
def search_data_files_for_id(id, subfolder, include_old = true)
  matches = []
  
  # Search in current app data
  app_dir = File.join(DATA_PATH, 'blueprints', subfolder)
  if Dir.exist?(app_dir)
    puts "  🔍 Searching in current data: #{app_dir}"
    Find.find(app_dir) do |path|
      next unless path.end_with?('.json')
      begin
        content = JSON.parse(File.read(path))
        matches << {path: path, content: content, location: 'current'} if content['id'] == id
      rescue JSON::ParserError
        # Skip malformed files
      end
    end
  end
  
  # Search in old data if requested
  if include_old && Dir.exist?(OLD_DATA_PATH)
    # Define different possible old paths to search
    old_paths = []
    
    case subfolder
    when 'units'
      # For units, check both blueprint and operational data
      old_paths << File.join(OLD_DATA_PATH, 'production_old4', 'blueprints', 'units')
      old_paths << File.join(OLD_DATA_PATH, 'production_old4', 'operational_data', 'units')
      old_paths << File.join(OLD_DATA_PATH, 'production_old3', 'blueprints', 'units')
      old_paths << File.join(OLD_DATA_PATH, 'production_old3', 'operational_data', 'units')
      old_paths << File.join(OLD_DATA_PATH, 'blueprints', 'units')
      old_paths << File.join(OLD_DATA_PATH, 'operational_data', 'units')
    when 'rigs'
      old_paths << File.join(OLD_DATA_PATH, 'production_old4', 'blueprints', 'rigs')
      old_paths << File.join(OLD_DATA_PATH, 'production_old4', 'operational_data', 'rigs')
      old_paths << File.join(OLD_DATA_PATH, 'blueprints', 'rigs')
    when 'modules'
      old_paths << File.join(OLD_DATA_PATH, 'production_old4', 'blueprints', 'modules')
      old_paths << File.join(OLD_DATA_PATH, 'production_old4', 'operational_data', 'modules')
      old_paths << File.join(OLD_DATA_PATH, 'blueprints', 'modules')
    end
    
    # Search each old path
    old_paths.each do |base_path|
      next unless Dir.exist?(base_path)
      puts "  🔍 Searching in old data: #{base_path}"
      
      # Recursively search all subdirectories
      Find.find(base_path) do |path|
        next unless path.end_with?('.json')
        begin
          content = JSON.parse(File.read(path))
          matches << {path: path, content: content, location: 'old'} if content['id'] == id
        rescue JSON::ParserError
          # Skip malformed files
        end
      end
    end
  end
  
  matches
end

# Function to migrate a file from old to new location
def migrate_file(file_data, component_type)
  old_path = file_data[:path]
  content = file_data[:content]

  # Remap category if needed
  category = content['category'] == 'power' ? 'energy' : (content['category'] || 'general')
  subcategory = content['subcategory'] || 'misc'

  # Determine if this is a blueprint or operational data
  is_blueprint = old_path.include?('blueprint') || old_path.include?('_bp.json')

  # Use correct folder and file naming
  if is_blueprint
    new_dir = case component_type
      when 'units' then GalaxyGame::Paths::UNIT_BLUEPRINTS_PATH.join(category).to_s
      when 'modules' then GalaxyGame::Paths::MODULE_BLUEPRINTS_PATH.join(category).to_s
      when 'rigs' then GalaxyGame::Paths::RIG_BLUEPRINTS_PATH.join(category).to_s
    end
    file_name = "#{content['id']}_bp.json"
  else
    new_dir = case component_type
      when 'units' then GalaxyGame::Paths::ENERGY_UNITS_PATH.to_s
      when 'modules' then GalaxyGame::Paths::ENERGY_MODULES_PATH.to_s
      when 'rigs' then GalaxyGame::Paths::ENERGY_RIGS_PATH.to_s
    end
    file_name = "#{content['id']}_data.json"
  end

  FileUtils.mkdir_p(new_dir)

  new_path = File.join(new_dir, file_name)

  # Backup if exists
  if File.exist?(new_path)
    backup_dir = File.join(BACKUP_PATH, component_type, category)
    FileUtils.mkdir_p(backup_dir)
    FileUtils.cp(new_path, File.join(backup_dir, file_name))
  end

  # Update category in JSON before saving
  content['category'] = category

  File.write(new_path, JSON.pretty_generate(content))
  puts "     ✅ Migrated to: #{new_path}"

  new_path
end

# Lookup services
unit_lookup = Lookup::UnitLookupService.new
rig_lookup = defined?(Lookup::RigLookupService) ? Lookup::RigLookupService.new : nil
module_lookup = defined?(Lookup::ModuleLookupService) ? Lookup::ModuleLookupService.new : nil
craft_lookup = Lookup::CraftLookupService.new
item_lookup = Lookup::ItemLookupService.new

# Load operational data
puts "\n📡 Loading craft operational data for: #{craft_id}..."
craft_data = craft_lookup.find_craft(craft_id)

if craft_data.nil?
  puts "❌ ERROR: No operational data found for craft ID: #{craft_id}"
  exit 1
end

# Load base blueprint if available
base_blueprint_path = File.join(DATA_PATH, 'blueprints', 'craft', 'space', 'satellites', 'generic_satellite_bp.json')
base_blueprint = nil
if File.exist?(base_blueprint_path)
  base_blueprint = JSON.parse(File.read(base_blueprint_path))
end

# Use ports from operational data, fallback to blueprint if missing
unit_ports = craft_data.dig('ports', 'unit_ports')
module_ports = craft_data.dig('ports', 'external_module_ports') || craft_data.dig('ports', 'module_ports')
rig_ports = craft_data.dig('ports', 'rig_ports')

if base_blueprint
  unit_ports ||= base_blueprint.dig('ports', 'unit_ports')
  module_ports ||= base_blueprint.dig('ports', 'external_module_ports') || base_blueprint.dig('ports', 'module_ports')
  rig_ports ||= base_blueprint.dig('ports', 'rig_ports')
end

unit_ports ||= 0
module_ports ||= 0
rig_ports ||= 0

puts "✅ Found craft: #{craft_data['name'] || craft_id}"

recommended_fit = craft_data['recommended_fit'] || {}

unit_count = (recommended_fit['units'] || []).sum { |u| u['count'] || 1 }
module_count = (recommended_fit['modules'] || []).sum { |m| m['count'] || 1 }
rig_count = (recommended_fit['rigs'] || []).sum { |r| r['count'] || 1 }

puts "\n🔎 Port Capacity Check:"
puts "  - Unit Ports: #{unit_ports}, Recommended Units: #{unit_count}"
puts "  - Module Ports: #{module_ports}, Recommended Modules: #{module_count}"
puts "  - Rig Ports: #{rig_ports}, Recommended Rigs: #{rig_count}"

if unit_count > unit_ports
  puts "❌ ERROR: Recommended fit exceeds available unit ports! (#{unit_count} > #{unit_ports})"
end
if module_count > module_ports
  puts "❌ ERROR: Recommended fit exceeds available module ports! (#{module_count} > #{module_ports})"
end
if rig_count > rig_ports
  puts "❌ ERROR: Recommended fit exceeds available rig ports! (#{rig_count} > #{rig_ports})"
end

if unit_count <= unit_ports && module_count <= module_ports && rig_count <= rig_ports
  puts "✅ Port capacity check passed."
end

# Map unit categories to port types
PORT_MAP = {
  'computers' => 'internal_unit_ports',
  'energy' => 'external_unit_ports',
  'propulsion' => ['propulsion_ports', 'external_unit_ports'], # Accept either if available
  'storage' => 'internal_fuel_storage_ports',
  # Add more as needed
}

# Count required ports by type
required_ports = Hash.new(0)
(recommended_fit['units'] || []).each do |unit|
  category = unit['category'] || 'unit'
  port_type = PORT_MAP[category] || 'internal_unit_ports'
  required_ports[port_type] += unit['count'] || 1
end

MODULE_PORT_MAP = {
  'internal' => 'internal_module_ports',
  'external' => 'external_module_ports'
}

(recommended_fit['modules'] || []).each do |mod|
  location = mod['location'] || 'internal'
  port_type = MODULE_PORT_MAP[location] || 'internal_module_ports'
  required_ports[port_type] += mod['count'] || 1
end

RIG_PORT_MAP = {
  'internal' => 'internal_rig_ports',
  'external' => 'external_rig_ports'
}

(recommended_fit['rigs'] || []).each do |rig|
  location = rig['location'] || 'internal'
  port_type = RIG_PORT_MAP[location] || 'internal_rig_ports'
  required_ports[port_type] += rig['count'] || 1
end

# Get available ports from blueprint
available_ports = base_blueprint['ports']

puts "\n🔎 Port Capacity Check:"
available_ports.each do |port_type, port_count|
  req_count = required_ports[port_type] || 0
  puts "  - #{port_type.humanize}: #{port_count}, Required: #{req_count}"
  if req_count > port_count
    puts "❌ ERROR: Recommended fit exceeds available #{port_type} (#{req_count} > #{port_count})"
  end
end

# === Units Check ===
puts "\n🧪 Checking recommended units..."
missing_units = []
migrated_units = []
generated_units = []

(recommended_fit['units'] || []).each do |unit_entry|
  unit_id = unit_entry['id']
  result = unit_lookup.find_unit(unit_id)

  if result.nil?
    missing_units << unit_id
    puts "  ❌ MISSING unit: #{unit_id}"
    
    # Check if the unit exists in app/data/units
    current_matches = search_data_files_for_id(unit_id, 'units', false)
    if current_matches.any?
      puts "     🔍 Found in current files:"
      current_matches.each { |m| puts "       - #{m[:path]}" }
      next
    end
    
    # Check if the unit exists in old data
    old_matches = search_data_files_for_id(unit_id, 'units', true)
    old_matches.reject! { |m| m[:location] == 'current' } # Remove current matches
    
    if old_matches.any?
      puts "     🔍 Found in old data files:"
      old_matches.each { |m| puts "       - #{m[:path]}" }
      
      if auto_migrate
        # Migrate both blueprint and operational data
        blueprint = old_matches.find { |m| m[:path].include?('blueprint') || m[:path].end_with?('_bp.json') }
        operational = old_matches.find { |m| !m[:path].include?('blueprint') && !m[:path].end_with?('_bp.json') }
        
        if blueprint
          new_path = migrate_file(blueprint, 'units')
          puts "     ✅ Migrated blueprint to: #{new_path}"
        end
        
        if operational
          new_path = migrate_file(operational, 'units')
          puts "     ✅ Migrated operational data to: #{new_path}"
        end
        
        migrated_units << unit_id
      else
        puts "     ℹ️ Run with --migrate flag to automatically migrate these files"
      end
    else
      puts "     ❌ Not found in old data"
    end
  else
    puts "  ✅ Found unit: #{unit_id}"
  end
end

# === Rigs Check ===
puts "\n🧪 Checking recommended rigs..."
missing_rigs = []
migrated_rigs = []

(recommended_fit['rigs'] || []).each do |rig_entry|
  rig_id = rig_entry['id']
  result = rig_lookup&.find_rig(rig_id)

  if result.nil?
    missing_rigs << rig_id
    puts "  ❌ MISSING rig: #{rig_id}"
    found = search_data_files_for_id(rig_id, 'rigs')
    if found.any?
      puts "     🔍 Found in files:"
      found.each { |f| puts "       - #{f}" }
    else
      puts "     ❌ Not found in app/data/rigs"
    end
  else
    puts "  ✅ Found rig: #{rig_id}"
  end
end

# === Modules Check ===
puts "\n🧪 Checking recommended modules..."
missing_modules = []
migrated_modules = []

(recommended_fit['modules'] || []).each do |mod_entry|
  mod_id = mod_entry['id']
  result = module_lookup&.find_module(mod_id)
  found = search_data_files_for_id(mod_id, 'modules')

  if result.nil? && found.none? { |m| m[:location] == 'current' } && !migrated_modules.include?(mod_id)
    if auto_migrate
      generator = GameDataGenerator.new
      blueprint, operational = generator.generate_module(
        mod_id,
        mod_entry['category'] || infer_category(mod_id),
        mod_entry['subcategory'] || 'default',
        mod_entry['properties'] || {}
      )
      generated_modules << mod_id
      puts "     🛠️ Generated new module: #{mod_id} (#{blueprint}, #{operational})"
    end
  end
end

# === Summary ===
puts "\n📊 Summary of Missing Components:"
puts "  🚫 Units: #{missing_units.count}"
puts "  🚫 Rigs: #{missing_rigs.count}"
puts "  🚫 Modules: #{missing_modules.count}"

if migrated_units.any? || migrated_rigs.any? || migrated_modules.any?
  puts "\n🔄 Migrated Components:"
  puts "  🔄 Units: #{migrated_units.count}" + (migrated_units.any? ? " (#{migrated_units.join(', ')})" : "")
  puts "  🔄 Rigs: #{migrated_rigs.count}" + (migrated_rigs.any? ? " (#{migrated_rigs.join(', ')})" : "")
  puts "  🔄 Modules: #{migrated_modules.count}" + (migrated_modules.any? ? " (#{migrated_modules.join(', ')})" : "")
end

remaining_missing = []
remaining_missing += (missing_units - migrated_units)
remaining_missing += (missing_rigs - migrated_rigs)
remaining_missing += (missing_modules - migrated_modules)

if remaining_missing.any?
  puts "\n❗ Some recommended fit entries are still missing."
  if auto_migrate
    puts "   These components weren't found in old data and need to be manually created."
  else
    puts "   Try running with --migrate flag to migrate components from old data."
  end
else
  puts "\n✅ All recommended fit entries found or migrated. Ready for deployment."
end

# Attempt to generate missing units, modules, and rigs if not found
puts "\n🛠️ Attempting to generate missing components..."
generated_units = []
generated_modules = []
generated_rigs = []

(recommended_fit['units'] || []).each do |unit_entry|
  unit_id = unit_entry['id']
  result = unit_lookup.find_unit(unit_id)

  if result.nil? && !migrated_units.include?(unit_id)
    # Try to generate if not found or migrated
    if auto_migrate
      # Use GameDataGenerator to create missing unit
      generator = GameDataGenerator.new
      # You may want to pass more properties if available
      blueprint, operational = generator.generate_unit(
        unit_id,
        'energy', # or use unit_entry['category'] if present
        unit_entry['subcategory'] || 'renewable',
        unit_entry['properties'] || {}
      )
      generated_units << unit_id
      puts "     🛠️ Generated new unit: #{unit_id} (#{blueprint}, #{operational})"
    end
  end
end

(recommended_fit['modules'] || []).each do |mod_entry|
  mod_id = mod_entry['id']
  result = module_lookup&.find_module(mod_id)
  found = search_data_files_for_id(mod_id, 'modules')

  # Only generate if NOT found in current data AND not migrated
  if result.nil? && found.none? { |m| m[:location] == 'current' } && !migrated_modules.include?(mod_id)
    if auto_migrate
      generator = GameDataGenerator.new
      blueprint, operational = generator.generate_module(
        mod_id,
        mod_entry['category'] || infer_category(mod_id),
        mod_entry['subcategory'] || 'default',
        mod_entry['properties'] || {}
      )
      generated_modules << mod_id
      puts "     🛠️ Generated new module: #{mod_id} (#{blueprint}, #{operational})"
    end
  end
end
