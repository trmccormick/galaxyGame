# TASK: Fix MaterialProcessingService PVE Output — Geosphere-Driven Chemical Formula Outputs
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix + refactor
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Touches JSON data, service logic, and spec — requires reasoning
about geosphere data model and chemical formula conventions. Not mechanical.
**Supervision Level**: 🟡 Standard

---

## Context

`Manufacturing::MaterialProcessingService#complete_job` handles PVE
(Planetary Volatiles Extractor) jobs. The current implementation has two
problems:

1. **Wrong output IDs** — service uses `extracted_water` and `extracted_gases`
   as case identifiers, but the JSON operational data uses `H2O` and
   `mixed_volatiles`. Nothing matches, so `depleted_regolith` is output
   instead of volatiles.

2. **`mixed_volatiles` is wrong** — we know the approximate composition of
   regolith from geosphere data. Outputting a generic `mixed_volatiles`
   blob ignores real composition data that already exists.

**Architectural decision (confirmed 2026-04-04):**
- PVE units output each volatile by chemical formula (`H2O`, `CO2`, `N2`,
  `CH4`, etc.) derived from `geosphere.crust_composition.volatiles`
- Natural variation of ±5% applied to each output
- `depleted_regolith` = input minus all extracted volatiles
- No `mixed_volatiles`, no `extracted_water` — real chemical formulas only
- This is already how `extracted_gases` case works — unify into one path

**The correct PVE output model:**
```
Input: regolith (kg)
Outputs (from geosphere crust_composition.volatiles):
  H2O    → input × (crust_H2O%  / 100) × efficiency × variation(±5%)
  CO2    → input × (crust_CO2%  / 100) × efficiency × variation(±5%)
  N2     → input × (crust_N2%   / 100) × efficiency × variation(±5%)
  CH4    → input × (crust_CH4%  / 100) × efficiency × variation(±5%)
  [etc.] → any volatile present in geosphere data
  depleted_regolith → input - sum(all extracted volatiles)
```

**Variation formula:**
```ruby
variation = 1.0 + (rand * 0.10 - 0.05)  # ±5% uniform distribution
```

---

## Problem Statement

**Error output:**
```
expected: ("extracted_water", a value within 0.01 of 0.75, settlement, {})
     got: ("depleted_regolith", 19.25, settlement, {})
# spec/services/manufacturing/material_processing_service_spec.rb:87
```

**Current behavior**: PVE job outputs `depleted_regolith` instead of
extracted volatiles because `out_id` from JSON (`H2O`, `mixed_volatiles`)
doesn't match service case handlers (`extracted_water`, `extracted_gases`).

**Expected behavior**: PVE job reads geosphere `crust_composition.volatiles`,
outputs each volatile by chemical formula with ±5% variation, outputs
`depleted_regolith` as remainder.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Section |
|---|---|---|
| `app/services/manufacturing/material_processing_service.rb` | Fix `complete_job` PVE output path | lines 60-90 |
| `spec/services/manufacturing/material_processing_service_spec.rb` | Update spec to expect `H2O` not `extracted_water` | lines 75-115 |
| `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json` | Update output_resources to use sentinel | on disk |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/manufacturing/material_processing_service.rb` | Full current implementation |
| `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_data.json` | Base PVE unit data |
| `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk2_data.json` | Check for consistency |
| `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk3_data.json` | Check for consistency |

---

## Implementation Steps

> Read all reference files before touching anything.

### Step 1 — Read the full service
```bash
cat galaxy_game/app/services/manufacturing/material_processing_service.rb
```

### Step 2 — Read all PVE operational data files
```bash
cat data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json
cat data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk2_data.json
cat data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk3_data.json
```

### Step 3 — Read the failing spec
```bash
cat galaxy_game/spec/services/manufacturing/material_processing_service_spec.rb
```

### Step 4 — Produce Synthesis Report and STOP

### Step 5 — Update JSON operational data for all PVE units

Replace `mixed_volatiles` and `H2O` separate entries with a single
`geosphere_volatiles` sentinel that tells the service to read live
geosphere data:

```json
"output_resources": [
  {
    "id": "geosphere_volatiles",
    "amount": 0,
    "unit": "kilogram",
    "note": "Outputs each volatile by chemical formula from geosphere crust_composition"
  },
  {
    "id": "depleted_regolith",
    "amount": 0,
    "unit": "kilogram"
  }
]
```

Apply to all four PVE files (base, mk1, mk2, mk3).

**Validate each JSON after editing:**
```bash
python3 -c "import json; json.load(open('data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json'))"
```

### Step 6 — Update service complete_job PVE path

Replace the current fragmented case handlers with a unified
`geosphere_volatiles` handler:

```ruby
when 'geosphere_volatiles'
  geosphere = @settlement.celestial_body&.geosphere
  crust_volatiles = geosphere&.crust_composition&.dig('volatiles') || {}
  
  total_extracted = 0.0
  
  crust_volatiles.each do |formula, percent|
    variation = 1.0 + (rand * 0.10 - 0.05)  # ±5% natural variation
    produced = job.input_amount * (percent.to_f / 100.0) * geosphere_eff * variation
    @settlement.inventory.add_item(formula, produced, @settlement, {})
    total_extracted += produced
  end

