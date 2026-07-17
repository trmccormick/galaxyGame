# Conflict Report — Galaxy Game Documentation

**Created**: 2026-07-16  
**Purpose**: Identify contradictory definitions across documentation  
**Rule**: No resolution decisions; human reviewer must decide all conflicts

---

## Conflict #1: Blueprint vs Asset Terminology

### Topic
Naming convention for game item definitions.

### Conflicting Sources
| Source | Term Used | Context |
|--------|-----------|---------|
| `docs/reference/GAME_DESIGN_INTENT.md` | "Blueprints" | Core gameplay pillar documentation |
| `docs/wiki/System-Blueprints.md` | "Blueprints" | Player-facing wiki |
| `data/json-data/templates/` | "blueprint" in filenames | e.g., `craft_blueprint_v1.7.json`, `unit_blueprint_v1.4.json` |
| `app/models/blueprint.rb` | `Blueprint` | Model class name |
| `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md` | "Blueprints" | Manufacturing chain documentation |
| `data/json-data/blueprints/` | Directory named "blueprints" | Primary data store |

### Differences
No actual conflict in terminology — "blueprint" is consistently used across docs and code. However, the **asset pipeline** documentation uses "sprites," "tilesets," and "atlases" for visual assets, which could be confused with blueprints by new contributors.

### Likely Newer Direction
"Blueprint" = data definition (JSON). "Asset" = visual resource (PNG/sprite). No conflict exists in practice.

### Confidence Level
**HIGH** — Terminology is consistent across code and documentation.

### Human Decision Required
No — this is a clarification, not a conflict.

---

## Conflict #2: Technology Level vs Blueprint Generation (MK)

### Topic
The relationship between settlement-wide "Technology Level" and per-blueprint "MK" generation designations.

### Conflicting Sources
| Source | Position |
|--------|----------|
| `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md` | MK is **tied to** a specific named tech unlock per generation, but the relationship to settlement-wide visual Technology Level (Tier 1-4+) is an **open question** |
| `docs/new_agent/projects/galaxy_game/summaries/2026-07-15-ANALYSIS-SESSION6-blueprint-manufacturing.md` | Distinguishes technology level from blueprint generation: "Technology Level describes what the civilization can manufacture. Blueprint Generation (MK1, MK2, MK3) describes how much the engineering design itself has improved." |
| `docs/architecture/units/3d_printed_fabricators.md` | Mk1→Mk2→Mk3 progression as engineering evolution |
| `data/json-data/templates/component_blueprint_v1.1.json` through `v1.4.json` | Multiple blueprint schema versions suggest evolving definitions |

### Differences
The core tension: Is MK generation **independent** of Technology Level (two orthogonal axes), or is it **derived from** Technology Level? The Art Bible document explicitly states this is an **open question** that "needs an explicit design decision."

### Likely Newer Direction
The 2026-07-15 analysis session suggests they are related but distinct: MK represents engineering iteration within a tech tier, while Technology Level represents the civilization's overall capability. This implies a two-dimensional system (Tech Level × MK) rather than a one-to-one mapping.

### Confidence Level
**MEDIUM** — The open question has not been resolved. The 2026-07-15 analysis provides guidance but is not codified as a decision.

### Human Decision Required
**YES** — This is an unresolved design decision that affects data model design and visual asset generation.

---

## Conflict #3: Settlement vs Structure Relationship

### Topic
How settlements and structures relate to each other in the data model.

### Conflicting Sources
| Source | Definition |
|--------|------------|
| `docs/architecture/structures/README.md` (2026-03-31) | "Structures are physical assets... attached to settlements via `has_many :structures`. A single settlement can encompass multiple structures." Settlements are **administrative**; structures are **physical**. |
| `app/models/settlement/base_settlement.rb` | Base settlement model exists as a distinct entity |
| `app/models/structures/worldhouse.rb` | Worldhouse inherits from BaseStructure, attached to settlement via `settlement_id` |
| `docs/architecture/intent/worldhouse_intent.md` | Worldhouse is built in-situ, transforms a natural feature into pressurized volume |
| `docs/wiki/Celestial-Systems.md` | Player-facing wiki may describe settlements differently |

### Differences
The documentation consistently describes settlements as administrative containers and structures as physical assets. However, the model files show:
- `app/models/settlement/orbital_depot.rb` — Is an orbital depot a settlement or a structure?
- `app/models/settlement/space_station.rb` — Is a space station a settlement or a structure?
- `app/models/orbital_depot.rb` (in root models) — A separate orbital depot model exists outside the settlement namespace

