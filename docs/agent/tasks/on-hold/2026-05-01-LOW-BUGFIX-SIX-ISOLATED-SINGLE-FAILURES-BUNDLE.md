# TASK: Fix Six Isolated LOW-Impact Failures

**Status**: BACKLOG
**Priority**: LOW
**Type**: bugfix
**Created**: 2026-05-01
**Failure Count**: 6 failures

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Small isolated fixes, independent of each other. Batch for efficiency.
**Supervision Level**: 🟢 Unsupervised

---

## Bugs

---

### Bug 1 — `GameDataGenerator` missing fixture file (failure #76)

**Spec**: `spec/services/generators/game_data_generator_spec.rb:22`
**Error**: `RuntimeError: Template file not found: /home/galaxy_game/spec/fixtures/sample_template.json`

The spec tries to load `spec/fixtures/sample_template.json` which doesn't exist.

**Fix**: Create `spec/fixtures/sample_template.json` with valid minimal content matching what `Generators::GameDataGenerator` expects as a template. Read `app/services/generators/game_data_generator.rb` to understand the expected template format, then create the fixture.

---

### Bug 2 — `Logistics::ContractService` `arrives_at can't be blank` (failure #77)

**Spec**: `spec/services/logistics/contract_service_spec.rb:20`
**Error**: `ActiveRecord::RecordInvalid: Validation failed: Arrives at can't be blank`

`Logistics::ContractService.create_internal_transfer` calls `calculate_delivery_time(from_settlement, to_settlement, transport_method)` for `arrives_at`, but it returns `nil` in the test context.

**Fix**:
1. Read `app/services/logistics/contract_service.rb` — find `calculate_delivery_time`.
2. The method likely fails to compute a time because the test settlements have no coordinates or transport data.
3. Either: add a fallback `|| 1.hour.from_now` in the `calculate_delivery_time` method, OR ensure the spec provides settlements with proper location data.
4. Prefer fixing the service with a safe fallback since nil arrival time is always wrong.

---

### Bug 3 — `Lookup::EarthReferenceService` format change (failure #78)

**Spec**: `spec/services/lookup/earth_reference_service_spec.rb:19`
**Error**: `expected nil to be within 5 of 78` — `atmosphere_composition["N2"]["percentage"]` returns `nil`

**Fix**:
1. Read `app/services/lookup/earth_reference_service.rb` — find `atmosphere_composition` method.
2. Read the actual Earth JSON data it loads. The format likely changed (e.g., `percentage` key renamed, or data structure nested differently).
3. Either update the service to use the correct key path, OR update the spec assertion to match the actual format. Prefer fixing the service if the spec assertion is correct.

---

### Bug 4 — `WormholeConsortiumFormationService` count off by 1 (failure #88)

**Spec**: `spec/services/wormhole_consortium_formation_service_spec.rb:11`
**Error**: `expected ConsortiumMembership.count to have changed by at least 4, but was changed by 3`

**Fix**:
1. Read `app/services/wormhole_consortium_formation_service.rb` — find `form_consortium`.
2. The service creates 3 memberships but the spec expects at least 4. Either a founding member is being skipped, or the spec expectation is wrong.
3. Read the spec to understand what 4 founding members it expects. Check if the 4th member's data exists in seed/fixture data.
4. Likely fix: one founding member record is missing from the test DB — either add it to the spec setup or fix the service's founding member query.

---

### Bug 5 — `Game#advance_time` wrong planet in stub (failure #43)

**Spec**: `spec/models/game_spec.rb:86`
**Error**: 
```
#<PlanetUpdateService>.new received unexpected arguments
  expected: (Mars, 5.0)
  got: (Mercury, 5.0)
```

**Fix**:
1. Read `spec/models/game_spec.rb` around line 86. The spec stubs `PlanetUpdateService.new` with a specific planet (Mars), but `game.rb#process_planets` iterates all planets in DB order — Mercury comes before Mars.
2. The spec should either:
   - Use `allow(PlanetUpdateService).to receive(:new).with(anything, anything).and_call_original` for the planets it doesn't care about, plus a specific stub for Mars
   - OR stub `PlanetUpdateService.new` without argument constraints: `allow(PlanetUpdateService).to receive(:new).and_return(mock_service)`
3. This is a spec isolation issue — fix the stub to not be overly specific about which planet.

---

### Bug 6 — `BaseUnit#store_on_surface` stub not applied (failure #51)

**Spec**: `spec/models/units/base_unit_spec.rb:254`
**Error**: `add_pile` was expected with `{material_name: ..., amount: ..., source_unit: ...}` but received 0 times.

**Fix**:
1. Read `spec/models/units/base_unit_spec.rb` around line 249-260.
2. The issue is that the stub for `add_pile` is applied to a specific `SurfaceStorage` instance (`surface_storage_real`), but the `store_on_surface` method calls `add_pile` on a different instance (reloaded from DB via `settlement_with_storage.surface_storage`).
3. Change the stub to use `allow_any_instance_of(Storage::SurfaceStorage).to receive(:add_pile).and_return(true)` to ensure it applies to all instances.
4. Run the spec to confirm it passes.

---

## Implementation Order

Fix bugs independently. Run each spec after fixing:

```
# Bug 1
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/generators/game_data_generator_spec.rb'

# Bug 2
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/contract_service_spec.rb'

# Bug 3
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/earth_reference_service_spec.rb'

# Bug 4
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/wormhole_consortium_formation_service_spec.rb'

# Bug 5
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/game_spec.rb'

# Bug 6
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/units/base_unit_spec.rb'
```

---

## Acceptance Criteria
- [ ] Bug 1: `game_data_generator_spec.rb` passes.
- [ ] Bug 2: `contract_service_spec.rb` passes.
- [ ] Bug 3: `earth_reference_service_spec.rb` passes.
- [ ] Bug 4: `wormhole_consortium_formation_service_spec.rb` passes.
- [ ] Bug 5: `game_spec.rb:85` passes.
- [ ] Bug 6: `base_unit_spec.rb:249` passes.

---

## Commit Instructions
```
git commit -m "fix: create sample_template.json fixture for GameDataGenerator spec"
git commit -m "fix: contract_service calculate_delivery_time returns nil — add fallback"
git commit -m "fix: earth_reference_service atmosphere_composition format key mismatch"
git commit -m "fix: wormhole consortium formation membership count"
git commit -m "fix(spec): game_spec PlanetUpdateService stub too specific — use flexible argument match"
git commit -m "fix(spec): base_unit store_on_surface stub not applied to correct instance"
```
