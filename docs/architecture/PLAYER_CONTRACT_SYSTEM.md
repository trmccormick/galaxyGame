# Player Contract System Implementation Guide

> **Purpose**: Bridge player-first task priority concept with actual implementation  
> **Last Updated**: 2026-01-18  
> **Status**: Planning document - defines how AI Manager generates player contracts

---

## Overview

The Player Contract System implements **player-first task priority** (GUARDRAILS.md Section 4): AI Manager offers both **missions** (assigned tasks with rewards) and **contracts/buy orders** (market opportunities) to players first, with NPC fallback. Players can also post their own market orders. This ensures players have first opportunity to earn GCC and influence game progression while maintaining autonomous NPC operations.

**Two Main Mechanisms:**

1. **Missions**: AI-generated tasks assigned to specific players (e.g., "Harvest 100 transparent panels for GCC reward")
2. **Contracts/Buy Orders**: Market listings where players fulfill AI needs (e.g., "AI offers GCC for 100 transparent panels") or players post their own offers

**Player-Posted Orders**: Players can create their own buy/sell orders with skill-based limits and listing fees.

**Contract Types (Initial Implementation)**:
- **Courier Contracts**: Transport materials/goods between locations
- **Item Exchange**: Direct trade of items between players
- **Future Options**: Auction contracts, loan contracts (EVE Online style bidding/lending)

---

## Economic Initialization & Market Development

### GCC=USD Starting Point

**Currency Foundation**: GCC (Galactic Credits) start at 1:1 parity with USD to establish real-world economic grounding.

**Real-World Cost Basis**: Initial lunar market prices based on current space transportation and infrastructure costs:
- **Transportation Costs**: $10,000-$20,000 per pound to LEO (Low Earth Orbit)
- **Infrastructure Costs**: ISS construction costs, lunar base concepts, commercial space operations
- **Resource Production**: Lunar water production, regolith processing, solar power generation

### Automated Market Building Approach

**Initial Phase**: Run automated builds to simulate real costs and establish baseline market data:
- **Data-Driven Universe**: Use real-world space economics to seed the game universe
- **Cost Simulation**: Automated systems generate initial market prices and contract values
- **Infrastructure Evolution**: Costs decrease as player-built infrastructure develops

**Market Development Stages**:
1. **Bootstrap Phase**: High import costs, basic local production (water, oxygen, basic materials)
2. **Infrastructure Growth**: Player construction reduces transportation dependency
3. **Market Maturity**: Local production undercuts imports, diversified economy emerges
4. **Expansion Phase**: Inter-system trade, specialized production centers

**Economic Justification**:
- **High Initial Costs**: Even local lunar water production costs remain high due to infrastructure needs
- **Need-Based Pricing**: Premium pricing justified by critical resource requirements
- **Infrastructure Investment**: Player construction projects drive cost reduction over time
- **Realistic Progression**: Mirrors actual space development economics (high initial costs → efficiency gains)

### Earth Anchor Price (EAP) Market Control

**What is EAP?**
Earth Anchor Price establishes maximum market prices for imported goods, preventing price gouging and ensuring economic stability.

**How EAP Controls Markets**:
- **Price Ceiling**: No player sell order can exceed EAP for imported materials
- **Import Trigger**: If market prices rise above EAP, NPCs automatically import from Earth
- **Contract Impact**: High-value contracts may be undercut by cheaper Earth imports
- **Economic Balance**: Prevents speculative bubbles while allowing profit margins

**EAP Enforcement**:
```ruby
def self.player_sell_orders_exceed_eap?(settlement, material)
  eap = get_anchor_price(material, 'USD')
  player_orders = Market.player_sell_orders(material)
  
  player_orders.any? { |order| order.price_per_unit > eap }
end
```

**Transport Requirements**:
- **Capability Levels**: surface_to_orbit, orbit_to_orbit, interplanetary, asteroid_relocation
  - **Asteroid Relocation Sub-types**: simple_capture (smaller asteroids), slag_propulsion (large asteroids with hollowing)
