# System Maturity Conditions for Expansion and Snap Events

## Overview
The "Snap" event (wormhole destabilization) requires a two-stage maturity process: first the core system must mature to create expansion pressure, then the destination system must accumulate sufficient mass during expansion to trigger instability.

## Two-Stage Maturity Model

### Stage 1: Core System Maturity (Expansion Pressure)
**Trigger**: Natural wormhole discovery and Eden expansion initiation

**Requirements** (All must be met):
- **Population Pressure**: Earth/Luna population exceeds sustainable limits (>50 million)
- **Economic Capacity**: GCC reserves sufficient for major expansion (>100 billion GCC)
- **Technological Readiness**: Inter-system transportation infrastructure operational
- **Resource Surplus**: Core system producing excess resources for export
- **Infrastructure Saturation**: Core settlements at capacity, requiring new colonies

**Core System Components**:
- Earth: Population and economic hub
- Luna: Industrial and resource base
- Mars: First extrasolar settlement
- Venus: Atmospheric harvesting operations
- Ceres Belt: Resource extraction and processing

**Expansion Readiness Indicators**:
- **Population Growth Rate**: >2% annually (indicating space constraints)
- **Economic Output**: >50 billion GCC monthly
- **Ship Production**: >10 inter-system capable vessels operational
- **Resource Exports**: >20,000 tons monthly to external markets
- **Colony Applications**: >100,000 pending applications for new settlements

### Stage 2: Expansion System Maturity (Snap Trigger)
**Trigger**: Eden system mass accumulation exceeds wormhole stability limits

**Requirements** (During active expansion):
- **Infrastructure Mass**: Combined mass of Eden settlements and transport infrastructure
- **Transport Volume**: Regular heavy cargo flows between systems
- **Settlement Network**: Multiple operational colonies in Eden system
- **Economic Activity**: Active trade routes and resource extraction

### 1. Infrastructure Mass Accumulation
**Threshold**: Combined Eden infrastructure mass >300,000 tons (reduced from 400k due to weaker counterbalance)

**Components**:
- **Settlement Habs**: Large habitat modules and support structures
- **Orbital Infrastructure**: Stations, depots, satellites, construction platforms
- **Transportation Assets**: Cyclers, shuttles, cargo vessels in transit
- **Industrial Facilities**: Resource processing plants, manufacturing centers

**Progression**:
- **Low Risk**: < 150,000 tons (50% of limit)
- **Moderate Risk**: 150,000 - 225,000 tons (50-75% of limit)
- **High Risk**: 225,000 - 270,000 tons (75-90% of limit)
- **Snap Imminent**: > 270,000 tons (90% of limit)

**Buildup Rate Impact**:
- **Slow Buildup**: Limited population/ship availability delays mass accumulation
- **Snap Delay**: Mass limit reached later in timeline, not decreased
- **Strategic Timing**: Years of in-game development before snap trigger
- **Early Phase**: < 50,000 tons (minimal snap risk)
- **Development Phase**: 50,000 - 200,000 tons (low snap risk)
- **Growth Phase**: 200,000 - 400,000 tons (moderate snap risk)
- **Maturity Phase**: > 400,000 tons (high snap risk - snap imminent)

### 2. Transport Volume and Frequency
**Threshold**: Monthly transport volume >50,000 tons

**Requirements**:
- **Regular Cycler Operations**: Bi-weekly heavy cargo runs
- **Crew Rotation**: Monthly personnel transport
- **Resource Flows**: Continuous material supply chains
- **Equipment Transfer**: Major machinery and infrastructure components

**Progression**:
- **Minimal**: Occasional transport only
- **Regular**: Weekly scheduled runs
- **Frequent**: Multiple runs per week
- **Intensive**: Daily heavy transport operations

### 3. Settlement Network Complexity
**Threshold**: 5+ operational interconnected settlements

**Requirements**:
- **Primary Settlement**: Main colony with full life support
- **Secondary Settlements**: Resource outposts and specialized facilities
- **Transportation Links**: Regular transport between settlements
- **Communication Network**: Real-time coordination systems

**Progression**:
- **Isolated Settlements**: Individual bases
- **Connected Network**: Basic transportation links
- **Integrated System**: Comprehensive infrastructure
- **Mature Network**: Redundant and optimized connections

