# TASK: Rewire ManufacturingService Cost Calculation — BOM via NpcPriceCalculator
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Touches ManufacturingService core logic, requires reasoning about
BOM structure, market pricing integration, and spec rewrite. Not a mechanical fix.
**Supervision Level**: 🟢 Autonomous OK

---

## Context

`ManufacturingService` currently reads `cost_data` directly from blueprint JSON
to determine construction cost:
```ruby
purchase_cost = blueprint['cost_data']['purchase_cost']['amount']
```

This is wrong for two reasons:
1. Many blueprints have no `cost_data` — the field was added inconsistently by agents
2. Even when present, `cost_data` is a static hint, not a live price

**The correct approach**: Construction cost is always derived from the blueprint's
bill of materials (BOM) priced at current market rates via `Market::NpcPriceCalculator`.

**Architectural decision (confirmed by human 2026-04-04):**
- Blueprint `cost_data` is a display hint only — never used for actual cost calculation
- Real cost = sum of (each BOM material × `NpcPriceCalculator.calculate_ask(settlement, material)`)
- This means construction costs naturally reflect market conditions
- A settlement producing its own steel pays less than one importing it
- No blueprint ever needs manual `cost_data` maintenance

**The pricing service already exists and is production-ready:**
`app/services/market/npc_price_calculator.rb`
- `NpcPriceCalculator.calculate_ask(settlement, resource_name)` — returns GCC/kg
- Falls back to Earth import cost when no market history exists
- Uses local production cost when settlement can produce locally
- Full cost-based → market-based progression already implemented

---

## Problem Statement

**Current behavior**: `ManufacturingService` reads `blueprint['cost_data']['purchase_cost']['amount']`,
fails when `cost_data` is absent, returns `success: false`.

**Expected behavior**: `ManufacturingService` reads blueprint BOM, prices each
material via `NpcPriceCalculator.calculate_ask`, sums to construction cost,
charges player, creates `UnitAssemblyJob`.

**Failing spec:**
```
Failure/Error: expect(result[:success]).to be true
  expected true, got false
# spec/services/manfacturing_service_spec.rb:103
```

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method |
|---|---|---|
| `app/services/manufacturing_service.rb` | Main service — replace cost_data read with BOM calculation | `#manufacture` |
| `spec/services/manfacturing_service_spec.rb` | Rewrite cost tests to use BOM pricing | lines 81-115 |

### Reference Files — read before starting
| File | Why You Need It |
|---|---|
| `app/services/market/npc_price_calculator.rb` | The pricing service to call — read fully |
| `app/services/lookup/unit_lookup_service.rb` | How blueprint BOM is accessed |
| `data/json-data/blueprints/units/power/solar_panel_bp.json` | Example blueprint with BOM structure |
| `data/json-data/blueprints/units/power/compact_solar_panel_bp.json` | Example with cost_data — confirms it's optional |

**Read `docs/architecture/life_support_waste_recycling_architecture.md` if
touching any life support unit blueprints.**

---

## Implementation Steps

> Use judgment. Read all reference files before touching anything.

### Step 1 — Understand the current manufacture flow
```bash
cat galaxy_game/app/services/manufacturing_service.rb
```

Map the current flow: how does it read cost, charge the player, create the job?

### Step 2 — Understand the BOM structure
```bash
cat data/json-data/blueprints/units/power/solar_panel_bp.json
```

Identify the BOM field name (likely `materials`, `bill_of_materials`, or
`required_materials`) and its structure: `{ material_name: quantity_kg }`.

### Step 3 — Understand NpcPriceCalculator interface
```bash
cat galaxy_game/app/services/market/npc_price_calculator.rb
```

Confirm: `calculate_ask(settlement, resource_name, context = {})` returns Float (GCC/kg) or nil.

### Step 4 — Produce Synthesis Report and STOP

Include:
- Current cost calculation path (exact lines)
- BOM field name and structure from blueprint JSON
- Proposed new calculation method
- How nil prices from NpcPriceCalculator will be handled
- Spec changes needed

### Step 5 — Implement BOM-based cost calculation

Replace the `cost_data` read with a BOM calculation method:

```ruby
def calculate_construction_cost(blueprint, settlement)
  bom = blueprint['materials'] # or whatever the BOM field is called
  return 0.0 unless bom.present?

  bom.sum do |material_name, quantity_kg|
    unit_price = Market::NpcPriceCalculator.calculate_ask(settlement, material_name)
    unit_price ||= 0.0  # graceful fallback if no price available
    unit_price * quantity_kg
  end
end
```

The `cost_data` field should be **ignored entirely** for cost calculation.
It may remain in JSON for display/reference purposes — do not strip it from files.

### Step 6 — Update the spec

Rewrite `manfacturing_service_spec.rb` cost tests to:
- Not reference `blueprint['cost_data']`
- Stub `NpcPriceCalculator.calculate_ask` to return a known price
- Assert construction cost equals stubbed price × BOM quantities
- Assert `result[:success]` is true

### Step 7 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manfacturing_service_spec.rb 2>&1 | grep "examples,"'
```

### Step 8 — Run related specs
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/ 2>&1 | grep "examples,"'
```

---

## Synthesis Report Format

```
CURRENT COST CALCULATION
File: manufacturing_service.rb line [N]
Current code: [exact lines reading cost_data]

BOM STRUCTURE CONFIRMED
Blueprint field: [field name]
Structure: [example]

NPC PRICE CALCULATOR INTERFACE CONFIRMED
Method: NpcPriceCalculator.calculate_ask(settlement, resource_name)
Returns: Float (GCC/kg) or nil

PROPOSED NEW CALCULATION
[pseudocode of new method]

NIL PRICE HANDLING
[how missing prices are handled — fallback to 0.0 or Earth import cost]

SPEC CHANGES NEEDED
[list of spec lines to rewrite]

RISK
[any shared code affected by this change]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. `spec/services/manfacturing_service_spec.rb` — 0 failures
2. `spec/services/manufacturing/` — no regressions
3. Full suite snapshot after completion:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] `manfacturing_service_spec.rb` — 0 failures
- [ ] No reference to `cost_data` in `ManufacturingService` runtime code
- [ ] `NpcPriceCalculator.calculate_ask` called for each BOM material
- [ ] Nil price handled gracefully (no crash on missing market data)
- [ ] `cost_data` left in blueprint JSON files untouched
- [ ] No regressions in manufacturing specs

---

## Stop Conditions — escalate immediately if:
- BOM field name is inconsistent across blueprints — report before proceeding
- `NpcPriceCalculator` raises errors in test context — report exact error
- `ManufacturingService` is called from more than 5 other services — report call sites
- Any rake task (`ai:sol:gcc_bootstrap`, `ai:lunar_base:with_isru`) fails after change

---

## Commit Instructions
```bash
git add galaxy_game/app/services/manufacturing_service.rb
git add galaxy_game/spec/services/manfacturing_service_spec.rb
git commit -m "refactor: manufacturing_service — replace cost_data read with BOM-based cost via NpcPriceCalculator"
git push
```

---

## Documentation
- [ ] Update `docs/systems/manufacturing.md` if it exists — note that cost_data
  is display-only, runtime cost always derived from BOM via NpcPriceCalculator
- [ ] If doc doesn't exist, flag gap in completion report — do not create it

---

## Dependencies
**Blocked by**: none — `NpcPriceCalculator` already exists and is production-ready
**Blocks**: `manfacturing_service_spec.rb` cost tests
**Related tasks**: none

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
