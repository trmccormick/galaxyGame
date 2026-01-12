require 'json'
require 'securerandom'

puts "\n🚀 Starting Starship Precursor Mission Integration Test..."

# 1. Load manifest, task list, and mission profile
manifest_path = File.join(GalaxyGame::Paths::JSON_DATA, 'missions', 'lunar-precursor', 'starship_precursor_manifest_v1.json')
tasks_path = File.join(GalaxyGame::Paths::JSON_DATA, 'missions', 'lunar-precursor', 'starship_precursor_tasks_v1.json')
profile_path = File.join(GalaxyGame::Paths::JSON_DATA, 'missions', 'lunar-precursor', 'starship_precursor_profile_v1.json')

manifest = JSON.parse(File.read(manifest_path))
task_list = JSON.parse(File.read(tasks_path))
profile = JSON.parse(File.read(profile_path))

puts "✔ Manifest loaded: #{manifest['manifest_id']}"
puts "✔ Loaded #{task_list.length} tasks"
puts "✔ Profile loaded: Start location type: #{profile.dig('start_location', 'type')}"

# 2. Setup celestial context and organization
puts "\n2. Setting up Earth and organization..."
earth = CelestialBodies::Planets::Rocky::TerrestrialPlanet.where(name: "Earth", identifier: "EARTH-01").first
unless earth
  raise "❌ ERROR: Earth not found in celestial_bodies table. Please seed the database with planetary data before running this test."
end

earth_location = Location::CelestialLocation.find_or_create_by!(
  name: "Kennedy Space Center",
  coordinates: "28.57°N 80.65°W",
  celestial_body: earth
)

space_x = Organizations::BaseOrganization.find_or_create_by!(
  name: 'AstroLift Corporation',
  identifier: 'ASTROLIFT',
  organization_type: :corporation
)

# 3. Create Starship using Lookup::CraftLookupService
puts "\n3. Creating Starship with manifest configuration..."
craft_lookup = Lookup::CraftLookupService.new
starship_data = craft_lookup.find_craft(manifest['craft']['id'])
raise "Starship operational data not found" unless starship_data

starship = Craft::Transport::HeavyLander.create!(
  name: "PrecursorMission-#{SecureRandom.hex(4)}",
  craft_name: starship_data['name'],
  craft_type: starship_data['subcategory'],
  owner: space_x,
  deployed: false,
  operational_data: starship_data
)
puts "Starship created: #{starship.name} (ID: #{starship.id})"

# 4. Port capacity check (like GCC sat test)
puts "\n4. Port Capacity Check:"
recommended_fit = starship.operational_data['recommended_fit'] || {}
recommended_units = recommended_fit['units'] || []
recommended_modules = recommended_fit['modules'] || []
recommended_rigs = recommended_fit['rigs'] || []
available_ports = starship.operational_data['ports'] || {}

PORT_MAP = {
  'computers' => 'internal_unit_ports',
  'energy' => 'external_unit_ports',
  'propulsion' => ['propulsion_ports', 'external_unit_ports'],
  'storage' => 'internal_fuel_storage_ports'
}
required_ports = Hash.new(0)
recommended_units.each do |unit|
  category = unit['category'] || 'unit'
  port_type = PORT_MAP[category] || 'internal_unit_ports'
  if port_type.is_a?(Array)
    fitted = false
    port_type.each do |pt|
      if (available_ports[pt] || 0) > (required_ports[pt] || 0)
        required_ports[pt] += unit['count'] || 1
        fitted = true
        break
      end
    end
    required_ports[port_type.first] += unit['count'] || 1 unless fitted
  else
    required_ports[port_type] += unit['count'] || 1
  end
end
MODULE_PORT_MAP = { 'internal' => 'internal_module_ports', 'external' => 'external_module_ports' }
recommended_modules.each do |mod|
  location = mod['location'] || 'internal'
  port_type = MODULE_PORT_MAP[location] || 'internal_module_ports'
  required_ports[port_type] += mod['count'] || 1
end
RIG_PORT_MAP = { 'internal' => 'internal_rig_ports', 'external' => 'external_rig_ports' }
recommended_rigs.each do |rig|
  location = rig['location'] || 'internal'
  port_type = RIG_PORT_MAP[location] || 'internal_rig_ports'
  required_ports[port_type] += rig['count'] || 1
end
available_ports.each do |port_type, port_count|
  req_count = required_ports[port_type] || 0
  puts "  - #{port_type.humanize}: #{port_count}, Required: #{req_count}"
  if req_count > port_count
    puts "❌ ERROR: Recommended fit exceeds available #{port_type} (#{req_count} > #{port_count})"
    exit 1
  end
end
puts "✅ Port capacity checks passed."

