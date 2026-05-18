# 2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Feature implementation for marketplace association on BaseStructure
**Supervision Level**: 🔴 Watched carefully

## Context
Market::Marketplace currently belongs_to Settlement::BaseSettlement only. Orbital structures (depots, stations) are not settlements - they are Structures::BaseStructure instances. Without marketplace on structure, craft docking at orbital structure have no local order book to transact against.

## Problem Statement
Marketplace only supports settlement ownership. Orbital structures cannot have marketplaces for local trading.

**Expected**: Marketplace can belong to either settlement or structure. BaseStructure gets has_one :marketplace.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/models/market/marketplace.rb` | Market order book | Make settlement optional, add structure association |
| `app/models/structures/base_structure.rb` | Structure base class | Add has_one :marketplace |
| `db/migrate/[timestamp]_add_structure_id_to_market_marketplaces.rb` | Migration | Add structure_id and structure_type columns |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `db/schema.rb` | Confirm market_marketplaces table columns |
| `app/models/settlement/base_settlement.rb` | Confirm existing marketplace association |

## Implementation Steps
1. **Generate migration**: Add structure_id:integer and structure_type:string to market_marketplaces
2. **Update Marketplace model**: Make settlement optional, add belongs_to :structure optional
3. **Update BaseStructure model**: Add has_one :marketplace with foreign_key :structure_id
4. **Run migration**: Apply database changes
5. **Validate schema**: Confirm new columns exist

## Acceptance Criteria
- [ ] market_marketplaces table has structure_id and structure_type columns
- [ ] Marketplace belongs_to :structure optional
- [ ] Marketplace belongs_to :settlement now optional
- [ ] BaseStructure has_one :marketplace
- [ ] Existing marketplace specs pass
- [ ] No regressions in models suite

## Stop Conditions
- Existing marketplace specs break on making settlement optional
- Schema already has structure_id
- Marketplace queries assume settlement always present

## Commit Instructions
```bash
git add app/models/market/marketplace.rb
git add app/models/structures/base_structure.rb
git add db/migrate/[timestamp]_add_structure_id_to_market_marketplaces.rb
git commit -m "feature: marketplace — add structure association, BaseStructure has_one marketplace"
```