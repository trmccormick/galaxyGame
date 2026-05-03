# TASK: Fix Spec Identifier Collision — before(:all) Solar System Leak + :luna Hardcoded Identifier
**Phase**: 3 — Promote to backlog ~May 15

**Status**: BACKLOG
**Priority**: HIGH
**Type**: bugfix
**Created**: 2026-05-01
**Failure Count**: 26 failures

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Surgical spec-only fixes — no production code changes.
**Supervision Level**: 🟡 Standard

---

## Context

Two root causes, same symptom: `ActiveRecord::RecordInvalid: Validation failed: Identifier has already been taken`.

**Root Cause A — `base_craft_spec.rb` `before(:all)` leaks solar_system**

`before(:all)` creates a solar_system into a local variable that is never captured in an instance variable, so `after(:all)` never destroys it. Because `before(:all)` data runs outside DatabaseCleaner transactions, the solar_system record persists across suite runs. On the next run, the FactoryBot sequence resets to 1, generating `SS-1` — which already exists in the DB from the previous run.

```ruby
# base_craft_spec.rb line ~25 — CURRENT (broken)
before(:all) do
  solar_system = FactoryBot.create(:solar_system)  # ← local var, never in after(:all)
  @celestial_body_instance = FactoryBot.create(:large_moon, solar_system: solar_system, ...)
end

after(:all) do
  @celestial_body_instance&.destroy
  # ← solar_system is NEVER destroyed
end
```

**Root Cause B — `celestial_bodies.rb` `:luna` trait hardcodes `LUNA-01`**

```ruby
# spec/factories/celestial_bodies/celestial_bodies.rb line 103
trait :luna do
  identifier { "LUNA-01" }  # ← hardcoded, conflicts with seed data LUNA-01
```

`LUNA-01` already exists in the test DB (seeded via world constants). Any spec that calls `create(:celestial_body, :luna)` fails. Affected: `storage/surface_storage_spec.rb` (6 failures).

**Root Cause C — `large_moons.rb` `:luna` trait sequence starts at LUNA-01**

```ruby
# spec/factories/celestial_bodies/satellites/large_moons.rb line 17
trait :luna do
  sequence(:identifier) { |n| "LUNA-#{n.to_s.rjust(2, '0')}" }  # n=1 → "LUNA-01" → conflict
```

First suite call generates `LUNA-01`, which conflicts with seeded LUNA-01. Affected: `item_spec.rb` (1 failure).

---

## Files Involved

| File | Change |
|---|---|
| `spec/models/craft/base_craft_spec.rb` | Capture solar_system in `@solar_system`; add to `after(:all)` |
| `spec/factories/celestial_bodies/celestial_bodies.rb` | Fix `:luna` trait to not hardcode `LUNA-01` |
| `spec/factories/celestial_bodies/satellites/large_moons.rb` | Fix `:luna` sequence to avoid LUNA-01 |
| `spec/models/storage/surface_storage_spec.rb` | Change `create(:celestial_body, :luna)` to use existing seed body |
| `spec/models/item_spec.rb` | Change `create(:large_moon, :luna)` to use existing seed body |
| `spec/models/units/base_unit_spec.rb` | Check if it uses `:luna` and apply same fix |

---

## Implementation Steps

### Step 1 — Fix `base_craft_spec.rb` solar_system leak

In `before(:all)`, change `solar_system = FactoryBot.create(:solar_system)` to `@solar_system = FactoryBot.create(:solar_system)`. Update the `large_moon` create call to use `@solar_system`. Add `@solar_system&.destroy` to `after(:all)`.

```ruby
# before(:all)
@solar_system = FactoryBot.create(:solar_system)
@celestial_body_instance = FactoryBot.create(:large_moon,
  identifier: "TEST-LUNA-#{SecureRandom.hex(4)}",
  solar_system: @solar_system
)

# after(:all)
@solar_system&.destroy
```

### Step 2 — Fix `celestial_bodies.rb` `:luna` trait

Specs that call `create(:celestial_body, :luna)` should use the seeded world constant instead of creating a new one. Two approaches:

**Preferred**: Use `find_or_create_by!` in `after(:build)` to return the existing record:
```ruby
trait :luna do
  name { "Luna" }
  sequence(:identifier) { |n| "LUNA-SPEC-#{n}" }  # never conflicts with LUNA-01
  # ... rest of trait unchanged
end
```

Then in specs like `surface_storage_spec.rb`, replace:
```ruby
let(:celestial_body) { create(:celestial_body, :luna) }
```
with:
```ruby
let(:celestial_body) { CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01') }
```

Only do this replacement in specs that actually need Luna's specific properties (atmosphere, geosphere, etc.). If they just need _a_ celestial body, use `create(:celestial_body)` without the `:luna` trait.

### Step 3 — Fix `large_moons.rb` `:luna` sequence

Change sequence to start well above 01 or use a non-conflicting prefix:
```ruby
sequence(:identifier) { |n| "LUNA-SPEC-#{n}" }
```

OR in `item_spec.rb`, replace `create(:large_moon, :luna)` with:
```ruby
CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01')
```

### Step 4 — Verify fixes

```
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/craft/base_craft_spec.rb spec/models/storage/surface_storage_spec.rb spec/models/item_spec.rb spec/models/units/base_unit_spec.rb'
```

Expected: 0 failures in these files.

---

## Acceptance Criteria
- [ ] `base_craft_spec.rb`: all 17 examples pass. `after(:all)` destroys solar_system.
- [ ] `storage/surface_storage_spec.rb`: 0 `Identifier has already been taken` errors.
- [ ] `item_spec.rb`: regolith handling example passes.
- [ ] `base_unit_spec.rb`: `store_on_surface` example passes (if :luna-related).
- [ ] No new failures introduced.

---

## Commit Instructions
`git add spec/models/craft/base_craft_spec.rb spec/factories/celestial_bodies/ spec/models/storage/surface_storage_spec.rb spec/models/item_spec.rb`
`git commit -m "fix(specs): resolve identifier collision from before(:all) solar_system leak and hardcoded LUNA-01 trait"`
