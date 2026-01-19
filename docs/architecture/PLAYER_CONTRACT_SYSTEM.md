# Player Contract System Implementation Guide

> **Purpose**: Bridge player-first task priority concept with actual implementation  
> **Last Updated**: 2026-01-18  
> **Status**: Planning document - defines how AI Manager generates player contracts

---

## Overview

The Player Contract System implements **player-first task priority** (GUARDRAILS.md Section 4): contracts are offered to players first with a 24-48h timeout, then fall back to NPC execution if not accepted. This ensures players have first opportunity to earn GCC and influence game progression while maintaining autonomous NPC operations.

---

## System Components

### 1. Contract Generation (AI Manager → Player)

**Service**: `app/services/ai_manager/contract_creation_service.rb`

**Trigger Conditions**:
- Settlement needs resources (via ResourceAcquisitionService)
- Construction project requires materials
- Mission profile task flagged as "player_eligible"
- NPC cannot fulfill task internally (no available workforce/equipment)

**Contract Types**:
- **Harvesting Contracts**: Extract resources from celestial bodies
- **Logistics Contracts**: Transport materials between settlements
- **Construction Contracts**: Deliver construction materials to build sites
- **Exploration Contracts**: Scout new systems, deploy probes
- **Emergency Contracts**: Critical repairs, disaster response

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
  
  # Requirements
  material: "Oxygen",
  quantity: 1000,  # kg
  delivery_location: "Luna Base Alpha Depot",
  
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

---

### Phase 3: Contract Distribution

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

### Phase 4: Timeout & NPC Fallback

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

### Phase 5: Contract Completion

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
