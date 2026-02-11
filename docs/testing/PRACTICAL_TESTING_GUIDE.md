# Testing Guide - Galaxy Game

## Overview

Galaxy Game uses RSpec for comprehensive testing across unit, integration, and system levels. This guide covers practical testing workflows, debugging techniques, and CI/CD integration.

## Quick Start

### Running Tests

```bash
# Run all tests (in container)
docker-compose exec web rspec

# Run specific test file
docker-compose exec web rspec spec/models/celestial_body_spec.rb

# Run specific test
docker-compose exec web rspec spec/models/celestial_body_spec.rb:15

# Run tests with coverage
docker-compose exec web rspec --coverage
```

### ⚠️ Critical: Docker Volume Path Mapping

**IMPORTANT**: When running tests inside Docker containers, be aware of volume path mappings:

```yaml
# docker-compose.dev.yml volume mapping:
- ./data/logs:/home/galaxy_game/log
```

**Path Translation**:
- **Host machine**: `./data/logs/rspec_full_123456.log`
- **Inside container**: `/home/galaxy_game/log/rspec_full_123456.log` or `log/rspec_full_123456.log`

**Common Mistake**: Using `data/logs/` path inside container (doesn't exist)
```bash
# ❌ WRONG - tries to write to non-existent /home/galaxy_game/data/logs/
docker-compose exec web rspec --out data/logs/rspec_full_$(date +%s).log

# ✅ CORRECT - writes to mapped /home/galaxy_game/log/
docker-compose exec web rspec --out log/rspec_full_$(date +%s).log
```

**Log Location Reference**:
- **View logs on host**: `cat data/logs/rspec_full_*.log`
- **View logs in container**: `docker-compose exec web cat log/rspec_full_*.log`

### Logging Test Output

```bash
# Run tests with full documentation output to log file
docker-compose exec web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec --format=documentation --out log/rspec_full_\$(date +%s).log 2>&1"

# Run tests and show only last 20 lines (for monitoring progress)
docker-compose exec web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec --format=documentation --out log/rspec_full_\$(date +%s).log 2>&1 | tail -20"

# Check most recent test log
ls -t data/logs/rspec_full_*.log | head -1

# View test results
cat \$(ls -t data/logs/rspec_full_*.log | head -1)
```

### Test Structure

```
spec/
├── models/           # Unit tests for models
├── controllers/      # Controller tests
├── services/         # Service layer tests
├── integration/      # Feature/integration tests
├── support/          # Test helpers and shared examples
└── rails_helper.rb   # Test configuration
```

## Test Categories

### Unit Tests (Models)

**Location**: `spec/models/`
**Purpose**: Test individual model behavior

```ruby
# spec/models/celestial_body_spec.rb
RSpec.describe CelestialBodies::CelestialBody, type: :model do
  describe '#habitable?' do
    context 'with earth-like conditions' do
      let(:earth) { create(:celestial_body, :earth) }

      it 'returns true' do
        expect(earth.habitable?).to be true
      end
    end
  end
end
```

### Controller Tests

**Location**: `spec/controllers/`
**Purpose**: Test API endpoints and responses

```ruby
# spec/controllers/admin/celestial_bodies_controller_spec.rb
RSpec.describe Admin::CelestialBodiesController, type: :controller do
  describe 'GET #sphere_data' do
    let(:celestial_body) { create(:celestial_body) }

    before { get :sphere_data, params: { id: celestial_body.id } }

    it 'returns success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns sphere data' do
      json = JSON.parse(response.body)
      expect(json).to have_key('atmosphere')
      expect(json).to have_key('hydrosphere')
    end
  end
end
```

### Service Tests

**Location**: `spec/services/`
**Purpose**: Test business logic services

```ruby
# spec/services/ai_manager/mission_planner_spec.rb
RSpec.describe AiManager::MissionPlanner, type: :service do
  describe '#plan_missions' do
    let(:mars) { create(:celestial_body, :mars) }

    it 'creates resource extraction missions' do
      planner = described_class.new(mars)
      missions = planner.plan_missions

      expect(missions).to include(have_attributes(type: 'resource_extraction'))
    end
  end
end
```

### Integration Tests

**Location**: `spec/integration/`
**Purpose**: Test complete user workflows

```ruby
# spec/integration/admin_monitoring_spec.rb
RSpec.describe 'Admin Monitoring', type: :feature do
  scenario 'user views celestial body monitor' do
    celestial_body = create(:celestial_body, :earth)

    visit admin_celestial_body_monitor_path(celestial_body)

    expect(page).to have_content('Earth')
    expect(page).to have_selector('.sphere-data')
    expect(page).to have_selector('.terrain-canvas')
  end
end
```

## Debugging Failing Tests

### Common Failure Patterns

#### 1. Database State Issues
```ruby
# Problem: Test data not cleaned up
it 'fails due to leftover data' do
  create(:celestial_body, name: 'Test Body')
  # Test fails because another test created same data
end

# Solution: Use database_cleaner or proper cleanup
it 'works with proper cleanup' do
  celestial_body = create(:celestial_body, name: 'Unique Test Body')
  # Test passes
end
```

#### 2. Factory Issues
```ruby
# Problem: Factory creates invalid data
let(:invalid_body) { create(:celestial_body, mass: nil) }

# Solution: Check factory validity
it 'validates factory data' do
  expect(celestial_body).to be_valid
end
```

#### 3. Asynchronous Operations
```ruby
# Problem: Test doesn't wait for async operations
it 'fails because data not ready' do
  post :run_ai_test, params: { id: celestial_body.id, test_type: 'resource_extraction' }
  expect(response).to have_http_status(:success) # Passes
  # But AI operation still running...
end

# Solution: Wait for completion or mock async behavior
it 'waits for completion' do
  post :run_ai_test, params: { id: celestial_body.id, test_type: 'resource_extraction' }
  expect(response).to have_http_status(:success)

  # Wait for background job or check status
  perform_enqueued_jobs
  celestial_body.reload
  expect(celestial_body.ai_missions).to be_present
end
```

### Debugging Tools

#### 1. Pry for Interactive Debugging
```ruby
# Add to spec/rails_helper.rb
require 'pry'

# In test:
it 'debugs with pry' do
  celestial_body = create(:celestial_body)
  binding.pry  # Stops execution here
  expect(celestial_body.name).to eq('Test Body')
end
```

#### 2. Save and Open Page (Feature Tests)
```ruby
# In feature spec:
scenario 'debugs page content' do
  visit admin_celestial_body_monitor_path(celestial_body)
  save_and_open_page  # Opens page in browser
  expect(page).to have_content('Earth')
end
```

#### 3. Test Database Inspection
```ruby
# Check database state during test
it 'inspects database' do
  create(:celestial_body)
  CelestialBodies::CelestialBody.count  # => 1

  # Use for debugging
  puts CelestialBodies::CelestialBody.all.pluck(:name)
end
```

## Test Data Management

### Factories

**Location**: `spec/factories/`
**Purpose**: Consistent test data creation

```ruby
# spec/factories/celestial_bodies.rb
FactoryBot.define do
  factory :celestial_body, class: 'CelestialBodies::CelestialBody' do
    sequence(:name) { |n| "Test Body #{n}" }
    type { 'terrestrial_planet' }
    body_category { 'terrestrial_planet' }
    mass { 5.972e24 }
    radius { 6.371e6 }
    gravity { 9.81 }

    trait :earth do
      name { 'Earth' }
      # Earth-specific attributes
    end

    trait :mars do
      name { 'Mars' }
      mass { 6.39e23 }
      radius { 3.3895e6 }
      gravity { 3.71 }
    end
  end
end
```

### Test Helpers

**Location**: `spec/support/`
**Purpose**: Shared test utilities

```ruby
# spec/support/api_helpers.rb
module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end

  def auth_as_admin
    admin = create(:user, :admin)
    sign_in admin
  end
end

# spec/rails_helper.rb
RSpec.configure do |config|
  config.include ApiHelpers, type: :controller
end
```

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Test Suite
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2.5'
      - name: Install dependencies
        run: bundle install
      - name: Setup database
        run: |
          bundle exec rails db:create
          bundle exec rails db:migrate
      - name: Run tests
        run: bundle exec rspec
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### Parallel Testing

```bash
# Run tests in parallel
bundle exec parallel_rspec spec/

# Or with specific groups
bundle exec rspec --tag ~slow spec/
bundle exec rspec --tag slow spec/
```

## Performance Testing

### Request Specs Performance
```ruby
# spec/requests/api_performance_spec.rb
require 'rails_helper'
require 'rspec-benchmark'

RSpec.describe 'API Performance', type: :request do
  include RSpec::Benchmark::Matchers

  describe 'GET /admin/celestial_bodies/:id/sphere_data' do
    let(:celestial_body) { create(:celestial_body) }

    it 'responds quickly' do
      expect {
        get admin_celestial_body_sphere_data_path(celestial_body)
      }.to perform_under(100).ms
    end
  end
end
```

## Best Practices

### 1. Test Isolation
- Each test should be independent
- Use `before(:each)` for setup, not `before(:all)`
- Clean up test data properly

### 2. Descriptive Test Names
```ruby
# Bad
it 'works' do
  # ...
end

# Good
it 'calculates correct orbital period for earth-like planets' do
  # ...
end
```

### 3. Test What Matters
- Test behavior, not implementation details
- Focus on public APIs and user-facing features
- Avoid testing private methods directly

### 4. Test Edge Cases
```ruby
it 'handles missing atmosphere data gracefully' do
  celestial_body = create(:celestial_body, atmosphere: nil)

  get :sphere_data, params: { id: celestial_body.id }

  expect(json_response['atmosphere']).to eq('Not Present')
end
```

### 5. Use Appropriate Matchers
```ruby
# Good matchers
expect(response).to have_http_status(:success)
expect(user).to be_valid
expect(collection).to include(have_attributes(name: 'Earth'))
expect { action }.to change(Model, :count).by(1)
```

## Troubleshooting

### Test Suite Running Slowly

**Symptoms**: `rspec` command takes very long to complete

**Possible Causes**:
1. **Database connections not cleaned up**
2. **Heavy factory usage**
3. **Complex setup in before blocks**
4. **Large test database**

**Solutions**:
```ruby
# 1. Use database_cleaner
# 2. Optimize factories
# 3. Use build instead of create when possible
# 4. Run tests in parallel
```

### Intermittent Failures

**Symptoms**: Tests pass sometimes, fail others

**Common Causes**:
1. **Race conditions in async code**
2. **Time-dependent tests**
3. **Shared state between tests**

**Solutions**:
```ruby
# Use Timecop for time-dependent tests
# Ensure proper test isolation
# Use wait_for expectations for async code
```

### Factory Errors

**Symptoms**: `FactoryBot::InvalidFactoryError`

**Debugging**:
```ruby
# Check factory validity
factory = build(:celestial_body)
puts factory.valid?
puts factory.errors.full_messages

# Use create! to see validation errors
create!(:celestial_body) # Will raise with details
```

### Docker Path Mapping Issues

**Symptoms**: Test logs not appearing in expected location, or "No such file or directory" errors

**Common Causes**:
1. **Using host paths inside container**
2. **Incorrect volume mount assumptions**
3. **Writing to unmapped directories**

**Docker Volume Mappings** (from `docker-compose.dev.yml`):
```yaml
- ./data/logs:/home/galaxy_game/log    # Logs
- ./galaxy_game:/home/galaxy_game      # App code
- ./data/json-data:/home/galaxy_game/app/data  # JSON data
```

**Solutions**:
```bash
# ❌ WRONG - data/logs doesn't exist inside container
docker-compose exec web rspec --out data/logs/test.log

# ✅ CORRECT - use container-mapped path
docker-compose exec web rspec --out log/test.log

# Check what directories exist inside container
docker-compose exec web ls -la /home/galaxy_game/

# Verify volume mapping
docker-compose exec web ls -la log/  # Should show host data/logs contents
```

**File Location Translation**:
- **Host writes to**: `./data/logs/rspec_full_123.log`
- **Container writes to**: `log/rspec_full_123.log` or `/home/galaxy_game/log/rspec_full_123.log`
- **Both access same file** due to volume mapping

---

**Last Updated**: February 11, 2026
**Test Framework**: RSpec 3.12
**Coverage Tool**: SimpleCov