- **Cargo Capacity**: Minimum tonnage/volume requirements  
- **Environmental Rating**: vacuum, atmosphere, reentry-capable
- **Special Equipment**: landing_gear, heat_shield, docking_ports, capture_system (for asteroid relocation), hollowing_tools (for slag propulsion)

**Player Competition**:
- Players can accept contracts requiring any transport capability they possess
- Higher capability requirements = higher payouts (more valuable service)
- Players undercut NPC logistics costs, creating competitive market
- "Player first" ensures players get opportunity before automated systems

**Specialized Transport Examples**:
- **Asteroid Relocation**: 
  - **Simple Capture**: Move smaller asteroids without modification
  - **Slag Propulsion**: Hollow larger asteroids (up to 10B kg) using mass for propellant (90% fuel reduction)
  - **Station Conversion**: Relocate asteroids for conversion into orbital stations/depots (cheaper than Earth construction)
    - **Integrated Workflow**: Tug relocates asteroid while performing initial hollowing; cyclers deliver specialized modules for final conversion
    - **Faster Deployment**: Asteroid shells come online faster than traditional I-beam/panel construction
  - **Equipment Required**: `capture_system` for all, hollowing tools for slag propulsion, conversion equipment for stations
- **Heavy Cargo**: Large-scale orbital-to-surface transfers using heavy lift transports
- **Deep Space**: Interplanetary cargo movement between settlements using private ships or specialized cyclers
- **Local Delivery**: Surface transportation between nearby facilities using tugs

**Real-World Parallel**: Similar to freight bidding where carriers compete based on equipment and routes.

**Mission JSON Integration**:
- Asteroid relocation contracts should be reflected in mission profile JSON files
- Include station conversion missions for Artificial Wormhole Stations (AWS) and orbital depots
- Support multi-phase contracts: relocation → hollowing → conversion → activation
- Enable player-driven orbital infrastructure development
- **Existing Mission Profiles**:
  - `asteroid-conversion-artificial-wormhole-station`: EM-shielded wormhole stabilization facilities
  - `asteroid-conversion-orbital-depot`: L1-style storage and processing depots  
  - `asteroid-conversion-planetary-staging-hub`: Mega-industrial complexes for planetary operations
- **Integrated Tug-Cycler Workflow**: Tugs handle heavy relocation and initial preparation; cyclers deliver precision modules

**Player Specialization Opportunities**:
- **Surface Haulers**: Tug operators for local settlement transport
- **Orbital Transfer**: Heavy lift pilots moving cargo orbit-to-surface  
- **Interplanetary Traders**: Cycler operators or private ship captains
- **Asteroid Relocators**: 
  - **Simple Capture Specialists**: Moving smaller asteroids without modification
  - **Slag Propulsion Experts**: Hollowing large asteroids for efficient relocation (90% fuel savings)
  - **Station Constructors**: Converting relocated asteroids into orbital infrastructure (cheaper than Earth-built stations)
- **Logistics Coordinators**: Managing multi-stage supply chains

**Market Competition**:
- Players bid on contracts, potentially undercutting NPC rates
- NPC systems remain as fallback when no players available
- Creates dynamic pricing based on player availability and competition
- Rewards player investment in transport infrastructure
- **Slag Propulsion Advantage**: Players using asteroid mass for fuel can offer 90% cheaper relocation contracts
- **Station Construction Value**: Asteroid-based stations provide cheaper orbital infrastructure than Earth-built alternatives

**Strategic Importance**:
- **Wormhole Infrastructure**: Asteroid stations serve as Artificial Wormhole Stations (AWS) for network expansion
- **Orbital Depots**: Converted asteroids become L1-style depots for storage and processing
- **Cost Efficiency**: Local asteroid conversion avoids expensive Earth-to-orbit transport costs
- **Scalability**: Players can create distributed orbital infrastructure networks
- **Integrated Construction**: Tug-cycler synergy enables faster station deployment than traditional methods
- **Parallel Operations**: Tugs perform hollowing during transit while cyclers prepare specialized modules

