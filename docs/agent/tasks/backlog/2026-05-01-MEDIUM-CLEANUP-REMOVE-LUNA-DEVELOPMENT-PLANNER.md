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

## Acceptance Criteria
- `LunaDevelopmentPlanner` file removed from codebase
- No Ruby files contain hardcoded Luna bootstrap phases or resource constants
- All tests still pass (this file should not be referenced by anything)
