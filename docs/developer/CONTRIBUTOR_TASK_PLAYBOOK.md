# Galaxy Game: Contributor Task Playbook

Purpose: Provide small, assignable task templates with exact commands, guardrails, and acceptance criteria for reliable maintenance and recovery.

## [2026-01-17] Environment Safety Patch

### ⚠️ CRITICAL: Mandatory Session Start Protocol
**BEFORE doing ANYTHING in this session:**

1. ✅ Read ENVIRONMENT_BOUNDARIES.md
2. ✅ Read the relevant sections of this playbook (GROK_TASK_PLAYBOOK.md)
3. ✅ Acknowledge you've read and will follow all git rules

#### Non-Negotiable Git Rules:
- ONLY commit files you directly created/modified in this session
- NEVER use `git add .` or `git add -A` 
- ALWAYS run `git status` before committing
- BACKUP files are NEVER committed (*.old*, *.new*, *.bak, etc.)
- LOG files are NEVER committed
- ZIP/DATA files are NEVER committed

**Any violation results in session termination.**

### ⚠️ CRITICAL: Mandatory Test Logging Protocol
**ALL RSpec test runs MUST be logged to preserve results for analysis and prevent redundant execution.**

**❌ NEVER run tests without logging:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec'
# This wastes time - results are lost forever!
```

**✅ ALWAYS log test runs:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'
# Results saved to ./log/rspec_full_[timestamp].log (maps to host ./data/logs/)
```

**Why this matters:**
- **Efficiency:** Analyze one logged run multiple times instead of re-running tests
- **Collaboration:** Other tasks can access recent test results without regeneration
- **Debugging:** Full failure context preserved for detailed analysis
- **Progress Tracking:** Historical failure counts and patterns maintained

### Mandatory Command Prefix
**ALL RSpec/Test commands MUST use `unset DATABASE_URL`** to prevent environment bleed between development and test databases.

**❌ WRONG (causes data loss):**
```bash
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/models/account_spec.rb
```

**✅ CORRECT (safe):**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/account_spec.rb'
```

### The "Safety Check" - Pre-flight Requirement
**BEFORE any destructive operation (RSpec, migrations, data operations), verify the database name:**

```bash
# Safety check - run this FIRST
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts ActiveRecord::Base.connection.current_database"'
# Expected output: galaxy_game_test
# ❌ If you see galaxy_game_development, STOP and fix environment first
```

### Log Mapping - Explicit Documentation
- **Container path:** `./log/` inside web container
- **Host path:** `./data/logs/` on host machine  
- **Volume mount:** `./data/logs:/home/galaxy_game/log` (from docker-compose.dev.yml)
- **Example:** Container writes to `./log/rspec_full_123456.log` → appears as `./data/logs/rspec_full_123456.log` on host

## Always-On Guardrails
- Atomic Commits: Only stage fixed code + its docs. Never `git add ..`.
- Backup First: Copy changed files to `tmp/pre_revert_backup/` before overwriting from the Jan 8 backup.
- Documentation Mandate: A fix is "Done" only when `/docs` reflects the new logic/state.
- Host vs Container: Host runs git/backup; container runs rspec and app commands.
- **Environment Protection:** Do NOT restart, rebuild, or stop Docker containers without explicit user permission, unless operating in autonomous "Grinder" mode. Assume containers are running correctly in interactive sessions.

## Container Operations Protocol

### 🚫 Prohibited in Interactive Mode
- `docker-compose down`, `docker-compose up`, `docker-compose restart`
- `docker stop`, `docker rm`, `docker build`
- Any container lifecycle operations

### ✅ Permitted in Interactive Mode  
- `docker-compose ps` - check status
- `docker-compose logs` - inspect logs
- `docker exec` - run commands inside running containers
- Database queries and test execution

### 🤖 Permitted in Grinder Mode
- Full container lifecycle management for batch processing
- Automated restarts as part of scripted workflows
- Must log all actions and provide rollback instructions

### 🔍 Pre-Operation Checklist
**BEFORE suggesting any container operation:**
1. Ask: "Are the containers currently running?"
2. Check: `docker-compose ps` 
3. Confirm: User explicitly approves any disruptive operations
4. Document: Any container changes in commit messages

## Log Path Reference
- **Host path:** `./data/logs/` - All RSpec logs stored here
- **Container path:** `/home/galaxy_game/log` - Inside container, mapped to host `./data/logs/`
- **Volume mount:** `./data/logs:/home/galaxy_game/log` (from docker-compose.dev.yml)

```bash
# Host - Check logs
ls -t ./data/logs/rspec_full_*.log

