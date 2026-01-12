# app/sample_test_scripts/blueprint_integrity_checker.rb

require 'json'
require 'pathname'

puts "\n--- Starting Blueprint Integrity Checker ---"

# --- Configuration ---
options = {
  strict_mode: ENV['STRICT_MODE'] == 'true',
  data_path: ENV['DATA_PATH'] || '/home/galaxy_game/app/data',
  debug: ENV['DEBUG'] == 'true'
}

DATA_BASE_PATH = Pathname.new(options[:data_path])
PRECURSOR_MISSION_MANIFEST_PATH = DATA_BASE_PATH.join('manifests', 'missions', 'precursor_mission_autonomous_setup_v1.json')

puts "Configured DATA_BASE_PATH (container): #{DATA_BASE_PATH}"
puts "Configured PRECURSOR_MISSION_MANIFEST_PATH (container): #{PRECURSOR_MISSION_MANIFEST_PATH}"

# --- Helper Functions ---

@definitions_cache = {}
@missing_definitions = {}
@integrity_checks_passed = true
@files_checked = 0

def load_json_file(file_path, context_id = "N/A")
  unless file_path.exist?
    puts "ERROR: File not found: #{file_path} (Context: #{context_id})"
    @integrity_checks_passed = false
    return nil
  end

  begin
    JSON.parse(file_path.read)
  rescue JSON::ParserError => e
    puts "ERROR: Invalid JSON in file: #{file_path} (Context: #{context_id})"
    puts "  Parser Error: #{e.message}"
    @integrity_checks_passed = false
    nil
  end
end

def get_definition(id, context = "unknown")
  return @definitions_cache[id] if @definitions_cache.key?(id)
  return nil if @missing_definitions.key?(id)

  search_subdirs = [
    'blueprints/craft/transport/spaceships',
    'blueprints/craft/transport/spaceships/variants',
    'blueprints/units',
    'blueprints/modules',
    'materials',
    'resources',
    'crafts/transport/spaceships'
  ]

  found_file = nil
  search_subdirs.each do |subdir|
    file_path = DATA_BASE_PATH.join(subdir, "#{id}.json")
    if file_path.exist?
      found_file = file_path
      break
    end
  end

  unless found_file
    puts "WARNING: Definition for ID '#{id}' not found in any standard paths (Context: #{context})"
    @missing_definitions[id] = true
    @integrity_checks_passed = false
    return nil
  end

  definition = load_json_file(found_file, id)
  if definition
    @definitions_cache[id] = definition
    puts "  Loaded definition: '#{id}' from #{found_file.relative_path_from(DATA_BASE_PATH)}"
  else
    @missing_definitions[id] = true
  end
  definition
end

def check_required_fields(definition, required_fields, context_id)
  is_valid = true
  unless definition.is_a?(Hash)
    puts "ERROR: Definition for '#{context_id}' is not a Hash. Cannot check fields."
    @integrity_checks_passed = false
    return false
  end
  required_fields.each do |field|
    unless definition.key?(field)
      puts "ERROR: Definition for '#{context_id}' is missing required field: '#{field}'"
      @integrity_checks_passed = false
      is_valid = false
    end
  end
  is_valid
end

def check_unit_physical_properties(unit_id, unit_blueprint)
  puts "  Checking physical properties for unit '#{unit_id}'..."
  unless unit_blueprint.key?('physical_properties')
    puts "    ERROR: Unit blueprint '#{unit_id}' is missing 'physical_properties' block."
    @integrity_checks_passed = false
    return false
  end

  physical_props = unit_blueprint['physical_properties']
  required_props = ['length_m', 'width_m', 'height_m', 'empty_mass_kg', 'density_kg_m3']
  is_valid = check_required_fields(physical_props, required_props, "#{unit_id}.physical_properties")

  if is_valid
    ['length_m', 'width_m', 'height_m', 'empty_mass_kg', 'density_kg_m3'].each do |prop|
      if physical_props.key?(prop) && (!physical_props[prop].is_a?(Numeric) || physical_props[prop] <= 0)
        puts "    ERROR: '#{unit_id}' #{prop} must be a positive number. Found: #{physical_props[prop].inspect}"
        @integrity_checks_passed = false
        is_valid = false
      end
    end
  end
  is_valid
end

def infer_blueprint_id_from_unit_name(unit_name)
  # Simple conversion from "Multi-Purpose Cryogenic Storage" to "multi_purpose_cryogenic_storage"
  # This assumes your blueprint IDs are snake_case versions of the names.
  # If there's a more complex mapping, this function would need a lookup table.
  unit_name.downcase.gsub(/[^a-z0-9_]/, '_').squeeze('_').gsub(/^_|_$/, '')
