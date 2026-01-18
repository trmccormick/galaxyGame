#!/bin/bash
# Restore from backup and manually fix the specific problematic lines

echo "🔧 RESTORING AND FIXING PRECURSORCAPABILITYSERVICE"
echo "==================================================="
echo ""

echo "Step 1: Restore from Backup"
echo "----------------------------"
docker exec -it web bash -c "
if [ -f app/services/ai_manager/precursor_capability_service.rb.backup4 ]; then
  cp app/services/ai_manager/precursor_capability_service.rb.backup4 app/services/ai_manager/precursor_capability_service.rb
  echo '✅ Restored from backup4'
elif [ -f app/services/ai_manager/precursor_capability_service.rb.backup3 ]; then
  cp app/services/ai_manager/precursor_capability_service.rb.backup3 app/services/ai_manager/precursor_capability_service.rb
  echo '✅ Restored from backup3'
else
  echo '❌ No backup found!'
fi
"

echo ""
echo "Step 2: Fix Specific Problematic Lines"
echo "---------------------------------------"
docker exec -it web bash -c "
echo 'Fixing line 140: subsurface_water_mass'
# Comment out or remove the subsurface_water_mass check
sed -i '140s/.*/      # Removed: subsurface_water_mass not in schema/' app/services/ai_manager/precursor_capability_service.rb

echo 'Fixing line 160: ice_mass and polar_ice_mass'
# Comment out the ice_mass checks
sed -i '160s/.*/      # Removed: ice_mass, polar_ice_mass not in schema/' app/services/ai_manager/precursor_capability_service.rb

echo ''
echo 'Verification - checking fixed lines:'
sed -n '138,142p' app/services/ai_manager/precursor_capability_service.rb
echo '...'
sed -n '158,162p' app/services/ai_manager/precursor_capability_service.rb
"

echo ""
echo "Step 3: Test if File is Valid Ruby"
echo "-----------------------------------"
docker exec -it web bash -c "
ruby -c app/services/ai_manager/precursor_capability_service.rb
"

echo ""
echo "Step 4: Test MissionPlanner"
echo "----------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'Testing MissionPlanner...'
  begin
    planner = AIManager::MissionPlannerService.new('mars-terraforming')
    puts '✅ MissionPlanner initialized successfully'
    
    results = planner.simulate
    puts '✅ Simulation completed!'
    puts ''
    puts 'Local capabilities: ' + results[:local_capabilities][:available].to_s
    
  rescue => e
    puts '❌ Error: ' + e.message
    puts e.backtrace.first(5).join(\"\\n\")
  end
\"
"

echo ""
echo "📋 NEXT STEPS"
echo "============="
echo "If it still fails, we need to see the actual extract_local_resources method"
echo "to understand its structure and fix it properly."