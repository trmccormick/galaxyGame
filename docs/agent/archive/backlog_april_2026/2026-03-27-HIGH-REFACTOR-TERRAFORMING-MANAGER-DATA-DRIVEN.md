# TASK: Refactor TerraformingManager to be Data-Driven
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: refactor  
**Created**: 2026-03-27  
**Last Updated**: 2026-03-27  

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Deep architectural refactor, requires explicit pathing and test discipline  
**Supervision Level**: watched carefully  

---

## Context
TerraformingManager is currently built around a hardcoded @worlds hash with named keys (:mars, :venus, :titan, :saturn). This makes the service brittle and non-extensible. The correct architecture is to accept a solar_system and dynamically query its celestial_bodies, removing all hardcoded world references.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/ai_manager.md` — AI manager service structure
- `docs/architecture/solar_system.md` — Solar system and celestial body relationships

---

## Problem Statement
The current implementation:
- Accepts a worlds hash in the initializer
- Uses @worlds[world_key] lookups throughout (15+ places)
- Has hardcoded world names in comments and logic

**Current behavior**: Only works for the four hardcoded worlds, cannot generalize to new bodies.  
**Expected behavior**: Accepts a solar_system, queries celestial_bodies dynamically, and never hardcodes world names.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/terraforming_manager.rb` | Main service | all references to @worlds, world_key |
| `spec/services/ai_manager/terraforming_manager_spec.rb` | Tests | all world setup and references |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/solar_system.rb` | Association to celestial_bodies |
| `app/models/celestial_body.rb` | World/planet model |

### Migration (if needed)
- [x] No migration needed

---

## Implementation Steps
1. Change TerraformingManager initializer to accept a solar_system, not a worlds hash.
2. Replace all @worlds[world_key] and @worlds.each references with dynamic queries against solar_system.celestial_bodies.
3. Remove all hardcoded world name references and comments.
4. Update specs to build solar_system and celestial_bodies, not a worlds hash.
5. Verify all tests pass.

---

## Synthesis Report Format
(see TASK_TEMPLATE.md)

---

## Testing Sequence
1. Isolation run: spec/services/ai_manager/terraforming_manager_spec.rb
2. Related specs: spec/services/ai_manager/
3. Full suite: see WORKFLOW_README.md

---

## Acceptance Criteria
- [ ] No @worlds hash or hardcoded world names remain
- [ ] All world lookups are dynamic via solar_system.celestial_bodies
- [ ] All tests pass

---

## Stop Conditions
- Fix causes new failures in specs you did not touch
- Root cause is in a shared concern or model
- Architectural decision required

---

## Commit Instructions
See TASK_TEMPLATE.md

---

## Documentation
- [ ] Update `docs/architecture/ai_manager.md` — note new data-driven pattern

---

## Dependencies
**Blocked by**: none  
**Blocks**: none  
**Related tasks**: none  

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `[file]` — [description of change]

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]
