# Settlement Progression and Footholds

**Status**: DIRECTION  
**Last Updated**: 2026-11-09  
**Related**: [getting_started.md](getting_started.md), [player_roles_and_alignment.md](player_roles_and_alignment.md), [surface_habitat_options.md](../infrastructure/surface_habitat_options.md), [ai_manager_economic_loops.md](../logistics/ai_manager_economic_loops.md), [portals_and_aws.md](../technical/portals_and_aws.md)

This page is the wiki home for the intended progression from early AI-built footholds to mature player-managed settlements and surface expansion. It consolidates prior lava-tube and early-settlement intent while adding the player-spawn, portal, population, and archetype material from the 2026-11-04 brainstorm.

---

## ESTABLISHED INTENT — Required Sol bootstrap, flexible expansion

The initial Sol progression has two required milestones: establish the **Luna foothold**, then establish the **Earth–Moon L1 station and fuel depot**. These are foundational requirements for opening the wider system; they are not optional examples among interchangeable starting strategies.

Beyond Earth, expansion is deliberately more flexible. The AI Manager should assess each destination and choose a viable development path based on local bodies and resources, available technology, fuel, logistics, and existing infrastructure. Do not impose a universal numbered phase sequence or require every system to reproduce the exact Sol construction recipe.

The game still needs the relevant **station and depot functions** as infrastructure expands. Their physical arrangement, scale, combination, and construction style are open to the chosen approach and local conditions. A station and a depot need not imply one fixed blueprint or a single prescribed configuration.

---

## ESTABLISHED INTENT — AI-led access, then player-led expansion (2026-11-09)

The AI Manager's initial settlement work exists to **open locations for people and players** and establish the footholds, stations, and supporting infrastructure that make further expansion practical. Equipment and industrial activity are means to that outcome, not the end goal.

### AI Manager establishes the footholds

The operator gives the AI Manager mission objectives, starting conditions, available resources, and constraints. The AI Manager is expected to inspect the location, assess its needs and opportunities, determine priorities, and choose a suitable development path. The mission defines the desired outcome; it must not prescribe a fixed, developer-authored sequence of every harvest, processing, manufacturing, and construction action.

The AI Manager should establish the capabilities needed to open the location: for example, resource extraction and processing, power, life support, fabrication, logistics, maintenance, and an initial foothold or station. The exact combination and order should depend on the location and its conditions.

### Simulation supervision and learning

Pre-player buildout is also an operator-supervised test and validation environment:

- Operators can assign missions to the AI Manager and observe its decisions and execution.
- The simulation must execute all intervening activity and consequences. Accelerated time or a manual buildout jump changes how quickly the simulation runs in wall-clock time; it does not skip harvesting, processing, production, construction, logistics, equipment operation, failures, or generated events.
- Operators can pause at inspection points or when a problem appears, review inventories and volatile stores, completed work, equipment condition, failures, unexpected events, and the AI Manager's responses, then intervene and resume.
- Mission outcomes and decision/execution histories can be evaluated and retained as training and validation data. The purpose is to assess whether the AI Manager selected a sound path, not merely whether it completed a scripted checklist.

Pause and manual time-jump controls belong to pre-player buildout supervision. Player gameplay uses the shared universe clock and centrally determined rate; individual players do not control the simulation rate, pause the universe, or jump the calendar. See [Game Time and Simulation Loop](../engineering/game_time_and_simulation_loop.md).

### Player and corporation expansion after access

Once a world is accessible, players and player corporations can establish their own bases and settlements. NPC footholds and stations are enabling infrastructure, not exclusive settlement ownership and not a requirement that every later development remain NPC-operated.

Players and corporations may also lease suitable space at NPC settlements to install portal endpoints / pairs, creating convenient connections for moving eligible payloads and supporting imports and exports. Portal use remains subject to the established portal technology and payload constraints: portals are not a blanket replacement for bulk freight, which continues to use appropriate physical transport.

The AI Manager continues operating and maintaining NPC infrastructure after player access. It may expand NPC capacity or services as conditions and demand justify it, while player organizations develop their own operations alongside it.

### Development after the initial access foothold

After essential access and station infrastructure are established, the AI Manager can prioritize secondary development according to local conditions and needs:

- Expand NPC settlement capacity to support additional population and activity.
- Improve production, logistics, maintenance, and other services.
- Pursue suitable terraforming programs as a long-horizon development objective.
- Respond to player and market demand without treating every opportunity as an automatic build requirement.

Terraforming is also an intentional long-term resource and GCC sink. Players can earn GCC by harvesting, processing, hauling, and selling resources needed by terraforming programs; see [Terraforming Economic Integration](../logistics/terraforming_economic_integration.md). Terraforming priorities and spending remain AI Manager / NPC development decisions rather than direct player control.

**Undecided implementation details:** how missions express objectives and constraints; how decision rationale and training records are stored; what constitutes sufficient access for player entry; lease terms, endpoint ownership, capacity, fees, and permissions; and how the AI Manager weighs population growth, player demand, and terraforming against other priorities.

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
