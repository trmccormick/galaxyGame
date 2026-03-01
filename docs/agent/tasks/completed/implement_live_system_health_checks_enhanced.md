# Task: Implement Live System Health Checks for AI Manager Validation Suite

## Overview
The current "System Health" section in the AI Manager validation suite UI displays only stub values ("Checking..."), with no live backend integration. This task is to implement real-time health checks for all system indicators in the validation view.

## Requirements

### Backend Implementation
- Replace all stubbed values in the System Health section with live data
- Implement backend endpoint for health checks (AJAX JSON response)
- Health checks should include:
  - **AI Service Status**: Check if AIManager services can be instantiated
  - **Database Connection**: Verify ActiveRecord connection is alive
  - **Pattern Availability**: Count loaded mission patterns and validate structure
  - **Performance Metrics**: Response time, memory usage, queue sizes

### Frontend Implementation  
- Update JavaScript to fetch live data via AJAX on page load
- Implement auto-refresh every 30 seconds
- Add manual refresh button
- Display loading states during health check
- Handle errors gracefully (timeout, service down, etc.)

### Testing & Quality
- Add RSpec tests for health check endpoint
- Test error conditions (DB down, service unavailable)
- Ensure response time < 2 seconds for all checks
- Add integration tests for frontend AJAX calls

### Documentation
- Document health check endpoint in API docs
- Add developer notes on extending health checks
- Update README with troubleshooting for failed health checks

## Detailed Implementation Plan

### 1. Create Health Check Endpoint

**Route:**
```ruby
# config/routes.rb
namespace :admin do
  namespace :ai_manager do
    get 'health_check', to: 'ai_manager#health_check'
  end
end
```

**Controller Action:**
```ruby
# app/controllers/admin/ai_manager_controller.rb
def health_check
  render json: {
    ai_service: check_ai_service,
    database: check_database,
    patterns: check_patterns,
    performance: check_performance,
    timestamp: Time.current
  }
end

private

def check_ai_service
  # Try to instantiate key AI services
  services = {}
  
  [
    [:mission_planner, AIManager::MissionPlannerService],
    [:economic_forecaster, AIManager::EconomicForecasterService],
    [:station_construction, AIManager::StationConstructionStrategy]
  ].each do |name, klass|
    services[name] = begin
      klass.new({})
      { status: 'operational', message: 'Service available' }
    rescue => e
      { status: 'error', message: e.message }
    end
  end
  
  all_operational = services.values.all? { |s| s[:status] == 'operational' }
  
  {
    status: all_operational ? 'operational' : 'degraded',
    services: services
  }
end

def check_database
  ActiveRecord::Base.connection.active?
  {
    status: 'connected',
    message: 'Database connection active',
    pool_size: ActiveRecord::Base.connection_pool.size,
    active_connections: ActiveRecord::Base.connection_pool.connections.count
  }
rescue => e
  {
    status: 'error',
    message: e.message
  }
end

def check_patterns
  # Check if mission patterns directory exists and is readable
  patterns = available_mission_patterns
  
  {
    status: patterns.any? ? 'available' : 'missing',
    count: patterns.size,
    patterns: patterns.keys,
    message: "#{patterns.size} patterns loaded"
  }
rescue => e
  {
    status: 'error',
    message: e.message
  }
end

def check_performance
  start_time = Time.current
  
  # Run a simple query to measure DB response
  Mission.count
  
  response_time = ((Time.current - start_time) * 1000).round(2) # ms
  
  {
    response_time_ms: response_time,
    status: response_time < 1000 ? 'fast' : 'slow',
    memory_mb: get_memory_usage,
    queue_size: get_queue_size
  }
end

def get_memory_usage
  # Get current Ruby process memory (simplified)
  `ps -o rss= -p #{Process.pid}`.to_i / 1024 rescue nil
end

def get_queue_size
  # Check Sidekiq queue if available
  Sidekiq::Queue.new.size rescue 0
end
```

### 2. Update Frontend JavaScript

**In validation.html.erb:**
```javascript
let healthCheckInterval = null;

