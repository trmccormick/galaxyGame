# AI Manager Resource Decision Architecture

## Overview

The AI Manager is not simply a capacity alarm. It is a **resource optimizer** that
evaluates multiple disposition pathways when capacity pressure occurs. Critically,
the AI Manager must respect **ownership** before acting on any resource.

---

## Ownership Rules

Before the AI Manager can act on any resource it must verify ownership:

```ruby
# AI Manager can only directly act on resources it owns
item.owner == ai_manager_corporation

# For player-owned resources the AI Manager can only:
# 1. Notify the player of the situation
# 2. Offer to purchase the resource
# 3. Suggest options the player can take
# 4. Execute actions the player has pre-authorized via standing orders
```

**Key principle:** The AI Manager never dumps, converts, sells, or vents
resources it doesn't own without explicit player authorization. Violation of
this would be a game-breaking trust issue.

---

## Capacity Pressure Decision Tree

When inventory fill ratio exceeds threshold (default 80%), the AI Manager
evaluates options in priority order:

### Step 1: Verify Ownership
```
Is this resource owned by the AI Manager's corporation?
  YES → full decision tree available
  NO  → notify player, suggest options, wait for authorization
```

### Step 2: Evaluate Conversion Pathways
Before assuming storage is needed, check if the resource can be converted
into something more compact or more valuable:

**Example: O2 capacity full, liquid storage available, H2 in inventory**
```
O2 (gas) + H2 (gas) → H2O (liquid)
  - Frees gas storage capacity
  - Creates water which has different storage requirements
  - Water has high utility value for life support and agriculture
  - Net positive if liquid storage is available
```

**Example: Excess CO2, lava tube present**
```
CO2 (gas) → vent to lava tube atmosphere
  - Frees gas storage
  - Builds lava tube atmosphere pressure (terraforming progress)
  - Net positive, no resource lost
```

**Example: Excess metals, manufacturing queue idle**
```
Raw metals → manufacture ibeams or components
  - Converts bulk raw material to higher-value finished goods
  - May free storage if finished goods are more compact
  - Generates value from idle manufacturing capacity
```

### Step 3: Evaluate Transfer/Sale Pathways
```
Are there incoming or docked crafts that need this resource?
  → Fulfill transfer contracts, generate revenue

Are there nearby settlements with deficit of this resource?
  → Create internal transfer contract

Is the market price favorable?
  → Lower ask price to accelerate sales and free storage
```

### Step 4: Evaluate Build Pathways
```
Is manufacturing capacity available?
  → Queue build job for additional storage units
  
Which storage type is needed?
  Gas → inflatable_gas_storage or cryogenic_tank
  Solids → open_surface_storage or warehouse_module
  Liquids → liquid_storage_tank
  
What is the build time vs urgency?
  → If urgent and can't wait for build, escalate to Step 5
```

### Step 5: Last Resort Options
```
Vent to space (gases only)
  → Permanent loss, log it, notify player
  → Only if: no conversion available, no buyers, no storage buildable
  → Never automatic — requires player acknowledgment or standing order

Surface dump (solids only, appropriate surfaces)
  → Items placed on surface outside settlement
  → Not lost but unprotected, may degrade
  → Log it, notify player
```

---

## Conversion Pathways Reference

The AI Manager maintains awareness of these conversion options:

| Input | Conditions | Output | Storage shift |
|-------|-----------|--------|---------------|
| O2 + H2 | Sabatier/electrolysis unit available | H2O | gas → liquid |
| CO2 + H2 | Sabatier unit available | CH4 + H2O | gas → gas + liquid |
| CO2 | Lava tube present | Atmosphere | gas → atmosphere |
| Raw metals | Manufacturing idle | Components/ibeams | bulk → finished goods |
| Organic waste | Bioreactor available | Fertilizer/biomass | waste → resource |
| Excess power | Electrolysis unit | H2 + O2 | energy → gas |

**Key insight:** Resource conversion is often preferable to raw storage expansion
because it creates value rather than just deferring the problem.

---

## Notification System

When the AI Manager cannot act (doesn't own the resource, or situation requires
player decision), it generates structured notifications:

```ruby
# Notification structure
{
  type: :capacity_pressure,
  severity: :warning,          # :info, :warning, :critical
  settlement: settlement.name,
  resource: 'O2',
  fill_ratio: 0.92,
  options: [
    {
      action: :convert_to_water,
      description: "Convert O2 + H2 to water (500kg H2 available)",
      requires: :player_authorization,
      outcome: "Frees 500m³ gas storage, adds 562kg water"
    },
    {
      action: :build_storage,
      description: "Construct inflatable_gas_storage (est. 4 hours)",
      requires: :resources_and_manufacturing,
      outcome: "Adds 50m³ gas capacity"
    },
    {
      action: :lower_sell_price,
      description: "Lower O2 ask price by 15% to accelerate sales",
      requires: :player_authorization,
      outcome: "Expected to free ~200m³ within 48 hours"
    }
  ]
}
```

---

## Standing Orders

Players can pre-authorize the AI Manager to act without per-event approval
via standing orders:

```ruby
# Example standing orders
{
  'gas_capacity_above_90' => :convert_o2_to_water_if_h2_available,
  'gas_capacity_above_95' => :lower_o2_price_by_10_percent,
  'gas_capacity_at_100'   => :vent_excess_to_lava_tube_if_present,
  'metal_capacity_above_80' => :queue_ibeam_manufacturing
}
```

Standing orders make the AI Manager semi-autonomous within boundaries the
player has defined. Without standing orders, the AI Manager notifies and waits.

---

## Resource Decision Log

Every AI Manager resource decision must be logged for player review:

```ruby
AiDecisionLog.create!(
  settlement: settlement,
  decision_type: :resource_disposition,
  action_taken: 'converted_o2_to_water',
  reasoning: 'O2 at 92% capacity, H2 available, liquid storage has 40% space',
  resources_affected: { 'O2' => -500, 'H2' => -56, 'H2O' => +504 },
  authorized_by: 'standing_order:gas_capacity_above_90',
  timestamp: Time.current
)
```

This creates full auditability — players can always see why the AI Manager
did what it did and adjust standing orders accordingly.

---

## Integration Points

| System | Integration |
|--------|-------------|
| `InventoryManager` | Source of truth for current quantities |
| `StrategySelector` | Evaluates which disposition pathway has best outcome |
| `MissionPlannerService` | Queues manufacturing jobs for storage expansion |
| `AtmosphereSimulationService` | Receives vented gases for lava tube buildup |
| `ByproductManufacturingService` | Handles conversion reactions (O2+H2→H2O) |
| `AiDecisionLog` | Records all decisions for player review |
| `EscalationService` | Escalates to player when AI Manager cannot act alone |