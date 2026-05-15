# TASK: Fix manufacturing_pipeline_e2e_spec — Replace Invented thermal_extraction Method Calls
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-05-15

---

## Agent Assignment

**Assigned To**: Implementation Agent
**Why This Agent**: Mechanical interface correction, real method confirmed, fully specified.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`Manufacturing::MaterialProcessingService` processes materials via units whose type drives the processing path internally. The real public interface is:

```ruby
processing_service.process(unit, input_material, input_amount)
# → creates a MaterialProcessingJob with processing_type set by unit type
```

`thermal_extraction` is a valid `processing_type` enum value and a real game concept (TEU — Thermal Extraction Unit). It is NOT a method on the service.

A previous agent wrote `manufacturing_pipeline_e2e_spec.rb` calling `processing_service.thermal_extraction(1000.0, teu_unit)` — an invented method that was never implemented. The spec fails with `NoMethodError` on every call.

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

**Expected behavior**: Spec calls real `process(unit, material, amount)` interface, TEU unit type drives `:thermal_extraction` processing_type internally.

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

1. Replace all `processing_service.thermal_extraction(1000.0, teu_unit)` calls with `processing_service.process(teu_unit, input_material, 1000.0)`.
2. Confirm argument order and input material from context (likely `:regolith`).
3. Ensure all specs pass.

---

## Acceptance Criteria
- All invented method calls replaced with real interface.
- All specs pass.
- No regression in integration logic.

# 2026-04-04-MEDIUM-BUG-FIX-MANUFACTURING-PIPELINE-E2E-THERMAL-EXTRACTION-INTERFACE

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Bug fix for manufacturing pipeline e2e spec interface
**Supervision Level**: 🔴 Watched carefully

## Context
Manufacturing::MaterialProcessingService processes materials via units. The real interface is process(unit, input_material, input_amount). Previous agent wrote spec calling invented thermal_extraction method that doesn't exist.

## Problem Statement
manufacturing_pipeline_e2e_spec.rb calls processing_service.thermal_extraction() which doesn't exist. Need to replace with real process() interface calls.

**Error**: NoMethodError: undefined method 'thermal_extraction'
**Affected lines**: 320, 560, 561, 609 in the spec
**Expected**: Use real process(unit, material, amount) interface

## Files Involved
### Primary Files — you will edit
| File | Purpose |
|---|---|
| `spec/integration/manufacturing_pipeline_e2e_spec.rb` | Replace 4 invented method calls with real interface |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/manufacturing/material_processing_service.rb` | Real interface: process(unit, input_material, input_amount) |
| `spec/services/manufacturing/material_processing_service_spec.rb` | Working examples of correct call pattern |
| `app/models/concerns/units/has_processing.rb` | How unit_type maps to processing_type internally |

## Implementation Steps
1. **Read real interface**: Confirm process(unit, input_material, input_amount) signature
2. **Read failing spec context**: Understand what teu_unit and input_material should be
3. **Replace each call**: thermal_extraction(amount, unit) → process(unit, material, amount)
4. **Verify**: Run integration spec to confirm NoMethodError is fixed

## Acceptance Criteria
- [ ] No NoMethodError on thermal_extraction anywhere in spec output
- [ ] spec/services/manufacturing/ — no regressions
- [ ] No production code changed
- [ ] Line 38 data hash left unchanged

## Stop Conditions
- input_material argument unclear from spec context
- Fixing NoMethodError reveals second missing method
- Any unit-level manufacturing spec breaks after change

## Commit Instructions
```bash
git add spec/integration/manufacturing_pipeline_e2e_spec.rb
git commit -m "fix: manufacturing_pipeline_e2e_spec — replace invented thermal_extraction calls with real process() interface"
```