when 'depleted_regolith'
  geosphere = @settlement.celestial_body&.geosphere
  crust_volatiles = geosphere&.crust_composition&.dig('volatiles') || {}
  total_volatile_percent = crust_volatiles.values.sum(&:to_f)
  produced = job.input_amount * (1.0 - (total_volatile_percent / 100.0)) * geosphere_eff
  @settlement.inventory.add_item('depleted_regolith', produced, @settlement, {})
```

Remove the old `extracted_water` and `extracted_gases` case handlers.

### Step 7 — Update the spec

Update expectations to use real chemical formulas:

```ruby
# Before
expect(settlement.inventory).to receive(:add_item)
  .with('extracted_water', a_value_within(0.01).of(0.75), settlement, {})

# After — stub rand for deterministic variation
allow(service).to receive(:rand).and_return(0.0)  # no variation
expect(settlement.inventory).to receive(:add_item)
  .with('H2O', a_value_within(0.01).of(0.75), settlement, {})
```

Note: stub `rand` to `0.0` in specs for deterministic output
(variation = 1.0 + (0.0 * 0.10 - 0.05) = 0.95 — or use 0.5 for neutral).

Actually use `0.5` for neutral variation:
```ruby
allow(service).to receive(:rand).and_return(0.5)
# variation = 1.0 + (0.5 * 0.10 - 0.05) = 1.0 (neutral)
```

### Step 8 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb 2>&1 | grep "examples,"'
```

### Step 9 — Verify rake tasks still pass
```bash
docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rake ai:sol:gcc_bootstrap'
docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rake ai:lunar_base:with_isru'
```

---

## Synthesis Report Format

```
CURRENT SERVICE CASE HANDLERS
[list current when clauses and what they do]

JSON OUTPUT RESOURCES (mk1)
[current output_resources array]

MISMATCH IDENTIFIED
out_id from JSON: [values]
Service case handlers: [values]
Result: [what actually gets called]

PROPOSED CHANGES
1. JSON: replace mixed_volatiles + H2O with geosphere_volatiles sentinel
2. Service: replace extracted_water + extracted_gases with geosphere_volatiles handler
3. Spec: update expected add_item calls to use H2O, stub rand for determinism

FILES TO EDIT
[list all files]

RISK
[shared code, other callers of complete_job]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. `spec/services/manufacturing/material_processing_service_spec.rb`
2. `spec/services/manufacturing/` — full suite
3. Rake tasks — confirm ISRU chain still works:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rake ai:sol:gcc_bootstrap'
docker exec -it web bash -c 'unset DATABASE_URL && bundle exec rake ai:lunar_base:with_isru'
```

---

## Acceptance Criteria
- [ ] `material_processing_service_spec.rb` — 0 failures
- [ ] PVE job outputs `H2O`, `CO2`, `N2` etc. by chemical formula
- [ ] No `mixed_volatiles` or `extracted_water` anywhere in service or JSON
- [ ] `depleted_regolith` = input minus extracted volatiles
- [ ] ±5% variation applied to each volatile output
- [ ] All 4 PVE JSON files updated and validated
- [ ] Rake tasks pass after change
- [ ] No regressions in manufacturing suite

---

## Stop Conditions
- Rake tasks fail after JSON changes — restore JSON and report
- `geosphere.crust_composition` returns nil for Luna — report before proceeding
- More than 3 other callers of `complete_job` found — report call sites
- Any volatile output produces negative amount — report calculation

---

## Commit Instructions
```bash
git add galaxy_game/app/services/manufacturing/material_processing_service.rb
git add galaxy_game/spec/services/manufacturing/material_processing_service_spec.rb
git add data/json-data/operational_data/units/production/extractors/
git commit -m "fix: PVE material processing — geosphere-driven volatile outputs with ±5% variation, replace mixed_volatiles with real chemical formulas"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: Luna ISRU chain accuracy
**Related tasks**: ISRU evaluator rewire (Task 2, 2026-04-03 — complete)

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