---

## System Components

### 1. Mission Generation (AI Manager → Player Assignment)

**Service**: `app/services/ai_manager/mission_creation_service.rb`

**Trigger Conditions**:
- Settlement needs resources (via ResourceAcquisitionService)
- Construction project requires materials
- Mission profile task flagged as "player_eligible"
- NPC cannot fulfill task internally (no available workforce/equipment)

**Mission Types**:
- **Harvesting Missions**: Extract resources from celestial bodies
- **Logistics Missions**: Transport materials between settlements
- **Construction Missions**: Deliver construction materials to build sites
- **Exploration Missions**: Scout new systems, deploy probes
- **Emergency Missions**: Critical repairs, disaster response

### 2. Contract/Buy Order Generation (AI Manager → Market)

**Service**: `app/services/ai_manager/contract_creation_service.rb`

**Trigger Conditions**:
- AI Manager needs specific items (e.g., 100 Transparent Panels)
- Settlement requires materials not immediately available
- Resource gaps in supply chain
- Opportunity for player-driven fulfillment

**Contract Types**:
- **Buy Orders**: AI Manager offers GCC for specific items/materials
- **Supply Contracts**: Requests for delivery of goods to locations
- **Service Contracts**: Requests for specific work (repairs, construction)
- **Station Expansion Contracts**: Players build and attach modular structures (e.g., factories, processing facilities) to existing stations, paying connection fees for ports/power. Players can operate facilities themselves or allow other players to use processing slots for materials.
- **Trade Contracts**: Exchange offers between different goods

---

## Station Expansion Contracts

**Purpose**: Enable player-driven settlement growth through modular construction, allowing players to build specialized facilities and monetize them through processing fees.

**How It Works**:
1. **Construction**: Players build modular structures (e.g., metal smelter facilities, nuclear fuel reprocessing facilities) using available blueprints
2. **Attachment**: Players pay connection fees to attach modules to existing settlements (surface bases or orbital stations), requiring available ports and sufficient power
3. **Operation**: Players outfit the structure with units and operate it themselves, or allow other players to use processing slots
4. **Monetization**: Facility owners can charge processing fees for other players to use their equipment with their materials

**Economic Model**:
- **Connection Fees**: GCC payment for port/power allocation on the host settlement
- **Processing Fees**: Variable rates set by facility owners for slot usage
- **Material Costs**: Players using facilities pay for their own input materials
- **Ownership Benefits**: Facility owners retain control and can upgrade/expand their modules

**Examples**:
- Player builds nuclear fuel reprocessing facility, attaches to lunar base (surface or orbital), charges other players for uranium processing
- Player constructs metal smelter, offers alloy production services to industrial players on any settlement
- AI Manager can offer contracts for players to build specific facilities needed for settlement expansion

**Integration with AI Manager**: As the game progresses, AI Manager increases base capabilities by offering contracts for players to build and attach specialized modules, creating organic station growth.

---

## Implementation Flow

### Phase 1: Resource Need Detection

**When**: Settlement needs resource it cannot produce locally

```ruby
# ResourceAcquisitionService detects need
def self.order_acquisition(settlement, material, amount)
  if is_local_resource?(material)
    # Check if player contract is appropriate
    if player_contract_eligible?(settlement, material, amount)
      create_player_contract(settlement, material, amount)
    else
      process_npc_fulfillment(settlement, material, amount)
    end
  else
    process_external_import(settlement, material, amount)
  end
end
```

**Eligibility Criteria** (needs implementation):
- Material is obtainable by player (not Earth-exclusive)
- Settlement has GCC budget for contract payout
- Quantity is player-scale (not massive bulk shipment)
- Time sensitivity allows player response window

---

### Phase 2: Contract Creation

