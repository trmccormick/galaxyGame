// TODO: Refactor geological features and structures
// Plan and implement migration of LavaTube, Crater, Skylight, AccessPoint to GeologicalFeatures:: namespace, and move player-built structures to Structures:: namespace. Update associations and schema to reflect natural vs. built separation. (See chat notes Dec 16, 2025)
// TODO: Expand MaterialRequestService to automatically generate market buy orders when material requests cannot be fulfilled from inventory. Integrate this with the market/order system for seamless procurement.
Refactor NPCPriceCalculator to be more dynamic (as you mentioned)
Consider refactoring find_matching_orders to use dependency injection for easier testing

## ARCHITECTURAL REFACTOR: Geological Features vs Structures Namespace

**Issue:** Natural geological features (LavaTube, Skylight, AccessPoint) mixed with player-built structures

**Proposed Namespaces:**
- GeologicalFeatures:: (discovered natural formations)
  - LavaTube (from lava_tubes.json) - move from Structures
  - Crater (NEW - from lunar_craters.json, martian_craters.json)
  - Skylight (has own table, belongs_to :lava_tube)
  - AccessPoint (has own table, belongs_to :lava_tube)

- Structures:: (player-built)
  - CraterDome (location: polymorphic → Crater)
  - HabitationFacility, Hangar, PowerStation, etc.

**Data Sources:**
- data/json-data/star_systems/sol/celestial_bodies/earth/luna/lava_tubes.json
- data/json-data/star_systems/sol/celestial_bodies/earth/luna/lunar_craters.json
- data/json-data/star_systems/sol/celestial_bodies/mars/martian_craters.json

**Priority:** Medium - improves architecture, not blocking

## FUTURE FEATURE: Technology Tree System

**Proposed Structure (from Gemini chat review):**
- Category: Computing & AI
- Tiers: Advanced Computing → AI Systems → Advanced AI → Quantum Computing
- Research Requirements: GCC costs, research points (engineering, scientific, social)
- Unlocks: Units, buildings, capabilities (e.g., Space-Hardened Computing System)
- Materials: Silicon, gold, electronics for construction
- Time-based research and building

**Implementation Notes:**
- JSON-based tech tree definitions
- Research progression with prerequisites
- Unlocks tied to AI manager capabilities, cycler configurations
- Potential for player-driven research branches

**Priority:** Low - Future expansion after core systems stable

## FUTURE FEATURE: AI Managers for Player Autonomy

**Concept:** AI systems that manage settlements and operations when the player is absent or focused elsewhere, enabling continuous gameplay progression.

**Key Features:**
- Autonomous decision-making for resource harvesting, building, and trade
- Delegated actions based on player-defined priorities
- Communication systems for status updates and decision approvals
- Physical player presence integration for immersive control

**Implementation Notes:**
- AI logic for economic decisions, market interactions, and infrastructure management
- Integration with existing services (ManufacturingService, MarketService)
- Player override capabilities for critical decisions
- Scalability for multiple settlements across star systems

**Priority:** Medium - Enhances gameplay depth without core changes
