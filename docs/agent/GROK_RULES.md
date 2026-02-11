# GROK RULES - QUICK REFERENCE
**Purpose**: One-page summary of ALL rules you must follow. Keep this open while working.

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
✅ ALWAYS: rspec > ./log/rspec_full_$(date +%s).log 2>&1

❌ NEVER: Test against development database
✅ ALWAYS: unset DATABASE_URL && RAILS_ENV=test

✅ ALWAYS: Test inside Docker: docker exec -it web bash
✅ ALWAYS: Verify tests pass before committing
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

### Starting Work
1. ✅ Read GROK_CURRENT_WORK.md for current task
2. ✅ Read relevant reference docs for context
3. ✅ Enter Docker container: `docker exec -it web bash`
4. ✅ Update GROK_CURRENT_WORK.md status

### During Work
1. ✅ Make small, testable changes
2. ✅ Test each change in Docker
3. ✅ Log all test output
4. ✅ Ask if confused (don't guess)

### Finishing Work
1. ✅ Run full test suite (with logging)
2. ✅ Exit Docker container
3. ✅ Commit from host (specific files only)
4. ✅ Update GROK_CURRENT_WORK.md (mark complete)
5. ✅ Move task to COMPLETED_TASKS_ARCHIVE.md
6. ✅ Ask user what's next

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

### Enter Docker
```bash
docker exec -it web bash
```

### Run Tests (Inside Docker)
```bash
# Set environment
unset DATABASE_URL
export RAILS_ENV=test

# Run with logging
bundle exec rspec path/to/spec.rb > ./log/rspec_full_$(date +%s).log 2>&1

# Check results
echo $?  # 0 = pass, non-zero = fail
```

### Database Operations (Inside Docker)
```bash
# Reset and seed
rails db:reset
rails db:seed

# Console
rails console

# Check what was created
rails c -e "CelestialBodies::CelestialBody.count"
```

### Exit Docker & Commit (On Host)
```bash
# Exit Docker
exit

# On host machine
git status
git add path/to/specific/file.rb
git commit -m "[Component] Clear description"
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

