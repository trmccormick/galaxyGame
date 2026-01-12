# lib/tasks/lunar_base_pipeline.rake
require 'json'
require 'securerandom'

namespace :lunar_base do
  desc "Simulate Lunar Base Construction Pipeline from Mission Manifest"
  task pipeline: :environment do
    puts "\n=== Lunar Base Construction Pipeline ==="

    # 1. Load mission manifest and profile, initialize TaskExecutionEngine
    puts "\n1. Loading mission files..."
    manifest_path = Rails.root.join('app', 'data', 'json-data', 'missions', 'lunar-precursor', 'lunar-precursor_manifest_v1.json')
    profile_path = Rails.root.join('app', 'data', 'json-data', 'missions', 'lunar-precursor', 'lunar-precursor_profile_v1.json')

    manifest = JSON.parse(File.read(manifest_path))
    profile = JSON.parse(File.read(profile_path))

    # Initialize TaskExecutionEngine to load tasks from phases
    engine = AIManager::TaskExecutionEngine.new('lunar-precursor')
    task_list = engine.instance_variable_get(:@task_list)

    puts "  ✓ Manifest loaded: #{manifest['manifest_id']}"
    puts "  ✓ Loaded #{task_list.length} tasks from phases"
    puts "  ✓ Profile loaded"

    # 2. Setup Luna and locations
    puts "\n2. Setting up Luna and locations..."
    luna = CelestialBodies::Satellites::Moon.find_by(name: "Luna")
    unless luna
      # Create Earth first
      earth = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_or_create_by!(name: "Earth") do |e|
        e.identifier = 'EARTH-01'
        e.mass = 5.972e24
        e.size = 6371.0
        e.gravity = 9.807
      end
      # Create Luna
      luna = CelestialBodies::Satellites::Moon.create!(
        name: "Luna",
        identifier: 'LUNA-01',
        mass: 0.7342e23,
        radius: 0.1737e7,
        size: 0.2727e0,
        gravity: 0.162e1,
        orbital_period: 0.27322e2,
        rotational_period: 0.27322e2,
        density: 0.3344e1,
        surface_temperature: 250.0,
        geological_activity: true,
        parent_celestial_body: earth
      )
      puts "  ✓ Created Earth and Luna"
    end

    # Use profile location or default
    site_coords = profile.dig('start_location', 'coordinates') || { 'lat' => 14.1, 'lon' => -56.8 }
    site_name = profile.dig('start_location', 'site') || "Marius Hills Lava Tube Entrance"
    
    landing_site = Location::CelestialLocation.find_or_create_by!(
      name: site_name.titleize,
      coordinates: "#{site_coords['lat']}°N #{site_coords['lon'].abs}°#{site_coords['lon'] >= 0 ? 'E' : 'W'}",
      celestial_body: luna
    )

    # 3. Create AstroLift organization and settlement
    puts "\n3. Creating AstroLift organization and settlement..."
    astrolift = Organizations::BaseOrganization.find_or_create_by!(
      name: 'AstroLift',
      identifier: 'ASTROLIFT',
      organization_type: :corporation
    )

    settlement = Settlement::BaseSettlement.find_or_create_by!(
      name: "Lunar Base Alpha",
      owner: astrolift,
      current_population: 0, # Starts unmanned
      location: landing_site
    )
    settlement.create_inventory! unless settlement.inventory

    # 4. Create Heavy Lift Transport craft
    puts "\n4. Creating Heavy Lift Transport craft..."
    craft_lookup = Lookup::CraftLookupService.new
    heavy_lift_data = craft_lookup.find_craft(manifest['craft']['id'])
    raise "Heavy Lift Transport operational data not found" unless heavy_lift_data

    heavy_lift = Craft::Transport::HeavyLander.create!(
      name: "AstroLift-LunarHauler-#{SecureRandom.hex(4)}",
      craft_name: heavy_lift_data['name'],
      craft_type: heavy_lift_data['category'],
      owner: astrolift,
      deployed: false,
      operational_data: heavy_lift_data
    )
    heavy_lift.create_inventory! unless heavy_lift.inventory
    puts "  ✓ Heavy Lift Transport created: #{heavy_lift.name}"

    # 5. Install units and load inventory from manifest
    puts "\n5. Installing units and loading inventory..."
    unit_lookup = Lookup::UnitLookupService.new
    
    # Install units on craft
    (manifest['craft']['installed_units'] || []).each do |unit_config|
      unit_data = unit_lookup.find_unit(unit_config['id'])
      next unless unit_data
      
      unit_identifier = "#{unit_config['id'].upcase}_#{heavy_lift.name}_#{SecureRandom.hex(4)}"
      unit_obj = Units::BaseUnit.create!(
        name: unit_config['name'],
        unit_type: unit_config['id'],
        owner: astrolift,
        identifier: unit_identifier,
        operational_data: unit_data
      )
      heavy_lift.install_unit(unit_obj)
      puts "  ✓ Installed #{unit_config['name']}"
    end

    # Load stowed units/cargo into craft inventory
    inventory = manifest['inventory'] || {}
    inventory.each do |category, items|
      next unless items.is_a?(Array)
      items.each do |item_config|
        count = item_config['count'] || 1
        item_name = "Unassembled #{item_config['name'] || item_config['id']}"
        
        heavy_lift.inventory.items.create!(
          name: item_name,
          amount: count,
          owner: astrolift,
          metadata: { "#{category.singularize}_type" => item_config['id'] }
        )
        puts "  ✓ Loaded #{count}x #{item_name}"
      end
    end

    # 6. Land craft and transfer inventory to settlement
    puts "\n6. Landing craft at site and transferring cargo..."
    heavy_lift.update!(deployed: true, docked_at: settlement)
    
    # Transfer all cargo to settlement inventory
    heavy_lift.inventory.items.each do |item|
      settlement_item = settlement.inventory.items.find_or_create_by!(
        name: item.name,
        owner: astrolift
      )
      settlement_item.update!(amount: settlement_item.amount + item.amount)
      puts "  ✓ Transferred #{item.amount}x #{item.name} to settlement"
    end

    # 7. Execute mission using TaskExecutionEngine
    puts "\n7. Executing mission phases..."
    engine.instance_variable_set(:@settlement, settlement)
    mission_identifier = "lunar_precursor_settlement_#{settlement.id}"
    engine.instance_variable_set(:@mission, Mission.find_by(identifier: mission_identifier, settlement: settlement) || Mission.create!(
      identifier: mission_identifier,
      settlement: settlement,
      status: 'in_progress'
    ))

    # Execute all tasks
    task_count = 0
    while engine.send(:execute_next_task)
      task_count += 1
    end

    puts "  ✓ Executed #{task_count} tasks successfully"

    # 8. Build structures (using construction services)
    puts "\n8. Building base structures..."
    
    # Create lava tube feature
    lava_tube = CelestialBodies::Features::LavaTube.find_or_create_by!(
      celestial_body: luna,
      feature_id: "alpha_lava_tube"
    ) do |feature|
      feature.feature_type = "lava_tube"
      feature.status = "surveyed"
      feature.static_data = {
        name: "Alpha Lava Tube",
        dimensions: {
          length_m: 600.0,
          width_m: 60.0,
          height_m: 35.0
        }
      }
    end
    # Ensure static_data is set even if lava_tube already exists
    lava_tube.update!(static_data: {
      name: "Alpha Lava Tube",
      dimensions: {
        length_m: 600.0,
        width_m: 60.0,
        height_m: 35.0
      }
    }) if lava_tube.static_data.blank?
    puts "  ✓ Discovered lava tube: #{lava_tube.name}"
    
    # Create skylight feature
    skylight = CelestialBodies::Features::Skylight.find_or_create_by!(
      celestial_body: luna,
      feature_id: "alpha_skylight"
    ) do |feature|
      feature.parent_feature = lava_tube
      feature.feature_type = "skylight"
      feature.status = "natural"
      feature.static_data = {
        diameter_m: 30.0
      }
    end
    # Ensure static_data is set
    skylight.update!(static_data: skylight.static_data.merge(diameter_m: 30.0))
    skylight.reload
    puts "  ✓ Created skylight: #{skylight.name}"

    # 9. Schedule construction jobs
    puts "\n9. Scheduling construction jobs..."
    skylight_job = ConstructionJob.create!(
      job_type: 'skylight_cover',
      status: 'scheduled',
      settlement: settlement,
      jobable: skylight,
      priority: 'high'
    )
    puts "  ✓ Scheduled skylight cover job"

    # 10. Calculate and request materials
    puts "\n10. Requesting materials..."
    skylight_materials = Construction::SkylightCalculator.calculate_materials(skylight, nil)
    skylight_materials.each do |material, amount|
      skylight_job.material_requests.create!(
        material_name: material,
        quantity_requested: amount,
        status: 'pending'
      )
      puts "  ✓ Requested #{amount} #{material}"
    end

    # 11. Simulate construction process
    puts "\n11. Simulating construction process..."
    skylight_job.material_requests.each do |request|
      item = settlement.inventory.items.find_by(name: request.material_name)
      if item && item.amount >= request.quantity_requested
        request.update!(status: 'fulfilled')
        item.update!(amount: item.amount - request.quantity_requested)
        puts "  ✓ Fulfilled: #{request.quantity_requested} #{request.material_name}"
      else
        available = item ? item.amount : 0
        puts "  ✗ Insufficient: #{request.quantity_requested} #{request.material_name} (have: #{available})"
      end
    end
    
    if skylight_job.material_requests.all? { |req| req.status == 'fulfilled' }
      skylight_job.update!(status: 'in_progress')
      puts "  ✓ Job in progress"
      skylight_job.update!(status: 'completed')
      skylight_job.jobable.update!(status: 'covered')
      puts "  ✓ Skylight construction completed"
    else
      puts "  ✗ Job waiting for materials"
    end

    # 12. Final status
    puts "\n=== FINAL STATUS ==="
    puts "\nCraft:"
    puts "  Name: #{heavy_lift.name}"
    puts "  Status: #{heavy_lift.deployed ? 'Landed' : 'In transit'}"
    puts "  Location: #{heavy_lift.location&.name}"
    
    puts "\nSettlement:"
    puts "  Name: #{settlement.name}"
    puts "  Owner: #{settlement.owner.name}"
    puts "  Population: #{settlement.current_population}"
    
    puts "\nStructures:"
    skylight.reload
    puts "  Lava Tube: #{lava_tube.name} (#{lava_tube.status})"
    puts "  Skylight: #{skylight.name} (#{skylight.status})"
    
    puts "\nDeployed Units:"
    deployed_units.each do |task_id, info|
      next unless info.is_a?(Hash)
      puts "  - #{info[:count]}x #{info[:unit]}"
    end
    
    puts "\nInventory Summary:"
    settlement.inventory.items.order(:name).each do |item|
      puts "  - #{item.name}: #{item.amount}"
    end
    
    puts "\n✓ Lunar Base Construction Pipeline Complete!"
  end
end
