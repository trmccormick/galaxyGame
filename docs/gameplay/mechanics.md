# Galaxy Game - Core Mechanics

## Game Overview

Galaxy Game is a space colonization simulation where players participate in an AI-managed interplanetary economy through a **player-first task priority system**. Players get first refusal on harvesting, logistics, and construction contracts, earning GCC (Galactic Crypto Currency) to influence game progression. NPCs provide autonomous fallback to ensure the game never stalls, creating a living universe that progresses whether players participate or not.

## Core Philosophy: Player-First Task Priority

### The Player-First System
- **Contracts Offered First:** All harvesting, logistics, and construction missions are offered to players with 24-48 hour timeout
- **Player Choice:** Accept contracts to earn GCC and influence development, or decline to let NPCs handle them
- **NPC Fallback:** Game progression continues autonomously via AI Manager if players don't participate
- **Living Economy:** NPCs build infrastructure, trade materials, and maintain operations independently
- **Player Influence:** GCC spending allows outbidding NPCs, accessing premium contracts, and directing development priorities

### Contract Types
- **Harvesting Missions:** Luna regolith collection, Venus CO₂ extraction, Titan methane processing
- **Logistics Missions:** Fuel delivery (L1 → Mars), material transport (Luna → LEO), supply runs
- **Construction Missions:** Habitat assembly, depot setup, atmospheric harvesting station deployment

### Dual Economy
- **GCC (Galactic Crypto Currency):** Player currency earned through contract completion, used for market trading and influence
- **Virtual Ledger:** NPC-to-NPC internal accounting system (invisible to players, ensures autonomous progression)

## Game Initialization

Upon first startup, the game automatically initializes the Sol solar system with core celestial bodies (Sun, Earth, Moon, Mars, Jupiter, etc.) using the SystemBuilderService. The game state begins in year 0, day 0, with time paused. Players can then start the simulation clock and begin exploration and development activities.

## Core Game Loop

### 1. Exploration Phase
- **Orbital Survey**: Initial reconnaissance of planetary systems
- **Resource Assessment**: Identify valuable materials and extraction opportunities
- **Site Selection**: Choose optimal locations for infrastructure development

### 2. Infrastructure Development
- **Orbital Stations**: Establish processing and manufacturing capabilities
- **Surface Bases**: Construct permanent settlements and mining operations
- **Transportation Networks**: Build cyclers and depots for interplanetary logistics

### 3. Resource Management
- **Extraction**: Harvest raw materials from planetary surfaces and atmospheres
- **Processing**: Convert raw materials into usable products
- **Trade**: Buy/sell resources in interplanetary markets

### 4. Expansion
- **New Colonies**: Establish operations on additional celestial bodies
- **Technology Advancement**: Unlock new equipment and capabilities
- **Economic Optimization**: Maximize profit through efficient operations

## Key Systems

### Planetary Terraforming

The game features a two-phase terraforming approach: early industrial support from Venus, followed by comprehensive Mars habitation development.

#### Early Game: Venus Industrial Hub
Venus serves as Earth's primary industrial platform for Mars terraforming:
- **Gas extraction** from Venus atmosphere for Mars thickening
- **CNT production** for orbital shades and infrastructure
- **Solar shade technology** development (initially for Venus cooling, later adapted for Mars warming)
- **Resource processing** and export to Mars via orbital transfers

#### Primary Target: Mars
Once orbital transfer technologies improve:
- **Atmospheric thickening** through imported CO2 and methane
- **Water liberation** from polar ice and imported sources
- **Temperature warming** via greenhouse gases and orbital mirrors
- **Biosphere establishment** starting with microbial lifeforms

#### Venus Evolution
Initially considered for habitation due to proximity, Venus transitioned to industrial role:
- **Pre-wormhole necessity**: Only viable large-scale industrial platform
- **Resource abundance**: Unlimited CO2 and atmospheric gases
- **Energy advantages**: Extreme conditions enable unique processes
- **Strategic positioning**: Efficient material transport to Mars

Current Venus assessment shows habitation unlikely due to 400°C+ temperatures, 90+ bar pressure, sulfuric acid atmosphere, and limited water. However, its industrial role has become permanent.

#### Current Capabilities
- **Atmospheric modifications** through industrial processors
- **Basic lifeform introduction** with hardy microorganisms
- **Resource importation** from other solar system bodies
- **Future portal technology** for specialized transport (personnel and small cargo) within and between star systems via hub networks, including ship-based emergency transport
- **Engineering potential** for specialized material transfer through continuous portal loop systems (complements cycler craft for bulk transport)
- **Cryogenic storage networks** (e.g., Venus-Titan gas banking for Mars terraforming)
- **Distributed processing networks** (e.g., Venus CO2 → O2/CO separation with portal transport to Mars/orbital depots)
- **Hydrogen fuel cycles** (e.g., outer solar system H2 import to Mars for water production via O2 combustion)

**Player Integration**: These portal systems operate as background mechanics providing economic opportunities and strategic constraints, enhancing player decision-making rather than becoming direct controls.

### AI Manager Comprehensive Role
**Multi-System Development Coordinator**: The AI manager oversees interconnected development systems that enable and accelerate player expansion.

