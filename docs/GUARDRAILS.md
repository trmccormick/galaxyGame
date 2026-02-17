## 🚀 Material Loss Logic for Interplanetary Transit [2026-02-03]
- All resource exports between planetary bodies (e.g., Ceres to Mars) must account for material loss due to transit risk and distance.
- Default loss rate is 5-10% for high-risk, long-distance routes (e.g., 2.8 AU Ceres-Mars).
- Loss variable must be applied to ROI calculations in service logic and validated by spec.
- Cite: ai_resource_allocation_engine.md, venus_tug_transition_strategy.md, and current game constraints.
# 🛡️ AI Manager: "First and Done" Guardrails
**Context:** Internal Game Logic (AIManager Module)
**Mandate:** These rules govern the autonomous behavior of the AI Manager during expansion and settlement.

---

## 🏗️ 1. Code & Documentation Sync
- **The Mandate:** No logic change to `manager.rb` or `autonomous_construction_manager.rb` is complete until the corresponding Markdown documentation is updated.
- **Pattern Integrity:** If a new mission pattern is added (e.g., via `ai:manager:teach:pattern`), the `learned_patterns.json` and `docs/` must reflect the new success criteria and ROI estimates.

## 🌉 2. The Anchor Law (Stability & Infrastructure)
- **Mass Requirement:** A wormhole link cannot be declared "stable" or "open for heavy traffic" unless the "Sweet Spot" contains a gravitational anchor of at least **10^16 kg** (minimum threshold for stable gravitational field generation).
- **Counterbalance Physics:** Wormhole stability requires gravitational anchors at 180° opposite the exit point. Jupiter provides Sol's natural counterbalance; artificial systems need AWS stations or asteroid placement.
- **Atmospheric Maintenance Mandate:** Terraformed worlds require ongoing technological support. AI Manager must maintain >95% system integrity or face reversion cascades. No "set and forget" terraforming.
- **The Phobos/Luna Pattern:** 
  - **No Moons:** Relocate a Phobos-sized asteroid (mass ≈ 1.0×10^16 kg) to act as a station/depot anchor.
  - **Large Moon:** Establish the "Luna Pattern" first—settle the moon, build materials, then establish the L1/Depot gateway.
  - **Reference Implementation:** See [AOL-732356 System Documentation](systems/aol-732356.md) for successful Phobos Pattern deployment using Asteroid XXXV ($2.44 \times 10^{19}$ kg) anchored to Gas Giant 18 ($5.72 \times 10^{27}$ kg).
- **Harvest First:** The AI Manager must prioritize local resource harvesting (ISRU) to build station components rather than importing them, unless the surface is strictly inaccessible.

## 💰 3. Market & GCC Integrity
**Core Design Philosophy:** Player-first with NPC fallback ensures the solar system colonization continues regardless of player activity levels, while giving players meaningful opportunities to lead, profit, and shape development.

**AI Manager Implementation:** JSON mission files and strategies must be refined to enable AI Manager pattern matching and correction, allowing dynamic adaptation to maintain expansion momentum when players don't participate.

### Contract Ceiling Limits
- **Contract Assignment:** All harvesting, logistics, and construction contracts MUST be offered to players first with 24-48 hour timeout window before moving to NPC queue.
- **NPC Fallback Mandate:** Game progression MUST NOT stall waiting for player acceptance. If player declines or timeout expires, task moves to NPC autonomous execution.
- **Expired Order Handling:** When player contracts expire unfilled, DCs activate automated harvesting workforce or arrange imports to maintain supply lines.
- **GCC Economy:** Players earn Galactic Crypto Currency (GCC) for completed missions. NPCs use Virtual Ledger for internal accounting (no GCC).
- **Autonomous Progression:** AI Manager ensures all mission objectives complete whether players participate or not.
- **Player Influence:** GCC spending allows players to outbid NPCs, access premium contracts, and influence development priorities.

## 🤖 5. Operational Boundaries
- **Autonomous Overrides:** The AI Manager may ignore Alpha Centauri in favor of local Milky Way wormholes if the `SimEvaluator` predicts a higher ROI or faster stability rating.
- **Verification:** All autonomous construction phases must be logged via the `PerformanceTracker` to ensure they meet the 85% success rate requirement.

