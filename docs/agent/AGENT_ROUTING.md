# Agent Routing Guide & Documentation Index
**Last Updated**: March 22, 2026  
**Purpose**: Route work to the right agent. Check doc index before creating new documentation.

---

## Agent Roster & Routing

### Web Agents — Free, No Request Limits

| Agent | Primary Role | Use For |
|---|---|---|
| **Claude** (claude.ai) | Session Strategist, Planner | Session triage, architecture decisions, task file creation, handoff summaries |
| **Perplexity** | Research | Looking up current libraries, external references, unfamiliar APIs |
| **Gemini** (web) | Game Design | Brainstorming mechanics, narrative, gameplay systems |
| **ChatGPT** (web) | Asset Generation | Sprite generation, image assets, visual design |

> Web agents do not touch code or run commands. They create task files and hand off to Copilot agents.

---

### Copilot Agents — Premium, Watch Request Burn

| Agent | Cost | Capability | Best For | Supervision |
|---|---|---|---|---|
| **GPT-4.1** | 0x | Good, needs guidance | Targeted single-file fixes with fully specified tasks | Watched carefully |
| **Grok** | 0.25x | Solid, reliable | Light implementation, well-defined tasks | Standard |
| **Gemini Flash** | 0.33x | Good autonomy | Multi-step implementation, reasonable inference | Standard |
| **Claude Sonnet 4.6** | 1x | Strong reasoning | Complex fixes, architecture, recovery from stuck agents | Trusted |
| **Claude Opus 4.6** | 3x | Highest capability | Untested in this workflow — reserve, do not use yet | TBD |

---

### Local Agents — Free, Setup In Progress

| Agent | Status | Notes |
|---|---|---|
| **Ollama** (local) | Available, not standardized | Tested. Use for free grinding once workflow is validated |
| **Qwen 32B** | Available on Windows/Intel | Best code quality for local |
| **Qwen 14B** | Available on M5 | Best speed/quality balance |

> Ollama onboarding is a pending backlog task. Until standardized, treat as experimental.

---

## Routing Decision Guide

```
What kind of work is this?

PLANNING / ARCHITECTURE / TASK CREATION?
  └─ Claude web (free, no limit) — stays here, produces task file

RESEARCH / EXTERNAL REFERENCE?
  └─ Perplexity web (free)

GAME DESIGN BRAINSTORMING?
  └─ Gemini web (free)

SPRITE / IMAGE GENERATION?
  └─ ChatGPT web (free)

IMPLEMENTATION — how complex is the task?

  Fully specified, single file, clear fix?
    └─ GPT-4.1 (0x) — free, but watch carefully
       Task file must be complete — explicit paths, methods, commands

  Well-defined, 1-3 files, some inference needed?
    └─ Grok (0.25x) — cost-effective, reliable
       Task file needs good detail

  Multi-step, requires some reasoning?
    └─ Gemini Flash (0.33x) — good autonomy, reasonable cost
       Task file can be leaner

  Complex root cause, architectural judgment needed?
  Previous agent got stuck after 2 attempts?
    └─ Claude Sonnet (1x) — spend deliberately
       Can work from lean task file

  Hardest problems only, Sonnet couldn't resolve?
    └─ Claude Opus (3x) — untested, last resort
```

---

## Request Budget Rules

1. **Always start with the cheapest capable agent** — if GPT-4.1 can do it with a well-specified task, use it
2. **Escalate when stuck** — same failure after 2 attempts = move up one tier, not retry same agent
3. **Claude Sonnet is the senior agent** — not the default. Use for complexity, not convenience
4. **Never use Opus until Sonnet is genuinely stuck** — it's untested in this workflow and 3x cost
5. **Web Claude is free** — use it for all planning, triage, and task creation without hesitation
6. **Full suite runs burn requests** — don't ask Copilot agents to run the full suite until targeted specs pass

---

## Task File Depth by Agent

The task file you hand to an agent should match its capability level.
A 0x agent handed a lean task file will burn requests on clarification.
A 1x agent handed an over-specified task file wastes your writing time but works fine.

**When in doubt — over-specify. It never hurts.**

| Agent | File Paths | Method Names | Step-by-Step Commands | Architecture Context | Recovery Instructions |
|---|---|---|---|---|---|
| GPT-4.1 (0x) | Exact | Exact + line numbers | Every command explicit | Full summary | Explicit escalation steps |
| Grok (0.25x) | Exact | Exact | Most commands explicit | Full summary | Explicit escalation steps |
| Gemini Flash (0.33x) | Exact | Approximate | Key commands | Summary | Standard stop conditions |
| Claude Sonnet (1x) | Approximate | Can infer | Key commands | High level OK | Standard stop conditions |
| Local Ollama | Exact | Exact + line numbers | Every command explicit | Full summary | Explicit escalation steps |

---

## Documentation Index

> **Check this index before creating any new documentation.**
> If the topic is already covered, add to the existing file.
> If it belongs in a new file, note the gap in your completion report — do not create it during an implementation task.
> All docs should eventually link to the GitHub wiki.

