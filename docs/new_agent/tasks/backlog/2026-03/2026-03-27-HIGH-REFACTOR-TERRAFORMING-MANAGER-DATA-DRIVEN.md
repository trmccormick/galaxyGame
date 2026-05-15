# 2026-03-27-HIGH-REFACTOR-TERRAFORMING-MANAGER-DATA-DRIVEN

**Agent**: 0.33x  
**Priority**: HIGH  
**Type**: refactor  
**Status**: BACKLOG  

## Context
TerraformingManager is currently built around a hardcoded @worlds hash with named keys (:mars, :venus, :titan, :saturn). This makes the service brittle and non-extensible. The correct architecture is to accept a solar_system and dynamically query its celestial_bodies, removing all hardcoded world references.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/ai_manager.md` — AI manager service structure
- `docs/architecture/solar_system.md` — Solar system and celestial body relationships

## Problem
The current implementation:
- Accepts a worlds hash in the initializer
- Uses @worlds[world_key] lookups throughout (15+ places)
- Has hardcoded world names in comments and logic

**Current behavior**: Only works for the four hardcoded worlds, cannot generalize to new bodies.  
**Expected behavior**: Accepts a solar_system, queries celestial_bodies dynamically, and never hardcodes world names.

## Files
- `app/services/ai_manager/terraforming_manager.rb` — Main service, all references to @worlds, world_key
- `spec/services/ai_manager/terraforming_manager_spec.rb` — Tests, all world setup and references

## Steps
1. Change TerraformingManager initializer to accept a solar_system, not a worlds hash
2. Replace all @worlds[world_key] and @worlds.each references with dynamic queries against solar_system.celestial_bodies
3. Remove all hardcoded world name references and comments
4. Update specs to build solar_system and celestial_bodies, not a worlds hash
5. Verify all tests pass

## Acceptance Criteria
- [ ] No @worlds hash or hardcoded world names remain
- [ ] All world lookups are dynamic via solar_system.celestial_bodies
- [ ] All tests pass

## Stop Conditions
- Fix causes new failures in specs you did not touch
- Root cause is in a shared concern or model
- Architectural decision required

## Commit Message
`refactor: terraforming_manager — data-driven solar system queries`