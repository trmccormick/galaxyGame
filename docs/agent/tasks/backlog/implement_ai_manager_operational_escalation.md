# AI Manager Operational Phase - Escalation Implementation Plan

## Current Status Assessment

### ✅ **Existing Infrastructure**
- **Models**: `Units::Robot`, `Craft::Harvester`, `Market::Order` (with expiration logic)
- **Services**: `EmergencyMissionService` (basic), `ContractCreationService` (stub)
- **Documentation**: Complete escalation design in `PLAYER_CONTRACT_SYSTEM.md`

### ✅ **IMPLEMENTED: Core Escalation System**
- **EscalationService**: Complete with strategy determination and escalation logic
- **Automated Harvester Deployment**: Full implementation with robot/craft creation
- **Special Mission Creation**: Emergency mission generation for critical resources
- **Scheduled Import Coordination**: Import source selection and delivery scheduling
- **Integration**: ResourceAcquisitionService and OperationalManager updated
- **Models**: ScheduledImport model created
- **Jobs**: HarvesterCompletionJob for automated harvesting fulfillment

### ❌ **Remaining Implementation Needs**
- Database migration created (needs to be run)
- Testing of escalation logic
- EmergencyMissionService expansion for special missions
- Import delivery job for scheduled imports

## Implementation Plan

### Phase 1: Core Escalation Service
**File**: `app/services/ai_manager/escalation_service.rb`

```ruby
module AIManager
  class EscalationService
    def self.handle_expired_buy_orders(expired_orders)
      expired_orders.each do |order|
        case determine_escalation_strategy(order)
        when :special_mission
          create_special_mission_for_order(order)
        when :automated_harvesting
          deploy_automated_harvesters(order)
        when :scheduled_import
          schedule_cycler_import(order)
        end
      end
    end

    private

    def self.determine_escalation_strategy(order)
      material = order.resource
      settlement = order.base_settlement

      # Priority 1: Special missions for critical resources
      return :special_mission if critical_resource?(material)

      # Priority 2: Automated harvesting if locally available
      return :automated_harvesting if can_harvest_locally?(settlement, material)

      # Priority 3: Scheduled imports as last resort
      :scheduled_import
    end

    def self.critical_resource?(material)
      ['oxygen', 'water', 'nitrogen', 'hydrogen'].include?(material.downcase)
    end

    def self.can_harvest_locally?(settlement, material)
      # Check if settlement's celestial body has the resource
      celestial_body = settlement.celestial_body
      case material.downcase
      when 'oxygen'
        celestial_body.atmosphere&.gases&.any? { |g| g.name == 'O2' }
      when 'water'
        celestial_body.hydrosphere&.total_liquid_mass&.positive?
      when 'nitrogen'
        celestial_body.atmosphere&.gases&.any? { |g| g.name == 'N2' }
      else
        # Check regolith composition for other materials
        celestial_body.composition&.dig('regolith', material.downcase)&.positive?
      end
    end
  end
end
```

### Phase 2: Automated Harvester Deployment
**Integration**: Extend existing `Units::Robot` and `Craft::Harvester` models

```ruby
# In EscalationService
def self.deploy_automated_harvesters(order)
  settlement = order.base_settlement
  material = order.resource
  quantity = order.quantity

  # Create automated harvester unit
  harvester = create_automated_harvester(settlement, material, quantity)

  # Deploy to appropriate location
  deploy_harvester_to_site(harvester, settlement.celestial_body, material)

  # Schedule completion
  schedule_harvester_completion(harvester, order)
end

def self.create_automated_harvester(settlement, material, quantity)
  case material.downcase
  when 'oxygen'
    Units::Robot.create!(
      name: "Automated Oxygen Harvester",
      settlement: settlement,
      operational_data: {
        'task_type' => 'atmospheric_harvesting',
        'target_material' => 'oxygen',
        'target_quantity' => quantity,
        'extraction_rate' => 10, # kg/hour
        'mobility_type' => 'stationary'
      }
    )
  when 'water'
    Craft::Harvester.create!(
      name: "Automated Water Extractor",
      settlement: settlement,
      operational_data: {
        'extraction_rate' => 50, # kg/hour
        'target_body' => settlement.celestial_body
      }
    )
  else
    # Regolith mining robot
    Units::Robot.create!(
      name: "Automated #{material.titleize} Miner",
      settlement: settlement,
      operational_data: {
        'task_type' => 'regolith_mining',
        'target_material' => material,
        'target_quantity' => quantity,
        'extraction_rate' => 25, # kg/hour
        'mobility_type' => 'wheeled'
      }
    )
  end
end
```

