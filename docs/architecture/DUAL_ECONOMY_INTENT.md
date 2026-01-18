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
- **Purpose**: Internal NPC-to-NPC accounting when GCC is scarce
- **Implementation**: Negative account balances (`Financial::Account.can_overdraft?`)
- **Key Behavior**:
  - Tracks obligations without transferring real currency
  - Uses current market prices for transactions
  - NPCs/Colonies can go negative (overdraft enabled)
  - Players **cannot** use Virtual Ledger (no overdraft)
- **Usage**: 
  - NPC-to-NPC resource trades when GCC reserves low
  - Service exchanges between Development Corporations
  - Deferred payment tracking

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
  - Trade resources via **Virtual Ledger** when GCC reserves are low
  - Use real GCC when available without depleting reserves
  - Focus on infrastructure development, not profit maximization
  - Revenue from operations funds expansion (not shareholder profits)
- **Unique Capabilities**: 
  - Can earn USD through Earth support contracts and exports
  - Can issue USD bonds for major capital projects (Earth-backed credit)
  - LDC specifically operates GCC mining satellites (the mint)

### Logistics Corps (e.g., AstroLift)
- **Mission**: Bridge Earth ↔ Space operations with bidirectional supply chains
- **Currency Acceptance**:
  - **USD**: Earth-side operations (terrestrial logistics, Earth contracts)
  - **GCC**: Space-side operations (orbital logistics, interplanetary transport)
- **Special Role**: 
  - Enable Earth imports when space-based production insufficient (equipment, specialized goods)
  - Enable lunar exports when production creates surplus (Helium-3, meteorites, samples)
  - Bidirectional supply ships maximize efficiency (outbound cargo TO space, return cargo FROM space)

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
  - Import specialized equipment unavailable in space
  - Pay wormhole transit fees
  - Fund satellite launches for GCC mining expansion
  - Reinvest in lunar infrastructure (non-profit development mission)
- **GCC Generation**: Operates crypto mining satellites that produce new GCC, providing controlled currency supply growth
- **Trade Balance**: Imports from Earth (equipment, specialized goods) balanced by exports to Earth AND Earth orbit (Helium-3, meteorites, samples, LEO depot propellant)

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
- NPC-to-NPC transactions
- GCC reserves below operational threshold
- Both parties are NPCs/Colonies (have `can_overdraft?` permission)
- Real currency transfer would deplete critical reserves

### When to Use Real GCC
- Player-involved transactions (always require real GCC)
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
