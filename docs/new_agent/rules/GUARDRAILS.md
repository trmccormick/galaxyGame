# Project Galaxy Game: Operational Guardrails

### **Core Execution (Docker vs. Host)**
- **Rule 1**: All Rails/RSpec commands MUST be prefixed with `docker compose exec web`.
- **Rule 2**: Git and file system operations (moving files, creating folders) MUST happen on the Host (Mac/Windows).

### **Documentation & Continuity (Atomic Logic)**
- **Rule 10**: Documentation mandate—update corresponding .md files after every code change.
- **Rule 11 (Atomic Documentation)**: The `TASK_OVERVIEW.md` must be updated *before* any task is considered "In Progress" or "Complete."
- **Rule 12**: Use the `new_agent/tasks/backlog/` and `active/` folders to maintain temporal history.
- **Rule 13**: Reserve strategic context for "Handoff Commands"; keep active discussion focused on the current sub-task.

### **Economic Constraints**
- **Rule 14**: All financial calculations must strictly adhere to the `DECISIONS.md` (0.5% SCC, 1:1 USD/GCC peg).