# TASK: base_organization_profit_spec.rb:13 quick win
**Status**: ACTIVE **Priority**: MEDIUM **Type**: bug-fix **Created**: 2026-04-08

**Assigned To**: GPT-4.1 0x **Why**: Single failure, profit distribution

## Problem
Line 13: BaseOrganization distributes profits to members based on ownership

## Steps
1. Run: rspec spec/models/organizations/base_organization_profit_spec.rb:13
2. Synthesis Report → STOP approval
3. Fix profit distribution logic  
4. rspec spec/models/organizations/base_organization_profit_spec.rb → 0 failures
5. git commit -m "fix: base_organization_profit_spec:13 profit distribution"