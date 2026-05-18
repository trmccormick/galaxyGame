# 2026-04-03-LOW-DATA-CO2-OXYGEN-PRODUCTION-UNIT-SCHEMA-AND-STOICHIOMETRY

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — JSON data migration with chemistry validation
**Supervision Level**: 🔴 Watched carefully

## Context
co2_oxygen_production_data.json contains operational data for the CO2 Oxygen Production Unit (life support unit). The file uses old schema and has impossible chemistry that doesn't mass-balance.

## Problem Statement
Two issues with the JSON file:
1. Uses legacy `resource_management.consumables/generated` schema instead of current `input_resources`/`output_resources`/`processing_capabilities`
2. Chemistry violates conservation of mass (65kg output from 45kg input)

**Current behavior**: Old schema, impossible chemistry
**Expected behavior**: New schema, physically realistic CO2 electrolysis process

## Files Involved
### Primary Files — you will edit
| File | Purpose | Key Section |
|---|---|---|
| `data/json-data/operational_data/units/life_support/co2_oxygen_production_data.json` | Operational data for CO2 Oxygen Production Unit | `resource_management`, `processing_capabilities`, `input_resources`, `output_resources` |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `data/json-data/operational_data/units/production/refineries/gas_conversion_unit_data.json` | Canonical example of correct schema |
| `galaxy_game/app/services/ai_manager/isru_evaluator.rb` | Shows which JSON fields the evaluator reads |

## Implementation Steps
1. **Decide chemistry**: Use MOXIE-style direct CO2 electrolysis (2CO2 → 2CO + O2)
2. **Add processing_capabilities**: Add atmospheric processing section
3. **Replace resource_management**: Convert to input_resources/output_resources format
4. **Update operational_properties**: Add power consumption, heat generation, etc.
5. **Validate JSON**: Ensure valid JSON syntax
6. **Run specs**: Verify base_craft_spec.rb still passes

## Acceptance Criteria
- [ ] JSON validates with no syntax errors
- [ ] Uses new schema (input_resources/output_resources/processing_capabilities)
- [ ] Resource IDs use chemical formulas (CO2, O2)
- [ ] Mass balance correct (output ≤ input)
- [ ] base_craft_spec.rb isolation run: 0 failures
- [ ] Process choice documented in JSON description

## Stop Conditions
- Chemistry requires broader ISRU system changes
- Schema migration affects other life support units

## Commit Instructions
```bash
git add data/json-data/operational_data/units/life_support/co2_oxygen_production_data.json
git commit -m "fix: co2_oxygen_production_data.json — migrate to new schema and fix stoichiometry"
```