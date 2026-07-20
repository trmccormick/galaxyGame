# Galaxy Game Wiki — Site Map

**Created**: 2026-07-16  
**Purpose**: Complete canonical navigation hierarchy for the Galaxy Game knowledge system.  
**Philosophy**: Organize by game concept, not repository layout. A new contributor should understand the game without knowing Ruby on Rails.

---

## Navigation Philosophy

The wiki is organized around **what the game is**, not how the codebase is structured. Contributors navigate by game domain (Economy, Terraforming, Settlements) rather than by file path or Rails namespace.

Each section has:
- **Canonical page** — ONE authoritative source for the topic
- **Supporting pages** — Detailed explanations of sub-topics
- **Reference pages** — Data tables, indices, constants

---

## 1. Vision

| Page | Type | Purpose |
|------|------|---------|
| [START_HERE.md](#) | Canonical | Entry point; what Galaxy Game is and how to navigate |
| [VISION_AND_PURPOSE.md](#) | Canonical | Why this project exists, goals, scope |
| [DESIGN_PHILOSOPHY.md](#) | Canonical | Core design principles, constraints, intentional complexity |
| [CORE_PRINCIPLES.md](#) | Supporting | Detailed principles (multiple layers, NPC-first economy, etc.) |
| [PLAYER_EXPERIENCE.md](#) | Canonical | What players do, gameplay loops, player roles |
| [PROJECT_GOALS.md](#) | Supporting | Short-term and long-term project objectives |

---

## 2. Story

| Page | Type | Purpose |
|------|------|---------|
| [STORY_OVERVIEW.md](#) | Canonical | Narrative arc, setting, stakes |
| [NARRATIVE_ACTS.md](#) | Supporting | Act-by-act story breakdown |
| [IMPLEMENTATION_PHASES.md](#) | Canonical | Story progression vs implementation progression (Intent #12) |
| [HISTORICAL_TIMELINE.md](#) | Supporting | In-universe timeline of events |
| [SNAP_EVENT.md](#) | Supporting | The Snap Event — narrative climax |
| [WORMHOLE_HISTORY.md](#) | Supporting | Natural and artificial wormhole history |

---

## 3. Universe Generation

> **Core truth**: StarSim is the solar system generation and initialization framework. It creates, loads, and completes star systems. It does NOT simulate planetary states.

| Page | Type | Purpose |
|------|------|---------|
| [UNIVERSE_GENERATION_OVERVIEW.md](#) | Canonical | How star systems are created, loaded, and completed — StarSim framework |
| [STARSIM.md](#) | Canonical | Solar system generation and initialization framework (NOT planetary simulation) |
| [PROCEDURAL_GENERATION.md](#) | Supporting | Wormhole-triggered system generation |
| [JSON_SCHEMAS_AND_IMPORT.md](#) | Canonical | JSON system definitions, import pipeline, known vs generated systems |
| [HYBRID_COMPLETION.md](#) | Supporting | Filling incomplete astronomical data |
| [KNOWN_SYSTEMS.md](#) | Reference | Sol, Eden, Alpha Centauri — pre-defined systems |
| [CELESTIAL_BODIES.md](#) | Canonical | Planets, moons, asteroids — unified reference |
| [NATURAL_WORMHOLES.md](#) | Supporting | Natural wormhole network |
| [ARTIFICIAL_WORMHOLES.md](#) | Supporting | Artificial wormhole construction and maintenance |
| [LOCAL_BUBBLE.md](#) | Supporting | Regional stellar context |

---

## 4. Planetary Simulation

> **Core truth**: TerraSim is the planetary simulation engine. It evaluates the current state of an existing world. It does NOT create solar systems.

| Page | Type | Purpose |
|------|------|---------|
| [PLANETARY_SIMULATION_OVERVIEW.md](#) | Canonical | How planetary states are evaluated and evolved — TerraSim engine |
| [TERRASIM.md](#) | Canonical | Planetary simulation engine (does NOT generate planets; evaluates existing worlds) |
| [GEOSPHERE.md](#) | Supporting | Geosphere simulation layer |
| [ATMOSPHERE.md](#) | Supporting | Atmosphere simulation layer |
| [HYDROSPHERE.md](#) | Supporting | Hydrosphere simulation layer |
| [BIOSPHERE.md](#) | Canonical | Biosphere — planet-scale biological envelope |
| [CRYOSPHERE.md](#) | Supporting | Cryosphere simulation layer |
| [BIOME_SYSTEM.md](#) | Canonical | Biome classification, PlanetBiome instances, terraforming-seeds |
| [TERRAFORMING.md](#) | Canonical | Terraforming as incremental industrial accumulation over time |
| [CLIMATE_CHANGES.md](#) | Supporting | How atmospheric/hydrospheric/geospheric changes propagate |

---

## 5. Game World Model

> **Hierarchy**: Galaxy → Solar System → Star → Celestial Body → Planet Environment → Settlement → Structure → Units

| Page | Type | Purpose |
|------|------|---------|
| [WORLD_MODEL_OVERVIEW.md](#) | Canonical | Complete world model hierarchy from galaxy to units |
| [GALAXY.md](#) | Supporting | Galaxy-level organization |
| [SOLAR_SYSTEM.md](#) | Canonical | Solar system structure and components |
| [STAR.md](#) | Supporting | Star properties and stellar classification |
| [CELESTIAL_BODY.md](#) | Canonical | Celestial body hierarchy and relationships |
| [PLANET_ENVIRONMENT.md](#) | Canonical | Planet environment model (mass, radius, gravity, orbital position, atmosphere, hydrosphere, geosphere, biosphere) |
| [SETTLEMENT.md](#) | Supporting | Settlement administration model |
| [STRUCTURE.md](#) | Supporting | Structure asset model |
| [UNIT.md](#) | Supporting | Unit model (craft, vessels, etc.) |

---

## 6. Simulation Engine

> **Core truth**: The simulation engine coordinates StarSim and TerraSim. StarSim creates/loads solar systems; TerraSim evaluates planetary states. They are fundamentally different concerns that work together in a pipeline.

| Page | Type | Purpose |
|------|------|---------|
| [SIMULATION_ENGINE_OVERVIEW.md](#) | Canonical | How StarSim and TerraSim coordinate — the simulation pipeline |
| [STAR_SIM_PIPELINE.md](#) | Supporting | StarSim → Solar System → Celestial Bodies flow |
| [TERRA_SIM_PIPELINE.md](#) | Supporting | Celestial Bodies → TerraSim → Planetary State flow |
| [SIMULATION_DATA_OWNERSHIP.md](#) | Canonical | Which system owns which data (StarSim owns systems; TerraSim owns planetary state) |
| [SIMULATION_INTEGRATION.md](#) | Supporting | How StarSim and TerraSim interact (import pipeline, initialization) |
| [SIMULATION_PIPELINE.md](#) | Supporting | End-to-end simulation flow from system generation to planetary evaluation |

---

## 7. Economy

| Page | Type | Purpose |
|------|------|---------|
| [ECONOMY_OVERVIEW.md](#) | Canonical | Economy at a glance — NPC-first, dual-currency, Earth anchor pricing |
| [CURRENCY.md](#) | Supporting | GCC and USD — dual-currency system |
| [MARKETS.md](#) | Canonical | Market structure — NPC-driven price discovery |
| [TRADING.md](#) | Supporting | How trading works (NPC-to-NPC, player opportunities) |
| [NPC_ECONOMY.md](#) | Canonical | NPC economy — how NPCs create and sustain markets |
| [PLAYER_ECONOMY.md](#) | Supporting | Player participation in the economy |
| [CONTRACTS.md](#) | Canonical | Contract system — opportunities, types, lifecycle |
| [SUPPLY_AND_DEMAND.md](#) | Supporting | Supply/demand mechanics and price discovery |
| [IMPORT_EXPORT.md](#) | Canonical | Import/export rules — Earth anchor pricing, transport costs |
| [PRICING.md](#) | Canonical | Pricing system — EAP, delta-V costs, locality premiums |
| [ECONOMIC_PHILOSOPHY.md](#) | Supporting | Why imports are expensive, why transport is never free |

---

## 8. Manufacturing

| Page | Type | Purpose |
|------|------|---------|
| [MANUFACTURING_OVERVIEW.md](#) | Canonical | Manufacturing at a glance — pipeline and philosophy |
| [RESOURCES.md](#) | Canonical | Resource types — raw, processed, components, materials |
| [ISRU.md](#) | Canonical | In-situ resource utilization — extraction and processing |
| [BLUEPRINTS.md](#) | Canonical | Blueprint system — JSON-driven data definitions |
| [CONSTRUCTION.md](#) | Supporting | Construction jobs and structure building |
| [TECHNOLOGY_LEVELS.md](#) | Canonical | Technology Level progression (two-axis with MK) |
| [MK_GENERATIONS.md](#) | Supporting | Model Kit — engineering iteration within a tier |
| [FACTORIES.md](#) | Supporting | NPC factories and fabrication |
| [RESOURCE_PROCESSING.md](#) | Supporting | Raw → processed → components pipeline |
| [MANUFACTURING_PIPELINE.md](#) | Canonical | End-to-end manufacturing flow overview |

---

## 9. Settlements

| Page | Type | Purpose |
|------|------|---------|
| [SETTLEMENTS_OVERVIEW.md](#) | Canonical | Settlement hierarchy at a glance |
| [COLONIES.md](#) | Canonical | Colony — government entity of 2+ settlements |
| [SETTLEMENTS.md](#) | Canonical | Settlement — administrative population center |
| [STRUCTURES.md](#) | Canonical | Structure — physical asset belonging to settlement |
| [WORLDHOUSES.md](#) | Canonical | Worldhouse — lava-tube enclosure habitat |
| [ORBITAL_SETTLEMENTS.md](#) | Canonical | Orbital depot — constellation of docked structures |
| [POPULATION.md](#) | Supporting | Population management and growth |
| [INFRASTRUCTURE.md](#) | Supporting | Infrastructure types and requirements |
| [EXPANSION.md](#) | Supporting | Settlement expansion mechanics |

---

## 10. Transportation

| Page | Type | Purpose |
|------|------|---------|
| [TRANSPORTATION_OVERVIEW.md](#) | Canonical | Transportation at a glance — craft, stations, logistics |
| [CRAFT.md](#) | Canonical | Craft types and capabilities |
| [STATIONS.md](#) | Supporting | Station types (Lagrange, gateway, converted rock) |
| [DEPOTS.md](#) | Supporting | Depot system and orbital facilities |
| [SHIPYARDS.md](#) | Supporting | Shipyard infrastructure (optional MVP) |
| [CYCLERS.md](#) | Canonical | Cycler routes — repeating transport paths |
| [CARGO.md](#) | Supporting | Cargo types, capacity, handling |
| [DOCKING.md](#) | Supporting | Docking mechanics and procedures |
| [LOGISTICS_NETWORK.md](#) | Canonical | End-to-end logistics network overview |

---

## 11. AI Manager

| Page | Type | Purpose |
|------|------|---------|
| [AI_MANAGER_OVERVIEW.md](#) | Canonical | AI Manager — orchestration layer and service portfolio |
| [MISSION_VALIDATION.md](#) | Supporting | How missions are validated and executed |
| [PATTERN_LEARNING.md](#) | Supporting | AI pattern learning and precursor intelligence |
| [EXPANSION_LOGIC.md](#) | Supporting | AI-driven expansion decisions |
| [ECONOMY_SUBSYSTEM.md](#) | Supporting | AI Manager economy management |
| [CONSTRUCTION_SUBSYSTEM.md](#) | Supporting | AI Manager construction planning |
| [LOGISTICS_SUBSYSTEM.md](#) | Supporting | AI Manager logistics coordination |
| [DECISION_MAKING.md](#) | Supporting | AI decision-making framework |
| [SIMULATION_INTEGRATION.md](#) | Supporting | AI Manager ↔ TerraSim integration |
| [SERVICE_PORTFOLIO.md](#) | Reference | Complete service inventory (80+ services) |

---

## 12. Gameplay

| Page | Type | Purpose |
|------|------|---------|
| [GAMEPLAY_OVERVIEW.md](#) | Canonical | Multiple interconnected gameplay loops overview |
| [PLANETARY_GAMEPLAY.md](#) | Supporting | Planetary settlement and terraforming gameplay |
| [ORBITAL_GAMEPLAY.md](#) | Supporting | Orbital station and depot gameplay |
| [INDUSTRY_GAMEPLAY.md](#) | Supporting | Manufacturing and resource industry |
| [MINING_GAMEPLAY.md](#) | Supporting | Mining operations and extraction |
| [TRADING_GAMEPLAY.md](#) | Supporting | Trading loop and economic opportunities |
| [TERRAFORMING_GAMEPLAY.md](#) | Supporting | Terraforming as a gameplay loop |
| [EXPLORATION_GAMEPLAY.md](#) | Supporting | Exploration, wormhole scouting, discovery |
| [CORPORATIONS.md](#) | Supporting | Player corporations and organizational structures |
| [PLAYER_PROGRESSION.md](#) | Canonical | How players advance through the game |

---

## 13. Development

| Page | Type | Purpose |
|------|------|---------|
| [DEVELOPMENT_OVERVIEW.md](#) | Canonical | Development architecture and conventions overview |
| [ARCHITECTURE.md](#) | Canonical | System architecture — data-driven, lookup services, AI Manager |
| [CODING_STANDARDS.md](#) | Supporting | Coding conventions and style guide |
| [JSON_STANDARDS.md](#) | Supporting | JSON data format standards (blueprints, resources, etc.) |
| [NAMING_CONVENTIONS.md](#) | Supporting | Naming conventions across the codebase |
| [BLUEPRINT_STANDARDS.md](#) | Supporting | Blueprint schema and versioning |
| [DEVELOPMENT_PHASES.md](#) | Canonical | MVP roadmap — Earth → Luna → L1 → Mars → Venus → ... |
| [BACKLOG.md](#) | Reference | Current backlog organized by phase |
| [TESTING.md](#) | Canonical | Testing philosophy and practical guide |
| [AI_WORKFLOW.md](#) | Supporting | AI agent workflow conventions |

---

## 14. Reference

| Page | Type | Purpose |
|------|------|---------|
| [GLOSSARY.md](#) | Canonical | Terminology glossary — all game terms defined |
| [TERMINOLOGY.md](#) | Supporting | Detailed terminology with usage context |
| [GAME_CONSTANTS.md](#) | Reference | Game constants (gravity, delta-V budgets, etc.) |
| [RESOURCE_LIST.md](#) | Reference | Complete resource catalog |
| [CELESTIAL_BODY_INDEX.md](#) | Reference | All celestial bodies in the game |
| [BLUEPRINT_INDEX.md](#) | Reference | All blueprints with properties |
| [JSON_SCHEMAS.md](#) | Reference | JSON schema definitions for all data types |
| [CROSS_REFERENCES.md](#) | Canonical | Cross-reference map between all major topics |

---

## Navigation Map

```
Galaxy Game Wiki
├── 1. Vision
│   ├── START_HERE (entry point)
│   ├── VISION_AND_PURPOSE
│   ├── DESIGN_PHILOSOPHY
│   ├── CORE_PRINCIPLES
│   ├── PLAYER_EXPERIENCE
│   └── PROJECT_GOALS
├── 2. Story
│   ├── STORY_OVERVIEW
│   ├── NARRATIVE_ACTS
│   ├── IMPLEMENTATION_PHASES
│   ├── HISTORICAL_TIMELINE
│   ├── SNAP_EVENT
│   └── WORMHOLE_HISTORY
├── 3. Universe Generation
│   ├── UNIVERSE_GENERATION_OVERVIEW
│   ├── STARSIM (solar system generation, NOT planetary simulation)
│   ├── PROCEDURAL_GENERATION
│   ├── JSON_SCHEMAS_AND_IMPORT
│   ├── HYBRID_COMPLETION
│   ├── KNOWN_SYSTEMS
│   ├── CELESTIAL_BODIES
│   ├── NATURAL_WORMHOLES
│   ├── ARTIFICIAL_WORMHOLES
│   └── LOCAL_BUBBLE
├── 4. Planetary Simulation
│   ├── PLANETARY_SIMULATION_OVERVIEW
│   ├── TERRASIM (planetary evaluation, NOT system generation)
│   ├── GEOSPHERE
│   ├── ATMOSPHERE
│   ├── HYDROSPHERE
│   ├── BIOSPHERE
│   ├── CRYOSPHERE
│   ├── BIOME_SYSTEM
│   ├── TERRAFORMING
│   └── CLIMATE_CHANGES
├── 5. Game World Model
│   ├── WORLD_MODEL_OVERVIEW
│   ├── GALAXY
│   ├── SOLAR_SYSTEM
│   ├── STAR
│   ├── CELESTIAL_BODY
│   ├── PLANET_ENVIRONMENT
│   ├── SETTLEMENT
│   ├── STRUCTURE
│   └── UNIT
├── 6. Simulation Engine
│   ├── SIMULATION_ENGINE_OVERVIEW
│   ├── STAR_SIM_PIPELINE
│   ├── TERRA_SIM_PIPELINE
│   ├── SIMULATION_DATA_OWNERSHIP
│   ├── SIMULATION_INTEGRATION
│   └── SIMULATION_PIPELINE
├── 7. Economy
│   ├── ECONOMY_OVERVIEW
│   ├── CURRENCY
│   ├── MARKETS
│   ├── TRADING
│   ├── NPC_ECONOMY
│   ├── PLAYER_ECONOMY
│   ├── CONTRACTS
│   ├── SUPPLY_AND_DEMAND
│   ├── IMPORT_EXPORT
│   ├── PRICING
│   └── ECONOMIC_PHILOSOPHY
├── 8. Manufacturing
│   ├── MANUFACTURING_OVERVIEW
│   ├── RESOURCES
│   ├── ISRU
│   ├── BLUEPRINTS
│   ├── CONSTRUCTION
│   ├── TECHNOLOGY_LEVELS
│   ├── MK_GENERATIONS
│   ├── FACTORIES
│   ├── RESOURCE_PROCESSING
│   └── MANUFACTURING_PIPELINE
├── 9. Settlements
│   ├── SETTLEMENTS_OVERVIEW
│   ├── COLONIES
│   ├── SETTLEMENTS
│   ├── STRUCTURES
│   ├── WORLDHOUSES
│   ├── ORBITAL_SETTLEMENTS
│   ├── POPULATION
│   ├── INFRASTRUCTURE
│   └── EXPANSION
├── 10. Transportation
│   ├── TRANSPORTATION_OVERVIEW
│   ├── CRAFT
│   ├── STATIONS
│   ├── DEPOTS
│   ├── SHIPYARDS
│   ├── CYCLERS
│   ├── CARGO
│   ├── DOCKING
│   └── LOGISTICS_NETWORK
├── 11. AI Manager
│   ├── AI_MANAGER_OVERVIEW
│   ├── MISSION_VALIDATION
│   ├── PATTERN_LEARNING
│   ├── EXPANSION_LOGIC
│   ├── ECONOMY_SUBSYSTEM
│   ├── CONSTRUCTION_SUBSYSTEM
│   ├── LOGISTICS_SUBSYSTEM
│   ├── DECISION_MAKING
│   ├── SIMULATION_INTEGRATION
│   └── SERVICE_PORTFOLIO
├── 12. Gameplay
│   ├── GAMEPLAY_OVERVIEW
│   ├── PLANETARY_GAMEPLAY
│   ├── ORBITAL_GAMEPLAY
│   ├── INDUSTRY_GAMEPLAY
│   ├── MINING_GAMEPLAY
│   ├── TRADING_GAMEPLAY
│   ├── TERRAFORMING_GAMEPLAY
│   ├── EXPLORATION_GAMEPLAY
│   ├── CORPORATIONS
│   └── PLAYER_PROGRESSION
├── 13. Development
│   ├── DEVELOPMENT_OVERVIEW
│   ├── ARCHITECTURE
│   ├── CODING_STANDARDS
│   ├── JSON_STANDARDS
│   ├── NAMING_CONVENTIONS
│   ├── BLUEPRINT_STANDARDS
│   ├── DEVELOPMENT_PHASES
│   ├── BACKLOG
│   ├── TESTING
│   └── AI_WORKFLOW
└── 14. Reference
    ├── GLOSSARY
    ├── TERMINOLOGY
    ├── GAME_CONSTANTS
    ├── RESOURCE_LIST
    ├── CELESTIAL_BODY_INDEX
    ├── BLUEPRINT_INDEX
    ├── JSON_SCHEMAS
    └── CROSS_REFERENCES
```

---

## Page Types Legend

| Type | Meaning |
|------|---------|
| **Canonical** | ONE authoritative page for the topic. All other pages on this topic link here. |
| **Supporting** | Detailed explanation of a sub-topic. Links to canonical page. |
| **Reference** | Data tables, indices, constants. Read-only reference material. |

---

## Reading Order (Onboarding Path)

A new contributor should read in this order:

1. **START_HERE** — What is Galaxy Game? How to navigate
2. **VISION_AND_PURPOSE** — Why this project exists
3. **DESIGN_PHILOSOPHY** — Core design principles
4. **STORY_OVERVIEW** — The narrative setting
5. **UNIVERSE_GENERATION_OVERVIEW** — How star systems are created and loaded
6. **PLANETARY_SIMULATION_OVERVIEW** — How planetary states are evaluated
7. **GAME_WORLD_MODEL_OVERVIEW** — Galaxy → Solar System → Star → Celestial Body → Planet Environment → Settlement → Structure → Units
8. **SIMULATION_ENGINE_OVERVIEW** — How StarSim and TerraSim coordinate
9. **ECONOMY_OVERVIEW** — NPC-first economy
10. **MANUFACTURING_OVERVIEW** — Resource pipeline
11. **SETTLEMENTS_OVERVIEW** — Colony hierarchy
12. **TRANSPORTATION_OVERVIEW** — Logistics network
13. **AI_MANAGER_OVERVIEW** — Orchestration layer
14. **GAMEPLAY_OVERVIEW** — Player experience
15. **DEVELOPMENT_OVERVIEW** — For contributors
16. **GLOSSARY** — Terminology reference

---

## Cross-Section Links (Canonical)

Every canonical page should link to:
- Related canonical pages in adjacent sections
- The Glossary for key terms
- The Cross References page for full topic map
- The relevant gameplay section if the system has player-facing mechanics
