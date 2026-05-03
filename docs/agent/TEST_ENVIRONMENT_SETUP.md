# Test Environment Setup
**Last Updated**: 2026-04-26
**Purpose**: How to set up the test database correctly before running RSpec.
Read this before touching database_cleaner.rb or any factory file.

---

## The Two Categories of Test Data

### World Constants (Fixture Data)
These records must exist in the test database before any spec runs.
They are NEVER created by factories. They are NEVER wiped by DatabaseCleaner.
They are seeded once and persist for the lifetime of the test database.

| Constant | Identifier | Why It Must Exist |
|---|---|---|
| Sol star system | SOL-01 | Humanity's home system — always present in game |
| Earth | EARTH-01 | Starting world |
| Luna | LUNA-01 | LDC home base, referenced by multiple specs |
| Mars | MARS-01 | Early colonization target |
| Mercury | MERCURY-01 | Sol body |
| Venus | VENUS-01 | Sol body |
| Jupiter | JUPITER-01 | Sol body |
| Saturn | SATURN-01 | Sol body |
| Uranus | URANUS-01 | Sol body |
| Neptune | NEPTUNE-01 | Sol body |
| Ceres | CERES-01 | Sol body |
| Vesta | VESTA-01 | Sol body |
| Psyche | PSYCHE-01 | Sol body |
| Pluto | PLUTO-01 | Sol body |
| Titan | TITAN-01 | Sol body |
| Phobos | PHOBOS-01 | Sol body |
| Deimos | DEIMOS-01 | Sol body |
| GCC currency | GCC | System currency — code expects it to exist |
| USD currency | USD | System currency — code expects it to exist |
| Lunar Development Corp | LDC | Primary NPC — referenced by specs and seed data |
| AstroLift | ASTROLIFT | Primary NPC logistics provider |

### Test-Specific Data
Everything else. Created by factories per-test. Wiped by DatabaseCleaner
transaction rollback after each test. Players, player settlements, contracts,
jobs, crafts, arbitrary celestial bodies — all fine to create in factories.

---

## Setup Steps — Run Once Per Fresh Test Database

Run these in order. Skip any step if the data already exists
(all commands use find_or_create — safe to re-run).

### Step 1 — Schema
```bash
RAILS_ENV=test bundle exec rails db:schema:load
```

### Step 2 — Build Sol System
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner "StarSim::SystemBuilderService.new(name: \"sol\", debug_mode: true).build!"'
```
Expected output ends with: `System build for sol complete!`

Sol bodies created: MERCURY-01, VENUS-01, EARTH-01, MARS-01, JUPITER-01,
SATURN-01, URANUS-01, NEPTUNE-01, CERES-01, VESTA-01, PSYCHE-01, PLUTO-01,
LUNA-01, TITAN-01, PHOBOS-01, DEIMOS-01

### Step 3 — Seed Currencies
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner "Financial::Currency.find_or_create_by!(symbol: \"GCC\", name: \"Galactic Crypto Currency\", is_system_currency: true, precision: 8); Financial::Currency.find_or_create_by!(symbol: \"USD\", name: \"US Dollar\", is_system_currency: true, precision: 2); puts \"Currencies: #{Financial::Currency.pluck(:symbol).inspect}\""'
```
Expected: `Currencies: ["GCC", "USD"]`

### Step 4 — Seed NPC Organizations
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner "Organizations::BaseOrganization.find_or_create_by!(identifier: \"LDC\") { |o| o.name = \"Lunar Development Corporation\"; o.organization_type = :development_corporation; o.operational_data = {\"is_npc\" => true} }; Organizations::BaseOrganization.find_or_create_by!(identifier: \"ASTROLIFT\") { |o| o.name = \"AstroLift\"; o.organization_type = :corporation; o.operational_data = {\"is_npc\" => true} }; puts \"Orgs: #{Organizations::BaseOrganization.pluck(:identifier).inspect}\""'
```
Expected: `Orgs: ["LDC", "ASTROLIFT"]`

### Step 5 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner "puts \"Bodies: #{CelestialBodies::CelestialBody.count}\"; puts \"Currencies: #{Financial::Currency.pluck(:symbol).inspect}\"; puts \"Orgs: #{Organizations::BaseOrganization.pluck(:identifier).inspect}\""'
```
Expected:
```
Bodies: 16
Currencies: ["GCC", "USD"]
Orgs: ["LDC", "ASTROLIFT"]
```

