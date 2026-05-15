# 2026-03-22-MEDIUM-TASK-GUARDRAILS-SPLIT

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: Claude 1x — Medium priority documentation task requiring judgment on content placement
**Supervision Level**: Standard

## Context
docs/GUARDRAILS.md grown into mixed document with agent operating rules AND game design decisions. Local agents updated GUARDRAILS.md instead of correct docs. Result is 681 lines of mixed content.

## Problem Statement
GUARDRAILS.md contains game design decisions mixed with agent rules. Makes it hard for agents to find needed information.

**Expected**: GUARDRAILS.md contains agent operating rules only. Game design decisions live in correct subdirectory docs.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `docs/GUARDRAILS.md` | Source file | Remove game design sections, keep agent rules |
| `docs/architecture/WORMHOLE_NETWORK_INTENT.md` | Target file | Add Anchor Law section |
| `docs/architecture/DUAL_ECONOMY_INTENT.md` | Target file | Add Market & GCC, Economic System sections |
| `docs/architecture/visual_layer_stack.md` | Target file | Add Terrain Generation & Rendering section |
| `docs/architecture/terrainforge_layer.md` | Target file | Add Monitor Interface & Layer System section |
| `docs/architecture/biosphere_system.md` | Target file | Add Sphere Creation Optimization section |
| `docs/architecture/atmospheric_maintenance_system.md` | Target file | Add Atmospheric Maintenance Mandate section |
| `docs/flavor/EASTER_EGGS.md` | Target file | Add Sci-Fi Easter Eggs section |
| `docs/gameplay/mechanics.md` | Target file | Add Player Experience Boundaries section |
| `docs/architecture/ai_manager/` | Target file | Add Sol as Training Data section |

### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `docs/systems/em_power_shield_technology.md` | New file | EM Power Transition & Shield Technology Evolution section |

### Primary Files — you will move
| File | Purpose | Action |
|---|---|---|
| `docs/ADMIN_DASHBOARD_REDESIGN.md` | Orphan file | Move to docs/developer/ |
| `docs/escalation_data_flow.md` | Orphan file | Move to docs/architecture/ai_manager/ |
| `docs/luna_ai_manager_visualization.md` | Orphan file | Move to docs/architecture/ai_manager/ |
| `docs/orbital_settlement_strategies.md` | Orphan file | Move to docs/architecture/ |
| `docs/star_naming_architecture.md` | Orphan file | Move to docs/architecture/ |
| `docs/GUARDRAILS.md.old*` | Old versions | Move to docs/archive/ |

## Implementation Steps
1. **Read and map content**: Read GUARDRAILS.md, map each section to correct target file
2. **Produce content map**: Create plan showing what moves where, wait for approval
3. **Move content**: Append sections to target files with source note, remove from GUARDRAILS.md
4. **Create new file**: docs/systems/em_power_shield_technology.md with EM/Shield content
5. **Clean up GUARDRAILS.md**: Remove moved sections, add header note pointing to AGENT_ROUTING.md
6. **Move root orphans**: Move 5 misplaced root files to correct subdirectories
7. **Archive old versions**: Move GUARDRAILS.md.old* files to archive/

## Acceptance Criteria
- [ ] GUARDRAILS.md contains agent operating rules only
- [ ] GUARDRAILS.md has header note pointing to AGENT_ROUTING.md
- [ ] All game design sections moved to correct target files
- [ ] No duplicate content created in target files
- [ ] docs/systems/em_power_shield_technology.md created
- [ ] 5 root orphan files moved to correct subdirectories
- [ ] 4 GUARDRAILS .old files archived

## Stop Conditions
- Don't move content without approval of content map
- If section doesn't fit target — flag it, don't guess
- If target already covers content — skip, don't duplicate

## Commit Instructions
```bash
git add docs/GUARDRAILS.md docs/architecture/ docs/flavor/ docs/gameplay/ docs/systems/
git commit -m "docs: move game design content from GUARDRAILS.md to correct docs"
git add docs/
git commit -m "docs: move root orphan files, archive GUARDRAILS old versions"
```