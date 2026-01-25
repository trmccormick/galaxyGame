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

## 🚀 9. Sci-Fi Easter Eggs (Love Letter to the Genre)

**Context:** Game World Flavor & Immersion  
**Mandate:** Transform the game into a "love letter" to sci-fi by including subtle nods to shows, books, and movies that inspired the project. These must remain non-infringing and feel natural to casual players while providing "eureka" moments for fans.

### 🧪 Core Philosophy
- **Subtle Nods:** References should be easter eggs, not core mechanics. Casual players see them as flavor; fans recognize them as homages.
- **No Copyright Infringement:** Use generic names, indirect references, or public-domain elements. Avoid direct quotes, logos, or protected trademarks.
- **Immersion First:** Easter eggs enhance the universe without breaking gameplay or requiring knowledge to enjoy.

### 🛰️ Integration Points
- **Celestial Body Names & Descriptions:** Unnamed moons or asteroid clusters can bear names of famous fictional star systems (e.g., "Arrakis Cluster" for a desert world, "Terminus Belt" for a trade hub, or "The Belt" for asteroid fields). Descriptions include subtle flavor text.
- **Mission Manifests:** `manifest_v1.1.json` files include "Legacy Cargo" or "Historic Logs" referencing famous ships/captains (e.g., "Cargo from the Nostromo" or "Logs from the Serenity's maiden voyage").
- **AI Manager Quips:** Occasional dialogue or "Error Codes" reference famous sentient computers (e.g., "HAL 9000 protocol engaged" for navigation errors, "GlaDOS testing sequence" for experimental phases, or "Holly override" for AI decisions).
- **Item Metadata:** Standard items like `slag_propellant` have flavor text referencing sci-fi fuel types (e.g., "Propellant reminiscent of the fuel used in the Rocinante's Epstein drives").

### 🌌 Alpha Centauri Connection
- **Wormhole Hub:** Use Alpha Centauri as the primary hub for Easter Eggs. "Natural wormholes" can open to systems in the Milky Way, acting as "guest appearances" for iconic sci-fi locations.
- **Proxima Centauri References:** Generated JSON files for Proxima systems include nods to *The Three-Body Problem* (e.g., "Trisolarian signals detected") or *Avatar* (e.g., "Pandora-like bioluminescent flora").
- **Milky Way Access:** Wormholes enable "visits" to sci-fi-inspired systems without developing FTL travel.

### 🛠️ Technical Implementation
- **GUARDRAILS.md Rules:** Naming conventions ensure easter eggs stay within "nod" category—e.g., no direct character names, focus on locations/ships/concepts.
- **JSON Schema:** Every generated system JSON includes `flavor_text` or `easter_egg_id` fields for references, kept separate from core game logic.
- **System-Level Easter Eggs:** For special systems (e.g., wormhole hubs), use `AIManager::WorldKnowledgeService#generate_system_easter_egg(has_wormhole: true)` to apply sci-fi references like the "Celestial Anomaly" from Star Trek DS9.
- **Location-Based Triggers:** `location` is now an optional parameter in `find_matching_easter_egg`. `ancient_world` is a reserved location tag triggered by worlds with a `geological_age > 10.0` or the `pre_collapse_ruins` trait. System-level tags (e.g., `deep_space`) are validated against `system.sector_type`.
- **Documentation Sync:** Any new easter egg must be documented in `docs/` with its source inspiration and guardrail compliance.
- **Testing:** Easter eggs must not affect gameplay balance or cause immersion breaks. Specs include checks for flavor text presence without requiring sci-fi knowledge.

### 📋 Examples & Compliance
- **Compliant:** "A barren world echoing the harsh deserts of ancient tales" (nods to Dune without naming).
- **Non-Compliant:** "Welcome to Arrakis, home of the Fremen" (direct reference, potential infringement).
- **Implementation Check:** Before adding, verify against public-domain status or generic nature.

### 🏷️ Easter Egg Categories & Sub-Categories
- **World Naming:** System/planet name references (e.g., Celestial Anomaly)
- **Found Footage:** Discovery logs and signals (e.g., Monolith, Ghost Ship)
- **AI Personality:** Sentient computer behaviors (e.g., HAL protocol)
- **Vessel Logs:** Ship sightings and encounters (e.g., Serenity-class)
- **Improbable Events:** Reality-bending anomalies (e.g., Infinite Improbability Drive)
- **Industrial Horror:** Corporate exploitation themes (e.g., Nostromo incident)
- **Military/Refugee Fleet:** Fleet sightings and refugee encounters (e.g., Lost Fleet)
- **Smuggler/Outlaw:** Rogue vessel and outlaw activities (e.g., Kessel Run)
- **Xeno-Biological Anomaly:** Alien life and biological threats (e.g., Protomolecule)