**Service**: `contract_creation_service.rb` (exists, needs expansion)

**Contract Data Structure**:
```ruby
{
  contract_id: "HARVEST_LUNA_O2_001",
  contract_type: "harvesting",
  issuer: "Luna Base Alpha",
  destination: "Luna Base Alpha",
  
  transport_requirements: {
    capability: "asteroid_relocation",  # surface_to_orbit, orbit_to_orbit, interplanetary, asteroid_relocation
    sub_type: "slag_propulsion",        # for asteroid_relocation: simple_capture, slag_propulsion
    minimum_cargo_capacity: 1000000000, # kg or m³ (1B kg for large asteroids)
    environmental_rating: "vacuum",    # vacuum, atmosphere, reentry
    special_equipment: ["capture_system", "hollowing_tools"] # required for slag propulsion
  },
  
  # Rewards
  payout_gcc: 2500,  # Calculated from market + transport costs
  reputation_gain: 50,
  bonus_conditions: {
    early_delivery: { threshold: "24h", bonus_gcc: 500 },
    quality_rating: { threshold: 95, bonus_gcc: 250 }
  },
  
  # Timing
  posted_at: Time.current,
  expires_at: Time.current + 48.hours,
  deadline: Time.current + 7.days,
  
  # Status
  status: "posted",  # posted, accepted, in_progress, completed, expired, failed
  npc_fallback: {
    enabled: true,
    trigger_time: Time.current + 48.hours,
    npc_cost_estimate: 3500  # Higher than player payout
  }
}
```

**Payout Calculation**:
```ruby
def calculate_gcc_payout(material, amount, destination)
  # Base cost: Market price
  market_price = Market::NpcPriceCalculator.calculate_ask(destination, material)
  base_cost = market_price * amount
  
  # Transport markup: 20-40% based on distance/difficulty
  transport_markup = calculate_transport_difficulty(destination) * 0.3
  
  # Urgency bonus: Higher for time-critical needs
  urgency_multiplier = urgency_level == :critical ? 1.5 : 1.0
  
  # Final player payout (should be competitive but profitable for AI)
  player_payout = base_cost * (1 + transport_markup) * urgency_multiplier
  
  # Ensure payout is below NPC fulfillment cost (AI saves money using players)
  npc_cost = estimate_npc_fulfillment_cost(material, amount, destination)
  [player_payout, npc_cost * 0.8].min
end
```

**Economic Integration Clarifications**:
- **GCC Minting**: Contract payouts are funded by LDC GCC reserves, not deducted from settlement budgets
- **Virtual Ledger**: NPC settlement budgets use Virtual Ledger for internal accounting during contract posting
- **Exchange Rate Impact**: Payouts calculated in GCC but may be affected by real-time exchange rate fluctuations
- **Reserve Requirements**: LDC maintains 25% GCC reserves for contract funding (see GUARDRAILS.md)

### Phase 3: Escalation on Expiration

**When Buy Orders Expire Unfilled**:
```ruby
def handle_expired_buy_orders(expired_orders)
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
```

**Escalation Options**:

1. **Special Missions/Contracts**: High-reward missions targeting specific resources
   ```json
   {
     "mission_id": "emergency_nitrogen_harvest_001",
     "type": "special_emergency",
     "description": "URGENT: Extract nitrogen from Martian atmosphere for lavatube project",
     "rewards": {
       "gcc": 15000,
       "bonus_items": ["rare_mineral_sample"],
       "reputation": 25
     },
     "time_limit": "48 hours"
   }
   ```

