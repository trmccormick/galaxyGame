# AI Manager / economy — agent reading order

**Status:** Navigation aid (2026-10-19)  
**Purpose:** Tell coding agents which docs win when older "locked" plans conflict.

## Read first (current intent)

1. `docs/gameplay/sol_core_buildup.md` — Luna→shipyard→core loop→Mars hub; player entry; tutorial; snapshots; UI/mock intent (§5.3–5.4); EM is later
2. `docs/architecture/ai_manager/AI_MANAGER_ROLE.md` — player-first markets; AI Manager keeps running
3. `docs/gameplay/terraforming.md` — terraforming is later background demand (sections above the reading note)
4. `docs/architecture/ai_manager/astrolift_corporation.md` — logistics NPC; Phase 1 before shipyard-scale cyclers
5. `docs/architecture/ai_manager/FOOTHOLD_PLANNER_ARCHITECTURE.md` — DC footholds open worlds
6. `docs/architecture/ai_manager/NPC_INITIAL_DEPLOYMENT_SEQUENCE.md` — pre-player NPC-only markets / tuning

**UI / mock prototypes:** Even with MockDataHelper or non-DB fixtures, prefer the Read-first list (especially `sol_core_buildup.md` §5.3–5.4) so player shells match DC foothold tutorial intent and do not treat post-Snap wormhole/admin UIs as the default first login unless the mock snapshot is explicitly that phase.

## Storyline (intent, thresholds in flux)

- `docs/storyline/02_crisis_mechanics.md` — Snap pre-player; reconnection window
- `docs/storyline/05_physics_topology.md` — AWS/mass/EM; not early Sol priority

## Biology / planetary (narrow)

- `docs/architecture/biology/TERRAFORMING_SEED_AND_LIFE_DIRECTION.md`
- `docs/architecture/terrasim/OVERVIEW.md` (Digital Twin note)

## Historical / surgical (do not override the list above)

Examples: `AI_MANAGER_MASTER_PLAN.md`, `AI_MANAGER_COMMAND.md`, `AI_MANAGER_WORMHOLE_EXPANSION.md`, `PLAYER_HANDOFF.md`, `AI_MANAGER_PRICING_INTENT.md`, `AI_MANAGER_ORCHESTRATOR_SPEC.md`, many `89→8_*` and "FINAL/LOCKED" notes. Use for refactor archaeology; prefer the Read-first list for behavior.

## Rule of thumb

If a doc says early terraforming fleet priority, player takes AWS control on login, or Earth↔Venus cyclers before the shipyard, **ignore that ordering** and follow `sol_core_buildup.md`.
