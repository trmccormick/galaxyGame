#!/bin/bash
# Fix remaining issues with PrecursorCapabilityService and Sol

echo "🔧 FIXING REMAINING ISSUES"
echo "=========================="
echo ""

echo "Issue 1: PrecursorCapabilityService calling undefined method"
echo "Issue 2: Sol creation failing due to 'type' column (STI)"
echo ""

echo "Step 1: Check Geosphere Schema"
echo "-------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  schema = ActiveRecord::Base.connection.columns(:geospheres)
  puts 'Geosphere columns:'
  schema.each do |col|
    puts '  - ' + col.name
  end
\"
"

echo ""
echo "Step 2: Fix PrecursorCapabilityService"
echo "---------------------------------------"
docker exec -it web bash -c "
# Find the line with surface_composition and see what the actual method should be
echo 'Checking PrecursorCapabilityService for surface_composition usage:'
grep -n 'surface_composition' app/services/ai_manager/precursor_capability_service.rb

echo ''
echo 'This method probably should be using a different attribute.'
echo 'We need to check what attributes Geosphere actually has.'
"

echo ""
echo "Step 3: Test What Geosphere Actually Returns"
echo "---------------------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  mars = CelestialBodies::CelestialBody.where('LOWER(name) = ?', 'mars').first
  if mars
    puts 'Mars geosphere:'
    geo = mars.geosphere
    if geo
      puts '  Found geosphere'
      puts '  Attributes: ' + geo.attributes.keys.join(', ')
      puts '  Composition: ' + (geo.composition || {}).inspect
    else
      puts '  No geosphere found'
    end
    
    puts ''
    puts 'Mars atmosphere:'
    atm = mars.atmosphere
    if atm
      puts '  Found atmosphere'
      puts '  Attributes: ' + atm.attributes.keys.join(', ')
      puts '  Composition: ' + (atm.composition || {}).inspect
    else
      puts '  No atmosphere found'
    end
  end
\"
"

echo ""
echo "Step 4: Skip Sol Creation (Not Critical)"
echo "------------------------------------------"
echo "Sol is not critical for Mars terraforming mission."
echo "The 'type' column is used for Single Table Inheritance."
echo "If you need Sol later, we'll need to either:"
echo "  1. Rename the 'type' column to something else (body_type)"
echo "  2. Or set CelestialBody.inheritance_column = nil"
echo ""
echo "Skipping Sol creation for now..."

echo ""
echo "Step 5: Quick Test of MissionPlanner"
echo "-------------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'Testing MissionPlannerService initialization...'
  begin
    planner = AIManager::MissionPlannerService.new('mars-terraforming')
    
    target = planner.instance_variable_get(:@target_location)
    earth = planner.instance_variable_get(:@earth)
    
    puts '✅ Target: ' + target.name if target
    puts '✅ Earth: ' + earth.name if earth
    puts ''
    puts 'Initialization successful! But capability service may have errors...'
  rescue => e
    puts '❌ Error: ' + e.message
    puts 'Backtrace:'
    puts e.backtrace.first(5).join(\"\\n\")
  end
\"
"

echo ""
echo "📋 NEXT STEPS"
echo "============="
echo ""
echo "The output above will tell us what method Geosphere actually has."
echo "Then we need to update PrecursorCapabilityService to use the correct attribute."
echo ""
echo "Likely fixes:"
echo "  - Change 'surface_composition' to 'composition'"
echo "  - Or check if it's stored in a JSONB field"
echo ""
echo "Share the Geosphere schema output and I'll create the exact fix!"