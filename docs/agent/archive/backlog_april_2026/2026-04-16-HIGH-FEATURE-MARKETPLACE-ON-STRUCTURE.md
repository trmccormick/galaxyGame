# TASK: Marketplace Association on BaseStructure
**Status**: BACKLOG
**Priority**: HIGH
**Type**: feature
**Created**: 2026-04-16
**Last Updated**: 2026-04-16

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Surgical model and migration change, fully specified,
no inference needed.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`Market::Marketplace` currently belongs_to `Settlement::BaseSettlement`
only. Orbital structures (depots, stations) are not settlements — they
are `Structures::BaseStructure` instances owned by a player, corporation,
or AI Manager. Without a marketplace on the structure, craft docking at
an orbital structure have no local order book to transact against.

This task adds `has_one :marketplace` to `BaseStructure` and updates
`Market::Marketplace` to support both settlement and structure as owners.

---

## Problem Statement

**Current**:
```ruby
# market/marketplace.rb
belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
```

**Expected**: Marketplace can belong to either a settlement or a structure.
Structure gets `has_one :marketplace`.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Section |
|---|---|---|
| `app/models/market/marketplace.rb` | Market order book | `belongs_to :settlement` line |
| `app/models/structures/base_structure.rb` | Structure base class | associations block |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `db/schema.rb` | Confirm market_marketplaces table columns |
| `app/models/settlement/base_settlement.rb` | Confirm existing marketplace association |

---

## Diagnostic Commands — Run First

```bash
docker exec -it web bash -c 'grep -n "settlement_id\|structure_id" /home/galaxy_game/db/schema.rb | grep "market"'

docker exec -it web bash -c 'grep -n "has_one :marketplace\|belongs_to :marketplace" /home/galaxy_game/app/models/settlement/base_settlement.rb'

docker exec -it web bash -c 'grep -n "belongs_to\|has_one\|has_many" /home/galaxy_game/app/models/market/marketplace.rb'
```

---

## Implementation Steps

### Step 1 — Generate migration to add structure_id to market_marketplaces

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && bundle exec rails generate migration AddStructureIdToMarketMarketplaces structure_id:integer structure_type:string'
```

### Step 2 — Make settlement optional in Marketplace

In `app/models/market/marketplace.rb` replace:
```ruby
belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
```
With:
```ruby
belongs_to :settlement, class_name: 'Settlement::BaseSettlement', optional: true
belongs_to :structure, class_name: 'Structures::BaseStructure', optional: true
```

### Step 3 — Add has_one :marketplace to BaseStructure

In `app/models/structures/base_structure.rb` add after existing associations:
```ruby
has_one :marketplace,
        class_name: 'Market::Marketplace',
        foreign_key: :structure_id,
        dependent: :destroy
```

### Step 4 — Run migration

```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'
```

### Step 5 — Validate schema

```bash
docker exec -it web bash -c 'grep -A 5 "create_table.*market_marketplaces" /home/galaxy_game/db/schema.rb'
```

---

## Synthesis Report Format

```
THE FAILURE
Spec: [none — feature addition]
Error: [none]
Expected: BaseStructure has_one :marketplace, Marketplace supports structure
Got: Marketplace only supports settlement

ROOT CAUSE
[one paragraph]

PROPOSED FIX
[confirm migration command and exact code changes]

RISK
[any existing marketplace specs that may break]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Isolation — marketplace specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/market/'
```

2. Structure specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/'
```

3. Full models suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ > /home/galaxy_game/log/rspec_models_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] `market_marketplaces` table has `structure_id` and `structure_type` columns
- [ ] `Marketplace belongs_to :structure` optional
- [ ] `Marketplace belongs_to :settlement` now optional
- [ ] `BaseStructure has_one :marketplace`
- [ ] Existing marketplace specs pass
- [ ] No regressions in models suite

## Stop Conditions
- Existing marketplace specs break on making settlement optional
- Schema already has structure_id — flag before proceeding
- Any marketplace query assumes settlement is always present

## Commit Instructions
```bash
git add galaxy_game/app/models/market/marketplace.rb
git add galaxy_game/app/models/structures/base_structure.rb
git add galaxy_game/db/migrate/[timestamp]_add_structure_id_to_market_marketplaces.rb
git commit -m "feature: marketplace — add structure association, BaseStructure has_one marketplace"
git push
```

## Dependencies
**Blocked by**: None
**Blocks**: 2026-04-16-HIGH-FEATURE-DOCKING-TRANSACTION-SERVICE.md
**Related**: 2026-04-16-MEDIUM-DATA-ECONOMIC-PARAMETERS-MARKET-FEES.md
