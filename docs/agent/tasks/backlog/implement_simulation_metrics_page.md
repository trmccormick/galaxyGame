# Implement Proper Simulation Metrics Page

## Problem Description
The "View Metrics" button in admin simulation currently redirects to the admin dashboard but is labeled as if it shows simulation metrics. This appears to be incomplete prototyping that needs proper implementation.

## Current Issue
- Button labeled "📊 View Metrics" but redirects to `/admin` dashboard
- Listed under "TESTING TOOLS" in simulation interface
- No actual metrics page exists for simulation performance/validation

## Required Implementation

### 1. Create Admin Metrics Controller and Route
Add new controller: `galaxy_game/app/controllers/admin/metrics_controller.rb`
```ruby
module Admin
  class MetricsController < ApplicationController
    def index
      # Load simulation metrics
      @simulation_metrics = load_simulation_metrics
      @system_health = load_system_health_metrics
      @ai_performance = load_ai_performance_metrics
    end

    private

    def load_simulation_metrics
      # Simulation execution times, success rates, etc.
    end

    def load_system_health_metrics
      # CPU, memory, database performance during simulations
    end

    def load_ai_performance_metrics
      # AI Manager decision quality, response times, etc.
    end
  end
end
```

Add route in `galaxy_game/config/routes.rb`:
```ruby
namespace :admin do
  get 'metrics', to: 'metrics#index'
end
```

### 2. Create Metrics View
Create `galaxy_game/app/views/admin/metrics/index.html.erb` with sections for:
- **Simulation Performance**: Execution times, throughput, queue status
- **System Health**: Resource usage, database load, cache performance
- **AI Metrics**: Decision quality, learning progress, prediction accuracy
- **Validation Metrics**: Error rates, convergence rates, drift detection

### 3. Update Simulation Page Button
Change the button in `galaxy_game/app/views/admin/simulation/index.html.erb`:
```erb
<button class="tool-button" onclick="window.location.href='/admin/metrics'">
    📊 View Metrics
</button>
```

### 4. Implement Metrics Collection
Add methods to collect real metrics:
- Background job monitoring (Sidekiq stats)
- Database query performance
- Memory/CPU usage tracking
- Simulation success/failure rates
- AI decision metrics

## Implementation Notes
- Follow SimEarth aesthetic (green terminal theme)
- Use charts/graphs for visual metrics display
- Include real-time updates where possible
- Add export functionality for metrics data
- Ensure proper error handling for missing data

## Acceptance Criteria
- "View Metrics" button opens dedicated metrics page
- Page shows simulation performance, system health, and AI metrics
- Real-time or near real-time data display
- Consistent with admin interface design
- No navigation confusion

## Priority
Medium - Improves admin monitoring capabilities

## Estimated Effort
4-6 hours (controller + view + metrics collection + styling)