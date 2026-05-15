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

| Agent | Access | Role |
|---|---|---|
| Claude (web, free tier) | When available | Planning, documentation, architecture review |
| Gemini | Web, free | Galaxy Game first-level review, plan preparation |
| Perplexity | Web, free | Research, documentation lookup, community questions |
| GitHub Copilot | Pro ($10/mo, token-based from June 2026) | Work/Samvera tasks only — conserve tokens |
| Local ollama cluster | Always available | All implementation — primary execution layer |

**Token conservation is the core constraint of this workflow.**
Cloud agents think and plan. Local agents execute.

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

---

## How a Session Works

### 1. Plan with a cloud agent
Use Claude, Gemini, or Perplexity to review the session handoff, current RSpec
baseline, and produce a priority stack and task files. This is the only time
cloud agents are used — planning and review gates only.

### 2. Route tasks to the right local agent
Read `rules/AGENT_ROUTING.md` before assigning any task.
Wrong agent = wasted time and degraded output.

### 3. One implementation agent at a time
Never run two agents executing RSpec simultaneously.
Task creation, research, and documentation can run in parallel.
Implementation cannot.

### 4. Every task follows the same pattern
1. Read task file completely before touching anything
2. Produce Synthesis Report and STOP
3. Wait for human approval
4. Apply fix
5. Run specs — confirm 0 new failures
6. Commit from host (Intel Mac)
7. Fill in completion report
8. Move task to `completed/`

### 5. Session ends with a handoff document
Save to: `docs/new_agent/tasks/session-handoffs/session_handoff_YYYY-MM-DD.md`

---

## Folder Structure

```
new_agent/
├── README.md                          ← you are here
├── ROUTING_LOGIC.md                   ← quick-reference routing (read this second)
├── TASK_OVERVIEW.md                   ← current session task stack
├── COMMUNICATION_PROTOCOL.md         ← how agents must format output
├── rules/
│   ├── GUARDRAILS.md                  ← execution rules — read before every task
│   ├── DECISIONS.md                   ← locked architectural decisions
│   └── AGENT_ROUTING.md              ← full routing table
├── agent_guides/
│   └── codestral_architect.md        ← Codestral role and system context
├── research/
│   └── LUNAR_GEOSPHERE_BASE.md       ← lunar resource baseline
├── context/
│   ├── PATTERNS.md                    ← Robot/Battery pattern, job lifecycle
│   └── CODEBASE_MAP.md               ← where things live in the codebase
└── tasks/
    ├── active/                        ← currently assigned tasks
    ├── backlog/
    │   ├── 2026_04/
    │   └── 2026_05/
    └── completed/                     ← finished tasks with completion reports
```

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
- **3956 examples, 22 failures, 57 pending**
- Branch: `regional-view-phase2`
- Monthly goal: Luna settled, ISRU producing, AI Manager trained on pattern
- **Copilot routing freeze**: Do not route tasks to Copilot until
  `AGENT_ROUTING.md` is updated after June 2026 Gemini research is complete