---

## Why DatabaseCleaner Is Configured This Way

`spec/support/database_cleaner.rb` uses `:transaction` strategy per test,
which rolls back all test-created records after each example. The `except`
list preserves world constants across the entire suite run:

```ruby
except: %w[celestial_bodies locations materials ar_internal_metadata schema_migrations]
```

**Do not remove celestial_bodies from this except list.**
Sol bodies are permanent fixtures. If they get wiped mid-suite, every spec
that depends on LUNA-01, EARTH-01 etc. will fail with setup errors.

The `:transaction` strategy means per-test data is fast to clean up —
no deletion, just rollback. World constants are never touched.

---

## Factory Rules — World Constants

Factories must NEVER create world constant records. Use finders instead.

```ruby
# WRONG — creates a duplicate, causes identifier collision on second run
association :celestial_body, factory: [:celestial_body, :luna]

# CORRECT — finds the seeded record
let(:luna) { CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01') }
```

```ruby
# WRONG — will collide if GCC already exists
let(:currency) { create(:currency, symbol: 'GCC') }

# CORRECT
let(:currency) { Financial::Currency.find_by!(symbol: 'GCC') }
```

```ruby
# WRONG — creates a new solar system with arbitrary bodies
let(:system) { create(:solar_system) }

# CORRECT — when you need Sol specifically
let(:sol) { SolarSystem.find_by!(identifier: 'SOL-01') }

# ALSO CORRECT — when you need any generic system (not Sol)
let(:system) { create(:solar_system) }  # fine for non-Sol tests
```

---

## Sphere Reset Pattern

Sol body spheres (atmosphere, geosphere, hydrosphere, biosphere) support
reset methods to restore default values between tests without recreating
the body. Use this instead of creating new celestial bodies when you need
a clean sphere state.

```ruby
after(:each) do
  luna.atmosphere.reset
  luna.geosphere.reset
  luna.hydrosphere.reset
end
```

Reset coverage as of 2026-04-26:

| Sphere | Reset Implemented | base_values Populated | Status |
|---|---|---|---|
| Atmosphere | ✅ atmosphere_concern.rb | ✅ | Complete |
| Geosphere | ✅ geosphere_concern.rb | ✅ | Complete |
| Hydrosphere | ✅ hydrosphere.rb | ✅ | Complete |
| Biosphere | ⚠️ biosphere.rb | ❌ incomplete | Partial — backlog task needed |

---

## sol.json vs sol-complete.json

| File | Purpose | Use For |
|---|---|---|
| `data/json-data/star_systems/sol.json` | Test fixture — 16 core Sol bodies | Test DB seeding |
| `data/json-data/star_systems/sol-complete.json` | Production seed — full Sol system | Production db:seed only |

Always use `sol.json` for test seeding. It was updated on 2026-04-26
to match the current SystemBuilderService JSON format.

**Never use sol-complete.json for test seeding** — it contains additional
bodies not needed for testing and takes longer to build.

---

## Background — Why This Architecture Exists

Early in development, agents built factories for world-constant bodies
(`:luna`, `:earth`, `:mars` traits, solar system factories that create
3 fresh celestial bodies). This caused two problems:

1. **Identifier collisions** — because `celestial_bodies` is never wiped
   by DatabaseCleaner, factory-created bodies accumulated across runs.
   The sequence counter reset to 1 but `CBODY-1` already existed.

2. **Slow test setup** — recreating Sol bodies per-test added significant
   overhead to the suite.

The correct architecture: Sol is a world constant, seeded once, never
recreated. Sphere resets handle test isolation for sphere state changes.
Factories handle only genuinely test-specific data.
