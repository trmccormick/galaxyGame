# Initiate Nightly Grinder Protocol - Test Suite Restoration

## Problem Description
The RSpec test suite has ~393 failing tests with database connection issues preventing proper testing. The nightly grinder protocol provides autonomous overnight restoration but needs to be initiated.

## Current Status
- **Test Database**: Connection issues (galaxy_game_test database does not exist)
- **Failure Count**: ~393 (estimated, cannot run full suite due to DB issues)
- **Blocker**: Cannot proceed to Phase 4 UI enhancements until <50 failures

## Required Actions

### Action 1: Set Up Test Database
**Command**: Run in Docker container
```bash
# Create and setup test database
RAILS_ENV=test bundle exec rake db:create
RAILS_ENV=test bundle exec rake db:schema:load
RAILS_ENV=test bundle exec rake db:seed
```

### Action 2: Run Initial Full Suite
**Command**: Generate fresh baseline for grinder
```bash
# Run full suite and log results
RAILS_ENV=test bundle exec rspec > ./data/logs/rspec_full_$(date +%s).log 2>&1
```

### Action 3: Launch Nightly Grinder
**Command**: Start autonomous restoration cycle
```bash
# Execute the autonomous nightly grinder protocol
# This will run for 4 hours processing specs autonomously
```

## Grinder Protocol Overview
- **Duration**: 4 hours per cycle
- **Processing**: 8-12 specs per cycle
- **Strategy**: Fail-fast autonomous decisions
- **Output**: Summary log with progress and complex issues flagged

## Success Criteria
- [ ] Test database properly configured
- [ ] Full RSpec suite runs without connection errors
- [ ] Nightly grinder initiated and running autonomously
- [ ] Progress tracking established

## Expected Outcome
- Autonomous reduction of simple restoration cases overnight
- Identification of complex issues requiring manual intervention
- Clear path to <50 failures for Phase 4 unlock

## Next Steps
After grinder cycle completes:
1. Review summary log for progress
2. Address complex issues flagged for manual review
3. Continue with Phase 1-3 restoration plan

## Reference Documents
- `RESTORATION_AND_ENHANCEMENT_PLAN.md` - Complete restoration strategy
- `test_suite_restoration_continuation.md` - Manual continuation tasks
- Current status: ~393 failures blocking Phase 4</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/initiate_nightly_grinder_protocol.md