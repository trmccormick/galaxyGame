# DIAGNOSTIC: Sol System Seeding Issue

## What We See
Dashboard shows for Sol system:
- ✅ 10 Celestial Bodies (total count correct)
- ✅ 2 Stars (both showing as "Sol" - duplicate display issue)
- ❌ 0 Terrestrial Planets (should be 4: Mercury, Venus, Earth, Mars)
- ❌ 0 Gas/Ice Giants (should be 4: Jupiter, Saturn, Uranus, Neptune)

## Hypothesis: Bodies Created but Not Categorized

The fact that we see "10 Celestial Bodies" suggests the records ARE being created, but:
1. Either they're not using the correct STI type
2. Or the dashboard query is filtering them out incorrectly

## Investigation Steps for Grok

### Step 1: Check What Actually Got Created
```ruby
# In Rails console:
system = SolarSystem.find_by(name: 'Sol')
bodies = system.celestial_bodies

puts "Total bodies: #{bodies.count}"
puts "\nBody types:"
bodies.each do |body|
  puts "  #{body.name}: #{body.type} (STI class: #{body.class.name})"
end

# Check specifically for Earth
earth = CelestialBodies::CelestialBody.find_by(name: 'Earth')
if earth
  puts "\nEarth details:"
  puts "  Type field: #{earth.type}"
  puts "  STI class: #{earth.class.name}"
  puts "  Size: #{earth.size}"
  puts "  Mass: #{earth.mass}"
  puts "  Radius: #{earth.radius}"
else
  puts "\nERROR: Earth not found!"
end
```

### Step 2: Check STI Type Mapping

The issue might be in `determine_model_class`. The JSON has:
```json
"type": "terrestrial_planet"
```

But the code maps:
```ruby
when "terrestrial" then CelestialBodies::Planets::Rocky::TerrestrialPlanet
```

Notice the mismatch: `"terrestrial_planet"` vs `"terrestrial"`

**Check if this is the bug:**
```ruby
# In console:
body_data = { type: "terrestrial_planet" }

# This should match, but might not:
case body_data[:type].to_s
when "terrestrial" then puts "MATCH"
when "terrestrial_planet" then puts "WOULD MATCH IF ADDED"
else puts "NO MATCH"
end
```

### Step 3: Check the Dashboard Query

The dashboard might be filtering by STI class incorrectly.

**Find the controller code:**
```bash
# In container:
grep -r "Terrestrial Planets" app/controllers/admin/
grep -r "celestial_bodies" app/controllers/admin/solar_systems_controller.rb
```

**Likely issue:** Dashboard is doing:
```ruby
terrestrial_planets = system.celestial_bodies.where(type: 'CelestialBodies::Planets::Rocky::TerrestrialPlanet')
```

But if bodies were created with the wrong STI type due to mapping issue, this query returns empty.

## Likely Root Cause

**BUG IN determine_model_class:**

JSON format uses:
- `"type": "terrestrial_planet"` (with underscore)
- `"type": "gas_giant"` (with underscore)
- `"type": "ice_giant"` (with underscore)

Code matches:
- `when "terrestrial"` (no underscore)
- `when "gas_giant"` (matches!)
- `when "ice_giant"` (matches!)

So:
- ✅ Gas giants work
- ✅ Ice giants work  
- ❌ Terrestrial planets DON'T match → fall through to default
- ❌ Default creates generic `CelestialBodies::CelestialBody` (not the STI subclass)

## Fix Required

In `system_builder_service.rb`, line ~318, change:

```ruby
# BEFORE (broken):
when "terrestrial" then CelestialBodies::Planets::Rocky::TerrestrialPlanet

# AFTER (fixed):
when "terrestrial", "terrestrial_planet" then CelestialBodies::Planets::Rocky::TerrestrialPlanet
```

## Testing After Fix

```ruby
# Should now show correct types:
system = SolarSystem.find_by(name: 'Sol')
terrestrial = system.celestial_bodies.where(type: 'CelestialBodies::Planets::Rocky::TerrestrialPlanet')
gas_giants = system.celestial_bodies.where(type: 'CelestialBodies::Planets::Gaseous::GasGiant')
ice_giants = system.celestial_bodies.where(type: 'CelestialBodies::Planets::Gaseous::IceGiant')

puts "Terrestrial planets: #{terrestrial.count} (should be 4)"
puts "Gas giants: #{gas_giants.count} (should be 2)"
puts "Ice giants: #{ice_giants.count} (should be 2)"
```

## Also Fix: Duplicate Sol Stars

The dashboard shows TWO Sol stars with identical data. This suggests:

**Either:**
1. The JSON file has two star entries
2. The star creation code is calling `find_or_create_by` with wrong uniqueness constraint

**Check:**
```ruby
stars = CelestialBodies::Star.where(solar_system_id: system.id)
puts "Stars in Sol system: #{stars.count}"
stars.each do |star|
  puts "  #{star.name} (identifier: #{star.identifier})"
end
```

**If duplicates exist:** Fix the uniqueness constraint in `create_star_record` method.

## Terrain Not Saving Issue

This is a **separate issue**. Even after bodies are created correctly, terrain generation might fail.

**Check:**
```ruby
earth = CelestialBodies::CelestialBody.find_by(name: 'Earth')
if earth&.geosphere
  puts "Geosphere exists: #{earth.geosphere.id}"
  puts "Terrain map present: #{earth.geosphere.terrain_map.present?}"
  if earth.geosphere.terrain_map
    puts "Terrain dimensions: #{earth.geosphere.terrain_map['width']}x#{earth.geosphere.terrain_map['height']}"
  end
else
  puts "ERROR: No geosphere for Earth!"
end
```

**If geosphere doesn't exist:** The `create_geosphere` method might be failing silently.

**If terrain_map is nil:** The `generate_automatic_terrain` method might not be running or is failing.

## Action Items for Grok

1. **Run diagnostics in Rails console** (Step 1)
2. **Fix STI type mapping** for "terrestrial_planet" (add to case statement)
3. **Re-seed database:** `rails db:reset && rails db:seed`
4. **Verify dashboard shows correct counts**
5. **Investigate duplicate stars issue**
6. **Check terrain generation** (separate from type mapping issue)

## Expected Outcome After Fix

```
Sol System:
- 10 Celestial Bodies ✅
- 2 Stars (Sol only, not duplicate) ✅
- 4 Terrestrial Planets (Mercury, Venus, Earth, Mars) ✅
- 2 Gas Giants (Jupiter, Saturn) ✅
- 2 Ice Giants (Uranus, Neptune) ✅
```

Then proceed to terrain generation fix.
