# Precursor Mission Bootstrap Architecture
## Architecture Reference

**Settlement Simulation Project — Version 1.0 — March 2026**

*Defines the precursor mission sequence, ISRU bootstrap loop, lava tube construction pattern, and the Sol training data model that teaches the AI Manager repeatable settlement patterns for new worlds.*

*Related services: `AIManager::PrecursorCapabilityService`, `AIManager::TaskExecutionEngine`, `ConstructionJobService`, `ResourceTrackingService`*
*Related files: `data/json-data/missions/npc-base-deploy/`, `data/json-data/missions/lunar-precursor/`*

---

## 1. Purpose

The precursor mission is the robotic phase that runs before humans arrive. Its job is to establish the minimum viable infrastructure that makes human habitation safe and sustainable. No humans land until the precursor phase is complete.

More importantly, Sol (Luna) is the **first training case** for the AI Manager's pattern library. Every decision the AI Manager makes about precursor sequencing on Mars, Titan, Europa, or any new world is informed by what it learned from Luna. The mission phase files and rake task simulations in this codebase are Sol's curriculum — they encode not just what to do but why each step happens in the order it does.

The `AIManager::PrecursorCapabilityService` is the runtime expression of this learning — it queries actual celestial body sphere data (`geosphere.crust_composition`, `atmosphere.composition`, `hydrosphere.water_bodies`) to determine what the bootstrap sequence should look like on any given world, rather than relying on hardcoded world identifiers.

---

## 2. Why the Lava Tube

The lunar base is not built on the surface. It is built inside a lava tube — specifically at a site like the Marius Hills lava tube entrance (14.1°N, 56.8°W as used in the mission profile).

The lava tube provides everything the surface cannot:

- **Radiation shielding** — meters of basalt overhead eliminate the need to construct shielding from scratch
- **Thermal stability** — surface temperatures swing from -173°C to +127°C across the lunar day; the tube interior is stable near -20°C
- **Microimpact protection** — no exposure to the continuous micrometeorite flux on the surface
- **Structural foundation** — geology already provides the enclosure; robots finish it rather than build it

This is a site selection rule, not a coincidence. The `AIManager::PrecursorCapabilityService` and settlement planning logic should prefer lava tube sites on any body where they exist. The sealed lava tube cover blueprints in `data/json-data/blueprints/components/structural/` were designed specifically for this use case.

---

## 3. The Passive Atmosphere Model

The lava tube is **not pressurised on day one**. Depending on tube size, there are not enough extracted gases to fill it. Pressurisation is an emergent property that builds up over time from:

- Airlock cycling losses (small but continuous)
- Unit seal leaks
- Deliberate venting from life support excess
- TEU/PVE off-gassing during processing
- CO2 and water vapor from human activity once crew arrives
- Plant transpiration from greenhouse units

This quasi-atmosphere accumulates passively over months and years. The simulation should track tube atmosphere as a slow accumulation, not a pressurisation event. Every skylight sealed and every leak minimised is atmosphere retained.

**Progression:**
- Early days — full EVA suits required everywhere in the tube
- Months in — partial pressure building, reduced suit requirements in some zones
- Years in — greenhouse zones potentially habitable with supplemental O2
- Long term — tube becomes a pressurised biome as algae bioreactors scale

This is why sealing the skylights is a high-priority early task — not for immediate pressurisation but to minimise loss rate so passive accumulation can build.

---

## 4. The Heavy Lift Launcher

The precursor mission begins with a **Heavy Lift Launcher** landing autonomously at the lava tube site. The craft carries everything needed for the first three phases in its cargo hold. It lands, deploys its robots, and the mission begins.

The craft itself becomes part of the infrastructure — its LOX and CH4 tanks are connected to the gas separator output lines for automated refuelling during the regolith processing phase. This means the craft can return to Earth (or be reused) once the bootstrap loop is running and the second mission lands on the prepared pad.

**Canonical craft:** `Heavy Lift Launcher` (previously referenced as Starship in early concept files — use `Heavy Lift Launcher` in all new files)

**Manifest structure:** `npc_base_deploy_manifest_v3.json` is the most complete reference — Starship naming is legacy and should be updated in production files.

---

## 5. The Bootstrap Sequence

The precursor mission runs in four phases. Each phase has a dependency on the previous — the AI Manager cannot skip ahead. This ordering is the core of what Sol teaches.

### Phase 1 — Initial Power, Comms & ISRU Deployment
*File: `initial_setup_phase_1_v1.1.json`*

The Heavy Lift Launcher lands. Robots deploy in strict priority order:

