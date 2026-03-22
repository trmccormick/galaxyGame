# Task Protocol — Planner Reference
**Galaxy Game Development — Agent Task Management**  
**Location**: `docs/agent/rules/`  
**Last Updated**: 2026-03-22  
**Audience**: Planner agents creating and assigning tasks

---

## Purpose

This document defines how planners write task files, specify commands, assign
agents, and set priorities. It is a reference for task creation — not for
execution. Executors follow `IMPLEMENTATION_AGENT_README.md`.

For the task file format itself, use `TASK_TEMPLATE.md`.

---

## Role Separation

| | Planner Agent | Implementation Agent |
|---|---|---|
| Write task files | ✅ | ❌ |
| Edit `docs/` | ✅ | ✅ docs only |
| Edit `app/` | ❌ | ✅ |
| Run RSpec | ❌ Never | ✅ When assigned |
| Run docker exec | ❌ Never | ✅ |
| Restart containers | ❌ Never | ❌ Never |
| Use docker-compose exec | ❌ Never | ❌ Never |
| Git commands (host) | ✅ | ✅ |

**Planner's job ends at writing correct task files.**  
**Implementation agent's loop is: fix → test → fix → green → commit → report back.**

---

## Critical: Planners Must Write Correct Commands

Commands in task files are run verbatim by implementation agents.
Incorrect command forms cause dev database corruption or silent failures.

### ✅ Canonical Command Forms — always use these exactly

```bash
# RSpec — always chained, always via docker exec -it web bash -c
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec \
  path/to/spec.rb > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'

# Rails runner — inside container
docker exec -it web bash -c 'bundle exec rails runner "puts SomeClass.count"'

# Database reset — inside container
docker exec -it web bash -c 'bundle exec rake db:reset db:seed'

# Git — on HOST only, never inside docker exec
git add path/to/specific/file.rb
git commit -m "fix: [component] — description"
git push
```

### ❌ Forbidden Forms — never write these in task files

```bash
# Bare commands — agent runs them on host by mistake
rails db:reset
bundle exec rspec

# docker-compose exec — bypasses database isolation, corrupts dev db
docker-compose exec web bundle exec rspec

# Persistent shell — breaks in non-interactive use
docker exec -it web bash
# ...followed by separate command lines
```

---

## Task Priority Levels

### 🔥 CRITICAL
- System-breaking issues
- Data loss prevention
- Core functionality failures
- Security vulnerabilities

### ⚠️ HIGH
- Features blocking other work
- Performance issues affecting users
- API or contract breakages
- Testing infrastructure failures

### 📋 MEDIUM
- Feature enhancements
- Code quality improvements
- Non-blocking UI improvements
- Documentation updates

### 🔧 LOW
- Code cleanup
- Minor optimizations
- Nice-to-have features
- Future-proofing

---

## Task Categories

### Bug Fixes
- Symptom-based: "Interface shows X but should show Y"
- Root cause: "Method Z fails because of W"
- Regression: "Previously working feature now broken"

### Feature Development
- New components — full feature implementation
- Enhancements — extend existing functionality
- Integrations — connect existing systems

### Infrastructure & Maintenance
- Testing — add or update test coverage
- Documentation — update guides and references
- Performance — optimize slow operations
- Data — update JSON data files, blueprints, operational data

### Research & Planning
- Architecture — design system changes
- Analysis — investigate complex issues before implementation

---

## Complexity & Time Estimates

Use these when setting `Estimated Effort` in task files:

| Level | Time | Description |
|---|---|---|
| Simple bug fix | 30–60 min | Single file, obvious issue, clear test |
| Medium fix | 2–4 hours | Multiple files, some investigation needed |
| Complex feature | 4–8 hours | Architecture changes, extensive testing |
| Research task | 1–2 hours | Investigation only, no implementation |
| Documentation | 30–90 min | Analysis plus writing |

**Multipliers:**
- First time working in this area of codebase: ×1.5
- Shared concerns or base classes involved: ×1.8
- High risk of regression: ×2.0

---

## Agent Assignment Guidelines

Full agent roster and cost tiers: `AGENT_ROUTING.md`

**Key rule: task file depth must match agent capability.**

- **0x agents (GPT-4.1)**: Every field explicit — exact file paths, line numbers,
  step-by-step commands, no ambiguity. Agent cannot infer gaps.
- **0.25x agents (Grok)**: Most fields explicit, commands fully specified.
- **0.33x agents (Gemini Flash)**: Key fields required, some inference OK.
- **1x agents (Claude Sonnet)**: Core fields required, can reason about gaps.

When in doubt — over-specify. It costs nothing and prevents wasted requests.

---

## Mandatory References in Every Task File

Every task assigned to an implementation agent must reference:

- **`GUARDRAILS.md`** — AI Manager behavior, economic boundaries, architectural rules
- **`ENVIRONMENT_BOUNDARIES.md`** — Container operations, prohibited actions
- Relevant architecture docs from `docs/architecture/` if the task touches
  a system with a doc there

---

## Task File Location

| Status | Folder |
|---|---|
| Ready to assign | `docs/agent/tasks/backlog/` |
| High priority, assign immediately | `docs/agent/tasks/critical/` |
| Currently being worked | `docs/agent/tasks/active/` |
| Finished | `docs/agent/tasks/completed/` |

When assigning a task, move the file from `backlog/` or `critical/` to `active/`.
When complete, move from `active/` to `completed/`.
Update `CURRENT_STATUS.md` after each completion.

---

## Quality Checklist — Before Handing Off a Task File

- [ ] Agent assignment specified with reason
- [ ] All file paths are exact, not approximate
- [ ] All commands use canonical form (see above)
- [ ] No forbidden command forms present
- [ ] Synthesis Report format included
- [ ] Stop conditions listed
- [ ] Acceptance criteria are measurable
- [ ] Priority level set
- [ ] Dependencies noted
- [ ] Relevant architecture docs referenced

---

## Common Pitfalls When Writing Task Files

**Hardcoded paths** — agent will break across environments  
Use `GalaxyGame::Paths::CONSTANT` not `"app/data/geotiff/earth.tif"`

**Missing DATABASE_URL unset** — will corrupt dev database  
Every test command must start with `unset DATABASE_URL &&`

**Namespace collisions** — use fully qualified class names  
`CelestialBodies::Planets::Rocky::TerrestrialPlanet` not `TerrestrialPlanet`

**Vague acceptance criteria** — agent doesn't know when it's done  
"Tests pass" is not enough. Specify: "X examples, 0 failures" or "method returns Y"

**Missing stop conditions** — agent keeps trying past the point of usefulness  
Always specify: escalate after 2 failed attempts, not 3 or more

**Creating docs during implementation tasks** — causes doc sprawl  
Task files should say "flag doc gap in completion report" not "create new doc"
