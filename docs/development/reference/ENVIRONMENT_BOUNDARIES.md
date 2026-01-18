# Environment Boundaries: Docker Container vs Host Machine
**Date:** January 16, 2026  
**Critical Reference:** Command Execution Rules

---

## [2026-01-17] Environment Safety Patch

### Mandatory Command Prefix for RSpec/Test Operations
**ALL RSpec/Test commands MUST use `unset DATABASE_URL`** to prevent environment bleed between development and test databases.

**❌ WRONG (causes data loss):**
```bash
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/models/account_spec.rb
```

**✅ CORRECT (safe):**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/account_spec.rb'
```

### The "Safety Check" - Pre-flight Database Verification
**BEFORE any destructive operation (RSpec, migrations, data operations), verify the database name:**

```bash
# Safety check - run this FIRST
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts ActiveRecord::Base.connection.current_database"'
# Expected output: galaxy_game_test
# ❌ If you see galaxy_game_development, STOP and fix environment first
```

### Log Path Mapping - Critical for Debugging
- **Container path:** `./log/` inside web container
- **Host path:** `./data/logs/` on host machine  
- **Volume mount:** `./data/logs:/home/galaxy_game/log` (from docker-compose.dev.yml)
- **Example:** Container writes to `./log/rspec_full_123456.log` → appears as `./data/logs/rspec_full_123456.log` on host

---

## The Golden Rules

### **Rule 1: Git Operations**
**NEVER run git commands inside the web docker container.**  
**ALWAYS run git commands on the host machine.**

### **Rule 2: Rails/RSpec Operations**
**NEVER run `bundle exec`, `rails`, or `rspec` directly on host.**  
**ALWAYS prefix with `docker-compose -f docker-compose.dev.yml exec web`**

### **Why This Matters**
- **Host system:** macOS with Ruby 2.x (or different version)
- **Web container:** Ruby 3.x with all gems, Rails app, PostgreSQL connection
- **Running on host = Guaranteed failure:** version mismatch, missing gems, no database

---

## ⚠️ CRITICAL: Common LLM Mistake

**LLMs will try to do this (WRONG):**
```bash
bundle exec rspec spec/models/account_spec.rb  # ❌ FAILS - wrong Ruby version
rails console                                   # ❌ FAILS - no Rails environment
rake db:migrate                                 # ❌ FAILS - no database connection
```

**You MUST do this instead (CORRECT):**
```bash
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/models/account_spec.rb  # ✅
docker-compose -f docker-compose.dev.yml exec web bundle exec rails console                      # ✅
docker-compose -f docker-compose.dev.yml exec web bundle exec rake db:migrate RAILS_ENV=test    # ✅
```

**If an LLM suggests a bare command, REJECT IT and demand the full docker-compose prefix.**

---

## Operation Boundaries Table

| Operation | Location | Command Example | What Happens If Run on Wrong Environment |
|-----------|----------|-----------------|------------------------------------------|
| **RSpec Tests** | ✅ CONTAINER | `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'` | Host: Ruby version mismatch, gems missing, DB connection fails. Container: DATABASE_URL causes environment bleed |
| **Rails Console** | ✅ CONTAINER | `docker-compose -f docker-compose.dev.yml exec web bundle exec rails c` | Host: Rails not found or wrong version, DB unreachable |
| **Rails Runner** | ✅ CONTAINER | `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner "puts Model.count"'` | Host: Rails environment missing, gems missing. Container: DATABASE_URL causes environment bleed |
| **Bundle Commands** | ✅ CONTAINER | `docker-compose -f docker-compose.dev.yml exec web bundle install` | Host: Installs gems for WRONG Ruby version |
| **Database Migrations** | ✅ CONTAINER | `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rake db:migrate'` | Host: Cannot connect to PostgreSQL container. Container: DATABASE_URL causes environment bleed |
| **Database Reset** | ✅ CONTAINER | `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rake db:reset'` | Host: Database connection error. Container: DATABASE_URL causes environment bleed |
| **Code Editing** | ✅ HOST | VS Code, vim, etc. on `/Users/tam0013/Documents/git/galaxyGame/` | Files mounted via volume |
| **Git Status** | ✅ HOST | `git status` | Git repo on host filesystem |
| **Git Add** | ✅ HOST | `git add galaxy_game/app/models/account.rb` | Git repo on host filesystem |
| **Git Commit** | ✅ HOST | `git commit -m "fix: restore Account model"` | Git repo on host filesystem |
| **Git Push** | ✅ HOST | `git push origin main` | Git repo on host filesystem |
| **Diff Files** | ✅ HOST | `diff current.rb data/old-code/galaxyGame-01-08-2026/current.rb` | Comparing host files |
| **Copy Files** | ✅ HOST | `cp data/old-code/backup.rb galaxy_game/app/models/` | Host filesystem operations |
| **Backup Files** | ✅ HOST | `cp file.rb tmp/pre_revert_backup/` | Host filesystem operations |
| **Documentation** | ✅ HOST | Edit `.md` files in `docs/` | Host filesystem operations |
| **Database Migrations** | ✅ CONTAINER | `docker-compose -f docker-compose.dev.yml exec web bundle exec rake db:migrate RAILS_ENV=test` | Rails/DB inside container |
| **Bundle Install** | ✅ CONTAINER | `docker-compose -f docker-compose.dev.yml exec web bundle install` | Gem installation inside container |
| **View Logs** | ✅ BOTH | Container: `cat log/test.log`<br>Host: `cat data/logs/rspec_full_*.log` | Logs accessible both places |