end


def check_all_dependencies(main_definition_id, main_definition)
  puts "\n--- Checking Dependencies for '#{main_definition_id}' ---"

  unless main_definition.is_a?(Hash)
    puts "ERROR: Main definition '#{main_definition_id}' is not a valid hash. Skipping dependency checks."
    @integrity_checks_passed = false
    return
  end

  # Check materials for craft blueprints
  if main_definition.key?('materials') && main_definition['materials'].is_a?(Array)
    puts "  Checking required materials..."
    main_definition['materials'].each do |material_entry|
      material_id = material_entry['id']
      if material_id
        material_def = get_definition(material_id, "material for #{main_definition_id}")
        check_required_fields(material_def, ['id', 'name', 'unit'], material_id) if material_def
      else
        puts "ERROR: Material entry in '#{main_definition_id}' is missing 'id'."
        @integrity_checks_passed = false
      end
    end
  end

  # Check compatible units/modules for craft blueprints
  if main_definition.key?('compatible_units') && main_definition['compatible_units'].is_a?(Hash)
    puts "  Checking compatible units..."
    main_definition['compatible_units'].each do |slot_type, unit_ids|
      if unit_ids.is_a?(Array)
        unit_ids.each do |unit_id|
          unit_def = get_definition(unit_id, "compatible unit for #{main_definition_id} (slot: #{slot_type})")
          if unit_def
            check_required_fields(unit_def, ['id', 'name', 'type'], unit_id)
          end
        end
      else
         puts "ERROR: compatible_units for slot '#{slot_type}' in '#{main_definition_id}' is not an Array."
         @integrity_checks_passed = false
      end
    end
  end

  # Check recommended/installed/stowed units/modules for craft configurations
  # This part now includes checking `custom_configuration.installed_units`
  ['recommended_units', 'recommended_modules', 'stowed_units'].each do |unit_list_key|
    if main_definition.key?(unit_list_key) && main_definition[unit_list_key].is_a?(Array)
      puts "  Checking #{unit_list_key}..."
      main_definition[unit_list_key].each do |unit_entry|
        unit_id = unit_entry['id'] || unit_entry['blueprint_id']
        if unit_id
          unit_def = get_definition(unit_id, "#{unit_list_key} in #{main_definition_id}")
          if unit_def
            check_required_fields(unit_def, ['id', 'name', 'type'], unit_id)
            check_unit_physical_properties(unit_id, unit_def)
          end
        else
          puts "ERROR: Entry in '#{main_definition_id}.#{unit_list_key}' is missing 'id' or 'blueprint_id'."
          @integrity_checks_passed = false
        end
      end
    elsif main_definition.key?(unit_list_key) # Key exists but is not an array
      puts "ERROR: '#{main_definition_id}.#{unit_list_key}' exists but is not an Array."
      @integrity_checks_passed = false
    end
  end

  # Specific check for custom_configuration.installed_units, found in the manifest
  if main_definition.key?('custom_configuration') && main_definition['custom_configuration'].is_a?(Hash) &&
     main_definition['custom_configuration'].key?('installed_units') && main_definition['custom_configuration']['installed_units'].is_a?(Array)
    
    puts "  Checking custom_configuration.installed_units..."
    main_definition['custom_configuration']['installed_units'].each do |unit_entry|
      # Try to infer blueprint ID from 'name' first, or use 'unit_type' as a fallback if necessary
      unit_name = unit_entry['name']
      unit_id_lookup = unit_name ? infer_blueprint_id_from_unit_name(unit_name) : nil

      if unit_id_lookup
        unit_def = get_definition(unit_id_lookup, "custom_configuration.installed_units in #{main_definition_id} (via name: '#{unit_name}')")
        if unit_def
          check_required_fields(unit_def, ['id', 'name', 'type'], unit_id_lookup)
          check_unit_physical_properties(unit_id_lookup, unit_def)
        end
      else
        puts "ERROR: Entry in '#{main_definition_id}.custom_configuration.installed_units' is missing 'name' or could not infer blueprint ID."
        @integrity_checks_passed = false
      end
    end
  end

  # Check inventory items, prioritizing 'units' as per the manifest
  if main_definition.key?('inventory') && main_definition['inventory'].is_a?(Hash)
    if main_definition['inventory'].key?('units') && main_definition['inventory']['units'].is_a?(Array)
      puts "  Checking inventory units..."
      main_definition['inventory']['units'].each do |item_entry|
        # Use 'name' from the manifest's inventory units as the lookup ID for the blueprint
        item_name = item_entry['name']
        item_id_lookup = item_name ? infer_blueprint_id_from_unit_name(item_name) : nil

        if item_id_lookup
          item_def = get_definition(item_id_lookup, "inventory item for #{main_definition_id} (via name: '#{item_name}')")
          if item_def
            check_required_fields(item_def, ['id', 'name'], item_id_lookup)
            # Ensure 'count' field exists for inventory units
            unless item_entry.key?('count') && item_entry['count'].is_a?(Numeric) && item_entry['count'] >= 0
                puts "ERROR: Inventory unit '#{item_name}' in '#{main_definition_id}' missing valid 'count' field."
                @integrity_checks_passed = false
            end
            check_unit_physical_properties(item_id_lookup, item_def) # Inventory units should also have physical properties
          end
        else
          puts "ERROR: Inventory unit entry in '#{main_definition_id}.inventory.units' is missing 'name' or could not infer blueprint ID."
          @integrity_checks_passed = false
        end
      end
    elsif main_definition['inventory'].key?('units') # Exists but not an array
      puts "ERROR: '#{main_definition_id}.inventory.units' exists but is not an Array."
      @integrity_checks_passed = false
    end

    # Check 'supplies' as a secondary, though currently empty in your manifest
    if main_definition['inventory'].key?('supplies') && main_definition['inventory']['supplies'].is_a?(Array)
        puts "  Checking inventory supplies..."
        main_definition['inventory']['supplies'].each do |item_entry|
            item_id = item_entry['id']
            if item_id
                item_def = get_definition(item_id, "inventory item for #{main_definition_id}")
                if item_def
                    check_required_fields(item_def, ['id', 'name'], item_id)
                    unless item_entry.key?('quantity') || item_entry.key?('count')
                        puts "WARNING: Inventory item '#{item_entry['name'] || item_id}' in '#{main_definition_id}' missing 'quantity' or 'count' field. Please standardize to 'quantity'."
                        @integrity_checks_passed = false
                    end
                end
            else
                puts "ERROR: Inventory item entry in '#{main_definition_id}.inventory.supplies' is missing 'id'."
                @integrity_checks_passed = false
            end
        end
    end
  end
