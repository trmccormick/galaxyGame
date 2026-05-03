# README.md Additions — 2026-04-26
# These are targeted additions to paste into the existing docs/agent/README.md
# Do not replace the whole file — add these in the locations noted.

---

## ADDITION 1
# Location: Agent Routing table (the | Need | Use | table near the bottom)
# Add this row:

| Test environment setup | Read `TEST_ENVIRONMENT_SETUP.md` before touching factories or database_cleaner.rb |

---

## ADDITION 2
# Location: Critical Rules — Every Agent section
# Add as Rule 13, after the existing Rule 12 (Nil Guard Diagnostic):

**13. Never create world constants in factories**
Sol bodies, GCC, USD, LDC, and AstroLift always exist in the test database.
Use finders — never factories — to reference them in specs.

```ruby
# WRONG
association :celestial_body, factory: [:celestial_body, :luna]

# CORRECT
let(:luna) { CelestialBodies::CelestialBody.find_by!(identifier: 'LUNA-01') }
```

See `TEST_ENVIRONMENT_SETUP.md` for the full world constants list, correct
finder patterns, and test database setup steps.

---

## ADDITION 3
# Location: Session Handoff section (near bottom of file)
# Add after the existing paragraph about handoff documents:

**Before starting any session**, verify the test database has world constants loaded:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner "puts \"Bodies: #{CelestialBodies::CelestialBody.count}\"; puts \"Currencies: #{Financial::Currency.pluck(:symbol).inspect}\""'
```
Expected: Bodies: 16, Currencies: ["GCC", "USD"]
If not — run the setup steps in `TEST_ENVIRONMENT_SETUP.md` before doing anything else.
