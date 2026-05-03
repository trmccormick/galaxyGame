# 2026-04-17-MEDIUM-MACRO-ATMOSPHERIC-STATE-SCHEMA.md

**Status:** TODO
**Priority:** MEDIUM
**Type:** schema definition / integration
**Created:** 2026-04-17
**Last Updated:** 2026-04-17

---

## Agent Assignment
**Assigned To:** Simulation/Data Integration Agent (human or LLM)
**Why This Agent:** Requires architectural review and schema design for planetary simulation
**Supervision Level:** Review required before implementation

---

## Context
This task defines and validates the canonical JSON schema for planetary atmospheric state tracking. It is a foundational requirement for the Digital Twin Sandbox, TerraSim, and all AI/automation modules that serialize, validate, or exchange atmospheric state data. It implements Phase 3 (Data Integration) of the atmospheric_maintenance_ai_framework epic. The schema will support seasonal modifiers, dust storm triggers, resource monitoring, and robust event-driven simulation logic.

---

## Target Files
- data/schemas/atmospheric_state.schema.json
- Integration points in:
  - app/services/ai_manager/atmospheric_evaluator.rb
  - app/services/ai_manager/stabilization_planner.rb
  - app/services/ai_manager/maintenance_scheduler.rb
  - app/services/ai_manager/failure_predictor.rb
  - TerraSim modules
  - Digital Twin Sandbox modules
- RSpec: spec/services/ai_manager/, spec/terrasim/, spec/digital_twin/

---

## Acceptance Criteria
- Canonical JSON schema for atmospheric state defined and validated
- Integrated with AI Manager, TerraSim, and Digital Twin Sandbox
- RSpec coverage for schema validation and integration
- Supports event triggers (dust storms, seasonal modifiers, resource monitoring)

---

## Subtasks
1. Draft canonical JSON schema for atmospheric state (data/schemas/atmospheric_state.schema.json)
2. Integrate schema validation with AI Manager, TerraSim, and Digital Twin Sandbox
3. Write/extend RSpec for schema validation and integration
4. Document schema and integration points in GUARDRAILS.md and architecture docs

---

## Commit Instructions
```
git add docs/agent/tasks/backlog/2026-04-17-MEDIUM-MACRO-ATMOSPHERIC-STATE-SCHEMA.md data/schemas/atmospheric_state.schema.json
# Move the original 2026-02-11-MEDIUM-MACRO-ATMOSPHERIC-STATE-SCHEMA.md to docs/agent/tasks/backlog/old/
```