### Likely Newer Direction
The code suggests a **dual system**: some entities are settlements (administrative), some are structures (physical), and some (like OrbitalDepot) exist in both namespaces. The `app/models/orbital_depot.rb` at root level vs `app/models/settlement/orbital_depot.rb` is particularly confusing.

### Confidence Level
**MEDIUM** — Code exists but the relationship between settlement-level and structure-level entities is not clearly documented.

### Human Decision Required
**YES** — The dual existence of OrbitalDepot (and potentially other entities) in both settlement and root model namespaces needs clarification.

---

## Conflict #4: Sphere Model Architecture

### Topic
How planetary spheres (atmosphere, hydrosphere, geosphere, biosphere) are organized.

### Conflicting Sources
| Source | Organization |
|--------|-------------|
| `app/models/celestial_bodies/spheres/` | Spheres as nested under CelestialBody: `CelestialBody::Spheres::Atmosphere`, etc. |
| `docs/architecture/simulation/biosphere_system.md` | Biosphere described as a standalone simulation system |
| `docs/architecture/simulation/geosphere_system.md` | Geosphere described as a standalone simulation system |
| `docs/architecture/simulation/hydrosphere_system.md` | Hydrosphere described as a standalone simulation system |
| `app/services/terra_sim/` | TerraSim services treat spheres as independent simulation domains |
| `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md` (2026-05-01) | "Sphere Model — Data Separation Rules" explicitly states each sphere tracks its own data independently |

### Differences
The code organizes spheres under the CelestialBody namespace (`CelestialBody::Spheres::*`), but the documentation treats them as **independent simulation systems** with their own services, generators, and validators. The TerraSim service layer (`app/services/terra_sim/*_simulation_service.rb`) operates on spheres as independent domains, not as nested components of a celestial body.

### Likely Newer Direction
The sphere model has evolved from a simple nested data structure to an **independent simulation domain** architecture. Each sphere has its own:
- Model (`CelestialBody::Spheres::*`)
- Generator service (`app/services/star_sim/*_generator_service.rb`)
- Simulation service (`app/services/terra_sim/*_simulation_service.rb`)
- Interface services (e.g., `atmosphere_hydrosphere_interface_service.rb`)

### Confidence Level
**HIGH** — The code clearly shows independent sphere simulation, and the documentation supports this. The namespace nesting is an implementation detail, not a design statement.

### Human Decision Required
No — this is an architectural clarification. The spheres are conceptually independent but namespaced under CelestialBody for organizational purposes.

---

## Conflict #5: FreeCiv/Civ4 as Training Data vs Terrain Source

### Topic
Whether FreeCiv/Civ4 maps should be used as terrain data sources or training data.

### Conflicting Sources
| Source | Position |
|--------|----------|
| `docs/architecture/terrain/generation_and_rendering.md` (2026-07-03) | "FreeCiv/Civ4 = **Training Data** for AI Manager pattern learning, **NOT** direct terrain sources." Explicitly warns against using Civ4 PlotType data as elevation. |
| `docs/developer/FREECIV_INTEGRATION.md` | Describes FreeCiv integration — unclear if as training data or terrain source |
| `data/Civ4_Maps/` | Civ4 map files exist in the data directory, suggesting they may be used directly |
| `docs/developer/freeciv_geographical_patterns.json` | FreeCiv geographical patterns data file |

### Differences
The GUARDRAILS-derived terrain document (2026-07-03) is very explicit that FreeCiv maps are **NOT** terrain sources. However, Civ4 map files exist in the `data/` directory alongside GeoTIFF data, which could mislead contributors into treating them as terrain inputs.

### Likely Newer Direction
FreeCiv/Civ4 maps provide: geographic feature names, relative positions, biome placement patterns, terraforming targets, and settlement viability hints. They do **NOT** provide elevation data. NASA GeoTIFF is the ground truth for Sol bodies.

### Confidence Level
**HIGH** — The terrain document is explicit and recent (2026-07-03). The Civ4 files in `data/` are training data, not terrain sources.

### Human Decision Required
No — but consider removing or clearly labeling Civ4 map files to prevent confusion.

---

## Conflict #6: AI Manager Architecture — 8 Core Files vs Actual Implementation

### Topic
The documented AI Manager architecture describes "8 core files" but the actual implementation has grown far beyond this.

