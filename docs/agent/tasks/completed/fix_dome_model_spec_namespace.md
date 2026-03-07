# Fix Dome Model Spec Namespace
**Task ID**: Fix_Dome_Model_Spec_Namespace
**Priority**: LOW
**Status**: PENDING
**Created**: March 6, 2026

## Description
spec/models/dome_spec.rb has 3 failures
All fail with NameError: uninitialized constant Dome
Spec uses bare Dome constant but class is Settlement::Dome

## Files Involved
- spec/models/dome_spec.rb

## Steps
1. IDENTIFY all occurrences of bare Dome constant in spec/models/dome_spec.rb
2. REPLACE all occurrences of bare Dome with Settlement::Dome
3. TEST: rspec spec/models/dome_spec.rb
4. VERIFY: 3/3 specs green
5. COMMIT: "Fix dome_spec namespace — use Settlement::Dome constant"

## Dependencies
None

## Estimated Time
10 minutes

## RSpec Impact
245 → 242 failures (3 failures eliminated)

## Success Criteria
rspec spec/models/dome_spec.rb → 3/3 green

## Handoff Agent
GPT-4.1 (single file, no grinding needed)