end

# Add a function to generate skeleton definitions
def generate_missing_definition(id, context)
  template = case context
             when /unit/i
               UNIT_TEMPLATE
             when /module/i
               MODULE_TEMPLATE
             when /material/i
               MATERIAL_TEMPLATE
             else
               GENERIC_TEMPLATE
             end
  
  # Replace placeholders
  template.gsub('{{id}}', id)
          .gsub('{{name}}', id.gsub('_', ' ').split.map(&:capitalize).join(' '))
end

# --- Main Execution ---

# 1. Verify Starship Chassis Blueprint
puts "\n--- Verifying Starship Chassis Blueprint (id: starship_blueprint) ---"
starship_chassis_id = "starship_blueprint"
starship_chassis_blueprint = get_definition(starship_chassis_id, "Starship Chassis")
if starship_chassis_blueprint
  check_required_fields(starship_chassis_blueprint, ['id', 'name', 'category', 'materials', 'ports', 'compatible_units', 'assembly_time', 'maintenance', 'research_required'], starship_chassis_id)
  check_all_dependencies(starship_chassis_id, starship_chassis_blueprint)
else
  puts "FATAL ERROR: Starship Chassis Blueprint '#{starship_chassis_id}' could not be loaded. Cannot proceed with variant checks."
  @integrity_checks_passed = false
end


