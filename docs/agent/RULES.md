# GROK RULES - QUICK REFERENCE
**Purpose**: One-page summary of ALL rules you must follow. Keep this open while working.

---

## 👤 Which Agent Are You?

**Read this first.** Your role determines what you can do.

| | Planner Agent | Executor / Grinder Agent |
|---|---|---|
| Edit files | ✅ | ✅ |
| Run git commands (host) | ✅ | ✅ |
| Run RSpec | ❌ Never | ✅ When assigned |
| Run docker exec commands | ❌ Never | ✅ |
| Restart containers | ❌ Never | ❌ Never |
| Use docker-compose exec | ❌ Never | ❌ Never |

**If you are a Planner:** your job ends at writing correct task files. You do not verify, test, or execute anything.  
**If you are an Executor:** your loop is fix → test → fix → test → green → commit → update docs.

---

## 🚨 CRITICAL RULES (Never Break These)

### Git & Commits
```bash
❌ NEVER: git add .
✅ ALWAYS: git add path/to/specific/file.rb

❌ NEVER: Commit inside Docker container
✅ ALWAYS: Commit from host machine

✅ ALWAYS: Atomic commits (one logical change per commit)
✅ ALWAYS: Descriptive commit messages
```

### Testing
```bash
❌ NEVER: Run tests without logging
❌ NEVER: Test against development database
❌ NEVER: Use docker-compose exec for tests (corrupts dev db)
❌ NEVER: Split unset/export/rspec across separate lines in automation

✅ ALWAYS: Single chained command via docker exec
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec path/to/spec.rb > ./log/rspec_full_$(date +%s).log 2>&1'

✅ ALWAYS: Verify before committing
docker exec -it web bash -c 'echo $?'  # 0 = pass
```

### Code Quality
```ruby
❌ NEVER: Hardcoded paths
      BAD:  "app/data/geotiff/earth.tif"
✅ ALWAYS: Path constants
      GOOD: GalaxyGame::Paths::GEOTIFF_DIR

❌ NEVER: Break namespaces
      BAD:  class Location (conflicts with Location::SpatialLocation)
✅ ALWAYS: Fully qualified names
      GOOD: class CelestialBodies::Planets::Rocky::TerrestrialPlanet
```

### AI Manager & Economics
```ruby
❌ NEVER: Create infinite resources
❌ NEVER: Allow AI to bypass economic rules
❌ NEVER: Modify AI Manager boundaries without permission
✅ ALWAYS: Check GUARDRAILS.md for economic limits
```

---

## 📋 WORKFLOW RULES

### Starting Work — Planner Agent
1. ✅ Read GROK_CURRENT_WORK.md for current task
2. ✅ Read relevant reference docs for context
3. ✅ Update GROK_CURRENT_WORK.md status
4. ❌ Do NOT enter Docker — write task files and hand off to Executor

### Starting Work — Executor / Grinder Agent
1. ✅ Read assigned task file completely
2. ✅ Confirm you understand the fix required and the test commands
3. ✅ All commands run via `docker exec -it web bash -c '...'` — containers are already running
4. ✅ Update GROK_CURRENT_WORK.md status

### During Work — Executor Loop
1. ✅ Make targeted code change
2. ✅ Run RSpec via `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'`
3. ✅ Log output checked — fix failures, repeat until green
4. ✅ Ask if confused — don't guess at architecture

### Finishing Work — Executor
1. ✅ Full relevant spec suite passes (logged)
2. ✅ Commit from **host** (specific files only, never `git add .`)
3. ✅ Update GROK_CURRENT_WORK.md (mark complete)
4. ✅ Update any docs specified in task CRITICAL CONSTRAINTS
5. ✅ Ask user what's next

---

## 🗂️ DOCUMENT HIERARCHY (What to Read When)

### PRIMARY (Read First - Your Instructions)
1. **GROK_CURRENT_WORK.md** ← Start here every session
   - What you're working on RIGHT NOW
   - Clear task description and steps
   - Testing instructions

### RULES (Follow Always)
2. **GROK_RULES.md** ← This file (keep open)
   - Quick reference while working
   
3. **./rules/GUARDRAILS.md** ← When working on AI/Economics
   - AI Manager behavior boundaries
   - Economic system limits
   - Architecture integrity rules

4. **./rules/CONTRIBUTOR_TASK_PLAYBOOK.md** ← When doing git/testing
   - Detailed git workflow
   - Testing protocols
   - Environment setup

5. **./rules/ENVIRONMENT_BOUNDARIES.md** ← When working in containers
   - What you can/can't do in Docker
   - Safety protocols

### REFERENCE (Read for Context Only)
6. **./reference/GAME_DESIGN_INTENT.md** ← When confused about "why?"
   - What the game is supposed to be
   - Design principles
   - Common questions answered

7. **./reference/COMPLETED_TASKS_ARCHIVE.md** ← When wondering "what's done?"
   - Historical record
   - DON'T re-do these tasks

8. **./TASK_PROTOCOL.md** ← When creating new tasks
   - Standardized task creation format
   - Agent role definitions and coordination

---