- **Namespace Preservation:** Models must reside in directories matching their Ruby namespace (e.g., `Location::SpatialLocation` belongs in `app/models/location/`).
- **Nesting Mandate:** Do not flatten directory structures during recovery. If a class is namespaced in `ApplicationRecord`, the spec must reflect that namespace (e.g., use `Location::SpatialLocation.new`, not `SpatialLocation.new`).

- **Service Namespace Integrity:**
  - All service classes (AIManager, Ceres, Mars, etc.) must use nested module definitions:
    ```ruby
    module AIManager
      module Testing
        class PerformanceMonitor
          # ...
        end
      end
    end
    ```
  - Do **not** use `module AIManager::Testing` for service classes. Zeitwerk may not resolve the parent module if not already loaded, causing `NameError`.
  - Ensure there is no file named `app/services/ai_manager/testing.rb` that conflicts with the `app/services/ai_manager/testing/` directory. If a namespace file is needed, it should only define the module and not contain logic or requires.
  - All specs for namespaced services must require `rails_helper` and never use `require_relative` for app/services code.
-  - After any namespace or structure change, run `bin/rails zeitwerk:check` and the relevant RSpec suite.

- **Manager/Service Placement Rule [2026-01-15]:**
  - All 'Manager' and 'Service' classes must reside in `app/services/` and never in `app/models/` unless they are backed by a database table (i.e., inherit from `ApplicationRecord`).
  - This ensures Zeitwerk autoloading and logical separation of concerns.
  - [cite: 2026-01-15]
