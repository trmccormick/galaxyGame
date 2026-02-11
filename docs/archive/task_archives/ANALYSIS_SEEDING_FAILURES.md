# ANALYSIS: System Seeding Failures - February 10, 2026

## Current State Assessment

### Symptoms Observed
1. **Dashboard shows systems with 0 planets**
   - Sol system exists (ID: 3) but has 0 bodies
   - Eden system exists (ID: 2) but has 0 bodies
   - `CelestialBodies::CelestialBody.count => 0`

2. **All planet creation fails with same error**
   ```
   ERROR: Failed to create Eden II: Size can't be blank, Size is not a number
   Failed attributes: {"size" => nil, ...}
   ```

3. **Duplicate Sol systems loading**
   - Both `sol.json` and `sol-complete.json` are being processed
   - Should only load `sol-complete.json` (the complete version)

4. **Cascading failures**
   - Planets fail → Moons can't find parents → Entire system empty

## Root Cause Analysis

### Issue 1: Missing `size` Attribute Mapping

**JSON Data (correct):**
```json
{
  "size": 0.8857333778854206,
  "mass": 3.661640510358585e+24,
  "radius": 5643007.350508015
}
```

**Model receives (incorrect):**
```ruby
{
  "size" => nil,
  "mass" => 0.3661640510358585e25,
  "radius" => 0.564300735051e7
}
```

**Location of bug:** `app/services/star_sim/system_builder_service.rb`

The service is **not mapping the `size` field** from JSON to the ActiveRecord attributes.

**Expected behavior:**
```ruby
attributes = {
  size: planet_data['size'],  # ← Missing this line
  mass: planet_data['mass'],
  radius: planet_data['radius'],
  ...
}
```

### Issue 2: JSON File Selection Logic

**Current behavior:**
```ruby
# Loads ALL .json files in data/json-data/star_systems/
Dir.glob('data/json-data/star_systems/**/*.json').each do |file|
  # Processes both sol.json AND sol-complete.json
end
```

**Expected behavior:**
- Only load `*-complete.json` files OR
- Exclude files matching `*-test.json` or non-complete variants

**Files that should load:**
- ✅ `sol-complete.json` (complete Sol system)
- ✅ `aol-732356.json` (complete AOL system)
- ✅ `atjd-566085.json` (complete ATJD system)

**Files that should NOT load:**
- ❌ `sol.json` (partial/test version)

### Issue 3: Validation Requirements

**Model validation (correct):**
```ruby
class CelestialBody < ApplicationRecord
  validates :size, presence: true, numericality: true
end
```

**JSON provides data (correct):**
```json
"size": 0.8857333778854206
```

**Mapping is broken (bug):**
The SystemBuilder is not extracting `size` from JSON, so model validation correctly fails.

## Impact Assessment

### Immediate Impact
- ❌ Cannot seed any systems (Sol, AOL-732356, ATJD-566085)
- ❌ Dashboard shows empty systems
- ❌ Monitor view has no bodies to display
- ❌ AI Manager has no bodies to generate terrain for
- ❌ Civilization layer has no bodies to load features for

### Development Impact
- 🚫 **Blocks terrain generation testing** (no planets to test on)
- 🚫 **Blocks monitor view improvements** (nothing to render)
- 🚫 **Blocks civilization layer work** (no Earth to show cities on)
- 🚫 **Blocks AI Manager training** (no bodies to learn patterns from)

This is a **CRITICAL BLOCKER** for all current work streams.

## Required Fixes

### Fix 1: Add `size` Attribute Mapping (CRITICAL)

**File:** `app/services/star_sim/system_builder_service.rb`

**Method:** `create_celestial_body` or similar planet creation method

**Required change:**
```ruby
def build_planet_attributes(planet_data)
  {
    identifier: planet_data['identifier'],
    name: planet_data['name'],
    type: planet_data['type'],
    size: planet_data['size'],  # ← ADD THIS LINE
    mass: planet_data['mass'],
    radius: planet_data['radius'],
    density: planet_data['density'],
    gravity: planet_data['gravity'],
    # ... rest of attributes
  }
end
```

### Fix 2: Filter JSON File Loading (HIGH)

**File:** Seed file or SystemBuilder initialization

**Current code:**
```ruby
Dir.glob('data/json-data/star_systems/**/*.json')
```

