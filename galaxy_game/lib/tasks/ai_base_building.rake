# lib/tasks/ai_base_building.rake
# Rake tasks for AI base building simulation and resource tracking

namespace :ai do
  namespace :base_building do
    desc "Run AI base building simulation for a settlement"
    task :simulate, [:settlement_id, :mission_id] => :environment do |t, args|
      settlement_id = args[:settlement_id]
      mission_id = args[:mission_id] || 'lunar_precursor'

      # Create a test settlement if no ID provided
      if settlement_id.nil?
        settlement = create_test_settlement
        puts "Created test settlement: #{settlement.name} (ID: #{settlement.id})"
      else
        settlement = Settlement::BaseSettlement.find(settlement_id)
      end

      puts "Starting AI base building simulation for #{settlement.name}"

      # Take initial inventory snapshot
      initial_inv_hash = {}
      settlement.inventory.items.each do |item|
        initial_inv_hash[item.name] = item.amount
      end
      initial_item_count = settlement.inventory.items.count
      puts "Initial inventory: #{initial_item_count} items"

      # Start the mission
      engine = AIManager::TaskExecutionEngine.new(mission_id)
      task_list = engine.instance_variable_get(:@task_list)
      
      if task_list.empty?
        puts "No tasks found for mission #{mission_id}. Available mission directories:"
        Dir.glob(Rails.root.join('app', 'data', 'json-data', 'missions', '*')).each do |dir|
          puts "  #{File.basename(dir)}" if File.directory?(dir)
        end
        exit
      end
      
      engine.instance_variable_set(:@settlement, settlement)
      mission_identifier = "#{mission_id}_settlement_#{settlement.id}"
      engine.instance_variable_set(:@mission, Mission.find_by(identifier: mission_identifier, settlement: settlement) || Mission.create!(
        identifier: mission_identifier,
        settlement: settlement,
        status: 'in_progress'
      ))

      # Execute all tasks
      while engine.send(:execute_next_task)
        puts "Executed task #{engine.instance_variable_get(:@current_task_index)}"
        sleep 1 # Small delay between tasks
      end

      # Get final inventory snapshot
      final_snapshot = ResourceTrackingService.track_inventory_snapshot(settlement)
      final_value = final_snapshot['total_value'] || 0
      final_items = final_snapshot['total_items'] || 0

      puts "\nSimulation Complete!"
      puts "Production Summary:"
      puts engine.send(:production_summary)

      puts "\nInventory Changes:"
      initial_items = initial_snapshot['total_items'] || 0
      puts "Initial: #{initial_items} items, value: #{total_value.round(2)}"
      puts "Final: #{final_items} items, value: #{final_value.round(2)}"
      puts "Change: #{(final_items - initial_items)} items, value: #{(final_value - total_value).round(2)}"

      # Show detailed inventory diff
      initial_inventory = initial_snapshot['inventory'] || {}
      final_inventory = final_snapshot['inventory'] || {}
      
      all_materials = (initial_inventory.keys + final_inventory.keys).uniq.sort
      
      puts "\nDetailed Inventory Changes:"
      all_materials.each do |material|
        initial_qty = initial_inventory[material] || 0
        final_qty = final_inventory[material] || 0
        change = final_qty - initial_qty
        next if change == 0
        puts "  #{material}: #{initial_qty} → #{final_qty} (#{change > 0 ? '+' : ''}#{change})"
      end

      # Get final stats
      stats = ResourceTrackingService.get_resource_stats(settlement, 1.hour)
      puts "\nResource Usage Summary:"
      puts "Total procurement operations: #{stats[:procurement_summary][:total_procurement]}"
      puts "Total quantity procured: #{stats[:procurement_summary][:total_quantity]}"

      puts "\nProcurement by method:"
      stats[:procurement_summary][:by_method].each do |method, quantity|
        puts "  #{method}: #{quantity}"
      end

      puts "\nProcurement by material:"
      stats[:procurement_summary][:by_material].each do |material, quantity|
        puts "  #{material}: #{quantity}"
      end

      if stats[:efficiency_metrics]['overall_efficiency']
        efficiency = stats[:efficiency_metrics]['overall_efficiency']
        puts "\nEfficiency Metrics:"
        puts "ISRU ratio: #{(efficiency['isru_ratio'] * 100).round(1)}%" if efficiency['isru_ratio']
        puts "Import ratio: #{(efficiency['import_ratio'] * 100).round(1)}%" if efficiency['import_ratio']
        puts "Self-sufficiency: #{efficiency['self_sufficiency'].round(1)}%" if efficiency['self_sufficiency']
      else
        puts "\nEfficiency Metrics: No data available"
      end
    end

    desc "Run AI habitat development simulation for lunar precursor mission 2"
    task :simulate_habitat, [:settlement_id] => :environment do |t, args|
      settlement_id = args[:settlement_id]
      mission_id = 'lunar_precursor_2'

      # Use existing settlement or create test settlement
      if settlement_id.nil?
        settlement = create_test_settlement_with_lava_tube
        puts "Created test settlement with lava tube: #{settlement.name} (ID: #{settlement.id})"
      else
        settlement = Settlement::BaseSettlement.find(settlement_id)
      end

      puts "Starting AI habitat development simulation for #{settlement.name}"

      # Take initial inventory snapshot
      initial_inv_hash = {}
      settlement.inventory.items.each do |item|
        initial_inv_hash[item.name] = item.amount
      end
      initial_item_count = settlement.inventory.items.count
      puts "Initial inventory: #{initial_item_count} items"

      # Start the habitat development mission
      engine = AIManager::TaskExecutionEngine.new(mission_id)
      task_list = engine.instance_variable_get(:@task_list)
      
      if task_list.empty?
        puts "No tasks found for mission #{mission_id}. Available mission directories:"
        Dir.glob(Rails.root.join('app', 'data', 'json-data', 'missions', '*')).each do |dir|
          puts "  #{File.basename(dir)}" if File.directory?(dir)
        end
        exit
      end
      
      engine.instance_variable_set(:@settlement, settlement)
      mission_identifier = "#{mission_id}_settlement_#{settlement.id}"
      engine.instance_variable_set(:@mission, Mission.find_by(identifier: mission_identifier, settlement: settlement) || Mission.create!(
        identifier: mission_identifier,
        settlement: settlement,
        status: 'in_progress'
      ))

      # Execute all tasks
      while engine.send(:execute_next_task)
        puts "Executed task #{engine.instance_variable_get(:@current_task_index)}"
        sleep 1 # Small delay between tasks
      end

      # Get final inventory snapshot
      final_snapshot = ResourceTrackingService.track_inventory_snapshot(settlement)
      final_value = final_snapshot['total_value'] || 0
      final_items = final_snapshot['total_items'] || 0

      puts "\nHabitat Development Complete!"
      puts "Development Summary:"
      puts engine.send(:production_summary)

      puts "\nInventory Changes:"
      initial_items = initial_snapshot['total_items'] || 0
      puts "Initial: #{initial_items} items, value: #{total_value.round(2)}"
      puts "Final: #{final_items} items, value: #{final_value.round(2)}"
      puts "Change: #{(final_items - initial_items)} items, value: #{(final_value - total_value).round(2)}"

      # Show detailed inventory diff
      initial_inventory = initial_snapshot['inventory'] || {}
      final_inventory = final_snapshot['inventory'] || {}
      
      all_materials = (initial_inventory.keys + final_inventory.keys).uniq.sort
      
      puts "\nDetailed Inventory Changes:"
      all_materials.each do |material|
        initial_qty = initial_inventory[material] || 0
        final_qty = final_inventory[material] || 0
        change = final_qty - initial_qty
        next if change == 0
        puts "  #{material}: #{initial_qty} → #{final_qty} (#{change > 0 ? '+' : ''}#{change})"
      end

      # Check habitat status
      puts "\n🏠 HABITAT STATUS:"
      lava_tube = CelestialBodies::Features::LavaTube.find_by(celestial_body: settlement.location.celestial_body)
      if lava_tube
        puts "  Lava Tube: #{lava_tube.static_data['dimensions']['length_m']}m × #{lava_tube.static_data['dimensions']['width_m']}m"
        puts "  Status: #{lava_tube.status}"
        puts "  Pressurized: #{lava_tube.can_pressurize? ? 'Yes' : 'No'}"
      else
        puts "  No lava tube found!"
      end

      # Check deployed units
      units_deployed = Units::BaseUnit.where(attachable: settlement).count
      puts "  Units deployed: #{units_deployed}"

      puts "\n✅ HABITAT DEVELOPMENT MISSION COMPLETE"
    end

    desc "Generate resource tracking report for a settlement"
    task :report, [:settlement_id, :hours] => :environment do |t, args|
      settlement_id = args[:settlement_id]
      hours = (args[:hours] || 24).to_i.hours

      settlement = Settlement::BaseSettlement.find(settlement_id)
      stats = ResourceTrackingService.get_resource_stats(settlement, hours)

      puts "Resource Tracking Report for #{settlement.name}"
      puts "=" * 50
      puts "Time period: Last #{hours / 1.hour} hours"
      puts ""

      puts "PROCUREMENT SUMMARY:"
      puts "Total operations: #{stats[:procurement_summary][:total_procurement]}"
      puts "Total quantity: #{stats[:procurement_summary][:total_quantity]}"

      puts "\nBY METHOD:"
      stats[:procurement_summary][:by_method].each do |method, quantity|
        puts "  #{method}: #{quantity} units"
      end

      puts "\nBY MATERIAL:"
      stats[:procurement_summary][:by_material].sort_by { |_, qty| -qty }.each do |material, quantity|
        puts "  #{material}: #{quantity} units"
      end

      puts "\nEFFICIENCY METRICS:"
      if stats[:efficiency_metrics]['overall_efficiency']
        eff = stats[:efficiency_metrics]['overall_efficiency']
        puts "ISRU ratio: #{(eff['isru_ratio'] * 100).round(1)}%"
        puts "Import ratio: #{(eff['import_ratio'] * 100).round(1)}%"
        puts "Self-sufficiency: #{eff['self_sufficiency'].round(1)}%"
      end

      puts "\nPROCUREMENT METHOD DETAILS:"
      stats[:efficiency_metrics].except('overall_efficiency').each do |method, metrics|
        next unless metrics.is_a?(Hash)
        puts "  #{method}:"
        puts "    Total quantity: #{metrics['total_quantity']}"
        puts "    Unique materials: #{metrics['unique_materials']}"
        puts "    Average order size: #{metrics['average_order_size'].round(1)}"
        puts "    Procurement frequency: #{(metrics['procurement_frequency'] * 3600).round(2)} per hour"
      end

      puts "\nINVENTORY TRENDS:"
      if stats[:inventory_trends].any?
        stats[:inventory_trends].sort_by { |_, trend| -trend['current'] }.first(10).each do |material, trend|
          puts "  #{material}: #{trend['current']} (#{trend['trend']})"
        end
      else
        puts "  No inventory trend data available"
      end
    end

    desc "Run comprehensive lunar precursor mission test with detailed production logging"
    task :comprehensive_test, [:settlement_id] => :environment do |t, args|
      settlement_id = args[:settlement_id]

      # Create a test settlement if no ID provided
      if settlement_id.nil?
        settlement = create_test_settlement_with_resources
        puts "Created test settlement: #{settlement.name} (ID: #{settlement.id})"
      else
        settlement = Settlement::BaseSettlement.find(settlement_id)
      end

      puts "\n=== COMPREHENSIVE LUNAR PRECURSOR MISSION TEST ==="
      puts "Testing settlement: #{settlement.name}"

      # Take initial inventory snapshot
      initial_snapshot = ResourceTrackingService.track_inventory_snapshot(settlement)
      puts "\n📊 INITIAL INVENTORY:"
      puts "  Items: #{initial_snapshot['total_items'] || 0}"
      puts "  Value: $#{(initial_snapshot['total_value'] || 0).round(2)}"

      # Start the mission
      engine = AIManager::TaskExecutionEngine.new('lunar_precursor')
      task_list = engine.instance_variable_get(:@task_list)

      if task_list.empty?
        puts "❌ No tasks found for lunar_precursor mission"
        exit
      end

      engine.instance_variable_set(:@settlement, settlement)
      mission_identifier = "lunar_precursor_settlement_#{settlement.id}"
      engine.instance_variable_set(:@mission, Mission.find_by(identifier: mission_identifier, settlement: settlement) || Mission.create!(
        identifier: mission_identifier,
        settlement: settlement,
        status: 'in_progress'
      ))

      # Execute all tasks with detailed logging
      while true
        current_index = engine.instance_variable_get(:@current_task_index)
        
        if current_index >= task_list.length
          puts "\n🎯 ALL #{task_list.length} TASKS COMPLETED SUCCESSFULLY!"
          break
        end
        
        task = task_list[current_index]
        puts "\n🔄 ATTEMPTING TASK #{current_index + 1}/#{task_list.length}: #{task['task_id']}"
        puts "   #{task['description']}"
        
        begin
          result = engine.send(:execute_next_task)
          
          if result
            puts "   ✅ COMPLETED TASK #{current_index + 1}/#{task_list.length}"
            
            # Log what was produced/consumed in this task
            produced = engine.instance_variable_get(:@produced_materials)
            consumed = engine.instance_variable_get(:@consumed_materials)

            if produced.any?
              puts "   📦 PRODUCED:"
              produced.each { |mat, qty| puts "      #{mat}: +#{qty}" }
            end

            if consumed.any?
              puts "   ⚡ CONSUMED:"
              consumed.each { |mat, qty| puts "      #{mat}: -#{qty}" }
            end

            # Check for specific infrastructure deployments
            case task['task_id']
            when 'prepare_landing_area'
              puts "   🛬 LANDING PAD: Surface preparation initiated"
            when 'deploy_inflatable_pressure_tank'
              puts "   🗄️  STORAGE: Inflatable pressure tank deployed"
            when 'deploy_cryogenic_tanks'
              puts "   🗃️  STORAGE: 3 cryogenic tanks deployed"
            when 'deploy_shell_printer'
              puts "   🏗️  CONSTRUCTION: Regolith shell printer deployed"
            when 'print_habitat_panels'
              puts "   🏠 SHELLS: 20 habitat panels printed"
            when 'deploy_volatiles_extractor'
              puts "   🌬️  ISRU: Volatiles extractor deployed (ready for extraction)"
            when 'deploy_thermal_extractor'
              puts "   🔥 ISRU: Thermal extraction unit deployed"
            end
          else
            puts "   ❌ TASK #{current_index + 1} FAILED - Stopping mission"
            break
          end
        rescue => e
          puts "   💥 EXCEPTION in task #{current_index + 1}: #{e.message}"
          puts "   #{e.backtrace.first}"
          break
        end

        sleep 0.5 # Brief pause between tasks
      end

      # Get final inventory snapshot
      final_inventory = {}
      settlement.inventory.items.each do |item|
        final_inventory[item.name] = item.amount
      end
      final_items = settlement.inventory.items.count
      final_value = 0 # Simplified, could calculate actual value

      puts "\n" + "=" * 60
      puts "🎯 MISSION COMPLETE!"
      puts "=" * 60

      puts "\n📊 FINAL INVENTORY:"
      puts "  Items: #{final_items}"
      puts "  Value: $#{(final_value).round(2)}"
      puts "  Change: #{final_items} items"

      # Show detailed inventory changes
      initial_inventory = {}
      final_inventory = final_inventory

      puts "\n📋 DETAILED INVENTORY CHANGES:"
      all_materials = (initial_inventory.keys + final_inventory.keys).uniq.sort

      changes = []
      all_materials.each do |material|
        initial_qty = initial_inventory[material] || 0
        final_qty = final_inventory[material] || 0
        change = final_qty - initial_qty
        changes << [material, initial_qty, final_qty, change] if change != 0
      end

      if changes.empty?
        puts "  No inventory changes detected"
      else
        changes.each do |material, initial, final, change|
          puts "  #{material}: #{initial} → #{final} (#{change > 0 ? '+' : ''}#{change})"
        end
      end

      # Check for ISRU production
      puts "\n🔬 ISRU PRODUCTION CHECK:"
      volatiles = ['H2O', 'O2', 'H2', 'CH4', 'LOX', 'carbon_monoxide', 'helium_3', 'neon']
      produced_volatiles = volatiles.select { |v| (final_inventory[v] || 0) > (initial_inventory[v] || 0) }

      if produced_volatiles.any?
        puts "  ✅ Volatiles extracted:"
        produced_volatiles.each do |vol|
          produced_qty = (final_inventory[vol] || 0) - (initial_inventory[vol] || 0)
          puts "     #{vol}: +#{produced_qty}"
        end
      else
        puts "  ⚠️  No volatiles extracted during mission"
        puts "     Note: Mission deploys ISRU equipment but doesn't run extraction cycles"
      end

      # Check for manufactured components
      puts "\n🏭 MANUFACTURING CHECK:"
      components = ['ibeam', 'modular_structural_panel_base', '3d_printed_ibeam_mk1']
      produced_components = components.select { |c| (final_inventory[c] || 0) > (initial_inventory[c] || 0) }

      if produced_components.any?
        puts "  ✅ Components manufactured:"
        produced_components.each do |comp|
          produced_qty = (final_inventory[comp] || 0) - (initial_inventory[comp] || 0)
          puts "     #{comp}: +#{produced_qty}"
        end
      else
        puts "  ⚠️  No components manufactured during mission"
        puts "     Note: Manufacturing tasks may require additional setup"
      end

      # Infrastructure summary
      puts "\n🏗️  INFRASTRUCTURE DEPLOYED:"
      units_deployed = Units::BaseUnit.where(attachable: settlement).count
      rigs_deployed = Rigs::BaseRig.where(attachable: settlement).count

      puts "  Units deployed: #{units_deployed}"
      puts "  Rigs deployed: #{rigs_deployed}"

      # Check storage capacity
      storage_units = Units::BaseUnit.where(attachable: settlement).where(unit_type: ['Inflatable Pressure Tank', 'Inflatable Cryogenic Tank'])
      total_storage = storage_units.sum { |u| u.operational_data&.dig('storage_capacity') || 0 }
      puts "  Storage capacity: #{total_storage} units"

      puts "\n✅ COMPREHENSIVE TEST COMPLETE"
    end
  end