---

## Why This Matters

### **Git Inside Container = Disaster**

The web docker container:
- Has a **different user** (typically `root` or `app`)
- May not have git configured (name, email)
- Creates commits with **wrong author**
- May have **permission issues** writing to mounted volumes
- **Not persistent** - git config lost on container restart

### **The Correct Workflow**

```bash
# ❌ WRONG - Git inside container
docker-compose -f docker-compose.dev.yml exec web git add .
docker-compose -f docker-compose.dev.yml exec web git commit -m "fix"

# ✅ CORRECT - Git on host
git add galaxy_game/app/models/account.rb
git commit -m "fix: restore Account model balance methods"
```

---

## Nightly Grinder Protocol: Hybrid Operations

The autonomous nightly grinder must coordinate both environments:

### **Step 1: Identify Target (CONTAINER)**
```bash
# Inside container - parse RSpec logs
LATEST_LOG=$(ls -t data/logs/rspec_full_*.log | head -n 1)
grep "rspec ./spec" $LATEST_LOG | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -1
```

### **Step 2: Compare Files (HOST)**
```bash
# On host - diff current vs Jan 8 backup
diff galaxy_game/app/models/account.rb \
     data/old-code/galaxyGame-01-08-2026/galaxy_game/app/models/account.rb
```

### **Step 3: Backup Current (HOST)**
```bash
# On host - preserve current state
mkdir -p tmp/pre_revert_backup
cp galaxy_game/app/models/account.rb tmp/pre_revert_backup/
```

### **Step 4: Restore/Fix Code (HOST)**
```bash
# On host - restore from Jan 8 or edit surgically
cp data/old-code/galaxyGame-01-08-2026/galaxy_game/app/models/account.rb \
   galaxy_game/app/models/account.rb
```

### **Step 5: Test (CONTAINER)**
```bash
# Inside container - verify fix
docker-compose -f docker-compose.dev.yml exec web \
  bundle exec rspec spec/models/account_spec.rb
```

### **Step 6: Commit (HOST)**
```bash
# On host - atomic commit
git add galaxy_game/app/models/account.rb docs/models/ACCOUNT.md
git commit -m "fix: restore Account model balance methods - Jan 8 backup restoration"
git push origin main
```

---

## Grok Command Templates

### **Template: Nightly Grinder Cycle (Hybrid)**

```bash
"Grok, execute nightly grinder cycle with STRICT environment boundaries:

⚠️ CRITICAL REQUIREMENT: ALL Rails/RSpec commands MUST use full docker-compose prefix.
NEVER run 'bundle exec', 'rails', or 'rspec' directly on host - Ruby version mismatch will cause failure.

CONTAINER OPERATIONS (ALL must start with docker-compose prefix):
1. Parse latest log: ls -t data/logs/rspec_full_*.log | head -n 1  (host command - OK)
2. Run RSpec: docker-compose -f docker-compose.dev.yml exec web bundle exec rspec [spec_path]
3. Generate full suite log: docker-compose -f docker-compose.dev.yml exec web /bin/bash -c "RAILS_ENV=test bundle exec rspec > ./data/logs/rspec_full_$(date +%s).log 2>&1"

HOST OPERATIONS:
1. Diff files: diff current data/old-code/galaxyGame-01-08-2026/[path]
2. Backup: cp [file] tmp/pre_revert_backup/
3. Restore: cp data/old-code/[path] galaxy_game/[path]
4. Git add: git add [specific_files_only]
5. Git commit: git commit -m '[prefix]: [description]'

CRITICAL RULES:
- NEVER run git inside container
- ALWAYS test in container before commit
- ALWAYS commit from host after green tests
- AHost: Parse log to identify failing spec (ls/grep/awk - no Ruby needed)
2. Host: Diff current vs Jan 8 (diff command - no Ruby needed)
3. Host: Backup current state (cp command - no Ruby needed)
4. Host: Restore from Jan 8 or edit surgically (cp/editor - no Ruby needed)
5. Container: Run individual spec with FULL docker-compose prefix
6. IF GREEN: Host: git add + commit (git commands - no Ruby needed)
7. IF RED: Host: Revert backup, log failure
8. REPEAT

REMINDER: 
- Git operations MUST be on host
- RSpec MUST be in container with FULL docker-compose prefix
- NEVER run bare 'bundle exec' or 'rails' commands - they will fail on host
8. REPEAT

REMINDER: Git operations MUST be on host. RSpec MUST be in container."
```

