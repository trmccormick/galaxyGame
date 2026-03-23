# Fix: HydrosphereConcern Spec (13 Failures)
**Status:** COMPLETED  
**Priority:** HIGH  
**Agent:** GPT-4.1 Copilot (Agent Mode)  
**Branch:** regional-view-phase2  
**Est:** 30min

---

## Mandatory First Steps

1. Read `docs/agent/README.md` completely before touching anything
2. Run the target spec first to confirm exactly 13 failures

```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/concerns/hydrosphere_concern_spec.rb > /home/galaxy_game/log/rspec_hydro_$(date +%s).log 2>&1'
```

---

## Root Cause (Planner Diagnosed — Do Not Re-diagnose)

**Problem 1 — Double hydrosphere creation:**
The `celestial_body` factory `after(:create)` callback automatically
calls `celestial_body.create_hydrosphere` for every celestial body.
The spec then also calls `create(:hydrosphere, :earth, celestial_body:
celestial_body)` — creating a second hydrosphere for the same body.

When the concern calls `celestial_body.hydrosphere` it returns the
first auto-created one (empty: `total_liquid_mass: 0.0`, no data)
— NOT the `:earth` one the spec intended. All tests that depend on
liquid mass, state distribution, or temperature fail because they
operate on the wrong hydrosphere.

**Problem 2 — String vs symbol keys:**
The `:earth` factory trait stores `state_distribution` with string
keys `{'liquid' => 95.0}` but `calculate_state_distributions` returns
symbol keys `{solid:, liquid:, vapor:}`. Any test comparing these
will fail.

**Problem 3 — Material setup doesn't affect total_hydrosphere_mass:**
The `before` block creates `CelestialBodies::Material` records on
`hydrosphere.materials` but `HydrosphereConcern` uses `total_liquid_mass`
as a scalar column — not a materials association. The material records
don't affect `total_hydrosphere_mass`.

---

## The Fix — Spec Changes Only

**File:** `spec/models/concerns/hydrosphere_concern_spec.rb`

Do NOT modify:
- The concern itself (`app/models/concerns/hydrosphere_concern.rb`)
- Any factory files
- Any other spec files

### Fix 1 — Replace the `let(:hydrosphere)` definition

Replace:
```ruby
let(:hydrosphere) { create(:hydrosphere, :earth, celestial_body: celestial_body) }
```

With:
```ruby
let(:hydrosphere) do
  celestial_body.hydrosphere.tap do |h|
    h.update!(
      temperature: 300.0,
      total_liquid_mass: 1.386e21,
      state_distribution: { 'liquid' => 95.0, 'solid' => 5.0, 'vapor' => 0.0 },
      composition: { 'H2O' => 100.0 },
      pressure: 1.0
    )
  end
end
```

This uses the auto-created hydrosphere that `celestial_body.hydrosphere`
returns — the one the concern actually uses — rather than creating a
second orphaned one.

### Fix 2 — Remove the material creation from before block

Remove these lines from the `before` block — they create records that
don't affect `total_liquid_mass` and add confusion:

```ruby
# REMOVE THIS:
hydrosphere.materials.create!(
  name: 'H2O', 
  amount: 5.0e18,
  location: 'hydrosphere',
  state: 'liquid',
  celestial_body: celestial_body
)
```

Keep the atmosphere H2O gas creation — that IS used by precipitation
tests.

### Fix 3 — Remove_liquid before block

In `describe '#remove_liquid'`, the before block uses `H2O_material`
which references the material record we just removed. Replace it with
a direct hydrosphere update:

```ruby
before do
  hydrosphere.update!(total_liquid_mass: 2.0e18)
end
```

---

## Phase 2 — Verify

```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/concerns/hydrosphere_concern_spec.rb > /home/galaxy_game/log/rspec_hydro_$(date +%s).log 2>&1'
```

Target: 13 failures → 0 failures.

If failures remain, read the log carefully. Report back with the
exact failure messages before making further changes.

---

## Phase 3 — Regression Check

Run the hydrosphere model spec to confirm nothing broken there:

```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/celestial_bodies/spheres/hydrosphere_spec.rb > /home/galaxy_game/log/rspec_hydro_model_$(date +%s).log 2>&1'
```

---

## Phase 4 — Commit

```bash
git add spec/models/concerns/hydrosphere_concern_spec.rb
git commit -m "FIX: hydrosphere_concern_spec — fix double hydrosphere creation

- Use celestial_body.hydrosphere instead of creating second :earth hydrosphere
- Remove material record creation that had no effect on total_liquid_mass
- Fix remove_liquid before block to use direct hydrosphere update
- 13 failures → 0 failures

Root cause: celestial_body factory auto-creates hydrosphere on after(:create).
Spec was creating a second one that the concern never used."
```

Update `CURRENT_STATUS.md`:
- `hydrosphere_concern_spec.rb` ✅ 0 failures
- Root cause documented: double hydrosphere from factory callback

---

## STOP Conditions

- If hydrosphere_spec.rb (model spec) gains new failures — stop and report
- If fix requires touching the concern or factories — stop and report
- If failures differ from the 13 documented — stop and report

**Do not touch anything outside `hydrosphere_concern_spec.rb`.**
