# Admin Monitoring System

## Overview

The Admin Monitoring System provides real-time monitoring and control interfaces for game systems using a SimEarth-inspired aesthetic. Built with a modular architecture, each admin section focuses on specific game subsystems.

## Architecture

### Design Pattern

All admin interfaces follow a consistent three-panel layout:
- **Left Panel (250px)**: Navigation, filters, or control lists
- **Main Panel (flex 1fr)**: Primary data display with data tables or visualizations
- **Right Panel (300px)**: Activity logs, console output, or statistics

### Visual Style (SimEarth Aesthetic)

```css
Background: #000 (black)
Text: #0f0 (green terminal)
Accent: #0ff (cyan)
Font: Courier New, monospace
Headers: 80px height, border-bottom: 2px solid #0f0
```

## Sections

### 1. AI Manager (`/admin/ai_manager`)

#### Mission Tracker (`/admin/ai_manager/missions`)

Monitors active AI missions with TaskExecutionEngine integration.

**Features:**
- Mission list separated by status (active/completed/failed)
- Progress tracking with percentage bars
- Real-time mission statistics
- Activity log console

**Controller:** `Admin::AiManagerController#missions`

```ruby
# Loads all missions with status separation
@missions = Mission.includes(:settlement).order(created_at: :desc)
@active_missions = @missions.where(status: [:in_progress])
@completed_missions = @missions.where(status: [:completed])
@failed_missions = @missions.where(status: [:failed, :stalled])
```

#### Mission Detail (`/admin/ai_manager/missions/:id`)

Displays detailed task breakdown for a specific mission.

**Features:**
- Complete task list with current/completed/pending indicators
- Task details: type, resource requirements, quantities, dependencies
- Mission controls: Advance Phase, Reset Mission
- Execution console with operational data
- Manifest data display (target location, objectives)

**Controller:** `Admin::AiManagerController#show_mission`

```ruby
# Integrates with TaskExecutionEngine
@engine = ::AIManager::TaskExecutionEngine.new(@mission.identifier)
@task_list = @engine.instance_variable_get(:@task_list)
@current_task_index = @engine.instance_variable_get(:@current_task_index)
@manifest = @engine.instance_variable_get(:@manifest)
```

**Testing Controls:**
- `POST /admin/ai_manager/advance_phase/:id` - Execute next task in mission
- `POST /admin/ai_manager/reset_mission/:id` - Reset mission to beginning

#### Mission Planner (`/admin/ai_manager/planner`)

What-if mission planning simulator with economic forecasting.

**Features:**
- **Configuration Panel**: Select mission pattern, tech level, timeline, budget, priority
- **Simulation Results**: Timeline breakdown, cost analysis, resource requirements, planetary changes
- **Economic Forecast**: GCC distribution analysis, demand forecasting, bottleneck identification, opportunity identification
- **Export Functionality**: Download complete simulation plan as JSON
- **Three-Panel Layout**: Config | Results | Forecast

**Controller:** `Admin::AiManagerController#planner`

```ruby
# Run simulation with parameters
@planner = AIManager::MissionPlannerService.new(
  params[:pattern],
  {
    tech_level: params[:tech_level] || 'standard',
    timeline_years: params[:timeline_years]&.to_i || 10,
    budget_gcc: params[:budget_gcc]&.to_i || 1_000_000,
    priority: params[:priority] || 'balanced'
  }
)

@simulation_result = @planner.simulate
@forecaster = AIManager::EconomicForecasterService.new(@simulation_result)
@forecast = @forecaster.analyze
```

**Available Mission Patterns:**
- `mars-terraforming` - Long-term atmospheric transformation
- `venus-industrial` - Cloud layer resource extraction
- `titan-fuel` - Methane harvesting and refining
- `asteroid-mining` - Resource extraction operations
- `europa-water` - Ice mining and water processing

**Simulation Results Include:**
- **Timeline**: Total duration, phase breakdown, key milestones
- **Costs**: Base cost, contingency (15%), grand total
- **Player Revenue**: Total contract opportunities, estimated contract count, average value
- **Resources**: Year-by-year requirements, peak demand period, total quantities
- **Planetary Changes**: Pattern-specific environmental changes

**Economic Forecast Provides:**
- **GCC Distribution**: DC vs player earnings, economic velocity (GCC/year)
- **Demand Forecast**: Resource trend (increasing/steady/declining), critical resources
- **Bottlenecks**: Resource spikes, concentrated demand periods with severity levels
- **Opportunities**: High-revenue years, bulk discount opportunities
- **Risk Assessment**: Financial (contingency), schedule (timeline), logistics (demand spikes)

**Export Action:**
- `POST /admin/ai_manager/export_plan` - Download JSON with full simulation data
- Includes pattern, parameters, results, timestamp, version

**Services:**
- `AIManager::MissionPlannerService` - Runs accelerated simulations
- `AIManager::EconomicForecasterService` - Analyzes economic implications

#### Decision Log (`/admin/ai_manager/decisions`)

Tracks AI decision-making processes and operational choices.