### 4. Economic Activity Level
**Threshold**: Active trade routes with >10 million GCC monthly turnover

**Indicators**:
- **Resource Extraction**: Operational mining and processing
- **Manufacturing**: Local production facilities
- **Trade Routes**: Regular commerce between settlements
- **Export Operations**: Resources shipped back to core system

**Progression**:
- **Subsistence**: Local resource use only
- **Inter-settlement Trade**: Basic resource sharing
- **Regional Economy**: Complex supply chains
- **Mature Economy**: Large-scale inter-system trade

## Snap Trigger Logic

### Stage 1 Trigger: Expansion Readiness Assessment
```ruby
def check_expansion_readiness
  population_pressure = earth_luna_population > 50_000_000 && emigration_demand > 0.1
  economic_capacity = gcc_reserves > 100_000_000_000
  tech_readiness = inter_system_vessels > 10
  resource_surplus = monthly_exports > 20_000
  
  if population_pressure && economic_capacity && tech_readiness && resource_surplus
    return :expansion_ready
  elsif [population_pressure, economic_capacity, tech_readiness, resource_surplus].count(true) >= 3
    return :approaching_readiness
  else
    return :not_ready
  end
end
```

### Stage 2 Trigger: Eden System Snap Risk
```ruby
def check_snap_trigger(eden_system)
  total_infrastructure_mass = calculate_infrastructure_mass(eden_system)
  monthly_transport_volume = calculate_monthly_transport(eden_system)
  settlement_count = count_operational_settlements(eden_system)
  economic_turnover = calculate_monthly_turnover(eden_system)

  # Eden mass limit: 300k tons (vs Sol's 500k due to weaker counterbalance)
  mass_limit = 300_000
  mass_percentage = (total_infrastructure_mass / mass_limit.to_f) * 100

  if total_infrastructure_mass > mass_limit && monthly_transport_volume > 50_000 && 
     settlement_count >= 5 && economic_turnover > 10_000_000
    return :snap_imminent
  elsif total_infrastructure_mass > mass_limit * 0.9 || monthly_transport_volume > 30_000 || settlement_count >= 3
    return :high_risk
  elsif total_infrastructure_mass > mass_limit * 0.75 || monthly_transport_volume > 15_000
    return :moderate_risk
  elsif total_infrastructure_mass > mass_limit * 0.5
    return :low_risk
  else
    return :very_low_risk
  end
end
```

### Buildup Rate and Timing Effects
- **Slow Buildup Delay**: Limited ships/population delays mass accumulation timing
- **Snap Timing**: Mass limit reached later, providing years of development time
- **Strategic Depth**: Players have extended period to prepare stabilization infrastructure
- **Counterbalance Effect**: Eden's offset positioning reduces stability vs Sol's perfect counterbalance

### Secondary Triggers: Crisis Acceleration
- **Economic Boom**: Sudden increase in trade volume during expansion
- **Megaproject Completion**: Large infrastructure additions in Eden system
- **Resource Rush**: Heavy extraction campaigns to fuel expansion
- **Technological Breakthrough**: New transportation methods enabling faster expansion

### AI Manager Response to Readiness Levels

#### Stage 1: Core System Development

##### Not Ready (Early Development)
- Focus on core system growth and stability
- Build population and economic base
- Research expansion technologies
- Monitor expansion indicators

##### Approaching Readiness (Growing Pressure)
- Begin expansion planning and resource allocation
- Accelerate ship construction programs
- Develop exploration capabilities
- Prepare for wormhole discovery

##### Expansion Ready (Critical Pressure)
- Initiate wormhole discovery protocols
- Prepare exploration fleets
- Allocate expansion budget
- Begin Eden system scouting

#### Stage 2: Eden System Expansion

#### Stage 2: Eden System Expansion

##### Very Low Risk (Early Expansion)
- Continue normal expansion operations
- Monitor mass accumulation in Eden system
- Prepare contingency planning for wormhole instability

##### Low Risk (Growth Phase)
- Begin AWS planning and resource allocation
- Increase EM harvesting preparations
- Monitor wormhole stability indicators
- Prepare Consortium formation protocols

