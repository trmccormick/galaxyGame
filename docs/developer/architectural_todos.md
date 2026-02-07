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

## TERRAIN & MAP SYSTEM FIXES [Added 2026-02-05]

### Monitor View Architecture Correction

**Issue:** Monitor loading FreeCiv/Civ4 data directly, converting terrain types to elevation.
**Impact:** Unrealistic elevation range (279-322m instead of real topography).

**Required Fixes:**
1. Load NASA GeoTIFF data directly for Sol bodies
2. Remove FreeCiv→elevation conversion code
3. Rename "Water" → "Hydrosphere" with composition-based colors
4. Add body-specific color gradients (Luna=grey, Mars=rust, etc.)
5. Fix `primary_liquid` method to check `liquid_name` attribute

**Data Source Hierarchy:**
- NASA GeoTIFF = Ground truth (Earth, Mars, Luna, Mercury)
- FreeCiv/Civ4 = Training data only (patterns, labels, hints)
- AI Manager = Generator for bodies without NASA data

**Files to Modify:**
- `app/views/admin/celestial_bodies/monitor.html.erb`
- `app/services/terrain/automatic_terrain_generator.rb`
- `app/models/concerns/hydrosphere_concern.rb`

**Priority:** HIGH - Blocks correct terrain display

### Geological Data Completion

**Issue:** Missing major features from Mars and Luna geological data.

**Mars Missing (from Civ4/FreeCiv cross-reference):**
- Volcanoes: Olympus Mons, Elysium Mons, Tharsis chain (Ascraeus/Pavonis/Arsia)
- Planitia: Hellas, Argyre, Utopia, Acidalia
- Terrae: Arabia Terra, Noachis Terra, Terra Sabaea
- Tholus: Hecatus Tholus, Albor Tholus

**Luna Missing:**
- Maria: Mare Tranquillitatis, Mare Imbrium, Oceanus Procellarum, etc.
- Montes: Mons Huygens, Apennine Mountains

**Existing Data (Wikipedia extraction 2025):**
- Mars: 1,134 craters, valles, lava tubes
- Luna: 1,577 craters, lava tubes

**JSON Files Needed:**
```
mars/geological_features/
├── craters.json          ✅ Exists
├── craters_catalog.json  ✅ Exists
├── valles.json           ✅ Exists
├── lava_tubes.json       ✅ Exists
├── volcanoes.json        ❌ MISSING
├── planitia.json         ❌ MISSING
├── terrae.json           ❌ MISSING
└── tholus.json           ❌ MISSING

luna/geological_features/
├── craters.json          ✅ Exists
├── craters_catalog.json  ✅ Exists
├── lava_tubes.json       ✅ Exists
├── maria.json            ❌ MISSING
└── montes.json           ❌ MISSING
```

**Strategy:** Use Civ4/FreeCiv labels as checklist, populate with Wikipedia/NASA data.

**Priority:** LOW - Data enrichment, not blocking

## EXTERNAL PROJECT OUTREACH [Added 2026-02-05]

### FreeMars Author Contact

**Project:** https://github.com/arikande/FreeMars  
**Author:** Deniz ARIKAN (@arikande)  
**Status:** 📋 TODO - Pending outreach

**Background:**
FreeMars is a standalone Java Mars colonization game with Mars-specific terrain
tilesets (wasteland, crater, ice, plains, etc.) and unit graphics. The repository 
has NO LICENSE FILE, meaning all rights are reserved by default.

**Primary Interest: Image Assets**
- Mars terrain tilesets (purpose-built for Mars colonization)
- Unit sprites (colonizers, engineers, transporters, etc.)
- Code is Java/Swing - not usable in Ruby/Rails regardless of license

**Purpose of Contact:**
1. **Primary:** Request permission to use/convert PNG assets (terrain, units)
2. **Secondary:** Ask about adding open-source license
3. **Optional:** Share Galaxy Game project

**See:** [EXTERNAL_REFERENCES.md](./EXTERNAL_REFERENCES.md) for full details and draft message

**Fallback:** FreeCiv tilesets (GPL) + OpenGameArt.org

**Priority:** MEDIUM - Would save significant asset creation time