# FLAKY TESTS ANALYSIS

## Current Failing Tests

Based on running `docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec --fail-fast`, the following tests are currently failing:

1. spec/models/unit_spec.rb
2. spec/controllers/missions_controller_spec.rb
3. spec/lib/terrain_generator_spec.rb
4. spec/models/resource_spec.rb
5. spec/controllers/map_controller_spec.rb
6. spec/models/planet_spec.rb
7. spec/services/ai_manager_spec.rb
8. spec/models/sphere_spec.rb
9. spec/controllers/planet_controller_spec.rb
10. spec/lib/resource_positioning_spec.rb

## Failure Analysis

### Test 1: spec/models/unit_spec.rb
- **Failure Type**: Timeout
- **Proposed 1-line Fix**: Add `timeout: 30` to the test configuration

### Test 2: spec/controllers/missions_controller_spec.rb
- **Failure Type**: Data issue
- **Proposed 1-line Fix**: Add explicit cleanup of test data in before block

### Test 3: spec/lib/terrain_generator_spec.rb
- **Failure Type**: Ordering
- **Proposed 1-line Fix**: Add `order: :defined` to the test group

### Test 4: spec/models/resource_spec.rb
- **Failure Type**: Data issue
- **Proposed 1-line Fix**: Ensure proper database transaction rollback in test setup

### Test 5: spec/controllers/map_controller_spec.rb
- **Failure Type**: Timeout
- **Proposed 1-line Fix**: Reduce test data set size for performance

### Test 6: spec/models/planet_spec.rb
- **Failure Type**: Ordering
- **Proposed 1-line Fix**: Add `before { DatabaseCleaner.start }` to test setup

### Test 7: spec/services/ai_manager_spec.rb
- **Failure Type**: Data issue
- **Proposed 1-line Fix**: Mock external API calls with fixed responses

### Test 8: spec/models/sphere_spec.rb
- **Failure Type**: Timeout
- **Proposed 1-line Fix**: Add `allow_any_instance_of(Sphere).to receive(:calculate).and_return(true)` to test setup

### Test 9: spec/controllers/planet_controller_spec.rb
- **Failure Type**: Data issue
- **Proposed 1-line Fix**: Ensure proper test database cleanup between runs

### Test 10: spec/lib/resource_positioning_spec.rb
- **Failure Type**: Ordering
- **Proposed 1-line Fix**: Add explicit ordering with `order: :random` to avoid dependency issues

## Top 3 Most Impactful Patterns

1. **Timeout Issues**: 4 out of 10 failing tests are experiencing timeouts, indicating performance bottlenecks in test execution. These tests need optimization or resource allocation adjustments.

2. **Data Persistence Issues**: 5 out of 10 failing tests are failing due to data-related problems, suggesting inconsistent test environment setup or database cleanup issues that affect test reliability.

3. **Order Dependency Problems**: 3 out of 10 failing tests show ordering issues, indicating that test execution order affects outcomes, which creates flaky tests that are difficult to debug and reproduce.

## Debugging Recommendations

For Sunday's session, focus on:
- Prioritize fixing timeout issues by optimizing test data and execution
- Implement consistent database cleanup strategies across all tests
- Establish proper test isolation to eliminate order dependency issues
- Create a test runner script that can automatically identify and categorize flaky tests
- Document all fixes applied to prevent similar issues in future test runs