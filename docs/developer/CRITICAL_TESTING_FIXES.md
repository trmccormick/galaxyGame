# Critical Testing Fixes - January 2026

**Last Updated:** 2026-01-17  
**Status:** Production - Use these commands for all testing

## The DATABASE_URL Problem

### What Was Wrong
Tests were running against the **development database** instead of the test database, causing:
- ❌ Development data being wiped during test runs
- ❌ Database deadlocks and conflicts
- ❌ Incomplete RSpec log files
- ❌ Unreliable test results

### Root Cause
The `DATABASE_URL` environment variable **overrides** `database.yml` settings, even when `RAILS_ENV=test` is set.

```bash
# This env var was set in docker-compose:
DATABASE_URL=postgres://postgres:password@db:5432/galaxy_game_development

# Result: RAILS_ENV=test was ignored, tests ran against development DB!
```

## Correct Commands (Always Use These)

### Run Full RSpec Suite
```bash
# ✅ CORRECT - Unsets DATABASE_URL, uses test DB
# Output goes to container /home/galaxy_game/log which maps to host ./data/logs/
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'

# ✅ EASIEST - Uses wrapper script that handles DATABASE_URL automatically
docker exec -it web bin/test > ./data/logs/rspec_full_$(date +%s).log 2>&1
```

**Important:** Container path `/home/galaxy_game/log` is mounted to host path `./data/logs/` per docker-compose.dev.yml

### Run Single Spec File
```bash
# ✅ CORRECT
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/file_spec.rb'
```

### Verify Database Connection
```bash
# Check which database you're connected to
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts ActiveRecord::Base.connection.current_database"'

# Expected output: galaxy_game_test
# ❌ If you see: galaxy_game_development - YOU HAVE A PROBLEM!
```

## Database Deadlock Recovery

If tests hang, fail with "database locked", or produce incomplete logs:

```bash
# 1. Kill all test processes
docker exec -it web pkill -f rspec

# 2. Drop and recreate test database
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails db:drop db:create db:migrate'

# 3. Re-seed core data (Sol, planets, materials)
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails db:seed'

# 4. Verify database has data
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts CelestialBodies::CelestialBody.count"'
# Expected: 14 (core celestial bodies)

# 5. Run clean test suite
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'
```

## Pre-flight Checks (Run Before Overnight Grinder)

```bash
# Use the startup script
sh ./start_grinder.sh

# Or manually verify:
# 1. Test DB connection
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts ActiveRecord::Base.connection.current_database"'

# 2. Seed data exists
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts CelestialBodies::CelestialBody.count"'

# 3. Clear cache
docker exec -it web rm -f tmp/rspec_examples.txt

# 4. Archive old logs
mkdir -p ./data/logs/archive && mv ./data/logs/rspec_full_*.log ./data/logs/archive/
```

## Factory Reference (Common Errors)

```bash
# List all available factories
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts FactoryBot.factories.map(&:name).sort.join(\"\n\")"'
```

**Known Factory Mappings (as of 2026-01-17):**
- ✅ Use `:base_unit` NOT `:unit`
- ✅ Currency seeding must complete before financial tests

## Never Use These (Wrong)

```bash
# ❌ WRONG - Missing DATABASE_URL unset
docker-compose -f docker-compose.dev.yml exec web /bin/bash -c "RAILS_ENV=test bundle exec rspec"

# ❌ WRONG - Uses docker-compose instead of docker exec
docker-compose -f docker-compose.dev.yml exec web ...

# ❌ WRONG - Doesn't specify test database
docker exec -it web bundle exec rspec
```

## Database Isolation Summary

| Database | Purpose | Protected? |
|----------|---------|------------|
| `galaxy_game_development` | Active development, seeded data | ✅ Tests now isolated |
| `galaxy_game_test` | RSpec test suite | ✅ Cleaned between runs |
| `galaxy_game_production` | Production (unused locally) | N/A |

## References

- [GROK_TASK_PLAYBOOK.md](GROK_TASK_PLAYBOOK.md) - Complete testing protocols
- [start_grinder.sh](../../start_grinder.sh) - Pre-flight and baseline generation
- [GUARDRAILS.md](../GUARDRAILS.md) - Code and commit guidelines

---

**Emergency Contact:** If grinder produces incomplete logs or weird failures, run the Database Deadlock Recovery steps above.
