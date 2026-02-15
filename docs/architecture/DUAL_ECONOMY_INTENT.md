# Dual Economy Intent

## Overview

The game implements a **three-currency economic model** with Earth as the stabilizing anchor that enables debt and imports to grow the space economy. This realistic model allows NPCs to operate effectively even when GCC is scarce, with controlled currency expansion through LDC mining operations rather than arbitrary injection.

### Economic Foundation
- **Earth**: Stabilizing force enabling debt growth and critical imports
- **LDC (Lunar Development Corporation)**: The GCC mint - generates new GCC through crypto mining satellites
- **Virtual Ledger**: NPC-to-NPC accounting system when GCC reserves are insufficient
- **USD Flow**: Earth grants/exports → LDC → GCC mining → Space economy expansion → Lunar exports → Earth

## The Three Currencies

### 1. GCC (Galactic Crypto Currency)
- **Purpose**: Primary player currency, premium NPC pricing
- **Supply Mechanism**: **LDC mines GCC** via crypto mining satellites (controlled expansion)
- **Properties**: 
  - Symbol: `GCC`
  - Precision: 8 decimals (cryptocurrency-style)
  - System currency (`is_system_currency: true`)
- **Usage**: 
  - Player-to-NPC transactions (primary)
  - NPC-to-NPC when sufficient reserves available
  - Market orders, contracts, service payments
- **Creation**: LDC operates crypto mining satellites that generate new GCC (simulated mining, not real crypto)

### 2. Virtual Ledger
- **Purpose**: Internal NPC-to-NPC IOU system when GCC reserves are insufficient, preserving GCC for player transactions
- **Implementation**: Negative account balances (`Financial::Account.can_overdraft?`)
- **Key Behavior**:
  - **NPC-Only System**: Tracks obligations between NPCs without transferring real currency
  - Uses current market prices for transactions
  - NPCs/Colonies can go negative (overdraft enabled)
  - **Players cannot use Virtual Ledger** (no overdraft - always require real GCC)
  - **GCC Preservation**: Keeps GCC available for player contracts, mission rewards, and buy orders
- **Usage**: 
  - NPC-to-NPC resource trades when GCC reserves low
  - Service exchanges between Development Corporations
  - Deferred payment tracking for DC expansion support

### 3. USD (United States Dollar)
- **Purpose**: Earth anchor currency enabling debt and import-driven economic expansion
- **Properties**:
  - Symbol: `USD`
  - Precision: 2 decimals (traditional currency)
  - System currency (`is_system_currency: true`)
- **Usage**:
  - Earth-to-Space imports (via logistics corps)
  - Space-to-Earth exports (Helium-3, meteorites, lunar samples)
  - Logistics corps accept USD for Earth-side operations
  - LDC reserves from Earth grants and export revenue
  - Wormhole infrastructure fees ($1,000 USD per transit)
- **Economic Role**: **Earth is the stabilizing force** - USD enables debt growth, critical imports, and economic expansion beyond initial GCC supply

## Economic Entities

### Development Corporations (DCs)
- **Mission**: **Non-profit entities** building footholds on other worlds
- **Examples**: LDC (Lunar Development Corporation), MDC (Mars Development Corporation), TDC (Titan Development Corporation)
- **Economic Behavior**:
  - **Local Resource Priority**: Prefer local resource harvesting over importing when possible, but import when infrastructure is incomplete or resources unavailable (e.g., Luna lacks N2)
  - Trade resources via **Virtual Ledger** when GCC reserves are low
  - Use real GCC when available without depleting reserves
  - Focus on infrastructure development, not profit maximization
  - Revenue from operations funds expansion (not shareholder profits)
- **Expansion Focus**: DCs prioritize establishing new footholds and supporting other DCs' expansion efforts
- **Player Order Priority**: Allow players first opportunity to fill resource orders; expired orders trigger DC automated harvesting or imports
- **Universal Infrastructure Model**: All DCs establish orbital stations and surface depots that serve as shared logistics hubs
- **Player Economic Hubs**: DCs provide essential services for players to sell harvested resources and acquire equipment
- **Multi-World Operations**: As DCs expand to new worlds, they create fueling/repair stations and trading posts
- **Inter-DC Cooperation**: DCs use Virtual Ledger to maintain supply lines and support each other's expansion, even during GCC scarcity
- **Unique Capabilities**: 
  - Can earn USD through Earth support contracts and exports
  - Can issue USD bonds for major capital projects (Earth-backed credit)
  - LDC specifically operates GCC mining satellites (the mint)

