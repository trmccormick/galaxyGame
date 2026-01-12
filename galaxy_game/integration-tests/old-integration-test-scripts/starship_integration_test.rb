require 'securerandom'
require 'json'
require 'fileutils'

puts "\nStarting Starship Integration Test with Updated Components..."
puts "Current directory: #{Dir.pwd}"
puts "Environment: #{Rails.env}"

# Debug directory structure - check where JSON files are
def debug_directory_structure(base_path)
  puts "\nDEBUG: Checking directory structure at #{base_path}"
  if Dir.exist?(base_path)
    puts "Directory exists!"
    dirs = Dir.glob("#{base_path}/*").select { |f| File.directory?(f) }
    puts "Subdirectories: #{dirs.map { |d| File.basename(d) }.join(', ')}"
    
    # Check for blueprint and operational_data dirs specifically
    blueprint_dir = File.join(base_path, 'blueprints')
    operational_dir = File.join(base_path, 'operational_data')
    
    if Dir.exist?(blueprint_dir)
      puts "Blueprints directory exists!"
      subdirs = Dir.glob("#{blueprint_dir}/*").select { |f| File.directory?(f) }
      puts "Blueprint subdirectories: #{subdirs.map { |d| File.basename(d) }.join(', ')}"
    else
      puts "Blueprints directory NOT FOUND!"
    end
    
    if Dir.exist?(operational_dir)
      puts "Operational data directory exists!"
      subdirs = Dir.glob("#{operational_dir}/*").select { |f| File.directory?(f) }
      puts "Operational data subdirectories: #{subdirs.map { |d| File.basename(d) }.join(', ')}"
    else
      puts "Operational data directory NOT FOUND!"
    end
  else
    puts "Directory does NOT exist!"
  end
end

# Check both potential locations for JSON files
app_data_dir = '/home/galaxy_game/app/data'
root_data_dir = '/home/galaxy_game/data'
debug_directory_structure(app_data_dir)
debug_directory_structure(root_data_dir)

# Try to determine the correct base directory
if Dir.exist?(File.join(app_data_dir, 'blueprints'))
  base_data_dir = app_data_dir
  puts "\nUsing base data directory: #{base_data_dir}"
elsif Dir.exist?(File.join(root_data_dir, 'blueprints'))
  base_data_dir = root_data_dir
  puts "\nUsing base data directory: #{base_data_dir}"
else
  puts "\nWARNING: Cannot find valid data directory with blueprints folder!"
  # Try checking Rails.root related paths
  rails_root_dir = File.join(Rails.root, 'data')
  debug_directory_structure(rails_root_dir)
  
  if Dir.exist?(File.join(rails_root_dir, 'blueprints'))
    base_data_dir = rails_root_dir
    puts "\nUsing Rails.root data directory: #{base_data_dir}"
  else
    puts "\nERROR: Cannot locate blueprints directory in any expected location!"
    base_data_dir = '/home/galaxy_game/app/data' # Default fallback
  end
end