# 2. Verify Starship Landing Cargo Variant Data
puts "\n--- Verifying Starship Landing Cargo Variant Data (id: starship_landing_cargo_variant_data) ---"
starship_variant_id = "starship_landing_cargo_variant_data"
starship_variant_data = get_definition(starship_variant_id, "Starship Landing Cargo Variant")
if starship_variant_data
  check_required_fields(starship_variant_data, ['id', 'name', 'base_chassis_blueprint_id', 'mass_empty_kg', 'cargo_capacity_m3', 'max_cargo_mass_kg', 'recommended_units', 'fuel_capacity_lox_kg', 'fuel_capacity_methane_kg'], starship_variant_id)
  
  if starship_variant_data.key?('base_chassis_blueprint_id') && starship_variant_data['base_chassis_blueprint_id'] != starship_chassis_id
    puts "ERROR: Starship variant data references incorrect base chassis ID: '#{starship_variant_data['base_chassis_blueprint_id']}'. Expected '#{starship_chassis_id}'."
    @integrity_checks_passed = false
  end

  check_all_dependencies(starship_variant_id, starship_variant_data)

  if starship_variant_data.key?('cargo_capacity_m3') && (!starship_variant_data['cargo_capacity_m3'].is_a?(Numeric) || starship_variant_data['cargo_capacity_m3'] <= 0)
    puts "ERROR: '#{starship_variant_id}' has non-positive or invalid cargo_capacity_m3. Found: #{starship_variant_data['cargo_capacity_m3'].inspect}"
    @integrity_checks_passed = false
  end
  if starship_variant_data.key?('max_cargo_mass_kg') && (!starship_variant_data['max_cargo_mass_kg'].is_a?(Numeric) || starship_variant_data['max_cargo_mass_kg'] <= 0)
    puts "ERROR: '#{starship_variant_id}' has non-positive or invalid max_cargo_mass_kg. Found: #{starship_variant_data['max_cargo_mass_kg'].inspect}"
    @integrity_checks_passed = false
  end

  puts "\n  Simulating Starship construction and capacity check (placeholder):"
  puts "    Starship variant capacity: #{starship_variant_data['cargo_capacity_m3'] || 'N/A'} m^3"
  puts "    Starship variant max cargo mass: #{starship_variant_data['max_cargo_mass_kg'] || 'N/A'} kg"
  puts "    (Further calculations would go here once all unit physical properties are accurately defined)"
else
  puts "FATAL ERROR: Starship Landing Cargo Variant Data '#{starship_variant_id}' could not be loaded. Cannot proceed with mission manifest checks dependent on it."
  @integrity_checks_passed = false
end

# 3. Verify the main precursor mission manifest
puts "\n--- Verifying Precursor Mission Autonomous Setup Manifest ---"
precursor_manifest = load_json_file(PRECURSOR_MISSION_MANIFEST_PATH, "Precursor Mission Manifest")

if precursor_manifest
  if precursor_manifest.key?('starship')
    puts "  Manifest contains 'starship' configuration block."
    starship_config_block = precursor_manifest['starship']
    # Removed 'installed_units' from this required fields check here, as it's nested under custom_configuration
    check_required_fields(starship_config_block, ['name', 'craft_name', 'stowed_units', 'inventory', 'custom_configuration'], "precursor_mission_autonomous_setup_v1.json.starship")
    
    # Check dependencies within the manifest's starship configuration
    check_all_dependencies("precursor_mission_autonomous_setup_v1.json.starship", starship_config_block)

    # Specific inventory check
    if starship_config_block.key?('inventory') && starship_config_block['inventory'].is_a?(Hash)
      if starship_config_block['inventory'].key?('units') && starship_config_block['inventory']['units'].is_a?(Array)
        puts "  Manifest confirms use of 'inventory.units'."
      elsif starship_config_block['inventory'].key?('units') # If 'units' exists but isn't an array
        puts "ERROR: Manifest 'inventory.units' exists but is not an Array."
        @integrity_checks_passed = false
      else
        puts "  WARNING: Manifest 'inventory' block does not contain a 'units' array as expected."
        @integrity_checks_passed = false
      end
    else
        puts "ERROR: Manifest 'starship' block is missing 'inventory' key or it's not a Hash."
        @integrity_checks_passed = false
    end

  else
    puts "ERROR: Precursor mission manifest does not contain a top-level 'starship' block."
    @integrity_checks_passed = false
  end
else
  puts "FATAL ERROR: Precursor Mission Manifest could not be loaded. Please ensure it exists at: #{PRECURSOR_MISSION_MANIFEST_PATH}"
  @integrity_checks_passed = false
end


puts "\n--- Blueprint Integrity Check Complete ---"
if @integrity_checks_passed
  puts "RESULT: All core blueprint and data integrity checks passed! 🎉"
else
  puts "RESULT: ERRORS/WARNINGS DETECTED. 🚨 Please review the output above to address issues."
end

puts "\n--- Blueprint Integrity Check Summary ---"
puts "Total definitions checked: #{@definitions_cache.size}"
puts "Missing definitions: #{@missing_definitions.size}"
puts "Total files checked: #{@files_checked}"
puts "Integrity checks passed: #{@integrity_checks_passed}"

def find_cargo_manifest(id)
  path = MANIFEST_PATHS[:cargo].join("#{id}.json")
  load_json_file(path, "Cargo Manifest #{id}")
end

def find_mission_manifest(id)
  path = MANIFEST_PATHS[:missions].join("#{id}.json")
  load_json_file(path, "Mission Manifest #{id}")
end