### Logistics Corps (e.g., AstroLift, Zenith Orbital, Vector Hauling)
- **Mission**: Bridge Earth ↔ Space operations with bidirectional supply chains across the solar system
- **Currency Acceptance**:
  - **USD**: Earth-side operations (terrestrial logistics, Earth contracts)
  - **GCC**: Space-side operations (orbital logistics, interplanetary transport)
- **Special Role**: 
  - Enable Earth imports when space-based production insufficient (equipment, specialized goods)
  - Enable exports from all DC locations when production creates surplus
  - Bidirectional supply ships maximize efficiency across all worlds
- **Universal Presence**: Logistics corps operate at all DC-established orbital stations and surface depots
- **Player Services**: Provide fueling, repair, and equipment acquisition services at every DC foothold
- **Business Dynamics**:
  - **Competition & Collaboration**: Companies compete for contracts but form joint ventures for major infrastructure projects
  - **Specialized Roles**: AstroLift (LEO depots), Zenith Orbital (station construction), Vector Hauling (cargo transport)
  - **Strategic Partnerships**: Multiple logistics corps can co-invest in infrastructure while maintaining competitive operations
  - **Shared Infrastructure**: Like airlines using the same airports, companies operate from shared facilities at all DC locations
  - **Commercial Operations**: Companies build and sell spacecraft at shipyards using local resources to players and other corporations

### LDC (Lunar Development Corporation)
- **Entity Type**: **Non-profit Development Corporation** (like all DCs - focused on infrastructure development, not profit maximization)
- **Critical Role**: **The GCC Mint** - LDC generates new GCC through crypto mining satellite operations
- **Bootstrap Sequence**: 
  1. Receive initial Earth grants for research/development
  2. Deploy first GCC crypto mining satellite (initial capital investment)
  3. Begin GCC generation to fund operations
  4. Mine lunar resources (Helium-3, meteorites, regolith samples, propellant)
  5. Sell lunar exports back to Earth on return supply ships
  6. Supply fuel to LEO depot for Earth-departing craft
  7. Use USD revenue to expand mining operations and GCC production
- **USD Revenue Sources**:
  - **Earth grants**: Research funding, development contracts
  - **Lunar exports to Earth**: Helium-3 (fusion fuel), meteorite samples, rare lunar materials
  - **LEO depot fuel sales**: Lunar-derived propellant for craft departing from Earth (LOX, LH2, methane)
  - **Support contracts**: Lunar radio telescope operations, research facilities
  - **Scientific partnerships**: Earth institutions pay for lunar research access
  - **Infrastructure hosting**: Fees for Earth-operated equipment on Luna
- **USD Usage**:
  - Purchase Earth items via AstroLift logistics (bidirectional supply ships)
  - **Import specialized resources unavailable locally** (e.g., N2 not available on Luna despite extensive ISRU infrastructure)
  - Import specialized equipment unavailable in space
  - Pay wormhole transit fees
  - Fund satellite launches for GCC mining expansion
  - Reinvest in lunar infrastructure (non-profit development mission)
- **GCC Generation**: Operates crypto mining satellites that produce new GCC, providing controlled currency supply growth
- **Joint Venture Partnerships**:
  - **Universal Model**: This shared infrastructure model applies to all DC orbital stations and surface depots across the solar system
  - **Multi-Company Collaborations**: LDC can form joint ventures with multiple logistics companies simultaneously
  - **AstroLift-LDC Infrastructure**: Co-own L1 stations, LEO depots, and shipyards (initial partnership)
  - **Partnership Model**: Logistics corps provide expertise and operations; LDC provides lunar resources
  - **Competitive Collaboration**: Even competing logistics companies can co-invest in infrastructure projects
  - **Shared Infrastructure Model**: Like airlines using the same airports, multiple companies operate from L1/LEO facilities
  - **Commercial Spacecraft Operations**: Companies build and sell craft at L1 shipyards using lunar resources to players and corporations
  - **Player Services**: Stations provide fueling, repair, resource trading, and equipment acquisition for all players
  - **Multiple Partners**: LDC works with various logistics companies (AstroLift, Zenith Orbital, Vector Hauling)
  - **Mutual Benefits**: All profit from joint ventures; LDC sells resources at depots and to logistics partners for construction
  - **Shipyard Access**: Logistics companies gain construction capabilities at L1 station/shipyard
  - **Non-Profit Focus**: LDC prioritizes footholds and expansion over profit maximization