##### Moderate Risk (Approaching Maturity)
- Accelerate AWS construction in both systems
- Deploy stabilization satellites preemptively
- Establish emergency reconnection protocols
- Finalize Consortium governance structure

##### High Risk (Critical Mass Approaching)
- Execute controlled snap if desired
- Activate emergency reconnection protocols
- Form Wormhole Transit Consortium
- Establish dual-link network management

##### Snap Imminent (Mass Limit Exceeded)
- Emergency stabilization procedures
- Immediate AWS activation
- Colony reconnection protocols
- Consortium dividend distribution setup

## Implementation Requirements

### AI Manager Integration
```ruby
class SystemMaturityMonitor
  def initialize(system)
    @system = system
    @maturity_metrics = {
      infrastructure_mass: 0,
      monthly_transport: 0,
      settlement_count: 0,
      isru_efficiency: 0.0
    }
  end

  def update_maturity_metrics
    @maturity_metrics[:infrastructure_mass] = calculate_total_mass
    @maturity_metrics[:monthly_transport] = calculate_transport_volume
    @maturity_metrics[:settlement_count] = count_operational_settlements
    @maturity_metrics[:isru_efficiency] = calculate_isru_efficiency
  end

  def maturity_level
    # Return :early, :developing, :mature, :snap_ready
    evaluate_maturity_level
  end

  def snap_risk_assessment
    # Return risk level and recommended actions
    assess_snap_risk
  end
end
```

### Mission Profile Integration
Mission profiles should include maturity tracking:

```json
{
  "mission_id": "mars_settlement_expansion",
  "maturity_impact": {
    "infrastructure_mass_addition": 25000,
    "economic_activity_increase": 0.15,
    "settlement_network_expansion": 1
  },
  "maturity_triggers": [
    "infrastructure_threshold_reached",
    "economic_maturity_achieved"
  ]
}
```

### UI Integration
Admin dashboard should display maturity status:

```
System Maturity Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Infrastructure Mass: 232,500 tons / 300,000 tons (77.5%)
Monthly Transport: 45,200 tons / 50,000 tons (90.4%)
Settlement Network: 6 settlements (connected)
ISRU Efficiency: 78% / 80% (97.5%)

Snap Risk Level: HIGH RISK
Recommended Actions:
• Begin AWS construction planning
• Increase EM harvesting operations
• Prepare Consortium formation protocols
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Timeline Expectations

### Realistic Development Timeline
- **6-12 months**: Reach moderate risk level
- **12-18 months**: Reach high risk level
- **18-24 months**: Reach snap-ready maturity
- **24+ months**: Snap event occurs naturally

### Accelerated Testing Timeline
For development/testing purposes:
- **1-2 weeks**: Reach moderate risk (compressed simulation)
- **2-4 weeks**: Reach high risk
- **4-6 weeks**: Trigger controlled snap

## Benefits of Maturity-Based Triggers

### Gameplay Benefits
- **Organic Progression**: Events feel earned through development
- **Strategic Depth**: Players can influence maturity pace
- **Narrative Satisfaction**: Crisis follows meaningful buildup
- **Replayability**: Different development paths lead to different snap timings

### Development Benefits
- **Predictable Testing**: Clear conditions for triggering events
- **Scalable Simulation**: Maturity metrics work across different system scales
- **AI Integration**: Clear decision points for AI Manager
- **Balance Control**: Adjustable thresholds for different difficulty levels

## Migration from Timeline-Based System

### Current State
- Some documentation references arbitrary timelines
- Mission profiles may not include maturity tracking
- AI Manager lacks maturity monitoring

### Migration Steps
1. **Audit Existing Content**: Review all timeline references
2. **Implement Maturity Tracking**: Add maturity metrics to AI Manager
3. **Update Mission Profiles**: Include maturity impact data
4. **Create Maturity UI**: Add dashboard for monitoring progress
5. **Test Maturity Triggers**: Validate snap triggering logic

## Success Criteria
- ✅ AI Manager tracks system maturity metrics
- ✅ Snap events triggered by maturity conditions, not timelines
- ✅ Players can monitor progress toward snap triggers
- ✅ Maturity system scales across different system types
- ✅ Clear feedback on risk levels and recommended actions</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/storyline/system_maturity_conditions.md