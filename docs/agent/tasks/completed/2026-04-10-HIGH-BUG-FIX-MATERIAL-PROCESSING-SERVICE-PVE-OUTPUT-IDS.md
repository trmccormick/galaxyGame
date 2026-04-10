# TASK: Fix MaterialProcessingService PVE output IDs — align to chemical formula convention
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-10
**Last Updated**: 2026-04-10

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Three file changes, fully specified, no inference needed
**Supervision Level**: 🔴 Watched carefully

---

## Context
`MaterialProcessingService` handles PVE (Planetary Volatiles Extractor) job
completion. It branches on output resource IDs from operational data to
determine how to calculate volatile extraction from geosphere composition.
The project convention is chemical formulas for resource IDs (H2O, CO2, N2).
The service was written with non-canonical IDs (`extracted_water`,
`extracted_gases`) that don't match the operational data or the ISRU evaluator.

---

## Problem Statement
`material_processing_service_spec.rb:86,111` fail because:
- Service branches on `when 'extracted_water'` and `when 'extracted_gases'`
- Operational data has output IDs `H2O` and `mixed_volatiles`
- Case statement never matches — falls through silently
- ISRU evaluator already uses `H2O` as the canonical water ID

**Current behavior**: Service produces `depleted_regolith` only, ignoring volatiles  
**Expected behavior**: Service extracts `H2O` and non-H2O volatiles by chemical formula

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Change |
|---|---|---|
| `galaxy_game/app/services/manufacturing/material_processing_service.rb` | Processing service | Fix case statement IDs and add_item calls |
| `galaxy_game/spec/services/manufacturing/material_processing_service_spec.rb` | Spec | Update expected add_item arguments |
| `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json` | Operational data | Revert output IDs to H2O and mixed_volatiles |

### Reference Files — read but do not edit
| File | Why |
|---|---|
| `galaxy_game/app/services/ai_manager/isru_evaluator.rb` | Already uses H2O as canonical ID — confirm alignment after fix |

---

## Implementation Steps

> Follow exactly in order. Do not apply anything before Synthesis Report is approved.

### Step 1 — Fix the service case statement

Open `galaxy_game/app/services/manufacturing/material_processing_service.rb`.

Find the case statement (around line 70). Replace:
```ruby
case out_id
when 'extracted_water'
  h2o = crust_volatiles['H2O'] || crust_volatiles['h2o']
  if h2o
    produced = job.input_amount * (h2o.to_f / 100.0) * geosphere_eff
    @settlement.inventory.add_item('extracted_water', produced, @settlement, {})
  end
when 'extracted_gases'
  crust_volatiles.each do |volatile, percent|
    next if volatile.to_s.downcase == 'h2o'
    produced = job.input_amount * (percent.to_f / 100.0) * geosphere_eff
    @settlement.inventory.add_item(volatile, produced, @settlement, {})
  end
```

With:
```ruby
case out_id
when 'H2O'
  h2o = crust_volatiles['H2O'] || crust_volatiles['h2o']
  if h2o
    produced = job.input_amount * (h2o.to_f / 100.0) * geosphere_eff
    @settlement.inventory.add_item('H2O', produced, @settlement, {})
  end
when 'mixed_volatiles'
  crust_volatiles.each do |volatile, percent|
    next if volatile.to_s.downcase == 'h2o'
    produced = job.input_amount * (percent.to_f / 100.0) * geosphere_eff
    @settlement.inventory.add_item(volatile, produced, @settlement, {})
  end
```

### Step 2 — Fix the spec expectations

Open `galaxy_game/spec/services/manufacturing/material_processing_service_spec.rb`.

Find line ~87. Replace:
```ruby
expect(settlement.inventory).to receive(:add_item).with('extracted_water', a_value_within(0.01).of(0.75), settlement, {})
```
With:
```ruby
expect(settlement.inventory).to receive(:add_item).with('H2O', a_value_within(0.01).of(0.75), settlement, {})
```

Find line ~112. The `CO2` and `N2` expectations are already correct — do not touch them. They work because `mixed_volatiles` iterates crust volatiles and adds each by its chemical formula directly.

### Step 3 — Revert the operational data file

Open `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json`.

In `output_resources`, ensure the IDs are:
```json
"output_resources": [
  {
    "id": "mixed_volatiles",
    "amount": 0,
    "unit": "kilogram"
  },
  {
    "id": "H2O",
    "amount": 0,
    "unit": "kilogram"
  },
  {
    "id": "depleted_regolith",
    "amount": 0,
    "unit": "kilogram"
  }
]
```

### Step 4 — Validate the JSON file
```bash
python3 -c "import json; json.load(open('data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json')); print('valid')"
```

### Step 5 — Copy updated data file into container
```bash
docker cp data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json web:/home/galaxy_game/app/data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json
```

---

## Synthesis Report Format
Before applying any fix, produce this and STOP:
THE FAILURE
Spec: material_processing_service_spec.rb:86,111
Error: add_item called with wrong arguments
Root causes: [confirm all three]
PROPOSED FIX

Service case statement: [show exact before/after]
Spec expectation line 87: [show exact before/after]
Data file output IDs: [confirm current state and what changes]

RISK

Service change: only affects PVE zero-amount output branch
Spec change: mechanical ID rename only
Data change: reverts to canonical IDs, aligns with ISRU evaluator

READY TO APPLY? — waiting for approval

---

## Testing Sequence

1. Isolation run — target specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb 2>&1 | tail -3'
```
Expected: 0 failures

2. ISRU evaluator — confirm no regression:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/isru_evaluator_spec.rb 2>&1 | tail -3'
```
Expected: 0 failures

3. Do NOT run full suite — report back after steps 1 and 2.

---

## Acceptance Criteria
- [ ] `material_processing_service_spec.rb` — 0 failures
- [ ] `isru_evaluator_spec.rb` — 0 failures
- [ ] No other files touched

---

## Stop Conditions — escalate immediately if:
- `isru_evaluator_spec` gains new failures after the fix
- The spec has additional `extracted_water` references beyond line 87
- Data file has unexpected structure differences from what is specified above

---

## Commit Instructions
On host, not in container:
```bash
git add galaxy_game/app/services/manufacturing/material_processing_service.rb \
        galaxy_game/spec/services/manufacturing/material_processing_service_spec.rb \
        data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json
git commit -m "fix: material_processing_service PVE outputs — align to H2O/mixed_volatiles chemical formula convention"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: nothing
**Related tasks**: none

---

## Completion Report
*Filled in by agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned