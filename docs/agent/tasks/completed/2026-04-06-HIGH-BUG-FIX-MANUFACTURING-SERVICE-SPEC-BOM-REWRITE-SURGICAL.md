# TASK: Rewrite manfacturing_service_spec — BOM-based cost, correct blueprint name
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-06
**Last Updated**: 2026-04-06

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Surgical line replacements only. Every change is specified exactly below.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ CRITICAL: Apply ONLY the changes listed below. Do not rewrite sections
> not listed here. Do not delete any test. Do not add new tests.
> Every change is specified as exact BEFORE → AFTER blocks.

---

## Context

`ManufacturingService` was refactored to calculate construction cost from BOM
via `Market::NpcPriceCalculator.calculate_ask` instead of reading `cost_data`
from blueprint JSON.

The spec was written against the old `cost_data` behavior and references a
blueprint that does not exist (`'Methane-Oxygen Rocket Engine'`). The correct
blueprint name is `'Methane Engine'`.

**Service behavior confirmed (do not change the service):**
- Line 22: reads `blueprint_data['required_materials']`
- Line 27-31: sums `NpcPriceCalculator.calculate_ask(settlement, material_name) * data['amount']`
- Line 33: applies `settlement.calculate_construction_cost(bom_cost)` — percentage still applies
- Player balance: `credit(50000)` is too low — Methane Engine BOM at real prices is ~160,000 GCC

**Methane Engine BOM confirmed:**
- titanium_alloy: 800kg
- electronics: 200kg
- superalloy: 500kg
- precision_components: 100kg
- Total: 1600kg × stubbed price = construction input

---

## Problem Statement

**Current failures**: 5 failures — all `result[:success]` is false because:
1. Blueprint name `'Methane-Oxygen Rocket Engine'` does not exist → blueprint not found
2. Tests conditioned on `cost_data` presence → skip fires or logic fails
3. `NpcPriceCalculator.calculate_ask` not stubbed → returns nil → cost calculation fails
4. Player balance too low for real prices

**Expected**: All non-skipped tests pass with stubbed NpcPriceCalculator returning 100.0 GCC/kg

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `spec/services/manfacturing_service_spec.rb` | Apply surgical changes listed below |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/manufacturing_service.rb` | Confirm service interface before touching spec |
| `app/services/market/npc_price_calculator.rb` | Confirm stub target: `Market::NpcPriceCalculator.calculate_ask` |

---

## Implementation Steps

> Apply changes IN ORDER. Use str_replace or equivalent exact match replacement.
> Do not touch any line not listed below.

### Step 1 — Read the current spec in full
```bash
cat galaxy_game/spec/services/manfacturing_service_spec.rb
```

Confirm the file matches what is documented here before making any changes.

### Step 2 — Add NpcPriceCalculator stub to the outer before block

**FIND** (lines 7-14, the outer before block opening):
```ruby
  before do
    # Set construction cost to a predictable percentage for testing
    settlement.construction_cost_percentage = 0.4  # 0.4% of purchase cost
    settlement.save!
    
    # Ensure player has enough funds for any reasonable construction cost
    player.credit(50000, "Test funds")  # Enough for most blueprints
```

**REPLACE WITH**:
```ruby
  before do
    # Set construction cost to a predictable percentage for testing
    settlement.construction_cost_percentage = 0.4  # 0.4% of purchase cost
    settlement.save!

    # Stub NpcPriceCalculator to return predictable price for all materials
    allow(Market::NpcPriceCalculator).to receive(:calculate_ask).and_return(100.0)

    # Ensure player has enough funds for BOM-based construction cost
    # Methane Engine BOM: 1600kg × 100.0 GCC/kg = 160,000 GCC base cost
    # With 0.4% construction percentage: 160,000 × 0.004 = 640 GCC
    # Credit enough for any reasonable test scenario
    player.credit(500_000, "Test funds")