#### Large-Scale Project Oversight
- **Terraforming Maintenance**: Manages ongoing planetary modification operations
- **Infrastructure Expansion**: Builds and maintains colony facilities and networks
- **Resource Allocation**: Optimizes long-term resource distribution for sustained growth
- **Progress Assurance**: Ensures development continues independent of player activity

#### Foothold Protocol Execution
- **Initial Base Construction**: Establishes Development Corporation Bases as colonization beachheads
- **Strategic Site Selection**: Positions initial settlements in optimal expansion locations
- **Foundation Development**: Creates basic infrastructure to support early colonization efforts
- **Player Enablement**: Provides platforms for player-driven colony development

#### Wormhole Network Development
- **System Expansion**: Increases accessible star systems for player exploration
- **Network Infrastructure**: Builds and maintains wormhole connections between systems
- **Exploration Pathways**: Opens new territories for colonization and trade
- **Inter-System Connectivity**: Creates routes for migration and resource exchange

#### Population Dynamics
- **Workforce Allocation**: 1-20% of population dedicated to terraforming (unless AI-assisted)
- **Growth Simulation**: Births (1.5%), deaths (0.8%), immigration (1%) affect labor availability
- **AI Assistance**: Reduces human workforce requirements for accelerated progress

### Population Simulation

Planetary populations evolve through:
- **Initial Settlement**: 20,000-150,000 colonists
- **Demographic Changes**: Births, deaths, immigration/emigration
- **Economic Factors**: Credits and resources influence population growth
- **Terraforming Impact**: Successful terraforming attracts more settlers

### Economic Engine

#### Resource Markets
- **Dynamic Pricing**: Supply and demand affect resource values
- **Interplanetary Trade**: Transport costs and time delays
- **Market Manipulation**: Players can influence prices through bulk transactions

#### Trade Simulation
- **Import Costs**: 100-500 credits per material unit
- **Export Earnings**: 50-200 credits per unit
- **Net Economics**: Imports minus exports affect planetary credits
- **Sustainability**: Colonies must maintain positive credit balance for operations

#### Production Chains
- **Raw Materials**: Extracted from planetary surfaces
- **Processed Goods**: Manufactured in orbital facilities
- **Finished Products**: Used for construction and trade

### AI Management

The AI Manager ensures autonomous game progression through:
- **Player-First Task Assignment:** Offers contracts to players (24-48h timeout), then assigns to NPCs if declined
- **Automated Missions:** Pre-planned colonization sequences execute whether players participate or not
- **Resource Allocation:** Optimal distribution of equipment across Sol system and wormhole networks
- **Crisis Response:** Emergency resource deployment maintains system stability
- **Pattern Learning:** Improvement through successful operations (Luna, Mars, Venus, Titan, Gas Giant patterns)
- **NPC Fallback:** Autonomous execution ensures game progression never stalls waiting for players

### Player Progression Path

#### Beginner Phase (Tutorial)
- **Simple Deliveries:** Luna → L1, Venus → LEO contracts
- **First GCC Earnings:** Complete missions to understand economy
- **Learn Market Basics:** Buy materials, fuel with earned GCC
- **Build Reputation:** Successful contracts unlock better opportunities

#### Intermediate Phase (After Reputation Threshold)
- **Multi-Leg Logistics:** Titan methane → Mars, Venus CO₂ → LEO
- **Outer Planet Missions:** Jupiter, Saturn, Uranus, Neptune depot operations
- **Higher GCC Rewards:** Access to premium contracts
- **Market Competition:** Outbid NPCs for valuable resources

#### Advanced Phase (High Reputation)
- **Wormhole Logistics:** Sol → AOL-732356 Prize World transport
- **Consortium Membership:** Vote on network routes, invest in AWS construction
- **Specialized Roles:** Exploration scouts, manufacturing specialists, fuel traders
- **Economic Influence:** High GCC balance shapes development priorities

## Victory Conditions

### Economic Victory
- Achieve target profit margins across all operations
- Establish self-sustaining interplanetary economy
- Maximize resource throughput efficiency

### Technological Victory
- Complete all terraforming projects
- Establish colonies on all major celestial bodies
- Develop advanced manufacturing capabilities

### Exploration Victory
- Survey and establish presence on all planetary systems
- Catalog all unique planetary phenomena
- Achieve complete scientific understanding

## Difficulty Levels

### Beginner
- Simplified resource chains
- Generous time limits
- AI assistance for planning
- Reduced failure consequences

### Standard
- Full complexity resource management
- Realistic time constraints
- Moderate AI assistance
- Standard failure penalties

### Expert
- Maximum complexity
- Minimal AI assistance
- Harsh failure penalties
- Real-time decision requirements

## Multiplayer Considerations

### Cooperative Mode
- Shared resource pools
- Combined terraforming efforts
- Competitive economic objectives

### Competitive Mode
- Resource competition
- Market manipulation
- Territory control
- Espionage mechanics

## Balance Considerations

### Resource Scarcity
- Limited rare materials require interplanetary trade
- Time delays encourage strategic planning
- Market fluctuations create economic challenges

### Technological Dependencies
- Advanced equipment requires rare materials
- Research prerequisites create progression gates
- Upgrade paths offer meaningful choices

### Risk/Reward Balance
- High-risk operations offer high rewards
- Failure penalties encourage conservative strategies
- Recovery mechanics prevent permanent setbacks