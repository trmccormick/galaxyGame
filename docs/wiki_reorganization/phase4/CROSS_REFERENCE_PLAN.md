# Cross-Reference Plan — Phase 4

**Created**: 2026-07-16  
**Purpose**: Identify all required internal wiki links to eliminate isolated documentation and create a connected knowledge graph.

---

## Linking Philosophy

Every canonical page should link to:
1. **Adjacent canonical pages** in related sections (e.g., Economy → Manufacturing)
2. **The Glossary** for every key term on first use
3. **The Cross References page** for the full topic map
4. **Supporting pages** that provide detailed sub-topic coverage
5. **Gameplay section** if the system has player-facing mechanics

---

## Section-to-Section Canonical Links

### 1. Vision → All Sections

| From | To | Context |
|------|-----|---------|
| START_HERE | DESIGN_PHILOSOPHY | "Core design principles" |
| START_HERE | STORY_OVERVIEW | "The narrative setting" |
| START_HERE | UNIVERSE_OVERVIEW | "The game world" |
| START_HERE | SIMULATION_OVERVIEW | "How the world works" |
| START_HERE | ECONOMY_OVERVIEW | "NPC-first economy" |
| START_HERE | MANUFACTURING_OVERVIEW | "Resource pipeline" |
| START_HERE | SETTLEMENTS_OVERVIEW | "Colony hierarchy" |
| START_HERE | TRANSPORTATION_OVERVIEW | "Logistics network" |
| START_HERE | AI_MANAGER_OVERVIEW | "Orchestration layer" |
| START_HERE | GAMEPLAY_OVERVIEW | "Player experience" |
| DESIGN_PHILOSOPHY | CORE_PRINCIPLES | "Detailed principles" |
| DESIGN_PHILOSOPHY | IMPLEMENTATION_PHASES | "Story vs implementation" (Intent #12) |

### 2. Story → Universe, Simulation, Settlements

| From | To | Context |
|------|-----|---------|
| STORY_OVERVIEW | SOL_SYSTEM | "The Sol system setting" |
| STORY_OVERVIEW | EDEN_SYSTEM | "Target colonization system" |
| STORY_OVERVIEW | WORMHOLE_HISTORY | "Wormhole network history" |
| STORY_OVERVIEW | IMPLEMENTATION_PHASES | "Story progression vs implementation" |
| SNAP_EVENT | ARTIFICIAL_WORMHOLES | "Snap Event wormhole mechanics" |
| SNAP_EVENT | EDEN_SYSTEM | "Snap Event Eden system impact" |
| WORMHOLE_HISTORY | NATURAL_WORMHOLES | "Natural wormhole network" |
| WORMHOLE_HISTORY | ARTIFICIAL_WORMHOLES | "Artificial wormhole construction" |

### 3. Universe Generation → Simulation, Transportation

| From | To | Context |
|------|-----|---------|
| UNIVERSE_OVERVIEW | SOL_SYSTEM | "Our solar system" |
| UNIVERSE_OVERVIEW | EDEN_SYSTEM | "Eden colonization target" |
| UNIVERSE_OVERVIEW | NATURAL_WORMHOLES | "Natural wormhole network" |
| UNIVERSE_OVERVIEW | CELESTIAL_BODIES | "All celestial bodies" |
| SOL_SYSTEM | TERRAFORMABLE_PLANETS | "Terraformable worlds in Sol" |
| SOL_SYSTEM | LUNA | "Luna — first settlement target" |
| EDEN_SYSTEM | ARTIFICIAL_WORMHOLES | "Eden access via artificial wormholes" |
| CELESTIAL_BODIES | BIOME_SYSTEM | "Biome types by celestial body" |
| CELESTIAL_BODIES | TERRAFORMING | "Terraforming potential by body" |

### 4. Planetary Simulation → Economy, Manufacturing, Terraforming

| From | To | Context |
|------|-----|---------|
| SIMULATION_OVERVIEW | STARSIM | "Star system generation" |
| SIMULATION_OVERVIEW | TERRASIM | "Planetary simulation" |
| SIMULATION_OVERVIEW | BIOME_SYSTEM | "Biome classification system" |
| SIMULATION_OVERVIEW | TERRAFORMING | "Terraforming pipeline" |
| STARSIM | CELESTIAL_BODIES | "Generated celestial bodies" |
| STARSIM | NATURAL_WORMHOLES | "Natural wormhole generation" |
| TERRASIM | BIOSPHERE | "Biosphere simulation layer" |
| TERRASIM | ATMOSPHERE | "Atmosphere simulation layer" |
| TERRASIM | HYDROSPHERE | "Hydrosphere simulation layer" |
| TERRASIM | GEOSPHERE | "Geosphere simulation layer" |
| TERRASIM | CRYOSPHERE | "Cryosphere simulation layer" |
| BIOSPHERE | BIOME_SYSTEM | "Biome classification" |
| BIOSPHERE | TERRAFORMING | "Terraforming biosphere evolution" |
| BIOME_SYSTEM | WORLDHOUSES | "Engineered biomes in worldhouses" |
| BIOME_SYSTEM | PLANETBIOME | "PlanetBiome instances" |
| TERRAFORMING | WORLDHOUSES | "Worldhouse terraforming-seeds" |
| TERRAFORMING | ISRU | "ISRU for terraforming materials" |

---

### 5. Game World Model → Universe, Simulation, Settlements

| From | To | Context |
|------|-----|---------|
| WORLD_MODEL_OVERVIEW | GALAXY | "Galaxy-level organization" |
| WORLD_MODEL_OVERVIEW | SOLAR_SYSTEM | "Solar system structure" |
| WORLD_MODEL_OVERVIEW | CELESTIAL_BODY | "Celestial body hierarchy" |
| WORLD_MODEL_OVERVIEW | PLANET_ENVIRONMENT | "Planet environment model" |
| WORLD_MODEL_OVERVIEW | SETTLEMENT | "Settlement administration" |
| WORLD_MODEL_OVERVIEW | STRUCTURE | "Structure asset model" |
| SOLAR_SYSTEM | STAR | "Star properties" |
| SOLAR_SYSTEM | CELESTIAL_BODY | "Celestial bodies in system" |
| CELESTIAL_BODY | PLANET_ENVIRONMENT | "Planet environment attributes" |
| SETTLEMENT | STRUCTURE | "Settlement-owned structures" |
| SETTLEMENT | UNIT | "Settlement-managed units" |

---

### 6. Simulation Engine → Universe, Planetary Simulation

| From | To | Context |
|------|-----|---------|
| SIMULATION_ENGINE_OVERVIEW | STAR_SIM_PIPELINE | "StarSim system generation pipeline" |
| SIMULATION_ENGINE_OVERVIEW | TERRA_SIM_PIPELINE | "TerraSim planetary evaluation pipeline" |
| SIMULATION_ENGINE_OVERVIEW | SIMULATION_DATA_OWNERSHIP | "Data ownership boundaries" |
| SIMULATION_ENGINE_OVERVIEW | SIMULATION_INTEGRATION | "StarSim ↔ TerraSim integration" |
| STAR_SIM_PIPELINE | CELESTIAL_BODIES | "Generated celestial bodies" |
| STAR_SIM_PIPELINE | NATURAL_WORMHOLES | "Natural wormhole generation" |
| TERRA_SIM_PIPELINE | BIOSPHERE | "Biosphere simulation layer" |
| TERRA_SIM_PIPELINE | ATMOSPHERE | "Atmosphere simulation layer" |
| TERRA_SIM_PIPELINE | HYDROSPHERE | "Hydrosphere simulation layer" |
| TERRA_SIM_PIPELINE | GEOSPHERE | "Geosphere simulation layer" |
| SIMULATION_DATA_OWNERSHIP | STARSIM | "StarSim owns system data" |
| SIMULATION_DATA_OWNERSHIP | TERRASIM | "TerraSim owns planetary state" |
| SIMULATION_INTEGRATION | JSON_SCHEMAS_AND_IMPORT | "Import pipeline connects systems" |

---

### 7. Economy → Manufacturing, Settlements, Transportation

| From | To | Context |
|------|-----|---------|
| ECONOMY_OVERVIEW | CURRENCY | "Dual-currency system (GCC/USD)" |
| ECONOMY_OVERVIEW | NPC_ECONOMY | "NPC-driven economy" |
| ECONOMY_OVERVIEW | PLAYER_ECONOMY | "Player participation" |
| ECONOMY_OVERVIEW | PRICING | "Earth anchor pricing" |
| ECONOMY_OVERVIEW | ECONOMIC_PHILOSOPHY | "Why imports are expensive" |
| CURRENCY | DUAL_ECONOMY_INTENT | "Dual economy design intent" |
| NPC_ECONOMY | AI_MANAGER_ECONOMY_SUBSYSTEM | "AI Manager economy management" |
| NPC_ECONOMY | CONTRACTS | "NPC contract opportunities" |
| PLAYER_ECONOMY | CONTRACTS | "Player contract system" |
| PRICING | IMPORT_EXPORT | "Import/export pricing rules" |
| PRICING | TRANSPORT_COSTS | "Transport cost calculation" |
| CONTRACTS | PLAYER_GAMEPLAY | "Player contract gameplay" |
| ECONOMIC_PHILOSOPHY | CORE_PRINCIPLES | "Core principle: transport never free" |

### 8. Manufacturing → Resources, Blueprints, Technology

| From | To | Context |
|------|-----|---------|
| MANUFACTURING_OVERVIEW | RESOURCES | "Resource types" |
| MANUFACTURING_OVERVIEW | ISRU | "In-situ resource utilization" |
| MANUFACTURING_OVERVIEW | BLUEPRINTS | "Blueprint system" |
| MANUFACTURING_OVERVIEW | CONSTRUCTION | "Construction jobs" |
| MANUFACTURING_OVERVIEW | TECHNOLOGY_LEVELS | "Technology progression" |
| MANUFACTURING_OVERVIEW | MK_GENERATIONS | "Model Kit generations" |
| RESOURCES | RESOURCE_LIST | "Complete resource catalog" |
| ISRU | LUNA_ISRU | "Luna ISRU operations" |
| BLUEPRINTS | BLUEPRINT_INDEX | "Complete blueprint index" |
| BLUEPRINTS | JSON_SCHEMAS | "Blueprint JSON schema" |
| TECHNOLOGY_LEVELS | MK_GENERATIONS | "TL/MK two-axis system" |
| CONSTRUCTION | STRUCTURES | "Structure construction" |

### 9. Settlements → Structures, Worldhouses, Orbital

| From | To | Context |
|------|-----|---------|
| SETTLEMENTS_OVERVIEW | COLONIES | "Colony government entity" |
| SETTLEMENTS_OVERVIEW | SETTLEMENTS | "Settlement administrative center" |
| SETTLEMENTS_OVERVIEW | STRUCTURES | "Structure physical asset" |
| SETTLEMENTS_OVERVIEW | WORLDHOUSES | "Worldhouse lava-tube habitat" |
| SETTLEMENTS_OVERVIEW | ORBITAL_SETTLEMENTS | "Orbital depot constellation" |
| COLONIES | SETTLEMENTS | "Colony requires 2+ settlements" |
| STRUCTURES | WORLDHOUSES | "Worldhouse as structure type" |
| STRUCTURES | ORBITAL_SETTLEMENTS | "Orbital structure types" |
| WORLDHOUSES | BIOME_SYSTEM | "Worldhouse biome integration" |
| WORLDHOUSES | TERRAFORMING | "Worldhouse terraforming-seeds" |
| ORBITAL_SETTLEMENTS | CYCLERS | "Cycler transport to orbital depots" |
| ORBITAL_SETTLEMENTS | DEPOTS | "Orbital depot facilities" |

### 10. Transportation → Logistics, Craft, Stations

| From | To | Context |
|------|-----|---------|
| TRANSPORTATION_OVERVIEW | CRAFT | "Craft types and capabilities" |
| TRANSPORTATION_OVERVIEW | STATIONS | "Station types" |
| TRANSPORTATION_OVERVIEW | DEPOTS | "Depot system" |
| TRANSPORTATION_OVERVIEW | CYCLERS | "Cycler routes" |
| TRANSPORTATION_OVERVIEW | LOGISTICS_NETWORK | "End-to-end logistics" |
| CRAFT | SKIMMER_CRAFT_INTENT | "Skimmer craft design intent" |
| STATIONS | CERES_GATEWAY | "Ceres Gateway station" |
| STATIONS | L1_LAGRANGE_FACILITIES | "L1 Lagrange facilities" |
| CYCLERS | TRANSPORT_COSTS | "Cycler transport costs" |
| LOGISTICS_NETWORK | WORMHOLE_NETWORK | "Wormhole network integration" |

### 11. AI Manager → All Systems

| From | To | Context |
|------|-----|---------|
| AI_MANAGER_OVERVIEW | MISSION_VALIDATION | "Mission validation system" |
| AI_MANAGER_OVERVIEW | PATTERN_LEARNING | "AI pattern learning" |
| AI_MANAGER_OVERVIEW | EXPANSION_LOGIC | "AI-driven expansion" |
| AI_MANAGER_OVERVIEW | ECONOMY_SUBSYSTEM | "Economy management" |
| AI_MANAGER_OVERVIEW | CONSTRUCTION_SUBSYSTEM | "Construction planning" |
| AI_MANAGER_OVERVIEW | LOGISTICS_SUBSYSTEM | "Logistics coordination" |
| AI_MANAGER_OVERVIEW | SERVICE_PORTFOLIO | "Complete service inventory (80+)" |
| ECONOMY_SUBSYSTEM | NPC_ECONOMY | "NPC economy orchestration" |
| ECONOMY_SUBSYSTEM | PRICING | "Price discovery" |
| CONSTRUCTION_SUBSYSTEM | CONSTRUCTION | "Construction job system" |
| LOGISTICS_SUBSYSTEM | CYCLERS | "Cycler route management" |
| LOGISTICS_SUBSYSTEM | DEPOTS | "Depot logistics coordination" |
| EXPANSION_LOGIC | SETTLEMENTS | "Settlement expansion planning" |
| PATTERN_LEARNING | PRECURSOR_INTELLIGENCE | "Precursor pattern learning" |

### 12. Gameplay → All Systems

| From | To | Context |
|------|-----|---------|
| GAMEPLAY_OVERVIEW | PLANETARY_GAMEPLAY | "Planetary settlement gameplay" |
| GAMEPLAY_OVERVIEW | ORBITAL_GAMEPLAY | "Orbital station gameplay" |
| GAMEPLAY_OVERVIEW | INDUSTRY_GAMEPLAY | "Manufacturing industry gameplay" |
| GAMEPLAY_OVERVIEW | MINING_GAMEPLAY | "Mining operations gameplay" |
| GAMEPLAY_OVERVIEW | TRADING_GAMEPLAY | "Trading loop gameplay" |
| GAMEPLAY_OVERVIEW | TERRAFORMING_GAMEPLAY | "Terraforming gameplay" |
| GAMEPLAY_OVERVIEW | EXPLORATION_GAMEPLAY | "Exploration and discovery" |
| GAMEPLAY_OVERVIEW | PLAYER_PROGRESSION | "Player progression system" |
| PLANETARY_GAMEPLAY | SETTLEMENTS | "Settlement management" |
| PLANETARY_GAMEPLAY | TERRAFORMING | "Planetary terraforming" |
| ORBITAL_GAMEPLAY | ORBITAL_SETTLEMENTS | "Orbital depot management" |
| ORBITAL_GAMEPLAY | CYCLERS | "Cycler transport operations" |
| INDUSTRY_GAMEPLAY | MANUFACTURING | "Manufacturing pipeline" |
| TRADING_GAMEPLAY | ECONOMY | "Economy participation" |
| EXPLORATION_GAMEPLAY | NATURAL_WORMHOLES | "Wormhole exploration" |
| EXPLORATION_GAMEPLAY | CELESTIAL_BODIES | "Celestial body discovery" |
| PLAYER_PROGRESSION | TECHNOLOGY_LEVELS | "Technology progression" |
| PLAYER_PROGRESSION | IMPLEMENTATION_PHASES | "MVP roadmap phases" |

### 13. Development → All Sections

| From | To | Context |
|------|-----|---------|
| DEVELOPMENT_OVERVIEW | ARCHITECTURE | "System architecture" |
| DEVELOPMENT_OVERVIEW | CODING_STANDARDS | "Coding conventions" |
| DEVELOPMENT_OVERVIEW | JSON_STANDARDS | "JSON data standards" |
| DEVELOPMENT_OVERVIEW | NAMING_CONVENTIONS | "Naming conventions" |
| DEVELOPMENT_OVERVIEW | BLUEPRINT_STANDARDS | "Blueprint schema standards" |
| DEVELOPMENT_OVERVIEW | DEVELOPMENT_PHASES | "MVP roadmap" |
| DEVELOPMENT_OVERVIEW | TESTING | "Testing philosophy" |
| DEVELOPMENT_OVERVIEW | AI_WORKFLOW | "AI agent workflow" |
| ARCHITECTURE | DATA_DRIVEN_SYSTEMS | "JSON-driven architecture" |
| ARCHITECTURE | LOOKUP_SERVICES | "Lookup service pattern" |
| ARCHITECTURE | AI_MANAGER_OVERVIEW | "AI Manager orchestration" |
| ARCHITECTURE | ARCHITECTURE_DECISION_LOG | "Architecture decision log" |
| DEVELOPMENT_PHASES | BACKLOG | "Current backlog by phase" |
| TESTING | PRACTICAL_TESTING_GUIDE | "Practical testing guide" |
| AI_WORKFLOW | LLM_AGENT_TASK_PROTOCOL | "Agent task protocol" |

### 14. Reference → All Sections

| From | To | Context |
|------|-----|---------|
| GLOSSARY | TERMINOLOGY | "Detailed terminology" |
| GLOSSARY | GAME_CONSTANTS | "Game constants" |
| GLOSSARY | CROSS_REFERENCES | "Cross-reference map" |
| RESOURCE_LIST | RESOURCES | "Resource types overview" |
| CELESTIAL_BODY_INDEX | CELESTIAL_BODIES | "Celestial bodies overview" |
| BLUEPRINT_INDEX | BLUEPRINTS | "Blueprints overview" |
| JSON_SCHEMAS | BLUEPRINT_STANDARDS | "Blueprint schema standards" |
| CROSS_REFERENCES | START_HERE | "Back to wiki entry point" |

---

## Missing Cross-Links (Current State)

These links do NOT currently exist in the documentation and should be added:

### Economy → Manufacturing
- [ ] ECONOMY_OVERVIEW → MANUFACTURING_OVERVIEW ("Economy depends on manufacturing")
- [ ] PRICING → RESOURCE_PROCESSING ("Raw material processing costs")
- [ ] CONTRACTS → MANUFACTURING ("Manufacturing contracts")

### Manufacturing → Settlements
- [ ] MANUFACTURING_OVERVIEW → SETTLEMENTS ("Manufacturing happens at settlements")
- [ ] CONSTRUCTION → SETTLEMENTS ("Construction requires settlement administration")
- [ ] BLUEPRINTS → STRUCTURES ("Blueprints define constructible structures")

### Simulation → Transportation
- [ ] TERRAFORMING → CYCLERS ("Terraforming materials via cycler transport")
- [ ] BIOME_SYSTEM → ORBITAL_SETTLEMENTS ("Biome distribution via orbital depots")

### Settlements → Economy
- [ ] SETTLEMENTS_OVERVIEW → ECONOMY_OVERVIEW ("Settlements participate in economy")
- [ ] WORLDHOUSES → PRICING ("Worldhouse resource pricing")
- [ ] ORBITAL_SETTLEMENTS → TRADING ("Orbital depot trading opportunities")

### Transportation → Simulation
- [ ] LOGISTICS_NETWORK → TERRAFORMING ("Logistics support terraforming operations")
- [ ] CYCLERS → ATMOSPHERE ("Cycler atmospheric considerations")

### AI Manager → Economy
- [ ] AI_MANAGER_OVERVIEW → NPC_ECONOMY ("AI Manager orchestrates NPC economy")
- [ ] ECONOMY_SUBSYSTEM → MARKET_OPERATIONS ("Economy subsystem manages markets")

### Gameplay → Simulation
- [ ] TERRAFORMING_GAMEPLAY → TERRASIM ("Terraforming gameplay uses TerraSim")
- [ ] EXPLORATION_GAMEPLAY → STARSIM ("Exploration uses StarSim-generated systems")

### Development → All Sections
- [ ] ARCHITECTURE → BIOME_SYSTEM ("Architecture supports biome system")
- [ ] ARCHITECTURE → BLUEPRINTS ("Blueprint lookup service architecture")
- [ ] TESTING → AI_MANAGER_OVERVIEW ("AI Manager testing strategy")

---

## Cross-Link Priority

### Critical (Add First)
1. START_HERE → all section canonical pages
2. ECONOMY_OVERVIEW → MANUFACTURING_OVERVIEW, PRICING, NPC_ECONOMY
3. MANUFACTURING_OVERVIEW → RESOURCES, BLUEPRINTS, CONSTRUCTION
4. SETTLEMENTS_OVERVIEW → COLONIES, STRUCTURES, WORLDHOUSES
5. AI_MANAGER_OVERVIEW → all subsystems + SERVICE_PORTFOLIO
6. GAMEPLAY_OVERVIEW → all gameplay loops

### High (Add Second)
7. SIMULATION_OVERVIEW → STARSIM, TERRASIM, BIOME_SYSTEM, TERRAFORMING
8. TRANSPORTATION_OVERVIEW → CRAFT, STATIONS, CYCLERS, LOGISTICS_NETWORK
9. DEVELOPMENT_OVERVIEW → ARCHITECTURE, TESTING, AI_WORKFLOW
10. GLOSSARY → all canonical pages (via CROSS_REFERENCES)

### Medium (Add Third)
11. Section-to-section links (e.g., Economy → Transportation)
12. Supporting page → canonical page reverse links
13. Game constants references in relevant sections

---

## Cross-Link Implementation Notes

### Link Format
Use relative wiki paths: `[Topic Name](../section/topic-page)`

### First Use Rule
Every key term should link to GLOSSARY on first use in a page:
- "The **GCC** ([glossary#gcc](#)) is the primary currency..."
- "A **Colony** ([settlements/colonies](#)) requires 2+ settlements..."

### Canonical Page Rule
Every supporting page should link to its canonical page at the top:
> "This page supports [Economy Overview](../economy/economy-overview)."

### Cross References Page
The CROSS_REFERENCES page should contain a complete adjacency map:
- Every canonical page listed with all its cross-links
- Searchable by topic name
- Shows which pages link TO it (incoming links)
