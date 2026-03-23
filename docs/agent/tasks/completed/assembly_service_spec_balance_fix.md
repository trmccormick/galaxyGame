# Task: Fix assembly_service_spec:56 — Tenant Fee Balance Assertion
## Assignee: GPT-4.1
## Priority: High (blocking cluster green)
## Branch: regional-view-phase2

---

## Problem

`spec/services/manufacturing/assembly_service_spec.rb:56` fails with:

```
expected: 0.1e4 (1000)
got: 0.964e3 (964)
```

The test sets `settlement.account.balance = 1000` and asserts it stays at 1000
after assembly. But the settlement balance drops by 36 (the tenant fee amount).

## Root Cause

Two bugs working together:

**Bug 1 — Wrong account being watched in the test.**
`Financial::Account.find_or_create_for_entity_and_currency` looks up accounts
by `accountable` AND `currency`. The test sets up accounts via
`settlement.account.update!(balance: 1000)` and
`player.account.update!(balance: 1000)` — these are generic accounts that may
not be the GCC-currency accounts the service actually uses.

When `charge_tenant_fee` calls `find_or_create_for_entity_and_currency` with
GCC currency, it finds or creates a *different* account than the one the test
updated. The test is asserting on the wrong account entirely.

**Bug 2 — Wrong assertion direction.**
`charge_tenant_fee` transfers FROM requester TO settlement. So the settlement
account should *increase* by the tenant fee, not stay flat. The original
assertion `expect(settlement.account.reload.balance).to eq(initial_settlement_balance)`
is logically wrong — settlement receives the fee so its balance should go up.

## Fix

Replace the `'charges the tenant fee'` example (lines ~56-72) with:

```ruby
it 'charges the tenant fee' do
  gcc_currency = Financial::Currency.find_by!(symbol: 'GCC')

  # Use the same account lookup the service uses — GCC-specific accounts
  settlement_gcc_account = Financial::Account.find_or_create_for_entity_and_currency(
    accountable_entity: settlement,
    currency: gcc_currency
  )
  settlement_gcc_account.update!(balance: 1000)

  player_gcc_account = Financial::Account.find_or_create_for_entity_and_currency(
    accountable_entity: player,
    currency: gcc_currency
  )
  player_gcc_account.update!(balance: 1000)

  result = described_class.start_assembly(
    blueprint: blueprint,
    settlement: settlement,
    requester: player,
    buy_missing: false
  )

  expect(result.success?).to be true
  # Player pays the fee
  expect(player_gcc_account.reload.balance).to eq(1000 - result.tenant_fee)
  # Settlement receives the fee
  expect(settlement_gcc_account.reload.balance).to eq(1000 + result.tenant_fee)
end
```

## Verify

```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/assembly_service_spec.rb:56 --format documentation 2>&1 | tail -20'
```

Should pass cleanly.

## Architectural Note (do NOT fix in this task)

The hardcoded tenant fee formula `10 + build_time_hours + material_count` in
`calculate_tenant_fee` is wrong by design. Fees should be a settlement-level
configuration:
- AI Manager sets fees for NPC-owned bases
- Player corporations set fees for their own bases
- Fee should be stored on the settlement or a related fee schedule record

This is a separate task. Do not change `calculate_tenant_fee` here — just fix
the spec.
