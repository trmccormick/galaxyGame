# Galaxy Game Phase Alignment & Task Placement

## Purpose

This document explains how to map work into the correct phases and task folders by unifying two existing phase systems:

- **System A — Service Integration Phases** (what’s live now) [status.md][file:109]
- **System B — World/Settlement Expansion Phases** (game progression) [session_handoff_2026-06-16][file:165]

Planning, triage, and new tasks should always reference this alignment.

---

## System A: AI Manager Service Integration (What Exists Today)

Source: `docs/new_agent/projects/galaxy_game/status.md` — “Luna Phase Queue” [file:109].

These phases describe which AI Manager services are integrated and tested:

- Phase 1: `Settlements::CostAnalyzer` → AI Manager (complete)
- Phase 2: `Logistics::ManifestGenerator` → AI Manager (complete)
- Phase 3: `Logistics::ShortageDetector` + `ImportRequestGenerator` → AI Manager (complete)
- Phase 4: Consumption-aware ordering + precursor phase awareness (complete)
- Phase 5: Wormhole topology integration for expansion (backlog) [file:109]

Use System A to answer: **“Is the service live and tested?”**

---

## System B: World/Settlement Expansion (Game Progression)
**Critical Context**: Phases 5–13 constitute the AI Manager **training and infrastructure code testing** layer. These phases are not "true gameplay" or permanent in-world buildup. Instead, they establish:
1. Infrastructure patterns and logistics chains the AI Manager learns to replicate
2. Code validation for settlement expansion, material flow, terraforming, and multi-world operations
3. Learned pattern data that enables the AI Manager to independently manage Luna settlement and core-loop expansion

**Wormhole Trigger**: Once the AI Manager independently and consistently manages Luna settlement and Earth-Mars-Venus-Psyche core-loop operations, a game trigger spawns the **natural wormhole**. This triggers the true multi-system expansion phase and wormhole-era gameplay.
Source: `research/LUNA-MVP-SIMULATION-DESIGN.md` and Claude’s audit handoff [file:165].

These phases describe the game’s expansion arc:

- 5+: Luna simulation loop calibration and blockers to a runnable settlement loop; AI Manager begins pattern recognition
- 6+: Luna worldhouse/lavatube buildout, ISRU calibration, Earth import management; AI Manager learns settlement and supply patterns
- 7+: L1 Depot and LEO Depot construction, price-reduction logistics loops; AI Manager learns multi-depot coordination
- 8+: L1 station growth, shipyards, tug and cycler construction; AI Manager learns orbital manufacturing chains
- 9+: Phobos/Deimos repositioning, hollowing, initial station fit-out, first cycler return/resupply loop; AI Manager learns asteroid terraforming
- 10+: Venus repeat of the Mars foothold pattern, with parallel second cycler-tug construction at Earth/L1; AI Manager validates repeatable patterns
- 11+: Normal cycler loop between Earth, Mars, and Venus with heavy logistics testing; AI Manager learns multi-world cargo transfer
- 12+: Optional split for parallel branch expansion: Mars→Ceres belt mining work and Mars→Titan/Saturn settlement work; AI Manager learns branch logistics
- 13+: Psyche asteroid mining (planetary core remnant) and parallel Mars terraforming initiation with Venus/Titan gas exports; AI Manager learns advanced multi-system operations
- 14+: AI Manager operational independence test: Sol day-to-day management and initial Eden system expansion attempt using learned Sol patterns
- 15+: Unplanned Eden expansion driven by AI Manager discovering better terraforming targets; AI Manager learns natural wormhole mass limits through operations, leading to crisis discovery

**Crisis Trigger (Post-Phase 15)**: The natural wormhole reaches mass-instability limits as Eden infrastructure accumulates. The Snap event occurs, shifting the exit point and orphaning the Eden colony. This forces the formation of the Wormhole Transit Consortium (WTC) and initiates Act 2 crisis gameplay.
Use System B to answer: **“When in the story should this feature exist?”**

---

## How Phase Folders Map to Systems

Task folders in `agent-tasks` should be interpreted as:

- `backlog/2026-06/`  
  - System A: ongoing Luna AI Manager mechanics and cleanup.  
  - Use for: near-term fixes and refactors that support the existing Luna queue.

- `backlog/phase5+/`  
  - System B: **Luna simulation loop calibration**.  
  - Use for: tasks that block the Luna simulation from running or prevent fuel-loop calibration and observation-driven tuning.

- `backlog/phase6+/`  
  - System B: Luna worldhouse buildout and settlement operations.  
  - Use for: lavatube/worldhouse construction, live ISRU calibration, and Earth import management that depend on a working Luna loop.

- `backlog/phase7+/`
  - System B: L1 and LEO depots.
  - Use for: depot staging, LOX and methane logistics, and early orbital infrastructure that reduce Earth-delivered prices.