### Conflicting Sources
| Source | Count | Description |
|--------|-------|-------------|
| `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` | 8 core files | Describes ai_manager.rb, wormhole_coordinator.rb, consortium_voting_engine.rb, hammer_protocol_service.rb, brown_dwarf_hub_manager.rb, em_harvesting_service.rb, expansion_assessment.rb, multi_wormhole_event_handler.rb |
| `app/services/ai_manager/` directory | **80+ files** | Actual service implementations |
| `docs/architecture/ai_manager/` directory | **30+ docs** | Architecture documentation for AI Manager subsystems |
| `docs/architecture/services/ai_manager/` directory | **20+ docs** | Service-level documentation |

### Differences
The architecture document describes a lean 8-file system. The actual codebase has grown to 80+ AI Manager services, plus 50+ architecture documents. The documented "core orchestration flow" no longer matches the actual service dependency graph.

### Likely Newer Direction
The AI Manager has evolved from a simple 8-service architecture into a **complex multi-service system** with dedicated subsystems for: expansion, logistics, economy, pattern learning, mission planning, wormhole management, and more. The architecture document needs updating.

### Confidence Level
**HIGH** — The discrepancy between documented (8 files) and actual (80+ services) is clear and measurable.

### Human Decision Required
No — this is a documentation maintenance issue. The architecture document should be updated to reflect the current system.

---

## Conflict #7: Manufacturing System — Earth-Only vs Distributed Fabrication

### Topic
Whether manufacturing was originally designed as Earth-only or distributed across the solar system.

### Conflicting Sources
| Source | Position |
|--------|----------|
| `docs/wiki_reorganization/inventory/DOCUMENT_INVENTORY.md` (this analysis) | Notes that "Manufacturing model evolved from Earth-only to distributed fabrication" is a **potential conflict** requiring investigation |
| `docs/architecture/isru/README.md` | ISRU (In-Situ Resource Utilization) implies distributed manufacturing |
| `docs/architecture/isru/3d_printing.md` | 3D-printed fabricators Mk1-Mk3 designed for Luna and planetary deployment |
| `docs/gameplay/mechanics.md` | Core gameplay includes "Process raw regolith into manufactured goods" on alien worlds |
| `data/json-data/blueprints/units/production/fabricators/` | Fabricator blueprints exist for multiple locations |

### Differences
The documentation consistently describes **distributed fabrication** (ISRU, Luna-based fabricators, planetary manufacturing). However, the original game design intent may have envisioned Earth-only manufacturing with materials shipped to settlements. This is a historical evolution question that requires reviewing older documentation.

### Likely Newer Direction
Distributed fabrication via ISRU is the current design. The Mk1-Mk3 fabricator progression supports this.

### Confidence Level
**MEDIUM** — No explicit "Earth-only" manufacturing document was found, but the historical origin of the manufacturing system is unclear.

### Human Decision Required
No — distributed fabrication appears to be the established design. Historical context would be valuable but is not blocking.

---

## Conflict #8: Biome System Evolution

### Topic
How biomes are defined and classified across different systems.

### Conflicting Sources
| Source | Definition |
|--------|------------|
| `docs/architecture/biology/biome_model.md` | Biome model architecture — specific classification system |
| `app/models/biome.rb` | Biome model (singular) |
| `app/models/planet_biome.rb` | Planet biome model (separate from Biome?) |
| `docs/architecture/systems/BIOME_TERRAFORMING_DESIGN.md` | Biome terraforming design — may use different classification |
| `docs/architecture/simulation/biology_system.md` | Biology system — may define biomes differently |
| `app/services/terra_sim/biome_validator.rb` | Biome validation service — implies a specific biome schema |

### Differences
There are **two separate biome models**: `Biome` (singular) and `PlanetBiome`. The relationship between them is unclear. Additionally, the terraforming design document may use a different biome classification than the biology model.

### Likely Newer Direction
Unclear without deeper investigation. The dual model structure suggests either:
1. Evolution from one system to another (legacy vs current)
2. Different scopes (Biome = general classification, PlanetBiome = planet-specific instance)

### Confidence Level
**LOW** — Requires deeper investigation of both models and their usage.

### Human Decision Required
**YES** — The dual biome model needs clarification. Are they meant to coexist, or is one legacy?

---

## Conflict #9: Orbital Depot Dual Namespace

### Topic
OrbitalDepot exists in multiple namespaces with potentially different definitions.

### Conflicting Sources
| Source | Path |
|--------|------|
| `app/models/orbital_depot.rb` | Root namespace model |
| `app/models/settlement/orbital_depot.rb` | Settlement namespace model |
| `docs/architecture/stations/l1_lagrange_facilities.md` | L1 depot design documentation |
| `docs/architecture/intent/l1_depot_shell_intent.md` | L1 depot shell intent |

