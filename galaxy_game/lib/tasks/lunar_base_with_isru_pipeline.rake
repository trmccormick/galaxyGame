# lib/tasks/lunar_base_with_isru_pipeline.rake
# docker compose exec web bundle exec rake lunar_base:with_isru
require 'json'
require 'securerandom'

# Include the Manufacturing::ProductionService from the ISRU validation rake
class LunarBaseProductionService
    # Constant data needed by the rake task for reporting
    PVE_DATA = {
        input_processed_kg: 5.0, output_gases_kg: 0.05, output_water_kg: 0.10, output_inert_waste_kg: 4.85
    }.freeze
    TEU_DATA = { input_raw_kg: 10.0, output_processed_kg: 9.95 }.freeze

    # Gas Composition Ratios (based on total mass)
    GASSES_RATIO = {
        hydrogen: 0.50,
        carbon_monoxide: 0.25,
        helium_3: 0.05,
        neon: 0.20
    }.freeze

    def initialize(settlement)
      @settlement = settlement
    end

    def manufacture_component(blueprint_data, target_units)
      # --- CORE LOGIC: CALCULATE CYCLES AND RESOURCES ---
      inert_req_kg = blueprint_data[:input_quantity_kg] * target_units

      # Use the calculation helper to maintain DRY principle
      calculations = self.class.calculate_cycles(inert_req_kg)

      total_raw_consumed = calculations[:total_raw_consumed]
      total_water = calculations[:total_water]
      total_gas = calculations[:total_gas]

      # --- STUB: EXECUTE LOGISTICS (Simulating DB changes) ---
      puts "  [STUB] Simulating DB actions for consumption and production (Target: #{target_units} units)..."

      inventory = @settlement.inventory
      surface_storage = inventory.surface_storage

      # 1. Consume Raw Regolith
      surface_storage.material_piles.find_by!(material_type: "raw_regolith").decrement!(:amount, total_raw_consumed)
      inventory.remove_item("raw_regolith", total_raw_consumed, @settlement, { "source_body" => "LUNA-01", "storage_location" => "surface_pile" })

      # 2. Produce Inert Waste and Volatiles (from TEU -> PVE)
      inert_waste_produced = calculations[:inert_waste_produced]

      surface_storage.add_pile(material_name: "inert_regolith_waste", amount: inert_waste_produced, source_unit: "PVE_MK1")
      inventory.add_item("inert_regolith_waste", inert_waste_produced, @settlement, { "storage_location" => "surface_pile" })

      inventory.add_item("water", total_water, @settlement)

      # Detailed Gas Item Creation
      GASSES_RATIO.each do |gas_name, ratio|
          gas_amount = total_gas * ratio
          inventory.add_item(gas_name.to_s, gas_amount, @settlement)
      end

      # 3. Consume Inert Waste and Produce Final Component (I-Beam)
      surface_storage.material_piles.find_by!(material_type: "inert_regolith_waste").decrement!(:amount, inert_req_kg)
      inventory.remove_item("inert_regolith_waste", inert_req_kg, @settlement, { "storage_location" => "surface_pile" })

      surface_storage.add_pile(material_name: blueprint_data[:id], amount: target_units, source_unit: "3D_PRINTER_MK1")
      inventory.add_item(blueprint_data[:id], target_units, @settlement, { "storage_location" => "surface_pile" })

      # --- END STUB EXECUTION ---

      # Return the actual calculated metrics for Rake task reporting
      {
        total_raw_consumed: total_raw_consumed,
        total_water: total_water,
        total_gas: total_gas,
        component_produced: blueprint_data[:id],
        component_amount: target_units
      }
    end

    # Expose calculation methods for Rake Task verification
    def self.calculate_cycles(target_inert_kg)
      pve_cycles = (target_inert_kg / PVE_DATA[:output_inert_waste_kg].to_f).ceil

      teu_input_needed = pve_cycles * PVE_DATA[:input_processed_kg]
      teu_cycles = (teu_input_needed / TEU_DATA[:output_processed_kg].to_f).ceil

      # Final Metrics Calculation
      total_raw_consumed = teu_cycles * TEU_DATA[:input_raw_kg]
      inert_waste_produced = pve_cycles * PVE_DATA[:output_inert_waste_kg]
      total_water = pve_cycles * PVE_DATA[:output_water_kg]
      total_gas = pve_cycles * PVE_DATA[:output_gases_kg]

      {
        pve_cycles: pve_cycles,
        teu_cycles: teu_cycles,
        total_raw_consumed: total_raw_consumed,
        inert_waste_produced: inert_waste_produced,
        total_water: total_water,
        total_gas: total_gas
      }
    end
  end
