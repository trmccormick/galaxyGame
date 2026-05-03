# Manual TerraSim Test Execution

## Task Overview
Execute TerraSim verification tests manually in Docker environment to validate conservative physics fixes and assess current failure count.

## Specific Steps

### 1. Access Docker Container
```bash
docker-compose -f docker-compose.dev.yml exec web bash
```

### 2. Run TerraSim Service Tests
```bash
# Unset DATABASE_URL to use test database
unset DATABASE_URL

# Run TerraSim services with documentation format
RAILS_ENV=test bundle exec rspec spec/services/terra_sim/hydrosphere_simulation_service_spec.rb spec/services/terra_sim/atmosphere_simulation_service_spec.rb --format documentation
```

### 3. Verify Conservative Physics Behavior
**Hydrosphere Service:**
- ✅ Evaporation rates: ~1e-8 (minimal changes)
- ✅ Ice melting: ≤1% per cycle (capped behavior)
- ✅ State distribution: Small/no measurable changes

**Atmosphere Service:**
- ✅ Temperature clamping: All temperatures between 150-400K
- ✅ Greenhouse effects: Capped at 2x base temperature
- ✅ Temperature updates: Proper clamping validation

### 4. Run Full Test Suite Assessment
```bash
# Get current failure count
RAILS_ENV=test bundle exec rspec --format progress | grep -E "(failures|errors)"
```

### 5. Document Results
- TerraSim service test status (pass/fail)
- Current total failure count
- Top failure patterns for systematic reduction

## Expected Outcome
- Confirmation that TerraSim fixes work (should reduce failures by ~7-10)
- Current failure count assessment (target: <50 total)
- Clear identification of remaining failure patterns

## Dependencies
- TerraSim verification task completed (code changes verified)
- Docker environment available

## Success Criteria
- TerraSim tests execute successfully
- Conservative physics behavior validated
- Failure count and patterns documented for next phase

## Troubleshooting
- If tests fail due to missing methods: Check atmosphere temperature clamping implementation
- If database errors: Ensure proper test database setup
- If container issues: Verify docker-compose configuration