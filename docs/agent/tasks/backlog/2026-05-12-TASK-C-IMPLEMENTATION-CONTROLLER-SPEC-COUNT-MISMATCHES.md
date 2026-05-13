# TASK C: Controller Specs Implementation & Verification
**Status**: BLOCKED
**Priority**: MEDIUM
**Type**: implementation
**Created**: 2026-05-12
**Parent Task**: 2026-05-12-MEDIUM-BUGFIX-CONTROLLER-SPEC-COUNT-MISMATCHES (decomposed)

---

## Agent Assignment
**Assigned To**: GPT-4.1 (0.75x)
**Why This Agent**: Precise implementation following approved strategy
**Supervision Level**: 🟢 Light oversight

---

## Context
Implementation phase following human-approved synthesis. Execute fixes according to approved strategy only.

---

## Prerequisites
- Task A (Investigation) completed
- Task B (Synthesis & Approval) completed with approved strategy
- Synthesis report available with specific fix instructions

---

## Implementation Steps

### Step 1 — Review Approved Strategy
Read synthesis report and confirm understanding of:
- Approved fix approach
- Order of implementation
- Risk mitigation steps

### Step 2 — Implement Count Mismatch Fixes
Apply fixes for the three count mismatch failures according to approved strategy:

**Failure 1 — MapStudioController celestial bodies (line 35)**
- [Specific implementation steps from synthesis report]

**Failure 2 — MapStudioController target planets (line 55)**
- [Specific implementation steps from synthesis report]

**Failure 3 — GameController planet count (line 94)**
- [Specific implementation steps from synthesis report]

### Step 3 — Implement Validation Response Fix
Apply fix for the 422 vs 200 response failure:

**Failure 4 — TerrestrialPlanetsController invalid params (line 108)**
- [Specific implementation steps from synthesis report]

### Step 4 — Run Verification Tests
Test each fix individually:
```bash
# Test each spec after its fix
docker exec -it web bash -c 'cd /home_galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/admin/map_studio_controller_spec.rb:32'
docker exec -it web bash -c 'cd /home_galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/admin/map_studio_controller_spec.rb:51'
docker exec -it web bash -c 'cd /home_galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/game_controller_spec.rb:92'
docker exec -it web bash -c 'cd /home_galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/terrestrial_planets_spec.rb:105'
```

### Step 5 — Run Regression Tests
Verify no impact on broader controller test suite:
```bash
docker exec -it web bash -c 'cd /home_galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/ 2>&1 | tail -15'
```

### Step 6 — Commit Changes
```bash
git add [specific files modified]
git commit -m "fix: controller specs — resolve count mismatches and 422 response

- Fixed celestial bodies count mismatch (expected 5, got 21)
- Fixed target planets count mismatch (expected 3, got 19)
- Fixed planet count mismatch (expected 2, got 12)
- Fixed invalid params response (422 instead of 200)

Root cause: [brief summary from synthesis report]
Approach: [controller changes / spec changes / hybrid]"
```

---

## Acceptance Criteria
- [ ] All four specs pass individually
- [ ] No regressions in controller test suite
- [ ] Changes committed with descriptive message
- [ ] Implementation follows approved synthesis strategy exactly

## Stop Conditions
- Implementation deviates from approved strategy
- Unexpected test failures during verification
- Changes affect non-target controller behavior

## Completion Report
**Completed by**:
**Completion date**:
**Files Modified**: [list of changed files]
**Tests Fixed**: 4 controller specs
**Regressions**: [None/Minor/Major - details]
**Commit Hash**: [hash]