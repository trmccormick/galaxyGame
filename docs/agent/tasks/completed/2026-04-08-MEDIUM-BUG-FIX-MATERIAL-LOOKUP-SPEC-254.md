# TASK: material_lookup_service_spec.rb:254 quick win
**Status**: ACTIVE **Priority**: MEDIUM **Type**: bug-fix **Created**: 2026-04-08

**Assigned To**: GPT-4.1 0x **Why**: Single failure, JSON parsing error handling

## Problem
Line 254: Lookup::MaterialLookupService handles JSON parsing errors gracefully

## Steps
1. Run: rspec spec/services/lookup/material_lookup_service_spec.rb:254
2. Synthesis Report → STOP approval
3. Fix JSON parsing rescue/return logic
4. rspec spec/services/lookup/material_lookup_service_spec.rb → 0 failures
5. git commit -m "fix: material_lookup_service_spec:254 JSON parsing rescue"