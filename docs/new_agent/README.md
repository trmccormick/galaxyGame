# Galaxy Game — Agent Workspace
**Version**: 2.0 (Local-First Architecture)
**Last Updated**: 2026-05-12
**Maintained By**: Session Strategist (Claude)

---

## What This Folder Is

This is the agent workspace for Galaxy Game development. It replaces
`docs/agent/` with a workflow designed around the local model cluster
rather than cloud-only agents.

**Read this file first. Every session. Every agent.**

---

## How a Session Works

### 1. Human starts a planning session with Claude
Claude reads the latest session handoff, current RSpec baseline, and
produces a priority stack and task files. This is the only time Claude
is used — planning gates only.

### 2. Tasks go to the right agent
Read `rules/AGENT_ROUTING.md` to determine which agent handles which task.
Wrong agent = wasted tokens and bad output.

### 3. One implementation agent at a time
Never run two agents that execute RSpec simultaneously.
Task creation, research, and documentation can run in parallel.
Implementation cannot.

### 4. Every task follows the same pattern
- Read task file completely before touching anything
- Produce Synthesis Report and STOP
- Wait for human approval
- Apply fix
- Run specs — confirm 0 new failures
- Commit from host
- Fill in completion report
- Move task to completed/

### 5. Session ends with a handoff document
Save to `docs/new_agent/tasks/session-handoffs/session_handoff_YYYY-MM-DD.md`

---

## Folder Structure

```
new_agent/
├── README.md                    ← you are here
├── rules/
│   ├── GUARDRAILS.md            ← execution rules — read before every task
│   ├── DECISIONS.md             ← locked architectural decisions
│   └── AGENT_ROUTING.md        ← which agent for which task
├── research/
│   └── LUNAR_GEOSPHERE_BASE.md ← lunar resource baseline
├── context/
│   ├── PATTERNS.md              ← Robot/Battery pattern, job lifecycle
│   └── CODEBASE_MAP.md         ← where things live in the codebase
└── tasks/
    ├── active/                  ← currently assigned tasks
    ├── backlog/
    │   ├── 2026_04/             ← April backlog
    │   └── 2026_05/             ← May backlog
    └── completed/               ← finished tasks with completion reports
```

---

## Before You Touch Any Code

1. Read `rules/GUARDRAILS.md` — execution rules
2. Read `rules/DECISIONS.md` — locked decisions, do not contradict
3. Read `rules/AGENT_ROUTING.md` — confirm you are the right agent
4. Read `context/PATTERNS.md` — understand the code patterns
5. Read your task file completely

If any of these files conflict with instructions in a task file,
**DECISIONS.md wins**. Stop and flag the conflict before proceeding.

---

## Hardware Topology (Quick Reference)

| Node | IP | Role |
|---|---|---|
| Intel Mac | — | Orchestration, VS Code, git |
| M4 Mac | 10.6.186.161 | Architect models (Codestral, Qwen 14B, DeepSeek) |
| Windows Ryzen 7 | 10.6.186.50 | Worker models (Qwen3-30B, Qwen 2.5, Nomic Embed) |
| Pi 4 | — | Samba shares, Docker capable |

Full routing in `rules/AGENT_ROUTING.md`.

---

## Current Baseline (2026-05-12)
- **3956 examples, 22 failures, 57 pending**
- Branch: `regional-view-phase2`
- Monthly goal: Luna settled, ISRU producing, AI Manager trained on pattern
