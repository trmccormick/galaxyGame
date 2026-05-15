# 2026-04-16-MEDIUM-ARCHITECTURE-MATERIAL-STORAGE-CLASSIFICATION

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Architecture design for material storage classification system
**Supervision Level**: 🔴 Watched carefully

## Context
Surface settlements can store outdoor-eligible materials on planet surface without enclosure (unlimited capacity). Materials like iron I-beams and solar panels can sit on Luna's surface. Gases, biologicals, hazardous materials must be enclosed.

DockingTransactionService needs to determine outdoor eligibility from material data. Material template has state_at_stp, storage.stability, import_config.transport_category fields that can derive this - but no explicit requires_enclosure flag.

## Problem Statement
No explicit outdoor storage eligibility flag in material data. DockingTransactionService needs way to determine which materials can be stored outdoors vs require enclosure.

**Expected**: Classification system deciding whether to derive at runtime from existing fields or bake explicit flag into material JSON files.

## Existing Material Fields
- state_at_stp: solid/liquid/gas
- storage.stability: stable/unstable/reactive  
- import_config.transport_category: standard/hazardous/cryogenic/biological/radioactive/pressurized

## Design Questions
1. Runtime derivation vs explicit flag in material JSON
2. Edge cases in derivation logic
3. Template update needed (v1.6 → v1.7)
4. Lookup service integration point

## Files Involved
### Primary Files — you will read
| File | Purpose |
|---|---|
| `data/json-data/materials/` | Material template structure |
| `app/models/material.rb` | Material model and data access |
| `app/services/market/docking_transaction_service.rb` | Will use classification (placeholder) |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/data/material_template_v1.6.md` | Current material template spec |

## Implementation Steps
1. **Analyze derivation logic**: Define exact conditional for outdoor eligibility
2. **Identify edge cases**: Materials where derivation gives wrong answer
3. **Decide approach**: Runtime derivation vs explicit flag vs hybrid
4. **Specify template update**: If needed, new field location and values
5. **Define lookup integration**: Method signature and location

## Acceptance Criteria
- [ ] Decision made: runtime derivation vs explicit flag
- [ ] Derivation logic or flag spec fully defined
- [ ] Edge cases identified and handled or flagged
- [ ] Lookup integration point specified
- [ ] Template version decision made
- [ ] No code or data changes made

## Stop Conditions
- None specified

## Commit Instructions
```bash
git add docs/architecture/material_storage_classification_design.md
git commit -m "docs: material storage classification architecture — outdoor eligibility system design"
```