# Container - Write logs (mapped to host ./data/logs/)
docker exec -it web bash -c 'bundle exec rspec > ./log/rspec_full_$(date +%s).log'
```

## Container Path Map (web container)
- Repo root mount: `/home/galaxy_game` (this is the `./galaxy_game` folder on host)
- Data mount: `/home/galaxy_game/app/data` (this is `./data/json-data` on host)
- Scripts: `/home/galaxy_game/scripts`
- Logs: `/home/galaxy_game/log`

Examples (inside container, cwd `/home/galaxy_game`):
- Ruby scripts: `ruby json-build-scripts/star_system_validator.rb --input app/data/star_systems/alpha_centauri.json`
- Rails runner: `bundle exec rails runner scripts/local_bubble_expand.rb --dir app/data/star_systems`

## Pre-flight Checks (Run BEFORE any protocol)

### Database Environment Verification
**Critical:** Test database issues cause deadlocks, incomplete logs, and unreliable results.

```bash
# Verify test database is accessible and properly configured
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts ActiveRecord::Base.connection.current_database"'
# Expected output: galaxy_game_test
```

If output shows `galaxy_game_development` or errors occur:
1. Run database environment fix: `sh ./scripts/fix_test_database_url.sh`
2. Verify test database has seed data: `sh ./scripts/prepare_test_database.sh`
3. Always use test wrapper: `docker exec -it web bin/test` OR `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec'`

### Test Environment Health Check
```bash
# Verify no deadlocks or hanging connections
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "ActiveRecord::Base.connection.execute(\"SELECT COUNT(*) FROM pg_stat_activity WHERE datname='\''galaxy_game_test'\''\")"'

# Clear any stale test data
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails db:test:prepare'
```

### Factory Verification
Common issue: Missing or renamed factories cause cascading failures.

```bash
# List all available factories
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts FactoryBot.factories.map(&:name).sort.join(\"\n\")"'
```

Known factory mapping (as of 2026-01-17):
- ✅ Use `:base_unit` not `:unit`
- ✅ Currency seeding must complete before financial tests

---

## Common Blockers & Solutions

### Database Deadlock During Test Runs

**Symptoms:**
- PostgreSQL deadlock errors during DatabaseCleaner truncation
- Tests hang or fail with "could not obtain lock" messages
- Full suite cannot complete due to truncation conflicts

**Root Cause:** DatabaseCleaner's `:truncation` strategy can cause deadlocks when:
- Tests run in parallel
- Foreign key constraints create circular dependencies
- Long-running transactions hold locks

**Solutions (try in order):**

1. **Switch to Deletion Strategy:**
```ruby
# spec/rails_helper.rb or spec/support/database_cleaner.rb
config.before(:suite) do
  DatabaseCleaner.strategy = :deletion  # Instead of :truncation
  DatabaseCleaner.clean_with(:deletion)
end
```

2. **Disable Parallel Tests:**
```bash
# Force sequential execution
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec --no-parallel'
```

3. **Use Transaction Strategy for Most Tests:**
```ruby
config.before(:each) do
  DatabaseCleaner.strategy = :transaction
end

config.before(:each, type: :feature) do
  DatabaseCleaner.strategy = :deletion  # Only for specs that need it
end
```

4. **Check for Stuck Connections:**
```sql
-- Find and kill stuck connections
SELECT pg_terminate_backend(pid) FROM pg_stat_activity 
WHERE datname = 'galaxy_game_test' AND state = 'idle in transaction';
```

**Prevention:**
- Always use `unset DATABASE_URL` before test runs
- Avoid manual database operations during test execution
- Use transactions when possible, deletion/truncation only when necessary

**Real-World Example (Jan 18, 2026):**
- Fixed segment_covering_service_spec.rb (12 failures → 0)
- Fixed precursor_capability_service_spec.rb (18 failures, solid surface detection)
- Hit database deadlock blocker during full suite run
- Stopped redundant test runs, diagnosed issue, applied deletion strategy

---

## Protocols

