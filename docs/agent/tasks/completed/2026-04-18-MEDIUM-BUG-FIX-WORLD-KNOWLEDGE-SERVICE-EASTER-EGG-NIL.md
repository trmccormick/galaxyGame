# TASK: WorldKnowledgeService Easter Egg Fix
**Status**: ACTIVE
**Priority**: MEDIUM
**Type**: bugfix
**Created**: 2026-04-23
**Last Updated**: 2026-04-23

---

## Context

Failure in `spec/services/ai_manager/world_knowledge_service_spec.rb:9`:
> expected nil to be a kind of Hash

Root cause: `generate_system_easter_egg` returns nil for wormhole systems, but spec expects a Hash.

---

## Implementation Steps

1. Read first 30 lines of the spec file for context.
2. Locate and review the `generate_system_easter_egg` method in `world_knowledge_service.rb`.
3. Synthesize the root cause and propose a fix.
4. Await approval before applying code changes.

---

## Proposed Fix Pattern

- If `system.has_wormhole?`, return a Hash (not nil):
  ```ruby
  { flavor_text: "Wormhole detected", anomaly_type: "exotic_matter" }
  ```

---

## Acceptance Criteria
- [ ] Spec passes: `spec/services/ai_manager/world_knowledge_service_spec.rb`
- [ ] No regressions in related code

---

## Commit Instructions
```bash
git add galaxy_game/app/services/ai_manager/world_knowledge_service.rb
# Commit message:
git commit -m "fix: always return Hash from generate_system_easter_egg (wormhole case)"
```
