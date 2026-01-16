# AI Manager Mission Planner UI

## Overview

The AI Manager Mission Planner provides a SimEarth-style interface for simulating large-scale planetary missions before execution. It allows Development Corporation administrators to:

1. Configure mission parameters (pattern, tech level, timeline, budget, priority)
2. Run accelerated simulations to forecast costs, resources, and timelines
3. Analyze economic impacts on player opportunities
4. Identify bottlenecks and risks before committing resources
5. Export plans as JSON or generate actual SupplyContract records

**Route**: `/admin/ai_manager/planner`

## UI Architecture

### Three-Panel Layout

The interface uses a grid layout with three equal-width panels matching the terminal aesthetic from the missions view:

#### LEFT PANEL: Configuration Form (300px)
- **Pattern Selector**: Dropdown loading from `@available_patterns`
  - mars-terraforming
  - venus-industrial
  - titan-fuel
  - asteroid-mining
  - europa-water
- **Tech Level**: Standard / Advanced / Experimental
- **Timeline**: 5-50 years (numeric input)
- **Budget**: 100,000 - ∞ GCC (numeric input with 100k steps)
- **Priority**: Balanced / Speed / Efficiency / Reliability
- **[RUN SIMULATION]** button (green terminal style)
- **[EXPORT PLAN]** button (cyan, appears after simulation)

#### CENTER PANEL: Simulation Results
Displays after simulation completes:
- **Timeline Breakdown**
  - Total years
  - Phases (with names and durations)
  - Milestones
- **Cost Analysis**
  - Base cost
  - Contingency (buffer for overruns)
  - Grand total (cyan highlight)
- **Player Revenue Opportunities**
  - Total opportunity GCC
  - Estimated contract count
  - Average contract value
- **Resource Requirements**
  - Peak demand year
  - Top 10 resources by total quantity
  - Scrollable list
- **Planetary Changes** (pattern-specific)
  - Atmospheric changes (Mars, Venus)
  - Fuel production rates (Titan)
  - Mining yields (Asteroids)
  - Water extraction (Europa)

#### RIGHT PANEL: Economic Forecast (350px)
Displays after simulation completes:
- **GCC Flow Analysis**
  - Total project cost
  - DC vs Player percentage split
  - Economic velocity (GCC/year)
- **Demand Forecast**
  - Trend (rising/stable/declining)
  - Peak demand year and quantity
  - Critical resources count
- **Bottlenecks** (red border, warning color)
  - Resource name or year
  - Severity level
  - Recommendation
  - Shows top 3
- **Opportunities** (cyan border)
  - Opportunity type
  - Description
  - Shows top 3
- **Risk Assessment** (yellow border)
  - Risk category
  - Severity
  - Description
  - Mitigation strategy

## Service Integration Points

### MissionPlannerService
**Location**: `app/services/ai_manager/mission_planner_service.rb`

Initialized with:
```ruby
@planner = AIManager::MissionPlannerService.new(
  pattern_name,
  {
    tech_level: 'standard' | 'advanced' | 'experimental',
    timeline_years: 5..50,
    budget_gcc: 100_000+,
    priority: 'balanced' | 'speed' | 'efficiency' | 'reliability'
  }
)
```

Methods:
- `simulate()` → Returns `@simulation_result` hash
- `create_contracts()` → Generates PlayerContract records
- `export_plan()` → Returns JSON string

Simulation result structure:
```ruby
{
  timeline: {
    total_years: Integer,
    phases: [{ name: String, duration: Integer }],
    milestones: [{ year: Integer, description: String }]
  },
  resources: {
    by_year: { year => { resource => quantity } },
    total: { resource => total_quantity },
    peak_demand: { year: Integer, total_units: Integer }
  },
  costs: {
    total_gcc: Float,
    contingency: Float,
    grand_total: Float,
    breakdown: { category => cost }
  },
  player_revenue: {
    total_opportunity_gcc: Float,
    contract_count: Integer,
    average_contract_value: Float
  },
  planetary_changes: {
    # Pattern-specific data
  }
}
```

### EconomicForecasterService
**Location**: `app/services/ai_manager/economic_forecaster_service.rb`

Initialized with simulation results:
```ruby
@forecaster = AIManager::EconomicForecasterService.new(@simulation_result)
@forecast = @forecaster.analyze
```

