# 🛡️ AI Manager: "First and Done" Guardrails
**Context:** Internal Game Logic (AIManager Module)
**Mandate:** These rules govern the autonomous behavior of the AI Manager during expansion and settlement.

---

## 🏗️ 1. Code & Documentation Sync
- **The Mandate:** No logic change to `manager.rb` or `autonomous_construction_manager.rb` is complete until the corresponding Markdown documentation is updated.
- **Pattern Integrity:** If a new mission pattern is added (e.g., via `ai:manager:teach:pattern`), the `learned_patterns.json` and `docs/` must reflect the new success criteria and ROI estimates.

## 🌉 2. The Anchor Law (Stability & Infrastructure)
- **Mass Requirement:** A wormhole link cannot be declared "stable" or "open for heavy traffic" unless the "Sweet Spot" contains a gravitational anchor of at least **10^16 kg** (minimum threshold for stable gravitational field generation).
- **The Phobos/Luna Pattern:** 
  - **No Moons:** Relocate a Phobos-sized asteroid (mass ≈ 1.0×10^16 kg) to act as a station/depot anchor.
  - **Large Moon:** Establish the "Luna Pattern" first—settle the moon, build materials, then establish the L1/Depot gateway.
  - **Reference Implementation:** See [AOL-732356 System Documentation](systems/aol-732356.md) for successful Phobos Pattern deployment using Asteroid XXXV ($2.44 \times 10^{19}$ kg) anchored to Gas Giant 18 ($5.72 \times 10^{27}$ kg).
- **Harvest First:** The AI Manager must prioritize local resource harvesting (ISRU) to build station components rather than importing them, unless the surface is strictly inaccessible.

## 💰 3. Market & GCC Integrity
- **Taxation:** All maintenance jobs (e.g., `WormholeMaintenanceJob`) must deduct the `maintenance_tax_em` from the correct economy (Global vs. Local) as defined in `wormhole_contract.json`.
- **ROI Validation:** The AI Manager should not initiate a phase if the `expected_roi` (calculated in `scout_logic.rb`) falls below the threshold defined in the current `ai_manager_tuning`.

## 🎯 4. Player-First Task Priority
- **Contract Assignment:** All harvesting, logistics, and construction contracts MUST be offered to players first with 24-48 hour timeout window before moving to NPC queue.
- **NPC Fallback Mandate:** Game progression MUST NOT stall waiting for player acceptance. If player declines or timeout expires, task moves to NPC autonomous execution.
- **GCC Economy:** Players earn Galactic Crypto Currency (GCC) for completed missions. NPCs use Virtual Ledger for internal accounting (no GCC).
- **Autonomous Progression:** AI Manager ensures all mission objectives complete whether players participate or not.
- **Player Influence:** GCC spending allows players to outbid NPCs, access premium contracts, and influence development priorities.

## 🤖 5. Operational Boundaries
- **Autonomous Overrides:** The AI Manager may ignore Alpha Centauri in favor of local Milky Way wormholes if the `SimEvaluator` predicts a higher ROI or faster stability rating.
- **Verification:** All autonomous construction phases must be logged via the `PerformanceTracker` to ensure they meet the 85% success rate requirement.

## 🧱 6. Architectural Integrity
- **Namespace Preservation:** Models must reside in directories matching their Ruby namespace (e.g., `Location::SpatialLocation` belongs in `app/models/location/`).
- **Nesting Mandate:** Do not flatten directory structures during recovery. If a class is namespaced in `ApplicationRecord`, the spec must reflect that namespace (e.g., use `Location::SpatialLocation.new`, not `SpatialLocation.new`).
- **Autoloader Compliance:** Any "uninitialized constant" error must first be triaged as a potential path/namespace mismatch before attempting to recreate the class.
- **Incident Precedent [2026-01-15]:** Resolved 10 RSpec failures caused by the flattening of the `Location` namespace in `wormhole_spec.rb`. This incident validated the importance of namespace preservation for maintaining system stability—just as the [Anchor Law](GUARDRAILS.md#-2-the-anchor-law-stability--infrastructure) requires physical mass thresholds for wormhole stability, architectural integrity requires namespace structures for code stability.
- **Gold Standard Reference:** `wormhole_spec.rb` serves as the canonical example of proper namespace testing. All future model specs must use fully qualified class names (e.g., `Location::SpatialLocation`) in both instantiation and association expectations.
- **Sabatier Bug Fix [2026-01-15]:** Resolved critical implementation gap in `WormholeMaintenanceJob` where `sabatier_offset_active` contract flags were configured but not executed. Added 40% tax reduction logic for local fuel production offsets. Ensures future job updates properly parse and apply all contract configuration flags to prevent silent feature failures.

## 💵 7. Economic System Guardrails

### Contract Ceiling Limits
- **Maximum Contract Value**: No single player contract may exceed 10% of current GCC money supply to prevent economic distortion
- **Daily Contract Limits**: Players limited to 5 active contracts per day to ensure market distribution
- **Contract Duration Caps**: Maximum 90 Earth days for any contract to prevent long-term economic commitments

### Debt and Overdraft Controls
- **Virtual Ledger Limits**: NPC entities cannot exceed 50% of their asset value in overdraft to prevent economic collapse
- **Player Debt Ceilings**: Players cannot accumulate debt exceeding 200% of their net worth
- **Interest Rate Floors**: Minimum 2% annual interest on all overdrafts to discourage excessive borrowing

### Reserve Requirements
- **LDC Stabilization Reserves**: Lunar Development Corporation must maintain 25% of total GCC supply as stabilization reserves
- **System-wide Liquidity**: Minimum 10% of all currencies held in liquid reserves for market stability
- **Emergency Funds**: 5% of annual GDP allocated to economic crisis response funds

### Currency Stability Measures
- **Exchange Rate Bands**: GCC/USD exchange rates limited to ±5% daily movement to prevent speculation
- **Minting Limits**: LDC limited to 5% annual GCC supply increase to control inflation
- **Burn Mechanisms**: Automatic GCC destruction for Earth exports to maintain supply equilibrium

### Market Intervention Rules
- **LDC Market Operations**: Lunar Development Corporation may intervene in currency markets only when exchange rate exceeds ±10% band
- **Price Stabilization**: Automatic purchase/sale of commodities when prices deviate >20% from 30-day average
- **Anti-Manipulation**: Any entity attempting to manipulate markets faces permanent ban and asset forfeiture

## 🎮 8. Player Experience Boundaries

### Economic Transparency
- **Contract Clarity**: All contracts must display clear GCC earnings, risk levels, and completion timeframes
- **Market Information**: Real-time access to commodity prices, exchange rates, and economic indicators
- **Performance Tracking**: Historical contract completion rates and earnings visibility

### Fair Competition
- **NPC Efficiency Caps**: NPC operations limited to 90% efficiency to maintain player competitive advantage
- **Contract Priority**: Players receive 48-hour exclusive window on all eligible contracts
- **Premium Access**: GCC spending enables priority contract access and faster NPC fallback

### Game Balance
- **Progression Gates**: Major expansions require player participation thresholds
- **Economic Multipliers**: Player contracts provide 1.5x GCC rewards vs NPC execution
- **Influence Mechanisms**: GCC investment allows players to influence AI Manager priorities