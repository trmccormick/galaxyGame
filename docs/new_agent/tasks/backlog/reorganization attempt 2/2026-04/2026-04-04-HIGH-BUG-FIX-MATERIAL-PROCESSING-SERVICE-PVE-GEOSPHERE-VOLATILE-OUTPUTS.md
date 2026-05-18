# TASK: Fix MaterialProcessingService PVE Output — Geosphere-Driven Chemical Formula Outputs
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix + refactor
**Created**: 2026-04-04
**Last Updated**: 2026-05-15

---

## Agent Assignment

**Assigned To**: Implementation Agent
**Why This Agent**: Touches JSON data, service logic, and spec — requires reasoning about geosphere data model and chemical formula conventions. Not mechanical.
**Supervision Level**: 🟡 Standard

---

## Context

`Manufacturing::MaterialProcessingService#complete_job` handles PVE (Planetary Volatiles Extractor) jobs. The current implementation has two problems:

1. **Wrong output IDs** — service uses `extracted_water` and `extracted_gases` as case identifiers, but the JSON operational data uses `H2O` and `mixed_volatiles`. Nothing matches, so `depleted_regolith` is output instead of volatiles.
2. **`mixed_volatiles` is wrong** — we know the approximate composition of regolith from geosphere data. Outputting a generic `mixed_volatiles` blob ignores real composition data that already exists.

**Architectural decision (confirmed 2026-04-04):**
- PVE units output each volatile by chemical formula (`H2O`, `CO2`, `N2`, `CH4`, etc.) derived from `geosphere.crust_composition.volatiles`
- Natural variation of ±5% applied to each output
- `depleted_regolith` = input minus all extracted volatiles
- No `mixed_volatiles`, no `extracted_water` — real chemical formulas only
- This is already how `extracted_gases` case works — unify into one path

---

## Problem Statement

**Error output:**
```
expected: ("extracted_water", a value within 0.01 of 0.75, settlement, {})
	got: ("depleted_regolith", 19.25, settlement, {})
# spec/services/manufacturing/material_processing_service_spec.rb:87
```

**Current behavior**: PVE job outputs `depleted_regolith` instead of extracted volatiles because `out_id` from JSON (`H2O`, `mixed_volatiles`) doesn't match service case handlers (`extracted_water`, `extracted_gases`).

**Expected behavior**: PVE job reads geosphere `crust_composition.volatiles`, outputs each volatile by chemical formula with ±5% variation, outputs `depleted_regolith` as remainder.

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

1. Refactor `complete_job` to output each volatile by chemical formula from geosphere data, with ±5% variation.
2. Update all relevant specs to expect chemical formula outputs.
3. Update PVE operational data files to match new output model.
4. Ensure all specs pass.

---

## Acceptance Criteria
- PVE jobs output volatiles by chemical formula, not generic IDs.
- No `mixed_volatiles` or `extracted_water` outputs remain.
- All specs and integration tests pass.

# 2026-04-04-HIGH-BUG-FIX-MATERIAL-PROCESSING-SERVICE-PVE-GEOSPHERE-VOLATILE-OUTPUTS

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Bug fix and refactor for PVE material processing outputs
**Supervision Level**: 🔴 Watched carefully

## Context
MaterialProcessingService#complete_job handles PVE (Planetary Volatiles Extractor) jobs. Current implementation has wrong output IDs - service uses extracted_water/extracted_gases but JSON uses H2O/mixed_volatiles. Need to make outputs geosphere-driven with real chemical formulas.

## Problem Statement
PVE job outputs depleted_regolith instead of extracted volatiles because output IDs from JSON don't match service case handlers. Need to output each volatile by chemical formula from geosphere data with ±5% variation.

**Current behavior**: Wrong output IDs cause fallback to depleted_regolith
**Expected behavior**: PVE outputs H2O, CO2, N2, CH4 etc. from geosphere crust_composition.volatiles

## Files Involved
### Primary Files — you will edit
| File | Purpose | Key Section |
|---|---|---|
| `app/services/manufacturing/material_processing_service.rb` | Fix complete_job PVE output path | lines 60-90 |
| `spec/services/manufacturing/material_processing_service_spec.rb` | Update spec expectations | lines 75-115 |
| `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk1_data.json` | Update output_resources | on disk |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_data.json` | Base PVE unit data |
| `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk2_data.json` | Check consistency |
| `data/json-data/operational_data/units/production/extractors/planetary_volatiles_extractor_mk3_data.json` | Check consistency |

## Implementation Steps
1. **Read all reference files**: Service, JSON files, failing spec
2. **Update JSON operational data**: Replace mixed_volatiles/H2O with geosphere_volatiles sentinel for all PVE units
3. **Update service**: Replace extracted_water/extracted_gases cases with geosphere_volatiles handler that reads geosphere data
4. **Update spec**: Change expectations to use chemical formulas, stub rand for deterministic testing
5. **Verify**: Run material processing spec and rake tasks

## Acceptance Criteria
- [ ] material_processing_service_spec.rb — 0 failures
- [ ] PVE job outputs H2O, CO2, N2 etc. by chemical formula from geosphere
- [ ] No mixed_volatiles or extracted_water anywhere
- [ ] depleted_regolith = input minus extracted volatiles
- [ ] ±5% variation applied to each volatile output
- [ ] All 4 PVE JSON files updated and validated
- [ ] Rake tasks pass after change

## Stop Conditions
- Rake tasks fail after JSON changes
- geosphere.crust_composition returns nil
- More than 3 other callers of complete_job found
- Any volatile output produces negative amount

## Commit Instructions
```bash
git add app/services/manufacturing/material_processing_service.rb
git add spec/services/manufacturing/material_processing_service_spec.rb
git add data/json-data/operational_data/units/production/extractors/
git commit -m "fix: PVE material processing — geosphere-driven volatile outputs with ±5% variation, replace mixed_volatiles with real chemical formulas"
```