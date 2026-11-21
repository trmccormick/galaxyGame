# Terraforming Options

> **Code Alignment Status:** `PARTIALLY VERIFIED`  
> *Last Audited:* 2026-11-21  
> *Audit Summary:* Raw atmospheric intake composition was cross-checked against the current `TerraSim::AtmosphericTransferService`; this does not verify the complete terraforming option set, economics, limits, or production cargo workflow.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-21 (Venus atmospheric industry scope clarified)  
**Related**: [surface_habitat_options.md](surface_habitat_options.md), [power_options.md](power_options.md), [ai_manager_economic_loops.md](../logistics/ai_manager_economic_loops.md), [modular_orbital_panel_swarms.md](modular_orbital_panel_swarms.md), settlement and logistics pages

This page is the wiki home for planetary-scale atmosphere modification options. Multiple pathways exist. A fast raw-gas pressure rise is primarily a **protection** measure for population and infrastructure. Traditional terraforming (climate and biosphere goals) and refined composition control are separate, later choices. Softer longer-horizon approaches remain available.

All content is **DIRECTION** or **OPEN** unless marked otherwise.

---

## Design Principles

1. Full traditional terraforming is optional and gated. Early footholds and surface habitats do not require a finished planetary atmosphere.
2. Raising ambient pressure can be pursued first as a protection and risk-reduction measure for people and infrastructure.
3. Multiple sourcing strategies exist. The AI Manager (and players) evaluate cost, time, capital, and risk.
4. Venus pressure relief and Mars volatile deficit form a natural pairing, but other sources (Titan, KBOs, local extraction) remain available.
5. Realistic logistics apply: boil-off, transit loss, alignment windows, fuel for skimmers, and infrastructure bootstrapping all matter.
6. Trade remains bidirectional even when mass flow is heavily one-way.
7. Natural atmospheric escape is an ongoing resource loss; retention and optional recovery technologies can complement replenishment and harvesting. This is an available path, not a mandatory terraforming prerequisite (see [Atmospheric Escape, Retention & Recovery](atmospheric_escape_and_recovery.md)).

---

## Raw Atmospheric Gas Transfer (Pressure-First Protection)

**DIRECTION**

A faster path whose primary purpose is **protection of population and infrastructure**, not traditional terraforming.

Raising ambient surface pressure reduces a set of environmental hazards (thermal extremes, dust mobility, suit/habitat differential stress, and related operational risk). Composition tuning, greenhouse optimization, and full climate/biosphere terraforming remain later optional stages.

### Pipeline
1. Skimmers harvest the **actual current Venusian atmospheric mixture** in the upper benign layers. Intake is proportional to the source atmosphere's current composition; it is not a CO₂/N₂-only or fixed-recipe collection step. CO₂ and N₂ may be important constituents, but the captured batch must retain the proportions represented by the atmosphere at extraction time. See [Skimmers & Mixed Volatiles](../logistics/skimmer_and_mixed_volatiles.md).
2. Gas is processed only as far as needed for mass-driver launch (compression / liquefaction or dense packaging).
3. Mass drivers fire the raw or minimally processed gas payloads toward Mars on alignment windows.
4. Artificial magnetosphere (or L1 shield) must already be active so the injected gas is not stripped by solar wind. The magnetosphere is independent progressive infrastructure and does not require relocating Phobos or Deimos (see [artificial_magnetosphere.md](artificial_magnetosphere.md)).
5. Gas is captured into the Martian atmosphere, raising total pressure.

### Characteristics
- Lower processing complexity on Venus than the refined O₂/N₂ + CNT method.
- Faster pressure gains once mass drivers and magnetosphere are online.
- Primary goal is protective pressure, not immediate Earth-like composition or climate.
- Composition is “whatever Venus supplies” initially; later stages can tune ratios, add greenhouse agents, or adjust oxygen fraction if traditional terraforming is chosen.
- Still requires the same magnetosphere prerequisite and mass-driver infrastructure.
- Venus excess pressure still makes losses tolerable.

This option lets a settlement reach useful protective pressure thresholds without committing to full terraforming.


### Intake composition and implementation boundary

**Owner-confirmed direction (2026-11-18):** atmospheric skimmers intake the source body's actual current gas mixture in proportion to its composition. This applies to Venus as well as other atmospheric sources; the mixture can change as extraction, processing, exhaust, venting, and other atmospheric changes alter the source. The raw intake must not be described as a fixed Venus recipe or as selective CO₂/N₂ collection. Selection and separation happen only in downstream processing where the installed equipment supports them.

