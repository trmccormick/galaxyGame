# TASK: Remove LunaDevelopmentPlanner — Wrong Design, Luna Knowledge Moved to JSON

**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: cleanup
**Created**: 2026-05-01
**MVP Gate**: NO — but must happen before Luna profile is considered "complete"
**Depends On**: LUNA-SETTLEMENT-MISSION-PROFILE-JSON task completed

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Supervision Level**: 🟢 Low — deletion only, no new code

---

## Context

`galaxy_game/app/services/ai_manager/luna_development_planner.rb` is the exact
anti-pattern we are eliminating. It hardcodes Luna's bootstrap phases as Ruby constants:

```ruby
BOOTSTRAP_PHASES = [
  { phase: :gcc_satellite, ... corporation: :zenith_orbital },
  { phase: :titan_harvesters, ... corporation: :astrolift },
  ...
]
RESOURCE_REQUIREMENTS = {
  gcc_satellite: { usd: 50000, time_days: 30 },
  ...
}
```

This is Luna-specific knowledge that belongs in the JSON mission profile, not in Ruby.
Once `luna_settlement_profile_v1.json` exists, this file has no purpose.

---

## Steps

1. Confirm nothing in app/ or spec/ calls `AIManager::LunaDevelopmentPlanner` directly
   ```
   grep -rn "LunaDevelopmentPlanner" galaxy_game/app/ galaxy_game/spec/
   ```
2. If no callers exist: delete the file
3. If callers exist: list them and STOP for review (do not rewrite)
4. Delete or move corresponding spec if one exists

---

## Progress (as of 2026-05-08)

### Current Status
- This cleanup task is **on hold** and not yet started.
- `luna_development_planner.rb` still exists in the codebase and contains hardcoded Luna bootstrap phases and resource constants.
- No evidence that the file has been deleted or that its logic has been fully migrated to JSON.
- The task's steps and acceptance criteria remain fully relevant and actionable.

### Findings
- The anti-pattern of hardcoded Luna logic in Ruby is still present and must be removed before the Luna profile is considered complete.
- No references to `LunaDevelopmentPlanner` have been removed or updated in the codebase.
- The task is **not stale** and should remain in the backlog for future cleanup.

### Next Steps
- Leave task in BACKLOG until the Luna JSON profile is complete and the Ruby file is confirmed unused and deleted.
- When reactivated: follow the steps to confirm no callers, then delete the file and any related specs.

---

## Acceptance Criteria
- `LunaDevelopmentPlanner` file removed from codebase
- No Ruby files contain hardcoded Luna bootstrap phases or resource constants
- All tests still pass (this file should not be referenced by anything)
