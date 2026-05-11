# TASK: Delete Zombie TerrestrialPlanet Model and Remove gas_quantities Dead Code
**Status**: BACKLOG
**Priority**: LOW
**Type**: cleanup
**Created**: 2026-05-02
**Failure Count**: 0 (not causing active failures — preventive cleanup)
**Phase Gate**: Do before Phase 3 spec health work begins (~May 15)

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Pure deletion and dead code removal. Every change is listed exactly
below. No judgment calls required.
**Supervision Level**: 🟢 Low — deletion only, no new code, no logic changes

---

## Root Cause

January data loss + accidental restore brought back pre-STI zombie code. Three
connected problems from the same source:

1. A duplicate `TerrestrialPlanet` model at the wrong namespace that Rails autoloads,
   creating a competing constant alongside the correct STI class.
2. Dead `gas_quantities` code in the correct model — the DB column was already
   commented out in the migration. A comment in the file itself says to remove it.
3. A controller spec whose `valid_attributes` hash references `gas_quantities` and
   `total_pressure` — neither exists as a DB column. All tests using this hash are
   commented out, making it a trap rather than an active failure.

---

## Fix 1 — Delete zombie model file

**DELETE**: `galaxy_game/app/models/celestial_bodies/terrestrial_planet.rb`

This file defines `CelestialBodies::TerrestrialPlanet < CelestialBody` — the old
pre-STI class. Wrong namespace, wrong inheritance, validates non-existent columns
(`atmosphere_composition`, `atmospheric_pressure`). No RSpec file references this
constant. No factory uses it. No app code calls it directly.

Confirm before deleting:
```bash
grep -rn "CelestialBodies::TerrestrialPlanet" galaxy_game/app/ galaxy_game/spec/
```
Expected: only two matches remain after delete:
- `galaxy_game/app/models/celestial_bodies/celestial_body.rb` — legacy case (fix below)
- `galaxy_game/app/models/celestial_bodies/terrestrial_planet.rb` — the file being deleted

---

## Fix 2 — Remove legacy case in celestial_body.rb

**File**: `galaxy_game/app/models/celestial_bodies/celestial_body.rb`

In the `planet_type` method, remove the entire `# Legacy types for compatibility`
block. The current STI classes handle all active types above it. The legacy cases
reference constants that will not exist after Fix 1.

**Remove these lines** (lines ~381-387):
```ruby
      # Legacy types for compatibility
      when CelestialBodies::TerrestrialPlanet then 'terrestrial'
      when CelestialBodies::GasGiant then 'gas_giant'
      when CelestialBodies::IceGiant then 'ice_giant'
      when CelestialBodies::Moon then 'moon'
      when CelestialBodies::DwarfPlanet then 'dwarf_planet'
```

**Check**: `CelestialBodies::GasGiant`, `CelestialBodies::IceGiant`, `CelestialBodies::Moon`,
`CelestialBodies::DwarfPlanet` — verify none of these constants exist in app/models before
removing. If any DO exist as separate files, remove only the `TerrestrialPlanet` line and
leave the others (STOP and report).

---

## Fix 3 — Remove dead gas_quantities code from rocky TerrestrialPlanet

**File**: `galaxy_game/app/models/celestial_bodies/planets/rocky/terrestrial_planet.rb`

Remove the following dead code blocks entirely. The file's own comments say to do this.

**Remove from public section** (around line 21):
```ruby
        attr_accessor :gas_quantities, :biomes, :atmospheric_pressure
```
Keep `attr_accessor` if other non-dead attrs are on the same line — they are not,
so remove the full line.

**Remove entire methods**:
- `add_gas` (uses gas_quantities — lines ~30-35)
- `calculate_total_pressure` (hardcodes 1.0 — lines ~37-40)
- `calculate_surface_conditions` (uses dead biomes attr — lines ~42-53)
- `update_biomes` (calls calculate_surface_conditions — lines ~55-57)
- `initialize_gas_quantities` private method (lines ~68-82)