```

### Step 3 — Fix blueprint name in "with sufficient funds" context

**FIND**:
```ruby
        blueprint = Lookup::BlueprintLookupService.new.find_blueprint('Methane-Oxygen Rocket Engine')
        expect(blueprint).to be_present, "Methane-Oxygen Rocket Engine blueprint should exist"
        
        purchase_cost = blueprint.dig('cost_data', 'purchase_cost', 'amount')
        
        if purchase_cost.present?
          expected_construction_cost = settlement.calculate_construction_cost(purchase_cost)
          
          result = ManufacturingService.manufacture(
            'Methane-Oxygen Rocket Engine',
            player,
            settlement,
            count: 1
          )
          
          expect(result[:success]).to be true
          expect(result[:message]).to include("Construction cost: #{expected_construction_cost} GCC")
          
          expect(UnitAssemblyJob.count).to eq(1)
          expect(player.reload.balance).to eq(initial_balance - expected_construction_cost)
        else
          # Skip cost-related test if blueprint doesn't have cost data
          skip "Blueprint does not have cost data"
        end
```

**REPLACE WITH**:
```ruby
        blueprint = Lookup::BlueprintLookupService.new.find_blueprint('Methane Engine')
        expect(blueprint).to be_present, "Methane Engine blueprint should exist"

        required_materials = blueprint['required_materials']
        expect(required_materials).to be_present, "Methane Engine blueprint must have required_materials BOM"

        bom_cost = required_materials.sum { |_name, data| data['amount'] * 100.0 }
        expected_construction_cost = settlement.calculate_construction_cost(bom_cost)

        result = ManufacturingService.manufacture(
          'Methane Engine',
          player,
          settlement,
          count: 1
        )

        expect(result[:success]).to be true
        expect(result[:error]).to be_nil, "Manufacturing failed: #{result[:error]}"
        expect(UnitAssemblyJob.count).to eq(1)
        expect(player.reload.balance).to eq(initial_balance - expected_construction_cost)
```

### Step 4 — Fix blueprint name in "with different construction cost percentages" context

**FIND**:
```ruby
        blueprint = Lookup::BlueprintLookupService.new.find_blueprint('Methane-Oxygen Rocket Engine')
        purchase_cost = blueprint.dig('cost_data', 'purchase_cost', 'amount')
        
        if purchase_cost.present?
          expected_cost = settlement.calculate_construction_cost(purchase_cost)
          
          initial_balance = player.balance
          
          result = ManufacturingService.manufacture(
            'Methane-Oxygen Rocket Engine',
            player,
            settlement,
            count: 1
          )
          
          expect(result[:success]).to be true
          expect(player.reload.balance).to eq(initial_balance - expected_cost)
        else
          # Skip cost-related test if blueprint doesn't have cost data
          skip "Blueprint does not have cost data"
        end
```

**REPLACE WITH**:
```ruby
        blueprint = Lookup::BlueprintLookupService.new.find_blueprint('Methane Engine')
        expect(blueprint).to be_present, "Methane Engine blueprint should exist"

        required_materials = blueprint['required_materials']
        expect(required_materials).to be_present, "Methane Engine blueprint must have required_materials BOM"

        bom_cost = required_materials.sum { |_name, data| data['amount'] * 100.0 }
        expected_cost = settlement.calculate_construction_cost(bom_cost)

        initial_balance = player.balance

        result = ManufacturingService.manufacture(
          'Methane Engine',
          player,
          settlement,
          count: 1
        )

        expect(result[:success]).to be true
        expect(player.reload.balance).to eq(initial_balance - expected_cost)
```

### Step 5 — Fix blueprint name in "automatically fulfills material requirements" test

**FIND** (3 occurrences in this test — replace all):
```ruby
        blueprint = Lookup::BlueprintLookupService.new.find_blueprint('Methane-Oxygen Rocket Engine')
        
        # Skip if blueprint doesn't have cost data
        purchase_cost = blueprint.dig('cost_data', 'purchase_cost', 'amount')
        skip "Blueprint does not have cost data" unless purchase_cost.present?
        
        required_materials = blueprint['production_data']&.dig('required_materials') || 
                            blueprint['required_materials'] || 
                            {}
```

**REPLACE WITH**:
```ruby
        blueprint = Lookup::BlueprintLookupService.new.find_blueprint('Methane Engine')
        expect(blueprint).to be_present, "Methane Engine blueprint should exist"

        required_materials = blueprint['required_materials'] || {}
```

Then find the manufacture call in this same test:
**FIND**:
```ruby
        result = ManufacturingService.manufacture(
          'Methane-Oxygen Rocket Engine',
          player,  # Use player
          settlement,
          count: 1
        )
```

**REPLACE WITH**:
```ruby
        result = ManufacturingService.manufacture(
          'Methane Engine',
          player,
          settlement,
          count: 1
        )
