# 2026-03-27-HIGH-REFACTOR-TERRAFORMING-MANAGER-DATA-DRIVEN

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority refactor for terraforming manager data-driven architecture
**Supervision Level**: 🔴 Watched carefully

## Context
TerraformingManager built around hardcoded @worlds hash with named keys (:mars, :venus, :titan, :saturn). Makes service brittle and non-extensible. Correct architecture accepts solar_system and dynamically queries celestial_bodies, removing all hardcoded world references.

## Problem Statement
Current implementation accepts worlds hash, uses @worlds[world_key] lookups throughout, has hardcoded world names. Only works for four hardcoded worlds, cannot generalize to new bodies.

**Expected**: Accepts solar_system, queries celestial_bodies dynamically, never hardcodes world names.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/services/ai_manager/terraforming_manager.rb` | Main service | Replace @worlds hash with solar_system.celestial_bodies dynamic queries |
| `spec/services/ai_manager/terraforming_manager_spec.rb` | Tests | Update specs to build solar_system and celestial_bodies instead of worlds hash |

## Implementation Steps
1. **Change initializer**: Modify TerraformingManager to accept solar_system instead of worlds hash
2. **Replace lookups**: Replace all @worlds[world_key] and @worlds.each references with dynamic queries against solar_system.celestial_bodies
3. **Remove hardcoded names**: Eliminate all hardcoded world name references and comments
4. **Update specs**: Modify tests to build solar_system and celestial_bodies instead of worlds hash
5. **Verify tests**: Ensure all tests pass with new data-driven approach

## Acceptance Criteria
- [ ] No @worlds hash or hardcoded world names remain in service
- [ ] All world lookups are dynamic via solar_system.celestial_bodies
- [ ] All tests pass with new data-driven architecture
- [ ] Service can work with any solar system and its celestial bodies

## Stop Conditions
- Breaking existing terraforming manager functionality
- Changes beyond terraforming manager service and specs

## Commit Instructions
```bash
git add app/services/ai_manager/terraforming_manager.rb
git add spec/services/ai_manager/terraforming_manager_spec.rb
git commit -m "refactor: Terraforming manager data-driven architecture with solar_system.celestial_bodies"
```