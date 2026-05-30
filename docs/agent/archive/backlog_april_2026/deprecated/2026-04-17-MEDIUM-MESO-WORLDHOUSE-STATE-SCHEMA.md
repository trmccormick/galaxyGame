# 2026-04-17-MEDIUM-MESO-WORLDHOUSE-STATE-SCHEMA.md

**Status:** BLOCKED — Pending architectural plan
**Priority:** MEDIUM
**Type:** schema definition / integration
**Created:** 2026-04-17

---

## Context
Defines and validates the canonical JSON schemas for worldhouse construction, maintenance, and failure states. All simulation and AI modules must use these schemas for state tracking and validation. Blocked until the architectural planning task is complete.

---

## Target Files
- data/schemas/worldhouse_state.schema.json
- Integration points in:
  - app/models/structures/worldhouse.rb
  - app/services/worldhouse_maintenance.rb
  - app/services/worldhouse_failure_analyzer.rb
  - app/services/ai_manager/worldhouse_learning.rb
- RSpec: spec/models/structures/, spec/services/

---

## Acceptance Criteria
- Canonical JSON schema for all worldhouse states defined and validated
- Integrated with construction, maintenance, failure, and AI learning modules
- RSpec coverage for schema validation and integration

---

## Subtasks
1. Draft canonical JSON schema for worldhouse construction, maintenance, and failure states
2. Integrate schema validation with all relevant modules
3. Write/extend RSpec for schema validation and integration
4. Document schema and integration points in architecture docs

---

## Commit Instructions
```
git add docs/agent/tasks/backlog/2026-04-17-MEDIUM-MESO-WORLDHOUSE-STATE-SCHEMA.md data/schemas/worldhouse_state.schema.json
# Do not implement until architectural plan is complete
```
