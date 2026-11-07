# Settlement Progression and Footholds

**Status**: DIRECTION  
**Last Updated**: 2026-11-04  
**Related**: [getting_started.md](getting_started.md), [player_roles_and_alignment.md](player_roles_and_alignment.md), [surface_habitat_options.md](../infrastructure/surface_habitat_options.md), [ai_manager_economic_loops.md](../logistics/ai_manager_economic_loops.md), [portals_and_aws.md](../technical/portals_and_aws.md)

This page is the wiki home for the intended progression from early AI-built footholds to mature player-managed settlements and surface expansion. It consolidates prior lava-tube and early-settlement intent while adding the player-spawn, portal, population, and archetype material from the 2026-11-04 brainstorm.

---

## Core Progression Arc

1. **Subterranean / Bermed Bootstrap** (AI Manager primary)
2. **Industrial Build-out** (AI + early players)
3. **Surface / High-Power Expansion** (players once power and logistics mature)

Players are not expected to perform the high-risk initial seal-and-pressurize work on virgin lava tubes. That is the AI Manager’s job.

---

## Foothold Architecture

**DIRECTION** (builds on extensive prior lava-tube material)

- Preferred early sites: lava tubes or heavily bermed locations (natural radiation shielding + thermal stability).
- AI Manager deploys initial bulkheads, seals tube mouths or constructs bermed pressure vessels, and establishes basic life support and power.
- Individual housing modules, labs, and workshops retain their own airlocks (defense-in-depth / compartmentalization).
- Once the primary volume is stable, the AI Manager builds stockpiles and planned civic capacity up to a defined baseline.

Prior documentation already covers multi-step lava-tube processes (survey → prepare entrance → seal with airlocks), sealed-volume atmosphere management, and early Luna/Mars establishment profiles. Those remain valid foundation material; this page treats them as established prerequisite rather than re-deriving them.

**OPEN**
- Exact criteria the AI Manager uses to select tube locations (ice proximity, structural integrity, access, etc.).
- Degree of automation versus any residual manual construction steps.

---

## Player Spawn and Starting Conditions

**DIRECTION**

- New players (or player corporations) begin at an **active AI-managed foothold**.
- Starting locations include Luna, Mars surface/subsurface sites, and orbital stations.
- Starter loadouts are location-appropriate (mining/ISRU tools on surface/subsurface, logistics/docking licenses on stations, etc.).
- Players may live and work inside the foothold, perform local crafting and mining, or immediately pivot to logistics without being forced into settlement architecture.

**OPEN**
- Precise starter packages and any initial corporate contract / debt relationship with the founding DC.
- Tutorial / onboarding flow that explains the difference between foothold tenant and independent operator.

---

## Mobility Between Layers

**DIRECTION**

- Intra-system portals (miniaturized AWS technology) move **low-mass** payloads only: personnel, high-value components, emergency supplies.
- Bulk materials (ores, structural steel, large machinery, volatiles in quantity) travel by physical freighters, cyclers, and skimmers.
- Portals are built in pairs and require physical infrastructure and power at both ends. EM is spent mainly by the firing side at the opening, with some used for stabilization; if EM is unavailable the link shuts down.
- Travel between settlements (even via portal) takes real time; hub-and-spoke routing with layovers is the normal pattern.
- A player based on a station can portal to a surface foothold and vice-versa; starting location does not lock career path.

See [portals_and_aws.md](../technical/portals_and_aws.md) for the full technology split and constraints.

**OPEN**
- Exact mass limits for portals.
- Portal scheduling, power windows, and EM consumption numbers.
- Whether player corporations can eventually own and toll private portal pairs.

---

## Population and Morale Dynamics

**DIRECTION**

- Settlements attract or lose population through the portal network according to quality of life (life support reliability, amenities, taxes/fees, power stability).
- High quality-of-life rating → immigration.
- Neglected facilities → stagnation then outflow.
- Critical failure can trigger mass portal evacuation. The physical plant (structures, machinery, stockpiles) remains; the base becomes a ghost site that can be reclaimed later.

This is intentionally analogous to guest-behavior models in which facilities and maintenance drive arrival and departure. Adapted here to a closed life-support environment.

**OPEN**
- Concrete morale / rating model and which systems feed it.
- Evacuation thresholds and residual population rules.

---

## Player Archetypes (Non-Exclusive)

**DIRECTION**

Players may specialize or combine freely:

| Archetype                   | Primary Focus                                      | Typical Starting Point          |
|-----------------------------|----------------------------------------------------|---------------------------------|
| Homestead Craftsman / Miner | Local extraction, processing, crafting inside a foothold | Surface or lava-tube foothold  |
| Logistics & Fleet Operator  | Freight, cyclers, orbital stations, market arbitrage | Orbital station or major hub   |
| Settlement Architect        | Zoning, life support, amenities, population growth (micro layer) | Any mature foothold            |
| Hybrid Industrialist        | Extract + manufacture + ship                       | Any                            |

The same character can move between these roles over time. Starting location does not permanently lock the player into one path.

---

## Surface Expansion Gate

Larger surface habitats (see [surface_habitat_options.md](../infrastructure/surface_habitat_options.md), a thought exercise, not a decided structure type) would need power and industry first; the conditions are OPEN. They become available only after the industrial and power conditions listed on that page are met. Until then surface activity remains limited.

---

## Relationship to AI Manager and Economy

- AI Manager builds and maintains the initial foothold and continues to operate the survival loops described in [ai_manager_economic_loops.md](../logistics/ai_manager_economic_loops.md).
- Player activity (taxes, fees, fulfilled missions) supplies the liquid GCC that lets the AI Manager outsource work and expand beyond the baseline blueprint.
- Players who undercut EAP or fill deficits become preferred suppliers; players who ignore a base may later find it in austerity or as a reclaimable ghost site.

---

## Open Questions

- Exact visual / UI representation of the micro settlement layer (dashboard-first vs richer spatial view later).
- How much of the zoning and conduit routing is required for the first playable version versus later expansion.
- Player ability to purchase or lease sectors inside an AI foothold versus founding fully independent settlements.
- Long-term ownership and governance model when multiple player corporations operate inside the same tube or dome complex.

All items remain **DIRECTION** or **OPEN** until further design decisions and acceptance.