2. **Automated Harvesters/Robots**: AI deploys robotic systems (lowest operational cost for AI)
   ```ruby
   # Deploy automated nitrogen harvester
   harvester = AutomatedHarvester.create!(
     target_material: "nitrogen",
     location: "Mars Atmosphere",
     operational_cost: 2000,  # GCC - lowest cost option for AI
     completion_time: 72.hours
   )
   ```

   **Cost Structure Clarification**:
   - **Automated Harvesters**: Lowest cost for AI (no player payouts, minimal operational overhead)
   - **Player Contracts**: Higher cost (includes GCC payouts + reputation rewards)
   - **Special Missions**: Higher cost (premium payouts for urgent/emergency work)
   - **Scheduled Imports**: Highest cost (transport + procurement + urgency premiums from external sources)

   **Precursor Missions for Base Establishment**:
   - All NPC bases start with automated precursor missions for foothold operations
   - These harvest resources automatically without player engagement
   - Purpose: Establish initial infrastructure and resource flow
   - Transition: Once operational, bases switch to player-first contract system
   - Player Engagement: Players can participate in expansion/upgrade missions after initial establishment

3. **Scheduled Imports**: Order from external sources via cycler/supply runs (highest cost)
   ```ruby
   # Schedule import on next cycler
   import = ScheduledImport.create!(
     material: "transparent_panels",
     quantity: 100,
     source: "Luna Manufacturing",
     transport_cost: 50000,  # GCC - includes shipping
     delivery_eta: 14.days
   )
   ```

   **Real-World Space Transportation Economics**:
   - **Transportation Dominates Cost**: Space imports are always highest cost due to transportation economics
   - **Example**: A 5-gallon water jug (40 lbs) costs ~$10,000-$20,000/lb to transport to LEO
   - **Total Cost**: $400,000-$800,000 for water that costs <$1 on Earth
   - **Cost Ratio**: Transportation cost is 400,000x higher than material cost
   - **Current Reality**: ISS resupply missions cost tens of millions per shipment
   - **Game Implication**: Imports represent last-resort option when local production fails

### Phase 4: Surplus Material Sales

**NPC-Generated Surplus**:
- When NPCs harvest/generate materials they don't need, they post sell orders
- Creates market liquidity and resource redistribution

```ruby
def handle_surplus_materials(production_output, project_needs)
  surplus = production_output - project_needs
  
  surplus.each do |material, amount|
    sell_order = SellOrder.create!(
      seller: "npc_harvester",
      material: material,
      quantity: amount,
      price_per_unit: calculate_market_sell_price(material),
      expiration: 30.days.from_now
    )
    
    Market::OrderBoard.post(sell_order)
  end
end
```

**Example Surplus Generation**:
- Automated nitrogen harvester produces 200 units but project only needs 150
- 50 units listed as sell order on market
- Players can purchase at market rates

---

### Phase 5: Contract Distribution

**Contract Board** (UI/API):
- Display available contracts sorted by payout, urgency, location
- Filter by contract type, location, difficulty
- Show expiration countdown
- Highlight high-value or time-critical contracts

**Player Actions**:
- **Accept Contract**: Locks contract to player, prevents NPC fallback
- **Decline/Ignore**: Contract remains available for other players
- **Request Extension**: Player can negotiate deadline (AI may approve based on urgency)

---

### Phase 6: Timeout & NPC Fallback

**After 48 Hours**:
```ruby
def check_contract_timeout(contract)
  if contract.expires_at < Time.current && contract.status == 'posted'
    # No player accepted - trigger NPC fallback
    Rails.logger.info "[Contract] #{contract.contract_id} expired - triggering NPC fallback"
    
    trigger_npc_fulfillment(contract)
    
    contract.update!(
      status: 'expired_npc_fallback',
      npc_fallback_triggered_at: Time.current
    )
  end
end
```

**NPC Fulfillment**:
- Use Virtual Ledger (no GCC cost)
- Higher operational cost than player contract (incentivizes player participation)
- Slower execution (player priority allows faster completion)
- Game progresses autonomously (never stalls waiting for players)

---

### Phase 7: Contract Completion