**Fixed code:**
```ruby
# Option A: Only load complete files
Dir.glob('data/json-data/star_systems/**/*-complete.json') +
Dir.glob('data/json-data/star_systems/**/aol-*.json') +
Dir.glob('data/json-data/star_systems/**/atjd-*.json')

# Option B: Exclude test files
Dir.glob('data/json-data/star_systems/**/*.json')
   .reject { |f| f.include?('sol.json') }  # Exclude non-complete variants
```

### Fix 3: Improve Error Logging (MEDIUM)

Add better debugging output to see which attributes are missing:

```ruby
def create_celestial_body(data)
  attributes = build_attributes(data)
  
  # Log what we're trying to create
  Rails.logger.debug "Creating #{data['name']} with attributes: #{attributes.inspect}"
  
  body = CelestialBodies::CelestialBody.new(attributes)
  
  unless body.valid?
    Rails.logger.error "Failed to create #{data['name']}: #{body.errors.full_messages.join(', ')}"
    Rails.logger.error "Failed attributes: #{body.attributes.inspect}"
    return nil
  end
  
  body.save!
end
```

## Testing Strategy

### Step 1: Verify Fix in Rails Console
```ruby
# In docker container
docker exec -it web rails console

# Test attribute extraction
data = {"size" => 0.885, "mass" => 3.66e24, "radius" => 5.64e6}
attributes = SystemBuilder.build_planet_attributes(data)
puts attributes[:size]  # Should output: 0.885, NOT nil

# Test JSON loading
files = Dir.glob('data/json-data/star_systems/**/*.json')
puts files  # Should NOT include 'sol.json'
```

### Step 2: Test Planet Creation
```ruby
# Load AOL-732356 JSON
json = JSON.parse(File.read('data/json-data/star_systems/aol-732356.json'))
planet_data = json['celestial_bodies']['terrestrial_planets'].first

# Try creating planet
builder = StarSim::SystemBuilderService.new
planet = builder.create_planet(planet_data, star_system_id: 1)

puts planet.valid?  # Should be true
puts planet.size    # Should be 0.8857, NOT nil
```

### Step 3: Full Seeding Test
```bash
# In container
docker exec -it web bash
cd /home/galaxy_game

# Clear existing data
rails db:reset

# Reseed
rails db:seed

# Verify
rails runner "puts CelestialBodies::CelestialBody.count"  # Should be > 0
```

### Step 4: Verify in Dashboard
```
Navigate to: http://localhost:3000/admin/dashboard
Expected: See Sol system with 8+ planets
```

## Success Criteria

- [ ] `size` attribute correctly mapped from JSON to model
- [ ] Only complete JSON files loaded (not test variants)
- [ ] All Sol system planets created (Earth, Mars, etc.)
- [ ] All AOL-732356 planets created
- [ ] Dashboard shows systems with planet counts
- [ ] `CelestialBodies::CelestialBody.count > 0`
- [ ] Monitor view can load planets
- [ ] No validation errors in seed output

## Files to Review/Modify

1. **MUST FIX:**
   - `app/services/star_sim/system_builder_service.rb` - Add size mapping

2. **SHOULD FIX:**
   - `db/seeds.rb` or system loading logic - Filter JSON files

3. **NICE TO HAVE:**
   - Add validation logging for better debugging
   - Document which JSON files are canonical vs test

## Next Steps for Implementation Agent

1. **Read this analysis document completely**
2. **Review `system_builder_service.rb` to locate attribute mapping**
3. **Add `size` field to attribute hash**
4. **Test in console before seeding**
5. **Run full seed and verify**
6. **Update documentation with findings**

## Questions to Answer

1. **Where exactly is the attribute mapping done?**
   - Is it in `build_planet_attributes`?
   - Is it in a separate method?
   - Is it using metaprogramming that's excluding `size`?

2. **Why is size excluded?**
   - Intentional (bug in code)?
   - Accidental (missed in list)?
   - Model issue (size not in schema)?

3. **Are other attributes missing?**
   - Check if `albedo`, `insolation`, etc. are also `nil`

4. **Is the model schema correct?**
   ```bash
   docker exec -it web rails console
   CelestialBodies::CelestialBody.column_names
   # Should include 'size'
   ```

---

**STATUS:** Analysis complete. Ready for implementation agent command.

**PRIORITY:** 🔥 CRITICAL - Blocks all planetary work
