# Operational Guardrails — Galaxy Game
**Last Updated**: 2026-07-03 (GUARDRAILS consolidation)  
**Status**: Trimmed to migration index. All substantive content has been extracted or merged per the consolidated plan at:
`/Users/tam0013/Documents/git/agent-tasks/projects/galaxy_game/tasks/backlog/2026-07-02-HIGH-DOCUMENTATION-GUARDRAILS-CONSOLIDATION.md`

> This file was trimmed from 680 lines to a migration index during GUARDRAILS consolidation, 2026-07-03.
> All agent rules, game design content, and project-specific process rules have been moved to their destinations below.
> Do not add new content here — use the appropriate destination file listed below.

---

## Migration Index

### Destination 1: Generic Agent Rules → agent-tasks/rules/GUARDRAILS.md
All generic agent operational rules (Docker, RSpec, database migrations, token conservation, etc.) are now consolidated in the authoritative cross-project file:
- **File**: `/Users/tam0013/Documents/git/agent-tasks/rules/GUARDRAILS.md` (425 lines)
- **Status**: 2 gaps identified for merge — awaiting explicit human review before writing

### Destination 2: Gaps for agent-tasks/rules/GUARDRAILS.md (AWAITING HUMAN REVIEW)
Two generic rules from docs/GUARDRAILS.md are NOT yet in agent-tasks/rules/GUARDRAILS.md. Present these to human for approval before merging:

**Gap A**: `unset DATABASE_URL && RAILS_ENV=test` mandatory prefix for ALL test commands  
→ Add to Rule 2 (Database Migrations) and Rule 3 (RSpec Execution) in agent-tasks/rules/GUARDRAILS.md

**Gap B**: Container lifecycle prohibition ("Containers always running" clause with forbidden commands list)  
→ Add as new sub-heading under Rule 1 (Docker) in agent-tasks/rules/GUARDRAILS.md

### Destination 3: Galaxy Game–Specific Process Rules → docs/galaxy_game_agent_rules.md
Project-specific rules extracted from this file:
- **File**: `/Users/tam0013/Documents/git/galaxyGame/docs/galaxy_game_agent_rules.md`
- **Content**: Universal Docking & Chassis Integration, Material Loss Logic for Interplanetary Transit

### Destination 4: Game Design Content → galaxyGame docs/ subdirectories

| Original Section | New Location |
|---|---|
| AI Manager §1: Code & Documentation Sync | `docs/architecture/ai_manager/AI_MANAGER_CODE_REVIEW_PROTOCOL.md` (appended) |
| AI Manager §2: Anchor Law | `docs/architecture/ai_manager/AI_MANAGER_WORMHOLE_EXPANSION.md` (appended) |
| AI Manager §3: Market & GCC Integrity | `docs/architecture/economy/MARKET_OPERATIONS.md` + `CURRENCY_AND_EXCHANGE.md` (merged) |
| AI Manager §5: Operational Boundaries + Namespace | `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` (appended) |
| AI Manager §7: Path Configuration | `docs/architecture/ai_manager/00_architecture_overview.md` (appended) |
| Section 7.5: Terrain Generation & Rendering | `docs/architecture/terrain/generation_and_rendering.md` (new file) |
| Section 8: Economic System Guardrails | `docs/architecture/economy/` — merged into FISCAL_POLICY_AND_FEES.md, MARKET_OPERATIONS.md, CURRENCY_AND_EXCHANGE.md |
| Section 9: Sol as AI Training Data | `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` (appended) |
| Section 10: Player Experience Boundaries | `docs/gameplay/player_experience_boundaries.md` (new file) |
| Section 11: Sci-Fi Easter Eggs | `docs/flavor/sci_fi_easter_eggs.md` (new file) |
| Section 14: Monitor Interface & Layer System | `docs/architecture/systems/monitor_interface_layers.md` (new file) |
| Section 13 (duplicate): Sphere Creation Optimization | `docs/architecture/systems/sphere_creation_optimization.md` (new file) |
| EM Power Transition & Shield Tech | `docs/architecture/systems/em_power_shield_tiers.md` (new file) |
| Resource Allocation Engine Integration | `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` (appended) |

---

## Directory Creation Summary

Directories created during consolidation:
- `docs/architecture/terrain/` — for terrain generation content
- `docs/flavor/` — for flavor/world-building content

---

## Prior Task Files Superseded

All prior GUARDRAILS task files are superseded by this consolidated plan. See the full list at:
`/Users/tam0013/Documents/git/agent-tasks/projects/galaxy_game/tasks/backlog/2026-07-02-HIGH-DOCUMENTATION-GUARDRAILS-CONSOLIDATION.md` (Supersedes section)

---

## Notes for Future Maintenance

- **Economic constants** (SCC Surcharge 0.5%, Broker Fee 0.3%, Sales Tax 3.37%) are verified aligned with `docs/architecture/economy/FISCAL_POLICY_AND_FEES.md` as the canonical source.
- **Formatting debt**: Original file had duplicate section numbering (Section 13 appeared twice, Section 4 missing). Noted but not fixed during this task.
- **Historical notes** (e.g., "Sabatier Bug Fix [2026-01-15]") have been preserved in their target architecture docs as historical context.
