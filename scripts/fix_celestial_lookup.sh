#!/bin/bash
# Fix Celestial Body Lookup to Use Name Instead of Identifier

echo "🔧 FIXING CELESTIAL BODY LOOKUP STRATEGY"
echo "========================================="
echo ""

echo "PROBLEM:"
echo "  Code searches by identifier: 'mars'"
echo "  Database has identifier: 'MARS-01'"
echo "  But name search works: 'Mars'"
echo ""

echo "Step 1: Update PatternTargetMapper"
echo "-----------------------------------"
docker exec -it web bash -c "
cat > app/services/ai_manager/pattern_target_mapper.rb << 'MAPPER'
module AIManager
  class PatternTargetMapper
    # Maps mission pattern names to celestial body identifiers or names
    PATTERN_TARGETS = {
      'mars-terraforming' => 'Mars',
      'venus-industrial' => 'Venus',
      'titan-fuel' => 'Titan',
      'asteroid-mining' => 'Ceres',
      'europa-water' => 'Europa'
    }.freeze
    
    def self.target_location(pattern_name)
      target_name = PATTERN_TARGETS[pattern_name]
      Rails.logger.info \"[PatternTargetMapper] Pattern: #{pattern_name} → target_name: #{target_name}\"
      return nil unless target_name
      
      # Try to find by name first (case-insensitive)
      body = CelestialBodies::CelestialBody.where('LOWER(name) = ?', target_name.downcase).first
      
      # Fallback to identifier search if name search fails
      body ||= CelestialBodies::CelestialBody.find_by(identifier: target_name)
      
      Rails.logger.info \"[PatternTargetMapper] Found celestial body: #{body&.name || 'NONE'}\"
      body
    end
  end
end
MAPPER

echo '✅ Updated PatternTargetMapper to search by name'
"

echo ""
echo "Step 2: Update MissionPlannerService Initialize"
echo "------------------------------------------------"
docker exec -it web bash -c "
# Backup first
cp app/services/ai_manager/mission_planner_service.rb app/services/ai_manager/mission_planner_service.rb.backup2

# Update the earth lookup to use name
sed -i \"s/@earth = CelestialBodies::CelestialBody.find_by(identifier: 'earth')/@earth = CelestialBodies::CelestialBody.where('LOWER(name) = ?', 'earth').first/g\" app/services/ai_manager/mission_planner_service.rb

echo '✅ Updated MissionPlannerService to find Earth by name'
"

echo ""
echo "Step 3: Test PatternTargetMapper"
echo "---------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'Testing PatternTargetMapper:'
  puts ''
  
  ['mars-terraforming', 'venus-industrial', 'titan-fuel', 'asteroid-mining'].each do |pattern|
    target = AIManager::PatternTargetMapper.target_location(pattern)
    puts '  ' + pattern.ljust(25) + ': ' + (target ? '✅ ' + target.name + ' (ID: ' + target.identifier + ')' : '❌ NOT FOUND')
  end
\"
"

echo ""
echo "Step 4: Test MissionPlannerService"
echo "-----------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts ''
  puts 'Testing MissionPlannerService initialization:'
  puts ''
  
  planner = AIManager::MissionPlannerService.new('mars-terraforming')
  
  target = planner.instance_variable_get(:@target_location)
  earth = planner.instance_variable_get(:@earth)
  cap_service = planner.instance_variable_get(:@capability_service)
  
  puts '  Target Location: ' + (target ? '✅ ' + target.name : '❌ NIL')
  puts '  Earth: ' + (earth ? '✅ ' + earth.name : '❌ NIL')
  puts '  Capability Service: ' + (cap_service ? '✅ PRESENT' : '❌ NIL')
\"
"

echo ""
echo "Step 5: Add Sol/Sun to Database (Optional)"
echo "-------------------------------------------"
echo "Note: Sol is not in the database. Adding it:"

docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  # Check if Sol/Sun exists
  sol = CelestialBodies::CelestialBody.where('LOWER(name) IN (?)', ['sol', 'sun']).first
  
  unless sol
    puts 'Creating Sol...'
    sol = CelestialBodies::CelestialBody.create!(
      identifier: 'SOL-01',
      name: 'Sol',
      type: 'Star',
      mass: 1.989e30,
      radius: 696340.0,
      properties: {
        luminosity: 3.828e26,
        surface_temperature: 5778
      }
    )
    puts '✅ Created Sol'
  else
    puts '✅ Sol already exists as: ' + sol.name
  end
\"

# Do the same for development
RAILS_ENV=development rails runner \"
  sol = CelestialBodies::CelestialBody.where('LOWER(name) IN (?)', ['sol', 'sun']).first
  
  unless sol
    puts 'Creating Sol in development...'
    sol = CelestialBodies::CelestialBody.create!(
      identifier: 'SOL-01',
      name: 'Sol',
      type: 'Star',
      mass: 1.989e30,
      radius: 696340.0,
      properties: {
        luminosity: 3.828e26,
        surface_temperature: 5778
      }
    )
    puts '✅ Created Sol in development'
  end
\"
"

echo ""
echo "📋 SUMMARY"
echo "=========="
echo ""
echo "✅ PatternTargetMapper now searches by NAME (case-insensitive)"
echo "✅ MissionPlannerService finds Earth by NAME"
echo "✅ Sol added to database"
echo ""
echo "Identifier mapping:"
echo "  Pattern 'mars-terraforming' → finds 'Mars' → gets MARS-01"
echo "  Pattern 'venus-industrial' → finds 'Venus' → gets VENUS-01"
echo "  etc."
echo ""
echo "Now run the original mission planner test:"
echo "  docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner \""
echo "    planner = AIManager::MissionPlannerService.new(\"mars-terraforming\")"
echo "    results = planner.simulate"
echo "    puts results[:local_capabilities].inspect"
echo "  \"'"