### 1) Autonomous Nightly Grinder Protocol (ANGP)
Use when you want fully automated overnight triage + documentation.

**MANDATORY LOGGING REQUIREMENT:** Every test run must be logged. Never run tests without `> ./log/rspec_full_$(date +%s).log 2>&1`

**PREREQUISITE:** Run Pre-flight Checks first to avoid incomplete logs!

**EFFICIENCY MANDATE:** Run the full suite ONCE with logging, then analyze that saved log multiple times. Do NOT run the suite again until you've fixed 3-5 specs from the same log analysis.

**❌ WASTEFUL (Don't do this):**
```bash
# Running multiple full suites just to check progress
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec | tail -20'  # 10-20 min
# Fix one spec
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec | tail -20'  # Another 10-20 min
# This wastes hours on redundant test runs!
```

**✅ EFFICIENT (MANDATORY LOGGING):**
```bash
# Run ONCE with logging (MANDATORY - always do this)
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'

# Analyze that log multiple times (seconds, not minutes)
LATEST_LOG=$(ls -t ./log/rspec_full_*.log | head -1)
grep "rspec ./spec" $LATEST_LOG | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -5

# Fix #1, commit
# Then re-analyze SAME log for next target (no rerun needed)
grep "rspec ./spec" $LATEST_LOG | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -5

# After fixing 3-5 specs, THEN run a fresh logged full suite
```

**Time Savings:** Analyzing one log 5 times = 10 seconds. Running suite 5 times = 50-100 minutes.

**Real-World Example (Jan 18, 2026 Session):**
- ❌ Grok ran multiple full suites without logging → Only fixed 2 specs in hours
- ✅ After correction: Fixed 2 specs, attempted 1 more, then hit blocker
- Lesson: Even with blocker, saved time for debugging instead of wasting it on redundant runs

**When You Hit a Blocker (e.g., Database Deadlock):**
1. STOP running full suites immediately
2. Diagnose blocker with targeted individual specs
3. Fix blocker issue (see Common Blockers section)
4. Resume with fresh logged run
5. Don't waste time running broken suites repeatedly

- Identify Latest Log:
```bash
# Host
LATEST_LOG=$(ls -t data/logs/rspec_full_*.log 2>/dev/null | head -n 1)
echo "Latest log: $LATEST_LOG"
```
- Extract top failing spec:
```bash
# Host
grep "rspec ./spec" "$LATEST_LOG" | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -1 | awk '{print $2}'
```
- If missing log, run full suite:
```bash
# Container (MANDATORY: output goes to /home/galaxy_game/log which maps to host ./data/logs/)
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'
```
- Compare failing code vs backup:
```bash
# Host
ls -la /Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026
```
- Document (MANDATORY): Update/create matching doc in `/docs` detailing Restored Logic, Market/GCC vars (tax_rate, exchange_fee), and alignment with Super‑Mars/Alpha Centauri intent.
- Fix & Verify one file at a time:
```bash
# Container
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [path_to_spec]'
```
- Atomic commit:
```bash
# Host
git add [fixed_files] [updated_docs]
git commit -m "fix: [short] — code + docs"
```

### 2) Interactive Quick‑Fix Protocol (IQFP)
Use for precision collaboration; produces a Synthesis Report, then awaits approval.

- Triage latest log (see ANGP Identify Latest Log).
- Gap Analysis: Compare failing file with Jan 8 backup and intent docs in `/docs`.
- Synthesis Report: include The Failure, The Discrepancy, Documentation Plan.
- Hold: Await approval before applying code or committing.

### 3) Big Fish Diagnostic & Doc Audit (BFDDA)
Heat‑map failures and check documentation coverage.

- Top 5 failing specs:
```bash
# Host
LOG_DIR="log"   # or "data/logs"
LATEST_LOG=$(ls -t "$LOG_DIR"/rspec_full_*.log 2>/dev/null | head -n 1)
grep "rspec ./spec" "$LATEST_LOG" | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -5
```
- For #1 failure: Check core file(s) vs Jan 8 backup.
- Doc Check: Verify matching doc in `/docs` exists and reflects current logic.
- Classify: Logic Regression (backup is better) vs Missing Documentation/Intent Gap.

### 4) Log & Environment Cleanup (LEC)
Keep workspace clean and context fresh.

- Archive logs (host):
```bash
mkdir -p ./log/archive && mv ./log/rspec_full_*.log ./log/archive/
# or for ol
- Clear RSpec cache (container):
```bash
docker-compose -f docker-compose.dev.yml exec web rm -f tmp/rspec_examples.txt
```
- Clear test database deadlocks (container):
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails db:test:prepare'
```
- Sync docs: Ensure `README.md` or system_architecture.md reflects current state.

### Current Status (2026-02-05)
- **✅ COMPLETED: Tug Construction Integration Test**
  - Full end-to-end validation of tug construction workflow
  - Mission profile loading, material procurement, orbital construction
  - Environmental adaptations, quality assurance, deployment
  - Test stable: 0 failures across multiple runs (4+ minutes execution)
  - Documentation updated in `docs/crafts/asteroid_relocation_tug_guide.md`
  - Mission profiles created: `l1_tug_construction_profile_v1.json` and manifest

- **✅ COMPLETED: Alio Tileset Surface View Integration**
  - FreeCiv Alio tileset (GPL-2.0+) integrated into Surface View rendering
  - Sci-fi planetary maps with burrow tubes, thermal vents, body-specific tile configurations
  - 25 RSpec examples, 0 failures, visual testing at /admin/celestial_bodies/3/surface?tileset=alio

- **Strategy:** Sequential task completion with full testing and documentation
- **Next:** Evaluate AI Manager learning patterns and terrain generation architecture

### Task Completion Log
Track progress here after each major task:

| Date | Task | Status | Notes |
|------|------|--------|-------|
| 2026-02-07 | Alio Tileset Surface View Integration | ✅ COMPLETED | 25 examples, 0 failures, sci-fi planetary rendering with burrow tubes |
| 2026-02-05 | Tug Construction Integration Test | ✅ COMPLETED | 4 examples, 0 failures, stable across runs |
| 2026-01-17 | Backup Restoration Session | ✅ COMPLETED | BaseSettlement, CelestialBody, BaseStructure factory fixes |
| 2026-01-17 | GameController/ShellPrintingJob Fixes | ✅ COMPLETED | 393 → 366 failures (-27) |

## bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails db:test:prepare'
```
- Sync docs: Ensure `README.md` or system_architecture.md reflects current state.

### 5) Database Deadlock Recovery (DDR)
Use when tests hang, fail with "database is locked", or produce incomplete logs.

**Symptoms:**
- RSpec suite stops mid-run
- Errors like "PG::TRDeadlockDetected" or "database deadlock detected"
- Multiple test sessions conflict
- Log files incomplete or truncated

**Recovery Steps:**
```bash
# 1. Kill all test processes (container)
docker exec -it web pkill -f rspec

# 2. Drop and recreate test database
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails db:drop db:create db:migrate'

# 3. Re-seed core data (Sol, planets, materials)
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails db:seed'

# 4. Verify database connection
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts CelestialBodies::CelestialBody.count"'
# Expected: 14 (core celestial bodies)

# 5. Run clean test suite (MANDATORY: with logging)
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'
```
# Note: Container ./log/ maps to host ./data/logs/

**Prevention:**
- Always use `unset DATABASE_URL` before RAILS_ENV=test
- Never run tests against development database
- Use `bin/test` wrapper script (automatically handles DATABASE_URL)
- Run database cleanup between major test runs

## Assignment Templates (Small, Delegable Tasks)

### Section Index
| Section | Focus Area | Priority Tasks |
|---------|------------|----------------|
| A-E | Core fixes, costs, economics | Spec fixes, blueprint migration, EAP calculator |
| F | Mission & Discovery | Mission profiles, folder structure, Anchor Law |
| G | Market Impact | Mission triggers, resource transformation |
| **H** | **Terrain & Maps [NEW 2026-02-05]** | **NASA GeoTIFF loader, hydrosphere colors, geological data** |

### A) Fix Single Failing Spec (Atomic)
- Steps:
  - Identify failing spec (ANGP).
  - Backup target files to `tmp/pre_revert_backup/`.
  - Compare against Jan 8 backup.
  - Implement minimal fix.
  - Update matching doc in `/docs`.
  - Run targeted rspec.
  - Atomic commit (code + doc).
- Acceptance:
  - Spec passes.
  - Docs describe restored/new logic; Market/GCC vars noted.

### B) Migrate One Blueprint to `cost_schema`
- Target: Choose one high‑impact blueprint (structural/power/life support).
- Steps:
  - Add numeric `cost_schema` fields: unit, installation, maintenance, research (GCC).
  - Keep legacy string cost fields for compatibility.
  - Validate via parser spec (once available).
  - Atomic commit.
- Acceptance:
  - Parser returns numeric values; no JSON schema errors.
- References:
  - [docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md](docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md)
  - [docs/developer/COST_SCHEMA_CONSUMPTION_GUIDE.md](docs/developer/COST_SCHEMA_CONSUMPTION_GUIDE.md)

### C) Add `EAPCalculator` Stub + Test
- Steps:
  - Create service with `calculate_earth_anchor_price(mass_kg, cargo_class, route)`.
  - Read rates/route modifiers from `config/economic_parameters.yml`.
  - Unit test parity with configured values.
  - Atomic commit.
- Acceptance:
  - Calculator returns expected GCC with clear breakdown fields.

### D) Add Economics Mode Toggle (Bootstrap vs Mature)
- Steps:
  - Add config flag and defaults.
  - Apply in planner/forecaster transport cost paths.
  - Integration spec: toggling mode changes transport cost outputs.
  - Atomic commit.
- Acceptance:
  - Mode visibly affects transport costs; tests green.

### E) Instrument Planner KPIs
- Steps:
  - Log transport burden %, delivered cost deltas, ROI, sourcing mix.
  - Add a simple spec that asserts presence of KPI fields in output.
  - Atomic commit.
- Acceptance:
  - KPIs present and parsable in logs/reports.

## Section F: Mission & Discovery Architecture

### Required Folder Structure
All mission data must follow the standardized folder structure:
```
data/json-data/missions/[category]/
├── [mission_name]_profile_v1.json
├── manifest_v1.1.json
└── phases_v1.json
```

**Categories:**
- `wormhole-discovery/` - Wormhole investigation and mapping missions
- `planetary-terraforming/` - Planet-scale environmental modification
- `asteroid-mining/` - Resource extraction from asteroids
- `orbital-construction/` - Space station and infrastructure building
- `interstellar-expansion/` - Multi-system exploration and colonization

### Template Version Requirements
- **Profile files**: Must use `v1` template format
- **Manifest files**: Must use `v1.1` template format (includes Anchor Law compliance)
- **Phase files**: Must use `v1` template format

### Anchor Law Integration
All missions targeting wormhole exploitation must:
1. Designate a primary asteroid anchor point (Phase 1 requirement)
2. Include Anchor Law compliance verification in manifest_v1.1.json
3. Establish claim registration objectives in phase planning

### Cross-references
- [Settlement Patterns Architecture](../architecture/settlement_patterns.md) - Planetary colonization frameworks
- [Mission Profile Library](../mission_profiles/00_complete_profile_library.md) - Complete mission template reference

## Section G: Market Impact

### Mission Completion Market Triggers
**MANDATORY RULE**: All mission completions must trigger a Market Manifest update in `data/json-data/market/`.

- **Trigger Events**: Mission completion automatically updates corresponding market manifest
- **Documentation**: Market changes must be documented in `docs/market/gcc_coupling_status.md`
- **Validation**: Market manifests must be validated for GCC coupling consistency

### Resource Transformation Table
Mission completions transform resource availability according to these codified rules:

| Mission Type | Primary Resource Impact | Secondary Effects |
|-------------|-------------------------|-------------------|
| Hollowed Asteroid Depot | +50% Silicate Supply | +100% Slag Fuel, +30% Construction Materials |
| Planetary Harvesting | +200% Helium-3 Supply | +75% Rare Earth Metals, +150% Volatiles |
| Wormhole Discovery | -40% Transport Costs | +25% Trade Volume, -20% Wormhole Tax |
| Orbital Construction | +40% Infrastructure Capacity | +60% Power Supply, +35% Crew Capacity |
| Asteroid Mining | +80% Mineral Supply | +50% Industrial Metals, +25% Fuel Resources |

### Market Manifest Structure
All market manifests must include:
- GCC/USD coupling logic with base exchange rates
- Resource supply status (Abundant/Low/Emerging/Stable)
- Economic indicators (tax rates, cost modifiers)
- Mission completion transformation rules
- Validation status and update timestamps

### Cross-references
- [GCC Coupling Status](../market/gcc_coupling_status.md) - Current exchange rates and market conditions
- [Market Manifest AC-B1](../../data/json-data/market/market_manifest_ac_b1.json) - Alpha Centauri market initialization

## Atomic Commit Recipe
```bash
# Host

## Schema Evolution Tracking **[2026-01-17]**

### Recent Schema Updates
Track breaking schema changes to prevent recurring "undefined method" errors:

**Geosphere Model:**
- ✅ Use `crust_composition` NOT `surface_composition`
- ✅ Use `stored_volatiles` (Hash with :CO2, :H2O keys) NOT `volatile_reservoirs`
- ✅ `stored_volatiles` structure: `{CO2: {polar_caps: Float, regolith: Float}, H2O: {subsurface_ice: Float}}`

**Hydrosphere Model:**
- ✅ Use `water_bodies` (Hash/JSON field) NOT `ocean_coverage`
- ✅ Check presence with `water_bodies.present?` NOT numeric comparison

**CelestialBody Lookup:**
- ✅ Search by `name` (case-insensitive) for user-facing identifiers
- ✅ `identifier` field uses format like "MARS-01", "EARTH-01" (internal system codes)
- ✅ Use `CelestialBodies::CelestialBody.find_by("LOWER(name) = ?", target_name.downcase)`

**SolarSystem Model:**
- ✅ Use `class_name: 'Location::SpatialLocation'` NOT `class_name: 'SpatialLocation'` for spatial_location association

### Before Restoring from Jan 8 Backup
1. Check if restored code uses old schema methods
2. Compare against current models in `app/models/celestial_bodies/spheres/`
3. Update method calls to match current schema
4. Run targeted spec to verify: `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/[relevant_spec].rb'`
git add [file1] [file2] docs/[updated_doc].md
git commit -m "fix: [component] — code + docs"
```

## Backup & Restore
```bash
# Host
mkdir -p tmp/pre_revert_backup
cp [target_file] tmp/pre_revert_backup/
# Compare to Jan 8 backup
ls -la /Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026
```

## Documentation Mandate
- Update or create relevant doc in `/docs` for each fix.
- Include restored logic, Market/GCC variables, and alignment with mission/system intent.

## Simulation Mandate **[2026-01-15] Documentation Update**
- All fixes to the AIManager::MissionPlannerService and TerraSim::Simulator must preserve or implement support for source: :simulation hooks to enable the Digital Twin workflow.
- Digital Twin operations shall use transient storage with automatic cleanup.
- Simulation exports must conform to manifest_v1.1.json schema for AI Manager execution.

## Main Page Interface Update **[2026-01-21] Galaxy Game Interface**
- **Goal:** Transform main page from SimEarth demo to proper galaxy game interface
- **Changes Made:**
  - Updated `app/views/game/index.html.erb` with galaxy game styling and layout
  - Added `get_time` and `state` actions to `app/controllers/game_controller.rb`
  - Interface features: time display, simulation controls, celestial body grid, navigation sidebar
- **Testing:** All game controller tests pass (27 examples, 0 failures)
- **Log:** `./data/logs/rspec_game_controller_1769038978.log`

## Terrain Data Organization and Path Configuration

### Data Directory Structure
**Critical:** Terrain data files must be stored outside the git repository for proper Docker volume mounting.

**❌ WRONG - Files in git-tracked location:**
```
galaxy_game/data/geotiff/processed/*.asc.gz  # Inside Rails app, tracked by git
```

**✅ CORRECT - Files in data mount location:**
```
data/geotiff/processed/*.asc.gz              # Root data/ directory, gitignored
data/processed/*.asc.gz                      # Accessible via Docker volume mount
```

### Path Configuration Standards
**ALL data paths must use `GalaxyGame::Paths` constants** instead of hardcoded paths.

**❌ WRONG - Hardcoded paths:**
```ruby
# In terrain generators or scripts
pattern_file = Rails.root.join("app/data/ai_manager/geotiff_patterns_#{body}.json")
```

**✅ CORRECT - Configured paths:**
```ruby
# Use GalaxyGame::Paths constants
pattern_file = GalaxyGame::Paths::AI_MANAGER_PATH.join("geotiff_patterns_#{body}.json")
```

### Docker Volume Mount Mapping
- **Host:** `./data/` → **Container:** `/home/galaxy_game/app/data`
- **Rails JSON_DATA:** `Rails.root.join('app', 'data')` = `/home/galaxy_game/app/data`
- **AI Manager Path:** `GalaxyGame::Paths::AI_MANAGER_PATH` = `/home/galaxy_game/app/data/ai_manager`

### Terrain Data File Locations
- **Elevation Data:** `data/geotiff/processed/` (luna_1800x900.asc.gz, mars_1800x900.asc.gz)
- **Pattern Files:** `data/json-data/ai_manager/` (geotiff_patterns_*.json)
- **Scripts:** Use `PROJECT_ROOT` variable for shell scripts to work from any directory

### Verification Commands
```bash
# Check terrain data exists in correct location
ls -la data/geotiff/processed/*.asc.gz
ls -la data/processed/*.asc.gz

# Verify path constants work
docker exec -it web bash -c "bundle exec rails runner \"puts GalaxyGame::Paths::AI_MANAGER_PATH\""

# Test terrain generation
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/terrain/ --format documentation'
```

## Section H: Terrain & Map System Fixes [2026-02-05]

### View Types Distinction

**Monitor View (Admin/Debug):**
- SimEarth-style layered rendering with toggleable overlays
- Terrain layer always ON as foundation (cannot be disabled)
- Body-specific color gradients (Luna=grey, Mars=rust, Earth=green-brown)
- Location: `app/views/admin/celestial_bodies/monitor.html.erb`

**Surface View (Gameplay):**
- Uses FreeCiv tileset sprites for proper game UI
- Requires 2:1 aspect ratio grid for cylindrical wrap
- Tile pixel size must match tileset (64×64 for Trident)
- Location: `app/views/admin/celestial_bodies/surface.html.erb`

### H1) NASA GeoTIFF Loader for Monitor View (✅ COMPLETED 2026-02-06)

**Goal:** Replace incorrect FreeCiv-derived elevation display with real NASA GeoTIFF data in the monitor view.

**Background:** Current monitor view converts FreeCiv terrain characters to arbitrary elevation values (279-322m uniform range). Real elevation data exists at `data/geotiff/processed/*.asc.gz` with 1800×900 resolution.

**Note:** The SimEarth-style layer system is correct - only the DATA SOURCE needs fixing. Terrain layer should remain always-on as the base.

**Layer System (Preserve This):**
- Layer 0 (Terrain/Lithosphere): Always ON - elevation-based body colors
- Layer 1 (Hydrosphere): Toggleable - liquid coverage overlay
- Layer 2 (Biosphere): Toggleable - vegetation/life overlay  
- Layer 3 (Infrastructure): Toggleable - stations/depots overlay

**Implementation:**
1. ✅ Updated `app/views/admin/celestial_bodies/monitor.html.erb` to load NASA terrain data directly from `geosphere.terrain_map`
2. ✅ Replaced FreeCiv data source with NASA elevation/biomes/resource_grid extraction
3. ✅ Added NASA-first water calculation using hydrosphere bathtub logic
4. ✅ Updated rendering loop to use layers.elevation, layers.biomes, layers.water, layers.resources
5. ✅ Maintained existing layer toggle system and SimEarth aesthetic
6. ✅ Updated documentation in ADMIN_SYSTEM.md to reflect NASA-first architecture

**Files Modified:**
- `app/views/admin/celestial_bodies/monitor.html.erb` - Complete NASA-first rendering implementation
- `docs/developer/ADMIN_SYSTEM.md` - Updated documentation for NASA terrain system

**Acceptance:**
- ✅ Terrain layer shows real elevation variation (Olympus Mons bright, Hellas dark)
- ✅ Layer toggles still work (Hydrosphere, Biosphere, etc.)
- ✅ Body-specific colors render correctly using NASA data
- ✅ Controller tests pass (169 examples, 0 failures)

**References:**
- [GUARDRAILS.md §7.5](../GUARDRAILS.md) - Terrain architecture principles
- [ELEVATION_DATA.md](ELEVATION_DATA.md) - Data sources
- [SURFACE_VIEW_IMPLEMENTATION_PLAN.md](SURFACE_VIEW_IMPLEMENTATION_PLAN.md) - Full task list

### H2) Hydrosphere Composition Colors (MEDIUM PRIORITY)

**Goal:** Render hydrosphere with composition-appropriate colors, not always blue.

**Background:** Some bodies have non-water hydrospheres (Titan has methane/ethane lakes). The `liquid_name` attribute in seed data specifies composition but isn't used for coloring.

**Steps:**
1. Fix `primary_liquid` method in `CelestialBodyHydrosphere` model
2. Check `hydrosphere.liquid_name` attribute first, fall back to `hydrosphere.liquids`
3. Add composition→color mapping:
   - H2O → blue (#0066cc)
   - CH4/C2H6 (methane/ethane) → orange (#cc6600)
   - NH3 (ammonia) → yellow-green (#99cc00)
   - N2 (nitrogen) → pale pink (#ffcccc)
4. Apply to hydrosphere rendering in map views

**Files to Modify:**
- `app/models/celestial_body_hydrosphere.rb` - Fix `primary_liquid` method
- `app/helpers/map_helper.rb` - Add composition color method
- `spec/models/celestial_body_hydrosphere_spec.rb` - Test liquid detection

**Acceptance:**
- Titan's hydrosphere renders orange, not blue
- Earth's oceans render blue
- Method correctly reads `liquid_name` attribute

### H3) Remove FreeCiv-to-Elevation Conversion (HIGH PRIORITY)

**Goal:** Stop treating FreeCiv terrain types as elevation data.

**Background:** Code currently maps FreeCiv terrain characters (d,p,g,f,h,m) to elevation ranges. This is architecturally wrong - FreeCiv terrain represents biomes/classification, not topography.

**Steps:**
1. Remove elevation conversion tables from monitor view
2. Remove terrain-to-elevation mapping from any services
3. Keep FreeCiv maps accessible for AI Manager training only
4. Update any code that relies on FreeCiv for elevation

**Files to Modify:**
- `app/views/admin/monitor.html.erb` - Remove terrain→elevation conversion
- Search for any `terrain_to_elevation` or similar methods

**Acceptance:**
- No code converts FreeCiv terrain characters to elevation numbers
- FreeCiv data only used by AI Manager for training/pattern learning

### H4) Complete Geological Data for Mars & Luna (LOW PRIORITY)

**Goal:** Add missing geological feature categories to validation data.

**Background:** Civ4 Mars map has 30 labeled features. Our geological data is missing key categories that prevent complete validation.

**Missing Data Files to Create:**
```
data/json-data/star_systems/sol/celestial_bodies/mars/features/
├── volcanoes.json     # Olympus Mons, Elysium Mons, Pavonis, Arsia, Ascraeus
├── planitia.json      # Hellas, Amazonis, Arcadia, Acidalia, Utopia
├── terrae.json        # Terra Sabaea, Terra Cimmeria, etc.
└── tholus.json        # Albor Tholus, Hecates Tholus

data/json-data/star_systems/sol/celestial_bodies/luna/features/
├── maria.json         # Mare Imbrium, Tranquillitatis, Serenitatis, etc.
└── montes.json        # Apenninus, Carpatus, Haemus, etc.
```

**Steps:**
1. Extract feature names from Civ4 Mars map (30 labels)
2. Cross-reference with NASA/USGS nomenclature
3. Add lat/lon coordinates for each feature
4. Validate against FreeCiv Mars map (50+ labels)
5. Create JSON files matching existing format (see craters.json for template)

**Acceptance:**
- All Civ4 Mars labels have corresponding geological data entries
- Coordinates match real positions (within reasonable tolerance)
- AI Manager can validate feature completeness

**References:**
- Civ4 Mars: `data/Civ4_Maps/MARS1.22b.Civ4WorldBuilderSave`
- FreeCiv Mars: `data/maps/mars-terraformed-133x64-v2.0.sav`

---

## Optional: Alpha Centauri JSON Generator Template
- Goal: Provide generator for Alpha Centauri system files.
- Suggested placement: `scripts/alpha_centauri_generator.rb` or JSON build script under `galaxy_game/json-build-scripts/`.
- Small task:
  - Scaffold minimal generator with CLI args.
  - Write 1 example JSON and doc page linking usage.
  - Atomic commit.

---
This playbook is designed for quick delegation: each task has steps, commands, and clear acceptance criteria. Use ANGP for overnight automation, IQFP for collaborative precision, BFDDA for failure heat‑maps, and LEC to keep the workspace clean.