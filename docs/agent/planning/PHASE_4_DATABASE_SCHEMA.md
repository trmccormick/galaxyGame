# Phase 4 Database Schema: Digital Twin & Simulation Models
**Date**: January 19, 2026
**Status**: Design Phase (Pre-implementation)

## Overview
Database schema design for Phase 4 Digital Twin Sandbox features, including transient simulation storage and result caching.

## New Models Required

### 1. DigitalTwin Model
**Purpose**: Persistent metadata for digital twin instances
**Storage**: Traditional database (not Redis) for audit trail

```ruby
# app/models/digital_twin.rb
class DigitalTwin < ApplicationRecord
  belongs_to :celestial_body
  belongs_to :created_by, class_name: 'User'  # admin user
  belongs_to :solar_system

  has_many :simulation_runs
  has_many :simulation_results

  enum status: {
    creating: 'creating',
    ready: 'ready',
    running_simulation: 'running_simulation',
    completed: 'completed',
    failed: 'failed',
    deleted: 'deleted'
  }

  # Attributes
  # t.string :name
  # t.text :description
  # t.integer :celestial_body_id
  # t.integer :solar_system_id
  # t.integer :created_by_id
  # t.string :status, default: 'creating'
  # t.jsonb :simulation_parameters
  # t.jsonb :initial_state_snapshot  # cloned data
  # t.datetime :created_at
  # t.datetime :updated_at
  # t.datetime :expires_at  # auto-cleanup

  validates :name, presence: true
  validates :celestial_body, presence: true
  validates :status, inclusion: { in: statuses.keys }

  # Cleanup expired twins
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :active, -> { where.not(status: :deleted) }
end
```

### 2. SimulationRun Model
**Purpose**: Track individual simulation executions
**Relationship**: Belongs to DigitalTwin

```ruby
# app/models/simulation_run.rb
class SimulationRun < ApplicationRecord
  belongs_to :digital_twin
  belongs_to :initiated_by, class_name: 'User'

  has_one :simulation_result

  enum status: {
    queued: 'queued',
    running: 'running',
    completed: 'completed',
    failed: 'failed',
    cancelled: 'cancelled'
  }

  enum pattern: {
    mars_terraform: 'mars_terraform',
    venus_industrial: 'venus_industrial',
    titan_fuel: 'titan_fuel',
    europa_ocean: 'europa_ocean',
    custom: 'custom'
  }

  # Attributes
  # t.integer :digital_twin_id
  # t.integer :initiated_by_id
  # t.string :status, default: 'queued'
  # t.string :pattern
  # t.integer :duration_years
  # t.jsonb :parameters
  # t.datetime :started_at
  # t.datetime :completed_at
  # t.text :error_message
  # t.float :progress, default: 0.0  # 0.0 to 1.0
  # t.datetime :created_at
  # t.datetime :updated_at

  validates :pattern, inclusion: { in: patterns.keys }
  validates :duration_years, numericality: { greater_than: 0, less_than_or_equal_to: 1000 }
end
```

### 3. SimulationResult Model
**Purpose**: Store complete simulation results and metrics
**Storage**: JSONB for flexible result data

```ruby
# app/models/simulation_result.rb
class SimulationResult < ApplicationRecord
  belongs_to :simulation_run
  belongs_to :digital_twin

  # Attributes
  # t.integer :simulation_run_id
  # t.integer :digital_twin_id
  # t.jsonb :start_state
  # t.jsonb :end_state
  # t.jsonb :key_events
  # t.jsonb :resource_consumption
  # t.jsonb :success_metrics
  # t.jsonb :performance_data
  # t.datetime :created_at

  # Success metrics structure
  # {
  #   habitability_score: 0.78,
  #   timeline_efficiency: 0.92,
  #   resource_efficiency: 0.85,
  #   cost_efficiency: 0.76
  # }

  # Key events structure
  # [
  #   {
  #     year: 15,
  #     event: 'oxygen_threshold_reached',
  #     description: 'Atmospheric O2 reached 0.1%',
  #     data: { o2_percentage: 0.1 }
  #   }
  # ]
end
```

### 4. LearnedPattern Model (Phase 5 Preview)
**Purpose**: Store AI-learned deployment patterns
**Status**: Design only (Phase 5)

```ruby
# Preview for Phase 5
class LearnedPattern < ApplicationRecord
  belongs_to :source_mission, class_name: 'Mission'
  belongs_to :created_by_pattern_extraction, class_name: 'User'

  has_many :pattern_applications

  # Attributes
  # t.string :pattern_id, unique: true
  # t.integer :source_mission_id
  # t.integer :created_by_id
  # t.float :success_score, default: 0.0
  # t.jsonb :required_conditions
  # t.jsonb :deployment_sequence
  # t.jsonb :optimizations
  # t.integer :times_applied, default: 0
  # t.float :success_rate, default: 0.0
end
```