end

# Helper method to create a test settlement for simulation
def create_test_settlement
  # Create a minimal settlement for testing
  player = Player.new(name: "AI Test Player #{Time.current.to_i}", active_location: "Test Settlement")
  player.save(validate: false) # Skip validations that might require account
  
  moon = CelestialBodies::CelestialBody.find_by(name: "Luna") || CelestialBodies::Satellites::LargeMoon.create!(
    name: "Luna",
    identifier: "LUNA-01",
    type: "CelestialBodies::Satellites::LargeMoon",
    size: 0.273,
    gravity: 1.62,
    density: 3.344,
    mass: 7.342e22,
    radius: 1.737e6,
    orbital_period: 27.322,
    albedo: 0.12,
    insolation: 1361,
    surface_temperature: 250,
    known_pressure: 0.0,
    properties: {}
  )
  
  # Create geosphere for Luna with crust composition
  if moon.geosphere
    moon.geosphere.update!(
      crust_composition: {
        "oxides" => {
          "SiO2" => 43.0,
          "Al2O3" => 24.0,
          "FeO" => 13.0,
          "CaO" => 11.0,
          "MgO" => 7.0,
          "TiO2" => 2.0
        },
        "volatiles" => {
          "H2" => 0.0001,
          "He" => 0.00005,
          "CO" => 0.00002,
          "CO2" => 0.00001,
          "CH4" => 0.000005,
          "N2" => 0.000003
        },
        "minerals" => {
          "Anorthite" => 60.0,
          "Ilmenite" => 5.0,
          "KREEP" => 1.0
        }
      }
    )
  else
    moon.create_geosphere!(
      geological_activity: 5,
      crust_composition: {
        "oxides" => {
          "SiO2" => 43.0,
          "Al2O3" => 24.0,
          "FeO" => 13.0,
          "CaO" => 11.0,
          "MgO" => 7.0,
          "TiO2" => 2.0
        },
        "volatiles" => {
          "H2" => 0.0001,
          "He" => 0.00005,
          "CO" => 0.00002,
          "CO2" => 0.00001,
          "CH4" => 0.000005,
          "N2" => 0.000003
        },
        "minerals" => {
          "Anorthite" => 60.0,
          "Ilmenite" => 5.0,
          "KREEP" => 1.0
        }
      }
    )
  end
  location = Location::CelestialLocation.create!(name: "Test Location #{Time.current.to_i}", coordinates: "#{rand(0.00..90.00).round(2)}°N #{rand(0.00..180.00).round(2)}°E", celestial_body: moon)
  
  settlement = Settlement::BaseSettlement.create!(
    name: "AI Test Settlement #{Time.current.to_i}",
    settlement_type: "base",
    current_population: 0,
    operational_data: {},
    owner: player,
    location: location
  )

  # Add some basic starting materials
  settlement.inventory.add_item("regolith", 1000)
  settlement.inventory.add_item("oxygen", 100)
  settlement.inventory.add_item("water", 50)

  settlement.save!
  settlement
