# 2026-04-01-HIGH-BUG-FIX-MATERIAL-PROCESSING-GAS-YIELDS

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Surgical spec fix for material processing gas yields
**Supervision Level**: 🔴 Watched carefully

## Context
MaterialProcessingService handles thermal/volatiles extraction from regolith. Post-Claude commits caused 6 spec failures related to gas composition and inventory deltas.

## Problem Statement
6 specs failed in material_processing_service_spec.rb:
- thermal_extraction job (line 46)
- inventory update (line 62)
- volatiles_extraction job (line 94)
- gas composition (line 110)

**Current behavior**: Wrong gas ratios, inventory mismatch post-job
**Expected behavior**: Mars baseline yields (0.06/0.995?), correct inventory delta

## Files Involved
### Primary Files — you will edit
| File | Purpose | Key Method |
|---|---|---|
| `app/services/manufacturing/material_processing_service.rb` | Extraction logic | `#thermal_extraction`, `#volatiles_extraction` |
| `spec/services/manufacturing/material_processing_service_spec.rb` | Test cases | lines 46,62,73,94,110,125 |

## Implementation Steps
1. **Diagnostic:** Grep for gas ratios and extraction methods
2. **Fix:** Correct gas composition ratios and inventory delta logic
3. **Test:** Run full material processing spec suite

## Acceptance Criteria
- [ ] Isolation run: 25 examples, 0 failures
- [ ] No regressions in manufacturing specs
- [ ] Gas composition matches Mars baseline (0.06/0.995?)
- [ ] Inventory deltas correct post-job

## Stop Conditions
- Precision issue deeper than service (geosphere lookup)
- Factory regression from Claude commits
- Circular dependency in material flow

## Commit Instructions
```bash
git add app/services/manufacturing/material_processing_service.rb spec/services/manufacturing/material_processing_service_spec.rb
git commit -m "fix: material_processing_service_spec — gas yields/inventory regression"
```