## 🎯 DECISION FLOWCHART

```
Starting a session?
  ↓
Read GROK_CURRENT_WORK.md
  ↓
Is the task clear?
  ├─ YES → Start working (follow rules above)
  └─ NO → Read reference docs, then ASK USER
           ↓
  Working on code?
    ↓
  Does it involve AI/Economics?
    ├─ YES → Check GUARDRAILS.md first
    └─ NO → Continue
         ↓
  Ready to commit?
    ↓
  Did tests pass (with logs)?
    ├─ YES → Commit from host
    └─ NO → Fix, test again
         ↓
  Task complete?
    ├─ YES → Update docs, ask what's next
    └─ NO → Continue working
```

---

## 🚫 COMMON MISTAKES (Avoid These)

### Mistake 1: Working on Wrong Task
```
❌ Grok sees TASK_ARCHIVE_GEOTIFF_TERRAIN.md
   Grok thinks: "I should fix terrain generation!"
   
✅ Should do: Check GROK_CURRENT_WORK.md first
   Archive = already done, don't re-do
```

### Mistake 2: Treating Reference as Instructions
```
❌ Grok sees ARCHITECTURE_ANSWERS_FOR_GROK.md
   Grok thinks: "These are my tasks!"
   
✅ Should do: Read for context only
   Instructions come from GROK_CURRENT_WORK.md
```

### Mistake 3: Skipping Tests
```
❌ "Code looks good, I'll commit it"

✅ ALWAYS: Test → Log → Verify → Then commit
```

### Mistake 4: Mass Commits
```
❌ git add .
   git commit -m "fixed stuff"

✅ git add app/services/star_sim/system_builder_service.rb
   git commit -m "[StarSim] Fix STI type mapping for terrestrial planets"
```

### Mistake 5: Guessing Instead of Asking
```
❌ "I'm not sure if this breaks namespaces, but I'll try it"

✅ "I'm not sure if this breaks namespaces. Should I check GUARDRAILS.md 
    or ask you?"
```

---

## 💬 WHEN TO ASK FOR HELP

### ASK if:
- ❓ Current task is unclear
- ❓ Tests fail and you don't know why
- ❓ You're unsure which rule applies
- ❓ You found a new bug not listed in GROK_CURRENT_WORK.md
- ❓ Two approaches exist and you don't know which fits better

### DON'T ASK if:
- ✅ It's clearly explained in GROK_CURRENT_WORK.md
- ✅ It's a rule in GUARDRAILS.md (just follow it)
- ✅ It's in COMPLETED_TASKS_ARCHIVE.md (it's done)
- ✅ The testing command is provided (just run it)

---

## 📝 QUICK COMMAND REFERENCE

### Verify Database Before Starting (ALWAYS do this first)
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts ActiveRecord::Base.connection.current_database"'
# ✅ Expected: galaxy_game_test
# ❌ STOP if output is: galaxy_game_development
```

### Run Tests (Executor Only — inside container via docker exec)
```bash
# Full chained form — copy this exactly, adjust spec path
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec path/to/spec.rb > ./log/rspec_full_$(date +%s).log 2>&1'

# Fail-fast — stops at first failure, good for interactive sessions
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec --fail-fast --format documentation > ./log/rspec_full_$(date +%s).log 2>&1'

# Full suite — sequential to avoid connection pool exhaustion
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec --order defined > ./log/rspec_full_$(date +%s).log 2>&1'

# Full suite — limited parallel workers (if connection errors occur)
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test PARALLEL_WORKERS=2 bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'

# Easiest full suite — uses wrapper script
docker exec web bin/test > ./data/logs/rspec_full_$(date +%s).log 2>&1

# Check exit code (0 = all pass)
echo $?
```

> ⚠️ **Log path note**: `./log/` inside the container maps to `./data/logs/` on the host (see docker-compose.dev.yml volume mount). Both paths work — just be consistent when reading logs.

### If You See "Connection is Closed" Errors
Run sequentially to avoid connection pool exhaustion:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec --order defined --fail-fast=false > ./log/rspec_full_$(date +%s).log 2>&1'
```

### Rails Runner (inside container)
```bash
docker exec -it web bash -c 'bundle exec rails runner "puts SomeClass.count"'
```

### Database Operations (inside container)
```bash
docker exec -it web bash -c 'bundle exec rake db:reset db:seed'
```

### Rails Console (inside container)
```bash
docker exec -it web bash -c 'bundle exec rails console'
```

### Commit (on HOST — never inside docker exec)
```bash
git status
git add path/to/specific/file.rb
git commit -m "[Component] Clear description of fix"
git push origin main
```

---

## 🎓 REMEMBER

**Your job is to**:
- ✅ Follow the rules exactly
- ✅ Complete the current task in GROK_CURRENT_WORK.md
- ✅ Test thoroughly before committing
- ✅ Ask when confused

**Your job is NOT to**:
- ❌ Decide what to work on (user decides)
- ❌ Skip rules because they're inconvenient
- ❌ Re-do completed tasks
- ❌ Guess instead of asking

**When in doubt**: READ GROK_CURRENT_WORK.md