- **Trade Balance**: Imports from Earth (equipment, specialized goods) balanced by exports to Earth AND Earth orbit (Helium-3, meteorites, samples, LEO depot propellant)

### MDC (Mars Development Corporation)
- **Entity Type**: **Non-profit Development Corporation** (like all DCs - focused on infrastructure development, not profit maximization)
- **Critical Role**: **Asteroid Belt Development** - MDC establishes footholds and resource extraction in the asteroid belt
- **Bootstrap Sequence**:
  1. Receive initial Earth grants for Mars colonization
  2. Establish Mars base infrastructure and ISRU capabilities
  3. Expand to asteroid belt operations (Ceres as primary hub)
  4. Develop asteroid mining and processing facilities
  5. Export rare metals and volatiles to Earth and inner planets
  6. Establish asteroid belt logistics network
- **USD Revenue Sources**:
  - **Earth grants**: Mars colonization funding, asteroid belt development contracts
  - **Asteroid exports**: Rare earth metals, platinum group metals, water ice, hydrocarbons
  - **Resource sales**: Volatiles and metals to inner planet colonies
  - **Infrastructure contracts**: Asteroid belt transportation and processing services
- **USD Usage**:
  - Purchase Earth items via AstroLift logistics
  - Import specialized mining and processing equipment
  - Fund asteroid belt expansion
  - Pay wormhole transit fees
  - Reinvest in Mars and asteroid infrastructure (non-profit development mission)
- **Joint Venture Partnerships**:
  - **Universal Model**: This shared infrastructure model applies to all DC orbital stations and surface depots across the solar system
  - **Multi-Company Collaborations**: MDC can form joint ventures with multiple logistics companies simultaneously
  - **AstroLift-MDC Infrastructure**: Co-own Ceres asteroid belt extraction facilities (initial partnership)
  - **Partnership Model**: Logistics corps provide transport and operations; MDC provides asteroid resources and mining expertise
  - **Competitive Collaboration**: Even competing logistics companies can co-invest in asteroid belt operations
  - **Shared Infrastructure Model**: Like airlines using the same airports, multiple companies operate from shared belt facilities
  - **Commercial Operations**: Companies build and sell asteroid mining craft using belt resources to players and corporations
  - **Player Services**: Depots provide fueling, repair, resource trading, and equipment acquisition for all players
  - **Multiple Partners**: MDC works with various logistics companies (AstroLift, Zenith Orbital, Vector Hauling)
  - **Mutual Benefits**: Both profit from joint ventures; MDC sells asteroid resources at depots and to logistics partners for operations
  - **Asteroid Access**: Logistics companies gain asteroid belt resource extraction and processing capabilities
  - **Non-Profit Focus**: MDC prioritizes footholds and expansion over profit maximization
- **Trade Balance**: Imports from Earth (equipment, specialized goods) balanced by exports to Earth AND inner planets (rare metals, volatiles, asteroid resources)

## Economic Flow Examples

### Example 1: Virtual Ledger Trade (GCC Scarce)
**Scenario**: AstroLift automated harvester delivers Titan gases to Luna

1. **Delivery**: AstroLift harvester arrives at Luna with raw gases
2. **Payment for Goods**: 
   - Luna pays AstroLift on **Virtual Ledger** (GCC scarce at Luna)
   - Transaction recorded as ledger obligation, no currency transfer
3. **Refuel & Repairs**: 
   - AstroLift craft refuels, performs maintenance at Luna
4. **Payment for Services**: 
   - Luna charges AstroLift on **Virtual Ledger** (offsetting obligations)
   - Net ledger position updated between entities
5. **GCC Settlement (when available)**:
   - If GCC becomes available at Luna, transactions settle with real GCC
   - Virtual Ledger obligations cleared, balances normalized

