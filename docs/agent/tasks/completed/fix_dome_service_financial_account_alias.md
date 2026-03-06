# Fix DomeService Financial Account Factory Alias

## Issue
spec/services/manufacturing/construction/dome_service_spec.rb has 4 failures
All fail with Factory not registered: "financial_account"
Factory exists as :account (class Financial::Account) in spec/factories/financial/accounts.rb
Spec calls create(:financial_account, ...) — alias is missing

## Fix
Add factory :financial_account as a nested alias inside the existing :account factory in spec/factories/financial/accounts.rb
No new files needed
One line addition

## Tasks
1. Locate spec/factories/financial/accounts.rb
2. Add alias :financial_account to the existing :account factory
3. Run rspec spec/services/manufacturing/construction/dome_service_spec.rb
4. Verify 24/24 green
5. Commit with message: Add :financial_account alias to account factory; green DomeService specs (24/24)

## Success Criteria
- rspec spec/services/manufacturing/construction/dome_service_spec.rb → 24/24 green
- No new files created
- One line change in existing factory file

## Priority
MEDIUM — unblocks DomeService completely, contributes to <300 failure target

## Time Estimate
15 minutes

## Agent Assignment
GPT-4.1 (simple single-file edit, no execution loop needed)