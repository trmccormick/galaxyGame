#!/bin/bash
# Fix PrecursorCapabilityService to use correct Geosphere attributes

echo "🔧 FIXING PRECURSORCAPABILITYSERVICE"
echo "====================================="
echo ""

echo "The fix: Change 'surface_composition' to 'crust_composition'"
echo ""

echo "Step 1: Backup and Fix PrecursorCapabilityService"
echo "--------------------------------------------------"
docker exec -it web bash -c "
# Backup
cp app/services/ai_manager/precursor_capability_service.rb app/services/ai_manager/precursor_capability_service.rb.backup3

# Fix: Replace surface_composition with crust_composition
sed -i 's/geo\.surface_composition/geo.crust_composition/g' app/services/ai_manager/precursor_capability_service.rb

echo '✅ Fixed surface_composition → crust_composition'

# Verify the fix
echo ''
echo 'Verification - checking fixed lines:'
grep -n 'crust_composition' app/services/ai_manager/precursor_capability_service.rb | head -5
"

echo ""
echo "Step 2: Test MissionPlanner Initialization"
echo "-------------------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'Testing MissionPlannerService with fixed PrecursorCapabilityService...'
  puts ''
  
  begin
    planner = AIManager::MissionPlannerService.new('mars-terraforming')
    
    target = planner.instance_variable_get(:@target_location)
    earth = planner.instance_variable_get(:@earth)
    cap_service = planner.instance_variable_get(:@capability_service)
    
    puts '✅ Target Location: ' + target.name
    puts '✅ Earth: ' + earth.name
    puts '✅ Capability Service: INITIALIZED'
    puts ''
    
    # Test capability service methods
    caps = cap_service.production_capabilities
    puts 'Production Capabilities:'
    puts '  Atmosphere: ' + caps[:atmosphere].inspect
    puts '  Surface: ' + caps[:surface].inspect
    puts '  Subsurface: ' + caps[:subsurface].inspect
    puts '  Regolith: ' + caps[:regolith].inspect
    puts ''
    
    # Test can_produce_locally
    test_chemicals = ['CO2', 'H2O', 'O2', 'SiO2', 'Fe']
    puts 'Testing can_produce_locally:'
    test_chemicals.each do |chem|
      result = cap_service.can_produce_locally?(chem)
      puts '  ' + chem.ljust(6) + ': ' + (result ? '✅ YES' : '❌ NO')
    end
    
  rescue => e
    puts '❌ Error: ' + e.message
    puts 'Backtrace:'
    puts e.backtrace.first(10).join(\"\\n\")
  end
\"
"

echo ""
echo "Step 3: Run Full Simulation Test"
echo "---------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'Running full Mars terraforming simulation...'
  puts ''
  
  begin
    planner = AIManager::MissionPlannerService.new('mars-terraforming')
    results = planner.simulate
    
    puts '=== SIMULATION RESULTS ==='
    puts ''
    puts 'Local Capabilities:'
    lc = results[:local_capabilities]
    puts '  Available: ' + lc[:available].to_s
    puts '  Location: ' + lc[:location].to_s
    puts '  Atmosphere resources: ' + lc[:atmosphere].length.to_s
    puts '  Surface resources: ' + lc[:surface].length.to_s
    puts '  Subsurface resources: ' + lc[:subsurface].length.to_s
    puts '  Regolith resources: ' + lc[:regolith].length.to_s
    puts ''
    
    puts 'Sample Cost Data (first 2 resources):'
    results[:costs][:breakdown].first(2).each do |resource, data|
      puts '  ' + resource + ':'
      puts '    Chemical Formula: ' + (data[:chemical_formula] || 'N/A')
      puts '    Source: ' + data[:source]
      puts '    Source Type: ' + data[:source_type]
      puts '    Transport Cost: ' + data[:transport_cost_per_unit].to_s + ' GCC/kg'
      puts ''
    end
    
    puts '✅ SIMULATION COMPLETE!'
    
  rescue => e
    puts '❌ Simulation failed: ' + e.message
    puts e.backtrace.first(5).join(\"\\n\")
  end
\"
"

echo ""
echo "📋 SUMMARY"
echo "=========="
echo "✅ Fixed PrecursorCapabilityService to use crust_composition"
echo "✅ Should now be able to extract Mars surface resources"
echo ""
echo "If successful, you should see:"
echo "  - CO2 available (from atmosphere)"
echo "  - Regolith/SiO2 available (from crust)"
echo "  - Local production costs calculated"