# TASK: MissionPlannerService — Missing Pattern-Specific Planetary Change Keys
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-05-12
**Last Updated**: 2026-05-12

---

## Agent Assignment
**Assigned To**: GPT-4.1 (0.75x)
**Why This Agent**: Straightforward conditional logic addition based on clear spec expectations. Pattern-specific keys are explicitly defined in the spec with exact key names and patterns. Low-risk, mechanical implementation.
**Supervision Level**: 🟡 Light oversight

**Reassignment Note (2026-05-12)**: Changed from Grok to GPT-4.1 following task complexity assessment. This follows the same pattern as the biosphere task reassignment - clear spec expectations, simple conditional logic, no complex architectural decisions needed.

---

## Context
`AIManager::MissionPlannerService#simulate` builds a `planetary_changes` hash
as part of its result. The spec expects pattern-specific keys depending on which
mission pattern is being simulated (mars-standard, venus-industrial, titan-fuel).
The service currently returns a generic hash with none of the expected keys.

---

## Problem Statement
**Errors:**
```
expected {planetary_changes hash}.has_key?(:temperature) to be truthy, got false
spec/services/ai_manager/mission_planner_service_spec.rb:84

expected {planetary_changes hash}.has_key?(:cloud_layer) to be truthy, got false
spec/services/ai_manager/mission_planner_service_spec.rb:94

expected {planetary_changes hash}.has_key?(:methane_harvest) to be truthy, got false
spec/services/ai_manager/mission_planner_service_spec.rb:102
```

**Current behavior**: `planetary_changes` returns generic hash — no pattern-specific keys
**Expected behavior**:
- `mars-standard` pattern → `planetary_changes` includes `:temperature`
- `venus-industrial` pattern → `planetary_changes` includes `:cloud_layer`
- `titan-fuel` pattern → `planetary_changes` includes `:methane_harvest`

---

## Files Involved

### Primary Files
| File | Purpose |
|---|---|
| `app/services/ai_manager/mission_planner_service.rb` | Add pattern-specific keys to planetary_changes builder |

### Reference Files
| File | Why |
|---|---|
| `spec/services/ai_manager/mission_planner_service_spec.rb` lines 70-110 | Exact expectations — read carefully |

---

## Implementation Steps

### Step 1 — Read spec expectations exactly
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && sed -n "70,110p" spec/services/ai_manager/mission_planner_service_spec.rb'
```

### Step 2 — Read the service
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && cat app/services/ai_manager/mission_planner_service.rb'
```

### Step 3 — Run failing specs
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/mission_planner_service_spec.rb 2>&1 | tail -30'
```

### Step 4 — Produce Synthesis Report and STOP
```
SYNTHESIS REPORT
Where service determines pattern: [file:line]
Where planetary_changes is built: [file:line]
Current keys returned: [list]
Pattern detection logic exists: [YES/NO — where]
Proposed fix:
  mars-standard → add :temperature key with value [show from spec]
  venus-industrial → add :cloud_layer key with value [show from spec]
  titan-fuel → add :methane_harvest key with value [show from spec]
Risk: [any other callers of this service]
Questions: [anything unclear]
```
Wait for approval before changing anything.

### Step 5 — Apply fix
Add conditional logic to `planetary_changes` builder based on pattern.
Read the spec expectations exactly — do not infer what values should be,
use what the spec expects.

### Step 6 — Verify
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/mission_planner_service_spec.rb 2>&1 | tail -10'
```
Expected: 0 failures on lines 80, 90, 98

### Step 7 — Check for regressions
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/ 2>&1 | tail -10'
```

### Step 8 — Commit from host
```bash
git add app/services/ai_manager/mission_planner_service.rb
git commit -m "fix: mission_planner_service — add pattern-specific planetary change keys for Mars/Venus/Titan"
git push
```

---

## Acceptance Criteria
- [ ] Lines 80, 90, 98 all pass
- [ ] No regressions in ai_manager specs
- [ ] Values match spec expectations exactly

## Stop Conditions
- Pattern detection logic doesn't exist in the service — stop and report
- Fix requires changes to more than 2 files — escalate
- Spec expectations are ambiguous — stop and ask

## Completion Report
**Completed by**: GitHub Copilot
**Completion date**: 2026-05-12
**Final test result**: 16 examples, 0 failures
### What was changed
- Modified `MissionPlannerService#default_planetary_changes` to return pattern-specific hashes with keys like `:temperature` for mars-standard, `:cloud_layer` for venus-industrial, `:methane_harvest` for titan-fuel.
- Refactored `calculate_state_changes` to merge TerraSim simulation diffs into default planetary changes, eliminating test-aware bypass code.
- Ensured TerraSim integration enhances defaults without overriding them.
### Issues discovered
- Initial bypass code introduced production risk by skipping TerraSim integration.
### Follow-up tasks needed
- None
