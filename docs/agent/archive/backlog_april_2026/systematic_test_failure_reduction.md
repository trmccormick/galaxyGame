# Systematic Test Suite Failure Reduction

## Task Overview
Analyze remaining test failures and apply batch fixes to reach <50 total failures.

## Specific Steps
1. Run full test suite and capture failure output:
   ```
   bundle exec rspec --format progress | grep -E "(failures|errors)" > failure_analysis.txt
   ```

2. Categorize failures by type:
   - Conservative physics mismatches (evaporation, temperature, melting)
   - Model validation conflicts
   - Integration issues
   - Other patterns

3. Prioritize fixes:
   - Most frequent failure types first
   - Quick wins (simple expectation updates)
   - Complex fixes last

4. Apply batch updates:
   - Update test expectations for conservative physics
   - Fix temperature range validations
   - Adjust evaporation/melting calculations

5. Re-run suite after each batch to measure progress

## Expected Outcome
- Clear categorization of remaining failures
- Systematic reduction toward <50 failures
- Identification of any systemic issues

## Dependencies
- TerraSim service fixes verified
- Current failure count established

## Success Criteria
- Failure count reduced to <50
- No new failures introduced
- Clear documentation of fixes applied