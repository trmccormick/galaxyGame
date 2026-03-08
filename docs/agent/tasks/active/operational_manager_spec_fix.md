# OperationalManagerSpec Fix
**Task ID**: OperationalManagerSpec_Fix
**Priority**: CRITICAL
**Status**: PENDING
**Created**: March 5, 2026

## Description
spec/services/ai_manager/operational_manager_spec.rb - 6 failures
Continue ai_manager cluster cleanup after EscalationService water harvesting fix.
**WORKFLOW**: Diagnostic-first approach - report error patterns before implementing fixes.

## ⚠️ CRITICAL DATABASE SAFETY WARNING
**ALL RSpec commands must unset DATABASE_URL to prevent catastrophic development database corruption.**  
**Correct:** `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'`  
**Incorrect:** `docker exec -it web rspec ...` (will wipe dev database!)  

## Steps
1. **PHASE 1 - DIAGNOSTIC ONLY**: Run diagnostic and report back (DO NOT make any code changes yet)
   ```bash
   docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/operational_manager_spec.rb --format documentation 2>&1 | grep "NameError\|NoMethod\|undefined\|Failure/Error" | head -20'
   ```
   **INSTRUCTIONS**: Paste the complete output back to the coordination agent. Do NOT proceed to Phase 2 until receiving explicit confirmation and targeted fix instructions.

2. **PHASE 2 - IMPLEMENT FIX** (Only after coordination agent provides targeted change instructions)
   - Apply the exact changes specified by coordination agent
   - Test: `docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/operational_manager_spec.rb'`
   - Commit: "Fix operational_manager_spec.rb (6→0, ai_manager cluster progress)"
   - Report: Updated failure count (398 → 392)

## Dependencies
- EscalationService water harvesting fix completion (8 failures → 0)
- TRUE BASELINE established: 398 failures (complete suite, all tests active)

## Estimated Time
15 minutes (after diagnostic confirmation)

## RSpec Impact
398 → 392 failures (6 specs fixed, ai_manager cluster progress)

## Handoff Agent
GPT-4.1 (diagnostic reporting + targeted fix execution)

## Workflow Notes
- **Phase 1**: Diagnostic only - report error patterns to coordination agent
- **Phase 2**: Implementation only - apply exact changes specified by coordination agent
- **No guessing**: Wait for targeted fix instructions before touching code
- **Coordination**: Claude provides diagnosis and exact change specifications