# Agent Routing Guide & Documentation Index
**Last Updated**: March 31, 2026  
**Purpose**: Route work to the right agent. Check doc index before creating new documentation.

---

## Agent Roster & Routing

### Web Agents — Free, No Request Limits

| Agent | Primary Role | Use For |
|---|---|---|
| **Claude** (claude.ai) | Session Strategist, Planner | Session triage, architecture decisions, task file creation, handoff summaries, game design |
| **Perplexity** (web) | Research + Planning | Issue diagnosis, session planning, RSpec patterns, Ruby metaprogramming, protocol review |
| **Gemini** (web) | Documentation + Game Design | Documentation synthesis, brainstorming mechanics, narrative, gameplay systems |
| **ChatGPT** (web) | Asset Generation | Sprite generation, image assets, visual design |

> Web agents do not touch code or run commands. They create task files and hand off to Copilot agents.
> Gemini web + GPT-4.1 is the preferred documentation pipeline — do not use Gemini Flash for docs.

---

### Copilot Agents — Premium, Watch Request Burn

| Agent | Cost | Capability | Best For | Supervision |
|---|---|---|---|---|
| **GPT-4.1** | 0x | Good, needs guidance | Targeted single-file fixes, commits, file ops, greps | 🔴 Watched carefully |
| **GPT-4o** | 0x | Untested | Try for medium complexity tasks — evaluate before relying on | 🔴 Watched carefully |
| **GPT-5 mini** | 0x | Untested | Try for simple tasks — evaluate before relying on | 🔴 Watched carefully |
| **Raptor mini** | 0x | Untested preview | Do not use until evaluated | 🔴 Watched carefully |
| **Grok Code Fast** | 0.25x | Better than GPT-4.1 | Complex multi-file fixes after GPT-4.1 fails twice | 🟡 Standard |
| **Claude Haiku 4.5** | 0.33x | Fast, limited | Simple reasoning tasks only — prefer free agents | 🟡 Standard |
| **Gemini Flash** | 0.33x | Good autonomy | Avoid — use Gemini web instead | 🟡 Standard |
| **GPT-5.1-Codex-Mini** | 0.33x | Untested | Evaluate before using | 🟡 Standard |
| **GPT-5.4 mini** | 0.33x | Untested | Evaluate before using | 🟡 Standard |
| **Claude Sonnet 4.6** | 1x | Strong reasoning | Complex fixes, architecture recovery, stuck agents | 🟢 Trusted |
| **Claude Sonnet 4/4.5** | 1x | Strong reasoning | Same as above — fallback if 4.6 unavailable | 🟢 Trusted |
| **GPT-5.2** | 1x | Untested | Evaluate before using | 🟡 Standard |
| **GPT-5.1** | 1x | Untested | Evaluate before using | 🟡 Standard |
| **GPT-5.1-Codex** | 1x | Untested | Evaluate before using | 🟡 Standard |
| **GPT-5.2-Codex** | 1x | Untested | Evaluate before using | 🟡 Standard |
| **GPT-5.3-Codex** | 1x | Untested | Evaluate before using | 🟡 Standard |
| **GPT-5.1-Codex-Max** | 1x | Untested | Evaluate before using | 🟡 Standard |
| **Gemini 2.5 Pro** | 1x | Likely strong | Evaluate before using — may replace Sonnet for some tasks | 🟡 Standard |
| **Gemini 3.1 Pro** | 1x | Untested preview | Do not use until evaluated | 🟡 Standard |
| **Claude Opus 4.5** | 3x | Highest capability | Genuine deadlocks only — Sonnet couldn't resolve | 🟢 Trusted |
| **Claude Opus 4.6** | 3x | Highest capability | Genuine deadlocks only — Sonnet couldn't resolve | 🟢 Trusted |

**Supervision Legend**:
- 🔴 Watched carefully = verify every output before accepting
- 🟡 Standard = review outputs, apply judgment
- 🟢 Trusted = can work from lean task file, exercise autonomy

---

### Local Agents — Free Claude Sonnet Alternative

| Agent | Host | Cost | Speed | Capability | Best For |
|---|---|---|---|---|---|
| **qwen3-coder:30b** | Windows 10.6.186.50 | **0x** | 🐌 Slow (CPU+4GB Vulkan) | Claude Sonnet tier | **Replace Claude Sonnet (1x)** — heavy background refactors |
| **qwen2.5-coder:3b** | Windows 10.6.186.50 | **0x** | 🐌 Medium (GPU viable) | GPT-4.1 tier | Overflow when GPT-4.1 busy |
| **Llama3.1:8b** | Mac localhost | **0x** | Medium | Light tasks | Fallback, autocomplete |

**Access**: Continue CLI `cn --config .continueconfig.yaml` → Windows model  
**Docker**: `docker exec web` (no `-t` for CLI)  
**Supervision**: 🟡 Standard — always review results

---

