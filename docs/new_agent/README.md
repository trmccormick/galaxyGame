
**Claude (web) usage:** Only use Claude for occasional high-level review or planning prompts. Do not use Claude as a primary session planner or for triage. Gemini is the main session planner.
# Galaxy Game — Agent Workspace
**Version**: 2.1 (Local-First Architecture)
**Last Updated**: 2026-05-14
**Maintained By**: Session Strategist (Claude)

---

## What This Folder Is

This is the agent workspace for Galaxy Game development. It defines the workflow,
routing rules, and execution standards for a multi-agent system built around local
models with selective cloud assistance.

**Read this file first. Every session. Every agent.**

---

## AI Stack

| Agent | Access | Cost | Role |
|---|---|---|---|
| **Gemini** | Web, free | 0 tokens | **PRIMARY PLANNER** — planning, triage, session strategy |
| **Qwen3.5 (Continue)** | Local M4/Windows | 0 tokens | **TRIAGE LAYER** — task detail, template conformance, implementation prep |
| **Perplexity** | Web, free | 0 tokens | **TASK MANAGEMENT** — review, deployment, clearly-written task validation |
| Claude (free web) | Web, free tier | ~0 tokens | **SUPPLEMENTARY REVIEW** — only for occasional high-level review or planning prompts; not used for primary planning or triage |
| **Premium Reserved** | Cloud, paid | 0.33x-1x | Complex reasoning, large multi-file tasks, architecture — use sparingly |
| GitHub Copilot | Pro ($10/mo) | Token pool | June 2026 policy update pending |
| Local ollama cluster | Always available | 0 tokens | Code implementation, synthesis reports, second opinions |

**Token conservation strategy**: 
- Gemini/Continue/Perplexity handle 90% of workflow (planning, triage, management)
- Premium agents reserved for complex reasoning and large tasks only
- Mechanical work routes to GPT-4.1 0x (free) when possible
- Save premium tokens for work that actually needs Claude 1x or Haiku 0.33x judgment

---

## Hardware Topology

| Node | IP | Models | Role |
|---|---|---|---|
| Intel Mac | — | — | Orchestration, VS Code, git commits |
| M4 Mac | 10.6.186.161 | Codestral, Qwen2.5-14B, DeepSeek 16B | Architect, implementation, logic |
| Windows Ryzen 7 | 10.6.186.50 | Qwen3-30B, Qwen2.5-3B, Llama 3.1 8B, Nomic Embed | Workers, autocomplete, embed |
| Pi 4 | — | — | Samba shares, Docker capable |

**M4 must stay caffeinated**: run `caffeinate` or set `pmset` before long sessions.
Full model routing in `rules/AGENT_ROUTING.md`.

**Automation Recommendation:**
Automate the `caffeinate` (or `pmset`) step on the M4 Mac as part of session startup scripts to prevent accidental sleep and ensure stable Ollama/model connections.

---

## Continue Integration (NEW — May 2026)

Continue is a VS Code extension providing local-first access to ollama models. This enables a new triage layer:

**Qwen3.5 Triage Phase** (runs BEFORE cloud agent involvement):
- ✅ Reads task files from backlog
- ✅ Verifies template conformance against TASK_TEMPLATE.md
- ✅ Assesses MVP alignment (valid vs. stale vs. obsolete)
- ✅ Adds implementation detail and code examples
- ✅ Routes to appropriate cloud agent (0x vs. 0.33x vs. 1x)
- ✅ Produces "Local Worker Triage Report" section

**What Continue CAN do**: Read files, understand Rails/RSpec patterns, generate code, analyze structure, verify template compliance

**What Continue CANNOT do**: Execute commands, run RSpec, access database, run git, see test output

**Key Rule**: If a Continue model needs to report command output or test results, ask for them to be pasted — never fabricate.

Full details in [`CONTINUE_WORKFLOW_AUDIT.md`](CONTINUE_WORKFLOW_AUDIT.md).

---

## How a Session Works

### 1. Plan with Gemini (PRIMARY GATE)
Use Gemini to review session handoff, current RSpec baseline, and produce a priority stack and task recommendations. Gemini is the PRIMARY PLANNER for all session planning and triage. Claude (web) may be used for occasional high-level review or planning prompts only, not as a primary planner.