Returns:
```ruby
{
  gcc_distribution: {
    total_project_cost: Float,
    dc_expenditure: Float,
    player_earnings: Float,
    dc_percentage: Float,
    player_percentage: Float,
    economic_velocity: Float
  },
  demand_forecast: {
    total_demand: Hash,
    peak_demand: { year: Integer, total_units: Integer },
    demand_curve: { trend: String },
    critical_resources: Array
  },
  bottlenecks: [
    {
      resource: String,
      year: Integer,
      quantity: Integer,
      severity: 'low' | 'medium' | 'high',
      recommendation: String
    }
  ],
  opportunities: [
    {
      type: String,
      description: String,
      gcc_potential: Float
    }
  ],
  risk_assessment: [
    {
      category: String,
      severity: String,
      description: String,
      mitigation: String
    }
  ]
}
```

## Pattern Name Mapping

The controller uses simplified UI names but JSON files use different identifiers. The `available_mission_patterns` private helper method provides mapping:

```ruby
def available_mission_patterns
  {
    'mars-terraforming' => 'mars_pattern',
    'venus-industrial' => 'venus_pattern', 
    'titan-fuel' => 'titan_pattern',
    'asteroid-mining' => 'gcc_mining_satellite_01_pattern',
    'europa-water' => 'europa_subsurface_exploration_pattern'
  }
end
```

**Current Status**: This mapping is defined but not yet actively used. Currently, simplified names are passed directly to services which use synthetic data.

## Controller Actions

### GET `/admin/ai_manager/planner`
- Initializes `@available_patterns` array
- If `params[:pattern]` present:
  - Creates `MissionPlannerService` with parameters
  - Calls `simulate()` to get `@simulation_result`
  - Creates `EconomicForecasterService` with results
  - Calls `analyze()` to get `@forecast`
- Renders three-panel view

### POST `/admin/ai_manager/export_plan`
- Creates `MissionPlannerService` with parameters
- Runs simulation
- Calls `export_plan()` to generate JSON
- Returns file download:
  - Filename: `mission_plan_{pattern}_{timestamp}.json`
  - Content-Type: `application/json`

## Testing

**Spec Location**: `spec/controllers/admin/ai_manager_controller_spec.rb`

Tests cover:
1. ✅ GET planner loads available patterns
2. ✅ GET planner without pattern doesn't run simulation
3. ✅ GET planner with pattern runs simulation
4. ✅ GET planner uses default parameters if not provided
5. ✅ POST export_plan returns JSON download
6. ✅ POST export_plan includes pattern and results

**Run specs in docker**:
```bash
docker exec -it web bash -c "cd /home/galaxy_game && bundle exec rspec spec/controllers/admin/ai_manager_controller_spec.rb"
```

All 11 examples pass (0 failures).

## Current Implementation Status

### ✅ Complete
- Three-panel UI with SimEarth aesthetic
- Pattern selection dropdown
- Configuration form (tech level, timeline, budget, priority)
- Simulation results display
- Economic forecast display
- Export plan functionality
- Controller specs (100% passing)
- Pattern name mapping helper

### 🔄 Using Synthetic Data
Currently, both services use synthetic/calculated data rather than loading actual JSON patterns:

**MissionPlannerService**:
- `estimate_phases()` - Calculates synthetic phases based on timeline
- `estimate_year_resources()` - Generates synthetic resource demands
- `estimate_unit_cost()` - Uses simplified cost calculations

**EconomicForecasterService**:
- All calculations based on simulation results
- No external data sources

## Future Enhancements

### 1. Load Actual Pattern Data
**File**: `data/json-data/ai-manager/mission_profile_patterns.json`

Update `MissionPlannerService.load_pattern_data()` to:
```ruby
def load_pattern_data
  pattern_id = available_mission_patterns[@pattern] || @pattern
  file_path = Rails.root.join('app/data/ai-manager/mission_profile_patterns.json')
  
  if File.exist?(file_path)
    all_patterns = JSON.parse(File.read(file_path))
    pattern = all_patterns['patterns'].find { |p| p['pattern_id'] == pattern_id }
    return pattern if pattern
  end
  
  # Fallback to synthetic data
  generate_synthetic_pattern
end
```

### 2. Integrate TerraSim for Planetary Calculations
Replace synthetic planetary changes with actual TerraSim computations:

**Mars Terraforming**:
```ruby
terrasim = Terrasim::Mars.new(@parameters[:timeline_years])
terrasim.add_greenhouse_gases(@simulation_result[:resources][:total]['CO2'])
terrasim.add_water(@simulation_result[:resources][:total]['H2O'])

@results[:planetary_changes] = {
  atmospheric_pressure: terrasim.final_pressure,
  temperature_increase: terrasim.delta_temperature,
  water_coverage: terrasim.ocean_percentage,
  habitability_index: terrasim.habitability_score
}
```

### 3. Connect to MaterialLookupService for Accurate Pricing
Replace `estimate_unit_cost()` with actual market prices:

