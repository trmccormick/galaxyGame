# Galaxy Game — Human Workflow Guide
**Audience**: You, the human developer coordinating agents  
**Last Updated**: 2026-03-22  

> ⚠️ **Doc Maintenance Rule**: This document uses role names only.
> Never add model-specific names to this file.
> Model assignments belong in `AGENT_ROUTING.md` only.

---

## How a Session Works

```
You talk to the Planning Agent (any capable web agent — free tier)
  └─ Planning Agent triages failures, diagnoses root causes
  └─ Planning Agent creates task file in docs/agent/tasks/
  └─ Planning Agent produces a Handoff Command
       └─ You copy the Handoff Command
       └─ You paste it to the Implementation Agent (Copilot or local)
            └─ Implementation Agent reads README.md + task file
            └─ Implementation Agent produces Synthesis Report, waits for approval
            └─ You approve or redirect
            └─ Implementation Agent applies fix, runs spec, commits
            └─ Implementation Agent reports completion
       └─ You share completion report back to Planning Agent
  └─ Planning Agent updates session handoff document
  └─ You save handoff to docs/agent/tasks/session-handoffs/
```

The Planning Agent does the thinking. The Implementation Agent does the execution.
You are the bridge between them — approving fixes, sharing results, directing priorities.

---

## Starting a Session

### What to give the Planning Agent at session start:
1. **Current baseline** — paste the tail of the latest RSpec log, or run:
   ```bash
   tail -5 $(ls -t ./data/logs/rspec_full_*.log | head -1)
   ```
2. **Session handoff from last session** — paste contents of the most recent
   file in `docs/agent/tasks/session-handoffs/`
3. **Your priority for today** — what you want to focus on

The Planning Agent will produce a triage, priority stack, and first task file.

### What to check before starting:
1. Read `docs/agent/CURRENT_STATUS.md` — live project state
2. Check `docs/agent/tasks/critical/` — anything urgent?
3. Check `docs/agent/tasks/active/` — anything left over from last session?
4. Verify Docker containers are running:
   ```bash
   docker ps | grep web
   ```

---

## Nightly RSpec Run

Run this before bed to get a fresh baseline overnight:

```bash
# Start the run — returns immediately, runs in background
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec \
  > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Check results in the morning:
```bash
# See the summary
tail -5 $(ls -t ./data/logs/rspec_full_*.log | head -1)

# See all failures
grep "rspec \." $(ls -t ./data/logs/rspec_full_*.log | head -1)
```

Paste the summary to the Planning Agent at the start of your next session.

---

## Handing Off to an Implementation Agent

The Planning Agent produces a **Handoff Command** for you to copy and paste.
You do not need to write this yourself — it is the Planning Agent's output.

The command will follow this structure:

```
Read docs/agent/README.md first, then your task file at:
docs/agent/tasks/active/[task_file_name].md

[PRIORITY] ISSUE: [brief summary]

The issue:
- [symptom]
- [root cause]

Your tasks:
1. Read the task file completely before touching anything
2. Produce a Synthesis Report and wait for approval
3. Apply the approved fix
4. Run the spec in isolation — confirm 0 failures
5. Commit from host with descriptive message
6. Report back with test results

