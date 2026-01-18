#!/bin/bash
# Comprehensive fix for all Geosphere schema mismatches

echo "🔧 COMPREHENSIVE GEOSPHERE SCHEMA FIX"
echo "======================================"
echo ""

echo "Step 1: Identify All Schema Mismatches"
echo "---------------------------------------"
docker exec -it web bash -c "
echo 'Searching for problematic method calls in PrecursorCapabilityService...'
grep -n 'subsurface_water_mass\|ice_mass\|water_ice_mass' app/services/ai_manager/precursor_capability_service.rb || echo 'No matches for water mass methods'
"

echo ""
echo "Step 2: Check What Geosphere Actually Has for Water"
echo "----------------------------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  mars = CelestialBodies::CelestialBody.where('LOWER(name) = ?', 'mars').first
  geo = mars.geosphere
  
  puts 'Geosphere water-related attributes:'
  puts '  stored_volatiles: ' + (geo.stored_volatiles || {}).inspect
  puts '  crust_composition: ' + (geo.crust_composition || {}).keys.join(', ')
  puts '  mantle_composition: ' + (geo.mantle_composition || {}).keys.join(', ')
  
  # Check if there's a hydrosphere
  hydro = mars.hydrosphere rescue nil
  if hydro
    puts ''
    puts 'Hydrosphere attributes:'
    puts hydro.attributes.keys.join(', ')
  else
    puts ''
    puts 'No hydrosphere found'
  end
\"
"

echo ""
echo "Step 3: Create Simplified extract_local_resources Method"
echo "---------------------------------------------------------"
docker exec -it web bash -c "
# Backup
cp app/services/ai_manager/precursor_capability_service.rb app/services/ai_manager/precursor_capability_service.rb.backup4

cat > /tmp/fix_extract_resources.rb << 'RUBY'
  # Extract local resources from celestial body's spheres
  # Returns hash of resources by location: atmosphere, surface, subsurface, regolith
  def extract_local_resources
    resources = {
      atmosphere: [],
      surface: [],
      subsurface: [],
      regolith: []
    }
    
    # ATMOSPHERE
    if atm = @location.atmosphere
      if atm.composition.present?
        atm.composition.each do |gas, percentage|
          resources[:atmosphere] << gas if percentage.to_f > 0.1
        end
      end
    end
    
    # SURFACE & REGOLITH (from geosphere crust)
    if geo = @location.geosphere
      if geo.crust_composition.present?
        composition = geo.crust_composition
        composition.each do |mineral, data|
          percent = data.is_a?(Hash) ? data['percentage'] || data[:percentage] : data
          if percent.to_f > 0.5
            resources[:surface] << mineral
            resources[:regolith] << mineral if mineral.to_s.downcase.include?('regolith') || mineral.to_s.downcase.include?('dust')
          end
        end
      end
      
      # SUBSURFACE (from stored volatiles + mantle)
      if geo.stored_volatiles.present?
        geo.stored_volatiles.each do |volatile, amount|
          resources[:subsurface] << volatile if amount.to_f > 0
        end
      end
      
      if geo.mantle_composition.present?
        geo.mantle_composition.each do |mineral, data|
          percent = data.is_a?(Hash) ? data['percentage'] || data[:percentage] : data
          resources[:subsurface] << mineral if percent.to_f > 1.0
        end
      end
    end
    
    # HYDROSPHERE (could be water, methane, ammonia, etc.)
    if hydro = @location.hydrosphere rescue nil
      if hydro.respond_to?(:composition) && hydro.composition.present?
        # Add the actual chemical composition, not assuming H2O
        hydro.composition.each do |substance, amount|
          # substance could be 'H2O', 'CH4', 'NH3', etc.
          resources[:subsurface] << substance if amount.to_f > 0
        end
      end
    end
    
    # Clean up: remove duplicates, normalize
    resources.each do |location, list|
      resources[location] = list.uniq.map(&:to_s).sort
    end
    
    resources
  end
RUBY

# Find the start and end of the extract_local_resources method
START_LINE=\$(grep -n 'def extract_local_resources' app/services/ai_manager/precursor_capability_service.rb | head -1 | cut -d: -f1)
END_LINE=\$(awk -v start=\"\$START_LINE\" 'NR>start && /^  end$/{print NR; exit}' app/services/ai_manager/precursor_capability_service.rb)

if [ -n \"\$START_LINE\" ] && [ -n \"\$END_LINE\" ]; then
  # Remove old method
  sed -i \"\${START_LINE},\${END_LINE}d\" app/services/ai_manager/precursor_capability_service.rb
  # Insert new method at the same location
  sed -i \"\${START_LINE}r /tmp/fix_extract_resources.rb\" app/services/ai_manager/precursor_capability_service.rb
  echo '✅ Replaced extract_local_resources method'
else
  echo '❌ Could not find method boundaries'
fi
"

echo ""
echo "Step 4: Test MissionPlanner Again"
echo "----------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'Testing with simplified extract_local_resources...'
  puts ''
  
  begin
    planner = AIManager::MissionPlannerService.new('mars-terraforming')
    results = planner.simulate
    
    puts '🎉 SIMULATION SUCCESSFUL!'
    puts ''
    puts '=== LOCAL CAPABILITIES ==='
    lc = results[:local_capabilities]
    puts 'Available: ' + lc[:available].to_s
    puts 'Location: ' + lc[:location]
    puts ''
    puts 'Resources found:'
    [:atmosphere, :surface, :subsurface, :regolith].each do |cat|
      count = lc[cat].length
      puts '  ' + cat.to_s.capitalize.ljust(15) + ': ' + count.to_s + ' types'
      lc[cat].first(5).each { |r| puts '      - ' + r }
      puts '      ...' if count > 5
    end
    
  rescue => e
    puts '❌ Still failing: ' + e.message
    puts e.backtrace.first(3).join(\"\\n\")
  end
\"
"

echo ""
echo "📋 SUMMARY"
echo "=========="
echo "Simplified extract_local_resources to only use attributes that actually exist:"
echo "  ✅ atmosphere.composition"
echo "  ✅ geosphere.crust_composition"
echo "  ✅ geosphere.mantle_composition"
echo "  ✅ geosphere.stored_volatiles"
echo "  ✅ hydrosphere.composition (if exists)"