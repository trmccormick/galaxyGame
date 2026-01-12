require 'securerandom'

puts "\nStarting Resource Acquisition Test..."

# 1. Setup lunar location with updated namespace
puts "\n1. Setting up lunar location..."
moon = CelestialBody.find_or_create_by!(
  name: 'Luna',
  celestial_body_type: 'terrestrial_planet',
  identifier: 'LUNA-SOL-3-1'
)

# Add atmosphere data for Moon
unless moon.atmosphere
  moon.create_atmosphere!(
    composition: {
      "oxygen" => 0.0,
      "nitrogen" => 0.0,
      "argon" => 0.0,
      "helium" => 0.2, # trace amounts
      "hydrogen" => 0.1 # trace amounts
    },
    pressure: 0.000000001, # Near vacuum
    temperature_range: { "min" => -173, "max" => 127 }
  )
end

# Add surface composition
unless moon.surface_composition
  moon.update!(
    surface_composition: {
      "lunar_regolith" => 90.0,
      "iron" => 5.0,
      "titanium" => 1.0,
      "aluminum" => 2.0,
      "silicon" => 2.0
    }
  )
end

crater_location = Location.find_or_create_by!(
  name: "Shackleton Crater",
  coordinates: "89.9°S 0.0°E",
  celestial_body: moon
)

# 2. Create player and settlement
puts "\n2. Creating player and settlement..."
player = Player.find_or_create_by!(username: "ResourceCommander")
settlement = Settlement.find_or_create_by!(
  name: "Resource Test Base",
  owner: player,
  current_population: 5,
  location: crater_location,
  credits: 1000000 # Give enough credits for purchasing
)

# Ensure settlement has an inventory
unless settlement.inventory
  settlement.create_inventory!
end

# 3. Add harvesting units to settlement
puts "\n3. Adding harvesting units to settlement..."
harvester_units = [
  { name: "Lunar Regolith Harvester", unit_type: "lunar_regolith_harvester" },
  { name: "Mineral Harvester", unit_type: "mineral_harvester" },
  { name: "Ice Harvester", unit_type: "lunar_ice_harvester" },
  { name: "Regolith Processor", unit_type: "regolith_oxygen_extractor" },
  { name: "Metal Processor", unit_type: "metal_processor" }
]

harvester_units.each do |unit_data|
  unit = Units::BaseUnit.create!(
    name: unit_data[:name],
    unit_type: unit_data[:unit_type],
    status: "idle",
    settlement: settlement
  )
  puts "  Added unit: #{unit.name} (#{unit.unit_type})"
end

# 4. Initialize the ResourceAcquisitionService
puts "\n4. Initializing ResourceAcquisitionService..."
resource_service = Resource::Acquisition.new(settlement)
puts "  Service initialized"

# 5. Test harvesting local resources
puts "\n5. Testing local resource harvesting..."
local_resources = ["Lunar Regolith", "Iron", "Aluminum", "Silicon"]

local_resources.each do |resource|
  puts "  Attempting to harvest #{resource}..."
  result = resource_service.acquire_resource(resource, 100)
  
  if result[:success]
    puts "    ✓ Successfully initiated harvesting of #{resource} using #{result[:method]}"
    puts "    Estimated completion time: #{result[:eta] / 1.hour} hours"
  else
    puts "    ✗ Failed to initiate harvesting of #{resource}"
  end
end

# 6. Test processing resources
puts "\n6. Testing resource processing..."
processed_resources = ["Oxygen", "Water", "Steel"]

# Add some materials needed for processing
settlement.inventory.items.create!(name: "Lunar Regolith", quantity: 500)
settlement.inventory.items.create!(name: "Lunar Ice", quantity: 100)
settlement.inventory.items.create!(name: "Iron", quantity: 50)
settlement.inventory.items.create!(name: "Carbon", quantity: 10)

processed_resources.each do |resource|
  puts "  Attempting to process #{resource}..."
  result = resource_service.acquire_resource(resource, 50)
  
  if result[:success]
    puts "    ✓ Successfully initiated processing of #{resource} using #{result[:method]}"
    puts "    Estimated completion time: #{result[:eta] / 1.hour} hours"
  else
    puts "    ✗ Failed to initiate processing of #{resource}"
  end
end

# 7. Test Earth imports
puts "\n7. Testing Earth imports..."
earth_imports = ["Electronics", "Medical Supplies", "Glass", "Food"]

earth_imports.each do |resource|
  puts "  Attempting to import #{resource} from Earth..."
  result = resource_service.acquire_resource(resource, 25, :high)
  
  if result[:success]
    puts "    ✓ Successfully initiated import of #{resource} using #{result[:method]}"
    puts "    Estimated delivery time: #{result[:eta] / 1.day} days"
    puts "    Cost: #{result[:job].job_data['import_cost']} credits"
  else
    puts "    ✗ Failed to initiate import of #{resource}"
  end
end

# 8. Test contracted harvesting
puts "\n8. Testing contracted harvesting..."
contracted_resources = ["Methane", "Nitrogen", "Hydrogen"]

contracted_resources.each do |resource|
  puts "  Attempting to contract harvesting of #{resource}..."
  result = resource_service.acquire_resource(resource, 200)
  
  if result[:success]
    puts "    ✓ Successfully contracted harvesting of #{resource} using #{result[:method]}"
    puts "    Source location: #{result[:job].job_data['source_location']}"
    puts "    Estimated delivery time: #{result[:eta] / 1.day} days"
    puts "    Cost: #{result[:job].job_data['contract_cost']} credits"
  else
    puts "    ✗ Failed to contract harvesting of #{resource}"
  end
end

# 9. Process some jobs to completion for testing
puts "\n9. Processing some jobs to completion..."
completed_jobs = 0

# Find the shortest job to complete
shortest_job = ResourceJob.where(status: 'in_progress').order(:estimated_completion).first
if shortest_job
  puts "  Completing job: #{shortest_job.job_type} for #{shortest_job.resource_type}"
  ResourceJobProcessor.complete_job(shortest_job)
  completed_jobs += 1
  
  # Check if resource was added to inventory
  item = settlement.inventory.items.find_by(name: shortest_job.resource_type)
  if item
    puts "    ✓ Resource added to inventory: #{item.quantity} #{item.name}"
  else
    puts "    ✗ Resource not found in inventory"
  end
else
  puts "  No jobs to complete"
end

# 10. Check settlement status
puts "\n10. Checking settlement status..."
puts "  Resources in inventory:"
settlement.inventory.items.each do |item|
  puts "    - #{item.name}: #{item.quantity}"
end

puts "  Active jobs:"
ResourceJob.where(status: 'in_progress').each do |job|
  puts "    - #{job.job_type} for #{job.resource_type} (ETA: #{job.estimated_completion.strftime('%Y-%m-%d %H:%M')})"
end

puts "  Credits remaining: #{settlement.reload.credits}"

puts "\nResource Acquisition Test Complete!"