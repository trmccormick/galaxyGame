require 'json'

puts "\nStarting AI Manager Basic Test..."

# 1. Setup mission environment with updated namespace
puts "\n1. Setting up mission environment..."
moon = CelestialBody.find_or_create_by!(
  name: 'Luna',
  celestial_body_type: 'terrestrial_planet',
  identifier: 'LUNA-SOL-3-1'
)

landing_site = Location.find_or_create_by!(
  name: "South Pole Landing Site",
  coordinates: "89.0°S 0.0°E",
  celestial_body: moon
)

# 1. Load the precursor mission manifest
puts "\n1. Loading precursor mission manifest..."
manifest_path = File.join(GalaxyGame::Paths::JSON_DATA, 'manifests', 'missions', 'precursor_mission_autonomous_setup_v1.json')
begin
  manifest = JSON.parse(File.read(manifest_path))
  puts "Manifest loaded successfully: #{manifest['mission_id']}"
rescue => e
  puts "ERROR: Failed to load manifest: #{e.message}"
  exit
end

# 3. Create player and settlement for AI to manage
puts "\n3. Creating player and settlement..."
player = Player.find_or_create_by!(username: "AI_Commander")
settlement = Settlement.find_or_create_by!(
  name: "Precursor Mission Base",
  owner: player,
  current_population: 0, # No humans yet
  location: landing_site
)

# Ensure settlement has an inventory
unless settlement.inventory
  settlement.create_inventory!
end

# 4. Create Starship with cargo from manifest
puts "\n4. Creating mission starship..."
starship_config = manifest['starship']
starship = Craft::Starship.create!(
  name: starship_config['name'] || "Precursor Starship",
  craft_name: starship_config['craft_name'],
  craft_type: starship_config['craft_type'],
  craft_sub_type: starship_config['craft_sub_type'],
  current_location: landing_site,
  owner: player
)

# Create inventory for starship
unless starship.inventory
  starship.create_inventory!
end

# Add units to starship inventory
manifest['inventory']['units'].each do |unit_config|
  unit_name = unit_config['name']
  count = unit_config['count'] || 1
  
  count.times do |i|
    starship.inventory.items.create!(
      name: "#{unit_name} ##{i+1}",
      item_type: 'unit',
      quantity: 1
    )
  end
  
  puts "  Added #{count}x #{unit_name} to starship"
end

# 5. Create AI Manager
puts "\n5. Creating AI Manager instance..."
ai_manager = AIManager::BaseManager.new(settlement)
puts "  AI Manager created for settlement: #{settlement.name}"

# 6. Create a simple construction plan for testing
puts "\n6. Creating basic construction plan..."
construction_plan = {
  'plan_name' => 'Initial Base Setup',
  'priority' => 'high',
  'recommended_units_to_build' => [
    {
      'unit_type' => 'power_unit',
      'variant' => 'solar_array',
      'count' => 2,
      'priority' => 'critical',
      'specifications' => { 'output' => 5000 }
    },
    {
      'unit_type' => 'habitat_module',
      'variant' => 'standard',
      'count' => 1,
      'priority' => 'high',
      'specifications' => { 'capacity' => 4 }
    },
    {
      'unit_type' => 'life_support_unit',
      'variant' => 'air_recycler',
      'count' => 1,
      'priority' => 'critical',
      'specifications' => { 'capacity' => 4 }
    }
  ]
}

# 7. Unload cargo to settlement
puts "\n7. Unloading cargo from starship to settlement..."
starship.inventory.items.each do |item|
  # Create corresponding item in settlement inventory
  settlement.inventory.items.create!(
    name: item.name,
    item_type: item.item_type,
    quantity: item.quantity
  )
  
  # Remove from starship
  item.destroy
end
puts "  All cargo transferred to settlement inventory"

# 8. Simulate AI Production Manager activities
puts "\n8. Simulating AI Production Manager activities..."

# Create production manager
production_manager = AIManager::ProductionManager.new(settlement)

# Execute plan
puts "  Executing construction plan: #{construction_plan['plan_name']}"
result = production_manager.manage_resources_for_construction(construction_plan)

puts "  Plan execution complete"
puts "  Required materials: #{result[:required_materials].inspect}"
puts "  Missing materials: #{result[:missing_materials].inspect}"

# 9. Check for created construction jobs
puts "\n9. Checking for created construction jobs..."
construction_jobs = settlement.construction_jobs
if construction_jobs.any?
  puts "  Created construction jobs: #{construction_jobs.count}"
  construction_jobs.each do |job|
    puts "    - Job ##{job.id}: #{job.job_type} (Status: #{job.status})"
    
    # List material requests
    puts "      Material requests:"
    job.material_requests.each do |request|
      puts "        * #{request.quantity_requested} #{request.material_name} (#{request.status})"
    end
  end
else
  puts "  No construction jobs created"
end

# 10. Check for created unit assembly jobs
puts "\n10. Checking for created unit assembly jobs..."
assembly_jobs = settlement.unit_assembly_jobs
if assembly_jobs.any?
  puts "  Created unit assembly jobs: #{assembly_jobs.count}"
  assembly_jobs.each do |job|
    puts "    - Job ##{job.id}: #{job.unit_type} x#{job.count} (Status: #{job.status})"
    
    # List material requests
    puts "      Material requests:"
    job.material_requests.each do |request|
      puts "        * #{request.quantity_requested} #{request.material_name} (#{request.status})"
    end
  end
else
  puts "  No unit assembly jobs created"
end

puts "\nAI Manager Basic Test Complete!"