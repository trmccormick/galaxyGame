# AI Manager — Luna Behavior Goals

## Purpose

Define what “good behavior” looks like for the AI Manager on Luna so that, when the simulation starts with a lander arriving and unloading cargo, all major decisions are made by the AI Manager using real game state instead of hardcoded sequences.

This document guides both implementation and test scenarios.

---

## Role on Luna

On Luna, the AI Manager is responsible for:

- Interpreting the initial arrival scenario (lander + cargo manifest).
- Choosing where and how to found the first settlement.
- Planning and executing the buildout of core infrastructure.
- Managing early imports and local production.
- Making decisions that are observable and explainable to a human operator.

The AI Manager should replace any legacy “scripted deployment” with decisions based on the same information those scripts encoded (e.g., initial cargo JSON, intended build order), expressed as data and policies rather than fixed steps [file:164][file:113].

---

## Start-of-Simulation Behavior (Lander + Cargo)

When the Luna simulation starts:

1. **Recognize the arrival event**  
   - Detect that a lander has arrived in lunar orbit or on the surface.
   - Read its cargo manifest (modeled on the original JSON intent: TEU, PVE, power units, hab modules, etc.) [file:113].

2. **Evaluate viable settlement sites**  
   - Use real Luna data (lava tubes, skylights, regolith properties, hazards) to score candidate sites, reusing the `generic_base_build` scoring pattern [file:164].
   - Never use random gating; decisions must be tied to resource and hazard metrics.

3. **Decide: land-and-found vs land-and-transfer**  
   - Either:
     - land and establish the settlement near the chosen site, or
     - land elsewhere and plan a transfer of cargo to the chosen settlement tile.
   - This choice must be logged with a short explanation (e.g., “Chose Marius Hills skylight due to high ISRU score and lower hazard”).

4. **Plan initial deployment from cargo**  
   - Determine which structures to deploy from the initial cargo to reach a minimal working state:
     - power,
     - hab,
     - communications,
     - TEU/PVE chain for ISRU,
     - minimal storage and shielding [file:113][file:164].
   - Express this as a task plan, not a hardcoded script (e.g., a list of `construct_structure`, `deploy_unit`, `connect_units`, `manufacture` effects).

---

## Decision Principles

All AI Manager decisions on Luna must follow these principles:

1. **Data over randomness**  
   - No `rand()` in siting, build order, or production decisions.
   - Every decision must be traceable to underlying data (resources, hazards, inventory, costs, demand) [file:164][file:165].

2. **Real state checks only**  
   - No effect handler may return `true` without verifying real state.
   - If a required model or association does not exist, the handler must fail and log the missing dependency [file:164].

3. **Fail fast, do not fake success**  
   - If a step cannot be executed (missing materials, bad state, invalid target), the run should stop or escalate, not “continue anyway” [file:164].

4. **Single source of truth for sequencing**  
   - The AI Manager uses `TaskExecutionEngineV2` and the `tasks_v2` library; no parallel, hardcoded world-specific sequences are allowed [file:164][file:165].

5. **Explainable decisions**  
   - Major decisions (site choice, first structures, production priorities) should have short human-readable explanations in logs or reports.

---

## Core Behavior Areas

### 1. Settlement Siting

- Evaluate candidate locations on Luna using:
  - resource availability (regolith quality, access to volatiles),
  - hazards (radiation, terrain),
  - ISRU potential,
  - existing features (lava tubes, skylights) [file:164][file:113].
- Produce:
  - a chosen site,
  - a numeric or categorical score,
  - a brief textual justification.

### 2. Initial Buildout

From the initial cargo manifest, the AI Manager should:

- Prioritize a minimal viable base:
  - power → hab → comms → ISRU → storage → shielding.
- Explicitly choose which items to deploy first and why:
  - “Deploy TEU and PVE before extra hab modules to start oxygen and depleted-regolith stockpiles.”
- Create a task plan that can be executed by `TaskExecutionEngineV2` step by step [file:164].

### 3. Production and Inventory

The AI Manager must:

- Track inventory of:
  - regolith,
  - volatiles (oxygen, etc.),
  - depleted regolith,
  - printed structural components [file:164].
- Decide when to:
  - run manufacturing tasks,
  - build new structures,
  - request imports (once those systems are wired in).
- Ensure depleted regolith is treated as a valuable byproduct for shielding, not waste [file:164][file:113].

### 4. Ongoing Simulation Loop

During ongoing simulation:

- Periodically reevaluate:
  - stockpiles,
  - demand (life support, fuel, construction),
  - risks (shortages, overflows).
- Adjust:
  - production schedules,
  - construction plans (e.g., more storage, more power),
  - import requests (future phases).

---

## Observability & Operator Experience

A typical operator run should look like:

- Run a rake task (e.g., `rake ai:luna:settle`).
- See:
  - the siting decision and rationale,
  - the chosen initial build plan,
  - each effect executed with success/failure markers,
  - a final summary of settlement state and inventory [file:164][file:165].
- If something fails, the logs should make it clear:
  - what failed,
  - why it failed,
  - and what dependency is missing.

This replaces the original silent, scripted deployment with a visible, explainable decision loop.

---

## Relationship to Legacy Scripts and JSON

Legacy landing scripts and JSON manifests remain useful as **reference for intent**, not as live control flow:

- JSON manifests define:
  - what the lander carries,
  - what was originally expected to be built first [file:113].
- Scripts describe:
  - a prototype build order,
  - test assumptions about what should exist on Luna at various stages.

The AI Manager should **read equivalent data** (cargo contents, candidate sites, structure definitions) and reproduce the intended behavior by decision, not by copying the script.

Where practical, older JSON and scripts should be:
- folded into structured test scenarios,
- used as acceptance examples for AI Manager behavior.

---

## Out of Scope for Luna Behavior

This document does not cover:

- L1 or LEO depot behavior.
- Station, cycler, or tug operation.
- Wormhole or multi-system logistics.

Those behaviors build on a proven Luna loop and live in later phase planning.
