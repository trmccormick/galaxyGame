---
status: overview
type: task-breakdown
created: 2026-05-18
---

# Resource Spawning System: Task Breakdown & Dependency Map

This document organizes the monolithic "AI Manager Resource Spawning System" task into actionable subtasks for design investigation and phased implementation.

---

## Task Breakdown Summary

Original task was 80 lines with no acceptance criteria or implementation steps. Broken into **6 focused tasks**:

| Task | Status | Type | Required Before Implementation |
|------|--------|------|------------------------------|
| [1] Resource Deposit Model Design | DESIGN NEEDED | Design | Next: Model design approval |
| [2] Deposit Plausibility Engine Design | DESIGN NEEDED | Design | Next: Deposit type rules |
| [3] Trigger System & Equipment Gating Design | DESIGN NEEDED | Design | Next: Trigger event definitions |
| [4] Create ResourceDeposit Model | READY (awaiting design) | Implementation | Design approval + parallel work |
| [5] Create DepositSpawner Service | BLOCKED (waiting design) | Implementation | Tasks 2 & 3 design approval |
| [6] Integrate Spawning with Game Events | BLOCKED (waiting impl) | Implementation | Task 5 completion |

---

## What Needs Design Investigation

These tasks require **you + Gemini + local agent** to flesh out before implementation:

### [1] Resource Deposit Model Design
**Questions to Answer**:
- What attributes define a deposit? (location format? depth range?)
- Should deposits be polymorphic (body vs settlement vs region)?
- How do we represent location on spherical bodies? (lat/long vs hex grid vs feature_id?)
- How do we track depletion over time?

**Lead**: You (game design intent) + Local Agent (Rails patterns)

---

### [2] Deposit Plausibility Engine Design  
**Questions to Answer**:
- What are the exact plausibility rules for 8+ deposit types?
- How does `stored_volatiles` → deposit count mapping work?
- How do we constrain spawning to respect scientific data?
- How do we handle generated worlds with no real scientific data?

**Lead**: Gemini (geological domain expertise) + You (game balance)

---

### [3] Trigger System & Equipment Gating Design
**Questions to Answer**:
- Which trigger events are MVP? (survey? settlement? mission? first-visit?)
- What does equipment tier 0/1/2/3 equipment access?
- When should deposits be visible vs hidden?
- How do we integrate with existing equipment/crafts/settlements?

**Lead**: You (game design) + Gemini (equipment progression balance)

---

## What Can Be Implemented (Once Design Approved)

These tasks are concrete and can proceed after design approval:

### [4] Create ResourceDeposit Model
**Prerequisite**: Design approval for model structure  
**Can start**: Immediately after [1] design approved  
**Duration**: ~2 hours (GPT-4.1)  
**Outputs**: Migration, Model, Factory, Specs

### [5] Create DepositSpawner Service  
**Prerequisites**: [2] Plausibility Engine design approved + [3] Trigger System design approved  
**Can start**: After [2] & [3] approved + [4] completed  
**Duration**: ~4 hours (GPT-4.1)  
**Outputs**: SpawnerService, PlausibilityEngine, Specs

### [6] Integrate Spawning with Game Events
**Prerequisites**: [5] completed + working DepositSpawner  
**Can start**: After [5] completed  
**Duration**: ~3 hours (GPT-4.1)  
**Outputs**: TriggerDispatcher, Hooks, Integration Specs

---

## Dependency Graph

```
DESIGN PHASE (This Week)
├─ [1] Resource Deposit Model Design
│  ├─ Input: You (game design), Local Agent (Rails)
│  └─ Output: Model schema, relationships
│
├─ [2] Deposit Plausibility Engine Design
│  ├─ Input: Gemini (geology), You (balance)
│  └─ Output: Plausibility rules, tier system
│
└─ [3] Trigger System & Equipment Gating Design
   ├─ Input: You (UX flow), Gemini (progression)
   └─ Output: Trigger events, equipment tiers, visibility rules

IMPLEMENTATION PHASE (After Design Approvals)
├─ [4] Create ResourceDeposit Model
│  ├─ Depends: [1] design approved
│  ├─ Assignee: GPT-4.1
│  └─ Duration: ~2 hours
│
├─ [5] Create DepositSpawner Service
│  ├─ Depends: [2] & [3] design approved + [4] completed
│  ├─ Assignee: GPT-4.1
│  └─ Duration: ~4 hours
│
└─ [6] Integrate Spawning with Game Events
   ├─ Depends: [5] completed
   ├─ Assignee: GPT-4.1
   └─ Duration: ~3 hours
   
TOTAL IMPLEMENTATION TIME: ~9 hours (after design approval)
```

---

## What's NOT in These Tasks

These are handled by other systems:
- ❌ ResourcePositioningService (map-based spawning) — left as-is, used by [5]
- ❌ PrecursorCapabilityService — not modified
- ❌ Survey mission mechanics — out of scope
- ❌ Equipment/craft progression system — assumed to exist

---

## Next Steps

1. **This Week**: Review design tasks with Gemini + Local Agent
   - Discuss [1]: Resource Deposit Model structure
   - Discuss [2]: Plausibility rules and constraints
   - Discuss [3]: Trigger events and equipment progression

2. **Week 2**: Implementation begins (once designs approved)
   - GPT-4.1 creates [4] ResourceDeposit Model
   - Parallel: GPT-4.1 creates [5] DepositSpawner (if [2] & [3] approved)
   - GPT-4.1 creates [6] Integration after [5] works

3. **Week 3**: System testing + end-to-end validation

---

## Files Created

All new task files are in: `docs/new_agent/tasks/backlog/2026-05/`

- `2026-05-18-DESIGN-Resource-Deposit-Model-And-Persistence.md`
- `2026-05-18-DESIGN-Deposit-Plausibility-Engine.md`
- `2026-05-18-DESIGN-Deposit-Trigger-System-And-Equipment-Gating.md`
- `2026-05-18-IMPL-Create-ResourceDeposit-Model.md`
- `2026-05-18-IMPL-Create-DepositSpawner-Service.md`
- `2026-05-18-IMPL-Integrate-Spawning-With-Game-Events.md`
- `2026-05-18-OVERVIEW-Resource-Spawning-Task-Breakdown.md` (this file)

---

## Original Task Status

**Original file**: `docs/agent/tasks/backlog/2026-05-01-MEDIUM-ARCHITECTURE-AI-MANAGER-RESOURCE-SPAWNING-SYSTEM.md`

**Action**: Leave as-is (reference only) — superseded by breakdown above

