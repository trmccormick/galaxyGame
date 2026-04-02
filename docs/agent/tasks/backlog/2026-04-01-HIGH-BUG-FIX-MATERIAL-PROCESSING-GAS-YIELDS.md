# TASK: Fix material_processing_service_spec.rb gas yield regression
**Status**: ACTIVE  
**Priority**: HIGH  
**Type**: bug-fix  
**Created**: 2026-04-01  
**Last Updated**: 2026-04-01  

## Agent Assignment
**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Surgical spec fix, single service, grep-revealed root cause  
**Supervision Level**: 🔴 Watched carefully  

## Context
MaterialProcessingService handles thermal/volatiles extraction from regolith. 
6 specs failed post-Claude commits - gas composition (0.06/0.995?) + inventory deltas.

## Problem Statement
**Error output**:
spec/services/manufacturing/material_processing_service_spec.rb:46 # thermal_extraction job
spec/services/manufacturing/material_processing_service_spec.rb:62 # inventory update
spec/services/manufacturing/material_processing_service_spec.rb:94 # volatiles_extraction job
spec/services/manufacturing/material_processing_service_spec.rb:110 # gas composition

text

**Current behavior**: Wrong gas ratios, inventory mismatch post-job  
**Expected behavior**: Mars baseline yields (0.06/0.995?), correct inventory delta  

## Files Involved
### Primary Files — you will edit
| File | Purpose | Key Method |
|---|---|---|
| `app/services/manufacturing/material_processing_service.rb` | Extraction logic | `#thermal_extraction`, `#volatiles_extraction` |
| `spec/services/manufacturing/material_processing_service_spec.rb` | Test cases | lines 46,62,73,94,110,125 |

## Implementation Steps
### Step 1 — Diagnostic
```bash
docker exec -it web bash -c 'grep -n "gas\|0.06\|0.995\|thermal_extraction\|volatiles_extraction" spec/services/manufacturing/material_processing_service_spec.rb app/services/manufacturing/material_processing_service.rb | head -20'
```
**STOP after diagnostic.**

### Step 2 — Synthesis Report [AGENT FILLS]

### Step 3 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb'
```
Expected: `25 examples, 0 failures`

## Testing Sequence
1. **Isolation**: `rspec spec/services/manufacturing/material_processing_service_spec.rb`
2. **Related**: `rspec spec/services/manufacturing/`
3. **Full suite** → log only

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
git push
```
