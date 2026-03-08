# Run Baseline RSpec After Architecture Cleanups Task

**Agent**: GPT-4.1
**Priority**: HIGH
**Status**: 📋 PENDING - Task created, ready for execution
**Estimated Effort**: 5 minutes
**Impact**: Confirm exact failure count (~203-206 failures expected)

## Description
Run full RSpec baseline to confirm exact failure count after completing all architecture cleanups. This establishes the new baseline before attacking the next priority cluster (manufacturing_pipeline_e2e_spec.rb).

## Required Command
Run the following command in the container:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

## Expected Results
- Log file created in `/home/galaxy_game/log/rspec_full_[timestamp].log`
- Failure count should be ~203-206 (after eliminating ~22 specs from cleanups)
- Top failing specs identified for next attack

## Success Criteria
- ✅ Command executes without database corruption (DATABASE_URL unset)
- ✅ Log file generated with complete test output
- ✅ Failure count extracted and reported
- ✅ No regressions from architecture changes

## Next Steps
After confirming baseline, attack manufacturing_pipeline_e2e_spec.rb cluster (validates TEU/PVE → tank farm → LEO depot → L1 shipyard pipeline).

## Validation
- Check log file exists and contains full output
- Extract failure count from log summary
- Verify no unexpected new failures from cleanups