--- ARCHIVED: OBSOLETE — SUPERSEDED BY IMPLEMENTATION ✅ ---  
Original task requested fix for MaterialProcessingService gas yield regression (6 failing specs). **Bug was fixed on April 1, 2026 at 13:13 UTC** (same day as task creation) in commit `1d92bd3d` — "fix: material_processing_service_spec — 5x gas yield (Mars baseline)". This file is preserved for historical reference only.

### What Was Implemented (Supersedes Original Task)
- ✅ MaterialProcessingService#complete_job — fully live with geosphere-driven volatile extraction logic  
- ✅ Gas composition calculation using stored_volatiles mass fractions normalized to percentages  
- ✅ H2O, mixed_volatiles (CO2, N2), and depleted_regolith outputs based on world-specific geosphere data  
- ✅ 75% efficiency factor applied per chemical formula convention  
- ✅ RSpec coverage: 7 examples, 0 failures in material_processing_service_spec.rb  

### Implementation Evidence
**Commit**: `1d92bd3db31e59e1b40fd34b97851ae64381477f` (April 1, 2026)  
**Files Changed**: 
- `app/services/manufacturing/material_processing_service.rb` — geosphere integration for zero-amount outputs
- `spec/services/manufacturing/material_processing_service_spec.rb` — updated to match new extraction logic

**Current Test Status** (verified June 11, 2026):
```bash
$ docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec spec/services/manufacturing/ --format progress
Finished in 13 minutes 25 seconds
167 examples, 0 failures, 4 pending
```

### What Was Extracted as New Task(s) (Actionable Work Remaining)
None — volatiles production chain is fully operational for Luna simulation. No new task needed.

--- END ARCHIVE HEADER ---

# TASK: Fix material_processing_service_spec.rb gas yield regression
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
