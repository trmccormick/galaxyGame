# 2026-03-27-MEDIUM-FEATURE-FINANCIAL-TRANSACTION-MODEL

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for financial transaction model implementation
**Supervision Level**: 🔴 Watched carefully

## Context
FinancialTransaction model tracks GCC currency movements between organizations in Consortium governance system. Called directly in BaseOrganization#distribute_consortium_profits but model and table do not exist. Per Wormhole Expansion Plan, responsible for routing transit fees to corporations that provided initial funding, tracking profit shares, and supporting Consortium dividend logic.

## Problem Statement
FinancialTransaction model and database table do not exist. BaseOrganization#distribute_consortium_profits calls FinancialTransaction.create! directly, causing NameError crash at runtime and spec failure in base_organization_profit_spec.rb.

**Expected**: FinancialTransaction.create! records financial movement between two organizations with amount, type, and description. Profit spec passes with 0 failures.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/models/financial_transaction.rb` | New model — record GCC movements between orgs | Create FinancialTransaction model |
| `db/migrate/[timestamp]_create_financial_transactions.rb` | Migration — create financial_transactions table | Create migration with proper columns |
| `spec/models/financial_transaction_spec.rb` | New spec — validate model behavior | Create comprehensive model spec |

## Implementation Steps
1. **Research phase**: Read all reference files, run diagnostics to understand call signature and existing patterns
2. **Generate migration**: Create financial_transactions table with proper columns based on create! call signature
3. **Create model**: Implement FinancialTransaction model with associations and validations
4. **Create spec**: Write comprehensive spec validating model behavior
5. **Run migrations**: Execute migrations in both development and test environments
6. **Verify integration**: Ensure base_organization_profit_spec.rb passes

## Acceptance Criteria
- [ ] FinancialTransaction model exists and can be instantiated
- [ ] financial_transactions table created with proper columns (amount, type, description, from_org_id, to_org_id, etc.)
- [ ] BaseOrganization#distribute_consortium_profits no longer crashes
- [ ] base_organization_profit_spec.rb passes with 0 failures
- [ ] Model includes proper validations and associations

## Stop Conditions
- Breaking existing organization profit distribution functionality
- Changes beyond financial transaction model and related specs

## Commit Instructions
```bash
git add app/models/financial_transaction.rb
git add db/migrate/[timestamp]_create_financial_transactions.rb
git add spec/models/financial_transaction_spec.rb
git commit -m "feat: Implement FinancialTransaction model for consortium profit distribution"
```