### Example 1b: Competitive Collaboration on Infrastructure
**Scenario**: Competing logistics companies co-invest in DC infrastructure across all locations

1. **Joint Venture Formation**: 
   - Multiple logistics companies (AstroLift, Zenith Orbital, MDC, etc.) form joint ventures with LDC at every DC foothold
   - Even though they compete for transport contracts, they collaborate on shared infrastructure at all orbital stations and surface bases
2. **Capital Investment**: 
   - Companies invest GCC/USD capital in DC infrastructure construction across the solar system
   - LDC provides local resources and construction oversight at each location
3. **Revenue Sharing**: 
   - Revenue split varies by location but typically favors LDC (40-50%) with logistics companies sharing remaining revenue
   - All benefit from docking fees, shipyard services, logistics contracts, and spacecraft sales at every DC facility
4. **Commercial Spacecraft Operations**: 
   - All logistics companies build and sell spacecraft at DC shipyards using local resources
   - Players and other corporations purchase craft from any company operating out of the same shared facilities
   - Like airlines at the same airport, companies compete for customers while sharing infrastructure at every DC location
5. **Market Competition Maintained**: 
   - Outside the joint venture, companies compete for individual transport contracts and spacecraft sales
   - Collaboration on infrastructure enables competition in operations and manufacturing across all worlds
6. **Economic Multiplier**: 
   - DC infrastructure at every foothold enables all companies to offer comprehensive services
   - Shared infrastructure reduces costs while maintaining competitive market dynamics throughout the solar system

### Example 2: LDC Bootstrap & Earth-Anchored Growth
**Scenario**: LDC establishes GCC mint and creates bidirectional Earth trade

**Phase 1: Initial Bootstrap**
1. **Earth Grants**: L
   - AstroLift return supply ships carry Helium-3 and meteorite samples to Earth
   - Lunar propellant delivered to LEO depot for Earth-departing craft
6. **USD Revenue**: 
   - Earth buyers pay USD for lunar resources (fusion fuel market, scientific samples)
   - LEO depot pays USD for lunar-derived propellant (LOX, LH2, methane)
