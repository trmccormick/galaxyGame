# TASK: Fix TaskExecutionEngineV2 — Replace Hardcoded load_environment with Real DB Read

**Status**: ACTIVE
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-05-01
**Last Updated**: 2026-05-02
**MVP Gate**: YES — without this the engine cannot assess any world's actual capabilities
**Depends On**: ✅ PrecursorCapabilityService refactor COMPLETE (commit 6d8efd1a, 2026-05-02)

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Exact replacement code provided in this task. Follow the pattern — no judgment calls needed.
**Supervision Level**: 🟡 Standard — verify it reads from DB not stub before closing

---

## Why This Blocks Luna MVP

`TaskExecutionEngineV2` is the generic, data-driven task runner. It's supposed to
load world properties from the database so the same engine works for Luna, Mars,
Titan, or any new body. Currently `load_environment` returns a hardcoded stub:

```ruby
def load_environment(target_body)
  # Placeholder: In real use, query DB or API for body properties
  { "name" => target_body, "atmosphere" => false, "regolith" => true }
end
```

This means the engine ignores real world data and the "data-driven, not world-driven"
design principle is violated. The entire point of this engine is world-agnostic
operation driven by DB state.

---

## Fix

**File**: `galaxy_game/app/services/ai_manager/task_execution_engine_v2.rb`

Replace `load_environment` to query the actual `CelestialBody` record and use
`PrecursorCapabilityService` to derive world capabilities:

```ruby
def load_environment(target_body)
  body = CelestialBodies::CelestialBody.find_by(identifier: target_body)
  return { "name" => target_body, "status" => :not_found } unless body

  capabilities = AIManager::PrecursorCapabilityService.new(body).production_capabilities

  {
    "name"            => body.name,
    "identifier"      => body.identifier,
    "atmosphere"      => body.atmosphere.present?,
    "has_regolith"    => capabilities[:surface].any?,
    "local_resources" => capabilities[:surface] + capabilities[:atmosphere].to_a,
    "isru_capable"    => capabilities[:isru_options].any?,
    "capabilities"    => capabilities
  }
end
```

Also update `initialize` to accept either an identifier string or a CelestialBody object:

```ruby
def initialize(target_body, manifest = {})
  @target_body = target_body.is_a?(String) ? target_body : target_body.identifier
  # ... rest unchanged
end
```

---

## Acceptance Criteria
- `load_environment` queries the DB — no hardcoded world properties
- Passing a `CelestialBody` object or an identifier string both work
- If body not found, returns `{ status: :not_found }` gracefully
- `PrecursorCapabilityService` must be passing before this task starts
- Engine still works for non-Luna bodies (Mars, Titan) via same code path
