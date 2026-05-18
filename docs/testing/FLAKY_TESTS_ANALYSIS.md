# Flaky Tests Analysis & Debugging Guide
**Last Updated**: May 15, 2026  
**Purpose**: Document flaky test patterns and debugging strategies for RSpec suite restoration.

---

## Overview

This document tracks identified flaky test patterns and provides debugging strategies for the Galaxy Game RSpec suite. Flaky tests are tests that sometimes pass and sometimes fail without code changes.

## Critical Rule: Test Output Redirection (Rule 7)
- **Single spec file**: OK to stream (`rspec spec/path/to/file_spec.rb`)
- **Multiple files or full suite**: MUST redirect to log file
- **Command template**: `docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/... > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'`
- **Report back**: ONLY final summary line + targeted failure snippets from the log
- **NEVER**: Paste full RSpec output to chat/IDE (crashes VSCode buffer)

---

## Identified Flaky Test Patterns

### Pattern 1: Database Environment Mismatch
**Symptoms**: Tests fail intermittently with `DatabaseNotFound` or `PG::UndefinedTable`

**Root Causes**:
- `DATABASE_URL` not unset before running RAILS_ENV=test tests
- Test database not properly set to test environment
- Schema not loaded or migrations pending

**Affected Tests** (from previous sessions):
- `spec/controllers/admin/simulation_controller_spec.rb`
- `spec/controllers/game_controller_spec.rb`
- Tests that query celestial bodies

**Fix**:
```bash
# ALWAYS run with unset DATABASE_URL
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:environment:set RAILS_ENV=test'
```

**Verification**:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner "puts Rails.env"'
# Should output: test
```

---

### Pattern 2: World Constants Not Seeded
**Symptoms**: Tests fail with `NoMethodError: undefined method [...] for nil:NilClass` after model creation, specifically when accessing:
- `CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01')`
- `Financial::Currency.find_by(symbol: 'GCC')`
- `Organizations::BaseOrganization.find_by(identifier: 'LDC')`

**Root Causes**:
- Sol system not built before test suite runs
- Currencies not seeded
- NPC organizations not created
- DatabaseCleaner configuration removes world constants

**Affected Tests**:
- Any spec using Luna, Earth, Mars, etc.
- Integration specs that need GCC currency
- AI Manager specs referencing LDC

**Fix** (Test Setup Steps):
```bash
# Step 1: Schema
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:schema:load'

# Step 2: Build Sol (may take 1-2 minutes)
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner \
  "StarSim::SystemBuilderService.new(name: \"sol\", debug_mode: true).build!"'

# Step 3: Seed Currencies
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner \
  "Financial::Currency.find_or_create_by!(symbol: \"GCC\", name: \"Galactic Crypto Currency\", is_system_currency: true, precision: 8); \
   Financial::Currency.find_or_create_by!(symbol: \"USD\", name: \"US Dollar\", is_system_currency: true, precision: 2); \
   puts \"Currencies: #{Financial::Currency.pluck(:symbol).inspect}\""'

# Step 4: Seed NPC Organizations
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner \
  "Organizations::BaseOrganization.find_or_create_by!(identifier: \"LDC\") { |o| o.name = \"Lunar Development Corporation\"; o.organization_type = :development_corporation; o.operational_data = {\"is_npc\" => true} }; \
   Organizations::BaseOrganization.find_or_create_by!(identifier: \"ASTROLIFT\") { |o| o.name = \"AstroLift\"; o.organization_type = :corporation; o.operational_data = {\"is_npc\" => true} }; \
   puts \"Orgs: #{Organizations::BaseOrganization.pluck(:identifier).inspect}\""'

# Step 5: Verify
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner \
  "puts \"Bodies: #{CelestialBodies::CelestialBody.count}\"; \
   puts \"Currencies: #{Financial::Currency.pluck(:symbol).inspect}\"; \
   puts \"Orgs: #{Organizations::BaseOrganization.pluck(:identifier).inspect}\""'
```

**Expected Output for Step 5**:
```
Bodies: 16
Currencies: ["GCC", "USD"]
Orgs: ["LDC", "ASTROLIFT"]
```

**Reference**: See `docs/agent/TEST_ENVIRONMENT_SETUP.md` for complete setup procedure

---

### Pattern 3: Test Isolation via Factory Misuse
**Symptoms**: Tests pass individually but fail when run in sequence; error: `Duplicate identifier collision`

**Root Causes**:
- Factories creating world constants (`:luna`, `:earth`, celestial body traits)
- Identifier sequence counter resets but DB not wiped
- Tests using `create(:celestial_body)` instead of `find_by!`

**Affected Pattern**:
```ruby
# WRONG - creates duplicate on second run
let(:luna) { create(:celestial_body, :luna) }

# CORRECT - finds the seeded record
let(:luna) { CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01') }
```

