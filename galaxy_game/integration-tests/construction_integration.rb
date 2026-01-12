require 'securerandom'

puts "\nStarting Construction Integration Test..."

# 1. Setup lunar location with updated namespace
puts "\n1. Setting up lunar location..."
moon = CelestialBody.find_or_create_by!(
  name: 'Luna',
  celestial_body_type: 'terrestrial_planet',
  identifier: 'LUNA-SOL-3-1'
)

crater_location = Location.find_or_create_by!(
  name: "Shackleton Crater",
  coordinates: "89.9°S 0.0°E",
  celestial_body: moon
)

lava_tube_location = Location.find_or_create_by!(
  name: "Marius Hills Lava Tube",
  coordinates: "14.1°N 56.8°W",
  celestial_body: moon
)

# 2. Create player and settlement
puts "\n2. Creating player and settlement..."
player = Player.find_or_create_by!(username: "TestCommander")
settlement = Settlement.find_or_create_by!(
  name: "Integration Test Base",
  owner: player,
  current_population: 10,
  location: crater_location
)

# Ensure settlement has an inventory
unless settlement.inventory
  settlement.create_inventory!
end

# 3. Add resources to settlement
puts "\n3. Adding resources to settlement inventory..."
resources = {
  "processed_regolith" => 5000,
  "metal_extract" => 2000,
  "silicate_extract" => 1500,
  "3d_printed_ibeams" => 100,
  "transparent_panels" => 50,
  "structural_panels" => 30,
  "fasteners" => 500,
  "sealant" => 200
}

resources.each do |resource, amount|
  item = settlement.inventory.items.find_or_create_by!(name: resource)
  item.update!(quantity: amount)
  puts "  Added #{amount} #{resource} to inventory"
end

# 4. Create a crater dome
puts "\n4. Creating a crater dome..."
crater_dome = Structures::CraterDome.create!(
  name: "Test Crater Dome",
  diameter: 100.0,
  depth: 20.0,
  location: crater_location,
  settlement: settlement,
  status: "planned"
)
puts "  Created dome: #{crater_dome.name}"

# 5. Create a lava tube and skylight
puts "\n5. Creating a lava tube and skylight..."
lava_tube = CelestialBodies::Features::LavaTube.create!(
  name: "Test Lava Tube",
  static_data: {
    "dimensions" => {
      "length_m" => 500.0,
      "width_m" => 50.0,
      "height_m" => 30.0
    },
    "attributes" => {
      "natural_shielding" => "moderate",
      "thermal_stability" => "high"
    },
    "conversion_suitability" => {
      "habitat" => "excellent"
    }
  },
  celestial_body: moon,
  location: lava_tube_location
)

skylight = Structures::Skylight.create!(
  name: "Test Skylight",
  diameter: 25.0,
  position: 250.0,  # Middle of the tube
  lava_tube: lava_tube,
  status: "uncovered"
)

puts "  Created lava tube: #{lava_tube.name}"
puts "  Created skylight: #{skylight.name}"

# 6. Create Construction Jobs
puts "\n6. Creating construction jobs..."
dome_job = ConstructionJob.create!(
  job_type: 'crater_dome_construction',
  status: 'scheduled',
  settlement: settlement,
  jobable: crater_dome,  # Already using jobable here
  priority: 'high'
)

skylight_job = ConstructionJob.create!(
  job_type: 'skylight_cover',
  status: 'scheduled', 
  settlement: settlement,
  jobable: skylight,     # Already using jobable here
  priority: 'medium'
)

puts "  Created dome construction job: ##{dome_job.id}"
puts "  Created skylight construction job: ##{skylight_job.id}"

# 7. Create Material Requests
puts "\n7. Creating material requests..."
dome_materials = {
  "processed_regolith" => 2000,
  "metal_extract" => 800,
  "silicate_extract" => 500,
  "3d_printed_ibeams" => 40,
  "structural_panels" => 20,
  "fasteners" => 200,
  "sealant" => 100
}

skylight_materials = {
  "processed_regolith" => 500,
  "transparent_panels" => 30,
  "fasteners" => 100,
  "sealant" => 50
}

dome_materials.each do |material, amount|
  dome_job.material_requests.create!(
    material_name: material,
    quantity_requested: amount,
    status: 'pending'
  )
  puts "  Added dome material request: #{amount} #{material}"
end

skylight_materials.each do |material, amount|
  skylight_job.material_requests.create!(
    material_name: material,
    quantity_requested: amount,
    status: 'pending'
  )
  puts "  Added skylight material request: #{amount} #{material}"
end

# 8. Simulate construction process
puts "\n8. Simulating construction process..."

# Update material requests to fulfilled if we have the materials
[dome_job, skylight_job].each do |job|
  job.material_requests.each do |request|
    item = settlement.inventory.items.find_by(name: request.material_name)
    
    if item && item.quantity >= request.quantity_requested
      request.update!(status: 'fulfilled')
      item.update!(quantity: item.quantity - request.quantity_requested)
      puts "  Fulfilled request: #{request.quantity_requested} #{request.material_name}"
    else
      puts "  Insufficient materials for: #{request.quantity_requested} #{request.material_name}"
    end
  end
  
  # Update job status if all materials are fulfilled
  if job.material_requests.all? { |req| req.status == 'fulfilled' }
    job.update!(status: 'in_progress')
    puts "  Job ##{job.id} now in progress"
    
    # Simulate completion after a short delay
    job.update!(status: 'completed')
    
    # Update the structure status
    if job.jobable_type == 'Structures::CraterDome'  # Changed from constructable_type to jobable_type
      job.jobable.update!(status: 'operational')     # Changed from constructable to jobable
      puts "  Dome construction completed"
    elsif job.jobable_type == 'Structures::Skylight' # Changed from constructable_type to jobable_type
      job.jobable.update!(status: 'covered')         # Changed from constructable to jobable
      puts "  Skylight construction completed"
    end
  else
    puts "  Job ##{job.id} waiting for materials"
  end
end

# 9. Check construction status
puts "\n9. Checking construction status..."
crater_dome.reload
skylight.reload
puts "  Crater Dome status: #{crater_dome.status}"
puts "  Skylight status: #{skylight.status}"

# 10. Check material usage
puts "\n10. Checking material usage..."
puts "  Resources remaining:"
resources.each do |resource, original_amount|
  item = settlement.inventory.items.find_by(name: resource)
  current_amount = item ? item.quantity : 0
  puts "    - #{resource}: #{current_amount} (used: #{original_amount - current_amount})"
end

puts "\nConstruction Integration Test Complete!"