```
Heavy Lift Launcher lands (autonomous)
  → CAR-300 construction robots deploy (2x)
  → Comms Equipment → uplink established
  → SMR-500 mapping robots deploy → site survey begins
  → HRV-400 resource harvesting robots deploy
  → Planetary Umbilical Hub (PUH) + Power Management Unit deploy + connect
  → RTG deploys → basic power online (continuous, day/night)
  → Solar Expansion Rig + 10x Compact Solar Panels → surface power online
  → Thermal Extraction Unit (TEU) deploys → ready
  → Planetary Volatiles Extractor Mk1 (PVE) deploys → connects to PUH
  → Inflatable tanks deploy (pressure tank, gas storage, cryogenic x3)
  → Mining Harvester deploys → begins harvesting raw regolith
  → Planetary I-Beam Printing Unit deploys → ready
  → Life support units deploy (Water Recycling, CO2/O2 Production, Waste Management)
  → Inflatable Habitat Units deploy (2x) — inside lava tube
  → Inflatable Greenhouse Unit deploys — inside lava tube
  → Maintenance robot (MRR-100) deploys
  → Satellite Batteries deploy (2x) — power storage for lunar night
  → Logistics robot (LTR-100) deploys
```

**Why this order:** Power must precede everything. RTG provides continuous baseline; solar provides peak capacity. TEU and PVE cannot run without power. Inflatables deploy before the shell printer because they need to establish their form before shells are printed over them.

### Phase 2 — Regolith Processing & Shell Fabrication
*File: `initial_regolith_processing_phase_2_v1.5.json`*

The ISRU loop starts running. This is the most critical phase — it produces the depleted regolith that enables all construction.

```
TEU + PVE processing chain verified
  → Gas Separator Unit deploys + connects to PVE output
  → Gas Conversion Unit deploys → Sabatier reactions begin
     (H2 + CO2 → CH4 + H2O — produces methane from extracted gases)
  → Cryogenic tanks deploy (Methane, Oxygen, Water)
  → Gas Separator → Cryo tanks (continuous routing)
  → Gas Separator → Heavy Lift Launcher tanks (automated refuelling)

  ISRU production loop running:
    raw_regolith (10 kg)
      → TEU (thermal baking, ~700-900°C)
      → processed_regolith (9.95 kg) + volatile_gases released
      → PVE (oxide reduction)
      → depleted_regolith (4.85 kg) + gases (0.05 kg) + water (0.10 kg)

  Gas composition from PVE:
    hydrogen:       50%
    carbon_monoxide: 25%
    neon:           20%
    helium-3:        5%

  3D Regolith Shell Printer deploys
    → connects to PUH (power)
    → prints protective shells over ALL inflatable units:
       - inflatable tanks (tank farm)
       - inflatable habitat units
       - inflatable greenhouse unit
       - general-purpose inflatable units
    → shell printing completes → inflatables become permanent hardened structures
```

**Why shell printing happens here:** The inflatables need to be filled enough to hold their form before shells are printed. The TEU/PVE loop produces the depleted regolith that is the shell printer's feedstock. The sequence is therefore: deploy inflatables → run ISRU → inflatables fill and hold shape → print shells → permanent structures established.

**The tank farm:** The inflatable tanks are the primary target of Phase 2 shell printing. Once shelled, they become the permanent gas storage infrastructure that all downstream operations depend on. This is the tank farm.

### Phase 3 — Infrastructure Construction
*File: `infrastructure_construction_phase_3_v1.4.json`*

With the tank farm established and ISRU running, construction of permanent surface infrastructure begins.

```
Shell printer → tank farm shells complete
  → I-Beam Printer → solar array framework fabrication begins
  → Solar array framework complete
  → 10x additional Compact Solar Panels mount to framework
  → Solar array connects to PUH → power grid extended
  → Additional Robot Charging Ports deploy (2x)
  → Surface power capacity significantly increased
```

### Phase 4 — Landing Pad & Lava Tube Preparation
*File: `infrastructure_construction_phase_4_v1.json`*

The critical milestone: prepare the landing pad for the second mission.

```
Power grid stable
  → Lunar Surface Preparation Unit (LSPU) deploys
  → Landing pad site: dust mitigation + surface smoothing
  → Landing pad prepared ✓  ← SECOND MISSION CAN NOW LAND

Inside lava tube:
  → I-Beam Printer → nitrogen tank mount structure
  → CAR-300 robots assemble nitrogen tank mount
  → CAR-300 robots prepare habitat floor sites inside tube
  → I-Beam production starts (continuous) → standard_i_beam stock accumulates
  → SMR-500 surveys lava tube skylights → skylight survey report generated
  → Skylight framework construction begins (consumes standard_i_beams)
  → Transparent panels + regolith panels → skylight sealing begins
```

