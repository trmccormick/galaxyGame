# TASK: Fix Four Isolated MEDIUM Failures — cover!, target_thickness_mm, GeosphereSimulation arity, magnetic_moment

**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bugfix
**Created**: 2026-05-01
**Failure Count**: 5 failures (1 + 2 + 1 + 1)

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Four isolated, independent bug fixes with clear error messages. Group them to reduce task overhead.
**Supervision Level**: 🟡 Standard

---

## Context

Four distinct bugs, each with 1-2 failures. Grouped for efficiency.

---

## Bug A — `undefined method 'cover!'` on `SegmentCoveringService` (1 failure)

**Failure #14**: `spec/integration/covering_system_integration_spec.rb:93`

```
NoMethodError: undefined method 'cover!' for an instance of Manufacturing::Construction::SegmentCoveringService
# ./app/models/structures/worldhouse.rb:80
#   in 'block in Structures::Worldhouse#recalculate_progress!'
```

`Structures::Worldhouse#recalculate_progress!` calls:
```ruby
Manufacturing::Construction::SegmentCoveringService.new(skylight, self).cover!
```

But `Manufacturing::Construction::SegmentCoveringService` has no `cover!` method.

**Fix**:
1. Read `app/services/manufacturing/construction/segment_covering_service.rb` to find the actual public method name (likely `cover`, `execute`, `perform`, or `seal`).
2. Either rename the method to `cover!` in the service, OR update `worldhouse.rb:80` to call the correct method name.
3. Prefer renaming in the service to `cover!` if no other callers use the old name.

---

## Bug B — `undefined method 'target_thickness_mm'` on `BaseUnit` (2 failures)

**Failures #15-16**: `spec/integration/shell_printing_game_loop_spec.rb:131, :160`

```
NoMethodError: undefined method 'target_thickness_mm' for an instance of Units::BaseUnit
# ./app/services/manufacturing/shell_printing_service.rb:168
#   in 'Manufacturing::ShellPrintingService#create_shell_printing_job'
```

`ShellPrintingService#create_shell_printing_job` reads `inflatable_tank.target_thickness_mm`, but `BaseUnit` has no such method or column.

**Fix**:
1. Read `app/services/manufacturing/shell_printing_service.rb` around line 168.
2. Read `app/models/units/base_unit.rb` — check if `target_thickness_mm` was removed or was always stored differently.
3. Likely fix: read from `operational_data` or a JSON property:
   ```ruby
   inflatable_tank.operational_data['target_thickness_mm']
   # or
   inflatable_tank.properties['target_thickness_mm']
   ```
4. If the attribute genuinely needs to exist on BaseUnit, add a delegating method to read from the appropriate JSON column.

---

## Bug C — `GeosphereSimulationService#simulate` wrong argument count (1 failure)

**Failure #75**: `spec/services/game_spec.rb:66`

```
ArgumentError: wrong number of arguments (given 1, expected 0)
# ./app/services/terra_sim/geosphere_simulation_service.rb:26 in 'simulate'
```

A caller is passing 1 argument to `GeosphereSimulationService#simulate`, but the method now takes 0 arguments.

**Fix**:
1. Read `app/services/terra_sim/geosphere_simulation_service.rb:26` — confirm method signature is `def simulate`.
2. Find the caller: grep for all calls to `GeosphereSimulationService.new(...)....simulate(` or `.simulate(` on a geosphere simulation service instance.
3. Two options:
   - If the argument was a `time_delta`, add it back: `def simulate(time_delta = nil)` (with a default to avoid breaking zero-arg callers)
   - If no callers should pass args, fix the caller to remove the argument

---

## Bug D — `undefined method 'magnetic_moment'` on `TerrestrialPlanet` (1 failure)

**Failure #74**: `spec/services/ai_manager/system_discovery_service_spec.rb:9`

```
NoMethodError: undefined method 'magnetic_moment' for an instance of CelestialBodies::Planets::Rocky::TerrestrialPlanet
# ./app/services/ai_manager/system_discovery_service.rb:110 in 'calculate_magnetic_score'
```

`SystemDiscoveryService#calculate_magnetic_score` calls `planet.magnetic_moment.to_f`. `TerrestrialPlanet` (and its parent model) have no `magnetic_moment` attribute.

**Fix**:
1. Add a `magnetic_moment` method to `CelestialBodies::Planets::Rocky::TerrestrialPlanet` (or its parent class) that reads from `properties` JSON or returns a sensible default:
   ```ruby
   def magnetic_moment
     properties&.dig('magnetic_moment') || 0.0
   end
   ```
2. Check if `magnetic_moment` is already stored somewhere in the model's JSON columns (`properties`, `base_values`, `current_values`).
3. If it exists on some other model/class, check if `TerrestrialPlanet` should inherit or delegate it.

---

## Implementation Order

Do each bug independently — they have no dependencies on each other.

Run each spec file to confirm the fix before moving to the next:
```
# Bug A
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/covering_system_integration_spec.rb'

# Bug B
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/shell_printing_game_loop_spec.rb'

# Bug C
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/game_spec.rb'

# Bug D
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/system_discovery_service_spec.rb'
```

---

## Acceptance Criteria
- [ ] **Bug A**: Covering system integration spec passes. No `NoMethodError` for `cover!`.
- [ ] **Bug B**: Both shell printing game loop spec examples pass.
- [ ] **Bug C**: `Game#advance_by_days` example passes. No `ArgumentError` in geosphere_simulation_service.
- [ ] **Bug D**: `SystemDiscoveryService#discover_available_systems` example passes. No `NoMethodError` for `magnetic_moment`.
- [ ] No new failures introduced.

---

## Commit Instructions
Commit each bug fix individually:
```
git commit -m "fix: add cover! method to SegmentCoveringService"
git commit -m "fix: read target_thickness_mm from operational_data in ShellPrintingService"
git commit -m "fix: restore time_delta argument to GeosphereSimulationService#simulate"
git commit -m "fix: add magnetic_moment reader to TerrestrialPlanet"
```
