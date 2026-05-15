# 2026-03-27-MEDIUM-FEATURE-FINANCIAL-TRANSACTION-MODEL

**Agent**: 0.33x  
**Priority**: MEDIUM  
**Type**: feature  
**Status**: BACKLOG  

## Context
`FinancialTransaction` is a planned model that tracks GCC currency movements between organizations in the Consortium governance system. It is called directly in `BaseOrganization#distribute_consortium_profits` but the model and table do not exist. Per the Wormhole Expansion Plan (v4), this system is responsible for routing transit fees to corporations that provided initial "Gamble" funding, tracking profit shares, and supporting the Consortium dividend logic. Without it, any consortium profit distribution call crashes with `NameError: uninitialized constant FinancialTransaction`.

**Relevant Architecture Docs** — read before starting:
- `docs/wormhole_expansion/wh-expansion.md` — Consortium governance, dividend logic, GCC routing, transit fee distribution
- `docs/agent/README.md` — project architecture overview
- `config/initializers/game_constants.rb` — GCC currency constants and economic values

## Problem
`FinancialTransaction` model and database table do not exist. `BaseOrganization#distribute_consortium_profits` calls `FinancialTransaction.create!` directly, causing a `NameError` crash at runtime and a spec failure in `base_organization_profit_spec.rb`.

**Error output**:
```
NameError:
  uninitialized constant FinancialTransaction
# ./app/models/organizations/base_organization.rb:118
# ./spec/models/organizations/base_organization_profit_spec.rb:16
```

**Current behavior**: Any call to `distribute_consortium_profits` crashes with uninitialized constant.

**Expected behavior**: `FinancialTransaction.create!` records a financial movement between two organizations with amount, type, and description. The profit spec passes with 0 failures.

## Files
- `galaxy_game/app/models/financial_transaction.rb` — New model — record GCC movements between orgs
- `galaxy_game/db/migrate/[timestamp]_create_financial_transactions.rb` — Migration — create financial_transactions table
- `galaxy_game/spec/models/financial_transaction_spec.rb` — New spec — validate model behavior

## Steps
1. **Research phase** (read only, no changes)
   - Run diagnostics to understand the call signature and existing patterns

2. **Generate and review migration**
   - Migration must create financial_transactions table with proper columns

3. **Create FinancialTransaction model**
   - Implement model with associations, validations, enum for transaction types

4. **Create factory**
   - Create spec/factories/financial_transactions.rb

5. **Create spec**
   - Cover validations, associations, enum, scopes

6. **Verify profit spec passes**
   - Run base_organization_profit_spec.rb

## Acceptance Criteria
- [ ] FinancialTransaction model exists with proper associations
- [ ] Database table created with correct columns
- [ ] Validations work correctly
- [ ] Transaction types enum implemented
- [ ] Factory and spec created
- [ ] base_organization_profit_spec.rb passes
- [ ] No NameError crashes

## Stop Conditions
- Migration conflicts with existing schema
- Association setup causes foreign key issues
- Transaction types don't match existing usage

## Commit Message
`feat: add FinancialTransaction model for consortium profit distribution`