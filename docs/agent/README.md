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
**Last Updated**: March 6, 2026 — EscalationIntegrationSpec fixed (238 → 221 failures)

| Metric | Value |
|---|---|
| Total Examples | 4,056 |
| Total Failures | 221 |
| Pending | 17 |
| Target | <50 failures |
| Log Location |
| **Host:** `/data/logs/rspec_full_[timestamp].log` |
| **Container:** `/home/galaxy_game/log/rspec_full_[timestamp].log` |

> **Note:** Log directory mapping is defined in `docker-compose.dev.yml` and related compose files:
> ```yaml
>   - ./data/logs:/home/galaxy_game/log
> ```
> Always consult the compose files for correct host vs. container bind mount paths.

### Top Failing Specs (start here)
1. `spec/services/ai_manager/escalation_service_spec.rb` — **25 failures**
2. `spec/services/manufacturing/construction/dome_service_spec.rb` — **24 failures**
3. `spec/services/manufacturing/construction/hangar_service_spec.rb` — **23 failures**
4. `spec/services/lookup/unit_lookup_service_spec.rb` — **18 failures**

### Grinder Startup
Always run `./start_grinder.sh` first — it seeds the test database, clears cache, generates a fresh baseline log, and outputs the current top failing specs. Do not start grinding without running this first.

```bash
# On host — starts grinder pre-flight and generates fresh baseline
./start_grinder.sh
```


### Mandatory RSpec Command Form
```bash
# Inside the container (always use this path for output):
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

> ⚠️ **Log path mapping:**
> - **Inside container:** `/home/galaxy_game/log/`
> - **On host:** `./data/logs/`
> - See `docker-compose.dev.yml` for bind mount details.

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
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec --fail-fast --format documentation > ./log/rspec_full_$(date +%s).log 2>&1'
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
> ⚠️ **Full suite runs require user permission. Single spec runs on modified
> files are permitted autonomously as part of the fix-verify-commit cycle.
> See testing rules above.**
```

---

This is a clean, minimal change — two sections updated, nothing else touched. GPT-4.1 can apply it as an atomic commit to `docs/agent/README.md` with the message:
```
Update test execution rules for single-executor workflow

1. **ALWAYS** consult [ENVIRONMENT_BOUNDARIES.md](rules/ENVIRONMENT_BOUNDARIES.md) for command safety
2. Use [grok_notes.md](reference/grok_notes.md) task templates for workflow guidance
3. **NEVER** run Rails/Ruby commands on host — always use `docker exec -it web bash -c '...'
4. **Tileset/Map Rendering:** All new map and surface rendering code must use the JSON-based tileset system. Legacy FreeCiv/Civ4 asset pipelines are deprecated.

### Git Operations (Host Only)
- `git` commands are run on the **host**, not inside the container
- All other commands (Rails, rake, rspec, bundle) run **inside the container only** via `docker exec -it web`

## 🧪 Testing Requirements & Validation Rules

### 🟡 Test Execution Rules — Single Executor Sessions
When operating as the sole Executor agent (no other agents running concurrently),
GPT-4.1 MAY run RSpec autonomously as part of the fix-verify-commit cycle:

✅ **Permitted without asking:**
- Running specs for files you just modified
- Running the spec file in isolation to verify a fix
- Running the containing directory as a pollution check

❌ **Still requires user permission:**
- Running the full suite (`bundle exec rspec` with no path)
- Running specs on files you did not touch in this session
- Running tests during planning, review, or diagnosis work

When in doubt about scope: run the single spec file only and report results.

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

> ⚠️ **CRITICAL: ALWAYS UNSET DATABASE_URL BEFORE RUNNING RSPEC**
> Never run rspec without unsetting DATABASE_URL first.
> DATABASE_URL overrides RAILS_ENV=test and will point Rails at the 
> wrong database — potentially wiping your development database.
> 
> **CORRECT command format — no exceptions:**
> `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [spec_path] > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'`
> 
> **NEVER use:**
> `docker-compose exec web bundle exec rspec`  ← missing DATABASE_URL unset
> `docker exec web rspec`  ← missing DATABASE_URL unset and RAILS_ENV

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

## 🧩 Blueprint & Operational Data Creation Protocol

### Template Usage and File Creation
- **Templates are versioned and must NEVER be modified directly.**
- To create a new unit, craft, or other entity:
  1. **Copy** the appropriate template file (e.g., `unit_blueprint_v1.3.json`, `unit_operational_data_v1.3.json`) from the templates directory.
  2. **Rename** the copy to match the entity, using the naming convention:
     - Blueprints: `<entity>_bp.json` (e.g., `biomass_recycler_bp.json`)
     - Operational data: `<entity>_data.json` (e.g., `biomass_recycler_data.json`)
  3. **Edit only the new file** to fill in the required fields for the specific unit or craft. Do not alter the template structure unless the version is being incremented for all units.
  4. **Preserve all other template fields** as defaults unless otherwise specified by the spec or requirements.
- **Never update or commit changes to the template files themselves.**

### Example Workflow
1. Copy `data/json-data/templates/unit_blueprint_v1.3.json` → `data/json-data/blueprints/units/life_support/biomass_recycler_bp.json`
2. Copy `data/json-data/templates/unit_operational_data_v1.3.json` → `data/json-data/operational_data/units/life_support/biomass_recycler_data.json`
3. Edit only the new files to match the unit's requirements/spec.

> **Note:** This protocol ensures versioned templates remain pristine and all entity data is isolated to its own file, preventing accidental global changes.

---


## 🧪 RSpec Test Output Naming Protocol

- **Full suite runs:**
   - Output log file: `/home/galaxy_game/log/rspec_full_$(date +%s).log` (inside container)
   - Output log file: `./data/logs/rspec_full_$(date +%s).log` (on host)
   - Command example:
      docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
- **Subset/spec runs:**
   - Output log file: `/home/galaxy_game/log/rspec_[scope]_$(date +%s).log` (inside container)
   - Output log file: `./data/logs/rspec_[scope]_$(date +%s).log` (on host)
   - Command example:
      docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/ > /home/galaxy_game/log/rspec_ai_manager_$(date +%s).log 2>&1'
- **Never monitor live output:** Always redirect to log file and review after completion.
- **Always use descriptive log names for partial runs** to avoid confusion and maintain clear test records.

> **Log path mapping is controlled by the bind mount in `docker-compose.dev.yml` and related compose files.**
> Always check the compose file for the current mapping.

### 🔴 Mandatory Verify Step — Spec Changes

When modifying or rewriting any spec file, the following steps are
**mandatory before reporting completion or asking the user anything**:

1. Run the spec file in isolation and confirm 0 failures:
```bash
   docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [spec_path] > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```
2. If failures exist — fix them before reporting back. Do not ask the user
   to run tests. Do not report "done" with known failures.
3. If the same failure persists after two fix attempts — STOP and escalate
   to Claude with the exact error output and the current spec content.
   Do not make a third attempt.

**Never report a spec task complete without a green isolation run.**

---