**Code cross-check (main branch, inspected 2026-11-21):** `TerraSim::AtmosphericTransferService#perform_raw_transfer` iterates the source atmosphere's gas records and extracts each in proportion to its recorded percentage. The same service also contains separate selective and processed modes. Its raw mode currently applies hard-coded source-name extraction limits (Venus: no percentage cap; Titan: 5%; other bodies: 20%), and writes the delivered gases directly into a target body's atmosphere at a default 98% transfer efficiency. That is existing implementation behavior, not confirmation that those limits or direct atmosphere-to-atmosphere delivery are the approved skimmer cargo workflow. The generic transfer boundary, extraction-limit policy, loss accounting, and craft mixed-volatiles cargo integration remain separate design/implementation questions; see [Skimmers & Mixed Volatiles](../logistics/skimmer_and_mixed_volatiles.md).

---

## Separate Skimmer and Industrial CO₂ Processing Roles

**Owner clarification (2026-11-21):** these are two different processes serving different operational goals. The skimmer's limited onboard CO₂ processing exists to fill its LOX tank for its own mission. Industrial CO₂ processing exists to make solid carbon/CNT feedstock. Do not merge these into one skimmer process or describe the skimmer as manufacturing CNTs.

The skimmer's `2CO₂ → 2CO + O₂` reaction produces oxygen that is liquefied and retained as LOX; CO is handled according to the craft's storage/venting configuration. The industrial route converts CO₂ into solid carbon for CNT production and produces oxygen as a co-product. Industrial processing takes place in dedicated industrial equipment, downstream of feedstock acquisition and transport. **It is not specific to Venus:** CNT production can be established wherever suitable carbon feedstock and industrial capability are available. For example, Luna can manufacture CNTs using imported CO₂. The viable location and economics depend on resource availability, imports, energy, equipment, and logistics—not on a Venus-only production rule. **Owner clarification (2026-11-21): Venus is expected to become a major atmospheric-gas and materials industrial powerhouse**, not merely a CNT production site. Its atmospheric composition provides abundant CO₂ and N₂ feedstocks and supports O₂ and CO processing/recovery, while strong solar-energy availability can power substantial industrial capacity. Expected outputs and activities include CNT/solid-carbon manufacture, O₂ production and handling, N₂ separation and supply, and CO₂ harvesting, processing, storage, and export. Other locations remain capable of selected production where supplied with suitable feedstock and industrial capacity; Luna is an example, not an assertion that every location has Venus's natural advantages.


## Venus Industrial Geography and Development Pattern (DIRECTION)

**Owner clarification (2026-11-21):** Venus's industrial role follows from its location and planetary makeup; it does not depend on making the planetary surface accessible. Routine surface access and surface-based industrial development are not assumed to be practical. The intended development pattern is atmospheric and orbital:

- **Cloud cities / high-altitude platforms:** provide inhabited and operational facilities in suitable atmospheric layers, including places to service atmospheric harvesting and processing systems.
- **Orbital infrastructure:** provides depots, industrial platforms, storage, transport interfaces, and larger-scale manufacturing and logistics capacity.
- **Imported asteroid feedstock:** asteroids are brought into the Venusian industrial system for processing and conversion into useful materials and products. Venus's atmospheric feedstocks and solar-energy environment complement these imported solid-material resources.
- **Distributed, expandable infrastructure:** the initial two stations are an establishment foothold, not a fixed limit or the complete industrial buildout. Further cloud-city and orbital facilities can be added as capacity, demand, and logistics justify them.

Do not imply that Venus's industrial future requires surface mines, factories, or routine surface access. Its atmospheric resources, solar-energy availability, orbital facilities, cloud-city infrastructure, and imported asteroid material together support the expected industrial hub. Exact facility counts, locations, asteroid sources, conversion flows, and construction sequence remain OPEN.

## Refined Brute-Force Venus → Mars Method (O₂/N₂ + CNT Shells)

**DIRECTION** — higher-processing, higher-control option that can support traditional terraforming goals. This is one example of a supply chain that uses Venusian CO₂ as CNT feedstock; it does not establish Venus as the only place where CNTs can be manufactured.

### End-to-End Pipeline

1. **Atmospheric harvesting**  
   Automated skimmers operate in the upper Venusian atmosphere (roughly the 1–2 bar region: near room temperature and Earth-like pressure).

2. **Depot processing**  
   Harvested gas is delivered to an orbital or high-altitude depot for separation.

