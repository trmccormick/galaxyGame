#!/bin/bash
# Fix volatile_reservoirs method name

echo "🔧 FIXING volatile_reservoirs → stored_volatiles"
echo "================================================="
echo ""

echo "Step 1: Find and Replace volatile_reservoirs"
echo "---------------------------------------------"
docker exec -it web bash -c "
# Show what needs to be fixed
echo 'Lines with volatile_reservoirs:'
grep -n 'volatile_reservoirs' app/services/ai_manager/precursor_capability_service.rb

echo ''
echo 'Fixing: volatile_reservoirs → stored_volatiles'

# Replace
sed -i 's/volatile_reservoirs/stored_volatiles/g' app/services/ai_manager/precursor_capability_service.rb

echo ''
echo 'Verification:'
grep -n 'stored_volatiles' app/services/ai_manager/precursor_capability_service.rb | head -3
"

echo ""
echo "Step 2: Test Full Simulation Again"
echo "-----------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'Testing MissionPlanner with all fixes...'
  puts ''
  
  begin
    planner = AIManager::MissionPlannerService.new('mars-terraforming')
    results = planner.simulate
    
    puts '✅ SIMULATION SUCCESSFUL!'
    puts ''
    puts '=== LOCAL CAPABILITIES ==='
    lc = results[:local_capabilities]
    puts 'Available: ' + lc[:available].to_s
    puts 'Location: ' + lc[:location]
    puts ''
    puts 'Resources by category:'
    puts '  Atmosphere: ' + lc[:atmosphere].length.to_s + ' types'
    lc[:atmosphere].each { |r| puts '    - ' + r.to_s }
    puts '  Surface: ' + lc[:surface].length.to_s + ' types'
    lc[:surface].each { |r| puts '    - ' + r.to_s }
    puts '  Subsurface: ' + lc[:subsurface].length.to_s + ' types'
    lc[:subsurface].each { |r| puts '    - ' + r.to_s }
    puts '  Regolith: ' + lc[:regolith].length.to_s + ' types'
    lc[:regolith].each { |r| puts '    - ' + r.to_s }
    puts ''
    puts 'Precursor enables:'
    lc[:precursor_enables].each do |k, v|
      puts '  ' + k.to_s.ljust(25) + ': ' + (v ? '✅' : '❌')
    end
    puts ''
    puts '=== COST BREAKDOWN (First 3 Resources) ==='
    results[:costs][:breakdown].first(3).each do |resource, data|
      puts resource + ':'
      puts '  Chemical Formula: ' + (data[:chemical_formula] || 'N/A')
      puts '  Source: ' + data[:source]
      puts '  Source Type: ' + data[:source_type]
      puts '  Unit Cost: ' + data[:unit_cost].to_s + ' GCC/kg'
      puts '  Transport Cost: ' + data[:transport_cost_per_unit].to_s + ' GCC/kg'
      puts '  Total Cost: ' + data[:total].to_s + ' GCC'
      puts ''
    end
    
  rescue => e
    puts '❌ Error: ' + e.message
    puts 'Backtrace:'
    puts e.backtrace.first(10).join(\"\\n\")
  end
\"
"

echo ""
echo "📋 SUCCESS CRITERIA"
echo "==================="
echo "If working correctly, you should see:"
echo "  ✅ Atmosphere resources (CO2, etc.)"
echo "  ✅ Surface/regolith resources (SiO2, etc.)"
echo "  ✅ Some resources marked as 'Local ISRU'"
echo "  ✅ Transport costs = 0 for local resources"
echo "  ✅ Transport costs > 0 for Earth imports"