require 'securerandom'
require 'json'

puts "\nStarting Starship Customization and Verification..."

# 1. Setup Game World (as before)
puts "\n1. Setting up Earth..."
earth = CelestialBodies::TerrestrialPlanet.find_by(name: 'Earth')
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

# 2. Load Starship Configuration from JSON
puts "\n4. Loading Starship Configuration from precursor_mission_autonomous_setup_v1.json..."
manifest_path = File.join(File.dirname(__FILE__), 'precursor_mission_autonomous_setup_v1.json')
begin
  manifest_data = JSON.parse(File.read(manifest_path))
  starship_config = manifest_data['starship'] # Adjust this to the correct key in your file
  puts "Configuration loaded from #{manifest_path}"
rescue Errno::ENOENT
  puts "Error: Manifest file not found at #{manifest_path}"
  exit
rescue JSON::ParserError => e
  puts "Error: Invalid JSON in manifest file: #{e.message}"
  exit
end

# 3. Create Starship with Configuration
puts "\n5. Creating Customized Starship..."
starship_name = "CustomStarship-#{SecureRandom.hex(4)}"
starship = space_x.owned_crafts.create!(
  name: starship_name,
  craft_name: starship_config['craft_name'], # Use craft name from config
  craft_type: 'transport', #  Hardcode
  current_location: earth_location
)

puts "Starship created: #{starship.name} (ID: #{starship.id})"

# 4. Build Units and Modules from Configuration
puts "\n6. Building Units and Modules from Configuration..."

# Function to calculate volume (m^3)
def calculate_volume(unit_data)
  length = unit_data['operational_data']&.[]('length') || 1
  width  = unit_data['operational_data']&.[]('width')  || 1
  height = unit_data['operational_data']&.[]('height') || 1
  length * width * height
end

# Function to calculate mass
def calculate_mass(unit_data)
   density = unit_data['operational_data']&.[]('density') || 1000 # kg/m^3
   volume = calculate_volume(unit_data)
   density * volume
end

total_volume = 0
total_mass   = 0

if starship_config['units']
  starship_config['units'].each do |unit_data|
    (unit_data['count'] || 1).times do |i|
      unit_name = "#{unit_data['name']}-#{i+1}"
      unit = starship.base_units.create!(
        name:       unit_name,
        unit_type:  unit_data['type'], # Get type from config
        operational_data: unit_data['operational_data']
      )
      puts "  Created Unit: #{unit.name} (#{unit.unit_type})"

      # Calculate volume and mass
      volume = calculate_volume(unit_data)
      mass   = calculate_mass(unit_data)
      total_volume += volume
      total_mass   += mass

      puts "    Volume: #{volume.round(2)} m^3, Mass: #{mass.round(2)} kg"
    end
  end
end

puts "\n  Total Starship Volume: #{total_volume.round(2)} m^3"
puts "\n  Total Starship Mass: #{total_mass.round(2)} kg"

# 5. Verify Loaded Inventory
puts "\n7. Verifying Loaded Inventory..."
if starship_config['inventory'] && starship_config['inventory']['supplies']
  starship_config['inventory']['supplies'].each do |item|
    # Find or create inventory items
    inventory_item = starship.inventory.items.find_or_create_by!(name: item['name'])
    inventory_item.update(quantity: item['quantity'])
    puts "  #{item['name']}: #{inventory_item.quantity} added to inventory"
  end
  puts "Inventory verified and loaded."
else
  puts "No inventory specified in configuration."
end

# 8. Check Starship Capacity
puts "\n8. Checking Starship Capacity..."
# Assume capacity and cargo_mass are defined in starship or its units.
puts "  Total Capacity: #{starship.total_capacity} m^3"
puts "  Total Cargo Mass: #{starship.cargo_mass} kg"

if starship.total_capacity < total_volume
  puts "\n  ERROR:  Volume Exceeds Capacity!  #{total_volume} m^3 > #{starship.total_capacity} m^3"
else
  puts "\n  Volume within capacity."
end

if starship.cargo_mass && starship.max_cargo_mass && total_mass > starship.max_cargo_mass
  puts "\n  ERROR: Mass Exceeds Max Cargo Mass! #{total_mass} kg > #{starship.max_cargo_mass} kg"
else
  puts "\n  Mass within limits."
end

