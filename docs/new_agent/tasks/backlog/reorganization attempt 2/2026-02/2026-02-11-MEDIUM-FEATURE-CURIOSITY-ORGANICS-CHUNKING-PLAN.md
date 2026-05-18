# 2026-02-11-MEDIUM-FEATURE-CURIOSITY-ORGANICS-CHUNKING-PLAN

**Agent:** GPT-4.1 (0.33x)
**Priority:** MEDIUM
**Type:** FEATURE
**Status:** STOPPED

## Context
This task implements new biology/gameplay features based on Curiosity rover organic discoveries and their implications for Mars settlement gameplay. Features include region-based biomass boosts, new scannable resources, AI site selection logic, supply chain enhancements, and narrative/lore triggers.

## Problem
Curiosity rover discoveries of organic compounds on Mars need to be integrated into gameplay mechanics to create meaningful biology-based features for settlement and resource management.

## Files
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
- data/json-data/
- spec/models/biology/
- spec/services/ai_manager/

## Steps
1. Implement +20% biomass production boost for Worldhouses in regions with confirmed organic deposits
2. Add "Fatty Acid Density" as a scannable resource for precursor drones
3. Apply growth acceleration buff for first Worldhouse in organic-rich areas
4. Update AI to prioritize lava tubes beneath ancient lakebeds for initial settlement
5. Refactor Ceres to act as nutrient catalyst supplier, unlocking Martian organic bonuses
6. Reference Curiosity discoveries in narrative and mission briefings
7. Add comprehensive RSpec coverage for all new logic

## Acceptance Criteria
- +20% biomass production boost for Worldhouses in organic-rich regions (Gale Crater, Hebes Chasma)
- "Fatty Acid Density" added as scannable resource for precursor drones
- Growth acceleration buff for first Worldhouse in organic-rich areas
- AI prioritizes lava tubes beneath ancient lakebeds for settlement
- Ceres acts as nutrient catalyst supplier for Martian organic bonuses
- Curiosity discoveries referenced in narrative and mission briefings
- RSpec coverage for all new logic and triggers

## Stop Condition
- Feature set reviewed and approved by assigned agent

## Commit Instructions
```
git add docs/new_agent/tasks/backlog/2026-02/2026-02-11-MEDIUM-FEATURE-CURIOSITY-ORGANICS-CHUNKING-PLAN.md
git commit -m "docs: add curiosity organics chunking plan feature (stopped pending review)"
```