**Player Delivers**:
```ruby
def complete_contract(contract, player)
  # Verify delivery
  if verify_material_delivery(contract, player)
    # Pay GCC
    transfer_gcc(contract.issuer, player, contract.payout_gcc)
    
    # Award reputation
    award_reputation(player, contract.reputation_gain)
    
    # Check bonus conditions
    if early_delivery?(contract)
      transfer_gcc(contract.issuer, player, contract.bonus_conditions[:early_delivery][:bonus_gcc])
    end
    
    contract.update!(
      status: 'completed',
      completed_at: Time.current,
      completed_by: player.id
    )
    
    Rails.logger.info "[Contract] #{contract.contract_id} completed by #{player.name} - #{contract.payout_gcc} GCC paid"
  end
end
```

**Economic Flow Clarification**:
- **GCC Source**: Payouts funded from LDC stabilization reserves, not settlement operating budgets
- **Settlement Accounting**: Settlements use Virtual Ledger for contract posting costs, resolved through successful delivery
- **LDC Revenue**: Contract system generates USD revenue for LDC through Earth exports and fuel sales
- **Currency Conversion**: GCC payouts may trigger exchange rate adjustments if reserves are drawn down

---

## Player-Posted Contracts

### Market Orders
**Player-Initiated Contracts**:
- Players can post their own buy/sell orders
- Listing costs: percentage of contract value (e.g., 1-5% of GCC value)
- Expiration times set by players (hours to weeks)
- Maximum active orders based on skill level

**Order Types**:
- **Buy Orders**: Players seeking specific items
- **Sell Orders**: Players offering items for sale
- **Trade Contracts**: Barter arrangements between players

**Skill-Based Limits**:
```ruby
def max_active_orders(player)
  base_limit = 5
  skill_bonus = player.skill_level(:trading) * 2  # Trading skill
  reputation_bonus = player.reputation_tier * 1
  
  base_limit + skill_bonus + reputation_bonus
end
```

**Listing Fee Calculation**:
```ruby
def calculate_listing_fee(contract_value_gcc, duration_days)
  base_percentage = 0.01  # 1% base fee
  duration_multiplier = [duration_days / 7.0, 1.0].min  # Up to 1x for week+
  
  contract_value_gcc * base_percentage * duration_multiplier
end
```

---

## Integration with Existing Services

### ResourceAcquisitionService Integration

**Current Code** (already implements player-first):
```ruby
def self.process_local_acquisition(settlement, material, amount)
  # Calculate GCC Price
  final_price_per_unit = calculate_gcc_contract_price(settlement, material)
  total_cost = final_price_per_unit * amount
  
  # Financial Check
  unless settlement.can_afford?(total_cost)
    return :insufficient_funds_gcc 
  end

  # Create Contract (The player mission/contract)
  ContractCreationService.create_player_contract(
    settlement, 
    material: material, 
    amount: amount, 
    payout_gcc: total_cost
  )
  
  :contract_created_gcc
end
```

**Status**: ✅ Integration hook exists, needs ContractCreationService expansion

---

### TaskExecutionEngine Integration

**Mission Profile Task Flagging**:
```json
{
  "task_id": "deliver_structural_panels",
  "description": "Transport 500kg structural panels to L1 Station",
  "task_type": "logistics",
  "player_eligible": true,
  "player_contract_params": {
    "contract_type": "logistics",
    "material": "modular_structural_panel_base",
    "quantity": 500,
    "origin": "Luna Base Alpha",
    "destination": "L1 Construction Station",
    "urgency": "normal",
    "estimated_payout_gcc": 1800
  },
  "npc_fallback": {
    "timeout_hours": 48,
    "npc_cost_estimate": 2500
  }
}
```

**Execution Logic**:
```ruby
def execute_task(task)
  if task['player_eligible'] && player_contract_system_enabled?
    # Post contract and wait for timeout
    contract = ContractCreationService.create_from_task(task)
    
    # Check periodically if player accepted
    wait_for_contract_completion_or_timeout(contract)
    
    if contract.status == 'completed'
      # Player fulfilled - continue mission
      return true
    elsif contract.status == 'expired_npc_fallback'
      # NPC fallback triggered - execute internally
      execute_npc_fallback(task)
      return true
    end
  else
    # Standard NPC execution
    execute_npc_task(task)
  end
end
```