namespace :lunar_base do
  desc "Simulate Lunar Base Construction Pipeline with ISRU Production"
  task with_isru: :environment do
    puts "\n=== Lunar Base Construction Pipeline with ISRU Production ==="

    # 1. Load mission manifest and profile, initialize TaskExecutionEngine
    puts "\n1. Loading mission files..."
    manifest_path = Rails.root.join('app', 'data', 'json-data', 'missions', 'lunar-precursor', 'lunar_precursor_manifest_v1.json')
    profile_path = Rails.root.join('app', 'data', 'json-data', 'missions', 'lunar-precursor', 'lunar_precursor_profile_v1.json')

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

    # 3. Create NPC Organizations and settlement
    puts "\n3. Creating NPC Organizations and settlement..."

    # Luna Development Corporation (LDC): The primary developer and settlement owner
    ldc = Organizations::BaseOrganization.find_or_create_by!(identifier: 'LDC') do |org|
      org.name = 'Lunar Development Corporation'
      org.organization_type = :development_corporation
      # Flag as NPC to enable the Virtual Ledger (negative balances)
      org.operational_data = { 'is_npc' => true }
    end
    puts "✅ Using organization: #{ldc.name} (ID: #{ldc.id})"

    # AstroLift: The logistics provider (fictional space transportation company)
    astrolift = Organizations::BaseOrganization.find_or_create_by!(identifier: 'ASTROLIFT') do |org|
      org.name = 'AstroLift'
      org.organization_type = :corporation
      org.operational_data = { 'is_npc' => true }
    end
    puts "✅ Using logistics provider: #{astrolift.name}"

    settlement = Settlement::BaseSettlement.find_or_create_by!(
      name: "Lunar Base Alpha #{Time.current.to_i}",
      owner: ldc, # LDC owns the base, not the logistics company
      current_population: 0, 
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

    # Execute AI Mission using TaskExecutionEngine
    puts "\n7. Executing AI Mission using TaskExecutionEngine..."
    
    # Create mission for settlement
    mission_id = 'lunar_precursor'
    mission_identifier = "#{mission_id}_settlement_#{settlement.id}"
    mission = Mission.find_by(identifier: mission_identifier, settlement: settlement) || Mission.create!(
      identifier: mission_identifier,
      settlement: settlement,
      status: 'in_progress'
    )
    
    # Execute mission using our AI TaskExecutionEngine
    engine = AIManager::TaskExecutionEngine.new(mission_id)
    engine.instance_variable_set(:@settlement, settlement)
    engine.instance_variable_set(:@mission, mission)
    
    deployed_units = {} # Initialize deployed units tracking
    
    # Execute all tasks
    while engine.execute_next_task
      puts "  ✓ Executed task: #{engine.instance_variable_get(:@current_task_index)}"
    end
    
    puts "  ✓ AI Mission completed"

    # 8. Build structures using ConstructionJobService
    puts "\n8. Building base structures using ConstructionJobService..."

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
    lava_tube.update!(static_data: lava_tube.static_data.merge({
      name: "Alpha Lava Tube",
      dimensions: {
        length_m: 600.0,
        width_m: 60.0,
        height_m: 35.0
      }
    })) if lava_tube.static_data.blank?
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
    skylight.update!(static_data: skylight.static_data.merge(diameter_m: 30.0))
    skylight.reload
    puts "  ✓ Created skylight: #{skylight.name}"

    # Use ConstructionJobService to create skylight cover job
    skylight_job = ConstructionJobService.create_job(skylight, 'skylight_cover', settlement: settlement)
    puts "  ✓ Scheduled skylight cover job using ConstructionJobService"

    # Auto-fulfill for simulation (like our AI system does)
    skylight_job.material_requests.update_all(status: 'fulfilled', fulfilled_at: Time.current)
    puts "  ✓ Auto-fulfilled material requests for simulation"

    # Start construction
    ConstructionJobService.send(:start_construction, skylight_job)
    puts "  ✓ Started construction"

    # Complete construction
    skylight_job.update!(status: 'completed', completion_date: Time.current)
    skylight_job.jobable.update!(status: 'enclosed')
    puts "  ✓ Skylight construction completed"

    # 12. ISRU Production Simulation with Resource Tracking
    puts "\n12. Simulating ISRU Production with Resource Tracking..."

    # Load blueprint from proper data directory
    blueprint_path = Rails.root.join('app', 'data', 'json-data', 'blueprints', 'components', 'structural', '3d_printed_ibeam_mk1_bp.json')
    blueprint_data = JSON.parse(File.read(blueprint_path))
    material_req = blueprint_data['blueprint_data']['material_requirements'].first

    # Configuration for I-Beam production
    IBEAM_TARGET_UNITS = 10
    IBEAM_BLUEPRINT = {
      id: blueprint_data['id'],
      input_material: material_req['material'],
      input_quantity_kg: material_req['quantity'].to_f
    }.freeze
    REQUIRED_INERT_KG = IBEAM_TARGET_UNITS * IBEAM_BLUEPRINT[:input_quantity_kg]

    expected_results = LunarBaseProductionService.calculate_cycles(REQUIRED_INERT_KG)

    # Stage raw regolith if not already present
    inventory = settlement.inventory
    unless inventory.surface_storage
        Storage::SurfaceStorage.find_or_create_by!(
            inventory: inventory,
            settlement_id: settlement.id
        ) do |ss|
            ss.celestial_body = luna
            ss.item_type = 'Solid'
        end
        inventory.reload
    end
    surface_storage = inventory.surface_storage

    staging_amount = expected_results[:total_raw_consumed] + 50.0
    existing_raw = surface_storage.material_piles.find_by(material_type: "raw_regolith")&.amount || 0
    if existing_raw < staging_amount
      additional_raw = staging_amount - existing_raw
      surface_storage.add_pile(material_name: "raw_regolith", amount: additional_raw, source_unit: "regolith_harvester_rover")
      inventory.add_item("raw_regolith", additional_raw, settlement, { "source_body" => luna.identifier, "storage_location" => "surface_pile" })

      # Track ISRU-sourced raw regolith
      ResourceTrackingService.track_procurement(
        settlement,
        IBEAM_BLUEPRINT[:input_material],
        additional_raw,
        :isru,
        { purpose: "Staged for I-Beam production", source_body: luna.identifier }
      )
      puts "  ✓ Staged additional raw regolith: #{additional_raw.round(2)} kg (ISRU-sourced)"
    end

    # Execute manufacturing service
    manufacturing_service = LunarBaseProductionService.new(settlement)
    results = manufacturing_service.manufacture_component(IBEAM_BLUEPRINT, IBEAM_TARGET_UNITS)

    # Track ISRU production outputs
    ResourceTrackingService.track_procurement(
      settlement,
      "water",
      results[:total_water],
      :isru,
      { purpose: "ISRU extraction byproduct", source_body: luna.identifier }
    )

    ResourceTrackingService.track_procurement(
      settlement,
      "oxygen",
      results[:total_gas],
      :isru,
      { purpose: "ISRU extraction byproduct", source_body: luna.identifier }
    )

    ResourceTrackingService.track_procurement(
      settlement,
      "3d_printed_ibeam_mk1",
      results[:component_amount],
      :isru,
      { purpose: "ISRU manufactured component", source_body: luna.identifier }
    )

    puts "  ✓ ISRU production completed: #{IBEAM_TARGET_UNITS} I-Beams manufactured with resource tracking"

    # 13. Final status
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

    puts "\nISRU Production Summary:"
    puts "  - Raw Regolith Consumed: #{results[:total_raw_consumed].round(2)} kg"
    puts "  - Water Extracted: #{results[:total_water].round(3)} kg"
    puts "  - Gases Extracted: #{results[:total_gas].round(3)} kg"
    puts "  - I-Beams Produced: #{results[:component_amount]} units"

    puts "\nResource Tracking Summary:"
    resource_stats = ResourceTrackingService.get_resource_stats(settlement)
    procurement_summary = resource_stats[:procurement_summary]

    puts "  Total Procurement Events: #{procurement_summary[:total_procurement]}"
    puts "  Total Quantity: #{procurement_summary[:total_quantity]}"

    puts "  By Procurement Method:"
    procurement_summary[:by_method].each do |method, quantity|
      puts "    - #{method.to_s.upcase}: #{quantity} units"
    end

    puts "  By Material:"
    procurement_summary[:by_material].each do |material, quantity|
      puts "    - #{material}: #{quantity} units"
    end

    puts "\nInventory Summary:"
    settlement.inventory.items.order(:name).each do |item|
      puts "  - #{item.name}: #{item.amount}"
    end

    puts "\n✓ Lunar Base Construction Pipeline with ISRU Production Complete!"
  end
end