# Agent & Development Workflow Documentation

This directory contains unified documentation for AI agent management and development workflow, organized by status and purpose. All new map and surface rendering tasks must use the JSON-based tileset system.

## 📁 Directory Structure

### Root Files
- **[CURRENT_STATUS.md](CURRENT_STATUS.md)** - Real-time project status, recent fixes, next steps
- **[GROK_CURRENT_WORK.md](GROK_CURRENT_WORK.md)** - Current agent work tracking

### `/rules/` - Agent Operating Rules
Core protocols and guidelines for AI agent operation.

**Files:**
- **[GROK_RULES.md](rules/GROK_RULES.md)** - Complete agent operating protocols
- **[TASK_PROTOCOL.md](rules/TASK_PROTOCOL.md)** - Task execution and completion standards

**Purpose**: Defines how agents operate and complete work

### `/tasks/` - Agent Task Management
Executable tasks for AI agents with status tracking.

**Subfolders:**
- **`/active/`** - Currently executing tasks
- **`/backlog/`** - Queued tasks awaiting assignment
- **`/critical/`** - Critical priority tasks requiring immediate attention
- **`/completed/`** - Finished tasks for reference

**Files:**
- **[TASK_OVERVIEW.md](tasks/TASK_OVERVIEW.md)** - Centralized task tracking log

**Purpose**: Task assignment, progress tracking, and completion validation

### `/planning/` - Future Roadmaps
Strategic planning documents for upcoming development phases.

**Files:**
- **[RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md)** - 6-phase roadmap
  - Phase 1-3: Test restoration (surgical fixes)
  - Phase 4: UI Enhancement (SimEarth admin + Eve mission builder)
  - Phase 5: AI Pattern Learning (autonomous wormhole expansion)
  - Phase 6: Documentation cleanup

**Purpose**: Long-term vision and phase-by-phase execution plans

### `/completed/` - Historical Records
Documentation of completed work for reference and learning.

**Files:**
- **[CONSTRUCTION_REFACTOR.md](completed/CONSTRUCTION_REFACTOR.md)** - Manufacturing pipeline implementation

**Purpose**: Preserve institutional knowledge, reference for similar future work

### `/reference/` - Technical Guides
Essential technical documentation for daily development.

**Files:**
- **[grok_notes.md](reference/grok_notes.md)** - Agent-specific technical notes

**Purpose**: Essential development and agent references

## 🔴 Current Grinder State
**Last Updated**: March 3, 2026 — update this section after every grinder run

| Metric | Value |
|---|---|
| Total Examples | 4,056 |
| Total Failures | 369 |
| Pending | 17 |
| Target | <50 failures |
| Log Location | `./data/logs/rspec_full_[timestamp].log` |

### Top Failing Specs (start here)
1. `spec/services/ai_manager/escalation_service_spec.rb` — **25 failures**
2. `spec/services/manufacturing/construction/dome_service_spec.rb` — **24 failures**
3. `spec/services/manufacturing/construction/hangar_service_spec.rb` — **23 failures**
4. `spec/integration/ai_manager/escalation_integration_spec.rb` — **20 failures**
5. `spec/services/lookup/unit_lookup_service_spec.rb` — **18 failures**

### Grinder Startup
Always run `./start_grinder.sh` first — it seeds the test database, clears cache, generates a fresh baseline log, and outputs the current top failing specs. Do not start grinding without running this first.

```bash
# On host — starts grinder pre-flight and generates fresh baseline
./start_grinder.sh
```