Priority: [LEVEL]
Estimated time: [estimate]
Agent Assignment: [role] — [reason]
```

### Where to paste it:
- **Copilot in VS Code**: Open Copilot Chat, switch to Agent mode, paste command
- **Local Ollama via Continue**: Open Continue panel, paste command
- **Any other interface**: Paste as the opening message

---

## VS Code Copilot Setup

### Enable Agent Mode
Agent mode gives Copilot terminal and file access — required for implementation work.

1. Press `Cmd+,` to open Settings
2. Search `chat.agent.enabled`
3. Check the box
4. Restart VS Code

### Switch Modes
Use the dropdown in the Copilot Chat panel:
- **Ask** — chat only, no file or terminal access
- **Edit** — file access, no terminal
- **Agent** — full access ← use this for implementation tasks

### If Agent Mode Stops Working
Microsoft updates can silently reset `chat.agent.enabled`. Re-enable via
`Cmd+,` → search `chat.agent.enabled` → check box → restart VS Code.

### Scope
Agent mode terminal access is for **local development only**.
Never grant terminal access to production or staging environments.

---

## Docker Volume Mount Warning

Always verify the base mount is present before overlay mounts:
```yaml
# In docker-compose.dev.yml — base mount must be first
- ./data/json-data:/home/galaxy_game/app/data
# Overlay mounts follow after
```

Mount order determines path resolution. If `GalaxyGame::Paths` constants fail,
check mount order with:
```bash
docker inspect web | grep -A 20 "Mounts"
```

---

## Session Handoffs

At the end of every session, the Planning Agent produces a session handoff document.
Save it to `docs/agent/tasks/session-handoffs/` with the naming convention:

```
session_handoff_YYYY-MM-DD.md
```

### What a good session handoff contains:
- Current baseline (examples, failures, pending)
- Branch name if not main
- Remaining failures with root causes and diagnostic commands
- Known pre-existing failures (not your responsibility this session)
- Key architecture decisions made this session
- Files modified this session
- Next session priorities with target failure count

### Starting fresh from a handoff:
Paste the handoff file contents to the Planning Agent at session start.
The Planning Agent will orient itself from the handoff without needing
you to re-explain context.

---

## Request Prefixes for Planning Agent

Use these prefixes when talking to the Planning Agent for clear, focused responses:

| Prefix | Use For | Example |
|---|---|---|
| `REVIEW:` | Analyze and provide feedback | `REVIEW: backlog for overlaps` |
| `PLAN:` | Develop strategy or roadmap | `PLAN: next phase after RSpec restoration` |
| `CREATE TASK:` | Generate task file + handoff command | `CREATE TASK: fix shell printing spec` |
| `CODE REVIEW:` | Evaluate code quality | `CODE REVIEW: new escalation service` |
| `TRIAGE:` | Analyze failure log | `TRIAGE: [paste RSpec output]` |
| `HANDOFF:` | Produce session handoff document | `HANDOFF: end of session` |

---

## Task File Lifecycle

```
Planning Agent creates task file
  └─ Saved to tasks/backlog/ or tasks/critical/
       └─ When assigned → moved to tasks/active/
            └─ Implementation Agent works from active/
            └─ When complete → moved to tasks/completed/
                 └─ Completion report added to file
```

Update `CURRENT_STATUS.md` after each completion.

---

## When to Use Which Agent

Full cost and capability guide: `docs/agent/AGENT_ROUTING.md`

Quick guide:
- **Diagnosis, architecture, task creation** → Planning Agent (free web agent)
- **Simple targeted fix, fully specified** → lowest cost implementation agent
- **Complex multi-file fix** → mid-tier implementation agent
- **Stuck after 2 attempts** → escalate to higher-tier implementation agent
- **Game design brainstorming** → creative web agent (free)
- **Sprite/image generation** → image generation agent (free)
- **Research/external references** → research web agent (free)

**Budget rule**: Always start with the cheapest capable agent.
Escalate when stuck, not before.

---

## Common Mistakes to Avoid

**Skipping the session handoff** — context is lost, next session starts from scratch

**Pasting task file contents instead of the file path** — implementation agents
in VS Code can read the file directly, pasting contents wastes tokens

**Approving a fix without reading the Synthesis Report** — the report exists
for a reason, read the risk section before approving

**Asking the implementation agent to run the full suite too early** — only
after all targeted specs in the session are green

**Creating documentation during implementation tasks** — always flag the gap,
create docs in a separate task

**Letting the implementation agent make a third fix attempt** — two attempts
then escalate to Planning Agent for re-diagnosis
