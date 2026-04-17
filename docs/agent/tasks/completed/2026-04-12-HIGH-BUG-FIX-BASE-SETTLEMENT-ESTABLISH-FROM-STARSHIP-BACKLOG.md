# TASK: BaseSettlement#establish_from_starship — Remove Stale Deployment Method
**Status**: BACKLOG
**Priority**: LOW
**Type**: refactor
**Created**: 2026-04-12
**Last Updated**: 2026-04-12

---

## Context
`BaseSettlement#establish_from_starship` references a starship deployment
pattern that no longer exists. Settlements are established by craft
operating in precursor or cycler missions — not by a dedicated Starship
class. This method is dead code and references `CargoManifestLoader` and
a starship inventory pattern that may not exist.

## Problem Statement
**Current**: `establish_from_starship(starship, location)` exists in
`BaseSettlement` and will confuse any agent or developer reading the file.
**Expected**: Method removed, deployment pattern documented correctly.

## Files Involved
- `app/models/settlement/base_settlement.rb` — remove method
- `docs/architecture/` — flag for documentation update on correct
  settlement establishment pattern

## Acceptance Criteria
- [ ] Method removed
- [ ] No references to it in service layer
- [ ] BaseSettlement specs still pass

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing
**Related**: `2026-04-12-HIGH-ARCHITECTURE-ORBITAL-SETTLEMENT-DECOUPLE-FROM-BASE.md`