**Features:**
- Real-time decision log with filtering by type
- Decision outcomes (success/failure/pending)
- Decision categories: Resource Allocation, Contract Negotiation, Mission Planning, Settlement Ops
- Statistics dashboard with success rates and response times
- Auto-refresh capability for live monitoring

**Controller:** `Admin::AiManagerController#decisions`

```ruby
# Decision tracking (currently stub implementation)
@decisions = []
```

#### Pattern Library (`/admin/ai_manager/patterns`)

Mission pattern testing and management interface.

**Features:**
- Pattern library with activation/deactivation controls
- Testing interface for pattern validation
- Pattern metadata: target bodies, complexity, success rates
- Configuration testing with tech level and budget parameters
- Pattern status indicators (active/inactive)

**Controller:** `Admin::AiManagerController#patterns`

```ruby
# Pattern management (currently stub implementation)
@patterns = []
```

#### Performance Metrics (`/admin/ai_manager/performance`)

AI system performance monitoring and optimization controls.

**Features:**
- Key performance indicators: Success rate, timeline efficiency, resource utilization
- System health monitoring with status indicators
- Performance controls: Decision timeouts, concurrent mission limits, resource thresholds
- Mission performance table with detailed breakdowns
- Trend analysis and bottleneck identification

**Controller:** `Admin::AiManagerController#performance`

```ruby
# Performance metrics (currently stub implementation)
@metrics = {
  success_rate: 0,
  average_timeline: 0,
  resource_efficiency: 0
}
```

### 2. Celestial Bodies (`/admin/celestial_bodies`)

#### Index (`/admin/celestial_bodies`)

Overview page listing all celestial bodies for monitoring selection.

**Features:**
- Complete celestial body catalog with type classification
- Statistics dashboard (total bodies, planets, moons, asteroids)
- Grouped display by celestial body type
- Direct links to individual body monitors
- Body details: mass, radius, temperature, atmosphere status

**Controller:** `Admin::CelestialBodiesController#index`

```ruby
# Load all celestial bodies for monitoring selection
@celestial_bodies = CelestialBodies::CelestialBody.all.order(:name)
@total_bodies = @celestial_bodies.count
@bodies_by_type = @celestial_bodies.group_by(&:type)
```

#### Monitor (`/admin/celestial_bodies/:id/monitor`)

Real-time planetary monitoring with sphere-based data visualization.

**Features:**
- Live planetary sphere data (atmosphere, hydrosphere, geosphere, biosphere)
- AI mission log for planet-specific missions
- AI testing console with predefined test scenarios
- Geological features tracking

**Controller:** `Admin::CelestialBodiesController#monitor`

**Data Endpoints:**
- `GET /admin/celestial_bodies/:id/sphere_data.json` - Live sphere metrics
- `GET /admin/celestial_bodies/:id/mission_log.json` - Mission activity
- `POST /admin/celestial_bodies/:id/run_ai_test` - Execute AI tests

**AI Test Types:**
- `resource_extraction` - Test resource gathering capabilities
- `base_construction` - Test base building procedures
- `isru_pipeline` - Test in-situ resource utilization

### 3. Development Corporations (`/admin/development_corporations`)

Monitor DC activities and economic performance.

**Features:**
- List all Development Corporation organizations
- Show settlements owned by each DC with locations
- Display GCC balances for each corporation
- Track active logistics contracts count
- Link to celestial body monitor for each DC base
- Statistics panel: total DCs, settlements, active contracts
- Production capabilities tracking (structures and units)

**Controller:** `Admin::DevelopmentCorporationsController#index`

```ruby
# Loads all Development Corporation organizations
@development_corporations = Organizations::BaseOrganization
  .where(organization_type: :development_corporation)
  .includes(:accounts)
  .order(:name)

# Groups settlements by DC owner
@dc_settlements = Settlement::BaseSettlement
  .where(owner_type: 'Organizations::BaseOrganization', owner_id: @development_corporations.pluck(:id))
  .includes(:location)
  .group_by(&:owner_id)

# Loads active contracts for DC settlements
@active_contracts = Logistics::Contract.active
  .where('from_settlement_id IN (?) OR to_settlement_id IN (?)', settlement_ids, settlement_ids)
```

**Data Models:**
- `Organizations::BaseOrganization` - DC records (organization_type: :development_corporation)
- `Settlement::BaseSettlement` - Settlements owned by DCs (polymorphic owner)
- `Logistics::Contract` - Active supply contracts between settlements
- `Financial::Account` - GCC balances for each DC

**DC Cards Display:**
- DC name and identifier (e.g., LDC, MDC, VDC)
- GCC balance with human-readable format (K/M/B)
- Settlement count and list
- Active contracts count
- Settlement locations with celestial body links
- [MONITOR] links to celestial body monitor views

### 4. Settlements (`/admin/settlements`)

Settlement status and resource monitoring (stub).

**Controller:** `Admin::SettlementsController`

### 5. Resources (`/admin/resources/flows`)

Track resource flows and economic chains (stub).

**Controller:** `Admin::ResourcesController`

