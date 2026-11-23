# AI Manager

This directory contains the application services for GalaxyGame's AI Manager: the autonomous economy, settlement-development, and logistics governor. This README is an orientation and working guide for the module. The canonical design and implementation record remains the [AI Manager wiki](../../../../docs/wiki/services/ai_manager.md).

## Purpose

The AI Manager reads the current game state and decides what work is needed to establish, operate, and develop footholds, settlements, and stations. It should make objective-led decisions from actual conditions rather than replaying a fixed deployment script.

Its strategic responsibility is to decide:

- whether an activity is needed;
- where and when it should happen;
- why it takes priority over competing needs;
- what resources, equipment, cargo, and supporting work are required; and
- how to adapt when conditions, resources, finances, or dependencies change.

The AI Manager coordinates existing game capabilities. It does not own star-system generation or initial terrain generation: StarSim and Map Studio provide world data that the AI Manager consumes.

## Important architectural distinction

**Strategic selection and activity execution are separate responsibilities.**

- The AI Manager evaluates objectives, world state, constraints, priorities, and available options. It composes plans and decides which activities to request.
- Mission profiles, task definitions, and execution services describe reusable activities and how selected work is carried out.
- Rake scenarios are development and validation instruments. They provide tested examples and operational evidence; they must not become permanent scripts that the AI Manager simply replays.

The presence of a planner, scorer, task library, or executor does not by itself demonstrate that the AI Manager can independently select an effective strategy. That behavior must be validated against real simulation state and observable outcomes.

## Current development focus: the integrated Luna benchmark

The immediate development and validation target is a sustainable Luna operation, not merely a completed initial build. The benchmark connects:

- settlement construction and ongoing management;
- Earth-side procurement and resupply, including delivery timing, capacity, and available funds;
- Venus atmospheric gas harvesting and processing;
- fuel production, storage, and transport loops;
- crew survival and the life-support dependencies that support it; and
- financial sustainability, including USD income, cash, expenses, and purchasing commitments.

The Rake-driven operation is a reference baseline. The AI Manager must ultimately plan and manage the operation independently, without invoking or relying on the Rake scripts, and respond to changed conditions and failures. The Rake is evidence and a test instrument—not the AI Manager's operating brain.

The current wiki also records important maturity boundaries: the V2 mission/task work is a developing execution foundation, and V2 has not yet been integrated into AI training. Defined task data must not be described as validated execution or completed learning integration.

## Scope and boundaries

- **Own:** high-level settlement objectives, strategic selection, prioritization, planning, coordination, and oversight of work performed by game services.
- **Coordinate:** resource needs, procurement, production, logistics, construction, maintenance, survival, and financial constraints as connected operational concerns.
- **Consume:** world, terrain, resource, market, transport, and simulation state supplied by their owning systems.
- **Do not absorb:** StarSim generation, Map Studio terrain generation, or the implementation details of every domain service the AI Manager coordinates.
- **Do not duplicate:** per-settlement acquisition, market, or transport mechanisms when a coordination layer can use their established interfaces.
- **Keep future network-scale work distinct:** cross-settlement and cross-system resource optimization builds on reliable local operations, acquisition, and transport-cost/connectivity inputs. It is not a substitute for those foundations.

## Operator visibility

The AI Manager needs an operator-facing environment that makes its work inspectable and understandable. The operator should be able to review objectives, current activity, decisions and their rationale, resource and financial state, completed and pending work, failures, and recovery actions. Pre-player simulation should support observation, pause, intervention, and resume while still processing the full consequences of elapsed simulation time.

The interface is a way to observe and supervise the AI Manager; it is not a substitute for the decision-making and execution architecture.

## Continuing work on this module

Before adding more backend behavior, review the module as a whole and establish an evidence-based map of its responsibilities and current implementation.

1. **Inventory the implementation.** Identify the services, jobs, entry points, dependencies, call paths, tests, and relevant data/configuration. Verify the current code rather than relying on filenames or older task descriptions.
2. **Map responsibilities and ownership.** Show how strategic selection, planning, task execution, resource acquisition, logistics, markets, construction, and settlement operations fit together. Identify overlaps and unclear boundaries.
3. **Compare implementation with established intent.** Use the canonical wiki and linked design decisions. Distinguish verified behavior, partial implementation, target intent, stale documentation, and unresolved questions.
4. **Review operator/UI needs alongside backend responsibilities.** Identify what the operator must be able to see, understand, configure, and intervene in; do not assume a screen implies a working backend capability.
5. **Agree on the architecture and priorities.** Use the Luna benchmark to identify the essential capabilities and dependencies. Keep later multi-settlement/network capabilities visible without pulling them prematurely into the immediate work.
6. **Only then create bounded implementation tasks.** Each task should have a clear responsibility, known interfaces and files where possible, measurable behavior, focused tests, and explicit dependencies. Do not start implementation merely because an older backlog task names a proposed class or API.

This review is planning and architecture work. It does not authorize a backend rewrite or implementation changes by itself.

## Primary references

- [Canonical AI Manager wiki](../../../../docs/wiki/services/ai_manager.md) — current intent, code-alignment notes, Luna benchmark, mission/task boundaries, and known gaps.
- [Luna behavior goals](../../../../docs/planning/AI-MANAGER%E2%80%94-LUNA-BEHAVIOR-GOALS.md) — intended Luna decision behavior and operator observability; planning guidance, not proof of implementation.
- [Multi-System Resource Coordination task](../../../../docs/../agent-tasks/projects/galaxyGame/tasks/backlog/ai-manager/2026-06-07-MEDIUM-FEATURE-MULTI-SYSTEM-RESOURCE-COORDINATION.md) — historical statement of later network-scale coordination intent. This task is deferred and must be reassessed against the current architecture before it is revived.

When these references conflict, do not silently choose one: record the conflict, verify code for implementation claims, and use the current owner-confirmed wiki for design intent.
