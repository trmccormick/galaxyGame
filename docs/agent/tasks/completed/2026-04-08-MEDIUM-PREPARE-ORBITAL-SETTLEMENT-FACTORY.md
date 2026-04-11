# TASK: Create OrbitalSettlement factory + test stub
**Status**: ACTIVE **Priority**: MEDIUM **Type**: refactor **Created**: 2026-04-08

**Assigned To**: GPT-4.1 0x **Why**: Factory creation only, no model changes

## Steps
1. Run: grep -rn "OrbitalSettlement\|orbital_settlement" spec/factories/ app/
2. Create spec/factories/settlement/orbital_settlement.rb:
   ```ruby
   FactoryBot.define do
     factory :orbital_settlement, class: 'Settlement::OrbitalSettlement' do
       base_settlement  # inherit from base
       settlement_type { 'orbital_station' }
     end
   end
   ```
3. Test: rspec spec/models/settlement/orbital_settlement_spec.rb (create if missing)
4. Commit: "prep: orbital_settlement factory for refactor"