**Fix duplicate private keyword**: There are two `private` declarations in this file.
Remove the second one (the one around line 64 after `initialize_gas_quantities` stub area).
The real `private` at the bottom of the class is correct.

**Keep everything else** — `temperature`, `temperature=`, `magnetic_moment`,
`atmosphere_composition`, `habitable_zone?`, `habitability_score`, all scoring methods,
`calculated_atmospheric_pressure`, `set_sti_type`.

---

## Fix 4 — Clean up celestial_bodies_spec.rb valid_attributes

**File**: `galaxy_game/spec/controllers/celestial_bodies_spec.rb`

The `valid_attributes` hash references `gas_quantities`, `total_pressure`, and
`temperature` — none are DB columns. All tests using this hash are already commented out.
The two active tests (`GET #map`, `GET #geological_features`) use the `luna` let block only.

**Remove the entire `valid_attributes` let block** (lines ~7-18):
```ruby
  let(:valid_attributes) {
    {
      name: "Earth",
      size: 1.0,
      gravity: 9.8,
      density: 5.5,
      orbital_period: 365,
      total_pressure: 10.0,
      gas_quantities: { "Nitrogen" => 780800, "Oxygen" => 209500 },
      temperature: -60
    }
  }
```

The `luna` let block is correct — keep it.

---

## Progress (as of 2026-05-08)

### Current Status
- This cleanup task is **partially complete**.
- The duplicate (zombie) `TerrestrialPlanet` model at the wrong namespace (`app/models/celestial_bodies/terrestrial_planet.rb`) has already been removed.
- Only the correct STI-compliant model remains: `app/models/celestial_bodies/planets/rocky/terrestrial_planet.rb`.
- Remaining steps (removal of dead `gas_quantities` code and legacy case in `celestial_body.rb`) have not yet been completed.
- The task's remaining steps and acceptance criteria are still relevant and actionable.

### Findings
- No file exists at the old zombie model path; only the correct model is present.
- Dead code and legacy references still need to be cleaned up as described in the task.
- The task is **not stale** and should remain in the backlog until fully completed.

### Next Steps
- Remove dead `gas_quantities` code and legacy compatibility block from `celestial_body.rb` as described.
- Leave task in BACKLOG until all cleanup steps are finished.

---

## Verification Steps

```bash
# After all changes — confirm no references to old class remain in app/ or spec/
grep -rn "CelestialBodies::TerrestrialPlanet" galaxy_game/app/ galaxy_game/spec/
# Expected: zero matches

# Confirm gas_quantities gone from app/
grep -rn "gas_quantities" galaxy_game/app/
# Expected: zero matches

# Run targeted specs to confirm nothing broken
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec \
  spec/models/celestial_bodies/planets/rocky/terrestrial_planets_spec.rb \
  spec/controllers/celestial_bodies_spec.rb \
  spec/controllers/terrestrial_planets_spec.rb \
  --format progress 2>&1 | tail -10'
```

---

## Do NOT Touch

- `galaxy_game/db/seeds copy.rb` and `seeds copy 2.rb` — these are historical seed backups,
  not loaded by Rails. Leave as-is.
- `galaxy_game/integration-tests/old-integration-test-scripts/` — archived scripts,
  not part of the test suite.
- The `TerrestrialPlanetsController` — it correctly references
  `CelestialBodies::Planets::Rocky::TerrestrialPlanet`. Leave it alone.
- `spec/controllers/terrestrial_planets_spec.rb` — separate spec, already correct,
  do not modify.

---

## Acceptance Criteria
- `app/models/celestial_bodies/terrestrial_planet.rb` deleted
- Legacy case block removed from `celestial_body.rb` planet_type method
- `gas_quantities` attr_accessor and all 5 dead methods removed from rocky TerrestrialPlanet
- Duplicate `private` keyword removed
- `valid_attributes` let block removed from `celestial_bodies_spec.rb`
- Zero `CelestialBodies::TerrestrialPlanet` references remaining in app/ or spec/
- Zero `gas_quantities` references remaining in app/
- Targeted specs pass after changes