**Fix**:
- Never use factories for world constants (see `TEST_ENVIRONMENT_SETUP.md` factory rules)
- Use `find_or_create_by` only for world constants during setup
- Always use `find_by!` in specs

---

### Pattern 4: Sphere Reset State Corruption
**Symptoms**: Specs checking atmosphere composition fail intermittently with type mismatches:
- `NoMethodError: undefined method '...' for #<Float>`
- `TypeError: can't convert String to Float`
- Gas percentage assertions return nil or String instead of Float

**Root Causes**:
- Sphere `reset` methods not properly restoring `base_values`
- Gas composition built from cached String values instead of parsed numerics
- Biosphere sphere reset incomplete (marked as partial in TEST_ENVIRONMENT_SETUP.md)

**Affected Tests**:
- `spec/models/celestial_bodies/spheres/atmosphere_spec.rb` (lines 176, 186)
- `spec/models/concerns/atmosphere_concern_spec.rb` (line 237)
- Integration specs calling `.reset` on spheres

**Diagnostic**:
```ruby
# In spec after sphere.reset:
puts "CO2 percentage: #{sphere.co2_percentage} (type: #{sphere.co2_percentage.class})"
# Should be: 95.32 (Float), NOT "95.32" (String)
```

**Fix** (See `docs/agent/TEST_ENVIRONMENT_SETUP.md`):
- Atmosphere reset: ✅ Complete (`atmosphere_concern.rb`)
- Geosphere reset: ✅ Complete (`geosphere_concern.rb`)
- Hydrosphere reset: ✅ Complete (`hydrosphere.rb`)
- Biosphere reset: ⚠️ Partial (backlog task needed)

**Workaround for now**:
```ruby
# Instead of sphere.reset, recreate:
planet.update!(hydrosphere: nil)
planet.create_hydrosphere!(base_values: fresh_values)
```

---

### Pattern 5: Test Timing/Race Conditions
**Symptoms**: 
- Tests pass on repeated runs but fail on first run
- Timeout waiting for database state changes
- Race between test setup and assertion

**Root Causes**:
- No explicit wait between game loop advancement
- Tests checking state before simulation completes
- Async operations not properly awaited

**Affected Tests**:
- `spec/integration/terraforming_integration_spec.rb`
- `spec/integration/terraforming_workflow_spec.rb`
- `spec/services/game_spec.rb`

**Fix**:
```ruby
# Add sleep between state changes
game.advance_days(1)
sleep 0.5  # Give simulation time to complete

# Or use explicit polling
def wait_for_state(condition, timeout: 5)
  Timeout.timeout(timeout) do
    loop { break if condition.call; sleep 0.1 }
  end
end
```

---

## Debugging Checklist

When a test fails intermittently:

- [ ] **Is `DATABASE_URL` unset?** Add `unset DATABASE_URL` before RAILS_ENV=test
- [ ] **Are world constants seeded?** Run TEST_ENVIRONMENT_SETUP.md Steps 1-5
- [ ] **Is test using factories for world constants?** Convert to `find_by!` lookups
- [ ] **Is test resetting sphere state?** Check reset method is complete for that sphere type
- [ ] **Are there timing dependencies?** Add explicit `sleep` or polling wait
- [ ] **Are tests run individually passing but together failing?** Check test isolation (factories, DatabaseCleaner config)
- [ ] **Does error mention string/float type mismatch?** Check sphere data parsing in reset

---

## Test Output Policy Reminder

**NEVER do this**:
```bash
docker exec web bash -c 'rspec spec/...' | cat  # Will paste full output
```

**DO THIS instead**:
```bash
docker exec web bash -c 'rspec spec/... > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
# Then report ONLY summary line and targeted failure snippets from log
```

---

## Sunday Session Priority List

1. **Environment setup** (5 min) — Verify DATABASE_URL unset, run TEST_ENVIRONMENT_SETUP.md
2. **Identify first failure** (5 min) — `--fail-fast` to first broken spec
3. **Apply relevant pattern** (10-30 min) — Use checklist above to fix root cause
4. **Run single test** (1-5 min) — Verify single spec passes  
5. **Run spec file** (5-10 min) — Verify whole file passes
6. **Run suite subset** (10-20 min) — Run 10-20 related specs to confirm no regressions
7. **Repeat** — Go to step 2 for next failure

---

## Related Documentation

- [TEST_ENVIRONMENT_SETUP.md](TEST_ENVIRONMENT_SETUP.md) — Complete setup procedure (world constants, database schema)
- [README.md](../agent/README.md) — Rule 7: RSpec Output Policy
- [GUARDRAILS.md](../GUARDRAILS.md) — Agent operating rules