- **Autoloader Compliance:** Any "uninitialized constant" error must first be triaged as a potential path/namespace mismatch before attempting to recreate the class.
- **Incident Precedent [2026-01-15]:** Resolved 10 RSpec failures caused by the flattening of the `Location` namespace in `wormhole_spec.rb`. This incident validated the importance of namespace preservation for maintaining system stability—just as the [Anchor Law](GUARDRAILS.md#-2-the-anchor-law-stability--infrastructure) requires physical mass thresholds for wormhole stability, architectural integrity requires namespace structures for code stability.
- **Gold Standard Reference:** `wormhole_spec.rb` serves as the canonical example of proper namespace testing. All future model specs must use fully qualified class names (e.g., `Location::SpatialLocation`) in both instantiation and association expectations.
- **Sabatier Bug Fix [2026-01-15]:** Resolved critical implementation gap in `WormholeMaintenanceJob` where `sabatier_offset_active` contract flags were configured but not executed. Added 40% tax reduction logic for local fuel production offsets. Ensures future job updates properly parse and apply all contract configuration flags to prevent silent feature failures.

## �️ 7. Path Configuration Standards
- **Centralized Path Management:** All data file paths must be defined in `galaxy_game/config/initializers/game_data_paths.rb` using `GalaxyGame::Paths` constants.
- **No Hardcoded Paths:** Never use `Rails.root.join('app/data/...')` directly in application code. Always use `GalaxyGame::Paths::CONSTANT`.
- **Docker Volume Awareness:** Data files must be stored in root `data/` directory (gitignored) for proper Docker volume mounting, not in `galaxy_game/data/` (git-tracked).
- **Script Portability:** Shell scripts must use `PROJECT_ROOT` variable to work from any directory.
- **Directory Name Consistency:** Path constants must match actual directory names (e.g., `ai_manager` not `ai-manager`).
- **Path Resolution:** `GalaxyGame::Paths::JSON_DATA` resolves to `/home/galaxy_game/app/data` in container (mounted from host `./data/`).

## 🏔️ 7.5. Terrain Generation & Rendering Architecture

### Core Principle: Data Source Hierarchy

**NASA GeoTIFF = Ground Truth** for Sol bodies with real data.
**FreeCiv/Civ4 = Training Data** for AI Manager pattern learning, NOT direct terrain sources.
**AI Manager = Generator** for bodies without NASA data, using learned patterns + physical conditions.

### Separation of Concerns
- **Generation Layer:** Produces pure elevation data only (height maps). No biome classification.
- **Rendering Layer:** Applies visualization based on elevation and body properties.
- **Data Storage:** `geosphere.terrain_map` contains `elevation` (2D numeric grid) and metadata.

### Sol System Terrain Sources

| Body | NASA Data | Grid Size | Status |
|------|-----------|-----------|--------|
| Earth | `earth_1800x900.asc.gz` | 180×90 | ✅ Available |
| Mars | `mars_1800x900.asc.gz` | 96×48 | ✅ Available |
| Luna | `luna_1800x900.asc.gz` | 50×25 | ✅ Available |
| Mercury | `mercury_1800x900.asc.gz` | 70×35 | ✅ Available |
| Titan | None | 74×37 | ❌ AI Manager generates |
| Venus | None | 172×86 | ❌ AI Manager generates |

### Grid Sizing & FreeCiv Tileset Compatibility

**Key Distinction:**
- **Grid Size** (e.g., 180×90) = number of tiles in the map
- **Tile Pixel Size** (e.g., 30×30, 64×64) = rendering size of each tile sprite
- FreeCiv tilesets work with ANY grid size - they tile sprites across the grid

**Grid Formula:** Diameter-based, maintains 2:1 aspect ratio for cylindrical wrap:
```ruby
scale_factor = body_diameter / 12742.0  # Earth as reference
width = (180 * scale_factor).round.clamp(40, 720)
height = (width / 2).round.clamp(20, 360)  # Enforce 2:1 aspect ratio
```

**Available Tilesets:**
| Tileset | Tile Size | Notes |
|---------|-----------|-------|
| Trident (original) | 30×30 | Classic FreeCiv |
| Trident (modified) | 64×64 | Current default |
| BigTrident | 60×60 | Double-size |
| Engels | 45×45 | Community |

### FreeCiv/Civ4 as Training Data (NOT Direct Sources)

**What FreeCiv/Civ4 Maps Provide:**
- Geographic feature names and relative positions (Olympus Mons, Hellas Basin, etc.)
- Biome placement patterns for AI Manager learning
- Terraforming target visualization (what COULD exist after terraforming)
- Settlement viability hints and resource distribution patterns
- Geological feature checklist for data completeness validation

**What FreeCiv/Civ4 Maps Do NOT Provide:**
- Accurate elevation data (PlotType 0-3 is NOT real topography)
- Current planetary state (both show post-terraforming scenarios)
- Correct grid dimensions (sizes don't match our diameter-based grids)

**IMPORTANT:** Converting FreeCiv terrain types to elevation produces unrealistic results
(uniform 279-322m range instead of -8km to +21km for Mars). Always use NASA GeoTIFF.

### Terrain Data Integrity
- **Grid Content:** Never store biome letters/symbols in `terrain_map['grid']`. Use normalized elevation values (0.0-1.0).
- **Elevation Variation:** Must show realistic height variation (Mars: -8km to +21km, Earth: -10km to +8km).
- **NASA Source Files:** Located at `data/geotiff/processed/*.asc.gz`

### Hydrosphere Layer
- **Label:** "Hydrosphere" not "Water" (supports non-H2O liquids)
- **Color by Composition:** H2O=blue, CH4/C2H6=orange, NH3=purple
- **Bathtub Logic:** Fill from lowest elevation based on coverage percentage
- **Source:** `hydrosphere.liquid_name` attribute determines display

### Body-Specific Rendering
- **Luna:** Grey gradient (regolith)
- **Mars:** Rust-red gradient (iron oxide)
- **Mercury:** Dark grey gradient (basalt)
- **Titan:** Orange-brown gradient (tholin deposits)
- **Earth:** Brown-green gradient (varied biomes)

### Architecture Correction [2026-02-05]
- **Root Cause:** Monitor was loading FreeCiv/Civ4 data directly and converting terrain types to elevation
- **Impact:** Unrealistic elevation range (279-322m instead of real topography)
- **Fix Required:** Load NASA GeoTIFF data directly, use FreeCiv/Civ4 only for AI Manager training
- **Hydrosphere Fix:** `primary_liquid` method must check `liquid_name` attribute first

## 💵 8. Economic System Guardrails

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

### Market Dynamics and Resource Flow
- **Buy/Sell Order System**: All bases and stations maintain active buy and sell orders for essential materials, creating natural resource flow incentives
- **Player Logistics Role**: Players and logistics NPCs bridge resource gaps by transporting materials from production sites to consumption sites as the game expands
- **Multi-Modal Transport**: Cycler routes provide slow but reliable bulk transport, while players enable faster, more flexible logistics
- **Construction Buy Orders**: Orbital stations and depots create buy orders for construction materials (e.g., L1 station buying 1000 3D printed ibeams), allowing players to participate in infrastructure development
- **Player Supply Chain**: Players can build or purchase materials from locations like Luna and sell them at demand centers like L1 Station for profit
- **NPC Fallback System**: If players don't fill orders within timeout windows, NPCs like AstroLift automatically fill them to maintain game progression
- **Baseline Price Setting**: NPC order fulfillment establishes market prices and ensures economic activity continues even without player participation
- **Early Game Critical**: NPC fallbacks are especially important early in the game when player logistics infrastructure is limited
- **Economic Continuity**: System ensures construction and expansion never stall due to lack of material supply, whether through player participation or NPC automation
- **Adaptive Cycler Logistics**: AI Manager loads cyclers with materials for specific destinations, but if no buy orders exist at arrival, cyclers can unload and place sell orders locally, then continue to next destination to prevent wasted trips and create market opportunities
- **Pre-Destination Market Analysis**: AI Manager evaluates demand at upcoming cycler stops before arrival, deciding whether to deliver cargo, sell locally, or continue with current load
- **Ownership-Based Decision Making**: Cargo handling depends on ownership - AstroLift-owned materials can be sold opportunistically, while TDC cargo is delivered as contracted regardless of local market conditions
- **Mobile Production Platforms**: Cyclers function as moving space stations that can be configured for onboard production during transit, turning raw materials into processed goods to maximize value from long transit times
- **Docked Craft Processing**: Craft docked with cyclers can continue onboard processing if they have sufficient power, raw materials, and storage capacity, allowing Venus skimmers to crack CO2 into O2 and CO during transit
- **Cycler Gas Storage & Utilization**: Cyclers maintain their own gas storage capacity and have operational uses for various gases (propulsion, life support), enabling them to store and utilize processed gases from docked craft production
- **Ownership-Based Value Capture**: Processing value during transit belongs to the owning company - if AstroLift owns both cycler and docked craft, they capture all processing value; mixed ownership requires inter-company agreements for revenue sharing and material ownership
- **Station-Style Processing Services**: Docked craft extend cycler/base infrastructure with their processing systems, following station economics - owners can charge fees for others to use processing capabilities, allowing monetization of idle craft systems for GCC earnings
- **Player Infrastructure Contributions**: Players can add structures/units to NPC bases (if connections available) to expand storage or processing capabilities, earning GCC usage fees while paying rent to base owners for space utilization
- **DC Infrastructure Foundation**: Development Corporations provide basic infrastructure and expand as needed if players do not contribute, following the player-first model with NPCs as backup to ensure continuous expansion

### NPC Debt Decision Influence
- **Virtual Ledger Trading:** NPCs can trade among themselves without GCC limitations using the virtual ledger, allowing inter-NPC debt accumulation
- **Expansion Restrictions:** High debt levels (>30% of assets) prevent NPC base construction and new settlement establishment
- **Procurement Conservatism:** NPCs with corporate debt exceeding 30% of total assets become conservative buyers, refusing purchases from players to preserve capital
- **AI Manager Integration:** Debt levels are continuously monitored and influence OperationalManager decision-making for resource allocation and expansion planning
- **Expected Behavior:** Inter-NPC debt is normal and expected for efficient resource distribution, but excessive debt triggers conservative decision-making

### Development Corporation Structure
- **Non-Profit Status:** Development Corporations (DCs) are non-profit entities formed for each world to establish base-level infrastructure
- **Profit Reinvestment:** DCs generate profits but reinvest them entirely rather than distributing dividends, focusing on expansion rather than profit extraction
- **Inter-DC Interest Exemption:** DCs do not charge interest to other DCs for loans or services, prioritizing collective expansion over individual profit
- **For-Profit NPC Corporations:** AstroLift and other NPC corporations are for-profit entities essential for logistics and specialized services
- **Infrastructure Focus:** DCs prioritize base infrastructure establishment while for-profit NPCs handle commercial logistics and transportation

## 🤖 9. Sol as AI Training Data

**Core Design Philosophy:** The Sol system serves as the primary training dataset for AI Manager autonomous decision-making in new system development. All patterns, economic dynamics, and infrastructure decisions learned from Sol must be applied to maintain consistent expansion quality and player-first economics.

### Training Data Structure
- **Mission Profiles:** JSON mission files (`l1_tug_construction_profile_v1.json`, cycler logistics manifests) provide pattern recognition templates for procurement, sequencing, and quality assurance workflows.
- **Economic Patterns:** Player-first with NPC fallback dynamics, market-based pricing, and infrastructure rental systems establish baseline ROI expectations and participation incentives.
- **Infrastructure Templates:** Orbital shipyards, cycler platforms, and development corporation foundations serve as architectural blueprints for new system deployment.

### AI Manager Learning Objectives
- **Pattern Matching:** Analyze Sol mission success rates, economic participation levels, and infrastructure ROI to identify optimal deployment strategies for new systems.
- **Adaptive Decision-Making:** When building new systems, AI Manager must evaluate local conditions against Sol-trained patterns, adapting cycler logistics, market dynamics, and construction sequencing accordingly.
- **Player Integration:** Maintain player-first economics by creating competitive opportunities in new systems, using Sol data to predict participation levels and adjust NPC fallback timing.

### Implementation Requirements
- **JSON Mission Refinement:** All Sol mission files must be structured for AI pattern recognition, including success criteria, ROI estimates, and adaptive parameters.
- **Economic Continuity:** New systems must replicate Sol's market dynamics, ensuring players can profit from infrastructure contributions and logistics operations.
- **Autonomous Expansion:** AI Manager uses Sol training data to make independent decisions about wormhole stability, resource prioritization, and development sequencing without requiring human intervention.

### Validation Metrics
- **Pattern Accuracy:** AI Manager decisions in new systems must achieve 85% success rate compared to Sol baseline performance.
- **Economic Alignment:** Player participation rates and GCC earnings in new systems should match or exceed Sol system averages.
- **Infrastructure Quality:** New system deployments must meet Sol-established standards for stability, resource availability, and expansion potential.

## 🎮 10. Player Experience Boundaries

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

## 🚀 11. Sci-Fi Easter Eggs (Love Letter to the Genre)

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

## 🐳 12. Environment & Container Management Guardrails

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

### 🗄️ 13. Database Environment Protection Guardrails

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

## 🖥️ 14. Monitor Interface & Layer System Guardrails

### Layer Toggle Logic - SimEarth Additive Overlays
- **Terrain Base Layer:** Terrain is ALWAYS visible as the geological foundation (lithosphere) and cannot be toggled off.
- **Additive Overlays:** All other layers (water, biomes, features, temperature, rainfall, resources) are additive overlays that can be combined freely.
- **Reset Behavior:** Clicking the Terrain button resets view to bare planet (terrain only, all overlays removed).
- **Button States:** Layer buttons show active state when their layer is visible; terrain button is always available for reset.
- **Implementation:** Layer visibility uses `Set` data structure for efficient add/remove operations.

### Terrain Data Sources
- **Primary:** Geosphere.terrain_map (structured data with current_state vs terraformed_goal)
- **Fallback:** Properties.terrain_grid (legacy flat array format)
- **Validation:** System checks both sources and provides clear error messages when no terrain data exists
- **Rendering:** Canvas-based tile rendering with 8px tiles, planet-specific color schemes (Mars red-tints, Earth topographic)

### Civ4/FreeCiv Import Integration
- **Terraformed Input:** Imports treat Civ4/FreeCiv maps as "terraformed goals" (lush, habitable versions)
- **Bare Planet Output:** TerrainTerraformingService converts to realistic barren states based on planet characteristics
- **Dual Storage:** Both barren terrain (for display) and terraformed goal (for AI progression) are stored
- **Planet Classification:** Arid (Mars-like), Oceanic (Earth-like), Temperate, Ice World transformation rules

### Layer Overlay Definitions
- **Water Layer:** Blue highlights for ocean/deep_sea terrain types from FreeCiv water layer data
- **Biomes Layer:** Vegetation/climate overlays using Civ4 biome extraction (forest, jungle, grasslands, plains, tundra, arctic, swamp, boreal) with terrain-specific colors
- **Features Layer:** Geological highlights (rocky areas)
- **Temperature Layer:** SimEarth-style red/blue thermal gradients based on planetary conditions
- **Rainfall Layer:** Blue wetness indicators for jungle/swamp/forest terrain types
- **Resources Layer:** Gold highlights for mineral-rich terrain from Civ4 resource layer data

### Performance Considerations
- **Tile Size:** Fixed 8px tiles for consistent rendering across zoom levels
- **Canvas Dimensions:** Dynamically calculated from terrain grid dimensions
- **Elevation Calculation:** Planet-specific algorithms considering temperature, pressure, latitude
- **Color Blending:** Alpha compositing for smooth layer overlays

## 🔧 13. Sphere Creation Optimization Plan

### Current Issue Analysis
- **Universal Biosphere Creation:** SystemBuilderService creates biosphere for every celestial body regardless of habitability
- **Database Bloat:** Unnecessary biosphere records for Mercury, Venus, Luna, and other barren worlds
- **Conceptual Confusion:** Biosphere existence should imply confirmed biological potential

### Optimization Strategy

#### Phase 1: Conditional Biosphere Creation (Immediate)
- **Criteria:** Only create biosphere for Earth initially (confirmed life-bearing world)
- **Implementation:** Modify `SystemBuilderService#create_celestial_body_record` to check `body.name.downcase == 'earth'`
- **Impact:** ~30-50% reduction in unnecessary sphere records during initial seeding

#### Phase 2: Enhanced Habitability Detection (Future)
- **Temperature Range:** Liquid water range (273-373K) + extended habitable range (200-400K)
- **Water Presence:** Confirmed hydrosphere with liquid water (not just theoretical subsurface)
- **Atmospheric Factors:** Pressure > 0.01 bar + magnetic field protection
- **Data Sources:** JSON biosphere data or explicit habitability confirmation

#### Phase 3: Subsurface Sphere Validation (Future)
- **Hydrosphere:** Only create when confirmed liquid water exists (Europa subsurface ocean requires confirmation)
- **Geosphere Layers:** Only populate mantle/core when geological data confirms complex structure
- **Material Transfer:** Preserve layered architecture for confirmed subsurface features

### Barren Terrain Default Preservation
- **Biome Density Logic:** When `biome_density = 0.0`, terrain displays bare geological features
- **Storage Optimization:** Barren worlds use summary hashes instead of full 2D grids
- **Rendering:** Elevation-based topographic colors without forced biome overlays

### Implementation Status
- **Phase 1:** ✅ Implemented - Biosphere creation limited to Earth
- **Phase 2:** 📋 Planned - Enhanced habitability detection system
- **Phase 3:** 📋 Planned - Subsurface sphere confirmation requirements

## 🛠️ Resource Allocation Engine Integration [2026-01-15]
- All bootstrap settlement logic must use AIManager::ResourceAllocator to calculate initial supply packages (energy, water, food, construction).
- ISRU priorities (oxygen, water, metals) must be ranked and documented per engine requirements.
- ResourceAllocator interacts with ColonyManager's trade logic for supply and extraction planning.
- All integration must be validated by spec and documented in the workflow.
- Cite: ai_resource_allocation_engine.md, Documentation Mandate.