3. **CNT shell manufacturing**  
   The CO₂ fraction is used as feedstock to manufacture carbon-nanotube (CNT) thermal-ablation shells.

4. **Payload preparation**  
   Frozen O₂ and N₂ are packed inside the CNT shells.

5. **Mass-driver launch**  
   When Venus and Mars are in proper orbital alignment, mass drivers fire the payloads onto ballistic trajectories toward Mars.

6. **Magnetic shield prerequisite**  
   An artificial magnetosphere (or L1 solar shield) must already be active at Mars. This is independent of any moon-relocation option; see [artificial_magnetosphere.md](artificial_magnetosphere.md).

7. **Reentry and release**  
   CNT shells ablate and burn up in the Martian atmosphere, releasing the O₂ and N₂ directly into the building atmosphere.

### Economic Characteristics

- **Venus atmospheric-industry advantage**: Venus is expected to become a major industrial hub for CNT/solid-carbon manufacture and for O₂, N₂, CO₂, and CO processing, separation, storage, and supply. Its atmospheric composition provides the feedstocks, and strong solar-energy availability supports substantial industrial operations.
- **Not an exclusive location**: CNT and gas processing are not restricted to Venus. Other locations can manufacture or process selected products when they have suitable feedstock and industrial capability; for example, Luna can use imported CO₂ to manufacture CNTs. The relative economics depend on feedstock acquisition, power, plant capacity, and transport. Do not assume zero-value feedstock or negligible losses merely because Venus has a large atmosphere.
- **Fuel still required**: Skimmers, platforms, and local transport need CH₄ or H₂.
- **No expensive interplanetary propellant for the gas itself**: Electromagnetic launch replaces chemical rockets for the Venus→Mars leg.

### Bootstrapping Dependency

Venus cannot easily produce the heavy metals and structural materials needed for mass drivers and high-throughput plants. External entities (Mars, Luna, or other hubs) must seed the initial capital and machinery. Once operational, Venus pays back that investment through the continuous volatile stream and continues to import heavy metals.

### Early Luna Involvement

- Luna manufactures and dispatches the first automated skimmers.
- Luna needs CO₂ and N₂ for its own growth.
- Luna has PSR water ice and can synthesize methane, closing an early fuel loop.
- Once volume scales, **cyclers** take over the heavy Venus–Luna leg; direct skimmer runs to Luna stop.

### Bidirectional Trade

- Venus exports: volatile payloads (and other industrial products).
- Venus imports: heavy metals, refractory materials, and goods it cannot produce locally.

---

### Industrial CO₂ Processing — CNT / Structural Carbon & Greenhouse Gas Handling (DIRECTION)

**Industrial framing:** dedicated industrial equipment can process available CO₂ feedstock into solid carbon for CNT / structural-carbon production, with useful gas products and possible export. Venus is expected to become a major atmospheric-gas and materials industrial powerhouse: its atmospheric composition supplies CO₂ and N₂ feedstocks and supports O₂ and CO processing/recovery, while strong solar-energy availability can power substantial industry. CNT/solid-carbon manufacture is one important part of this wider industrial base, alongside O₂ production and handling, N₂ separation and supply, and CO₂ harvesting, processing, storage, and export. These capabilities are not exclusive to Venus: Luna can also manufacture CNTs when supplied with imported CO₂, and other locations can process gases where feedstocks and industrial capability exist. This is distinct from the skimmer's limited onboard processing, whose operational purpose is to produce and retain LOX for the craft's own mission fuel cycle.

**Keep the two CO₂ processes distinct:**

- **Skimmer onboard processing (Mk1):** the HLT takes in the current mixed atmosphere and processes only enough captured CO₂, within its onboard capability, to produce O₂ for liquefaction and storage in the craft's LOX tank. The reaction is `2CO₂ → 2CO + O₂`. This supports the skimmer's LOX/fuel requirement; it is not the CNT manufacturing process. CO handling follows the skimmer's configured storage/venting policy. See [Skimmers & Mixed Volatiles](../logistics/skimmer_and_mixed_volatiles.md).
- **Industrial CO₂ processing:** a separate industrial plant or depot processes CO₂ feedstock to produce solid carbon for CNT manufacture, with O₂ as a co-product. This is the route for producing structural carbon/CNT material and supporting the industrial O₂/N₂ export pipeline. It is not performed by the Mk1 skimmer's onboard LOX-processing equipment.

Pure carbon or CNT feedstock export is allowed and useful; nothing restricts it. The plant need not be located at the source of the CO₂: transporting CO₂ to an industrial site, including Luna, is a valid supply option when its costs and capacity make sense.