- `backlog/phase8+/`
  - System B: L1 station growth and shipyards.
  - Use for: tug/cycler construction and hybrid Luna-plus-Earth orbital manufacturing.

- `backlog/phase9+/`
  - System B: Mars foothold expansion.
  - Use for: Phobos/Deimos repositioning, hollowing, station fit-out, and the first cycler-tug return/resupply loop.

- `backlog/phase10+/`
  - System B: Venus foothold expansion.
  - Use for: repeating the Mars asteroid-moving/station-building pattern at Venus, including the parallel second cycler-tug pair under construction at Earth/L1.

- `backlog/phase11+/`
  - System B: mature inner-system cycler logistics.
  - Use for: normal Earth→Mars→Venus cycler loops, docking and undocking tests, cargo transfer validation, and operational heavy-logistics tuning.

- `backlog/phase12+/`
  - System B: optional split for branch expansion beyond the main Earth-Mars-Venus loop.
  - Use for: Mars→Ceres belt mining work and Mars→Titan/Saturn settlement work if those branches need to be separated from Phase 11 parallel operations.

- `backlog/phase13+/`
  - System B: Psyche asteroid mining (planetary core remnant) and parallel Mars terraforming initiation.
  - Use for: Psyche asteroid mining, relocation, and industrial refining of high-value metals from a planetary core remnant, OR limited Mars atmospheric buildup work using Venus/Titan gas exports and initial terraforming logistics setup.

- `backlog/phase14+/`
  - System B: AI Manager operational independence test with Sol management and initial Eden expansion.
  - Use for: Sol day-to-day settlement/logistics operations under full AI Manager control, initial natural wormhole discovery and exploration, early Eden settlement attempts using Sol resource allocation patterns.

- `backlog/phase15+/`
  - System B: Unplanned Eden expansion and natural wormhole mass-limit discovery.
  - Use for: Eden infrastructure buildup driven by AI Manager resource redirection, unplanned expansion due to superior terraforming targets, discovery of natural wormhole mass limits through operational stress, crisis event preparation.

**Rule of thumb:**  
Use **System A** to see if a service is ready to use.  
Use **System B** to decide which phase folder a new task belongs in.

---

## Current Planning Focus

Right now, planning and implementation focus on:

- **Luna as the foundation**: settlement, regolith processing, volatiles, depleted-regolith shielding, and printed components.
- **Refactor and simulation tuning**: nearly 4,000 specs pass; remaining work is about simulation behavior and AI Manager decision quality, not bulk new features [file:109].
- **A living Luna loop for players**: the priority is a believable Luna simulation, not early buildout of later phases.

Any new task should first answer:  
**“Does this help Luna behave like a living, testable simulation now?”**  
If no, it likely belongs in a later phase folder.

---

## Task Placement Rules (Practical)

When creating or triaging a task:

1. **Check System A (status.md)**  
   - If it depends on a service that isn’t integrated yet, note the dependency explicitly [file:109].

2. **Classify with System B**  
  - Blocks the Luna simulation from running or calibrating → `phase5+/`.
  - Enables Luna settlement buildout, live ISRU, or Earth import management → `phase6+/`.
  - Enables L1/LEO depots and orbital price-reduction loops → `phase7+/`.
  - Enables L1 shipyards, tugs, cyclers, or functional L1 station growth → `phase8+/`.
  - Enables Phobos/Deimos repositioning, hollowing, or first-loop resupply → `phase9+/`.
  - Enables the Venus repeat pattern or second cycler-tug parallel construction → `phase10+/` [file:165].
  - Enables normal Earth→Mars→Venus cycler logistics, docking, undocking, or cargo transfer validation → `phase11+/`.
  - Enables Mars→Ceres belt mining or Mars→Titan/Saturn branch expansion when split from the main logistics phase → `phase12+/`.   - Enables Psyche asteroid mining, relocation, or industrial refining from a planetary core remnant → `phase13+/`.
   - Enables limited Mars terraforming initiation using Venus/Titan gas exports → `phase13+/`.
   - Enables full AI Manager operational independence with Sol management and initial Eden expansion → `phase14+/`.
   - Enables unplanned Eden expansion and natural wormhole mass-limit discovery → `phase15+/`.
3. **Respect the current focus**  
   - If the work doesn’t support Luna simulation or cleanup in the near term, keep it out of the active Luna backlog and into the appropriate future phase.

---

## How to Use This Page

- Backlog triage sessions should reference this document before moving tasks.
- New planning docs and SOPs should link here when they talk about “Phase 5+” or “Phase 6+”.
- If older docs use conflicting phase numbers, interpret them through System B and update the task placement accordingly [file:165].