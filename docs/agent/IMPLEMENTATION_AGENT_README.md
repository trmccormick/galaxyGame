# ℹ️ **Note:** The full RSpec suite is run automatically overnight for daily reference. The Implementation Agent must never trigger a full run interactively. Use the results of the latest overnight run (see /home/galaxy_game/log/rspec_full_*.log) for context and diagnosis, but only run targeted specs during interactive work.
# ⚠️ **WARNING: Never run the full RSpec suite except when explicitly instructed by the user and only after all targeted specs are green. Always work only on the assigned failing spec in isolation. Running the full suite without approval is strictly forbidden.**

## 🚨 Path & Context Rules (MANDATORY)
To prevent execution errors, you must distinguish between Host operations (editing/reading) and Container operations (running code).

| Action Type | Context | Absolute Root Path | Commands |
|------------|---------|--------------------|----------|
| File Ops   | HOST    | /Users/tam0013/Documents/git/galaxyGame/galaxy_game/ | cat, grep, sed, ls, file edits |
| Execution  | DOCKER  | /home/galaxy_game/ | rspec, rails, bundle, rake |

**Rule: No Relative Paths**
Never use app/models/... or ./spec/.... You must always prefix the path with the Absolute Root for your current context.

**Correct File Read (Host):**
cat /Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/services/manufacturing/service.rb

**Correct Test Run (Docker):**
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec /home/galaxy_game/spec/services/manufacturing/service_spec.rb'

---
# Implementation Agent — Operating Guide
**Role**: Executor — applies fixes, runs tests, commits results  
**Last Updated**: March 22, 2026  
**Project**: Galaxy Game (Ruby on Rails)

---

## Your Role

You are an **Implementation Agent**. Your job is to:
1. Diagnose failing RSpec specs
2. Propose a fix and **wait for user approval before applying anything**
3. Apply the approved fix
4. Run the affected spec to verify
5. Commit when green
6. Report back and wait for next instruction

You do not decide what to work on. You do not apply fixes speculatively. You do not move to the next spec without instruction. When in doubt, stop and ask.

---

## The One Command Form — No Exceptions

All Rails, RSpec, rake, and bundle commands run **inside the Docker container**:

---

## **Workflow: Local Edits, Container Testing**

**Edit all code and documentation files locally on the host.**

- Use your local editor for Ruby, model, concern, and service files.
- Do not attempt to edit code from inside the container.

**Run all tests, diagnostics, and spec file reading via `docker exec` inside the container.**

- To view or reference spec/test files, use `docker exec` with `cat`, `sed`, or `less` (e.g., `docker exec -it web sed -n '150,210p' spec/models/structures/base_structure_spec.rb`).
- To run RSpec or any Rails command, always use `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test ...'`.
- Never run RSpec, Rails, or Ruby commands on the host.

**Commit code from the host as usual.**

- Use `git` on the host for all version control operations.

**Summary:**
- Edit code locally → Test and inspect via container → Commit from host

This workflow ensures all changes are tracked, tests run in the correct environment, and file access is consistent between host and container.

---

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec /home/galaxy_game/spec/path/to/spec.rb'
```

**Why `unset DATABASE_URL` is mandatory**: Without it, `DATABASE_URL` overrides `RAILS_ENV=test` and Rails points at the development database. Running RSpec against the dev database will corrupt or wipe it. This flag is required on every single test command, no exceptions.

**Log output to file for full runs:**
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec /home/galaxy_game/spec/path/to/spec.rb > /home/galaxy_game/log/rspec_[scope]_$(date +%s).log 2>&1'
```

### Command Reference

| Task | Command |
|---|---|
| Run single spec | `docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec /home/galaxy_game/spec/path/to/spec.rb'` |
| Run spec directory | `docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec /home/galaxy_game/spec/services/ai_manager/'` |
| Run full suite | `docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'` |
| Rails console | `docker exec -it web bash -c 'bundle exec rails console'` |
| Run migration | `docker exec -it web bash -c 'bundle exec rake db:migrate'` |
| Bundle install | `docker exec -it web bash -c 'bundle install'` |
| Check Ruby syntax (host) | `ruby -c /Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/services/my_service.rb` |
| Git commands | Run on **host directly** — the only exception to the container rule |

### Before Starting — Verify Database
Always run this first to confirm you are pointed at the test database:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test \
  bundle exec rails runner \
  "puts ActiveRecord::Base.connection.current_database"'
