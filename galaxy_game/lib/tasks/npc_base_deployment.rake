# lib/tasks/npc_base_deployment.rake
require 'json'
require 'securerandom'

namespace :npc do
  namespace :base_deployment do
    desc "Simulate NPC Base Deployment Pipeline from Mission Manifest"
    task pipeline: :environment do
      puts "\n=== NPC Base Deployment Pipeline ==="

      mission_id = 'npc_base_deploy'

      # 1. Load mission manifest
      puts "\n1. Loading mission manifest..."
      manifest_name = ENV['TEST_MANIFEST'] || 'npc_base_deploy_manifest_v1'
      manifest_path = Rails.root.join('app', 'data', 'json-data', 'missions', 'npc-base-deploy', "#{manifest_name}.json")
      manifest = JSON.parse(File.read(manifest_path))
      puts "  ✓ Manifest loaded: #{manifest['manifest_id']}"

      # 2. Setup Luna and locations
      puts "\n2. Setting up Luna and locations..."
      luna = CelestialBodies::CelestialBody.find_by(identifier: 'LUNA-01')
      if luna.nil?
        begin
          luna = CelestialBodies::Satellites::Moon.find_or_create_by!(identifier: 'LUNA-01') do |moon|
            moon.name = "Luna"
            moon.mass = 0.7342e23
            moon.radius = 0.1737e7
            moon.size = 0.2727e0
            moon.gravity = 0.162e1
            moon.orbital_period = 0.27322e2
            moon.rotational_period = 0.27322e2
            moon.density = 0.3344e1
            moon.surface_temperature = 250.0
            moon.geological_activity = true
            moon.parent_celestial_body = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_or_create_by!(identifier: 'EARTH-01') do |e|
              e.name = "Earth"
              e.mass = 5.972e24
              e.size = 6371.0
              e.gravity = 9.807
            end
          end
          puts "  ✓ Created Luna"
        rescue ActiveRecord::RecordInvalid => e
          puts "  ⚠ Luna creation failed (#{e.message}), trying to find existing..."
          luna = CelestialBodies::CelestialBody.find_by(identifier: 'LUNA-01')
          raise "Could not create or find Luna" unless luna
          puts "  ✓ Found existing Luna"
        end
      else
        puts "  ✓ Luna already exists"
      end

      # Create base camp location
      base_camp = Location::CelestialLocation.find_or_create_by!(
        name: "Luna Base Camp",
        celestial_body: luna
      ) do |loc|
        loc.coordinates = "0.0°N 0.0°E"
        loc.altitude = 0.0
      end
      puts "  ✓ Base camp location ready: #{base_camp.name}"

      # 3. Create settlement
      puts "\n3. Creating settlement..."
      settlement = Settlement::BaseSettlement.create!(
        name: "NPC Automated Base #{SecureRandom.hex(4)}",
        location: base_camp,
        settlement_type: 'base'
      )
      puts "  ✓ Created settlement: #{settlement.name} (ID: #{settlement.id})"

      # 4. Create mission record
      puts "\n4. Creating mission record..."
      mission_identifier = "#{mission_id}_settlement_#{settlement.id}"
      mission = Mission.create!(
        identifier: mission_identifier,
        settlement: settlement,
        status: 'in_progress'
      )
      puts "  ✓ Mission created: #{mission_identifier}"

      # 5. Load inventory from manifest
      puts "\n5. Loading inventory from manifest..."
      manifest['inventory']['units'].each do |unit|
        settlement.inventory.add_item(unit['name'], unit['count'])
        puts "  ✓ Added #{unit['count']}x #{unit['name']}"
      end
      puts "  ✓ Inventory loaded with #{settlement.inventory.items.count} item types"

      # 6. Initialize TaskExecutionEngine (it will load tasks from profile)
      puts "\n6. Initializing task execution engine..."
      # Use base mission_id for loading tasks from correct directory
      engine = AIManager::TaskExecutionEngine.new(mission_id)
      
      # Manually set the mission and settlement since we created them
      engine.instance_variable_set(:@mission, mission)
      engine.instance_variable_set(:@settlement, settlement)
      
      task_list = engine.instance_variable_get(:@task_list)
      puts "  ✓ Loaded #{task_list.length} tasks from profile"

      # 7. Execute mission phases
      puts "\n7. Executing mission phases..."
      
      # Execute all tasks synchronously
      task_count = 0
      while engine.send(:execute_next_task)
        task_count += 1
      end

      puts "  ✓ Executed #{task_count} tasks successfully"

      # 8. Final status
      puts "\n8. Deployment complete!"
      puts "  ✓ Settlement: #{settlement.name}"
      puts "  ✓ Location: #{base_camp.name}"
      puts "  ✓ Final inventory: #{settlement.inventory.items.count} item types"
      puts "  ✓ Mission status: #{mission.reload.status}"
      
      # Show material tracking
      produced = engine.instance_variable_get(:@produced_materials)
      consumed = engine.instance_variable_get(:@consumed_materials)
      
      if produced.any? || consumed.any?
        puts "\n9. Material tracking:"
        if produced.any?
          puts "  Produced:"
          produced.each { |mat, qty| puts "    • #{mat}: #{qty}" }
        end
        if consumed.any?
          puts "  Consumed:"
          consumed.each { |mat, qty| puts "    • #{mat}: #{qty}" }
        end
      end

      puts "\n=== NPC Base Deployment Complete ==="
    end
  end
end