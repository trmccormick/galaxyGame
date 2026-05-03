# TASK: MaterialLookupService — Fix corrupted JSON error log message
**Status**: ACTIVE
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-18
**Last Updated**: 2026-04-18

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single service file, grep to find log message, update to match spec
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agent: read every section carefully before starting.
> Do not infer file paths or method names — they are provided explicitly below.

---

## Context

`Lookup::MaterialLookupService` handles corrupted JSON files gracefully.
When a JSON parse error occurs it logs an error message. The spec expects
the message to match `/Invalid JSON in file:/`. The service either logs
a different message or does not log at all when JSON parsing fails.

---

## Problem Statement

**Error output:**
```
expected: 1 time with arguments: (/Invalid JSON in file:/)
received: 0 times
# ./spec/services/lookup/material_lookup_service_spec.rb:255
```

**Current behavior**: `Rails.logger.error` is either not called or called
with a different message when JSON parsing fails.

**Expected behavior**: `Rails.logger.error` called exactly once with a
message matching `/Invalid JSON in file:/`.

---

## Files Involved

### Primary Files — you will edit this
| File | Purpose | Key Section |
|---|---|---|
| `galaxy_game/app/services/lookup/material_lookup_service.rb` | Material lookup service | JSON error handling block |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/spec/services/lookup/material_lookup_service_spec.rb` | Lines 250-260 — exact spec expectation |

### Migration
- [x] No migration needed

---

## Implementation Steps

### Step 1 — Read the spec expectation
```bash
sed -n '245,265p' galaxy_game/spec/services/lookup/material_lookup_service_spec.rb
```

### Step 2 — Find current error handling in service
```bash
grep -n "rescue\|logger\|JSON\|parse\|error" galaxy_game/app/services/lookup/material_lookup_service.rb | head -20
```

### Step 3 — Apply fix
The error log message must contain `"Invalid JSON in file:"` followed by
the file path. Update the rescue block to log exactly:
```ruby
Rails.logger.error("Invalid JSON in file: #{file_path}")
```
Where `file_path` is whatever variable holds the current file being parsed.

---

## Synthesis Report Format
Before applying any fix, produce a report in this format and **stop**:

```
THE FAILURE
Spec: spec/services/lookup/material_lookup_service_spec.rb:254
Error: Rails.logger.error expected 1 time with /Invalid JSON in file:/,
       received 0 times
Expected: logger called with correct message
Got: logger not called or called with wrong message

ROOT CAUSE
[paste exact current rescue/log code from service]

PROPOSED FIX
[exact line change]

RISK
Low — only affects error logging path, not happy path.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. **Isolation run:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/material_lookup_service_spec.rb:254 2>&1 | grep -E "example|failure" | tail -5'
```
Expected: `1 example, 0 failures`

2. **Full spec file:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/lookup/material_lookup_service_spec.rb 2>&1 | grep -E "example|failure" | tail -5'
```
Expected: 0 new failures introduced.

---

## Acceptance Criteria
- [ ] `material_lookup_service_spec.rb:254` — 0 failures
- [ ] No regressions in material lookup specs

---

## Stop Conditions — escalate to user immediately if:
- Service has no rescue block for JSON errors at all — needs design decision
- Fix requires changing the public interface of the service
- More than one log call needs updating

---

## Commit Instructions
```bash
git add galaxy_game/app/services/lookup/material_lookup_service.rb
git commit -m "fix: material_lookup_service — update corrupted JSON error log message to match spec expectation"
git push
```

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
