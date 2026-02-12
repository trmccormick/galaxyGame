# TerraSim Test Suite Verification

## Task Overview
Verify the TerraSim service test fixes are working correctly and assess current failure count.

## Specific Steps
1. Run TerraSim service verification:
   ```
   bundle exec rspec spec/services/terra_sim/hydrosphere_simulation_service_spec.rb spec/services/terra_sim/atmosphere_simulation_service_spec.rb --format documentation
   ```

2. Confirm conservative physics behavior:
   - Temperature clamping between 150-400K
   - Minimal evaporation rates (~1e-8)
   - Ice melting capped at ≤1% per cycle
   - Greenhouse effects limited to 2x base temperature

3. Run full test suite to get current failure count:
   ```
   bundle exec rspec --format progress | grep -E "(failures|errors)"
   ```

## Expected Outcome
- TerraSim services pass with conservative physics
- Current failure count reported (target: reduce from 408 to <50)
- Identification of remaining failure patterns

## Dependencies
- Database cleaner consolidation completed
- TerraSim test expectations updated

## Success Criteria
- TerraSim verification tests pass
- Clear report of current failure count and patterns