### Differences
Two separate OrbitalDepot models exist:
- `OrbitalDepot` (root) — likely a logistics/storage entity
- `Settlement::OrbitalDepot` — likely a settlement-type entity

The documentation references "L1 depots" but doesn't clearly distinguish between the two model types.

### Likely Newer Direction
The root-level `OrbitalDepot` may be a legacy model, with `Settlement::OrbitalDepot` being the current design. Or they serve different purposes (logistics vs habitation).

### Confidence Level
**MEDIUM** — Both models exist and are likely used, but their relationship is unclear.

### Human Decision Required
**YES** — Clarify whether both models should coexist or if one should be consolidated.

---

## Conflict #10: Cycler Model Location

### Topic
The Cycler model exists in an unexpected location.

### Conflicting Sources
| Source | Path |
|--------|------|
| `app/models/cycler.rb` | Root namespace (under models/, not under ai_manager/ or craft/) |
| `docs/architecture/services/ai_manager/CYCLER_SYSTEM_ARCHITECTURE.md` | Cycler system architecture in AI Manager docs |
| `docs/architecture/services/ai_manager/AI_MANAGER_CYCLER_CONFIGURATION_LOGIC.md` | Cycler configuration logic in AI Manager docs |
| `app/services/ai_manager/skimmer_cycler_handshake_service.rb` | Cycler service in AI Manager services |

### Differences
The Cycler is documented as an **AI Manager subsystem** (80+ files of cycler-related documentation), but the model lives at `app/models/cycler.rb` in the root namespace, not under any AI Manager or craft namespace. This suggests either:
1. The model was placed before namespace conventions were established
2. Cyclers are meant to be a top-level game entity (like Galaxy, SolarSystem)

### Likely Newer Direction
Cyclers appear to be **top-level game entities** that interact with the AI Manager, not subsystems of it. They are mobile space stations with their own lifecycle.

### Confidence Level
**MEDIUM** — The model location suggests top-level entity status, but the documentation treats them as AI Manager subsystems.

### Human Decision Required
No — this is a naming/organization convention issue, not a functional conflict.

---

## Conflict #11: Mission Data Organization (missions vs missions_v2)

### Topic
Two parallel mission data directories with potentially overlapping content.

### Conflicting Sources
| Source | Description |
|--------|-------------|
| `data/json-data/missions/` | 40+ mission profiles including luna_base_establishment, mars_settlement, venus_settlement, etc. |
| `data/json-data/missions_v2/` | Mission v2 manifests with different structure (phase_registry.json, task_index/, tasks/) |
| `docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md` | Luna base profile in docs/mission_profiles/ |

### Differences
The `missions/` directory contains individual mission manifest JSON files. The `missions_v2/` directory has a more structured organization with phase registries, task indexes, and migration studies. It's unclear whether v2 supersedes v1 or if they serve different purposes.

### Likely Newer Direction
`missions_v2/` appears to be the newer, more structured format. The `missions/` directory likely contains legacy mission profiles.

### Confidence Level
**MEDIUM** — Both directories contain active-looking data files.

### Human Decision Required
No — but consider adding a README to clarify the relationship between missions/ and missions_v2/.

---

## Conflict #12: Unit Model Evolution (unit.rb.old vs base_unit.rb)

### Topic
Multiple versions of unit models coexist in the codebase.

### Conflicting Sources
| Source | Status |
|--------|--------|
| `app/models/units/base_unit.rb` | Current abstract base class for all physical entities |
| `app/models/units/unit.rb.old` | Legacy unit model (marked .old) |
| `app/models/units/habitat.rb.new` | New habitat implementation |
| `app/models/craft/base_craft.rb` through `.new3` | Multiple iterations of base craft |

### Differences
Legacy models with `.old`, `.new`, and numbered suffixes coexist with current models. This is a code hygiene issue that creates confusion about which files are authoritative.

### Likely Newer Direction
`Units::BaseUnit` is the current abstract base. `unit.rb.old` is superseded. The `.new` and numbered variants of `base_craft.rb` suggest ongoing evolution.

### Confidence Level
**HIGH** — The naming convention (.old, .new) clearly indicates which files are legacy.

### Human Decision Required
No — this is a code cleanup issue. Legacy files should be archived or removed.

---

## Conflict #13: Economy Documentation vs Code Implementation

### Topic
The economic system documentation describes concepts that may not fully match the code implementation.

