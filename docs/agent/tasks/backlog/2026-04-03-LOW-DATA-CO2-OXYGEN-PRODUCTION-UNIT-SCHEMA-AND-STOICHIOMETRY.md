# TASK: Migrate co2_oxygen_production_data.json to new schema and fix stoichiometry
**Status**: BACKLOG
**Priority**: LOW
**Type**: data
**Created**: 2026-04-03
**Last Updated**: 2026-04-03

---

## Agent Assignment

**Assigned To**: Gemini Flash 0.33x
**Why This Agent**: JSON-only data migration with a clear reference file (GCU) and explicit chemistry; no Ruby changes required
**Supervision Level**: 🟡 Standard

---

## Context

`co2_oxygen_production_data.json` is the operational data file for the CO2 Oxygen Production Unit, a life support unit that splits atmospheric CO2 into breathable oxygen. It is loaded by `UnitLookupService` and read by `ISRUEvaluator` (and potentially future life support evaluators) to determine production rates.

The file was never migrated from the old `resource_management.consumables/generated` schema to the current `input_resources` / `output_resources` / `processing_capabilities` schema used by all ISRU units (GCU, TEU, Gas Separator) as of April 3, 2026. Additionally its chemistry is physically impossible — inputs and outputs do not mass-balance.

This task is currently **not blocking any specs** — the unit ID is referenced in `base_craft.rb` and `base_craft_spec.rb` but those tests only check the ID, not the JSON chemistry. Fix it before the ISRU evaluator is extended to cover life support units.

**Relevant Architecture Docs** — read before starting:
- `docs/ai_manager/isru_evaluator.md` — how the evaluator reads `output_resources` and `processing_capabilities`
- `data/json-data/operational_data/units/production/refineries/gas_conversion_unit_data.json` — canonical example of the correct schema (fixed April 2026)

---

## Problem Statement

The file at `data/json-data/operational_data/units/life_support/co2_oxygen_production_data.json` has two problems:

**Problem 1 — Old schema**

Current format uses the legacy structure:
```json
"resource_management": {
  "consumables": {
    "co2_kg": { "rate": 40.0, "current_usage": 0 },
    "hydrogen_kg": { "rate": 5.0, "current_usage": 0 }
  },
  "generated": {
    "oxygen_kg": { "rate": 30.0, "current_output": 0 },
    "water_l":   { "rate": 35.0, "current_output": 0 }
  }
}
```

Required format (matches GCU, TEU, Gas Separator):
```json
"processing_capabilities": { ... },
"input_resources":  [ { "id": "CO2", "amount": N, "unit": "kilogram" } ],
"output_resources": [ { "id": "O2",  "amount": N, "unit": "kilogram" } ]
```

Resource IDs must use chemical formulas (CO2, H2O, O2, CH4) — no `_kg`/`_l` suffixes, no human-readable names.

**Problem 2 — Impossible mass balance**

Current values: 40 kg CO2 + 5 kg H2 in → 30 kg O2 + 35 kg H2O out = 65 kg out from 45 kg in. This violates conservation of mass.

**Current behavior**: File is in old schema; chemistry is wrong; future evaluator reads will produce garbage rates
**Expected behavior**: Schema matches `unit_operational_data` template; chemistry balances; process is physically realistic

---

## Chemistry Decision — read before implementing

There are two realistic processes for this unit. **Choose Sabatier + Electrolysis** (same as GCU) because:
- The unit already has both `reactor` and `electrolysis` sections in `production_systems`
- It matches the Mars Direct / NASA ISRU architecture already implemented in the GCU
- H2 input closed-loop (electrolysis regenerates H2 from water byproduct — no external H2 needed)

**Net reaction**: CO2 + 2H2O → CH4 + 2O2 (but this unit is life-support scale, smaller throughput than GCU)

**However** — if this unit is meant to be a *life support* unit (not propellant production) then CH4 is a waste product and the intent is just: produce breathable O2 from cabin CO2. In that case the correct chemistry is **direct CO2 electrolysis** (MOXIE-style):

```
2CO2 → 2CO + O2
```

No H2 input. No H2O output. Only inputs: CO2 + electrical power. Only output: O2 (+ CO waste vented).

**Recommendation**: Use direct CO2 electrolysis (MOXIE) for this unit since it is categorized as `life_support` and co-located with `co2_scrubber`. Leave Sabatier+electrolysis to the GCU. If unsure, escalate to user before changing.

