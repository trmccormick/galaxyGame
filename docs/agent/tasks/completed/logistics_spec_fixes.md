# Task: Fix Logistics Cluster — 5 Failures Across 2 Specs

## Overview
Two distinct fixes needed. Read carefully — one touches a service file, one adds
a method to a model.

---

## Fix 1: Add `orbital?` to BaseSettlement (4 failures in inventory_manager_spec)

### Problem
`Logistics::InventoryManager` calls `settlement.orbital?` but this method doesn't
exist on `Settlement::BaseSettlement`, causing `NoMethodError`.

### File to modify
`app/models/settlement/base_settlement.rb`

### Fix
Add the following method to the public section of `BaseSettlement`:

```ruby
def orbital?
  is_a?(Settlement::SpaceStation) || settlement_type.to_s == 'station'
end
```

Find a logical place to add it — near other boolean query methods, or after the
`enum settlement_type` declaration (around line 51).

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/inventory_manager_spec.rb --format progress 2>&1 | tail -3'
```
Expected: 0 failures

---

## Fix 2: Fix `valid_settlement_pair?` in ContractService (1 failure in contract_service_spec)

### Problem
`valid_settlement_pair?` requires `owner.nil?` but settlements ALWAYS have an
owner (either a player corporation or an NPC development corporation). The check
should verify the owner is an NPC organization, not that it's nil.

`BaseOrganization` has an `is_npc?` method that checks
`operational_data&.dig('is_npc') == true`.

### File to modify
`app/services/logistics/contract_service.rb`

### Find (around line 67):
```ruby
def self.valid_settlement_pair?(from_settlement, to_settlement)
  # Both must be NPC settlements
  from_settlement.owner.nil? && to_settlement.owner.nil? &&
  from_settlement != to_settlement
end
```

### Replace with:
```ruby
def self.valid_settlement_pair?(from_settlement, to_settlement)
  # Both must be NPC-owned settlements (not player-owned)
  from_settlement != to_settlement &&
  (from_settlement.owner.nil? || from_settlement.owner.is_npc?) &&
  (to_settlement.owner.nil? || to_settlement.owner.is_npc?)
end
```

NOTE: Keep the `owner.nil?` fallback for safety in case any legacy data has no owner.

### Also check the spec setup
The spec creates settlements with `create(:base_settlement)` which assigns a
player owner by default. The spec needs to use the `:independent` trait or
explicitly pass `owner: nil` OR create settlements owned by an NPC corporation.

Check the spec:
```bash
docker exec -it web bash -c 'sed -n "1,15p" /home/galaxy_game/spec/services/logistics/contract_service_spec.rb'
```

If the spec uses `create(:base_settlement)` without `:independent`, update to:
```ruby
let(:from_settlement) { create(:base_settlement, :independent, name: 'Supplier Base') }
let(:to_settlement) { create(:base_settlement, :independent, name: 'Consumer Base') }
```

The `:independent` trait sets `owner: nil` which satisfies the `owner.nil?`
fallback in the updated `valid_settlement_pair?`.

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/contract_service_spec.rb --format progress 2>&1 | tail -3'
```
Expected: 0 failures

---

## Final Verification

Run the full logistics suite:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/ --format progress 2>&1 | tail -3'
```
Expected: 15 examples, 0 failures