## Routing Decision Guide
```
What kind of work is this?

PLANNING / ARCHITECTURE / TASK CREATION?
  └─ Claude web (free) — stays here, produces task file

DOCUMENTATION / DOC SYNTHESIS?
  └─ Gemini web (free) + GPT-4.1 (free) — preferred pipeline
     Do NOT use Gemini Flash (0.33x) for documentation

RESEARCH / EXTERNAL REFERENCE / ISSUE DIAGNOSIS?
  └─ Perplexity web (free)

GAME DESIGN BRAINSTORMING?
  └─ Gemini web (free) or Claude web (free)

SPRITE / IMAGE GENERATION?
  └─ ChatGPT web (free)

IMPLEMENTATION — how complex is the task?

  Fully specified, single file, clear fix?
    └─ GPT-4.1 (0x) — free, watch carefully
       Task file must be complete — explicit paths, methods, commands

  Same failure after 2 GPT-4.1 attempts?
    └─ Grok Code Fast (0.25x) — better capability, worth the cost
       Task file needs good detail

  Complex root cause, architectural judgment needed?
  Grok failed or unavailable?
    └─ Claude Sonnet (1x) — spend deliberately
       Can work from lean task file

  Hardest problems only, Sonnet couldn't resolve?
    └─ Claude Opus (3x) — last resort only
```

---

## Request Budget Rules

1. **Always start with the cheapest capable agent** — GPT-4.1 first, always
2. **Escalate when stuck** — same failure after 2 attempts = move up one tier
3. **Grok Code Fast is the first escalation** — not Gemini Flash, not Sonnet
4. **Claude Sonnet is the senior agent** — not the default, use for complexity
5. **Never use Opus until Sonnet is genuinely stuck** — 3x cost, last resort
6. **Web agents are free** — Claude, Perplexity, Gemini web have no limit
7. **Gemini web replaces Gemini Flash** — same quality, zero cost
8. **Perplexity replaces research premium spend** — use web version
9. **Full suite runs burn requests** — don't run full suite until targeted specs pass
10. **Never escalate to premium for diagnosis** — Claude web diagnoses, GPT-4.1 executes
11. **Single RSpec Runner**: Never run RSpec in parallel across agents. Only one implementation agent may execute RSpec at a time (container lock).

---

## Task File Depth by Agent

The task file you hand to an agent should match its capability level.
A 0x agent handed a lean task file will burn requests on clarification.
A 1x agent handed an over-specified task file wastes writing time but works fine.

**When in doubt — over-specify. It never hurts.**

| Agent | File Paths | Method Names | Step-by-Step Commands | Architecture Context | Recovery Instructions |
|---|---|---|---|---|---|
| GPT-4.1 (0x) | Exact | Exact + line numbers | Every command explicit | Full summary | Explicit escalation steps |
| GPT-4o (0x) | Exact | Exact + line numbers | Every command explicit | Full summary | Explicit escalation steps |
| Grok Code Fast (0.25x) | Exact | Exact | Most commands explicit | Full summary | Explicit escalation steps |
| Gemini Flash (0.33x) | Exact | Approximate | Key commands | Summary | Standard stop conditions |
| Claude Sonnet (1x) | Approximate | Can infer | Key commands | High level OK | Standard stop conditions |
| Claude Opus (3x) | High level OK | Can infer | Key commands | High level OK | Standard stop conditions |
| Local Ollama | Exact | Exact + line numbers | Every command explicit | Full summary | Explicit escalation steps |

---

## Untested Agents — Evaluation Needed
The following agents are available but have not been evaluated in this workflow.
Do not assign implementation tasks until tested on a low-risk isolated spec fix:
- GPT-4o (0x) — try first, likely capable
- GPT-5 mini (0x) — try for simple tasks
- Grok Code Fast (0.25x) — known capable, better than GPT-4.1 per session history
- GPT-5.1-Codex-Mini (0.33x)
- GPT-5.4 mini (0.33x)
- GPT-5.2, GPT-5.1, GPT-5.1-Codex, GPT-5.2-Codex, GPT-5.3-Codex, GPT-5.1-Codex-Max (1x each)
- Gemini 2.5 Pro, Gemini 3.1 Pro (1x each)
- Raptor mini Preview (0x)

When evaluating a new agent: assign a single well-specified isolated spec fix,
watch carefully, assess output quality before trusting with more complex work.

---

## Documentation Index

> **Check this index before creating any new documentation.**
> If the topic is already covered, add to the existing file.
> If it belongs in a new file, note the gap in your completion report — do not create it during an implementation task.

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
| `architecture/` | Canonical home for all system design docs |
| `architecture/life_support_waste_recycling_architecture.md` | Life support material taxonomy, closed loop flow |
| `architecture/precursor_mission_bootstrap_architecture.md` | Luna bootstrap, ISRU loop, Sol as AI training |

### `/docs/ai_manager` — AI Systems
| Path | Purpose |
|---|---|
| `ai_manager/` | AI manager design, strategy trees, evaluator logic |

### `/docs/developer` — Development Reference
| Path | Purpose |
|---|---|
| `developer/` | Setup guides, coding patterns, service references |

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
2. **Never create docs at `/docs` root** — they become orphans
3. **Never create docs during implementation tasks** — flag the gap, create separately
4. **One doc per system** — consolidate duplicates
5. **Link to GitHub wiki** — all docs are eventually wiki candidates
6. **Name clearly** — `[system]_[topic].md`

---

## Cleanup Backlog
- [ ] Archive or delete `GUARDRAILS.md.old`, `.old2`, `.old3.md`, `.old4.md`
- [ ] Move root orphans to correct subdirectories (5 files)
- [ ] Create index files for undocumented subdirectories
- [ ] Audit `docs/developer/` for duplicates
- [ ] Audit `docs/architecture/` for overlapping content
- [ ] Establish GitHub wiki sync process