**Why the landing pad is Phase 4 not Phase 1:** The surface preparation unit needs the power grid extended (Phase 3) to operate efficiently. More importantly, by Phase 4 the ISRU loop is running and producing depleted regolith — the landing pad surface can be stabilised with printed regolith panels, not just smoothed.

---

## 6. The ISRU Bootstrap Loop

The ISRU chain is the engine that makes everything else possible. It converts local rock into construction material, propellant, and eventually life support gases.

```
raw_regolith
  ↓ TEU (Thermal Extraction Unit — bakes at ~700-900°C)
  → processed_regolith + volatile_gases (CO2, H2O, SO2 released)
  ↓ PVE (Planetary Volatiles Extractor — oxide reduction)
  → depleted_regolith + oxygen + raw_gases

depleted_regolith
  → Shell Printer → inflatable shells → tank farm + hardened structures
  → I-Beam Printer → structural I-beams → frameworks + skylight supports
  → Panel Printer → regolith panels + transparent panels → skylight sealing

raw_gases + oxygen
  → Gas Separator → sorted gas streams
  → Gas Conversion Unit (Sabatier) → CH4 + H2O from H2 + CO2
  → Cryogenic tanks → LOX, LCH4, LN2 storage
  → Heavy Lift Launcher refuelling (automated)
  → Tank farm → reserve for second mission + ongoing operations
```

**Production ratios (from `LunarBaseProductionService`):**
- TEU: 10 kg raw regolith → 9.95 kg processed regolith
- PVE: 5 kg processed → 4.85 kg depleted regolith + 0.10 kg water + 0.05 kg gases
- I-beam production: depleted regolith is primary input material

---

## 7. Printed Components

The shell printer and I-beam printer produce distinct component types from depleted regolith:

| Component | Printer | Primary Use | Blueprint Reference |
|---|---|---|---|
| `regolith_shell` | 3D Regolith Shell Printer | Hardens inflatable units | `3d_regolith_shell_bp.json` |
| `standard_i_beam` | Planetary I-Beam Printing Unit | Structural frameworks, skylight supports | `3d_printed_ibeam_mk1_bp.json` |
| `regolith_panel` | 3D Regolith Shell Printer | Opaque wall/floor/divider panels | structural blueprints |
| `transparent_panel` | 3D Regolith Shell Printer | Skylight glazing, light transmission | structural blueprints |
| `structural_framework` | I-Beam Printer + CAR-300 assembly | Solar arrays, tank mounts, habitat frames | structural blueprints |

**Transparent panels:** Lunar regolith contains sufficient silica that sintering at high temperature (already achieved by the TEU process) can produce glass-like material. The TEU process feeds directly into transparent panel production as a secondary capability.

---

## 8. Industrial Expansion
*File: `npc_base_deploy_industrial_expansion_v1.json`*

Once the second mission lands and the base transitions from precursor to operational, industrial expansion begins. This phase transitions the base from survival mode to economic participation.

```
Additional TEU units (×2 → 3 total) → increased throughput
Additional PVE units (×2 → 3 total) → increased volatile extraction
Material Refining Plant → lunar metals + alloy production
3D Printing Factory → large structural components + ship modules
Storage farm expansion → Cryogenic + pressurised tanks (×8)
Automated cargo handling → logistics efficiency
Surface transport network → mining ↔ processing ↔ manufacturing zones
L1 station module manufacturing begins
Power expansion → 20x additional solar panels + energy storage
Atmosphere control units → support increased personnel
Venus + Titan harvester supply chain integration
```

At this point the base is no longer consuming Earth imports for basic materials — it is producing surplus and beginning to export (He-3, lunar samples, refuelling services).

---

## 9. What Sol Teaches the AI Manager

Sol is training data. The mission phase sequence encodes the decision logic that `AIManager::PrecursorCapabilityService` and `AIManager::TaskExecutionEngine` generalise to new worlds.

**The invariant pattern (applies everywhere):**
1. Establish power (RTG baseline + local generation)
2. Establish comms
3. Survey site → identify local resources
4. Deploy ISRU chain matched to local geology/atmosphere
5. Produce depleted construction material → begin building permanent structures
6. Build tank farm → store extracted gases/propellants
7. Prepare landing pad → enable second mission
8. Scale life support → enable human habitation

**World-specific adaptations the AI Manager learns:**