async function fetchHealthStatus() {
    try {
        const response = await fetch('/admin/ai_manager/health_check');
        const data = await response.json();
        
        updateHealthCards(data);
        log('Health check completed', 'success');
    } catch (error) {
        log('Health check failed: ' + error.message, 'error');
        setAllHealthCardsError();
    }
}

function updateHealthCards(data) {
    // AI Service
    const aiStatus = data.ai_service.status === 'operational' ? 'pass' : 'fail';
    const aiText = data.ai_service.status === 'operational' ? 
        '✅ Online' : '❌ ' + data.ai_service.status;
    updateHealthCard('health-ai-service', aiStatus, aiText);
    
    // Database
    const dbStatus = data.database.status === 'connected' ? 'pass' : 'fail';
    const dbText = data.database.status === 'connected' ? 
        `✅ ${data.database.active_connections}/${data.database.pool_size} connections` : 
        '❌ Disconnected';
    updateHealthCard('health-database', dbStatus, dbText);
    
    // Patterns
    const patternStatus = data.patterns.status === 'available' ? 'pass' : 'fail';
    const patternText = data.patterns.status === 'available' ? 
        `✅ ${data.patterns.count} Loaded` : '❌ Missing';
    updateHealthCard('health-patterns', patternStatus, patternText);
    
    // Performance
    const perfStatus = data.performance.status === 'fast' ? 'pass' : 'warn';
    const perfText = `${data.performance.response_time_ms}ms`;
    updateHealthCard('health-performance', perfStatus, perfText);
}

function startAutoRefresh() {
    // Initial check
    fetchHealthStatus();
    
    // Refresh every 30 seconds
    healthCheckInterval = setInterval(fetchHealthStatus, 30000);
}

// Start on page load
document.addEventListener('DOMContentLoaded', startAutoRefresh);
```

### 3. RSpec Tests

**spec/controllers/admin/ai_manager_controller_spec.rb:**
```ruby
describe 'GET #health_check' do
  it 'returns health status as JSON' do
    get :health_check
    expect(response).to have_http_status(:success)
    expect(response.content_type).to include('application/json')
    
    json = JSON.parse(response.body)
    expect(json).to have_key('ai_service')
    expect(json).to have_key('database')
    expect(json).to have_key('patterns')
    expect(json).to have_key('performance')
  end
  
  it 'checks AI service status' do
    get :health_check
    json = JSON.parse(response.body)
    
    expect(json['ai_service']).to have_key('status')
    expect(json['ai_service']).to have_key('services')
  end
  
  it 'checks database connection' do
    get :health_check
    json = JSON.parse(response.body)
    
    expect(json['database']['status']).to eq('connected')
  end
  
  it 'handles database errors gracefully' do
    allow(ActiveRecord::Base.connection).to receive(:active?).and_raise(StandardError)
    
    get :health_check
    json = JSON.parse(response.body)
    
    expect(json['database']['status']).to eq('error')
  end
end
```

## Acceptance Criteria
- ✅ All health cards in the validation view display live, accurate status
- ✅ No stubbed or hardcoded values remain in the System Health section
- ✅ Health checks run automatically on page load
- ✅ Auto-refresh every 30 seconds
- ✅ Response time < 2 seconds per health check
- ✅ All new code is covered by RSpec tests and passes in Docker
- ✅ Error conditions handled gracefully (timeouts, service down)
- ✅ Documentation updated with new endpoint details

## Files to Modify
- `config/routes.rb` - Add health_check route
- `app/controllers/admin/ai_manager_controller.rb` - Add health_check action
- `app/views/admin/ai_manager/testing/validation.html.erb` - Update JavaScript
- `spec/controllers/admin/ai_manager_controller_spec.rb` - Add health check tests

## Estimated Effort
- Backend implementation: 2-3 hours
- Frontend integration: 1-2 hours  
- Testing: 1-2 hours
- Total: 4-7 hours

## Future Enhancements (Out of Scope)
- WebSocket support for real-time updates
- Historical health status graphs
- Alert notifications for degraded services
- Health check for external APIs (if any)
- Detailed memory profiling

---

**Created:** 2026-02-19  
**Updated:** 2026-02-20  
**Status:** Backlog  
**Priority:** Medium  
**Owner:** Unassigned  
**Labels:** backend, frontend, testing, ai-manager