```ruby
def calculate_costs
  total_cost = 0
  cost_breakdown = {}
  
  resources[:total].each do |resource, quantity|
    material = MaterialLookupService.find_by_name(resource)
    unit_cost = material&.base_price || estimate_unit_cost(resource)
    cost = quantity * unit_cost
    
    cost_breakdown[resource] = cost
    total_cost += cost
  end
  
  # ... rest of method
end
```

### 4. Generate Actual SupplyContract Records
Implement `create_contracts()` to generate database records:

```ruby
def create_contracts
  contracts = []
  
  @results[:resources][:by_year].each do |year, resources|
    resources.each do |resource_name, quantity|
      contract = SupplyContract.create!(
        material: MaterialLookupService.find_by_name(resource_name),
        quantity: quantity,
        gcc_total: calculate_contract_value(resource_name, quantity),
        delivery_year: Time.current.year + year,
        mission_pattern: @pattern,
        status: 'planned',
        created_by: 'ai_manager'
      )
      
      contracts << contract
    end
  end
  
  contracts
end
```

### 5. Add Real-Time Progress Tracking
When missions are executing, link back to planner:
- Show original plan vs actual progress
- Highlight variances (cost overruns, delays, resource shortages)
- Suggest plan adjustments based on execution data

### 6. Multi-Pattern Comparison
Add UI to compare 2-3 patterns side-by-side:
```ruby
def compare_patterns
  patterns = params[:patterns] # ['mars-terraforming', 'venus-industrial']
  scenarios = {}
  
  patterns.each do |pattern|
    planner = AIManager::MissionPlannerService.new(pattern, @base_params)
    scenarios[pattern] = planner.simulate
  end
  
  @comparison = AIManager::EconomicForecasterService.new.compare_scenarios(scenarios)
end
```

### 7. Save/Load Plans
Add database persistence:
```ruby
class MissionPlan < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  
  serialize :parameters, JSON
  serialize :simulation_results, JSON
  
  validates :pattern, presence: true
  validates :name, presence: true, uniqueness: true
end
```

## Design Philosophy

The Mission Planner follows the SimEarth aesthetic:
- **Green terminal text** on black background
- **Cyan highlights** for important values
- **Red borders** for warnings/bottlenecks
- **Courier New** monospace font
- **Grid-based layouts** with equal panel widths
- **Immediate feedback** - no page reloads
- **Data density** - maximize information per screen

## Related Documentation

- [AI Manager Architecture](../ai_manager/README.md)
- [Mission Profiles](../ai_manager/MISSION_PROFILES.md)
- [Economic Forecasting](../systems/ECONOMIC_FORECASTING.md)
- [Material Lookup Service](../../app/services/README.md)
- [TerraSim Integration](../terrasim/INTEGRATION.md)

---

**Last Updated**: January 15, 2026  
**Status**: Production-ready UI with synthetic data; awaiting integration with actual pattern JSON and TerraSim

---

## Market Integration (v2.0 - January 2026)

### Real Market Pricing

The Mission Planner now integrates with the live game economy using:

#### Market::NpcPriceCalculator
- Provides real-time GCC pricing for all resources
- Accounts for supply/demand fluctuations
- Uses settlement-specific pricing
- Falls back to Earth import costs when unavailable

#### Logistics::TransportCostService
- Calculates per-kg transport costs between locations
- Accounts for delta-v requirements
- Considers route infrastructure (refueling stations, depots)
- Applies physics-based cost modeling

#### PatternTargetMapper
Maps mission patterns to target celestial bodies:
```ruby
AIManager::PatternTargetMapper.target_location('mars-terraforming') # => Mars CelestialBody
```

### Sourcing Hierarchy

The planner determines resource sources in this priority order:

1. **Local ISRU (In-Situ Resource Utilization)**
   - Zero transport cost
   - Location-specific resources (Mars: regolith, water_ice, CO2)
   - Requires local production infrastructure

2. **Regional Supply**
   - Nearby settlements (same planet/moon system)
   - Moderate transport costs
   - Faster delivery than Earth import

3. **Earth Import**
   - Fallback for unavailable resources
   - Highest transport costs
   - Guaranteed availability

### Cost Breakdown Structure

```ruby
costs: {
  total_gcc: Float,
  transport_cost_total: Float,
  transport_cost_ratio: Float (percentage),
  breakdown: {
    'resource_name' => {
      quantity: Integer,
      source: String, # "Local ISRU", "Regional Supply", or settlement name
      source_type: 'local' | 'regional' | 'import',
      unit_cost: Float (GCC/kg),
      transport_cost_per_unit: Float (GCC/kg),
      total_material_cost: Float,
      total_transport_cost: Float,
      total: Float,
      alternatives: [
        { source: String, total: Float, savings: Float, savings_percent: Float }
      ]
    }
  },
  contingency: Float,
  grand_total: Float
}
```

