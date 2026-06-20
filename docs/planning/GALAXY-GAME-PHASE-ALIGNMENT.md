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

Source: `research/LUNA-MVP-SIMULATION-DESIGN.md` and Claude’s audit handoff [file:165].

These phases describe the game’s expansion arc:

- 5+: Luna loop (settlement + production)  
- 6+: Station building, depot establishment  
- 7+: Shipyard, orbital craft construction  
- 8+: Phobos/Deimos hollowing, station fit-out  
- 9+: Cycler bulk material loops  
- 10+: Limited terraforming testing  
- 11+: Natural wormhole, Sol expansion [file:165]

Use System B to answer: **“When in the story should this feature exist?”**

---

## How Phase Folders Map to Systems

Task folders in `agent-tasks` should be interpreted as:

- `backlog/2026-06/`  
  - System A: ongoing Luna AI Manager mechanics and cleanup.  
  - Use for: near-term fixes and refactors that support the existing Luna queue.

- `backlog/phase5+/`  
  - System B: **Luna loop and manufacturing foundation**.  
  - Use for: tasks that make Luna a working settlement and production base (simulation tuning, siting logic, local manufacturing, etc.) [file:165].

- `backlog/phase6+/`  
  - System B: L1 and LEO depots, early stations.  
  - Use for: depot staging, basic station infrastructure that depends on a working Luna loop [file:165].

- `backlog/phase9+/`  
  - System B: late-game expansion (cyclers as bulk loops, wormholes, multi-system work).  
  - Use for: features that require shipyards and mature infrastructure to exist first [file:165].

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
   - Luna-only, foundational simulation or manufacturing → `phase5+/`.
   - Needs L1/LEO depots or early stations → `phase6+/`.
   - Needs shipyards, cyclers as bulk loops, or multi-system features → `phase9+/` [file:165].

3. **Respect the current focus**  
   - If the work doesn’t support Luna simulation or cleanup in the near term, keep it out of the active Luna backlog and into the appropriate future phase.

---

## How to Use This Page

- Backlog triage sessions should reference this document before moving tasks.
- New planning docs and SOPs should link here when they talk about “Phase 5+” or “Phase 6+”.
- If older docs use conflicting phase numbers, interpret them through System B and update the task placement accordingly [file:165].