---

## Contract Pricing Strategy

### Player vs. NPC Cost Differential

**Goal**: Make player contracts profitable for both AI Manager and players

```
NPC Internal Cost: 3500 GCC (Virtual Ledger cost converted to GCC equivalent)
    ↓
Player Contract Payout: 2500 GCC (70-80% of NPC cost)
    ↓
AI Savings: 1000 GCC (28% cost reduction)
    ↓
Player Profit Margin: ~800 GCC (after fuel/time costs ~1700)
```

**Win-Win**:
- AI Manager saves 28% by using player contracts
- Players earn profit margin on top of operational costs
- Economy stays dynamic with player participation

---

## Economic Guardrails

### 1. EAP Ceiling Enforcement

**From ResourceAcquisitionService** (already implemented):
```ruby
def self.player_sell_orders_exceed_eap?(settlement, material)
  # If any player sell orders exceed EAP, NPC chooses Earth import instead
  eap = get_anchor_price(material, 'USD')
  player_orders = Market.player_sell_orders(material)
  
  player_orders.any? { |order| order.price_per_unit > eap }
end
```

**Purpose**: Prevent player price gouging - AI will import from Earth rather than pay above EAP

---

### 2. GCC Budget Constraints

**Before Posting Contract**:
```ruby
def can_afford_contract?(settlement, contract_payout)
  current_gcc_balance = settlement.gcc_wallet_balance
  pending_contracts_total = settlement.pending_contracts.sum(:payout_gcc)
  
  available_gcc = current_gcc_balance - pending_contracts_total
  
  available_gcc >= contract_payout
end
```

**If Insufficient**:
- Delay non-critical contracts
- Trigger GCC income generation (sell surplus materials)
- Use NPC fallback (Virtual Ledger, no GCC required)

---

### 3. Contract Volume Limits

**Prevent Contract Spam**:
- Max 5 active contracts per settlement
- Min 1 hour between similar contracts (same material/type)
- Priority queue: Critical > Urgent > Normal > Optional

---

## Mission Profile Examples

### Example 1: Luna ISRU Oxygen Contract

**Mission Profile Task**:
```json
{
  "task_id": "luna_oxygen_production_001",
  "description": "Extract 2000kg oxygen from lunar regolith",
  "task_type": "resource_extraction",
  "player_eligible": true,
  "player_contract_params": {
    "contract_type": "harvesting",
    "material": "Oxygen",
    "quantity": 2000,
    "extraction_location": "Luna Highland Region",
    "delivery_location": "Luna Base Alpha Depot",
    "difficulty": "intermediate",
    "equipment_required": ["regolith_processor", "oxygen_separator"],
    "estimated_time_hours": 12,
    "payout_gcc": 3200,
    "bonus_early_delivery_gcc": 500
  },
  "npc_fallback": {
    "timeout_hours": 48,
    "npc_method": "deploy_autonomous_isru_unit",
    "npc_cost_gcc_equivalent": 4500
  }
}
```

**Outcome Scenarios**:
- **Player Accepts**: Player uses their ship + equipment, extracts oxygen, delivers to depot → earns 3200 GCC (or 3700 with early bonus)
- **Timeout**: NPC deploys autonomous ISRU unit (Virtual Ledger), slower but guaranteed completion

---

### Example 2: Venus Atmospheric Nitrogen Transport

**Mission Profile Task**:
```json
{
  "task_id": "venus_nitrogen_transport_001",
  "description": "Transport 500kg nitrogen from Venus to Mars",
  "task_type": "logistics",
  "player_eligible": true,
  "player_contract_params": {
    "contract_type": "logistics",
    "material": "Nitrogen",
    "quantity": 500,
    "origin": "Venus Atmospheric Harvesting Station",
    "destination": "Mars Terraforming Depot",
    "difficulty": "expert",
    "distance_au": 1.2,
    "hazards": ["high_radiation", "long_transit"],
    "estimated_time_days": 45,
    "payout_gcc": 15000,
    "bonus_perfect_delivery_gcc": 2000
  },
  "npc_fallback": {
    "timeout_hours": 72,
    "npc_method": "cycler_bulk_transport",
    "npc_cost_gcc_equivalent": 22000
  }
}
```

