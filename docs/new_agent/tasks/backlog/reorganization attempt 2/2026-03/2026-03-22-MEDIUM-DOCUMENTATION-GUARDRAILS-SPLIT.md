# 2026-03-22-MEDIUM-DOCUMENTATION-GUARDRAILS-SPLIT

**Agent:** GPT-4.1 (0.33x)
**Priority:** MEDIUM
**Type:** DOCUMENTATION
**Status:** BACKLOG

## Context
docs/GUARDRAILS.md has grown into a mixed document containing both agent operating rules AND game design decisions. Local agents couldn't find the correct doc for a topic so they updated GUARDRAILS.md instead. The result is 681 lines of mixed content.

## Problem
GUARDRAILS.md contains game design decisions mixed with agent rules. The correct home for each section already exists in docs/. This task moves game design content to those homes and leaves only agent operating rules in GUARDRAILS.md.

## Files
- docs/GUARDRAILS.md
- docs/architecture/WORMHOLE_NETWORK_INTENT.md
- docs/architecture/DUAL_ECONOMY_INTENT.md
- docs/architecture/visual_layer_stack.md
- docs/architecture/terrainforge_layer.md
- docs/architecture/biosphere_system.md
- docs/architecture/atmospheric_maintenance_system.md
- docs/flavor/EASTER_EGGS.md
- docs/gameplay/mechanics.md
- docs/architecture/ai_manager/
- docs/systems/em_power_shield_technology.md (new)
- docs/ADMIN_DASHBOARD_REDESIGN.md
- docs/escalation_data_flow.md
- docs/luna_ai_manager_visualization.md
- docs/orbital_settlement_strategies.md
- docs/star_naming_architecture.md
- docs/GUARDRAILS.md.old*

## Steps
1. Read and map current GUARDRAILS.md content
2. Produce Content Map and wait for approval
3. Move content to target files (after approval)
4. Create new file for EM/Shield content
5. Clean up GUARDRAILS.md
6. Move root orphan files to correct subdirectories
7. Archive GUARDRAILS old versions

## Acceptance Criteria
- GUARDRAILS.md contains agent operating rules only
- All game design sections moved to correct target files
- No duplicate content created
- docs/systems/em_power_shield_technology.md created
- 5 root orphan files moved to correct subdirectories
- 4 GUARDRAILS .old files archived

## Stop Condition
- Uncertain about content placement
- Target file already covers content well

## Commit Instructions
```
git add docs/GUARDRAILS.md docs/architecture/ docs/flavor/ docs/gameplay/ docs/systems/
git commit -m "docs: move game design content from GUARDRAILS.md to correct docs"
git add docs/
git commit -m "docs: move root orphan files, archive GUARDRAILS old versions"
```