**Ballpark numbers for MOXIE-style at life-support scale** (at 92% electrolysis efficiency):
- Input: 44 kg CO2 → 32 kg O2 + 28 kg CO (vented)
- Power: ~10 kW continuous
- This supports ~4-6 crew members breathing for 24h

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Section |
|---|---|---|
| `data/json-data/operational_data/units/life_support/co2_oxygen_production_data.json` | Operational data for CO2 Oxygen Production Unit | `resource_management`, `processing_capabilities`, `input_resources`, `output_resources` |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `data/json-data/operational_data/units/production/refineries/gas_conversion_unit_data.json` | Canonical example of correct schema post-April 2026 migration |
| `data/json-data/operational_data/units/production/refineries/gas_separator_unit_data.json` | Second example of correct schema |
| `galaxy_game/app/services/ai_manager/isru_evaluator.rb` | Shows which JSON fields the evaluator reads (`output_resources`, `processing_capabilities`) |

### Migration (if needed)
- [x] No migration needed — JSON data file only, no database schema change

---

## Implementation Steps

### Step 1 — Decide on chemistry and add `processing_capabilities`

Add the new top-level section after `subcategory`. For MOXIE/direct CO2 electrolysis:

```json
"processing_capabilities": {
  "atmospheric_processing": {
    "enabled": true,
    "types": ["co2_electrolysis"],
    "efficiency": 0.92
  },
  "geosphere_processing": {
    "enabled": false,
    "types": [],
    "efficiency": 0.0
  }
}
```

### Step 2 — Replace `resource_management.consumables/generated` with `input_resources` / `output_resources`

Remove the old `resource_management` block entirely. Add:

```json
"input_resources": [
  { "id": "CO2", "amount": 44.0, "unit": "kilogram" }
],
"output_resources": [
  { "id": "O2", "amount": 32.0, "unit": "kilogram" }
]
```

CO waste is vented — do not list it as an output resource (it is not stored or used).

### Step 3 — Update `operational_properties`

Replace the old per-resource rates under `connections` and `resource_management` with:

```json
"operational_properties": {
  "power_consumption_kw": 10.0,
  "heat_generation_kw": 3.0,
  "failure_rate": 0.003,
  "maintenance_interval_hours": 500.0
}
```

### Step 4 — Update `metadata`

Ensure:
```json
"metadata": {
  "version": "2.0",
  "type": "unit_operational_data",
  "category": "life_support",
  "template_compliance": "unit_operational_data"
}
```

And top-level `"template": "unit_operational_data"` must remain.

### Step 5 — Validate JSON

```bash
python3 -m json.tool data/json-data/operational_data/units/life_support/co2_oxygen_production_data.json > /dev/null && echo "valid"
```

### Step 6 — Run affected specs

```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/craft/base_craft_spec.rb'
```

These specs only test the unit ID, not the JSON chemistry, so they should remain green.

---

## Acceptance Criteria
- [ ] `python3 -m json.tool` validates the file with no errors
- [ ] File uses `input_resources` / `output_resources` / `processing_capabilities` schema (no `resource_management.consumables/generated`)
- [ ] All resource IDs use chemical formulas: `CO2`, `O2` — no `_kg`/`_l` suffixes
- [ ] Mass balance checked: output O2 mass ≤ input CO2 mass (oxygen atoms balance)
- [ ] `base_craft_spec.rb` isolation run: 0 failures
- [ ] Process choice (MOXIE vs Sabatier) documented in `description` field of the JSON

---

## Stop Conditions — escalate to user immediately if:
- Unsure whether this unit should use MOXIE (CO2 electrolysis) or Sabatier+electrolysis — the two produce different outputs and serve different roles
- Any Ruby file change is found to be necessary
- `base_craft_spec.rb` fails after the JSON edit

---

## Commit Instructions
Run git commands on **host**, not inside container.

Note: `data/` is in `.gitignore` — this file is **not tracked by git**. No commit needed. Simply update the file on disk.

---

## Documentation
- [ ] No doc changes needed
- [ ] Flag doc gap: no architecture doc exists for life support unit JSON schema — add to backlog if needed

---

## Dependencies
**Blocked by**: none
**Blocks**: Future extension of `ISRUEvaluator` to cover life support units
**Related tasks**: `2026-04-03-HIGH-DOCUMENTATION-AI-MANAGER-FILE-AUDIT-CLASSIFY-ALL-SERVICES.md` (audit will classify this unit's evaluator coverage)

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
-

### Issues discovered
-

### Follow-up tasks needed
-

### Lessons learned
-