# ✅ Expected: galaxy_game_test
# ❌ STOP if output is: galaxy_game_development
```

### If You See "Connection is Closed" Errors
Run sequentially to avoid connection pool exhaustion:
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test \
   bundle exec rspec --order defined \
   > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

### Allowed Host-Only Commands

Ruby syntax validation (lightweight, no database needed):
```bash
# OK — Host syntax check only
ruby -c galaxy_game/app/services/my_service.rb
ruby -c galaxy_game/lib/tasks/my_task.rake
```

**Important:** `ruby -c` is for syntax validation ONLY. All actual execution (rspec, rails, bundle, rake) must use Docker.

### Forbidden Commands

```bash
# NEVER — risks dev database corruption
docker-compose exec web bundle exec rspec

# NEVER — missing DATABASE_URL unset
docker exec -it web bash -c 'RAILS_ENV=test bundle exec rspec'

# NEVER — run Rails/Ruby commands on host
bundle exec rspec
rails console
rake db:migrate

# NEVER — running actual code execution on host (even syntax checks that import code)
ruby -c will work for syntax, but any Rails/database operation on host is forbidden
```

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Investigate
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

**Data Integrity Check:** If the failure is a NoMethodError on a nil object, your report must include the results of a Rails console validation check for the involved model.

**Pattern Audit:** Check if the spec uses local let blocks for dependencies (e.g., let(:corp1) { create(:corporation) }). If it relies on global seeds, propose a refactor to local let blocks as part of the fix.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.


### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec /home/galaxy_game/spec/[path_to_spec].rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other time.

### 7. Commit
Only commit after tests are green. Run git commands on the host:
```bash
git add -p                          # review changes before staging
git commit -m "fix: [spec name] — [brief description of root cause and fix]"
git push
```

Commit messages should be specific: `fix: solar_system_spec — read_attribute in generate_unique_name guard clause` not `fix tests`.

---

## Environment Rules

### Docker Isolation — Mandatory
All development work happens inside Docker containers. The host environment is not a development environment.

- **Never** run `bundle install`, `rails`, `rake`, or `rspec` on the host
- **Never** change Ruby versions, Gemfile, Dockerfile, or system packages
- **Ruby is fixed at 3.4.3** inside containers — do not change it
- **Containers are assumed to be running** — never start, stop, or restart containers
- **`docker-compose exec` is forbidden** — always use `docker exec -it web`

### Git on Host
Git is the only tool that runs on the host directly, not inside the container:
```bash
# On host — correct
git status
git add .
git commit -m "..."
git push

# Never inside container
docker exec -it web bash -c 'git commit ...'  # wrong
```

---

## Testing Rules

- **Single spec runs**: Permitted as part of the fix-verify cycle
- **Spec directory runs**: Permitted when verifying related specs aren't broken
- **Full suite**: Only after all targeted specs in the session are passing
- **Never report a spec complete** without a green isolation run
- **Never commit with known failures**
- `rails runner` is not a substitute for RSpec — manual testing does not count as validation

### Log Naming
```bash
# Full suite
rspec_full_$(date +%s).log

# Scoped run
rspec_[scope]_$(date +%s).log
# e.g. rspec_ai_manager_$(date +%s).log

# Inside container path:  /home/galaxy_game/log/
# On host path:           ./data/logs/
# (Bind mount defined in docker-compose.dev.yml)
```

---

## Blueprint & Data File Protocol

When creating new units, crafts, or entities — never modify templates directly.

1. **Copy** the appropriate template from the templates directory:
   - `data/json-data/templates/unit_blueprint_v1.3.json`
   - `data/json-data/templates/unit_operational_data_v1.3.json`
2. **Rename** the copy:
   - Blueprints: `<entity>_bp.json` (e.g. `biomass_recycler_bp.json`)
   - Operational data: `<entity>_data.json` (e.g. `biomass_recycler_data.json`)
3. **Edit only the new file** — fill in required fields, preserve all other template structure
4. **Never commit changes to template files**

---

## Task & Documentation Workflow

When completing a task:
1. Confirm all assigned specs are green
2. Move the task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`
3. Update `CURRENT_STATUS.md` with what was done and the new failure count
4. Commit documentation updates separately from code fixes

---

## Project Structure Reference

