
# 2026-02-11-MEDIUM-BIOLOGY-CURIOSITY_ORGANICS_CHUNKING_PLAN.md

**Status:** STOPPED — Pending review and approval
**Priority:** MEDIUM
**Type:** feature review (biology/gameplay)
**Created:** 2026-02-11
**Last Updated:** 2026-04-17

---

## Agent Assignment
**Assigned To:** Biology/Gameplay Feature Review Agent (human or LLM)
**Why This Agent:** Requires cross-disciplinary review of simulation, AI, and narrative integration
**Supervision Level:** Review required before implementation

---

## Context
This task implements new biology/gameplay features based on Curiosity rover organic discoveries and their implications for Mars settlement gameplay. Features include region-based biomass boosts, new scannable resources, AI site selection logic, supply chain enhancements, and narrative/lore triggers. No overlapping or duplicate tasks exist in the current backlog or docs.

---

## Target Files
- app/models/biology/
- app/services/ai_manager/
- app/services/resource_tracking_service.rb
- app/services/autonomous_mission_service.rb
- app/services/ai_manager/colony_manager.rb
- app/services/ai_manager/precursor_learning_service.rb
- app/services/ai_manager/system_architect.rb
- app/services/ai_manager/task_execution_engine.rb
- app/controllers/admin/resources_controller.rb
- app/controllers/admin/celestial_bodies/spheres_controller.rb
- data/json-data/ (for region/resource mapping)
- RSpec: spec/models/biology/, spec/services/ai_manager/

---

## Acceptance Criteria
- +20% biomass production boost for Worldhouses in regions with confirmed organic deposits (e.g., Gale Crater, Hebes Chasma)
- "Fatty Acid Density" added as a scannable resource for precursor drones
- Growth acceleration buff for first Worldhouse in organic-rich areas
- AI prioritizes lava tubes beneath ancient lakebeds for initial settlement
- Ceres acts as a nutrient catalyst supplier, unlocking Martian organic bonuses via supply chain
- Curiosity 2025/2026 discoveries referenced in narrative and mission briefings
- RSpec coverage for all new logic and triggers

---

## Subtasks
1. **Legacy Organics Mechanic**
   - Implement a +20% biomass production boost for Worldhouses in regions with confirmed organic deposits.
   - RSpec: region-based production modifier.
2. **Fatty Acid Density Resource**
   - Add "Fatty Acid Density" as a scannable resource for precursor drones.
   - RSpec: drone scan and resource mapping.
3. **Ancient Bloom Buff**
   - Apply a growth acceleration buff to the first Worldhouse built in organic-rich areas.
   - RSpec: first-structure bonus logic.
4. **Sedimentary Basin AI Priority**
   - Update AI to prioritize lava tubes beneath ancient lakebeds for initial settlement.
   - RSpec: AI site selection logic.
5. **Ceres-Mars Bridge Enhancement**
   - Refactor Ceres to act as a nutrient catalyst supplier, unlocking Martian organic bonuses via supply chain.
   - RSpec: supply chain and unlock logic.
6. **Lore Integration**
   - Reference Curiosity 2025/2026 discoveries in game narrative and mission briefings.
   - RSpec: narrative/lore triggers.

---

## Review Block
**STOPPED for review and approval before implementation.**
No implementation or design work should proceed until this feature set is reviewed and approved by the assigned agent(s).

---

## Commit Instructions
```
git add docs/agent/tasks/backlog/2026-02-11-MEDIUM-BIOLOGY-CURIOSITY_ORGANICS_CHUNKING_PLAN.md
# Do not implement until review and approval are complete
```
