# TASK: Fix manufacturing_pipeline_e2e_spec — Replace Invented thermal_extraction Method Calls
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Mechanical interface correction, real method confirmed, fully specified.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ Do not implement until the unit/service layer is clean (<50 failures full suite).
> This is an integration spec — address only after unit specs are green.

---

## Context

`Manufacturing::MaterialProcessingService` processes materials via units whose
type drives the processing path internally. The real public interface is:

```ruby
processing_service.process(unit, input_material, input_amount)
# → creates a MaterialProcessingJob with processing_type set by unit type
```

`thermal_extraction` is a valid `processing_type` enum value and a real game
concept (TEU — Thermal Extraction Unit). It is NOT a method on the service.

A previous agent wrote `manufacturing_pipeline_e2e_spec.rb` calling
`processing_service.thermal_extraction(1000.0, teu_unit)` — an invented method
that was never implemented. The spec fails with `NoMethodError` on every call.

**Real interface confirmed in:**
- `app/services/manufacturing/material_processing_service.rb` — `def process(unit, input_material, input_amount)`
- `spec/services/manufacturing/material_processing_service_spec.rb` — correct usage pattern

---

## Problem Statement

**Error output:**
```
NoMethodError: undefined method 'thermal_extraction'
  for an instance of Manufacturing::MaterialProcessingService
# ./spec/integration/manufacturing_pipeline_e2e_spec.rb:320
```

**Affected lines in spec** (4 call sites):
- Line 38: `'processes' => ['thermal_extraction']` — data hash, may be correct as-is
- Line 320: `processing_service.thermal_extraction(1000.0, teu_unit)`
- Line 560: `processing_service.thermal_extraction(1000.0, teu_unit)`
- Line 561: `processing_service.thermal_extraction(1000.0, teu_unit)`
- Line 609: `processing_service.thermal_extraction(1000.0, teu_unit)`

**Current behavior**: NoMethodError on every call to `thermal_extraction`.

**Expected behavior**: Spec calls real `process(unit, material, amount)` interface,
TEU unit type drives `:thermal_extraction` processing_type internally.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `spec/integration/manufacturing_pipeline_e2e_spec.rb` | Replace 4 invented method calls with real interface |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/manufacturing/material_processing_service.rb` | Real interface: `process(unit, input_material, input_amount)` |
| `spec/services/manufacturing/material_processing_service_spec.rb` | Working examples of correct call pattern |
| `app/models/concerns/units/has_processing.rb` | How unit_type maps to processing_type internally |

---

## Implementation Steps

### Step 1 — Read the real interface and working spec examples
```bash
sed -n '1,60p' galaxy_game/app/services/manufacturing/material_processing_service.rb
sed -n '1,60p' galaxy_game/spec/services/manufacturing/material_processing_service_spec.rb
```

Understand the argument order: `process(unit, input_material, input_amount)`.
Note what `input_material` expects — likely a material symbol or object.

### Step 2 — Read the failing spec context around each call site
```bash
sed -n '310,335p' galaxy_game/spec/integration/manufacturing_pipeline_e2e_spec.rb
sed -n '550,575p' galaxy_game/spec/integration/manufacturing_pipeline_e2e_spec.rb
sed -n '600,620p' galaxy_game/spec/integration/manufacturing_pipeline_e2e_spec.rb
```

Identify what `teu_unit` is in each context and what input material is
implied. The amount `1000.0` likely maps to the `input_amount` argument.

### Step 3 — Produce Synthesis Report and STOP

### Step 4 — Replace each call site

```ruby
# Before (invented — does not exist)
teu_job = processing_service.thermal_extraction(1000.0, teu_unit)

# After (real interface)
teu_job = processing_service.process(teu_unit, input_material, 1000.0)
```

The argument order swaps: unit comes first, material second, amount third.
Determine `input_material` from context — likely `:regolith` or a material
object already set up in the spec's let blocks.

Line 38 (`'processes' => ['thermal_extraction']`) is a data hash in a
factory or setup block — do NOT change this unless it is causing a failure.
It references the processing_type string, not the method name.

### Step 5 — Run the integration spec
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/manufacturing_pipeline_e2e_spec.rb 2>&1 | grep "examples,"'
```

Note: this is an integration spec — additional failures beyond the
NoMethodError are expected and are out of scope for this task.
Success = no more NoMethodError on `thermal_extraction`.

---

## Synthesis Report Format

```
THE FAILURE
Spec: manufacturing_pipeline_e2e_spec.rb lines 320, 560, 561, 609
Error: NoMethodError — undefined method 'thermal_extraction'

REAL INTERFACE CONFIRMED
def process(unit, input_material, input_amount) — line [N] of material_processing_service.rb

CALL SITE ANALYSIS
Line 320: teu_unit is [description], input_material should be [material]
Line 560: [same analysis]
Line 561: [same analysis]
Line 609: [same analysis]

PROPOSED FIX
Each call: processing_service.thermal_extraction(1000.0, teu_unit)
       → processing_service.process(teu_unit, [material], 1000.0)

RISK
Integration spec only. No production code changes. Other failures in this
spec are pre-existing and out of scope.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Target spec only:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/manufacturing_pipeline_e2e_spec.rb 2>&1 | grep "examples,"'
```

2. Confirm no regressions in unit-level manufacturing specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/ 2>&1 | grep "examples,"'
```

---

## Acceptance Criteria
- [ ] No `NoMethodError: undefined method 'thermal_extraction'` anywhere in spec output
- [ ] `spec/services/manufacturing/` — no regressions
- [ ] No production code changed
- [ ] Line 38 data hash left unchanged unless it is itself causing a failure

---

## Stop Conditions — escalate immediately if:
- `input_material` argument is unclear from spec context — report what's available before guessing
- Fixing NoMethodError reveals a second missing method — report before proceeding
- Any unit-level manufacturing spec breaks after the change

---

## Commit Instructions
```bash
git add galaxy_game/spec/integration/manufacturing_pipeline_e2e_spec.rb
git commit -m "fix: manufacturing_pipeline_e2e_spec — replace invented thermal_extraction calls with real process() interface"
git push
```

---

## Dependencies
**Blocked by**: Full suite must be <50 failures before this is assigned
**Blocks**: nothing
**Related tasks**: none

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