# 5. Install units (and modules/rigs if present)
puts "\n5. Installing units and modules..."
unit_lookup = Lookup::UnitLookupService.new
missing_units = []
(manifest['craft']['installed_units'] || []).each do |unit|
  unit_data = unit_lookup.find_unit(unit['id'])
  if unit_data.nil?
    missing_units << unit['id']
    puts "  ❌ Unknown unit type: #{unit['id']}"
    next
  end
  unit_identifier = "#{unit['id'].upcase}_#{starship.name}_#{SecureRandom.hex(4)}"
  unit_obj = Units::BaseUnit.create!(
    name: unit['name'],
    unit_type: unit['id'],
    owner: space_x,
    identifier: unit_identifier,
    operational_data: unit_data
  )
  starship.install_unit(unit_obj)
  puts "  - Installed #{unit['name']} (#{unit['id']})"
end
if missing_units.any?
  puts "❌ ERROR: The following unit types are required but not defined in the system:"
  missing_units.each { |u| puts "  - #{u}" }
  exit 1
end

# 6. Load inventory
puts "\n6. Loading inventory..."

inventory = manifest['inventory'] || {}
unit_lookup = Lookup::UnitLookupService.new
craft_lookup = Lookup::CraftLookupService.new
rig_lookup = Lookup::RigLookupService.new if defined?(Lookup::RigLookupService)
modules_lookup = Lookup::ModuleLookupService.new if defined?(Lookup::ModuleLookupService)
item_lookup = Lookup::ItemLookupService.new

invalid_inventory = []
units_loaded = []
units_missing = []

inventory.each do |category, items|
  next unless items.is_a?(Array)
  items.each do |item_config|
    count = item_config['count'] || 1
    item_id = item_config['id']
    item_name = item_config['name'] || item_id
    case category
    when 'units'
      unit_data = unit_lookup.find_unit(item_id)
      if unit_data
        canonical_name = unit_data['name']
        puts "  ✓ Unit: #{canonical_name} (#{count}x)"
        begin
          starship.inventory.items.create!(
            name: canonical_name,
            amount: count,
            owner: space_x,
            metadata: { 'unit_type' => item_id }
          )
          units_loaded << {name: canonical_name, count: count}
        rescue ActiveRecord::RecordInvalid => e
          puts "    ✗ Failed to add unit item: #{canonical_name} (#{e.message})"
          invalid_inventory << {category: 'unit', name: canonical_name, error: e.message}
        end
      else
        puts "  ✗ Unit definition NOT FOUND for #{item_name} (#{item_id}), skipping."
        units_missing << {name: item_name, count: count}
        invalid_inventory << {category: 'unit', name: item_name, error: "Missing operational data"}
      end
    when 'craft'
      craft_data = craft_lookup.find_craft(item_id)
      if craft_data && craft_data['name']
        canonical_name = craft_data['name']
        puts "  ✓ Craft: #{canonical_name} (#{count}x)"
      else
        canonical_name = item_name
        puts "  ✗ Craft definition NOT FOUND for #{item_name} (#{item_id}), using manifest name."
        invalid_inventory << {category: 'craft', name: item_name, error: "Missing operational data"}
      end
      begin
        starship.inventory.items.create!(
          name: canonical_name,
          amount: count,
          owner: space_x,
          metadata: { 'craft_type' => item_id }
        )
      rescue ActiveRecord::RecordInvalid => e
        puts "    ✗ Failed to add craft item: #{canonical_name} (#{e.message})"
        invalid_inventory << {category: 'craft', name: canonical_name, error: e.message}
      end
    when 'rigs'
      rig_data = rig_lookup&.find_rig(item_id)
      if rig_data && rig_data['name']
        canonical_name = rig_data['name']
        puts "  ✓ Rig: #{canonical_name} (#{count}x)"
      else
        canonical_name = item_name
        puts "  ✗ Rig definition NOT FOUND for #{item_name} (#{item_id}), using manifest name."
        invalid_inventory << {category: 'rig', name: item_name, error: "Missing operational data"}
      end
      begin
        starship.inventory.items.create!(
          name: canonical_name,
          amount: count,
          owner: space_x,
          metadata: { 'rig_type' => item_id }
        )
      rescue ActiveRecord::RecordInvalid => e
        puts "    ✗ Failed to add rig item: #{canonical_name} (#{e.message})"
        invalid_inventory << {category: 'rig', name: canonical_name, error: e.message}
      end
    when 'modules'
      module_data = modules_lookup&.find_module(item_id)
      if module_data && module_data['name']
        canonical_name = module_data['name']
        puts "  ✓ Module: #{canonical_name} (#{count}x)"
      else
        canonical_name = item_name
        puts "  ✗ Module definition NOT FOUND for #{item_name} (#{item_id}), using manifest name."
        invalid_inventory << {category: 'module', name: item_name, error: "Missing operational data"}
      end
      begin
        starship.inventory.items.create!(
          name: canonical_name,
          amount: count,
          owner: space_x,
          metadata: { 'module_type' => item_id }
        )
      rescue ActiveRecord::RecordInvalid => e
        puts "    ✗ Failed to add module item: #{canonical_name} (#{e.message})"
        invalid_inventory << {category: 'module', name: canonical_name, error: e.message}
      end
    when 'supplies', 'consumables'
      item_data = item_lookup.find_item(item_id)
      if item_data && item_data['name']
        canonical_name = item_data['name']
        puts "  ✓ #{category.singularize.capitalize}: #{canonical_name} (#{count}x)"
      else
        canonical_name = item_name
        puts "  ✗ #{category.singularize.capitalize} definition NOT FOUND for #{item_name} (#{item_id}), using manifest name."
        invalid_inventory << {category: category, name: item_name, error: "Missing item data"}
      end
      begin
        starship.inventory.items.create!(
          name: canonical_name,
          amount: count,
          owner: space_x,
          metadata: { "#{category.singularize}_type" => item_id }
        )
      rescue ActiveRecord::RecordInvalid => e
        puts "    ✗ Failed to add #{category.singularize} item: #{canonical_name} (#{e.message})"
        invalid_inventory << {category: category, name: canonical_name, error: e.message}
      end
    else
      puts "  ✓ Item: #{item_name} (#{count}x)"
      begin
        starship.inventory.items.create!(
          name: item_name,
          amount: count,
          owner: space_x
        )
      rescue ActiveRecord::RecordInvalid => e
        puts "    ✗ Failed to add item: #{item_name} (#{e.message})"
        invalid_inventory << {category: 'item', name: item_name, error: e.message}
      end
    end
  end