**Outcome Scenarios**:
- **Player Accepts**: High-value long-haul contract, significant profit margin, Mars terraforming continues
- **Timeout**: NPC uses cycler fleet (more expensive, slower), Venus-Mars pipeline continues autonomously

---

## UI/UX Requirements

### Contract Board Interface

**Required Features**:
- **Filter/Sort**: By type, location, payout, urgency, expiration
- **Map View**: Show contract locations on system map
- **Difficulty Rating**: Beginner, Intermediate, Expert, Elite
- **Requirements Check**: Show if player meets equipment/skill requirements
- **Profit Calculator**: Estimate player profit after fuel/time costs
- **Countdown Timers**: Show expiration and deadline clearly

**Contract Card Display**:
```
┌────────────────────────────────────────────────┐
│ HARVESTING CONTRACT                   [URGENT] │
│ Luna Oxygen Extraction                         │
│                                                │
│ 🎯 Payout: 3,200 GCC (+500 early bonus)       │
│ 📍 Luna Highland Region → Luna Base Alpha     │
│ ⏱️  Expires: 42h 15m                           │
│ ⚙️  Requires: Regolith Processor              │
│                                                │
│ Estimated Profit: ~1,100 GCC                   │
│ Difficulty: ★★☆☆☆ Intermediate                │
│                                                │
│ [ACCEPT CONTRACT]  [VIEW DETAILS]              │
└────────────────────────────────────────────────┘
```

---

## Implementation Phases

### Phase 1: Core Contract System (Grok Task)
- Expand `contract_creation_service.rb` with full contract generation
- Implement contract data model (Contract ActiveRecord model)
- Add contract posting/expiration logic
- Connect ResourceAcquisitionService → ContractCreationService

### Phase 2: Timeout & NPC Fallback (Grok Task)
- Implement contract timeout monitoring (background job)
- Add NPC fallback trigger logic
- Connect fallback to existing NPC execution services

### Phase 3: Mission Profile Integration (Grok Task)
- Add `player_eligible` flag to mission profile tasks
- Implement TaskExecutionEngine contract-aware execution
- Create contract-from-task generation

### Phase 4: Contract Board UI (Future)
- Build contract listing API
- Implement filter/sort/search
- Add player accept/decline actions

### Phase 5: Completion & Rewards (Future)
- Verify delivery system
- GCC payment processing
- Reputation system integration
- Bonus condition checks

---

## Success Metrics

**Player Engagement**:
- % of contracts accepted by players vs. NPC fallback
- Average player profit margin per contract type
- Contract completion success rate

**Economic Health**:
- AI Manager GCC savings vs. NPC costs
- Player GCC earnings from contracts
- Market price stability (EAP ceiling effectiveness)

**Autonomous Operations**:
- % of tasks completed via NPC fallback
- Average NPC fallback trigger time
- Zero mission stalls (100% autonomous progression)

---

## Related Documentation

- [GUARDRAILS.md](../GUARDRAILS.md) - Section 4: Player-First Task Priority mandate
- [mechanics.md](../gameplay/mechanics.md) - Player-first system and dual economy
- [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) - Phase 1 player contract economy
- [PLAYER_UI_VISION.md](PLAYER_UI_VISION.md) - Contract board UI concepts
- [IMPLEMENTATION_STATUS.md](../ai_manager/IMPLEMENTATION_STATUS.md) - AI Manager service status

---

**Status**: Planning document ready for Grok task assignment  
**Next Steps**: Assign Phase 1-3 implementation tasks to Grok
