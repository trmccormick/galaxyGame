# TASK: Material Storage Classification — Architecture Design
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: architecture
**Created**: 2026-04-16
**Last Updated**: 2026-04-16

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires reasoning about material properties,
derivation logic, and template design across a large material dataset.
**Supervision Level**: 🟡 Standard

---

## Context

Surface settlements can store outdoor-eligible materials on the planet
surface without enclosure (effectively unlimited capacity). Materials
like iron I-beams and solar panels can sit on Luna's surface. Gases,
biologicals, and hazardous materials must be enclosed.

The `DockingTransactionService` needs to determine outdoor eligibility
from material data. The material template (v1.6) has `state_at_stp`,
`storage.stability`, and `import_config.transport_category` fields that
can be used to derive this — but no explicit `requires_enclosure` flag.

This task designs the classification system and decides whether to derive
it at runtime or bake it into material JSON files.

---

## Existing Material Fields Available For Derivation

From `material_v1.6` template:

```json
"state_at_stp": "solid" | "liquid" | "gas"

"storage": {
  "pressure": "atmospheric" | "standard" | "pressurized",
  "temperature": "standard" | "cryogenic" | "refrigerated",
  "stability": "stable" | "unstable" | "reactive"
}

"cost_data": {
  "import_config": {
    "transport_category": "standard" | "hazardous" | "cryogenic" |
                          "biological" | "radioactive" | "pressurized"
  }
}
```

---

## Proposed Derivation Logic (for design review)

```
outdoor_eligible = true IF ALL of:
  state_at_stp == 'solid'
  storage.stability == 'stable'
  transport_category NOT IN [hazardous, cryogenic, biological, radioactive]

Examples:
  iron    → solid, stable, standard     → outdoor OK ✓
  oxygen  → gas, stable, hazardous      → must enclose ✗
  methane → gas, stable, hazardous      → must enclose ✗
  panels  → solid, stable, standard     → outdoor OK ✓
  food    → solid, stable, biological   → must enclose ✗
  LOX     → liquid, stable, cryogenic   → must enclose ✗
```

---

## Design Questions to Answer

### 1. Runtime derivation vs explicit flag
Should `outdoor_eligible?` be derived at runtime from existing fields,
or should material JSON files have an explicit `requires_enclosure: true/false`
flag added to the template?

**Pros of derivation**: No data migration needed, works for all existing materials
**Pros of explicit flag**: Clearer, allows edge cases, AI-readable

### 2. Edge cases in derivation
Are there materials where the derivation logic gives the wrong answer?
Example: powdered iron is a fire hazard but iron bars are safe.
How does the system handle material form/state nuance?

### 3. Template update
Should `material_v1.6` be updated to `material_v1.7` with an explicit
`storage_requirements.outdoor_eligible` field?
Or add it to existing `storage_requirements` section?

### 4. Lookup service integration
Where does the derivation/lookup happen?
Options:
- Inside `DockingTransactionService#outdoor_eligible?`
- In `MaterialGeneratorService` or `MaterialLookupService`
- As a concern on material-aware models

---

## Output — Design Document

```
CLASSIFICATION APPROACH
=======================
Decision: [runtime derivation | explicit flag | hybrid]
Reasoning: [why]

DERIVATION LOGIC (if runtime)
==============================
Exact conditional: [Ruby pseudocode]
Edge cases handled: [list]
Edge cases not handled: [flag for future]

TEMPLATE UPDATE (if explicit flag)
====================================
New field: [name, location in template, values]
Template version bump: [1.6 → 1.7?]
Materials needing backfill: [estimate count]

LOOKUP INTEGRATION
==================
Method: [exact signature]
Location: [service or concern]
Called from: [DockingTransactionService]

DATA MIGRATION SCOPE
====================
How many material files need updating: [estimate]
Which materials are edge cases: [list]

FOLLOW-UP TASKS
===============
[list implementation tasks with scope and agent tier]
```

---

## Acceptance Criteria
- [ ] Decision made: runtime derivation vs explicit flag
- [ ] Derivation logic or flag spec fully defined
- [ ] Edge cases identified and handled or flagged
- [ ] Lookup integration point specified
- [ ] Template version decision made
- [ ] No code or data changes made

## Dependencies
**Blocked by**: None
**Blocks**: 2026-04-16-HIGH-FEATURE-DOCKING-TRANSACTION-SERVICE.md
  (service has placeholder logic — needs confirmed approach)
**Related**: 2026-04-16-HIGH-ARCHITECTURE-RAW-RESOURCE-EXTRACTION-PRICING.md