end

if invalid_inventory.any?
  puts "\n❌ ERROR: Invalid inventory items detected:"
  invalid_inventory.each do |inv|
    puts "  - [#{inv[:category]}] #{inv[:name]}: #{inv[:error]}"
  end
  exit 1
end

# 7. Validate units
puts "\n7. Validation Results:"
puts "  Units loaded successfully: #{units_loaded.size}"
units_loaded.each { |unit| puts "    - #{unit[:name]} (#{unit[:count]}x)" }
puts "\n  Units missing definitions: #{units_missing.size}"
units_missing.each { |unit| puts "    - #{unit[:name]} (#{unit[:count]}x)" }

# 8. Calculate volume and mass
puts "\n8. Calculating Cargo Metrics..."
total_volume = 0
total_mass = 0
starship.inventory.items.each do |item|
  unit_data = unit_lookup.find_unit(item.name.split('#').first.strip.downcase.gsub(" ", "_"))
  if unit_data
    volume = unit_data['volume'] || 1.0
    mass = unit_data['mass'] || 100.0
    total_volume += volume * item.amount
    total_mass += mass * item.amount
  end
end
puts "  Total Volume: #{total_volume.round(2)} m³"
puts "  Total Mass: #{total_mass.round(2)} kg"

# 9. Verify tasks can be executed with available units
puts "\n9. Verifying Task Dependencies..."
executable_tasks = []
blocked_tasks = []
task_list.each do |task|
  next unless task['task_id']
  puts "  Checking task: #{task['task_id']}"
  units_required = []
  if task['effects']
    task['effects'].each do |effect|
      if effect['action'] == 'deploy_unit'
        units_required << effect['unit']
      end
    end
  end
  missing_units = units_required.reject do |unit_name|
    units_loaded.any? { |u| u[:name] == unit_name }
  end
  if missing_units.empty?
    executable_tasks << task['task_id']
    puts "    ✓ Task executable - all required units available"
  else
    blocked_tasks << {task_id: task['task_id'], missing_units: missing_units}
    puts "    ✗ Task blocked - missing units: #{missing_units.join(', ')}"
  end
end
puts "\n10. Task Execution Summary:"
puts "  Executable tasks: #{executable_tasks.size}/#{task_list.count { |t| t['task_id'] }}"
puts "  Blocked tasks: #{blocked_tasks.size}/#{task_list.count { |t| t['task_id'] }}"

# 11. Simulate task/phase execution
puts "\n11. Simulating Task Execution..."
profile['phases'].each do |phase|
  puts "\nPhase: #{phase['name']}"
  phase['tasks'].each do |task_id|
    task = task_list.find { |t| t['task_id'] == task_id }
    next unless task
    puts "  Executing task: #{task['description']}"
    # Simulate effects (e.g., deploy_unit, connect_units, set_unit_state)
    # Update state as needed
    # Log results
  end
end

puts "\n✅ Starship Precursor Mission Integration Test Complete!"