This strategy ensures the game honors sci-fi's legacy while maintaining focus on realistic space colonization.

## 🐳 10. Environment & Container Management Guardrails

**Context:** Development Environment Integrity  
**Mandate:** Protect running applications and collaborative work sessions from unintended disruptions.

### 🚫 Container Restart Prohibition
- **No Autonomous Restarts:** Do NOT restart, rebuild, or stop Docker containers without explicit user permission, unless operating in autonomous "Grinder" mode for overnight batch processing.
- **Interactive Mode Default:** In interactive sessions (Quick-Fix Protocol, manual code review), assume containers are running correctly and other agents may be active.
- **Verification First:** Before suggesting any container operations, ask "Are the containers currently running?" or check status with `docker-compose ps`.
- **Exception - Grinder Mode:** Autonomous Nightly Grinder may perform container operations as part of its scripted workflow, but must log all actions and provide rollback instructions.

### 🔍 Environment State Preservation
- **Running Application Assumption:** Assume the Rails application is running unless explicitly told otherwise. Do not assume container state from tool outputs alone.
- **Collaborative Awareness:** Multiple agents may be working simultaneously. Container operations affect all agents - coordinate or ask first.
- **Minimal Intervention:** Prefer code-only fixes that don't require service restarts. Rails development mode reloads most changes automatically.

### ✅ Permitted Container Operations
- **Status Checks:** `docker-compose ps`, `docker ps` - safe informational commands
- **Log Inspection:** `docker-compose logs` - safe for debugging
- **Database Queries:** Container-based Rails commands for data inspection
- **Test Execution:** Running RSpec inside containers (with proper environment isolation)
- **Grinder Mode:** Full container lifecycle management during autonomous batch processing

### � Configuration Change Prohibition
- **No Autonomous Config Changes:** Do NOT suggest or make changes to Docker Compose files, .gitignore, environment files, or other infrastructure configurations without explicit user permission.
- **Interactive Mode Restriction:** In interactive sessions, assume all configurations are correct and do not propose modifications unless directly requested.
- **Documentation First:** Any proposed config changes must be documented and approved before implementation.
- **Exception - Grinder Mode:** Autonomous mode may propose config changes as part of scripted workflows, but must provide clear rollback instructions and require approval.

### 🚨 Incident Response [2026-01-23]
- **Root Cause:** Unintended configuration changes during file review session
- **Impact:** Disrupted user workflow and required manual reversion
- **Prevention:** Added explicit prohibition on config changes without permission
- **Recovery:** Always confirm user intent before suggesting file modifications

### 🗄️ 11. Database Environment Protection Guardrails

**Context:** Database Integrity and Test Isolation  
**Mandate:** Prevent accidental corruption of development database through improper test execution.

#### 🚫 Test Environment Violation Prohibition
- **RAILS_ENV=test Mandate:** ALL RSpec test executions MUST use `RAILS_ENV=test` to prevent development database corruption.
- **DATABASE_URL Unset Requirement:** ALL test commands MUST prefix with `unset DATABASE_URL` to avoid environment bleed.
- **Safety Check First:** Before any test run, verify database context:
  ```bash
  docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts ActiveRecord::Base.connection.current_database"'
  # Expected: galaxy_game_test
  # ❌ STOP if shows galaxy_game_development
  ```

#### 🚨 Development Database Corruption Response
- **Immediate Stop:** If tests run against development database, STOP all operations immediately.
- **Corruption Assessment:** Check for data anomalies or missing records in development database.
- **Recovery Protocol:** Reseed development database if corruption detected:
  ```bash
  # Kill any running processes
  docker exec -it web pkill -f rails
  
  # Drop and recreate development database
  docker-compose -f docker-compose.dev.yml exec web rails db:drop db:create db:migrate db:seed
  
  # Verify data integrity
  docker-compose -f docker-compose.dev.yml exec web rails runner "puts 'Celestial bodies: #{CelestialBodies::CelestialBody.count}'"
  ```
- **Prevention Logging:** Document incident in commit message and update guardrails.

#### ✅ Correct Test Execution Pattern
```bash
# ❌ WRONG - Corrupts development database
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec

# ✅ CORRECT - Safe test execution
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'
```

#### 📊 Incident Precedent [2026-01-24]
- **Root Cause:** RSpec executed without RAILS_ENV=test, potentially corrupting development database
- **Impact:** Development database may contain test artifacts or corrupted data
- **Prevention:** Added explicit database environment protection guardrails
- **Recovery:** Development database reseeding required to restore clean state

---

*Last Updated: January 24, 2026*  
*Status: Active - Database environment protection protocols enforced*