### Phase 3: Special Mission Creation
**Integration**: Extend `EmergencyMissionService`

```ruby
# In EscalationService
def self.create_special_mission_for_order(order)
  settlement = order.base_settlement
  material = order.resource
  quantity = order.quantity

  # Calculate premium reward (2x normal rate)
  base_reward = calculate_base_reward(material, quantity)
  premium_reward = base_reward * 2

  # Create emergency mission
  EmergencyMissionService.create_emergency_mission(
    settlement,
    material.to_sym,
    reward: premium_reward,
    time_limit: 48.hours,
    priority: :high
  )
end

def self.calculate_base_reward(material, quantity)
  # Use existing NPC price calculator
  price_per_unit = Market::NpcPriceCalculator.calculate_ask(nil, material)
  price_per_unit * quantity * 1.5 # 50% markup for player effort
end
```

### Phase 4: Scheduled Import Coordination
**New Service**: `app/services/ai_manager/import_scheduler.rb`

```ruby
module AIManager
  class ImportScheduler
    def self.schedule_cycler_import(order)
      settlement = order.base_settlement
      material = order.resource
      quantity = order.quantity

      # Find best import source
      import_source = find_best_import_source(settlement, material)

      # Calculate transport cost
      transport_cost = calculate_transport_cost(import_source, settlement, material, quantity)

      # Schedule on next available cycler
      schedule_import_delivery(
        material: material,
        quantity: quantity,
        source: import_source,
        destination: settlement,
        transport_cost: transport_cost,
        delivery_eta: calculate_delivery_time(import_source, settlement)
      )
    end

    def self.find_best_import_source(destination_settlement, material)
      # Priority: Earth, other settlements in system, orbital depots
      sources = [
        { type: :earth, location: 'Earth', cost_multiplier: 3.0 },
        { type: :settlement, location: find_nearby_settlements(destination_settlement), cost_multiplier: 1.5 },
        { type: :depot, location: find_orbital_depots(destination_settlement), cost_multiplier: 1.2 }
      ]

      sources.find { |source| can_supply?(source, material) } || sources.first
    end
  end
end
```

### Phase 5: Integration Points

**Update ResourceAcquisitionService**:
```ruby
# Add to existing ResourceAcquisitionService
def self.check_expired_orders
  expired_orders = Market::Order.where(order_type: :buy)
                                .where('created_at < ?', 24.hours.ago)
                                .where(status: :active)

  EscalationService.handle_expired_buy_orders(expired_orders) if expired_orders.any?
end
```

**Add to OperationalManager**:
```ruby
# In OperationalManager#make_decision
def check_market_escalation
  ResourceAcquisitionService.check_expired_orders
end
```

## Testing Strategy

### Unit Tests
- `EscalationService` strategy determination
- Harvester deployment logic
- Mission creation integration
- Import scheduling

### Integration Tests
- End-to-end escalation flow
- Robot/Harvester model integration
- Market order expiration handling

### Simulation Tests
- Resource shortage scenarios
- Escalation priority testing
- Cost optimization validation

## Success Criteria

### Functional ✅ MOSTLY COMPLETE
- [x] Expired buy orders trigger appropriate escalation
- [x] Automated harvesters deploy for local resources
- [x] Special mission creation interface ready
- [x] Import scheduling system implemented
- [x] Database migration created
- [ ] Testing validation required

### Performance
- [ ] Escalation processing < 100ms per order
- [ ] No database deadlocks during bulk operations
- [ ] Memory efficient for large order volumes

### Economic Balance
- [ ] AI saves money using players vs direct harvesting
- [ ] Market liquidity maintained through NPC fallbacks
- [ ] Player opportunity windows respected (48-hour delays)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/implement_ai_manager_operational_escalation.md