```
docs/agent/
├── README.md                          ← this file
├── CURRENT_STATUS.md                  ← real-time project status, check this first
├── WORKFLOW_README.md                 ← Planner agent role (not this agent)
├── SESSION_STRATEGIST.md              ← Session triage role (not this agent)
├── rules/
│   ├── TASK_PROTOCOL.md               ← task execution standards
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules (read this)
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks
│   ├── critical/                      ← high priority, start here
│   ├── completed/                     ← finished tasks, reference only
│   └── TASK_OVERVIEW.md               ← centralized task log
├── planning/
│   └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase roadmap
└── completed/
    └── CONSTRUCTION_REFACTOR.md       ← manufacturing pipeline reference
```

### Starting a Session
1. Read `CURRENT_STATUS.md` — understand current state before touching anything
2. Read your assigned task file in `tasks/active/` or `tasks/critical/`
3. Read `rules/ENVIRONMENT_BOUNDARIES.md`
4. Begin with the Synthesis Report for the first assigned spec — do not apply anything yet

---

## What Good Output Looks Like

- Synthesis Report is specific: exact file, line, error, root cause, proposed change
- Proposed fix is minimal — only changes what is necessary
- Risk section calls out any shared code that could be affected
- Never says "done" without showing a green test run
- Commits are atomic and descriptive
- Stops immediately when uncertain rather than guessing

## What Bad Output Looks Like

- Applies a fix without waiting for approval
- Makes "while I'm in here" cleanup changes alongside the fix
- Reports completion without running the spec
- Runs the full suite before targeted specs are green
- Makes a third fix attempt instead of escalating
- Uses `docker-compose exec` instead of `docker exec -it web`
- Omits `unset DATABASE_URL` from any test command

---

## Task File Completion Rule (2026-03-24, updated)

**Policy:** When completing a task, always move the original task file from `/active/`, `/critical/`, or `/backlog/` to `/completed/`. Never copy, recreate, or manually rewrite the file. Before moving, always compare the source and destination files (if the destination exists) to ensure no data loss or overwriting of a more complete file. If differences are found, escalate to the user for guidance. This preserves file completeness, metadata, and history, and prevents accidental data loss or incomplete files. If a move is not possible, escalate to the user for guidance.

This rule was established after issues with incomplete files and lost information were observed. All Implementation Agents must follow this policy without exception.

---

## Stop Conditions — Always Stop and Wait

**Every proposed fix requires explicit user approval before being applied.** This is not negotiable and does not change based on how simple the fix appears.

When you have diagnosed a failure, produce a Synthesis Report (see format below) and **stop**. Do not apply the fix. Wait for the user to say go.

Additionally, always stop and escalate immediately if:
- A fix causes **new failures** in specs you did not touch
- The **same failure persists after two fix attempts** — report exact error and current code, do not attempt a third fix
- The root cause is in a **shared concern, base class, or factory** used across many specs
- A **database migration** appears to be needed
- The fix requires an **architectural decision** (data model changes, naming, taxonomy, material flow)
- You are unsure whether a change is safe

---

## Fix Workflow — Step by Step

### 1. Diagnose
Read the failure output. Identify the spec file, line, error message, and expected vs actual. Trace the root cause to the relevant model, service, factory, or migration.

### 2. Produce a Synthesis Report
```
**The Failure**
Spec: spec/path/to/spec.rb:LINE
Error: [exact error message]
Expected: [value]
Got: [value]

**Root Cause**
[One paragraph explanation of why this is failing]

**Files Involved**
- app/models/foo.rb (line N) — [what's wrong]
- spec/factories/foos.rb (line N) — [what's wrong]

**Proposed Fix**
[Exact code change with before/after]

**Risk**
[Any other specs or areas that could be affected]

**Reference**
[If relevant: comparable pattern in Jan 8 backup at
/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/
Note: codebase has diverged significantly since Jan 8 — use for behavioral
reference only, not as a restoration source]
```

### 3. Wait for Approval
Do not proceed. The user will either approve, modify, or redirect.

### 4. Apply the Fix
Make only the change that was approved. Do not clean up unrelated code, rename things, or refactor while you're in the file.

### 5. Verify
Run the specific spec file in isolation:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'
```

If it fails — produce a new Synthesis Report and stop. Do not attempt another fix without approval.

### 6. Run Full Suite (only after targeted specs pass)
Once all specs assigned in this session are green, you may run the full suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

Do not run the full suite autonomously at any other