### 6. Simulation (`/admin/simulation`)

Central simulation control and status monitoring (stub).

**Controller:** `Admin::SimulationController`

## Routes

```ruby
namespace :admin do
  # Dashboard
  get 'dashboard', to: 'dashboard#index'
  
  # AI Manager
  get 'ai_manager/missions', to: 'ai_manager#missions', as: 'ai_manager_missions'
  get 'ai_manager/missions/:id', to: 'ai_manager#show_mission', as: 'ai_manager_mission'
  post 'ai_manager/advance_phase/:id', to: 'ai_manager#advance_phase', as: 'ai_manager_advance_phase'
  post 'ai_manager/reset_mission/:id', to: 'ai_manager#reset_mission', as: 'ai_manager_reset_mission'
  get 'ai_manager/planner', to: 'ai_manager#planner', as: 'ai_manager_planner'
  post 'ai_manager/export_plan', to: 'ai_manager#export_plan', as: 'ai_manager_export_plan'
  
  # Celestial Bodies
  resources :celestial_bodies, only: [] do
    member do
      get :monitor
      get :sphere_data
      get :mission_log
      post :run_ai_test
    end
  end
  
  # Other sections (stub controllers)
  resources :development_corporations, only: [:index]
  resources :settlements, only: [:index]
  resources :resources, only: [] do
    collection do
      get :flows
    end
  end
  resources :simulation, only: [:index]
end
```

## Testing

All admin controllers have comprehensive RSpec coverage.

### Running Tests

```bash
# All admin controller tests
docker-compose exec web bundle exec rspec spec/controllers/admin/

# Specific controller
docker-compose exec web bundle exec rspec spec/controllers/admin/ai_manager_controller_spec.rb
```

### Test Coverage

- **AI Manager Controller**: 11 examples
  - Mission loading and status separation
  - Mission detail view with TaskExecutionEngine integration
  - Phase advancement controls
  - Mission reset functionality
  - Mission planner simulator configuration
  - Simulation execution with custom parameters
  - Economic forecast generation
  - Plan export as JSON
  
- **AI Manager Services**: 25 examples
  - **MissionPlannerService** (12 examples): Pattern initialization, resource calculations, cost analysis, timeline generation, planetary changes simulation, contract generation, plan export
  - **EconomicForecasterService** (13 examples): Demand forecasting, GCC distribution, bottleneck identification, opportunity detection, risk assessment, scenario comparison
  
- **Celestial Bodies Controller**: 29 examples
  - Monitor view rendering
  - Sphere data JSON endpoints
  - Mission log tracking
  - AI test execution

- **Development Corporations Controller**: 5 examples
  - DC loading with settlements and accounts
  - Settlement grouping by DC owner
  - Active contracts counting
  - Organization type separation (DCs, Service Corps, Consortiums)

**Total**: 70 examples (45 controllers + 25 services), 0 failures

## Implementation Notes

### TaskExecutionEngine Integration

The AI Manager mission tracker integrates directly with the existing `AIManager::TaskExecutionEngine` service:

1. **Module Loading**: Requires `app/services/ai_manager.rb` which loads all AIManager services
2. **Instance Variable Access**: Extracts private data using `instance_variable_get`:
   - `@task_list` - Array of mission tasks
   - `@current_task_index` - Index of current task
   - `@manifest` - Mission configuration data
3. **Task Execution**: Calls `engine.execute_next_task` to advance mission phases
4. **Data Files**: Tasks loaded from JSON files in `app/data/missions/{mission-identifier}/`

### Error Handling

Controllers implement consistent error handling:

```ruby
rescue ActiveRecord::RecordNotFound
  redirect_to admin_ai_manager_missions_path, alert: "Mission not found"
end
```

### Flash Messages

Standard flash message types:
- `notice` - Success messages (green)
- `alert` - Error/warning messages (red)

## Future Enhancements

### Phase 1 (Stub Controllers)
- Implement DC monitoring with financial metrics
- Build settlement resource tracking
- Create resource flow visualization
- Develop simulation control interface

### Phase 2 (Advanced Features)
- Real-time WebSocket updates for live data
- AI decision logging and pattern analysis
- Performance metrics dashboard
- Mission success/failure analytics
- Automated testing suite for AI scenarios

### Phase 3 (Integration)
- Cross-section data correlation
- Automated alert system
- Mission scheduling and queuing
- Comprehensive audit logging

## Contributing

When adding new admin sections:

1. **Follow the pattern**: Use three-panel layout with SimEarth aesthetic
2. **Create stub action**: Start with placeholder data
3. **Add routes**: Namespace under `admin/`
4. **Write specs**: Minimum controller action coverage
5. **Update dashboard**: Add navigation link in `app/views/admin/dashboard/index.html.erb`
6. **Document**: Add section to this file

## Resources

- **Stylesheets**: `app/assets/stylesheets/admin/monitor.css`
- **Controllers**: `app/controllers/admin/`
- **Views**: `app/views/admin/`
- **Specs**: `spec/controllers/admin/`
- **Routes**: `config/routes.rb` (admin namespace)
