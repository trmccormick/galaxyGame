# Task: Fix Manufacturing Cluster — 8 Failures Across 3 Specs

## Overview
Three distinct fixes needed. All are straightforward. Do them in order.

---

## Fix 1: cost_calculator.rb — Operator Precedence Bug (2 failures)

### Files to modify
- `app/services/manufacturing/cost_calculator.rb`

### Problem
Line 83 has an operator precedence bug. Ruby parses `||` before `?:` so the line:
```ruby
base_efficiency = @blueprint.dig('production_data', 'base_material_efficiency') || @blueprint['waste_factor'] ? (1.0 - @blueprint['waste_factor']) : 1.0
```
...is evaluated as:
```ruby
base_efficiency = (@blueprint.dig(...) || @blueprint['waste_factor']) ? (1.0 - @blueprint['waste_factor']) : 1.0
```
When `waste_factor` is nil, this tries `1.0 - nil` and raises `TypeError`.

### Fix
Add parentheses to force correct precedence:

Find:
```ruby
base_efficiency = @blueprint.dig('production_data', 'base_material_efficiency') || @blueprint['waste_factor'] ? (1.0 - @blueprint['waste_factor']) : 1.0
```

Replace with:
```ruby
base_efficiency = @blueprint.dig('production_data', 'base_material_efficiency') || (@blueprint['waste_factor'] ? (1.0 - @blueprint['waste_factor']) : 1.0)
```

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/cost_calculator_spec.rb --format progress 2>&1 | tail -3'
```
Expected: 0 failures

---

## Fix 2: shell_printing_service_spec.rb — Printer Not Operational (5 failures)

### Files to modify
- `spec/services/manufacturing/shell_printing_service_spec.rb`

### Problem
The `printer_unit` factory creates a structure that is not operational.
The service raises `"Printer must be operational"` because `printer_unit.operational?` returns false.
This is a spec setup issue — the printer needs to be set operational before the tests run.

### Investigation needed first
Check how `printer_unit` is defined in the spec and what `operational?` checks:

```bash
docker exec -it web bash -c 'grep -n "printer_unit\|let(:printer\|operational" /home/galaxy_game/spec/services/manufacturing/shell_printing_service_spec.rb | head -20'
```

```bash
docker exec -it web bash -c 'grep -n "def operational?" /home/galaxy_game/app/models/structures/base_structure.rb'
```

### Expected fix pattern
In the `before` block of the `with sufficient materials` context and any other
context that uses `printer_unit`, add a line to make it operational. Likely one of:

```ruby
printer_unit.update!(operational: true)
# OR
printer_unit.update_columns(status: 'operational')
# OR
allow(printer_unit).to receive(:operational?).and_return(true)
```

Use whichever matches how `operational?` is implemented in the model.

Also check the `with incompatible printer` context (line 195) — that test expects
the printer to raise an error for incompatibility, NOT for being non-operational.
That context may need the printer to be operational but incompatible (wrong type).

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/shell_printing_service_spec.rb --format progress 2>&1 | tail -3'
```
Expected: 0 failures

---

## Fix 3: assembly_service_spec.rb — Balance Mismatch (1 failure)

### Files to modify
- `spec/services/manufacturing/assembly_service_spec.rb`

### Problem
```
expected: 0.1e4   (1000.0)
     got: 0.964e3  (964.0)
```
The test expects the player's balance to remain at 1000 after assembly, but it's
being charged 36.0 as a tenant fee. Either:
- The `initial_player_balance` is set before the fee is charged (capturing wrong value)
- The test expects no fee but a fee is being applied
- The fee amount changed and the assertion needs updating

### Investigation needed first
```bash
docker exec -it web bash -c 'sed -n "50,80p" /home/galaxy_game/spec/services/manufacturing/assembly_service_spec.rb'
```

### Expected fix pattern
One of:
1. If `initial_player_balance` is captured before setup that charges a fee, move it after setup
2. If the test is asserting balance unchanged but a fee IS expected, update the assertion to `eq(initial_player_balance - expected_fee)`
3. If the fee amount is wrong in the service, fix the service

Determine which is correct by reading the test description: "charges the tenant fee" — so a fee IS expected. The assertion is likely checking the wrong value. Fix the assertion to account for the fee being charged.

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/assembly_service_spec.rb:56 --format progress 2>&1 | tail -3'
```
Expected: 1 example, 0 failures

---

## Final Verification

Run the full manufacturing suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/ --format progress 2>&1 | tail -3'
```
Expected: 164 examples, 0 failures, 1 pending
