require_relative '../../config/environment'
require 'securerandom'

puts "\nStarting Starship Build Test..."

# Step 1: Ensure Earth exists
puts "\n1. Setting up Earth..."
earth = CelestialBodies::TerrestrialPlanet.find_by(name: 'Earth')
puts "Earth created/found with ID: #{earth.identifier}"

# Step 2: Create Kennedy Space Center location
puts "\n2. Creating Earth Location..."
earth_location = Location::CelestialLocation.find_or_create_by!(
  name: "Kennedy Space Center",
  coordinates: "28.57°N 80.65°W",
  celestial_body: earth
)
puts "Location created: #{earth_location.name}"

# Step 3: Create organization first
puts "\n3. Creating Organization..."
space_x = Organizations::BaseOrganization.find_or_create_by!(
  name: 'AstroLift Corporation',
  identifier: 'ASTROLIFT',
  organization_type: :corporation
)
puts "Organization created: #{space_x.name}"

# Step 4: Create and verify starship
puts "\n4. Creating Basic Starship..."

# Debug lookup service first
puts "\n4. Checking craft lookup service..."
lookup_service = Lookup::CraftLookupService.new

# Debug paths
puts "\nChecking lookup paths:"
puts "Base path: #{Lookup::CraftLookupService::BASE_PATH}"
puts "Available categories: #{Lookup::CraftLookupService::CATEGORIES.keys}"

# Try lookup with different variations
variants = [
  ["Starship (Lunar Variant)", "transport", "spaceship"],
  ["starship_lunar", "transport", "spaceship"],
  ["starship", "transport", "spaceship"]
]

variants.each do |name, type, subtype|
  puts "\nTrying lookup with:"
  puts "  Name: #{name}"
  puts "  Type: #{type}"
  puts "  Subtype: #{subtype}"
  
  craft_data = lookup_service.find_craft(name, type, subtype)
  puts "  Result: #{craft_data ? 'Found' : 'Not Found'}"
end

# Create starship using lunar variant
puts "\n5. Creating Lunar Variant Starship..."
starship = space_x.owned_crafts.create!(
  name: "Starship #{SecureRandom.hex(4)}",
  craft_name: "starship_lunar",  # Use lunar variant name that worked in lookup
  craft_type: "transport",
  current_location: earth_location
)

# Verify creation and units (already built by after_create callback)
puts "\n6. Checking Starship Status..."
puts "Basic Info:"
puts "  ID: #{starship.id}"
puts "  Name: #{starship.name}"
puts "  Type: #{starship.craft_type}"
puts "  Owner: #{starship.owner.name}"

# Force reload and check operational data
starship.reload
puts "\nOperational Data Status:"
if starship.operational_data.present?
  puts "  Data Present: Yes"
  puts "  Name: #{starship.operational_data['name']}"
  puts "  Units Count: #{starship.operational_data['recommended_units']&.count || 0}"
else
  puts "  ERROR: No operational data loaded"
end

# Remove explicit build_units_and_modules call since it's handled by after_create
puts "\nUnit Count by Type:"
starship.base_units.group_by(&:unit_type).each do |type, units|
  puts "  #{type}: #{units.count} units"
end

# Step 7: Verify specific units
puts "\n7. Verifying Key Units..."
{
  'lox_tank' => 150000,
  'methane_tank' => 100000,
  'starship_habitat_unit' => nil
}.each do |unit_type, expected_capacity|
  unit = starship.base_units.find_by(unit_type: unit_type)
  puts "\n#{unit_type.titleize}:"
  if unit
    puts "  Found: Yes"
    puts "  Name: #{unit.name}"
    if expected_capacity
      actual_capacity = unit.operational_data&.dig('storage', 'capacity')
      puts "  Capacity: #{actual_capacity} (Expected: #{expected_capacity})"
    end
  else
    puts "  Found: No"
  end
end

# Step 8: Verify capabilities
puts "\n8. Checking Capabilities..."
puts "Population Capacity: #{starship.total_capacity}"
puts "Power Usage: #{starship.power_usage}"
puts "Total Mass: #{starship.total_mass}"

# Step 9: Check inventory setup
puts "\n9. Verifying Inventory..."
if starship.inventory
  puts "Inventory created successfully"
  puts "Items count: #{starship.inventory.items.count}"
else
  puts "No inventory present"
end