## Migration Strategy

### Phase 4-A: Core Digital Twin Tables
```ruby
# db/migrate/20260119000000_create_digital_twins.rb
class CreateDigitalTwins < ActiveRecord::Migration[7.0]
  def change
    create_table :digital_twins do |t|
      t.string :name, null: false
      t.text :description
      t.references :celestial_body, null: false, foreign_key: true
      t.references :solar_system, null: false, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.string :status, default: 'creating'
      t.jsonb :simulation_parameters
      t.jsonb :initial_state_snapshot
      t.datetime :expires_at
      t.timestamps
    end

    add_index :digital_twins, :status
    add_index :digital_twins, :expires_at
    add_index :digital_twins, [:celestial_body_id, :status]
  end
end
```

### Phase 4-B: Simulation Tracking
```ruby
# db/migrate/20260119000001_create_simulation_runs.rb
class CreateSimulationRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :simulation_runs do |t|
      t.references :digital_twin, null: false, foreign_key: true
      t.references :initiated_by, foreign_key: { to_table: :users }
      t.string :status, default: 'queued'
      t.string :pattern
      t.integer :duration_years
      t.jsonb :parameters
      t.datetime :started_at
      t.datetime :completed_at
      t.text :error_message
      t.float :progress, default: 0.0
      t.timestamps
    end

    add_index :simulation_runs, :status
    add_index :simulation_runs, [:digital_twin_id, :status]
  end
end
```

### Phase 4-C: Results Storage
```ruby
# db/migrate/20260119000002_create_simulation_results.rb
class CreateSimulationResults < ActiveRecord::Migration[7.0]
  def change
    create_table :simulation_results do |t|
      t.references :simulation_run, null: false, foreign_key: true
      t.references :digital_twin, null: false, foreign_key: true
      t.jsonb :start_state
      t.jsonb :end_state
      t.jsonb :key_events
      t.jsonb :resource_consumption
      t.jsonb :success_metrics
      t.jsonb :performance_data
      t.timestamps
    end

    add_index :simulation_results, :simulation_run_id, unique: true
  end
end
```

## Redis/Transient Storage Strategy

### Digital Twin Transient Data
**Purpose**: Store cloned planetary data during simulation
**Structure**:
```
redis_key: "digital_twin:#{id}"
data: {
  atmosphere: { ... },
  hydrosphere: { ... },
  biosphere: { ... },
  geosphere: { ... },
  simulation_state: { ... }
}
```

### Simulation Job Queue
**Purpose**: Async processing of long-running simulations
**Implementation**: Sidekiq/ActiveJob with progress tracking

```ruby
# app/jobs/run_simulation_job.rb
class RunSimulationJob < ApplicationJob
  queue_as :simulation

  def perform(simulation_run_id)
    simulation_run = SimulationRun.find(simulation_run_id)
    # ... simulation logic with progress updates
  end
end
```

## Data Retention & Cleanup

### Automatic Cleanup
```ruby
# app/jobs/cleanup_expired_digital_twins_job.rb
class CleanupExpiredDigitalTwinsJob < ApplicationJob
  queue_as :maintenance

  def perform
    DigitalTwin.expired.each do |twin|
      # Remove Redis data
      Redis.current.del("digital_twin:#{twin.id}")

      # Mark as deleted (soft delete)
      twin.update(status: :deleted)
    end
  end
end
```

### Retention Policies
- **DigitalTwin records**: 90 days after expiration
- **SimulationRun records**: 1 year
- **SimulationResult records**: 2 years
- **Redis transient data**: Immediate cleanup on expiration

## Performance Considerations

### Indexing Strategy
- Composite indexes on frequently queried combinations
- JSONB GIN indexes for metadata searches
- Partial indexes for active records only

### Query Optimization
```ruby
# Efficient queries for admin dashboard
DigitalTwin.active.includes(:celestial_body, :simulation_runs)
  .where(solar_system_id: @solar_system.id)
  .order(created_at: :desc)
```

### Caching Strategy
- Cache simulation results for UI responsiveness
- Cache aggregated metrics for dashboard
- Use Redis for transient simulation state

## Migration Rollback Plan

### Safe Rollback
1. Stop all simulation jobs
2. Export any valuable simulation results
3. Run migrations in reverse order
4. Clean up Redis keys
5. Verify no orphaned records

### Data Preservation
- Simulation results can be exported as JSON before rollback
- Digital twin metadata preserved for audit trail
- Learned patterns (Phase 5) would require special handling

## Testing Strategy

### Model Tests
- Factory validation for all new models
- Association and validation testing
- JSONB data structure validation

### Integration Tests
- Full simulation workflow testing
- Cleanup job testing
- API endpoint testing with realistic data

### Performance Tests
- Large simulation result storage/retrieval
- Concurrent digital twin creation
- Cleanup job performance under load</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/development/planning/PHASE_4_DATABASE_SCHEMA.md