**Greenhouse-gas handling:** Water produced by any H₂ + CO₂ reaction is a potent greenhouse gas. It must be removed from the Venusian atmosphere and stored in cold-shadow CNT tanks behind the L1 shade until surface temperature and pressure conditions later allow safe re-injection. This is a staging step, not an abandonment — greenhouse agents are retained for later Mars atmospheric use.

**Structural standard:** the standardized modular octagonal CNT panel is the structural unit for both Venus L1 shade arrays and later Mars L1 concentrator arrays (ESTABLISHED INTENT, owner, 2026-11-16; see [Modular Orbital Panel Swarms](modular_orbital_panel_swarms.md)). Exact dimensions, PV-to-reflector ratios and the proton-capture mesh remain **OPEN**.

**Solar-wind proton capture:** can be embedded in the panel mesh as a secondary, low-volume H₂ yield. It does not replace bulk H₂ logistics; it is a supplemental harvest only.

---

## Softer / Longer-Horizon Options

**DIRECTION / OPEN**

These trade time and lower CapEx for slower atmospheric gains. They may be chosen when protective pressure is not urgent or when capital is constrained.

### Gradual Venus Siphon
Steady, low-intensity upper-atmosphere extraction without immediate mass-driver build-out. Venus slowly sheds pressure while feeding a manageable trickle of its **current mixed atmospheric composition** into the inner-system network. Constituents can be separated or processed downstream according to the receiving equipment and demand; do not treat the intake itself as selective CO₂/N₂ extraction.

### Titan Long-Lead
- Primary volatiles: hydrocarbons (CH₄) and N₂.
- Strengths: large stable inventory of organics and nitrogen.
- Limits: long transit, cryogenic holding losses, weaker as a bulk CO₂ mass source for rapid pressure building.
- Best treated as a baseline organic/fuel provider rather than a rapid pressure or atmosphere-builder.

### Kuiper Belt Object (KBO) Slow-Boat
- Low-thrust or gravity-assist trajectories bring ice-rich bodies inward over decades.
- Clean water and volatiles with minimal surface damage on arrival.
- Extreme lead times; high value for pure water inventory once the logistics are paid for.

### Local / Hybrid
Continued reliance on Martian polar CO₂, subsurface ice, and industrial greenhouse-gas production, possibly combined with modest imports. Lower throughput, lower external dependency.

---

## AI Manager Decision Framing

**DIRECTION**

The AI Manager evaluates pathways as capital projects against EAP, timeline pressure, feedstock availability, power availability, transport cost, and available industrial capacity. Venus's atmospheric composition and solar-energy availability make it an expected major industrial hub for CNTs and O₂, N₂, CO₂, and CO processing. The AI Manager can still compare Venus-based production with importing feedstocks to another industrial hub (for example, Luna) when local demand, logistics, or other constraints justify it:

- Need rapid protective pressure, magnetosphere already online → favor raw-gas mass-driver transfer.
- Need controlled O₂/N₂ composition for longer-term terraforming goals → favor refined CNT-shell pipeline.
- Low CapEx + long timeline → favor gradual siphon, Titan trickle, or KBO slow-boat.
- Bootstrapping cost of Venus infrastructure is a real gate; external heavy-industry support is required before high-throughput methods can run.

Sol is the training ground. Once the AI Manager can balance these loops inside Sol, the same first-principles scoring (volatile inventory, delta-V, insolation, bootstrap potential) is applied to extrasolar candidates.

---

## Open Questions / Future Work

- Exact protective pressure targets (what millibar ranges meaningfully reduce operational risk for population and infrastructure).
- Processing and packaging requirements for the raw-gas transfer path.
- Feedstock ratios for the refined CNT path (CO₂ mass per unit shell vs. frozen O₂/N₂ payload).
- Mass-driver launch cadence and alignment-window scheduling for both methods.
- Artificial magnetosphere / L1 shield power and construction requirements (placement and construction options live on [artificial_magnetosphere.md](artificial_magnetosphere.md); station/depot construction options on [station_construction_options.md](../engineering/station_construction_options.md)).
- Transit and boil-off loss models for any non-mass-driver legs.
- How the AI Manager scores time-versus-cost trade-offs and when it switches strategies.
- Data structures for multi-body capital investment and payback tracking.
- Survey heuristics and scoring matrix for prime candidates beyond Sol.

All numerical values and ownership models remain **OPEN**.
