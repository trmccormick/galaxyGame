---
status: blocked-waiting-implementation
priority: HIGH
type: implementation
system_domain: AI_MANAGER
parent_task: AI Manager Resource Spawning System (2026-05-01)
created: 2026-05-18
depends_on: 2026-05-18-IMPL-Create-DepositSpawner-Service.md
assigned_to: GPT-4.1
---

# IMPL: Integrate Deposit Spawning with Game Events (Triggers)

**Status**: BLOCKED - WAITING FOR DepositSpawner implementation  
**Priority**: HIGH  
**Type**: implementation  
**Parent**: AI Manager Resource Spawning System  
**Depends On**: DepositSpawner service (must be working first)

---

## Objective

Connect deposit spawning to game events so deposits are actually created when:
- A player surveys a region
- A settlement is founded
- A mining mission is initiated
- A body is visited for the first time

---

## Implementation Files

### File 1: TriggerDispatcher Service
**Location**: `galaxy_game/app/services/ai_manager/trigger_dispatcher.rb`

**Responsibility**: Route spawning triggers to DepositSpawner

**Methods** (pending design approval):
```ruby
# Called when survey mission completes
def on_survey_complete(region_id, celestial_body_id, player_equipment_tier:)
  # Determine equipment tier from player equipment
  # Call DepositSpawner.reveal_deposits_on_survey
  # Log event for player notification
end

# Called when settlement is founded
def on_settlement_founded(settlement_id)
  # Get settlement location
  # Get player equipment tier
  # Call DepositSpawner.spawn_deposits_near_settlement
  # Notify settlement manager of available resources
end

# Called when mining mission starts
def on_mission_initiated(mission_id, celestial_body_id, mission_type: :exploration)
  # Verify mission has access to target deposits
  # Spawn deposits if needed
  # Report mission briefing with resource availability
end

# Called on first player landing on a body
def on_first_visit(celestial_body_id, player_id, player_equipment_tier:)
  # Spawn initial resource map
  # Determine what tier 0 resources are visible
  # Create tutorial/discovery event
end
```

### File 2: Hook Integration

**Where triggers are called:**

#### Survey Completion Hook
- **File**: `galaxy_game/app/models/survey_mission.rb` (or similar)
- **Hook**: `after_complete` or `on_completion` callback
- **Implementation**:
```ruby
def on_completion
  # ... existing logic ...
  TriggerDispatcher.on_survey_complete(
    region_id: self.region_id,
    celestial_body_id: self.celestial_body_id,
    player_equipment_tier: self.player.equipment_tier
  )
end
```

#### Settlement Founded Hook
- **File**: `galaxy_game/app/models/settlement/base_settlement.rb`
- **Hook**: `after_create` callback or initialization
- **Implementation**:
```ruby
after_create :spawn_initial_deposits

def spawn_initial_deposits
  TriggerDispatcher.on_settlement_founded(self.id)
end
```

#### Mission Initiation Hook
- **File**: `galaxy_game/app/models/mission.rb` (or specific mission types)
- **Hook**: `after_create` or `on_start` callback
- **Implementation**:
```ruby
def on_mission_start
  TriggerDispatcher.on_mission_initiated(
    mission_id: self.id,
    celestial_body_id: self.target_body_id,
    mission_type: self.mission_type
  )
end
```

#### First Visit Hook
- **File**: `galaxy_game/app/models/craft/base_craft.rb` (or landing logic)
- **Hook**: Somewhere in landing sequence
- **Implementation**:
```ruby
def on_landing_at_new_body(celestial_body)
  unless celestial_body.visited_by?(self.owner)
    TriggerDispatcher.on_first_visit(
      celestial_body_id: celestial_body.id,
      player_id: self.owner_id,
      player_equipment_tier: self.owner.equipment_tier
    )
  end
end
```

### File 3: Specs
**Location**: `galaxy_game/spec/services/ai_manager/trigger_dispatcher_spec.rb`

**Test Scenarios**:
- on_survey_complete creates new deposits
- on_settlement_founded spawns nearby resources
- on_mission_initiated prepares mission briefing
- on_first_visit creates initial visible resources
- Multiple triggers on same body don't duplicate deposits
- Equipment tier affects what deposits are visible
- Survey with tier-0 equipment doesn't reveal tier-2 resources

### File 4: Integration Specs
**Location**: `galaxy_game/spec/integration/ai_manager/resource_spawning_workflow_spec.rb`

**End-to-End Scenarios**:
```ruby
scenario "Player lands on Luna, surveys, finds water ice" do
  # 1. Player lands on Luna (tier 0 equipment)
  # 2. System calls on_first_visit → spawns surface resources
  # 3. Player initiates survey mission
  # 4. Survey completes → reveals additional deposits
  # 5. Verify water ice now visible in deposit list
end

scenario "Settlement founded gets ISRU resources" do
  # 1. Settlement founded at specific location
  # 2. System calls on_settlement_founded
  # 3. Verify regolith, water ice available nearby
  # 4. Settlement ISRU can access these deposits
end

scenario "Equipment tier gates deposit access" do
  # 1. Player with tier-0 equipment surveys Luna
  # 2. Verify only surface resources visible
  # 3. Player upgrades to tier-2 equipment
  # 4. Verify deep subsurface resources now visible
  # 5. Both resources in database, visibility controlled by tier
end
```

---

## Acceptance Criteria

- [ ] TriggerDispatcher routes events correctly
- [ ] All four trigger types (survey, settlement, mission, first-visit) work
- [ ] Deposits created in database via triggers
- [ ] Equipment tier gates visible deposits
- [ ] No duplicate deposits from multiple triggers
- [ ] TriggerDispatcher specs pass
- [ ] Integration specs demonstrate full workflow
- [ ] Hooks integrated without breaking existing functionality
- [ ] Performance: trigger completes in < 1 second

---

## Stop Conditions

- If DepositSpawner not working → STOP (can't integrate non-existent service)
- If hooks cause cascade failures → STOP and report
- If duplicate deposits created → STOP and debug trigger logic
- If equipment tier gating fails → STOP (design issue)

---

## Notes

- This task depends on working DepositSpawner
- ResourceDeposit model must exist (separate task)
- Triggers should be idempotent (can call multiple times safely)
- Consider whether triggers should use queue/job (async) vs immediate (sync)

---

## Status Progression

1. **Current**: BLOCKED - waiting for DepositSpawner
2. **After DepositSpawner works**: READY FOR IMPLEMENTATION
3. **After integration**: SYSTEM TESTING
4. **Final**: Can remove old spawning system if applicable

