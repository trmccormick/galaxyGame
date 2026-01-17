#!/bin/bash
# MissionPlanner Integration Diagnostic Script
# Run from your Mac (outside container)

echo "🔍 DIAGNOSTIC TEST SUITE"
echo "========================"
echo ""

echo "📋 Test 1: Verify PatternTargetMapper"
echo "--------------------------------------"
docker exec -it web rails runner "
puts '1. Testing CelestialBody lookup:'
mars = CelestialBodies::CelestialBody.find_by(identifier: 'mars')
puts \"   Mars found: #{mars ? 'YES (' + mars.name + ')' : 'NO - THIS IS THE PROBLEM!'}\"

puts ''
puts '2. Testing PatternTargetMapper:'
target = AIManager::PatternTargetMapper.target_location('mars-terraforming')
puts \"   Target: #{target ? target.name : 'NIL - MAPPER BROKEN!'}\"
"

echo ""
echo "📋 Test 2: Check if Debug Logging Was Added"
echo "--------------------------------------------"
docker exec -it web bash -c "
grep -n 'Rails.logger.info.*MissionPlanner' app/services/ai_manager/mission_planner_service.rb | head -5
"

echo ""
echo "📋 Test 3: Run MissionPlanner and Check Logs"
echo "---------------------------------------------"
docker exec -it web bash -c "
# Clear old logs
> log/development.log

# Run the planner
rails runner \"
  planner = AIManager::MissionPlannerService.new('mars-terraforming')
  results = planner.simulate
  
  puts ''
  puts '=== RESULTS SUMMARY ==='
  puts 'Target: ' + (planner.instance_variable_get(:@target_location)&.name || 'NIL!!!')
  puts 'Capability Service: ' + (planner.instance_variable_get(:@capability_service) ? 'PRESENT' : 'NIL!!!')
  puts ''
  puts 'Local Capabilities:'
  puts results[:local_capabilities].inspect
  puts ''
  puts 'Sample Cost Data (first 3 resources):'
  results[:costs][:breakdown].first(3).each do |resource, data|
    puts \\\"  #{resource}:\\\"
    puts \\\"    Chemical Formula: #{data[:chemical_formula] || 'MISSING!'}\\\"
    puts \\\"    Source Type: #{data[:source_type]}\\\"
    puts \\\"    Source: #{data[:source]}\\\"
    puts \\\"    Transport Cost: #{data[:transport_cost_per_unit]} GCC/kg\\\"
    puts \\\"    Unit Cost: #{data[:unit_cost]} GCC/kg\\\"
    puts ''
  end
\"

echo ''
echo '=== CHECKING LOGS FOR DEBUG OUTPUT ==='
tail -100 log/development.log | grep -i missionplanner
"

echo ""
echo "📋 Test 4: Check calculate_costs Method"
echo "----------------------------------------"
docker exec -it web bash -c "
echo 'Looking for calculate_costs method implementation:'
grep -A 30 'def calculate_costs' app/services/ai_manager/mission_planner_service.rb | head -35
"

echo ""
echo "📋 Test 5: Verify summarize_local_capabilities Exists"
echo "------------------------------------------------------"
docker exec -it web bash -c "
if grep -q 'def summarize_local_capabilities' app/services/ai_manager/mission_planner_service.rb; then
  echo '✅ summarize_local_capabilities method EXISTS'
  grep -A 20 'def summarize_local_capabilities' app/services/ai_manager/mission_planner_service.rb
else
  echo '❌ summarize_local_capabilities method MISSING - THIS IS A PROBLEM!'
fi
"

echo ""
echo "📋 Test 6: Check TransportCostService"
echo "--------------------------------------"
docker exec -it web rails runner "
puts 'Testing TransportCostService directly:'
begin
  cost = Logistics::TransportCostService.calculate_cost_per_kg(
    from: 'earth',
    to: 'mars',
    resource: 'water'
  )
  puts \"  Earth → Mars transport: #{cost} GCC/kg\"
  puts \"  \" + (cost > 0 ? '✅ Working!' : '❌ Returns 0 - THIS IS THE PROBLEM!')
rescue => e
  puts \"  ❌ ERROR: #{e.message}\"
  puts \"  This is why transport costs are 0!\"
end
"

echo ""
echo "📋 Test 7: Check simulate Method"
echo "---------------------------------"
docker exec -it web bash -c "
echo 'Checking simulate method structure:'
grep -A 15 'def simulate' app/services/ai_manager/mission_planner_service.rb | grep -E 'local_capabilities|timeline|resources|costs'
"

echo ""
echo "🎯 SUMMARY: Check the output above for:"
echo "  1. Is Mars being found? (Test 1)"
echo "  2. Are debug logs present? (Test 2)"
echo "  3. What do the actual results show? (Test 3)"
echo "  4. Is calculate_costs calling calculate_total_delivered_cost? (Test 4)"
echo "  5. Does summarize_local_capabilities exist? (Test 5)"
echo "  6. Is TransportCostService working? (Test 6)"
echo "  7. Is simulate calling local_capabilities? (Test 7)"
echo ""
echo "Run this and share the output - we'll identify the exact problem!"