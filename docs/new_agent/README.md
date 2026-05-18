# Galaxy Game — Agent Workspace (Project-Specific)

**Important**: The shared agent infrastructure has been moved to a separate repository.

---

## Where to Find Agent Guidance

### ⭐ Shared Agent Workspace (All Projects)
**Location**: `/Users/tam0013/Documents/git/agent-tasks/`  
**Purpose**: Rules, routing, guides, protocols for all projects (Galaxy Game, Samvera, WVU)

**Contains:**
- `README.md` — Main agent workspace guide (READ THIS FIRST)
- `ROUTING_LOGIC.md` — Quick-reference routing
- `rules/GUARDRAILS.md` — Execution rules
- `rules/DECISIONS.md` — Locked architectural decisions
- `rules/AGENT_ROUTING.md` — Full routing table
- `agent_guides/` — Work project guides (samvera_hyku, samvera_hyrax, wvulibraries_*)
- `TASK_TEMPLATE.md` — Template for new tasks
- `COMMUNICATION_PROTOCOL.md` — Agent output format rules

**To use:**
```bash
# From any project, reference the shared workspace:
~/Documents/git/agent-tasks/

# Or once it moves to OneDrive (for work projects):
~/OneDrive/agent-workspace/
```

---

## Galaxy Game Project-Specific Files (This Folder)

```
docs/new_agent/
├── README.md                           ← you are here
├── agent_guides/
│   └── galaxy_game.md                  ← Galaxy Game domain context
└── projects/
    └── galaxy_game/
        ├── status.md                   ← Project baseline & current state
        ├── context/
        │   ├── CODEBASE_MAP.md        ← Where code lives
        │   └── PATTERNS.md             ← Code patterns in use
        └── research/
            └── LUNAR_GEOSPHERE_BASE.md ← Lunar resource baseline
```

---

## Task Files

**Galaxy Game tasks** are now in the separate `agent-tasks` repository:

```
/Users/tam0013/Documents/git/agent-tasks/galaxy_game/
├── active/           ← Current sprint work
├── backlog/          ← Planned but not started
├── completed/        ← Finished (archive)
├── planning/         ← Long-term strategy
└── testing/          ← Testing-focused tasks
```

---

## Before Starting Any Galaxy Game Task

1. **Read shared agent workspace**: `~/Documents/git/agent-tasks/README.md`
2. **Check Galaxy Game status**: `projects/galaxy_game/status.md`
3. **Understand Galaxy Game context**: `projects/galaxy_game/context/CODEBASE_MAP.md`
4. **Review rules**: `~/Documents/git/agent-tasks/rules/GUARDRAILS.md`
5. **Read your task file**: `~/Documents/git/agent-tasks/galaxy_game/[status]/[TASK].md`

---

## Multi-System Setup

**All Systems Access:**
- Intel Mac (home)
- M4 MacBook (portable, office work)
- Windows Ryzen (personal)

**Shared Workspace Location:**
- `~/Documents/git/agent-tasks/` (git-based, cloned on each system)
- **Future**: May move to `~/OneDrive/agent-workspace/` for work projects only

**Tasks Sync:**
- Push/pull via git
- Always use `git pull` before starting a session

---

## References

- **Agent-tasks repository**: https://github.com/trmccormick/agent-tasks
- **Shared agent workspace**: `~/Documents/git/agent-tasks/README.md`
- **Galaxy Game domain guide**: `agent_guides/galaxy_game.md`
- **Galaxy Game status**: `projects/galaxy_game/status.md`