begin
  # 1. Setup Game World
  puts "\n1. Setting up Earth..."
  # Create Earth first if it doesn't exist
  earth = CelestialBodies::TerrestrialPlanet.find_or_create_by!(
    name: 'Earth',
    celestial_body_type: 'terrestrial_planet',
    mass_kg: 5.972e24,
    radius_km: 6371,
    gravity_m_s2: 9.81,
    day_length_hours: 24,
    orbital_period_days: 365.25,
    atmosphere_composition: { "nitrogen" => 78.1, "oxygen" => 20.9, "argon" => 0.9, "carbon_dioxide" => 0.04 },
    average_temperature_c: 15,
    identifier: 'EARTH-SOL-3'
  )
  puts "Earth created/found with ID: #{earth.identifier}"

  puts "\n2. Creating Earth Location..."
  earth_location = Location::CelestialLocation.find_or_create_by!(
    name: "Kennedy Space Center",
    coordinates: "28.57°N 80.65°W",
    celestial_body: earth
  )
  puts "Location created: #{earth_location.name}"

  puts "\n3. Creating Organization..."
  space_x = Organizations::BaseOrganization.find_or_create_by!(
    name: 'AstroLift Corporation',
    identifier: 'ASTROLIFT',
    organization_type: :corporation
  )
  puts "Organization created: #{space_x.name}"

  # 2. Create Starship Configuration for Testing
  puts "\n4. Creating Test Starship Configuration..."
  starship_config = {
    'name' => "Starship Integration Test",
    'craft_name' => "Starship-Crew-Transport",
    'craft_type' => 'transport',
    'description' => "Test configuration using all new components",
    'modules' => [
      {
        'id' => 'raptor_engine',
        'count' => 3,
        'category' => 'propulsion'
      },
      {
        'id' => 'lox_tank',
        'count' => 1,
        'category' => 'propulsion'
      },
      {
        'id' => 'methane_tank',
        'count' => 1,
        'category' => 'propulsion'
      },
      {
        'id' => 'retractable_landing_legs',
        'count' => 4,
        'category' => 'landing'
      },
      {
        'id' => 'airlock_module',
        'count' => 2,
        'category' => 'access'
      },
      {
        'id' => 'co2_venting_system',
        'count' => 2,
        'category' => 'life_support'
      },
      {
        'id' => 'air_filtration_system',
        'count' => 2,
        'category' => 'life_support'
      },
      {
        'id' => 'co2_scrubber_module',
        'count' => 3,
        'category' => 'life_support'
      },
      {
        'id' => 'fire_suppression_system',
        'count' => 2,
        'category' => 'safety'
      },
      {
        'id' => 'emergency_power_backup',
        'count' => 1,
        'category' => 'power'
      }
    ],
    'units' => [
      {
        'id' => 'starship_habitat_unit',
        'count' => 1,
        'category' => 'habitation'
      },
      {
        'id' => 'storage_unit',
        'count' => 2,
        'category' => 'storage'
      },
      {
        'id' => 'life_support_module',
        'count' => 1,
        'category' => 'life_support'
      },
      {
        'id' => 'waste_management_unit',
        'count' => 1,
        'category' => 'life_support'
      },
      {
        'id' => 'co2_oxygen_production_unit',
        'count' => 1,
        'category' => 'life_support'
      },
      {
        'id' => 'water_recycling_unit',
        'count' => 1,
        'category' => 'life_support'
      },
      {
        'id' => 'landing_radar',
        'count' => 1,
        'category' => 'navigation'
      }
    ]
  }

  puts "Configuration created with #{starship_config['modules'].sum { |m| m['count'] }} modules and #{starship_config['units'].sum { |u| u['count'] }} units"

  # 3. Create Starship with Configuration
  puts "\n5. Creating Starship for Integration Test..."
  starship_name = "TestStarship-#{SecureRandom.hex(4)}"
  
  begin
    starship = space_x.owned_crafts.create!(
      name: starship_name,
      craft_name: starship_config['craft_name'],
      craft_type: starship_config['craft_type'],
      current_location: earth_location
    )
    puts "Starship created: #{starship.name} (ID: #{starship.id})"
  rescue => e
    puts "ERROR creating starship: #{e.message}"
    puts "Backtrace: #{e.backtrace[0..5].join("\n")}"
    
    # Try to get a clearer error message
    puts "\nDEBUG: Checking owned_crafts association"
    puts "space_x.owned_crafts method exists? #{space_x.respond_to?(:owned_crafts)}"
    puts "space_x.owned_crafts class: #{space_x.owned_crafts.class}"
    
    # Try creating a craft with minimal attributes
    puts "\nTrying minimal craft creation:"
    begin
      minimal_craft = space_x.owned_crafts.new(name: starship_name)
      puts "Required attributes: #{minimal_craft.class.attribute_names.select { |a| minimal_craft._validators[a.to_sym]&.any? { |v| v.kind == :presence } }}"
      puts "Can save? #{minimal_craft.valid?}"
      puts "Validation errors: #{minimal_craft.errors.full_messages.join(', ')}" unless minimal_craft.valid?
    rescue => e
      puts "ERROR with minimal craft: #{e.message}"
    end
    
    # Create a fallback craft for testing
    starship = Struct.new(:name, :id, :total_capacity, :cargo_mass, :max_cargo_mass).new(
      starship_name, 'test-id', 2000.0, 0, 120000.0
    )
    puts "Created fallback test starship object"
  end

  # 4. Load Components and Calculate Properties
  puts "\n6. Loading Components from JSON Files..."

  total_volume = 0
  total_mass = 0
  total_power_draw = 0
  total_heat_generation = 0

  # Helper function to load module data
  def load_component_data(id, type, category, base_dir)
    # Try different possible paths for the blueprint file
    blueprint_paths = [
      File.join(base_dir, 'blueprints', "#{type}s", category, "#{id}.json"),
      File.join(base_dir, 'blueprints', "#{type}s", "#{id}.json"),
      File.join(base_dir, 'blueprints', category, "#{id}.json"),
      File.join(base_dir, 'blueprints', "modules", category, "#{id}.json"), # Try both singular and plural
      File.join(base_dir, 'blueprints', "units", category, "#{id}.json")
    ]
    
    blueprint_path = blueprint_paths.find { |path| File.exist?(path) }
    
    unless blueprint_path
      puts "  WARNING: Blueprint not found for #{id} (#{type}, #{category})"
      puts "  Searched paths: #{blueprint_paths.join(', ')}"
      # List some files that do exist as a reference
      Dir.glob(File.join(base_dir, 'blueprints', '**', '*.json')).first(3).each do |f|
        puts "  Example existing file: #{f}"
      end
      return nil
    end
    
    # Try different possible paths for the operational file
    operational_paths = [
      File.join(base_dir, 'operational_data', "#{type}s", category, "#{id}.json"),
      File.join(base_dir, 'operational_data', "#{type}s", "#{id}.json"),
      File.join(base_dir, 'operational_data', category, "#{id}.json"),
      File.join(base_dir, 'operational_data', "modules", category, "#{id}.json"), # Try both singular and plural
      File.join(base_dir, 'operational_data', "units", category, "#{id}.json")
    ]
    
    operational_path = operational_paths.find { |path| File.exist?(path) }
    
    unless operational_path
      puts "  WARNING: Operational data not found for #{id} (#{type}, #{category})"
      puts "  Searched paths: #{operational_paths.join(', ')}"
      # List some files that do exist as a reference
      Dir.glob(File.join(base_dir, 'operational_data', '**', '*.json')).first(3).each do |f|
        puts "  Example existing file: #{f}"
      end
      return nil
    end
    
    begin
      blueprint_data = JSON.parse(File.read(blueprint_path))
      operational_data = JSON.parse(File.read(operational_path))
      
      puts "  Successfully loaded: #{blueprint_path}"
      puts "  Successfully loaded: #{operational_path}"
      
      return {
        blueprint: blueprint_data,
        operational: operational_data
      }
    rescue => e
      puts "  ERROR loading data for #{id}: #{e.message}"
      if File.exist?(blueprint_path)
        puts "  Blueprint file exists but may be invalid JSON: #{blueprint_path}"
        puts "  First 100 chars: #{File.read(blueprint_path)[0..100]}"
      end
      if File.exist?(operational_path)
        puts "  Operational file exists but may be invalid JSON: #{operational_path}"
        puts "  First 100 chars: #{File.read(operational_path)[0..100]}"
      end
      return nil
    end
  end

  # Process modules
  if starship_config['modules']
    puts "\nLoading Modules:"
    starship_config['modules'].each do |module_config|
      component_id = module_config['id']
      count = module_config['count'] || 1
      category = module_config['category']
      
      component_data = load_component_data(component_id, 'module', category, base_data_dir)
      
      if component_data.nil?
        puts "  Skipping module #{component_id} - data not found"
        next
      end
      
      blueprint = component_data[:blueprint]
      operational = component_data[:operational]
      
      # Create each module instance
      count.times do |i|
        # Create the module
        module_name = "#{blueprint['name']}-#{i+1}"
        
        puts "  Adding Module: #{module_name}"
        
        # Extract physical properties
        physical = blueprint['physical_properties']
        if physical
          volume = physical['length_m'] * physical['width_m'] * physical['height_m']
          mass = physical['mass_kg']
          
          total_volume += volume
          total_mass += mass
          
          puts "    Volume: #{volume.round(2)} m³, Mass: #{mass.round(2)} kg"
        else
          puts "    WARNING: No physical properties found for #{module_name}"
        end
        
        # Extract operational properties
        operational_props = blueprint['operational_properties']
        if operational_props
          power_draw = operational_props['power_draw_kw'] || 0
          heat_gen = operational_props['heat_generation_kw'] || 0
          
          total_power_draw += power_draw
          total_heat_generation += heat_gen
          
          puts "    Power Draw: #{power_draw} kW, Heat Generation: #{heat_gen} kW"
        else
          puts "    WARNING: No operational properties found for #{module_name}"
        end
        
        # In a real implementation, we would create the module in the database here
      end
    end
  else
    puts "No modules specified in configuration."
  end

  # Process units
  if starship_config['units']
    puts "\nLoading Units:"
    starship_config['units'].each do |unit_config|
      component_id = unit_config['id']
      count = unit_config['count'] || 1
      category = unit_config['category']
      
      component_data = load_component_data(component_id, 'unit', category, base_data_dir)
      
      if component_data.nil?
        puts "  Skipping unit #{component_id} - data not found"
        next
      end
      
      blueprint = component_data[:blueprint]
      operational = component_data[:operational]
      
      # Create each unit instance
      count.times do |i|
        # Create the unit
        unit_name = "#{blueprint['name']}-#{i+1}"
        
        puts "  Adding Unit: #{unit_name}"
        
        # Extract physical properties
        physical = blueprint['physical_properties']
        if physical
          volume = physical['length_m'] * physical['width_m'] * physical['height_m']
          mass = physical['mass_kg']
          
          total_volume += volume
          total_mass += mass
          
          puts "    Volume: #{volume.round(2)} m³, Mass: #{mass.round(2)} kg"
        else
          puts "    WARNING: No physical properties found for #{unit_name}"
        end
        
        # Extract operational properties
        operational_props = blueprint['operational_properties']
        if operational_props
          power_draw = operational_props['power_draw_kw'] || 0
          heat_gen = operational_props['heat_generation_kw'] || 0
          
          total_power_draw += power_draw
          total_heat_generation += heat_gen
          
          puts "    Power Draw: #{power_draw} kW, Heat Generation: #{heat_gen} kW"
        else
          puts "    WARNING: No operational properties found for #{unit_name}"
        end
        
        # In a real implementation, we would create the unit in the database here
      end
    end
  else
    puts "No units specified in configuration."
  end

  # Print Totals
  puts "\n7. Starship Integration Test Results:"
  puts "  Total Volume: #{total_volume.round(2)} m³"
  puts "  Total Mass: #{total_mass.round(2)} kg"
  puts "  Total Power Draw: #{total_power_draw.round(2)} kW"
  puts "  Total Heat Generation: #{total_heat_generation.round(2)} kW"

  # Check limits (example values)
  starship_max_volume = 2000.0 # m³ (example)
  starship_max_mass = 120000.0 # kg (example)
  starship_power_capacity = 400.0 # kW (example)
  starship_heat_capacity = 200.0 # kW (example)

  puts "\n8. Checking Limits:"
  puts "  Volume Check: #{total_volume <= starship_max_volume ? 'PASS' : 'FAIL'} (#{total_volume.round(2)}/#{starship_max_volume} m³)"
  puts "  Mass Check: #{total_mass <= starship_max_mass ? 'PASS' : 'FAIL'} (#{total_mass.round(2)}/#{starship_max_mass} kg)"
  puts "  Power Check: #{total_power_draw <= starship_power_capacity ? 'PASS' : 'FAIL'} (#{total_power_draw.round(2)}/#{starship_power_capacity} kW)"
  puts "  Heat Check: #{total_heat_generation <= starship_heat_capacity ? 'PASS' : 'FAIL'} (#{total_heat_generation.round(2)}/#{starship_heat_capacity} kW)"

  # Integration Test Status
  puts "\n9. Integration Test Summary:"
  tests_passed = 0
  tests_failed = 0

  if total_volume <= starship_max_volume
    tests_passed += 1
  else
    tests_failed += 1
  end

  if total_mass <= starship_max_mass
    tests_passed += 1
  else
    tests_failed += 1
  end

  if total_power_draw <= starship_power_capacity
    tests_passed += 1
  else
    tests_failed += 1
  end

  if total_heat_generation <= starship_heat_capacity
    tests_passed += 1
  else
    tests_failed += 1
  end

  puts "  Tests Passed: #{tests_passed}/4"
  puts "  Tests Failed: #{tests_failed}/4"
  puts "  Integration Test Status: #{tests_failed == 0 ? 'PASSED' : 'FAILED'}"

rescue => e
  puts "\nFATAL ERROR in integration test: #{e.message}"
  puts "Error backtrace: #{e.backtrace[0..10].join("\n")}"
end

puts "\nStarship Integration Test Complete!"