```

### Step 6 — Fix blueprint name in "stores actual blueprint data in specifications" test

**FIND**:
```ruby
        blueprint = Lookup::BlueprintLookupService.new.find_blueprint('Methane-Oxygen Rocket Engine')
        
        # Skip if blueprint doesn't have cost data
        purchase_cost = blueprint.dig('cost_data', 'purchase_cost', 'amount')
        skip "Blueprint does not have cost data" unless purchase_cost.present?
        
        result = ManufacturingService.manufacture(
          'Methane-Oxygen Rocket Engine',
          player,
          settlement
        )
```

**REPLACE WITH**:
```ruby
        blueprint = Lookup::BlueprintLookupService.new.find_blueprint('Methane Engine')
        expect(blueprint).to be_present, "Methane Engine blueprint should exist"

        result = ManufacturingService.manufacture(
          'Methane Engine',
          player,
          settlement
        )
```

### Step 7 — Verify example count before running

After applying all changes, confirm no tests were deleted:
```bash
grep -c "it \"" galaxy_game/spec/services/manfacturing_service_spec.rb
```
Expected: 8 (same as original)

### Step 8 — Run the spec
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manfacturing_service_spec.rb 2>&1 | tail -20'
```

Report the full tail output — do not grep, do not filter.

---

## Synthesis Report Format

```
CHANGES APPLIED
Step 2: NpcPriceCalculator stub added — YES/NO
Step 3: sufficient funds context fixed — YES/NO
Step 4: construction cost percentage context fixed — YES/NO
Step 5: material requirements context fixed — YES/NO
Step 6: blueprint data context fixed — YES/NO

EXAMPLE COUNT
Before: 8 | After: [N]

TEST RESULTS
[full tail -20 output]

READY TO COMMIT? YES/NO
```

---

## Testing Sequence

1. Isolation:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manfacturing_service_spec.rb 2>&1 | tail -20'
```

2. Related manufacturing specs — no regressions:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/ 2>&1 | grep "examples,"'
```

---

## Acceptance Criteria
- [ ] 8 examples still present (no tests deleted)
- [ ] 0 failures or only pre-existing skips remain
- [ ] No reference to `'Methane-Oxygen Rocket Engine'` anywhere in spec
- [ ] No reference to `cost_data` in any non-skipped test path
- [ ] `NpcPriceCalculator` stubbed in outer before block
- [ ] No regressions in `spec/services/manufacturing/`
- [ ] No production code changed

---

## Stop Conditions — escalate immediately if:
- Example count drops below 8 after changes
- A change cannot be applied because the FIND text doesn't match exactly —
  report the actual text found and stop
- New failures appear in specs you did not touch
- `calculate_construction_cost` raises an error — report exact message

---

## Commit Instructions
Only after all acceptance criteria are met:
```bash
git add galaxy_game/app/services/manufacturing_service.rb
git add galaxy_game/spec/services/manfacturing_service_spec.rb
git commit -m "refactor: manufacturing_service — BOM-based cost via NpcPriceCalculator, fix spec blueprint name"
git push
```

---

## Dependencies
**Blocked by**: none — service change already applied
**Blocks**: full suite baseline confirmation
**Related tasks**: `2026-04-04-HIGH-REFACTOR-MANUFACTURING-SERVICE-BOM-COST-VIA-NPC-PRICE-CALCULATOR.md`

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**: GitHub Copilot (Implementation Agent)
**Completion date**: 2026-04-07
**Final test result**: 8 examples, 0 failures, 3 pending
### What was changed
- Updated all blueprint references in the spec to use 'Methane Engine' instead of 'Methane-Oxygen Rocket Engine'.
- Stubbed NpcPriceCalculator in the outer before block to return 100.0 for all materials.
- Updated BOM cost calculation to match service logic (using required_materials, not cost_data).
- Ensured player is credited enough for BOM-based construction cost.
- Confirmed all acceptance criteria: 8 examples, 0 failures, no deleted tests, no regressions, and no production code changes.

### Issues discovered
- The spec previously referenced a non-existent blueprint and used outdated cost logic.
- The service file was not committed initially but was later committed and pushed.

### Follow-up tasks needed
- None for this spec; full suite baseline confirmation is now unblocked.

### Lessons learned
- Always update both spec and service together and commit both.
- Always move completed task files and fill in the completion report per workflow.
- Confirm all acceptance criteria and workflow steps before closing a task.
