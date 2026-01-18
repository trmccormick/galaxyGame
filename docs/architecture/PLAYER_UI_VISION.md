# Player UI Vision - SimEarth Meets Eve Online

**⚠️ CRITICAL**: This is a **FUTURE VISION DOCUMENT** - NOT current development priorities.

**Current Development Focus** (Jan 2026): AI Manager pattern learning in Sol system, then wormhole expansion to Prize systems like AOL-732356. **Players are NOT being introduced yet** - this is testing and buildout only. See [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) for actual development sequence.

**Purpose**: Define the player-facing UI IF/WHEN players are introduced (potentially after wormhole network operational).

**Philosophy**: Players would be participants in an existing AI-managed economy (not empty sandbox), learning through contracts and missions in a SimEarth-style universe with Eve Online economic depth.

**Target Timeline**: Unknown - depends on AI Manager testing success. Earliest possible: After Milestone 5 (wormhole network stable). See [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md#player-integration-future---not-current-development) for details.

---

## 🌍 Living Solar System at Player Entry

### NPC Infrastructure Already Active

**When players join, NPCs have completed:**
- ✅ **Luna Base**: Regolith I-beam and panel production operational
- ✅ **L1 Station**: Ship construction bays, tug/cycler manufacturing
- ✅ **LEO Depot**: Earth orbit refueling and cargo staging
- ✅ **Mars (Phobos)**: Hybrid station (Luna + L1 patterns), terraforming support
- ✅ **Venus Orbital**: Artificial moon depots, atmospheric harvesting (N2, O2, CO)
- ✅ **Titan/Saturn**: Fuel production (methane, ethane), helium-3 processing
- ✅ **Jupiter System**: Helium-3 harvesting, moon depot network (Callisto, Ganymede, Europa, Io)
- ✅ **Uranus System**: Ammonia depot, atmospheric siphon operations
- ✅ **Neptune System**: Triton nitrogen processing, helium-3 extraction, research base

**Outer Planet Depot Stations (Already Built)**:
- Jupiter: Radiation-shielded orbital station + 4 moon depots (Callisto, Ganymede, Europa, Io)
- Saturn: Titan resource hub + small moon network (Enceladus, Dione, Rhea)
- Uranus: Ammonia processing depot + atmospheric siphon platform
- Neptune: Triton surface base + orbital depot, nitrogen/helium-3 processing

**Active Markets**:
- GCC markets at each settlement with baseline pricing
- NPC buy/sell contracts for materials, fuel, gases
- Automated logistics contracts (transport between settlements)
- NPC-to-NPC trading via Virtual Ledger (internal accounting)

**Early Terraforming Operations**:
- **Mars**: Phase 2 atmospheric enrichment active (CO2 import from Venus, N2 from Triton/Titan)
- **Venus**: Industrial hub established, cloud city operations, atmospheric resource extraction
- NPCs managing gas transport contracts (Venus → Mars for N2/CO2 terraforming)

---

## 🎮 Player Experience Philosophy

### SimEarth: Universe Building Focus

**What Players Do**:
- Manage economic flows (not micro-control)
- Optimize logistics routes (not design every structure)
- Participate in terraforming (not control every molecule)
- Build reputation through contracts (not combat)

**What AI/NPCs Handle**:
- Daily settlement operations
- Automated production scheduling
- Standard resource extraction
- Baseline trade fulfillment

**SimEarth Visual Style**:
- Top-down system view (planetary orbits, trade routes visible)
- Data-rich displays (atmospheric composition, resource flows, economic indicators)
- Time acceleration (watch years of terraforming in minutes via simulation)
- What-if scenarios (test contract strategies before committing)

### Eve Online: Economic Depth

**What Players Control**:
- Contract bidding (undercut NPCs, specialize in niches)
- Market speculation (futures, derivatives, resource hoarding)
- Logistics optimization (find profitable routes NPCs miss)
- Corporation formation (player alliances, shared contracts)

**What Game Provides**:
- Deep market data (price history, supply/demand trends, competitor analysis)
- Contract system (delivery, courier, manufacturing, resource extraction)
- Reputation mechanics (NPCs trust experienced players with better contracts)
- Insurance/collateral (protect against contract failures)

**Eve Online UI Style**:
- Information density (compact tables, filters, sorting)
- Market visualization (price charts, order books, transaction logs)
- Contract complexity (multi-step delivery chains, escrow, collateral)
- Player-driven pricing (set own buy/sell orders, not fixed prices)

---

## 🖥️ Current UI Status vs Required

### ✅ Admin UI (Exists - For Development/Testing)

**Location**: `/admin/*` routes

**Current Features**:
- ✅ AI Manager Mission Planner ([/admin/ai_manager/planner](galaxy_game/app/views/admin/ai_manager/planner.html.erb))
  - SimEarth-style mission simulation (5 patterns: Mars, Venus, Titan, Asteroid, Europa)
  - Resource forecasting, economic impact analysis
  - Player opportunity calculation
  - Export to JSON or generate contracts
  
- ✅ Development Corporation Operations ([/admin/development_corps](galaxy_game/app/views/admin/development_corps/operations.html.erb))
  - NPC organization tracking (Development Corps, Service Corps, Consortiums)
  - Settlement listings, active contracts
  - GCC balance display, production capabilities
  
- ✅ AI Manager Missions View ([/admin/ai_manager/missions](galaxy_game/app/views/admin/ai_manager/missions.html.erb))
  - Active/completed/failed mission tracking
  - Phase progression monitoring
  - Mission reset and advancement controls
  
- ✅ Celestial Body Monitor
  - Planetary geological feature visualization
  - Atmospheric composition tracking
  - Resource availability data

**Purpose**: Developer debugging and testing (NOT player-facing)

---

### ❌ Player UI (MISSING - Needs Implementation)

**Critical Gaps for Player Entry**:

#### 1. **Player Dashboard** (No Implementation)

**Required Features**:
- Account overview (GCC balance, reputation score, active contracts)
- Quick stats (contracts completed, deliveries made, total earnings)
- Notifications (contract offers, market alerts, system events)
- Recent activity log (last 10 transactions, contract completions)

**SimEarth Elements**:
- Solar system map (see all settlements, routes, current location)
- Resource flow visualization (D3.js Sankey diagram showing GCC movement)
- Time acceleration controls (speed up simulation for long-haul routes)

**Eve Online Elements**:
- Market ticker (live price updates for key materials)
- Contract alerts (new high-value opportunities)
- Corporation roster (if player joined organization)

**Missing Files**:
- `galaxy_game/app/controllers/players_controller.rb` (doesn't exist)
- `galaxy_game/app/views/players/dashboard.html.erb` (doesn't exist)
- `galaxy_game/app/models/player.rb` (may need enhancement for UI)

---

#### 2. **Contract/Mission Board** (No Implementation)

**Required Features**:
- Available contracts list (filterable by type, location, reward, difficulty)
- Contract details view (requirements, reward, collateral, time limit, issuer reputation)
- Accept contract button (with collateral deposit if required)
- Active contracts tracker (progress bars, deadlines, delivery status)
- Contract history (completed, failed, expired with performance metrics)

**Contract Types** (from existing [MissionContract model](galaxy_game/app/models/mission_contract.rb)):
- Resource delivery (transport X tons of material from A to B)
- Manufacturing (produce Y units of item using provided materials)
- Exploration (survey location, return geological data)
- Construction (deliver construction materials to settlement)

**SimEarth Elements**:
- Contract impact visualization (how this contract affects system resource flows)
- Completion simulator (estimate time, profit margin, risk factors)
- Tutorial contracts (low-risk intro missions with guidance)

**Eve Online Elements**:
- Contract comparison (sort by GCC/hour, risk-adjusted ROI)
- Issuer reputation display (NPCs with track record, player reviews)
- Collateral requirements (escrowed GCC to guarantee performance)
- Multi-leg contracts (A → B → C delivery chains with higher rewards)

**Missing Files**:
- `galaxy_game/app/controllers/contracts_controller.rb` (doesn't exist)
- `galaxy_game/app/views/contracts/index.html.erb` (browse available)
- `galaxy_game/app/views/contracts/show.html.erb` (contract details)
- `galaxy_game/app/views/contracts/active.html.erb` (player's active contracts)

**Partially Exists**:
- ✅ `galaxy_game/app/models/mission_contract.rb` (backend model exists)
- ✅ `galaxy_game/app/services/mission_contract_service.rb` (contract logic exists)
- ❌ No player-facing views or controllers

---

#### 3. **Market Interface** (No Implementation)

**Required Features**:
- Buy/sell order book (live market depth for each material)
- Price charts (historical pricing, 30/90/365 day trends)
- Own orders management (create buy/sell orders, cancel, modify)
- Transaction history (past trades with profit/loss calculation)
- Market alerts (price threshold notifications)

**Materials Trading**:
- Raw materials (regolith, ice, methane, ammonia, CO2, N2, O2)
- Processed goods (I-beams, panels, fuel, construction materials)
- Manufactured items (ships, tugs, cyclers, station modules)

**SimEarth Elements**:
- System-wide resource flow (see how your trade affects planetary supplies)
- Production forecast (predict future supply/demand based on active missions)
- Settlement needs visualizer (which settlements need what materials)

**Eve Online Elements**:
- Order book depth (see buy/sell walls, liquidity)
- Spread analysis (bid-ask spread, arbitrage opportunities)
- Volume indicators (daily trading volume, market liquidity)
- Regional markets (different pricing at Luna vs Mars vs Titan)

**Missing Files**:
- `galaxy_game/app/controllers/markets_controller.rb` (doesn't exist)
- `galaxy_game/app/views/markets/index.html.erb` (market overview)
- `galaxy_game/app/views/markets/material.html.erb` (individual material trading)
- `galaxy_game/app/models/market_order.rb` (may need creation or enhancement)

**Note**: Market backend may exist (GCC currency system operational), but no player UI to interact with it.

---

#### 4. **Ship/Cargo Management** (No Implementation)

**Required Features**:
- Ship inventory (current cargo, capacity, location)
- Route planner (plot course from A to B with delta-v cost)
- Fuel calculator (estimate fuel consumption for route)
- Cargo manifest (what's loaded, destination, contract assignment)
- Ship status (location, velocity, ETA to destination)

**Ship Types** (from mission data):
- Tug (short-range cargo hauler, asteroid repositioning)
- Cycler (long-range continuous orbit transport)
- Skimmer (atmospheric gas harvesting)
- Ferry shuttle (passenger/cargo transfer to cyclers)

**SimEarth Elements**:
- Orbital mechanics visualization (Hohmann transfers, delta-v diagrams)
- Time acceleration (fast-forward long journeys)
- Fuel efficiency comparison (optimize routes for profit)

**Eve Online Elements**:
- Cargo value tracking (total GCC value of loaded cargo)
- Insurance status (ship coverage, collateral protection)
- Route safety (NPC traffic, accident risk, contract reliability)

**Missing Files**:
- `galaxy_game/app/controllers/ships_controller.rb` (doesn't exist)
- `galaxy_game/app/views/ships/index.html.erb` (player's ships)
- `galaxy_game/app/views/ships/show.html.erb` (ship details, cargo)
- `galaxy_game/app/models/ship.rb` (may need creation or enhancement)

---

#### 5. **Settlement/Production View** (No Implementation)

**Required Features** (if player owns/manages settlement):
- Production queue (what's being manufactured, completion time)
- Resource storage (current inventory levels, capacity)
- Production capacity (available manufacturing bays, upgrades)
- Contract fulfillment (auto-assign production to accepted contracts)
- Upgrade planning (what modules can be built, cost, benefit)

**SimEarth Elements**:
- Settlement efficiency metrics (production vs capacity, idle time)
- Resource flow diagram (inputs → production → outputs)
- Expansion simulator (test upgrade impact before building)

**Eve Online Elements**:
- Cost-benefit analysis (ROI on production upgrades)
- Market integration (auto-sell excess production)
- Contract automation (fulfill recurring orders automatically)

**Missing Files**:
- `galaxy_game/app/controllers/settlements_controller.rb` (may exist but needs player UI)
- `galaxy_game/app/views/settlements/show.html.erb` (settlement dashboard)
- `galaxy_game/app/views/settlements/production.html.erb` (production management)

**Note**: Settlement models exist (used by NPCs), but no player ownership/management UI.

---

#### 6. **Reputation & Progression System** (No Implementation)

**Required Features**:
- Reputation score (trustworthiness with NPCs, contract success rate)
- Rank progression (rookie → experienced → expert → master trader)
- Unlock tiers (higher reputation unlocks better contracts, lower collateral)
- Performance metrics (on-time delivery %, contract completion rate, profit margin)
- NPC relationships (faction standing, preferred trader bonuses)

**SimEarth Elements**:
- Economic impact score (how much player contributed to system growth)
- Terraforming participation (assisted X tons of CO2 to Mars)

**Eve Online Elements**:
- Reputation decay (inactive players lose standing over time)
- Faction bonuses (Development Corps offer better rates to high-rep players)
- Blacklisting (failed contracts hurt reputation, harder to get new ones)

**Missing Files**:
- `galaxy_game/app/models/player_reputation.rb` (doesn't exist)
- `galaxy_game/app/services/reputation_service.rb` (doesn't exist)
- `galaxy_game/app/views/players/reputation.html.erb` (reputation dashboard)

---

#### 7. **Tutorial/Onboarding Flow** (No Implementation)

**Required Features**:
- Welcome screen (lore introduction, game concept explanation)
- First contract tutorial (walk through accepting, completing simple delivery)
- Market tutorial (buy low, sell high with guided example)
- Ship tutorial (plot route, manage fuel, deliver cargo)
- Progression tutorial (how reputation unlocks better opportunities)

**Tutorial Contracts** (should be auto-generated by AI Manager):
1. **Simple Delivery**: Transport 10 tons regolith from Luna to L1 (reward: 500 GCC)
2. **Market Trade**: Buy methane at Titan, sell at Mars (reward: profit margin lesson)
3. **Production Order**: Deliver 5 I-beams to Venus depot (reward: 1000 GCC, unlocks manufacturing contracts)

**Missing Files**:
- `galaxy_game/app/controllers/tutorials_controller.rb` (doesn't exist)
- `galaxy_game/app/views/tutorials/welcome.html.erb` (onboarding flow)
- `galaxy_game/app/views/tutorials/first_contract.html.erb` (contract tutorial)

---

#### 8. **System Map/Navigation** (No Implementation)

**Required Features**:
- Solar system map (all planets, moons, settlements visible)
- Zoom controls (system overview → planetary detail → settlement level)
- Trade route overlay (visualize active contracts, NPC logistics)
- Resource flow animation (see GCC and materials moving between settlements)
- Filter controls (show only fuel depots, only manufacturing, only markets)

**SimEarth Visual Style**:
- Top-down 2D view (not 3D flight simulator)
- Orbital paths visible (planetary positions accurate to current sim time)
- Time controls (speed up to watch trade routes over days/weeks)

**Interactive Elements**:
- Click settlement → view market, contracts, production
- Click route → see ships in transit, cargo, ETA
- Click planet → atmospheric composition, terraforming progress

**Missing Files**:
- `galaxy_game/app/views/game/system_map.html.erb` (doesn't exist)
- `galaxy_game/app/javascript/system_map.js` (D3.js or Canvas rendering)
- `galaxy_game/app/controllers/game_controller.rb` (may exist but needs enhancement)

**Partially Exists**:
- ✅ Admin has celestial body monitor (could be adapted)
- ❌ No player-facing system map with trade routes

---

## 🏗️ Implementation Priority

### Phase 4.1: Core Player Experience (Highest Priority)

**Goal**: Players can join, accept contracts, complete deliveries, earn GCC

**Required Components**:
1. **Player Dashboard** (overview, balance, notifications)
2. **Contract Board** (browse, accept, track active contracts)
3. **Ship Management** (basic cargo, route planning, delivery)
4. **Tutorial Flow** (onboarding for new players)

**Estimated Effort**: 2-3 weeks (after test suite green)

**Deliverables**:
- Players can register accounts
- Players can browse and accept contracts from NPCs
- Players can complete simple delivery contracts
- Players receive GCC rewards and build reputation
- Tutorial guides players through first 3 contracts

---

### Phase 4.2: Economic Depth (Medium Priority)

**Goal**: Players engage with market, optimize profits, specialize

**Required Components**:
1. **Market Interface** (buy/sell orders, price charts, trading)
2. **Reputation System** (unlock better contracts, NPC relationships)
3. **Production View** (if player builds/owns settlements)

**Estimated Effort**: 2-3 weeks (after Phase 4.1)

**Deliverables**:
- Players can trade materials on GCC markets
- Players see historical pricing and trends
- Reputation unlocks higher-value contracts
- Players can specialize (logistics, manufacturing, exploration)

---

### Phase 4.3: Strategic Tools (Lower Priority)

**Goal**: Players optimize at system level, participate in terraforming

**Required Components**:
1. **System Map** (trade route visualization, resource flows)
2. **Settlement Management** (if players own production facilities)
3. **Economic Forecasting** (simulate contract strategies before committing)

**Estimated Effort**: 2-3 weeks (after Phase 4.2)

**Deliverables**:
- Players see entire solar system economy in motion
- Players can test "what-if" scenarios (SimEarth style)
- Players participate in terraforming (deliver CO2 to Mars for rewards)
- System-level optimization (find arbitrage opportunities)

---

### Phase 4.4: Corporation & Social (Future)

**Goal**: Players form alliances, share contracts, coordinate logistics

**Required Components**:
1. **Corporation System** (player organizations, shared warehouses)
2. **Contract Sharing** (corporation-wide contract pools)
3. **Reputation Bonuses** (corporation standing with NPC factions)

**Estimated Effort**: 3-4 weeks (after Phase 4.3)

**Deliverables**:
- Players can form/join corporations
- Corporation members share warehouse space
- Pooled contracts (multi-player delivery chains)
- Corporation reputation (better rates from NPCs)

---

## 🎨 UI Design Mockups (Conceptual)

### Player Dashboard (SimEarth + Eve Online Hybrid)

```
┌──────────────────────────────────────────────────────────────────┐
│ GALAXY GAME - Player Dashboard                    [Player Name]  │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ GCC Balance     │  │ Active Contracts │  │ Reputation      │ │
│  │ 45,320 GCC      │  │ 3 in progress    │  │ ★★★★☆ (Expert)  │ │
│  │ +2,400 (24h)    │  │ 1 pending pickup │  │ Next: Master    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ SOLAR SYSTEM MAP                       [Zoom] [Filter]    │  │
│  │                                                            │  │
│  │         ☉ Sun                                             │  │
│  │                                                            │  │
│  │    ⚪ LEO Depot ───→ 🌍 Earth                             │  │
│  │                                                            │  │
│  │           🌙 Luna ←─── [YOUR SHIP HERE]                   │  │
│  │              │                                             │  │
│  │              └───→ L1 Station                             │  │
│  │                                                            │  │
│  │                      🔴 Mars (Phobos)                     │  │
│  │                                                            │  │
│  │                            ♀ Venus                        │  │
│  │                                                            │  │
│  │                                  ♄ Saturn (Titan)         │  │
│  │                                                            │  │
│  │  [Trade Routes: ON] [Settlements: ON] [Ships: ON]        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ ACTIVE CONTRACTS                              [View All]  │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ ▸ Deliver 50t Methane: Titan → Mars                      │  │
│  │   Reward: 3,200 GCC | Progress: ████████░░ 80%           │  │
│  │   ETA: 2.3 days | Fuel remaining: 85%                    │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ ▸ Transport I-beams: Luna → Venus Depot                  │  │
│  │   Reward: 1,800 GCC | Status: Pending pickup             │  │
│  │   Deadline: 7 days | Collateral: 500 GCC (escrowed)      │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ MARKET ALERTS                                             │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ ⚠ Methane price at Mars +15% (terraforming demand)       │  │
│  │ ✓ I-beam oversupply at Luna -8% (good buying opportunity)│  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  [View Contracts] [Markets] [Ships] [Reputation] [Tutorial]     │
└──────────────────────────────────────────────────────────────────┘
```

---

### Contract Board (Eve Online Style)

```
┌──────────────────────────────────────────────────────────────────┐
│ CONTRACT BOARD - Available Missions                              │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  [Filter: All Types ▼] [Location: All ▼] [Sort: Reward ▼]      │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ DELIVERY CONTRACT #4523                      [ACCEPT]     │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ Issuer: Luna Development Corp (★★★★★ Trusted)            │  │
│  │ Type: Resource Delivery                                   │  │
│  │ Route: Luna Base → L1 Station                            │  │
│  │ Cargo: 100 tons Regolith I-beams                         │  │
│  │ Reward: 2,500 GCC                                         │  │
│  │ Collateral: 500 GCC (returned on completion)             │  │
│  │ Deadline: 5 days                                          │  │
│  │ Difficulty: ★☆☆☆☆ (Beginner-friendly)                   │  │
│  │                                                            │  │
│  │ [View Details] [Calculate Profit] [Accept Contract]       │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ MULTI-LEG DELIVERY #4524                     [ACCEPT]     │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ Issuer: Mars Terraforming Initiative (★★★★☆)             │  │
│  │ Type: Multi-destination Delivery Chain                    │  │
│  │ Route: Venus → L1 Station → Mars (Phobos)                │  │
│  │ Cargo: 200 tons CO2 gas (terraforming supply)            │  │
│  │ Reward: 8,500 GCC (+500 GCC bonus if under 10 days)      │  │
│  │ Collateral: 2,000 GCC (escrowed)                          │  │
│  │ Deadline: 15 days                                         │  │
│  │ Difficulty: ★★★☆☆ (Experienced traders)                  │  │
│  │                                                            │  │
│  │ [View Details] [Fuel Estimate] [Accept Contract]          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ MANUFACTURING ORDER #4525                    [ACCEPT]     │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ Issuer: Jupiter Orbital Hub Corp (★★★★★)                 │  │
│  │ Type: Production Contract                                 │  │
│  │ Location: Player's Settlement (must have manufacturing)   │  │
│  │ Produce: 50x Structural Panels (materials provided)       │  │
│  │ Reward: 4,200 GCC                                         │  │
│  │ Deadline: 7 days                                          │  │
│  │ Difficulty: ★★☆☆☆ (Requires manufacturing bay)           │  │
│  │                                                            │  │
│  │ [View Requirements] [Check Capacity] [Accept Contract]    │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  [Page 1 of 12] [Next] [Filter Options] [Tutorial Contracts]    │
└──────────────────────────────────────────────────────────────────┘
```

---

### Market Interface (Eve Online Order Book Style)

```
┌──────────────────────────────────────────────────────────────────┐
│ MARKET - Methane (CH4)                          Location: Titan  │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────┐  ┌─────────────────────────────────────┐│
│  │ CURRENT PRICE      │  │ PRICE CHART (30 Days)               ││
│  │ 45.2 GCC/ton       │  │                                     ││
│  │ ▲ +2.3% (24h)      │  │ 50 GCC ┤         ╱╲                ││
│  │                    │  │        │      ╱╲/  \                ││
│  │ Spread: 1.2 GCC    │  │ 45 GCC ┤─────╱      ╲───╲╱─────    ││
│  │ Volume: 2.3M tons  │  │        │                     ╲      ││
│  └────────────────────┘  │ 40 GCC ┤                      ╲__   ││
│                          │        └──────────────────────────   ││
│                          │         1d    7d    14d    30d       ││
│                          └─────────────────────────────────────┘│
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ ORDER BOOK                                                 │  │
│  ├─────────────────────────┬─────────────────────────────────┤  │
│  │ BUY ORDERS              │ SELL ORDERS                     │  │
│  ├─────────────────────────┼─────────────────────────────────┤  │
│  │ Price (GCC/t) | Volume  │ Price (GCC/t) | Volume          │  │
│  ├─────────────────────────┼─────────────────────────────────┤  │
│  │ 44.8          | 1,200t  │ 45.5          | 800t            │  │
│  │ 44.5          | 2,500t  │ 45.8          | 1,500t          │  │
│  │ 44.2          | 1,800t  │ 46.0          | 2,200t          │  │
│  │ 44.0          | 3,000t  │ 46.5          | 5,000t (NPC)    │  │
│  │ 43.5          | 10,000t │ 47.0          | 20,000t (NPC)   │  │
│  └─────────────────────────┴─────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ PLACE ORDER                                                │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ [Buy] [Sell]                                              │  │
│  │                                                            │  │
│  │ Price: [45.0] GCC/ton  (Market: 45.2 GCC/ton)            │  │
│  │ Volume: [500] tons                                        │  │
│  │ Total: 22,500 GCC                                         │  │
│  │                                                            │  │
│  │ Order Type: [Limit ▼] [Immediate ▼]                      │  │
│  │ Duration: [30 days ▼]                                     │  │
│  │                                                            │  │
│  │              [Place Order] [Simulate Profit]               │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ YOUR ACTIVE ORDERS                       [Cancel All]     │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ BUY 1,000t @ 44.0 GCC/ton (expires in 28 days) [Cancel]  │  │
│  │ SELL 500t @ 46.5 GCC/ton (expires in 15 days) [Cancel]   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  [Markets Home] [Transaction History] [My Orders] [Alerts]       │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Integration Requirements

### Backend Services Already Exist (Partial)

**Existing Components**:
- ✅ `MissionContract` model ([galaxy_game/app/models/mission_contract.rb](galaxy_game/app/models/mission_contract.rb))
- ✅ `MissionContractService` ([galaxy_game/app/services/mission_contract_service.rb](galaxy_game/app/services/mission_contract_service.rb))
- ✅ `PlayerContract` migration ([galaxy_game/db/migrate/20260112010001_create_player_contracts.rb](galaxy_game/db/migrate/20260112010001_create_player_contracts.rb))
- ✅ `AIManager::MissionPlannerService` (economic forecasting)
- ✅ `AIManager::EconomicForecasterService` (market pricing simulation)

**Missing Components**:
- ❌ Player authentication/registration system
- ❌ Player model with GCC wallet, reputation, contract history
- ❌ Market order model (buy/sell orders, order book)
- ❌ Ship model (cargo, fuel, location, route)
- ❌ Notification system (contract alerts, market alerts)
- ❌ Tutorial system (onboarding flow, progressive unlocks)

---

### Required API Endpoints (All Missing)

**Player Management**:
- `POST /api/players/register` - Create new player account
- `GET /api/players/:id/dashboard` - Player dashboard data
- `GET /api/players/:id/stats` - Reputation, earnings, contracts completed

**Contracts**:
- `GET /api/contracts` - List available contracts (filterable)
- `GET /api/contracts/:id` - Contract details
- `POST /api/contracts/:id/accept` - Accept contract (deposit collateral)
- `GET /api/contracts/active` - Player's active contracts
- `POST /api/contracts/:id/complete` - Mark contract complete (trigger payment)

**Markets**:
- `GET /api/markets/:location` - Market data for location (Titan, Luna, Mars, etc.)
- `GET /api/markets/:location/:material` - Order book for specific material
- `POST /api/markets/orders` - Place buy/sell order
- `DELETE /api/markets/orders/:id` - Cancel order
- `GET /api/markets/history/:material` - Historical pricing data

**Ships**:
- `GET /api/ships` - Player's ships
- `GET /api/ships/:id` - Ship details (cargo, fuel, location)
- `POST /api/ships/:id/load_cargo` - Load cargo for contract
- `POST /api/ships/:id/set_route` - Plot route A → B
- `POST /api/ships/:id/deliver` - Deliver cargo (complete contract leg)

**System Map**:
- `GET /api/system/settlements` - All settlements with locations
- `GET /api/system/routes` - Active trade routes (visualization data)
- `GET /api/system/ships_in_transit` - All ships currently en route

---

## 🎯 Success Metrics for Player UI

### Engagement Metrics

**Tutorial Completion**:
- Target: >80% of new players complete first 3 contracts
- Metric: Time from registration to first contract completion
- Success: <30 minutes average

**Contract Participation**:
- Target: >60% of players accept at least 1 contract per week
- Metric: Active contract ratio (players with active contracts / total players)
- Success: >50% players have active contract at any given time

**Market Activity**:
- Target: >40% of players place at least 1 market order per week
- Metric: Player-to-player trade volume vs NPC trade volume
- Success: >20% of total market volume from player orders

### Economic Metrics

**Player Income**:
- Target: Players can earn 10K+ GCC per week from contracts
- Metric: Average GCC earned per active player per week
- Success: Players can sustain operations without Earth imports

**Market Efficiency**:
- Target: Player competition reduces NPC profit margins by 10-15%
- Metric: Average contract completion cost (NPC baseline vs player undercuts)
- Success: Players find profitable niches NPCs don't optimize

**Specialization**:
- Target: >30% of players specialize in specific contract types
- Metric: Player contract type distribution (delivery, manufacturing, exploration)
- Success: Diverse player economy (not everyone doing same contracts)

### Retention Metrics

**7-Day Retention**:
- Target: >60% of players return after first week
- Metric: Players active on Day 7 vs Day 1
- Success: Tutorial effectively teaches game loop

**30-Day Retention**:
- Target: >40% of players still active after 1 month
- Metric: Players active on Day 30 vs Day 1
- Success: Contracts remain engaging, not repetitive

**Wormhole Event Retention**:
- Target: >70% of active players participate in wormhole discovery crisis
- Metric: Players active during "The Snap" event vs week prior
- Success: Crisis drives engagement, players become stakeholders

---

## 🚀 Next Steps

### Immediate Actions (After Test Suite < 50 Failures)

1. **Create Player Model** - Authentication, GCC wallet, reputation
2. **Build Player Dashboard** - Simple overview (balance, contracts, reputation)
3. **Implement Contract Board** - Browse available contracts, accept, track active
4. **Create Tutorial Flow** - Onboarding with first 3 guided contracts

### Short-Term (Phase 4.1 - 2-3 weeks)

1. Complete player authentication and registration
2. Build contract browsing and acceptance UI
3. Implement basic ship/cargo management
4. Create tutorial system with 3 starter contracts
5. Deploy to staging for player testing

### Medium-Term (Phase 4.2 - 4-6 weeks)

1. Build market interface (order book, trading)
2. Implement reputation system (unlock progression)
3. Add settlement management (if players own production)
4. Expand contract types (manufacturing, exploration)

### Long-Term (Phase 4.3+ - 8-12 weeks)

1. System map with trade route visualization
2. Economic forecasting tools (SimEarth what-if scenarios)
3. Corporation system (player alliances)
4. Wormhole expansion participation (crisis event)

---

## 📖 Related Documentation

- [NPC_INITIAL_DEPLOYMENT_SEQUENCE.md](NPC_INITIAL_DEPLOYMENT_SEQUENCE.md) - What NPCs build before player entry
- [SIMEARTH_ADMIN_VISION.md](SIMEARTH_ADMIN_VISION.md) - Admin-side simulation and pattern learning
- [GUARDRAILS.md](../GUARDRAILS.md) - AI Manager economic rules and player-first mandate
- [wh-expansion.md](../../wh-expansion.md) - Wormhole expansion plan (player participation in crisis)
- [AI_MANAGER_PLANNER.md](../developer/AI_MANAGER_PLANNER.md) - Existing admin mission planner UI
- [planet_ui_development_plan.md](../developer/planet_ui_development_plan.md) - Admin monitoring interface

---

**Last Updated**: 2026-01-18  
**Status**: Vision document - implementation pending test suite green (<50 failures)  
**Next Review**: After Phase 4.1 implementation begins