### Sourcing Strategy Analysis

```ruby
sourcing_strategy: {
  local_production: Float (percentage),
  regional_supply: Float (percentage),
  earth_import: Float (percentage),
  transport_cost_ratio: Float (percentage),
  infrastructure_note: String
}
```

### Economic Forecast Enhancements

#### Transport Cost Analysis
```ruby
transport_analysis: {
  total_transport_cost: Float,
  total_material_cost: Float,
  transport_percentage: Float,
  high_transport_resources: [
    {
      resource: String,
      transport_percentage: Float,
      transport_cost: Float,
      total_cost: Float,
      recommendation: String
    }
  ],
  recommendation: String # Overall transport optimization advice
}
```

#### Cost Optimization Suggestions
```ruby
cost_optimization: {
  alternative_sourcing: [
    {
      resource: String,
      current_cost: Float,
      alternative: String (source name),
      alternative_cost: Float,
      savings: Float,
      savings_percent: Float,
      recommendation: String
    }
  ],
  total_potential_savings: Float,
  infrastructure_investments: [
    {
      type: 'local_production_facility',
      investment_required: Float,
      annual_savings: Float,
      payback_period_years: Float,
      roi_percentage: Float,
      recommendation: String
    }
  ],
  optimization_priority: 'HIGH' | 'MEDIUM' | 'LOW' | 'MINIMAL'
}
```

### UI Updates

#### Center Panel Additions
- **Transport Cost**: Displayed as percentage of total cost
- **Sourcing Strategy**: Pie chart showing local/regional/import percentages

#### Right Panel Additions
- **Transport Analysis**: High transport cost warnings
- **Cost Optimization**: Alternative sourcing recommendations
- **Infrastructure ROI**: Investment payback calculations

### Graceful Degradation

When market data is unavailable:
1. Falls back to simplified cost estimates
2. Assumes Earth import for all resources
3. Uses generic transport cost multipliers
4. Logs warnings but continues simulation

### Testing with Mocks

Specs mock external services to avoid database dependencies:

```ruby
# Mock CelestialBody lookups
allow(CelestialBodies::CelestialBody).to receive(:find_by).with(identifier: 'mars')
  .and_return(double('Mars', id: 1, identifier: 'mars'))

# Mock Market pricing
allow(Market::NpcPriceCalculator).to receive(:calculate_ask).and_return(100.0)

# Mock Transport costs
allow(Logistics::TransportCostService).to receive(:calculate_cost_per_kg).and_return(50.0)

# Mock Settlement queries
allow(Settlement::BaseSettlement).to receive(:joins).with(:celestial_body)
  .and_return(double('Relation', where: double('Where', limit: [])))
```

### Performance Considerations

- **Caching**: Market prices are fetched once per simulation
- **Batch Queries**: Settlement lookups use joins to minimize DB hits
- **Fallback Strategy**: Quick estimates when services timeout
- **Resource Limits**: Alternative source search limited to 5 settlements

### Example Usage

```ruby
# Run simulation with market pricing
planner = AIManager::MissionPlannerService.new('mars-terraforming', {
  tech_level: 'standard',
  timeline_years: 10,
  budget_gcc: 5_000_000
})

result = planner.simulate

# Access sourcing breakdown
result[:sourcing_strategy][:local_production] # => 45.0 (%)
result[:sourcing_strategy][:earth_import] # => 25.0 (%)

# Check transport costs
result[:costs][:transport_cost_ratio] # => 23.5 (%)

# Find high-transport resources
forecaster = AIManager::EconomicForecasterService.new(result)
forecast = forecaster.analyze

forecast[:transport_analysis][:high_transport_resources]
# => [{ resource: 'structural_panels', transport_percentage: 65.2, ... }]

# Get optimization suggestions
forecast[:cost_optimization][:alternative_sourcing]
# => [{ resource: 'water_ice', savings: 125_000, ... }]
```

### Troubleshooting

**Issue**: "uninitialized constant PatternTargetMapper"  
**Solution**: Ensure `require_relative 'ai_manager/pattern_target_mapper'` is in `app/services/ai_manager.rb`

**Issue**: All resources showing as "Earth Import"  
**Solution**: Check `can_produce_locally?` logic matches your celestial body identifiers

**Issue**: Transport costs are zero  
**Solution**: Verify `Logistics::TransportCostService.calculate_cost_per_kg` is accessible and returns valid values

**Issue**: Alternative sources not appearing  
**Solution**: Create settlements on different celestial bodies in your database

---

**Last Updated**: January 16, 2026  
**Status**: Production-ready with real market integration