| Factor | Luna | Mars | Titan | Europa |
|---|---|---|---|---|
| Natural shelter | Lava tube — primary | Canyon/crater — partial | Dense atmosphere — surface viable | Subsurface ocean — surface only |
| Atmosphere | None → passive accumulation | Thin CO2 — already present | Dense N2/CH4 — abundant | None |
| TEU priority | Critical — only volatile source | Moderate — atmosphere supplements | Low — atmosphere abundant | High — ice processing |
| PVE priority | Critical — only O2 source | Supplemental — CO2 electrolysis available | Low | High — water electrolysis |
| Shell printing | Day 1 — primary construction method | Day 1 — dust/radiation hardening | Modified — different feedstock | Modified — ice-based |
| Water source | Polar ice — import or harvest | Subsurface ice + atmospheric | Lakes + atmospheric | Subsurface ocean |
| Pressurisation | Years — passive accumulation | Faster — CO2 base exists | Different atmospheric chemistry | Not applicable surface |
| He-3 export | High value — strategic | Trace | Present | Trace |

**The `PrecursorCapabilityService` data sources:**
- `CelestialBody.atmosphere.composition` — determines atmospheric ISRU capability
- `CelestialBody.geosphere.crust_composition` — determines surface mining + TEU/PVE outputs
- `CelestialBody.hydrosphere.water_bodies` — determines water extraction viability

These three queries replace all hardcoded world logic. A world the AI Manager has never seen before gets a precursor sequence assembled from the same building blocks Sol taught it — adapted to whatever the sphere data says is actually there.

---

## 10. Handoff State — Second Mission Arrival

The precursor phase is complete and the second mission can land when:

- [ ] Landing pad prepared and stable
- [ ] Power grid online and stable (RTG + solar)
- [ ] Comms uplink active
- [ ] Tank farm operational — LOX, LCH4, LN2 in storage
- [ ] Heavy Lift Launcher refuelled for return or reuse
- [ ] At least 2x inflatable habitat units shell-hardened and verified sealed
- [ ] Water Recycling Unit operational
- [ ] CO2/O2 production unit operational
- [ ] Waste Management unit operational
- [ ] Lava tube skylight survey complete
- [ ] Skylight framework construction begun

The second mission brings additional crew, expansion units, and supplies. It connects to the existing power grid and tank farm immediately on landing. The ISRU loop has been running for weeks or months by this point — depleted regolith is accumulating, gas storage is building, and the AI Manager has real production data to inform its economic planning.

---

## 11. File Reference

| File | Purpose | Status |
|---|---|---|
| `npc_base_deploy_manifest_v3.json` | Most complete manifest — Starship naming is legacy, use Heavy Lift Launcher | Concept — update naming |
| `npc_base_deploy_manifest_v1_interplanetary_enhanced.json` | Enhanced manifest with Titan/Venus processing infrastructure | Concept |
| `npc_base_deploy_profile_v1.1.json` | Mission profile — 3 phases | Concept |
| `initial_setup_phase_1_v1.1.json` | Phase 1 task list | Concept — drives implementation |
| `initial_regolith_processing_phase_2_v1.5.json` | Phase 2 task list | Concept — drives implementation |
| `infrastructure_construction_phase_3_v1.4.json` | Phase 3 task list | Concept — drives implementation |
| `infrastructure_construction_phase_4_v1.json` | Phase 4 task list | Concept — drives implementation |
| `npc_base_deploy_industrial_expansion_v1.json` | Industrial expansion phase | Concept |
| `lunar_base_pipeline.rake` | Rake simulation — basic pipeline | Legacy — may not run |
| `lunar_base_with_isru_pipeline.rake` | Rake simulation — with ISRU production ratios | Reference for production ratios |
| `app/services/ai_manager/precursor_capability_service.rb` | Runtime world adaptation | Implemented ✅ |
| `app/services/ai_manager/task_execution_engine.rb` | Mission phase executor | Implemented ✅ |
| `app/services/construction/construction_job_service.rb` | Construction job management | Implemented ✅ |

---

## 12. Relationship to Other Architecture Docs

- **`life_support_waste_recycling_architecture.md`** — defines the life support units deployed in Phase 1 (Water Recycling, CO2/O2 Production, Waste Management, Inflatable Greenhouse). The precursor mission is the upstream context for when and why these units deploy.
- **`terraforming_vs_engineered_worlds_architecture.md`** — the long-term vision the precursor mission is building toward. Precursor → settlement → terraforming is the progression.
- **`layer_architecture_exotic_bodies.md`** — defines how different body types affect what ISRU is possible; informs the world adaptation table in Section 9.
- **`PRECURSOR_CAPABILITY_SERVICE.md`** — implementation detail for the service that operationalises Section 9.
- **`AI_MANAGER_CONSTRUCTION_ECONOMICS.md`** — LDC funds the precursor mission via virtual ledger; AstroLift provides the Heavy Lift Launcher logistics.

---

*This document represents the canonical precursor mission narrative. The JSON phase files and rake tasks are the source of truth for task sequencing — this document explains the reasoning behind that sequence and how Sol generalises to new worlds.*
*Update this document when the phase sequence changes, new world patterns are added, or the handoff criteria are revised.*
