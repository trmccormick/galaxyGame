# COMMAND: Fix System Seeding - Missing Size Attribute

## READ FIRST: ANALYSIS_SEEDING_FAILURES.md

I've uploaded `ANALYSIS_SEEDING_FAILURES.md` which contains:
- Complete symptom analysis (0 planets created, all validation failures)
- Root cause identification (`size` attribute not mapped from JSON)
- Impact assessment (blocks ALL planetary work)
- Testing strategy
- Success criteria

**READ THE ANALYSIS DOCUMENT BEFORE PROCEEDING.**

## The Problem (Summary)

**Current state:**
```bash
CelestialBodies::CelestialBody.count => 0  # NO PLANETS CREATED
```

**Why:**
- JSON has: `"size": 0.8857333778854206` ✅
- Model receives: `"size" => nil` ❌
- Validation fails: "Size can't be blank"

**The SystemBuilder is not mapping the `size` field from JSON to ActiveRecord attributes.**

## Your Tasks

### Task 1: Locate the Bug (Investigation)

**File to check:** `app/services/star_sim/system_builder_service.rb`

Look for methods that build attributes from JSON:
- `build_planet_attributes`
- `create_celestial_body`
- `map_json_to_model`
- Or similar attribute mapping code

**In Rails console, verify the issue:**
```ruby
# Test that schema has size column
CelestialBodies::CelestialBody.column_names.include?('size')  # Should be true

# Load JSON manually
json = JSON.parse(File.read('data/json-data/star_systems/aol-732356.json'))
planet_data = json['celestial_bodies']['terrestrial_planets'].first

# Check JSON has size
planet_data['size']  # Should be 0.8857..., not nil

# Now trace through SystemBuilder to see where size gets lost
```

### Task 2: Fix the Attribute Mapping (Critical Fix)

**Add the missing `size` mapping.**

Example (adjust to match actual code structure):
```ruby
def build_planet_attributes(planet_data)
  {
    identifier: planet_data['identifier'],
    name: planet_data['name'],
    type: determine_planet_type(planet_data),
    size: planet_data['size'],  # ← ADD THIS LINE
    mass: planet_data['mass'],
    radius: planet_data['radius'],
    density: planet_data['density'],
    gravity: planet_data['gravity'],
    surface_temperature: planet_data['surface_temperature'],
    albedo: planet_data['albedo'],
    # ... other fields
  }
end
```

**Check for other missing fields too:**
- Is `albedo` being mapped?
- Is `insolation` being mapped?
- Is `orbital_period` being mapped?

Add any other missing fields you find.

### Task 3: Fix JSON File Loading (High Priority)

**Current issue:** Both `sol.json` AND `sol-complete.json` are loading.

**Find where JSON files are loaded** (probably in `db/seeds.rb` or SystemBuilder initialization).

**Current code might look like:**
```ruby
Dir.glob('data/json-data/star_systems/**/*.json').each do |file|
  # Processes ALL .json files
end
```

**Fix to:**
```ruby
# Only load complete/canonical files
json_files = Dir.glob('data/json-data/star_systems/**/*.json')
                .reject { |f| f.match?(/sol\.json$/) }  # Exclude partial test file
                
# Or explicitly list complete files
json_files = [
  'data/json-data/star_systems/sol-complete.json',
  'data/json-data/star_systems/aol-732356.json',
  'data/json-data/star_systems/atjd-566085.json'
]

json_files.each do |file|
  # Process only complete systems
end
```

### Task 4: Test the Fix

**In Rails console (inside Docker):**
```ruby
# Clear database
ActiveRecord::Base.connection.execute("TRUNCATE TABLE celestial_bodies CASCADE")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE solar_systems CASCADE")

# Load one system manually to test
json = JSON.parse(File.read('data/json-data/star_systems/aol-732356.json'))
builder = StarSim::SystemBuilderService.new(json)
builder.build_system

# Verify planets created
puts CelestialBodies::CelestialBody.count  # Should be > 0
puts CelestialBodies::CelestialBody.first.size  # Should NOT be nil

# Check specific planet
eden = CelestialBodies::CelestialBody.find_by(name: 'Eden II')
puts "Eden II size: #{eden&.size}"  # Should be 0.8857...
puts "Eden II valid: #{eden&.valid?}"  # Should be true
```

**If console test passes, run full seed:**
```bash
docker exec -it web bash -c "cd /home/galaxy_game && rails db:reset && rails db:seed"
```

**Verify in Rails runner:**
```bash
docker exec -it web rails runner "puts CelestialBodies::CelestialBody.count"
# Should output: 50+ (Sol planets + AOL planets + ATJD planets)
```

### Task 5: Verify in Dashboard

Navigate to: `http://localhost:3000/admin/dashboard`

**Expected results:**
- ✅ Sol system shows 8+ planets
- ✅ AOL-732356 system shows 6+ planets
- ✅ No duplicate "Sol" entries
- ✅ Can click into systems and see planets

## Critical Constraints

**TESTING REQUIREMENTS:**
- ❌ DO NOT run RSpec tests (this is a data seeding issue, not code logic)
- ✅ DO test in Rails console first
- ✅ DO verify database state after seeding
- ✅ DO check dashboard UI manually

**CONTAINER RULES:**
- All Rails console testing inside Docker: `docker exec -it web rails console`
- All database operations inside Docker
- Commits from HOST, not inside Docker

**FILE CHANGES:**
- Modify: `app/services/star_sim/system_builder_service.rb` (add size mapping)
- Modify: `db/seeds.rb` or similar (fix JSON file selection)
- Document: Update ANALYSIS_SEEDING_FAILURES.md with findings

## Success Criteria

After your fix:

```ruby
# Should all pass:
CelestialBodies::CelestialBody.count > 0
CelestialBodies::CelestialBody.find_by(name: 'Earth')&.size&.present?
CelestialBodies::CelestialBody.find_by(name: 'Eden II')&.size&.present?
SolarSystem.find_by(name: 'Sol')&.celestial_bodies&.count >= 8
```

Dashboard should show populated systems with planet counts.

## Expected Timeline

- Investigation: 30 minutes
- Fix implementation: 30 minutes  
- Testing: 30 minutes
- Documentation: 15 minutes
- **Total: ~2 hours**

## Deliverables

1. **Fixed system_builder_service.rb** with size attribute mapping
2. **Fixed JSON file loading** (no duplicates)
3. **Seeded database** with all planets created
4. **Updated ANALYSIS_SEEDING_FAILURES.md** with "RESOLVED" section documenting:
   - What the bug was
   - Where it was located
   - How it was fixed
   - Test results

## Additional Notes

- This is a **CRITICAL BLOCKER** - nothing else can progress without planets
- The terrain generation fix is waiting for this
- The monitor view improvements are waiting for this
- The civilization layer is waiting for this

**Fix this first, then we can resume other work.**

---

**REMINDER:** Read ANALYSIS_SEEDING_FAILURES.md completely before starting. It has detailed investigation notes and testing strategies.