### `/docs` Root — Project-Wide
| File | Purpose | Status |
|---|---|---|
| `README.md` | Agent workflow overview, directory map | Active |
| `GUARDRAILS.md` | Architectural integrity rules, prohibited actions | Active — use this version |
| `GUARDRAILS.md.old*` | Superseded versions | Cleanup needed — do not read |
| `CURRENT_STATUS.md` | Real-time project status, current failure count | Update after every session |
| `GLOSSARY_SYSTEM_MECHANICS.md` | Game mechanics terminology | Active |
| `MIGRATION_GUIDE.md` | Database migration patterns | Active |
| `PRACTICAL_TESTING_GUIDE.md` | Testing quick reference | Active |
| `escalation_data_flow.md` | Escalation system data flow | Orphan — needs move to `ai_manager/` |
| `luna_ai_manager_visualization.md` | Luna AI manager viz | Orphan — needs move to `ai_manager/` |
| `orbital_settlement_strategies.md` | Orbital settlement design | Orphan — needs move to `architecture/` |
| `star_naming_architecture.md` | Star naming conventions | Orphan — needs move to `architecture/` |
| `ADMIN_DASHBOARD_REDESIGN.md` | Admin UI redesign spec | Orphan — needs move to `developer/` |

### `/docs/agent` — Agent Operations
| Path | Purpose |
|---|---|
| `agent/README.md` | Implementation agent operating guide |
| `agent/WORKFLOW_README.md` | Planner agent role |
| `agent/SESSION_STRATEGIST.md` | Session triage role |
| `agent/TASK_TEMPLATE.md` | Canonical task file template |
| `agent/AGENT_ROUTING.md` | This file |
| `agent/tasks/backlog/` | Queued tasks (~176 files) |
| `agent/tasks/active/` | Currently assigned tasks |
| `agent/tasks/critical/` | High priority, start here |
| `agent/tasks/completed/` | Finished tasks, reference only |
| `agent/rules/TASK_PROTOCOL.md` | Task execution standards |
| `agent/rules/ENVIRONMENT_BOUNDARIES.md` | Command safety rules |
| `agent/planning/RESTORATION_AND_ENHANCEMENT_PLAN.md` | 6-phase roadmap |

### `/docs/architecture` — System Design
| Path | Purpose |
|---|---|
| `architecture/` | 40 files — canonical home for all system design docs |
| `architecture/life_support_waste_recycling_architecture.md` | Life support material taxonomy, closed loop flow |
| `architecture/precursor_mission_bootstrap_architecture.md` | Luna bootstrap, ISRU loop, Sol as AI training |

> Architecture decisions live here. Before making a structural change to any
> game system, check this directory for an existing doc on that system.

### `/docs/ai_manager` — AI Systems
| Path | Purpose |
|---|---|
| `ai_manager/` | AI manager design, strategy trees, evaluator logic |

### `/docs/developer` — Development Reference
| Path | Purpose |
|---|---|
| `developer/` | 50 files — setup guides, coding patterns, service references |

### `/docs/systems` — Game Systems
| Path | Purpose |
|---|---|
| `systems/` | Individual game system documentation |

### `/docs/storyline` — Narrative
| Path | Purpose |
|---|---|
| `storyline/` | Game narrative, lore, faction design |

### `/docs/legacy` — Historical Reference
| Path | Purpose |
|---|---|
| `legacy/` | Old code kept for reference — do not modify |
| `legacy/[pascal file]` | Undergraduate pathfinding implementation — reference for wormhole pathfinding task |

### Directories Needing Index
The following directories have files but no index doc yet. Do not create one
during implementation tasks — flag the gap:
- `docs/crafts/`
- `docs/economics/`
- `docs/market/`
- `docs/reference/`
- `docs/testing/`
- `docs/gameplay/`
- `docs/mission_profiles/`
- `docs/wormhole_expansion/`

---

## Doc Creation Rules

1. **Check this index first** — if the topic is covered, add to the existing file
2. **Never create docs at `/docs` root** — they become orphans. Use the correct subdirectory
3. **Never create docs during implementation tasks** — flag the gap, create in a separate task
4. **One doc per system** — if a second doc for the same system exists, consolidate
5. **Link to GitHub wiki** — all docs are eventually wiki candidates, write accordingly
6. **Name clearly** — `[system]_[topic].md` e.g. `terraforming_gas_calculations.md`

---

## Cleanup Backlog
These are known doc issues that need a dedicated cleanup task:

- [ ] Archive or delete `GUARDRAILS.md.old`, `.old2`, `.old3.md`, `.old4.md`
- [ ] Move root orphans to correct subdirectories (5 files)
- [ ] Create index files for undocumented subdirectories
- [ ] Audit `docs/developer/` (50 files) for duplicates
- [ ] Audit `docs/architecture/` (40 files) for overlapping content
- [ ] Establish GitHub wiki sync process
