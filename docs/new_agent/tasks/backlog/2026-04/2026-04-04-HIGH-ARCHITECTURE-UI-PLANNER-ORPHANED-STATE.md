# 2026-04-04-HIGH-ARCHITECTURE-UI PLANNER ORPHANED STATE

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
[2026-03-24] - HIGH: IMPLEMENT ORPHANED SYSTEM LOGIC IN MISSION PLANNER UI
CONTEXT & ARCHITECTURE:
This task implements the "Network Partition" (Orphaned) state within the AI Manager Mission Planner. ...

---

## Original Content

[2026-03-24] - HIGH: IMPLEMENT ORPHANED SYSTEM LOGIC IN MISSION PLANNER UI
CONTEXT & ARCHITECTURE:
This task implements the "Network Partition" (Orphaned) state within the AI Manager Mission Planner. When a system is disconnected from the Sol-side GCC sync (e.g., Eden post-Snap), the UI must transition from a "Galactic Trade" model to a "Local Physics & Scarcity" model.

CORE REFERENCES:

GUARDRAILS.md: AI Manager strategic boundaries

AI_MANAGER_PLANNER.md: UI Layout and SimEarth aesthetic standards

asteroid_conversion_physics.md: Physical constraints for towing/composition

CONTRIBUTOR_TASK_PLAYBOOK.md: Git and logging protocols

MANDATORY CONSTRAINTS:

Use fully qualified names: AIManager::MissionPlannerService, Location::SpatialLocation.

All RSpec runs MUST use: > ./log/rspec_full_$(date +%s).log 2>&1

Test commands MUST use: unset DATABASE_URL && RAILS_ENV=test

Use GalaxyGame::Paths::CONSTANT for all file system references.

IMPLEMENTATION STEPS:

Controller Layer (Admin::AiManager::PlannerController)

Modify #index and #simulate to detect connectivity_status of the target_system.

Pass @is_orphaned boolean to the view context.

Service Layer (AIManager::MissionPlannerService)

Sourcing Override: If is_orphaned is true, set earth_import weight to 0 and force local_production as the sole source.

Towing Logic: If pattern == :asteroid_mining or :asteroid_conversion, calculate towing_duration based on asteroid.mass and target_distance. Prepend this phase to the simulation timeline.

Scarcity Pricing: Apply a 5.0x multiplier to the EconomicForecasterService results for resources tagged high_tech.

View Layer (Rails/JS)

Add a red terminal-style banner: _orphaned_connection_alert.html.erb.

Disable/Gray-out "Earth Import" toggles in the configuration form when an orphaned system is selected.

Update the Timeline JS to render a "Towing Phase" block with tooltips for Mass, Composition, and Fracture Risk.

VERIFICATION COMMANDS:

Bash
# Run specialized tests for Orphaned State logic
unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/mission_planner_service_spec.rb > ./log/rspec_full_$(date +%s).log 2>&1

# Verify UI Controller response
unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/admin/ai_manager/planner_controller_spec.rb > ./log/rspec_full_$(date +%s).log 2>&1
COMPLETION STATUS: ⬜ PENDING

[ ] Orphaned state detected in Controller

[ ] Earth import disabled in Service

[ ] Towing phase duration calculated and prepended to timeline

[ ] UI reflects "Network Partition" terminal alert