### Mandatory RSpec Command Form
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb > ./data/logs/rspec_full_$(date +%s).log 2>&1'
```

> ⚠️ Logs go to `./data/logs/` — not `./log/`. Always use this path.

---

**Agent-Driven Development**: Most work flows through the `/tasks/` system where planning documents are converted into executable agent tasks.

**Status Tracking**: Use `CURRENT_STATUS.md` for real-time updates, `/tasks/TASK_OVERVIEW.md` for detailed task logs.

**Planning → Execution**: Documents in `/planning/` are broken down into tasks in `/tasks/backlog/` for agent assignment.

**Task Completion Workflow**: 
1. Complete all task requirements and testing
2. Move task file from source directory (`/active/`, `/critical/`, `/backlog/`) to `/completed/`
3. Remove empty source directories to maintain clean structure
4. Update `CURRENT_STATUS.md` with completion details
5. Commit changes following mandatory pre-commit testing protocol
  - RSpec ALWAYS in container
  - Command validation patterns

**Purpose**: Quick reference for correct development practices

---

## 🎯 Usage Patterns

### Simulation & Map Data Intent
- **FreeCiv/Civ4 tilespec and biome data are no longer used for map rendering.**
- All surface and monitor views use the new JSON-based tileset system for both scientific and artistic worlds.
- Biome data is only included for worlds with biosphere or active terraforming.
- Terrain/elevation data is always present; biomes/features/resources/civilization layers are conditionally included based on world properties.

### Starting Your Day
1. Read [CURRENT_STATUS.md](CURRENT_STATUS.md) to see latest progress
2. **CRITICAL**: Review [Environment Boundaries & Docker Isolation](#-critical-environment-boundaries--docker-isolation) section below
3. Check [ENVIRONMENT_BOUNDARIES.md](rules/ENVIRONMENT_BOUNDARIES.md) for command safety rules
4. Reference [RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md) for phase context

### Planning New Features
1. Review [RESTORATION_AND_ENHANCEMENT_PLAN.md](planning/RESTORATION_AND_ENHANCEMENT_PLAN.md) phases
2. Check [CONSTRUCTION_REFACTOR.md](completed/CONSTRUCTION_REFACTOR.md) for implementation patterns
3. Update [CURRENT_STATUS.md](CURRENT_STATUS.md) when starting work

### Interactive Quick-Fix Protocol (Executor — when user is present)
Use this for monitored collaboration during the day. Stops at first failure and waits for analysis before applying fixes.

```bash
# Step 1: Run fail-fast to find first failure
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec --fail-fast --format documentation 2>&1 | tee ./log/rspec_full_$(date +%s).log'
```

After running, produce a Synthesis Report:

**The Failure** — spec file, line, error message, expected vs actual

**The Discrepancy** — compare current code vs Jan 8 backup at:
`/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/`

**Proposed Fix** — code change with rationale

**Documentation Plan** — what docs need updating after the fix

**Then STOP** — wait for user approval before applying any changes.

> Use Grinder (overnight) for autonomous batch processing. Use Quick-Fix (daytime) for monitored single-failure collaboration.

### Autonomous Grinder Protocol (Executor — overnight unattended)
Run `./start_grinder.sh` first to establish baseline, then grind top failing specs autonomously:
- Fix → test → fix → green → commit → next spec
- No user prompts between specs
- Only stop for architectural decisions requiring human input
- Update `CURRENT_STATUS.md` after each batch
> ⚠️ **Tests are ONLY run when explicitly requested by the user. Do not run tests as part of review, planning, or routine coding tasks.** See GUARDRAILS.md Section 13.

1. **ALWAYS** consult [ENVIRONMENT_BOUNDARIES.md](rules/ENVIRONMENT_BOUNDARIES.md) for command safety
2. Use [grok_notes.md](reference/grok_notes.md) task templates for workflow guidance
3. **NEVER** run Rails/Ruby commands on host — always use `docker exec -it web bash -c '...'`
4. **Tileset/Map Rendering:** All new map and surface rendering code must use the JSON-based tileset system. Legacy FreeCiv/Civ4 asset pipelines are deprecated.

### Git Operations (Host Only)
- `git` commands are run on the **host**, not inside the container
- All other commands (Rails, rake, rspec, bundle) run **inside the container only** via `docker exec -it web`

## 🧪 Testing Requirements & Validation Rules

### 🔴 NEVER Run Tests Unprompted
**RSpec must only be run when the user has explicitly requested it.** The following do NOT grant permission to run tests:
- Completing a code change
- Finding or fixing a bug
- Code review or planning work
- Pre-commit validation (flag it, don't run it autonomously)

When in doubt: **do not run tests. Ask the user.**

### **MANDATORY: Pre-Commit Testing Protocol**
**When tests ARE requested, ALL code changes MUST pass RSpec before commit:**

1. **Run RSpec tests for changed code — always via `docker exec`, never `docker-compose exec`:**
   ```bash
   # ✅ CORRECT
   docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
   # OR for specific files:
   docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/escalation_service_spec.rb'

   # ❌ FORBIDDEN — risks dev database corruption
   docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec
   ```

2. **Validation Rules (MANDATORY):**
   - ✅ **Green-before-done**: All RSpec tests must pass
   - ✅ **No regressions**: Existing tests still pass
   - ✅ **Service integration**: Related services load and interact correctly
   - ✅ **Rails runner verification**: Manual testing with `rails runner` for complex logic

3. **Testing Scope Requirements:**
   - **New/Modified Services**: Full RSpec spec file required
   - **Bug Fixes**: Tests demonstrating the fix works
   - **Integration Changes**: Tests verifying service interactions
   - **Configuration Changes**: Tests validating new behavior

### **🚫 CRITICAL: Environment Boundaries & Docker Isolation**

**ALL development work MUST occur within Docker containers. Host system isolation is mandatory:**

#### **NEVER Run Commands on Host System**
- ❌ **Do NOT run** `bundle install`, `rails server`, `rake db:migrate`, etc. on host
- ❌ **Do NOT change** Ruby versions, system packages, or host environment
- ❌ **Do NOT run** Rails commands, RSpec tests, or database operations on host
- ❌ **Do NOT modify** host Ruby, Node.js, or system-level dependencies

#### **ALWAYS Use `docker exec` for Everything in the Container**
- ✅ **Rails Commands**: `docker exec -it web bash -c 'bundle exec rails ...'`
- ✅ **RSpec Tests**: `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'`
- ✅ **Database Operations**: `docker exec -it web bash -c 'bundle exec rake db:...'`
- ✅ **Bundle Install**: `docker exec -it web bash -c 'bundle install'`
- ✅ **Rails Console**: `docker exec -it web bash -c 'bundle exec rails console'`
- ✅ **Git commands**: Run on the **host** directly — this is the only exception

