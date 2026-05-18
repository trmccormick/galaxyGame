# Task Organization — Agent-Tasks Repository

**Updated**: May 18, 2026

---

## Overview

All project tasks have been moved from this repository to a separate, shared `agent-tasks` repository. This keeps the main project repos clean while maintaining a centralized task tracking system.

---

## Repository Structure

```
📁 /Users/tam0013/Documents/git/
├── 📁 galaxyGame/                    ← Project code & agent rules (THIS REPO)
│   └── docs/new_agent/              ← Agent guidance, routing, decisions
├── 📁 agent-tasks/                   ← ALL TASK FILES (SEPARATE REPO)
│   ├── galaxy_game/
│   │   ├── active/
│   │   ├── backlog/
│   │   ├── completed/
│   │   └── ...
│   ├── samvera_hyku/
│   ├── samvera_hyrax/
│   └── ...
├── 📁 hydra_acda_portal_public/
├── 📁 wvu_knapsack/
└── 📁 ... other projects
```

---

## What's Where?

### ✅ STAYS in galaxyGame (`docs/new_agent/`)
- **Agent Rules**: `rules/GUARDRAILS.md`, `rules/DECISIONS.md`, `rules/AGENT_ROUTING.md`
- **Guidance**: `README.md`, `agent_guides/`, `TASK_TEMPLATE.md`
- **Routing**: `ROUTING_LOGIC.md`, `CONTINUE_WORKFLOW_AUDIT.md`
- **Status**: `projects/galaxy_game/status.md`
- **Context**: `projects/galaxy_game/context/CODEBASE_MAP.md`

### 🚀 MOVED to agent-tasks (`/agent-tasks/galaxy_game/`)
- **Active Tasks**: `active/`
- **Backlog Tasks**: `backlog/`
- **Completed Tasks**: `completed/`
- **Planning Tasks**: `planning/`
- **Documentation Tasks**: `documentation/`
- **Testing Tasks**: `testing/`
- **Deprecated Tasks**: `depricated/`

---

## How to Use

### Finding Galaxy Game Tasks
```bash
# From galaxyGame or any project, reference:
../agent-tasks/galaxy_game/active/
../agent-tasks/galaxy_game/backlog/
../agent-tasks/galaxy_game/completed/
```

### Cloning agent-tasks on New Systems
```bash
cd ~/Documents/git
git clone https://github.com/trmccormick/agent-tasks.git
```

### Workflow
1. **Review tasks**: Open `agent-tasks/galaxy_game/active/` for current work
2. **Check backlog**: Open `agent-tasks/galaxy_game/backlog/` for planned work
3. **Agent rules**: Check `galaxyGame/docs/new_agent/rules/` for execution guidelines
4. **Status**: See `galaxyGame/docs/new_agent/projects/galaxy_game/status.md` for current baseline

---

## Why This Structure?

| Reason | Benefit |
|--------|---------|
| Separate repo | Tasks don't clutter project history |
| Shared location | Single source of truth across systems |
| Offline access | Clone locally, work without network |
| Multi-project | One place to track all 5 projects |
| Pi-optional | Can sync to home server for backup |

---

## Multi-System Sync

### Intel Mac & M4 MacBook
```bash
# Both systems have independent clones
# Sync via: git push / git pull
```

### Home Network (Optional)
- Can mount `agent-tasks/` from Pi Samba share when on home network
- Configured in: https://github.com/trmccormick/home-server

---

## References

- **agent-tasks repo**: https://github.com/trmccormick/agent-tasks
- **galaxyGame agent rules**: `docs/new_agent/rules/`
- **Task template**: `docs/new_agent/TASK_TEMPLATE.md`