### **Template: Manual Surgical Fix (Hybrid)**

```bash
"Grok, execute manual surgical fix with environment boundaries:

ANALYSIS (HOST):
- Compare: diff galaxy_game/app/services/[file] data/old-code/[file]
- Identify breaking changes vs improvements

BACKUP (HOST):
- mkdir -p tmp/pre_revert_backup
- cp galaxy_game/app/services/[file] tmp/pre_revert_backup/

FIX (HOST):
- Edit galaxy_game/app/services/[file]
- Restore ONLY broken methods from Jan 8
- Preserve post-Jan-8 improvements

TEST (CONTAINER):
- docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/services/[file]_spec.rb

DOCUMENT (HOST):
- Update docs/services/[FILE].md with fix explanation

COMMIT (HOST):
- git add galaxy_game/app/services/[file] docs/services/[FILE].md
- git commit -m 'fix: [description] - surgical restoration from Jan 8'

REMINDER: All git on host. All RSpec in container."
```

---

## Common Mistakes to Avoid

### ❌ **Mistake 1: Git Inside Container**
```bash
docker-compose exec web git commit -m "fix"
# Creates commit with wrong auth (Most Common LLM Error)**
```bash
# LLM tries to run directly on host
bundle exec rspec spec/models/account_spec.rb

# Error output:
# rbenv: version `3.2.2' is not installed
# OR: Gem::LoadError - cannot load such file -- rails
# OR: PG::ConnectionBad - could not connect to server

# Root cause: Wrong Ruby version, missing gems, no container database
```

**Why this fails:**
1. Host has Ruby 2.7.x (or different version)
2. Container has Ruby 3.2.2 with all gems installed
3. Container has PostgreSQL connection, host doesn't
4. Container has Rails app loaded, host doesn'tbash
bundle exec rspec spec/models/account_spec.rb
# Missing container database, gems, Rails environment
```

### ❌ **Mistake 3: Batch Commits**
```bash
git add .
git commit -m "fixes"
# Commits unrelated changes, violates atomic commit rule
```

### ❌ **Mistake 4: No Backup Before Restore**
```bash
cp backup.rb current.rb  # No backup of current state!
# If restore fails, current work lost
```

### ✅ **Correct Pattern**
```bash
# 1. Backup (host)
cp galaxy_game/app/models/account.rb tmp/pre_revert_backup/

# 2. Restore (host)
cp data/old-code/galaxyGame-01-08-2026/galaxy_game/app/models/account.rb \
   galaxy_game/app/models/account.rb

**⚠️ ALWAYS copy these commands EXACTLY - do NOT remove the docker-compose prefix**

### **Full RSpec Suite (Container)**
```bash
# Run full test suite and save to timestamped log
docker-compose -f docker-compose.dev.yml exec web /bin/bash -c \
  "RAILS_ENV=test bundle exec rspec > ./data/logs/rspec_full_$(date +%s).log 2>&1"

# ❌ WRONG - will fail on host
# bundle exec rspec > ./data/logs/rspec_full_$(date +%s).log
```

### **Individual Spec (Container)**
```bash
# Run single spec file
docker-compose -f docker-compose.dev.yml exec web \
  bundle exec rspec spec/models/account_spec.rb

# ❌ WRONG - will fail on host  
# bundle exec rspec spec/models/account_spec.rb
```

### **Rails Console (Container)**
```bash
# Open Rails console in test environment
docker-compose -f docker-compose.dev.yml exec web \
  bundle exec rails console -e test

# ❌ WRONG - will fail on host
# rails console
```

### **Database Operations (Container)**
```bash
# Reset test database
docker-compose -f docker-compose.dev.yml exec web \
  bundle exec rake db:reset RAILS_ENV=test

# Run migrations
docker-compose -f docker-compose.dev.yml exec web \
  bundle exec rake db:migrate RAILS_ENV=test

# ❌ WRONG - will fail on host
# rake db:migrate