### 2. Triage & Detail with Qwen3.5 (Continue)
For each selected task file:
- Qwen3.5 reads the task file
- Verifies template conformance
- Adds implementation detail, code examples
- Produces "Local Worker Triage Report"
- Routes to appropriate cloud agent

### 3. Route tasks to the right cloud agent
Read `rules/AGENT_ROUTING.md` after Qwen3.5 has triaged. Qwen3.5 recommendations + task detail + MVP alignment → cloud agent routing decision. Claude (web) is not used for regular routing or triage.

### 4. One implementation agent at a time
Never run two agents executing RSpec simultaneously.
Task creation (Qwen3.5), research, and documentation can run in parallel.
Implementation cannot.

### 5. Every task follows the same pattern
1. Qwen3.5 reads and details the task (Continue phase)
2. Human reviews Qwen3.5 output and approves
3. Cloud agent reads the detailed task
4. Produce Synthesis Report and STOP
5. Wait for human approval
6. Apply fix
7. Run specs — confirm 0 new failures
8. Commit from host (Intel Mac)
9. Fill in completion report
10. Move task to `completed/`

**Flaky Spec Note:**
If any specs become flaky (pass in isolation but fail in suite), investigate for shared state, global config, or order-dependent setup. Address these before major milestones or breaks.

**Important Task Order Warning:**
If the water escalation ISRU chain task is completed, always run the full RSpec suite and verify no regressions before starting Task 1 (Effect Execution Engine v2). This prevents compounding unknowns and follows the handoff’s instructions.

### 6. Session ends with a handoff document
Save to: `docs/new_agent/tasks/session-handoffs/session_handoff_YYYY-MM-DD.md`

---

## Folder Structure

```
new_agent/
├── README.md                          ← you are here
├── ROUTING_LOGIC.md                   ← quick-reference routing (read this second)
├── TASK_OVERVIEW.md                   ← current session task stack
├── TASK_TEMPLATE.md                   ← template for new tasks
├── TASKS_ORGANIZATION.md              ← ⭐ NEW: where task files live (separate repo)
├── COMMUNICATION_PROTOCOL.md         ← how agents must format output
├── rules/
│   ├── GUARDRAILS.md                  ← execution rules — read before every task
│   ├── DECISIONS.md                   ← locked architectural decisions
│   └── AGENT_ROUTING.md              ← full routing table
├── agent_guides/
│   ├── galaxy_game.md                ← Galaxy Game domain context
│   ├── samvera_hyku.md               ← Hyku domain context
│   ├── samvera_hyrax.md              ← Hyrax domain context
│   ├── wvulibraries_acda_portal.md   ← ACDA Portal domain context
│   └── wvulibraries_knapsack.md      ← Knapsack domain context
├── projects/
│   └── galaxy_game/
│       ├── status.md                  ← current project baseline
│       └── context/
│           ├── CODEBASE_MAP.md       ← where things live
│           └── PATTERNS.md           ← code patterns in use
└── (task files moved to separate agent-tasks repo — see TASKS_ORGANIZATION.md)
```

**⭐ IMPORTANT**: Task files are now in a separate repository: `/Users/tam0013/Documents/git/agent-tasks/`
See [`TASKS_ORGANIZATION.md`](TASKS_ORGANIZATION.md) for details on the new structure.

---

## Before You Touch Any Code

Read these files in order:

1. `rules/GUARDRAILS.md` — execution rules, non-negotiable
2. `rules/DECISIONS.md` — locked decisions, do not contradict
3. `rules/AGENT_ROUTING.md` — confirm you are the right agent for this task
4. `context/PATTERNS.md` — understand the code patterns in use
5. Your assigned task file

**If any file conflicts with your task file, `DECISIONS.md` wins.**
Stop and flag the conflict before proceeding.

---

## Current Baseline
- **3960 examples, 0 failures, 57 pending** (RSpec suite clean as of 2026-05-18)
- Branch: `regional-view-phase2`
- Monthly goal: Luna settled, ISRU producing, AI Manager trained on pattern
- **Copilot routing freeze**: Do not route tasks to Copilot until
  `AGENT_ROUTING.md` is updated after June 2026 Gemini research is complete

**Reminder:** Schedule a Copilot policy review for June 2026 to align with the new token-based billing and update routing rules accordingly.
