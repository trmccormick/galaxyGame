# TASK: wormhole_expansion_service_spec.rb:17 quick win
**Status**: ACTIVE **Priority**: MEDIUM **Type**: bug-fix **Created**: 2026-04-08

**Assigned To**: GPT-4.1 0x **Why**: Single failure, wormhole capacity

## Problem
Line 17: WormholeExpansionService#find_expansion_opportunities finds systems with available wormhole capacity

## Steps
1. Run: rspec spec/services/wormhole_expansion_service_spec.rb:17  
2. Synthesis Report → STOP approval
3. Fix capacity check logic
4. rspec spec/services/wormhole_expansion_service_spec.rb → 0 failures
5. git commit -m "fix: wormhole_expansion_service_spec:17 capacity check"