## Quick Reference Commands

### **Full RSpec Suite (Container)**
```bash
docker-compose -f docker-compose.dev.yml exec web /bin/bash -c \
  "RAILS_ENV=test bundle exec rspec > ./data/logs/rspec_full_$(date +%s).log 2>&1"
```

### **Does command start with `docker-compose -f docker-compose.dev.yml exec web`?
- [ ] Did I verify this is NOT a bare `bundle exec` or `rails` command?
- [ ] Did I remember the host has a **different Ruby version** and will fail?

**For Git operations:**
- [ ] Am I running this on the **host machine**?
- [ ] NOT inside any docker container?
- [ ] Committing only the files I worked on this session?
- [ ] NOT using `git add .` (batch commits forbidden)?

**For File operations:**
- [ ] Did I **backup to tmp/pre_revert_backup/** before overwriting?
- [ ] Am I operating on **host filesystem** (files mounted to container)?
- [ ] Can I use normal shell commands (cp, mv, diff) without Ruby?

**For Documentation:**
- [ ] Did I update the corresponding `.md` file in `docs/`?
- [ ] Is the doc commit **bundled with the code commit**?

---

## Command Validation Test

**If an LLM suggests any of these commands, REJECT immediately:**

```bash
# ❌ ALL OF THESE WILL FAIL ON HOST
bundle exec rspec spec/models/account_spec.rb
rails console
rake db:migrate
rspec spec/
bundle install
rails runner "puts Account.count"
```

**Demand the LLM provide the correct containerized versions:**

```bash
# ✅ ALL OF THESE WORK (containerized)
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/models/account_spec.rb
docker-compose -f docker-compose.dev.yml exec web bundle exec rails console
docker-compose -f docker-compose.dev.yml exec web bundle exec rake db:migrate RAILS_ENV=test
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/
docker-compose -f docker-compose.dev.yml exec web bundle install
docker-compose -f docker-compose.dev.yml exec web bundle exec rails runner "puts Account.count"
```

---

## Docker Compose Architecture Reference

From `docker-compose.dev.yml`:

**Services:**
- `web` - Rails server (port 3000), Ruby 3.2.2, all gems installed
- `db` - PostgreSQL 16 container
- `redis` - Redis for Sidekiq/caching
- `sidekiq` - Background job worker

**Volumes (Host → Container):**
- `./galaxy_game` → `/home/galaxy_game` (Rails app code)
- `./data/json-data` → `/home/galaxy_game/app/data` (game data)
- `./data/logs` → `/home/galaxy_game/log` (log files)
- `./data/bundle` → `/usr/local/bundle` (gem cache)

**Why commands must run in container:**
1. Ruby 3.2.2 installed in container, not on host
2. All gems installed in `/usr/local/bundle` inside container
3. PostgreSQL running in `db` container, accessible only from `web` container
4. Rails app loaded in container's Ruby environment
5. Env vars loaded from `./env/.env.dev.local.app`

**Host system only has:**
- Git
- Docker/Docker Compose
- Text editor
- Shell (bash/zsh)
- macOS filesystem tools (cp, mv, diff)

**Host system does NOT have:**
- Correct Ruby version (or any Ruby)
- Rails gems
- PostgreSQL connection
- Redis connection
- Rails environment

---

**End of Boundaries Document**  
**Reference this document before EVERY nightly grinder run and manual fix session.**  
**If an LLM suggests a bare Rails/RSpec command, send them this document
### **Diff Current vs Jan 8 (Host)**
```bash
diff galaxy_game/app/models/account.rb \
     data/old-code/galaxyGame-01-08-2026/galaxy_game/app/models/account.rb
```

### **Atomic Commit (Host)**
```bash
git add galaxy_game/app/models/account.rb docs/models/ACCOUNT.md
git commit -m "fix: restore Account balance methods"
git push origin main
```

---

## Summary Checklist

Before executing any operation, ask:

**For RSpec/Rails operations:**
- [ ] Am I running this **inside the web docker container**?
- [ ] Using `docker-compose -f docker-compose.dev.yml exec web`?

**For Git operations:**
- [ ] Am I running this on the **host machine**?
- [ ] NOT inside any docker container?
- [ ] Committing only the files I worked on this session?

**For File operations:**
- [ ] Did I **backup to tmp/pre_revert_backup/** before overwriting?
- [ ] Am I operating on **host filesystem** (files mounted to container)?

**For Documentation:**
- [ ] Did I update the corresponding `.md` file in `docs/`?
- [ ] Is the doc commit **bundled with the code commit**?

---

**End of Boundaries Document**  
**Reference this document before EVERY nightly grinder run and manual fix session.**
