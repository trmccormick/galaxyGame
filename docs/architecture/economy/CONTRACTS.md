# Player Contract System

## Overview

The Player Contract System implements **player-first task priority** where the AI Manager offers missions and contracts to players before NPCs, ensuring players have primary opportunities to earn GCC and influence game progression. This system bridges player agency with autonomous NPC operations.

## Contract Types

### 1. Courier Contracts
**Purpose**: Transport materials and goods between locations using player-owned vessels.

**Subtypes**:
- **Surface Transport**: Local delivery between nearby facilities using tugs
- **Orbital Transfer**: Heavy lift operations moving cargo orbit-to-surface
- **Interplanetary Transport**: Deep space cargo movement between settlements
- **Asteroid Relocation**: Specialized contracts for moving celestial bodies
  - **Simple Capture**: Moving smaller asteroids without modification
  - **Slag Propulsion**: Hollowing large asteroids using mass for propellant (90% fuel savings)
  - **Station Conversion**: Relocating asteroids for conversion into orbital infrastructure

**Requirements**:
- Transport capability levels (surface_to_orbit, orbit_to_orbit, interplanetary, asteroid_relocation)
- Cargo capacity minimums
- Environmental ratings (vacuum, atmosphere, reentry-capable)
- Special equipment (landing_gear, heat_shield, docking_ports, capture_system, hollowing_tools)

### 2. Manufacturing Contracts
**Purpose**: Produce specific items or materials for AI Manager needs.

**Examples**:
- **Resource Processing**: Convert raw materials into refined products
- **Component Assembly**: Build spacecraft components or infrastructure modules
- **Specialized Production**: Create rare materials or advanced alloys

**Economic Model**:
- **Blueprint Licensing**: Players purchase limited-run blueprint copies from NPCs
- **Production Limits**: Prevent infinite manufacturing while encouraging specialization
- **Research Permissions**: Licensed blueprints allow efficiency improvements

### 3. Exploration Contracts
**Purpose**: Scout new systems, deploy probes, and gather intelligence.

**Types**:
- **System Survey**: Initial reconnaissance of new celestial bodies
- **Resource Assessment**: Detailed analysis of resource potential
- **Route Mapping**: Charting safe navigation paths
- **Scientific Research**: Data collection for research objectives

### 4. Station Expansion Contracts
**Purpose**: Enable player-driven settlement growth through modular construction.

**Process**:
1. **Construction**: Players build modular structures using licensed blueprints
2. **Attachment**: Pay connection fees for ports and power allocation
3. **Operation**: Players operate facilities or allow others to use processing slots
4. **Monetization**: Charge processing fees for facility usage

**Economic Model**:
- **Connection Fees**: GCC payment for host settlement resources
- **Processing Fees**: Variable rates set by facility owners
- **Blueprint Costs**: Upfront licensing fees for construction rights

## Contract Mechanics

### Generation Triggers
- **Resource Gaps**: AI Manager needs materials not immediately available
- **Construction Projects**: Building sites require delivery of components
- **Mission Profile Tasks**: Tasks flagged as "player_eligible"
- **Supply Chain Needs**: Resource shortages in production chains

### Player vs NPC Priority
**Player-First Priority**:
1. **Contract Posting**: AI Manager posts contracts to market
2. **Player Acceptance Window**: 24-48 hour window for player fulfillment
3. **Timeout Fallback**: If no players accept, contracts move to NPC queue
4. **NPC Execution**: Automated systems fulfill contracts at reduced efficiency

**Economic Multipliers**:
- **Player Rewards**: 1.5x GCC value vs NPC execution
- **NPC Efficiency**: 70% of player capability but guaranteed completion

### Contract Lifecycle
1. **Posting**: AI Manager creates contract with requirements and rewards
2. **Acceptance**: Player accepts contract, receives advance payment
3. **Fulfillment**: Player completes objectives within time limits
4. **Verification**: System confirms delivery/completion
5. **Payment**: Full GCC reward transferred to player account

## Collateral and Escrow Systems

### Escrow Mechanics
**Purpose**: Protect both parties in high-value transactions.

**Implementation**:
- **Contract Value Threshold**: Escrow required for contracts > 10,000 GCC
- **Deposit Requirements**: 20% of contract value held in escrow
- **Release Conditions**: Funds released upon successful completion
- **Dispute Resolution**: Arbitration system for failed contracts

### Collateral Requirements
**For High-Risk Contracts**:
- **Performance Bonds**: Insurance against contract failure
- **Asset Liens**: Equipment or inventory pledged as security
- **Reputation Stakes**: Contract success affects player reputation score

## Reputation Effects

### Reputation System
**Purpose**: Track player reliability and influence contract availability.

**Factors**:
- **Completion Rate**: Percentage of contracts successfully fulfilled
- **On-Time Delivery**: Meeting contract deadlines
- **Quality Standards**: Meeting specification requirements
- **Dispute History**: Resolution of contract disputes

### Reputation Tiers
- **Bronze (0-25)**: Basic contracts, standard rewards
- **Silver (26-50)**: Premium contracts, 10% bonus rewards
- **Gold (51-75)**: Exclusive contracts, 25% bonus rewards
- **Platinum (76-100)**: Priority access, 50% bonus rewards

### Reputation Impacts
- **Contract Access**: Higher reputation unlocks better contracts
- **Pricing**: Better rates and bonuses for reliable players
- **Penalties**: Failed contracts reduce reputation and access
- **Recovery**: Successful completions gradually restore reputation

## NPC vs Player Contract Priority

### Priority Framework
**Player-First Principle**:
- AI Manager prioritizes player opportunities for economic engagement
- Maintains game progression even without player participation
- Balances player agency with autonomous NPC operations

### Implementation Rules
1. **Contract Posting**: All eligible tasks posted as player contracts first
2. **Acceptance Window**: 24-48 hours for player response
3. **NPC Fallback**: Automated execution if no player acceptance
4. **Economic Incentives**: Players receive premium rewards vs NPC rates

### Economic Balance
- **GCC Distribution**: Players earn primary share of new GCC creation
- **NPC Reserves**: Automated systems maintain operational reserves
- **Market Liquidity**: Player activity drives market dynamics
- **Scalability**: System works with any number of active players

## Contract Limits and Guardrails

### Economic Guardrails
- **Maximum Contract Value**: No single contract exceeds 10% of GCC money supply
- **Contract Duration Caps**: Maximum 90 Earth days
- **Reputation Requirements**: Minimum reputation for high-value contracts
- **Market Stability**: Earth Anchor Price prevents price gouging

### Risk Management
- **Insurance Requirements**: High-value contracts require bonding
- **Dispute Resolution**: Arbitration system for contract failures
- **Economic Transparency**: Real-time market and contract information
- **Emergency Funds**: 5% of GDP allocated for economic crisis response</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/economics/CONTRACTS.md