> ⚠️ **`docker-compose exec` is FORBIDDEN for running app commands.** It does not reliably isolate the database environment and has caused dev database corruption. Always use `docker exec -it web`.

#### **Ruby Version Management**
- **DO NOT change Ruby versions** in Gemfile, Dockerfile, or host system
- **Ruby version is fixed** at 3.4.3 in Docker containers - this is intentional
- **Host Ruby version is irrelevant** - all work happens in isolated containers
- **Version mismatches indicate configuration errors**, not version changes needed

#### **Service Isolation Benefits**
- **Predictable environment**: Same Ruby, gems, and dependencies every time
- **No host pollution**: Development doesn't affect or require host system changes
- **Team consistency**: All developers work in identical Docker environments
- **Clean separation**: Host system remains stable and unchanged

### **NEVER Commit Without Testing — But Do Not Run Tests Autonomously**
- **Rails runner commands are NOT sufficient** for validation
- **Manual testing is NOT sufficient** for validation
- **Only RSpec tests provide proper regression protection**
- **All substantive changes require automated test coverage**
- **If you are a Planner agent:** flag that tests are needed, do not run them yourself

### **Testing Workflow (Executor / Grinder Agent Only)**
1. Make code changes
2. Write/update RSpec tests
3. Run tests (only when instructed):
   ```bash
   docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec'
   ```
4. Fix any failures
5. Re-run tests until green
6. Only then commit and push

---

## 📝 Maintenance Guidelines

### When to Update Current Grinder State (top of this file)
- After every `./start_grinder.sh` run — update failure count and top targets
- After each batch of fixes — update the failure count
- When a spec file reaches 0 failures — remove it from the top targets list
- When failure count crosses thresholds (369 → 300 → 200 → 100 → 50)

### When to Add to /completed/
- After completing major refactors
- When finishing multi-week development phases
- For documenting E2E integration work
- Preserving "how we built this" context

### When to Update Planning Docs
- Adding new phases or sub-phases
- Changing success metrics or targets
- Discovering better workflow patterns
- Adjusting timeline estimates

---

## 🔗 Related Documentation

### Parent Documentation
- [Main Docs README](../README.md) - Full project documentation hub
- [Developer Setup](../developer/setup.md) - Environment configuration

### Sibling Directories
- [Architecture](../architecture/) - System design
- [Storyline](../storyline/) - Game narrative
- [AI Manager](../ai_manager/) - AI systems

---

**Last Updated**: March 3, 2026  
**Maintainer**: Development team  
**Status**: Active organization (v2.0)

### **⚙️ GRINDER / EXECUTOR AGENT AUTONOMY**
**This section applies ONLY to the Executor (Grinder) agent. Planner agents are not exempt from any restrictions.**

When running as the Grinder/Executor agent on an explicitly assigned grinding task:
- **No user prompts required** for `docker exec -it web` command execution
- **Automatic fix application** without confirmation for failing specs
- **Self-contained validation** and commit cycles
- **Continuous progression** to next specs without input
- **`docker-compose exec` remains forbidden** — always use `docker exec -it web`
- **Container lifecycle (start/stop/restart) remains forbidden** — containers are always assumed running
- **RAILS_ENV=test and unset DATABASE_URL remain mandatory** on every test run — no exceptions

This exception enables efficient test suite restoration while maintaining all safety protocols in GUARDRAILS.md Sections 12 and 13.
