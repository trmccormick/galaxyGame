# TASK: MaterialLookupService — JSON Parse Error Not Logged
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-05-12
**Last Updated**: 2026-05-12

---

## Agent Assignment
**Assigned To**: GPT-4.1 (0x)
**Why This Agent**: Add one log call to a rescue block — mechanical, fully specified
**Supervision Level**: 🔴 Watched carefully

---

## Context
`Lookup::MaterialLookupService` parses JSON material files. When a file contains
invalid JSON the spec expects `Rails.logger.error` to be called with a message
matching `/Invalid JSON in file:/`. The service is either not rescuing the parse
error or not logging it when it does.

---

## Problem Statement
**Error:**
```
expected Rails.logger to have received :error with (/Invalid JSON in file:/)
received: 0 times
spec/services/lookup/material_lookup_service_spec.rb:258
```
**Current behavior**: JSON parse failure occurs silently — no log call
**Expected behavior**: `Rails.logger.error("Invalid JSON in file: #{path}")` called on parse failure

---

## Files Involved

### Primary Files
| File | Purpose |
|---|---|
| `app/services/lookup/material_lookup_service.rb` | Add logger call in rescue block |

### Reference Files
| File | Why |
|---|---|
| `spec/services/lookup/material_lookup_service_spec.rb` lines 240-265 | Exact expectation |

---

## Implementation Steps

### Step 1 — Read the service and spec
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && cat app/services/lookup/material_lookup_service.rb'
```
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && sed -n "240,265p" spec/services/lookup/material_lookup_service_spec.rb'
```

### Step 2 — Run spec and confirm error
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/material_lookup_service_spec.rb:251 2>&1 | tail -20'
```

### Step 3 — Produce Synthesis Report and STOP
```
SYNTHESIS REPORT
JSON parsing location: [file and line]
Rescue block exists: [YES/NO]
Logger call exists: [YES/NO]
Exact fix: [show before/after code]
Risk: [any other callers affected]
```
Wait for approval.

### Step 4 — Apply fix
Add `Rails.logger.error("Invalid JSON in file: #{path}")` in the rescue block.
Do not change any other behavior — silent failure is acceptable, just needs logging.

### Step 5 — Verify isolation
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/material_lookup_service_spec.rb 2>&1 | tail -10'
```

### Step 6 — Check for regressions
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/ 2>&1 | tail -10'
```

### Step 7 — Commit from host
```bash
git add app/services/lookup/material_lookup_service.rb
git commit -m "fix: material_lookup_service — log error on JSON parse failure"
git push
```

---

## Acceptance Criteria
- [ ] Spec line 251 passes
- [ ] No regressions in lookup specs
- [ ] Log message matches `/Invalid JSON in file:/`

## Stop Conditions
- Rescue block is shared across multiple services — escalate before touching
- Service has no rescue block at all and adding one changes behavior significantly

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