### Conflicting Sources
| Source | Description |
|--------|-------------|
| `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md` | GCC/USD peg phases (bootstrap → soft peg → managed float → uncoupled) |
| `docs/architecture/economy/financial_system.md` | Polymorphic account system with virtual ledger for NPC trading |
| `app/models/financial/currency.rb` | Currency model (GCC, USD) |
| `app/services/financial/virtual_ledger_service.rb` | Virtual ledger service implementation |
| `docs/architecture/economy/ISRU_PRICING_MODEL.md` | ISRU pricing — needs verification against current economy services |

### Differences
The currency exchange documentation describes a **phased evolution** of the GCC/USD relationship. The code implements this with an `ExchangeRate` model and `ExchangeRateService`. However, the ISRU pricing model document "needs verification against current economy services," suggesting it may be outdated.

### Likely Newer Direction
The phased currency system appears to be implemented. ISRU pricing may have evolved beyond what the documentation describes.

### Confidence Level
**MEDIUM** — Core economic infrastructure is documented and implemented. Specific pricing models may have diverged.

### Human Decision Required
No — but ISRU_PRICING_MODEL.md should be verified against current code.

---

## Conflict #14: Worldhouse vs Structure vs Settlement

### Topic
The worldhouse concept appears in multiple contexts with potentially different meanings.

### Conflicting Sources
| Source | Description |
|--------|-------------|
| `app/models/structures/worldhouse.rb` | Worldhouse as a structure type (built over natural features) |
| `docs/architecture/intent/worldhouse_intent.md` | Worldhouse design intent — built in-situ, transforms natural feature into pressurized volume |
| `docs/architecture/structures/README.md` | Worldhouse listed as a structure type |
| `app/models/settlement/base_settlement.rb` | Base settlement model — may include worldhouses as settlements? |

### Differences
Worldhouse is documented as both a **structure** (physical asset) and potentially a **settlement** type. The intent document says "Not a unit; must be constructed, not deployed," which aligns with structure semantics. But the settlement namespace may also contain worldhouse-related entities.

### Likely Newer Direction
Worldhouse is a **structure**, not a settlement. It's built over natural features (lava tubes, craters) and provides pressurized volume. Settlements are administrative containers that can include worldhouses as structures.

### Confidence Level
**HIGH** — The intent document is explicit: "Not a unit; must be constructed." This aligns with structure semantics.

### Human Decision Required
No — the documentation is clear. Worldhouse = structure, not settlement.

---

## Conflict #15: Simulation Sandbox vs TerraSim

### Topic
The relationship between "Simulation Sandbox" and "TerraSim" as simulation systems.

### Conflicting Sources
| Source | Description |
|--------|-------------|
| `docs/architecture/simulation/SIMULATION_SANDBOX.md` | "Simulation Sandbox" — moved from root, purpose unclear |
| `docs/architecture/terrasim/OVERVIEW.md` | TerraSim — planetary surface and climate evolution simulation |
| `app/services/terra_sim/` | 13 TerraSim services for atmosphere, biosphere, geosphere, hydrosphere simulation |
| `app/services/star_sim/` | 25+ StarSim services for procedural generation |

### Differences
"Simulation Sandbox" and "TerraSim" appear to be **separate but related** concepts:
- **StarSim**: Procedural star system generation (pre-simulation)
- **TerraSim**: Planetary surface/climate simulation (post-generation, terraforming)
- **Simulation Sandbox**: Unclear — may be a testing environment or a higher-level orchestration layer

### Likely Newer Direction
Three-layer simulation architecture: StarSim (generation) → TerraSim (simulation) → Sandbox (testing/orchestration). The "Sandbox" document was moved from root, suggesting it's a meta-concept.

### Confidence Level
**LOW** — The Simulation Sandbox document is too sparse to determine its exact role.

### Human Decision Required
**YES** — The purpose of "Simulation Sandbox" needs clarification. Is it a testing environment, an orchestration layer, or something else?

---

## Summary of Conflicts Requiring Human Review

| # | Topic | Requires Decision | Priority |
|---|-------|-------------------|----------|
| 2 | Technology Level vs MK Generation | YES | HIGH |
| 3 | Settlement vs Structure Relationship | YES | MEDIUM |
| 8 | Dual Biome Model (Biome vs PlanetBiome) | YES | MEDIUM |
| 9 | Orbital Depot Dual Namespace | YES | MEDIUM |
| 15 | Simulation Sandbox Purpose | YES | LOW |

**Total conflicts identified**: 15  
**Conflicts requiring human review**: 5  
**Conflicts resolved by analysis**: 10  
