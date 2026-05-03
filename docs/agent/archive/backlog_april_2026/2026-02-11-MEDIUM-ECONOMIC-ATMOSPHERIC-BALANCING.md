
# 2026-02-11-MEDIUM-ECONOMIC-ATMOSPHERIC-BALANCING.md

**Status:** STOPPED — Pending review and approval
**Priority:** MEDIUM
**Type:** feature review (economic/simulation)
**Created:** 2026-02-11
**Last Updated:** 2026-04-17

---

## Agent Assignment
**Assigned To:** Economic/Simulation Feature Review Agent (human or LLM)
**Why This Agent:** Requires review of economic simulation, player agency, and AI integration
**Supervision Level:** Review required before implementation

---

## Context
This task implements economic balancing for atmospheric maintenance, integrating GCC cost calculations, ROI logic, and player agency/override features. It is unique in the backlog and not superseded by any other economic or atmospheric maintenance task. The parent epic is atmospheric_maintenance_ai_framework.md.

---

## Target Files
- app/services/ai_manager/
- app/models/market/
- app/models/financial/
- app/models/terraforming_project.rb
- app/jobs/location_operations_job.rb
- app/services/launch_payment_service.rb
- Economic engine, AI Manager, and market logic
- RSpec: spec/services/ai_manager/, spec/models/market/, spec/models/financial/

---

## Acceptance Criteria
- GCC cost calculations and ROI logic implemented for atmospheric maintenance
- Player override/agency logic present and testable
- RSpec coverage for economic simulation and player override scenarios

---

## Subtasks
1. Integrate GCC cost calculations and ROI logic for atmospheric maintenance
2. Implement player agency/override logic for economic decisions
3. Write/extend RSpec for economic simulation and override scenarios

---

## Review Block
**STOPPED for review and approval before implementation.**
No implementation or design work should proceed until this feature set is reviewed and approved by the assigned agent(s).

---

## Commit Instructions
```
git add docs/agent/tasks/backlog/2026-02-11-MEDIUM-ECONOMIC-ATMOSPHERIC-BALANCING.md
# Do not implement until review and approval are complete
```
