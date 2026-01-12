# scripts/test_craft_creation.rb
require 'rails_helper'

# Find or create the Celestial Location (Lunar Surface)
lunar_surface = Location::CelestialLocation.find_or_create_by(name: 'Lunar Surface') do |location|
  location.coordinates = "#{SecureRandom.hex(4)}°N #{SecureRandom.hex(4)}°E"
  # ... other celestial location attributes if needed
end

# Create the Spatial Location (only if the craft is in orbit or moving on the surface)
# If the craft is stationary on the surface, comment this out.
# lunar_surface_spatial = Location::SpatialLocation.create(
#   name: "Starship Location",
#   x_coordinate: 0,
#   y_coordinate: 0,
#   z_coordinate: 0,
#   spatial_context: lunar_surface # Link to the celestial location
# )

# Create the Starship, linking it to the appropriate Location
starship = Craft::BaseCraft.new(
  name: 'Starship',
  craft_name: 'Starship',
  craft_type: 'spaceship',
  owner: nil, # Or your appropriate owner
  location: lunar_surface # Use lunar_surface or lunar_surface_spatial
)

# Load Craft data
starship.load_craft_info

# Build units and modules (if needed)
starship.build_units_and_modules

# Save the Starship
if starship.save
  puts "Starship created successfully:"
  puts starship.inspect
  puts "Craft Info:"
  puts starship.craft_info.inspect
  puts "Total Mass: #{starship.total_mass}"
  puts "Power Usage: #{starship.power_usage}"
  puts "Input Resources: #{starship.input_resources.inspect}"
  puts "Output Resources: #{starship.output_resources.inspect}"
  puts "Storage Capacity: #{starship.storage_capacity}"
  puts "Available Storage: #{starship.available_storage}"

  # Example of adding items to inventory (if you have inventory set up)
  # water = Item.find_or_create_by(name: "Water", material_type: "consumable", storage_method: "bulk_storage")
  # starship.inventory.add_item(water, 100)
  # puts "Inventory: #{starship.inventory.items.inspect}"

  # Example of docking
  # settlement = Settlement::BaseSettlement.first # Or find a specific settlement
  # if starship.dock(settlement)
  #   puts "Starship docked at #{settlement.name}"
  # end

else
  puts "Error creating Starship:"
  puts starship.errors.full_messages
end

# Querying for the craft
found_starship = Craft::BaseCraft.find_by(craft_name: 'Starship')
if found_starship
    puts "Found Starship:"
    puts found_starship.inspect
end