end

# Helper method to create a test settlement with resources for comprehensive testing
def create_test_settlement_with_resources
  settlement = create_test_settlement

  # Add substantial regolith for ISRU operations
  settlement.inventory.add_item("raw_regolith", 5000)
  settlement.inventory.add_item("regolith", 2000)

  # Add some initial volatiles that might be needed
  settlement.inventory.add_item("water", 200)
  settlement.inventory.add_item("oxygen", 150)

  # Add construction materials
  settlement.inventory.add_item("inert_regolith_waste", 1000)

  puts "  Added resources: 5000 raw_regolith, 2000 regolith, 200 water, 150 oxygen, 1000 inert_regolith_waste"

  settlement.save!
  settlement
end

# Helper method to create a test settlement that simulates completion of first precursor mission
def create_test_settlement_with_lava_tube
  settlement = create_test_settlement

  # Add substantial resources as if first precursor mission completed
  settlement.inventory.add_item("raw_regolith", 10000)
  settlement.inventory.add_item("regolith", 5000)
  settlement.inventory.add_item("water", 500)
  settlement.inventory.add_item("oxygen", 300)
  settlement.inventory.add_item("inert_regolith_waste", 2000)

  # Generate a lava tube as if first precursor mission completed
  moon = settlement.location.celestial_body
  generator = Generators::LavaTubeGenerator.new(
    random: true,
    params: {
      celestial_body: moon,
      feature_id: "lt_settlement_#{settlement.id}",
      status: 'natural',
      length: 3000,
      diameter: 25,
      height: 15
    }
  )
  lava_tube = generator.generate

  puts "  ✅ Simulated first precursor completion:"
  puts "     • Generated lava tube: #{lava_tube.static_data['dimensions']['length_m']}m × #{lava_tube.static_data['dimensions']['width_m']}m"
  puts "     • Added resources: 10000 raw_regolith, 5000 regolith, 500 water, 300 oxygen"
  puts "     • Infrastructure ready for habitat development"

  settlement.save!
  settlement
end