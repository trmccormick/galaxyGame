# Task: Fix Logistics Regression + Processing Service Spec

## Fix 1: Logistics ContractService regression (2 failures)

### Problem
The previous fix to `valid_settlement_pair?` introduced a regression.
The invalid settlements test (line 35) stubs `owner` to return a `Player` instance,
but `Player` has no `is_npc?` method, causing a `NoMethodError`.

### File to modify
`app/services/logistics/contract_service.rb`

### Find:
```ruby
def self.valid_settlement_pair?(from_settlement, to_settlement)
  # Both must be NPC-owned settlements (not player-owned)
  from_settlement != to_settlement &&
  (from_settlement.owner.nil? || from_settlement.owner.is_npc?) &&
  (to_settlement.owner.nil? || to_settlement.owner.is_npc?)
end
```

### Replace with:
```ruby
def self.valid_settlement_pair?(from_settlement, to_settlement)
  # Both must be NPC-owned settlements (not player-owned)
  from_settlement != to_settlement &&
  (from_settlement.owner.nil? || (from_settlement.owner.respond_to?(:is_npc?) && from_settlement.owner.is_npc?)) &&
  (to_settlement.owner.nil? || (to_settlement.owner.respond_to?(:is_npc?) && to_settlement.owner.is_npc?))
end
```

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/ --format progress 2>&1 | tail -3'
```
Expected: 15 examples, 0 failures

---

## Fix 2: ProcessingService spec — balance math off by 1000 (1 failure)

### Problem
`Player` starts with a default balance of 1,000 (set in `FinancialManagement` concern).
The spec deposits 99,000 and withdraws 95,000, leaving 5,000.
`cost_gcc` is 5,000 and the check is `balance < cost` — 5,000 is NOT less than 5,000,
so the error is never raised.

Fix: withdraw 96,000 instead of 95,000, leaving 4,000 which is less than 5,000.

### File to modify
`spec/services/processing_service_spec.rb`

### Find (around line 122):
```ruby
context 'when owner does not have enough GCC' do
  before do
    owner.account.withdraw(95_000.0, "Testing insufficient funds")
  end
```

### Replace with:
```ruby
context 'when owner does not have enough GCC' do
  before do
    owner.account.withdraw(96_000.0, "Testing insufficient funds")
  end
```

### Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/processing_service_spec.rb:126 --format progress 2>&1 | tail -3'
```
Expected: 1 example, 0 failures

Then run the full spec:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/processing_service_spec.rb --format progress 2>&1 | tail -3'
```
Expected: 0 failures
