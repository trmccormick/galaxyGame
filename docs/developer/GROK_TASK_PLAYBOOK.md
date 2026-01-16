# Galaxy Game: Grok Task Playbook

Purpose: Provide small, assignable task templates with exact commands, guardrails, and acceptance criteria for reliable maintenance and recovery.

## Always-On Guardrails
- Atomic Commits: Only stage fixed code + its docs. Never `git add ..`.
- Backup First: Copy changed files to `tmp/pre_revert_backup/` before overwriting from the Jan 8 backup.
- Documentation Mandate: A fix is "Done" only when `/docs` reflects the new logic/state.
- Host vs Container: Host runs git/backup; container runs rspec and app commands.

## Log Path Hint
- Default path used in recent sessions: `log/rspec_full_*.log`
- Alternate path (older scripts): `data/logs/rspec_full_*.log`
- Set `LOG_DIR` to the one you use consistently.

```bash
# Host
LOG_DIR="log"   # or "data/logs"
LATEST_LOG=$(ls -t "$LOG_DIR"/rspec_full_*.log 2>/dev/null | head -n 1)
```

## Container Path Map (web container)
- Repo root mount: `/home/galaxy_game` (this is the `./galaxy_game` folder on host)
- Data mount: `/home/galaxy_game/app/data` (this is `./data/json-data` on host)
- Scripts: `/home/galaxy_game/scripts`
- Logs: `/home/galaxy_game/log`

Examples (inside container, cwd `/home/galaxy_game`):
- Ruby scripts: `ruby json-build-scripts/star_system_validator.rb --input app/data/star_systems/alpha_centauri.json`
- Rails runner: `bundle exec rails runner scripts/local_bubble_expand.rb --dir app/data/star_systems`

## Protocols

### 1) Autonomous Nightly Grinder Protocol (ANGP)
Use when you want fully automated overnight triage + documentation.

- Identify Latest Log:
```bash
# Host
LOG_DIR="log"   # or "data/logs"
LATEST_LOG=$(ls -t "$LOG_DIR"/rspec_full_*.log 2>/dev/null | head -n 1)
echo "Latest log: $LATEST_LOG"
```
- Extract top failing spec:
```bash
# Host
grep "rspec ./spec" "$LATEST_LOG" | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -1 | awk '{print $2}'
```
- If missing log, run full suite:
```bash
# Host → Container
docker-compose -f docker-compose.dev.yml exec web /bin/bash -c "RAILS_ENV=test bundle exec rspec > ./data/logs/rspec_full_$(date +%s).log 2>&1"
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
bundle exec rspec [path_to_spec]
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
mkdir -p ./data/logs/archive && mv ./data/logs/rspec_full_*.log ./data/logs/archive/
```
- Clear RSpec cache (container):
```bash
docker-compose -f docker-compose.dev.yml exec web rm -f tmp/rspec_examples.txt
```
- Sync docs: Ensure `README.md` or system_architecture.md reflects current state.

## Assignment Templates (Small, Delegable Tasks)

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

## Atomic Commit Recipe
```bash
# Host
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

## Optional: Alpha Centauri JSON Generator Template
- Goal: Provide generator for Alpha Centauri system files.
- Suggested placement: `scripts/alpha_centauri_generator.rb` or JSON build script under `galaxy_game/json-build-scripts/`.
- Small task:
  - Scaffold minimal generator with CLI args.
  - Write 1 example JSON and doc page linking usage.
  - Atomic commit.

---
This playbook is designed for quick delegation: each task has steps, commands, and clear acceptance criteria. Use ANGP for overnight automation, IQFP for collaborative precision, BFDDA for failure heat‑maps, and LEC to keep the workspace clean.