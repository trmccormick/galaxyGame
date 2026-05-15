# TASK: WormholeConsortiumFormationService — Member Must Be Corporation
**Status**: COMPLETED
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-05-12
**Last Updated**: 2026-05-14

---

## Agent Assignment
**Assigned To**: GPT-4.1 (0x)
**Why This Agent**: Single file factory fix, fully mechanical, no inference needed
**Supervision Level**: 🔴 Watched carefully

---

## Context
`WormholeConsortiumFormationService` creates consortium memberships for founding
members. `ConsortiumMembership` validates that the member must be a corporation.
The spec is creating members without the corporation type.

---

## Problem Statement
**Error:**
```
ActiveRecord::RecordInvalid: Validation failed: Member must be a corporation
app/services/wormhole_consortium_formation_service.rb:21
spec/services/wormhole_consortium_formation_service_spec.rb:10
spec/services/wormhole_consortium_formation_service_spec.rb:20
```
**Current behavior**: Factory creates members without corporation type — validation fails
**Expected behavior**: Members are corporations — validation passes

---

## Files Involved

### Primary Files
| File | Purpose |
|---|---|
| `spec/services/wormhole_consortium_formation_service_spec.rb` | Spec using wrong factory trait |
| `spec/factories/` | Factory definition for members |

### Reference Files
| File | Why |
|---|---|
| `app/services/wormhole_consortium_formation_service.rb` | Do not edit — validation is correct |
| `app/models/consortium_membership.rb` | Understand the corporation validation |

---

## Implementation Steps

### Step 1 — Read the spec and factory
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && cat spec/services/wormhole_consortium_formation_service_spec.rb | head -30'
```
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && grep -rn "corporation\|consortium\|member" spec/factories/ | head -20'
```

### Step 2 — Run spec and confirm error
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/wormhole_consortium_formation_service_spec.rb 2>&1 | tail -20'
```

### Step 3 — Produce Synthesis Report and STOP
```
SYNTHESIS REPORT
Factory used for members: [name]
Corporation trait exists: [YES/NO]
Fix location: [spec or factory]
Exact change needed: [one line]
Risk: [any other specs using this factory]
```
Wait for approval before changing anything.

### Step 4 — Apply fix
Either use corporation trait in spec OR add trait to factory.
Do NOT change the validation in the service or model.

### Step 5 — Verify
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/wormhole_consortium_formation_service_spec.rb 2>&1 | tail -10'
```
Expected: 0 failures

### Step 6 — Commit from host
```bash
git add [specific files only]
git commit -m "fix: wormhole_consortium_spec — use corporation trait for member factory"
git push
```

---

## Acceptance Criteria
- [ ] Both spec lines 8 and 19 pass
- [ ] No regressions in related specs
- [ ] Validation in service/model untouched

## Stop Conditions
- Corporation trait doesn't exist and factory is used in more than 3 other specs
- Validation logic needs changing — escalate, do not touch

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