7. **Reinvestment** (Non-Profit Mission): LDC uses USD revenue to:
   - Deploy additional GCC mining satellites (expand currency supply)
   - Import Earth equipment on next supply run (bidirectional logistics)
   - Expand lunar infrastructure (more mining, more ISRU, more exports)
   - Fund development projects (not shareholder profi
5. **Lunar Exports**: AstroLift return supply ships carry Helium-3 and meteorite samples to Earth
6. **USD Revenue**: Earth buyers pay USD for lunar resources (fusion fuel market, scientific samples)
7. **Reinvestment**: LDC uses USD revenue to:
   - Deploy additional GCC mining satellites (expand currency supply)
   - Import Earth equipment on next supply run (bidirectional logistics)
   - Pay for expanded operations (more mining, more exports)

**Phase 3: Economic Expansion**
8. **GCC Supply Growth**: Multiple mining satellites generate GCC for space economy
9. **New GCC Enables**:
   - Player contracts (AI offers tasks to players for GCC payment)
   - NPC reserve growth (reduces Virtual Ledger dependency)
   - Market liquidity (more GCC for resource trading)
10. **Balanced Trade**: Imports from Earth (equipment) balanced by exports to Earth (Helium-3, samples)
11. **Debt Capacity**: Earth's stability allows LDC to issue USD-denominated bonds for large capital projects
12. **Self-Sustaining Cycle**: Earth grants → GCC mining → Lunar production → Earth exports → USD revenue → Expanded mining → More GCC

## Decision Logic: Virtual Ledger vs. GCC

### When to Use Virtual Ledger
- NPC-to-NPC transactions (IOU system for internal DC/colony accounting)
- GCC reserves below operational threshold
- Both parties are NPCs/Colonies (have `can_overdraft?` permission)
- Real currency transfer would deplete critical reserves needed for player transactions
- DC expansion support and inter-DC resource sharing
- Maintaining supply lines during GCC scarcity periods

### When to Use Real GCC
- **Player-involved transactions (always require real GCC)**
  - Player contracts and mission rewards
  - Player buy/sell orders at DC trading hubs
  - Player equipment and spacecraft purchases
- NPC has sufficient GCC reserves without depletion risk
- Virtual Ledger debt accumulation reaches reconciliation trigger
- Priority transactions (emergency supplies, critical infrastructure)

### Pricing Consistency
- Virtual Ledger transactions use **current market prices** (same as GCC transactions)
- No price discrimination between GCC and Virtual Ledger trades
- `Market::NPCPriceCalculator` provides unified pricing for both

## Implementation Status

### ✅ Completed
- **Multi-currency accounts** (`Financial::Account`)
  - Per-entity, per-currency account creation
  - Overdraft logic via `can_overdraft?`
  - Optimistic locking for concurrency
- **Currency system** (`Financial::Currency`)
  - GCC and USD seeded as system currencies
  - Extensible for colony-issued currencies
- **Ledger tracking** (`Financial::LedgerEntry`, `Financial::LedgerManager`)
  - NPC-to-NPC transfer logging
  - Asset swap and debt reconciliation framework
- **Bond system** (`Financial::Bond`)
  - Multi-currency debt issuance
  - FX risk tracking
  - Repayment with exchange rate conversion

### ⚠️ Partial
- **Virtual Ledger decision logic**
  - Basic overdraft permission exists
  - Need threshold logic for when to use Virtual Ledger vs. GCC
  - Need priority rules (prefer GCC when available without depletion)
- **Debt reconciliation**
  - `LedgerManager.reconcile_npc_debts` framework exists
  - Asset swap mechanics need implementation
  - USD-to-GCC liquidation needs exchange rate integration

### 💡 Planned
- **AI Manager integration**
  - ResourceAcquisitionService should check GCC reserves before using real currency
  - Virtual Ledger fallback logic for NPC-to-NPC sourcing
  - Debt accumulation monitoring and reconciliation triggers
- **Player visibility**
  - UI showing NPC Virtual Ledger positions (transparency)
  - Market intelligence: which NPCs have debt vs. reserves
  - Contract opportunities based on NPC liquidity

## Exchange Rate & Currency Conversion

### USD-to-GCC Exchange Mechanism ✅ IMPLEMENTED
**Service**: `Financial::ExchangeRateService`
- **Default Peg**: 1:1 (1 USD = 1 GCC, 1 GCC = 1 USD)
- **Implementation**: Rates hash `{ ["FROM", "TO"] => rate }`
- **Fluctuation**: Supports dynamic rates (test shows GCC depreciation to 1 USD = 1.3 GCC)
- **Bond Risk**: Currency depreciation increases debt burden in depreciated currency
- **Item Valuation**: Can value items/blueprints in any currency using exchange rates

**Real-World Parallel**: Bretton Woods system (fixed peg with adjustment capability)

### GCC Reserve Protection ⚠️ PATTERN EXISTS
**From Integration Tests** (`exchange_rate_integration.rb`):
```ruby
# Try to pay up to 50% of launch cost in GCC, but not more than LDC has
max_gcc_portion = launch_cost_usd * 0.50
available_gcc = ldc_gcc_account.balance.to_f
gcc_paid = [max_gcc_portion, available_gcc].min
```

**Decision Logic**:
1. **Percentage-Based Threshold**: Use up to 50% of transaction value in GCC
2. **Preserve Reserves**: Never deplete GCC account completely
3. **Fallback to USD**: Pay remainder in USD (or bond if underfunded)

**Implementation Needed**:
- Formalize threshold rules in `ResourceAcquisitionService`
- Entity-specific reserve ratios (DCs: 30%?, Logistics: 20%?, LDC: 50%?)
- Context-dependent: emergency vs. routine transactions

### Bond Mechanics ✅ IMPLEMENTED
**Model**: `Financial::Bond` with multi-currency support

**Features**:
- Polymorphic issuer/holder (any entity can issue/hold bonds)
- Currency-denominated (track debt in USD, GCC, or any currency)
- Multi-currency repayment with exchange rate conversion
- Status tracking: `:issued`, `:paid`, `:defaulted`

**Repayment Logic**:
```ruby
def total_repaid(exchange_rate_service = nil)
  repayments.sum do |repayment|
    if repayment.currency_id == currency_id
      repayment.amount
    else
      exchange_rate_service.convert(repayment.amount, repayment.currency_id, currency_id)
    end
  end
end
```

**Real-World Parallel**: Corporate bonds with FX hedging risk

### Solvency & Restricted Mode ✅ IMPLEMENTED
**From Economic Stress Tests** (`economic_stress_test.rake`):

**Solvency Metric**: USD balance (critical for wormhole access, Earth imports)
- **Solvent**: USD balance > 0
- **Restricted Mode**: USD balance ≤ 0 (cannot access wormholes, Earth imports blocked)

**Monitored Metrics**:
- USD balance per SSC/DC
- Off-market volume (Virtual Ledger) vs. public market volume
- Wormhole transit capacity (requires USD reserves)

**Real-World Parallel**: Central bank reserve requirements, credit ratings

### Infrastructure Costs ✅ DEFINED
**Wormhole Transit Fee**: $1,000 USD per transit
- Deducted from local SSC USD accounts
- Creates USD drain requiring Earth export revenue or USD bonds
- Drives need for Virtual Ledger when USD scarce

**Real-World Parallel**: Toll roads, Suez/Panama Canal fees

## Open Questions for Implementation

1. **Virtual Ledger Settlement Priority**:
   - When GCC becomes available, settle all debts or partial?
   - Priority ranking: oldest debts first? largest debts? critical partners?
   - Automatic reconciliation triggers vs. manual settlement?

2. **Asset Swap Mechanics**:
   - How are goods valued for debt settlement? (current market price via NPCPriceCalculator?)
   - Which resources acceptable for swap? (surplus only? strategic reserves excluded?)
   - Who initiates swaps: AI Manager automatic? NPC negotiation? Player visibility?

3. **Player Interaction with Virtual Ledger**:
   - Can players see NPC Virtual Ledger positions? (market intelligence)
   - Can players trade with NPCs on Virtual Ledger terms? (NO - players use GCC only)
   - Does Virtual Ledger debt affect NPC contract availability/pricing?

4. **GCC Reserve Formalization**:
   - Entity-specific thresholds (DC: 30%? Logistics: 20%? Player: 0%?)
   - Emergency override rules (critical supplies ignore thresholds?)
   - Dynamic thresholds based on economic conditions?

5. **Debt Accumulation Limits**:
   - Maximum Virtual Ledger debt per entity (multiple of annual revenue?)
   - Consequences of excessive debt (credit freeze? forced asset liquidation?)
   - Recovery mechanisms for insolvent NPCs (bailout? bankruptcy? restructuring?)

6. **Exchange Rate Dynamics**:
   - Who sets USD-GCC rates? (central authority? market forces?)
   - Update frequency (real-time? daily? event-driven?)
   - Factors driving fluctuation (GCC supply? USD demand? wormhole activity?)

## Related Documentation
- [Player Contract System](PLAYER_CONTRACT_SYSTEM.md) - Player-first task priority, GCC pricing
- [AI Manager Implementation Status](../ai_manager/IMPLEMENTATION_STATUS.md) - ResourceAcquisitionService integration
- [Wormhole Expansion Plan](../../wh-expansion.md) - Phase 2: ResourceAcquisitionService economics

## Code References
- `app/models/financial/account.rb` - Multi-currency accounts, overdraft logic
- `app/models/financial/currency.rb` - Currency definitions (GCC, USD)
- `app/models/financial/bond.rb` - USD-denominated debt with FX risk
- `app/models/financial/ledger_entry.rb` - Virtual Ledger transaction tracking
- `app/models/financial/ledger_manager.rb` - Debt reconciliation framework
- `app/services/financial/exchange_rate_service.rb` - USD/GCC conversion, 1:1 peg
- `app/services/ai_manager/resource_acquisition_service.rb` - Economic sourcing logic
- `app/models/market/marketplace.rb` - NPC pricing and trade execution
- `integration-tests/exchange_rate_integration_2.rb` - Bond repayment under GCC depreciation
- `integration-tests/gcc_mining_sat.rb` - LDC crypto mining satellite deployment and revenue
- `lib/tasks/economic_stress_test.rake` - Solvency monitoring, wormhole fees, Virtual Ledger tracking
