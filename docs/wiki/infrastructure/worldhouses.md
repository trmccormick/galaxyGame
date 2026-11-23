---
title: Worldhouses and Engineered Environments
category: Infrastructure
status: DESIGN INTENT
last_updated: 2026-11-22
---

# Worldhouses and Engineered Environments

> **Status: ESTABLISHED INTENT — owner-confirmed 2026-11-22.** This page records settlement and environmental-engineering gameplay intent. It does not claim that every described environmental, biological, automation, or remote-operation capability is implemented.

## Purpose

A **Worldhouse** is an engineered enclosure that uses a natural geological feature or other suitable terrain as part of a contained environmental volume. It can create a protected and controllable local environment without requiring the player to transform the surrounding planet.

A Worldhouse is not inherently a human habitat, a finished city, a terraforming facility, or a fixed-size construction type. It is an engineering capability that can serve many purposes as the player or AI Manager develops it.

Examples include:
- A sealed lunar lava tube that protects an early settlement and can grow into an underground city.
- An enclosed Martian valley or canyon used as a home base, industrial area, biological experiment, or larger environmental project.
- A small enclosure for testing organisms or environmental conditions.
- A large controlled environment intended to contribute to planetary terraforming.
- An industrial or robotic volume whose atmosphere is unsuitable for people.

The player may enclose an entire feature or develop a smaller portion where the terrain and engineering approach permit. The game should not restrict the concept to a predetermined list of settlement types or scales.

## Settlement gameplay: build, operate, modify, and expand

**ESTABLISHED INTENT — 2026-11-22**

Settlement gameplay is persistent and player-directed. A player can establish a useful base and continue improving it over time; they do not have to pursue terraforming, build a fully developed habitat, or remain continuously present for the settlement to be worthwhile.

A player might:
1. Establish a modest base in or near a natural feature.
2. Enclose some or all of the feature when resources, GCC, construction capacity, and technology allow.
3. Harvest local resources and use them to support construction, processing, and manufacturing.
4. Establish a home area, workshop, research space, agricultural area, or industrial operation as desired.
5. Experiment with environmental conditions or introduce suitable basic life.
6. Add equipment and capabilities incrementally as they become affordable.
7. Leave the settlement operating while pursuing orbital, interplanetary, or deep-space activities.
8. Monitor the settlement remotely, change priorities, issue commands, and redirect robotic assets when communications permit.

The player may focus on any combination of living, harvesting, manufacturing, research, environmental experimentation, and supporting space operations. Priorities can change as the settlement develops.

The gameplay loop is:

**Design → build → operate → observe → learn → modify → expand.**

The game supplies engineering capabilities, resources, costs, physical constraints, and simulation outcomes. The player or AI Manager decides how to combine those capabilities and what the settlement should become.

## Flexible environmental configuration

A Worldhouse is defined by its enclosure and the environmental volume it makes possible, not by a mandatory atmospheric profile.

Pressure, gas composition, temperature, humidity, lighting, radiation protection, and other conditions are separate environmental properties to the extent supported by the simulation and installed technology. In particular, **human-level pressure does not imply an Earth-like or breathable gas composition**.

A player could, for example, seal a section of Valles Marineris, pressurize it using a Martian-gas mixture, introduce basic life suited to the conditions, and observe the results. The player could begin with limited technology and add gas processing, filtration, thermal control, environmental monitoring, recovery, or human life-support capabilities later. The example is not a required sequence or a fixed recipe.

Possible purposes and configurations include:
- Human habitation.
- Industrial or robotic operations.
- Research and environmental experiments.
- Biological introduction, adaptation, and observation.
- Agriculture and other life-supporting activities.
- Local paraterraforming.
- A project intended to contribute to planetary terraforming.

These purposes are not mutually exclusive. A Worldhouse may change purpose as the player modifies it.

## Terraforming Seeds, Worldhouses, and Paraterraforming

These terms describe related but different aspects of environmental engineering; they should not become rigid, mutually exclusive structure classes.

- **Worldhouse** describes an engineered enclosure and the controlled environmental volume it creates around or within a natural feature.
- **Terraforming Seed** describes an environment, deployment, or project intended to establish conditions or biological activity that may contribute to terraforming. It may be small, large, enclosed, or associated with a Worldhouse. It is a purpose or role, not a required physical form.
- **Paraterraforming** describes creating locally controlled environments while the broader planetary environment remains substantially unchanged.
- **Planetary terraforming** describes intentional modification of the wider planetary environment.

A Worldhouse can serve as a Terraforming Seed, but not every Worldhouse needs to contribute to terraforming. A Terraforming Seed does not have to be a Worldhouse: a player might create a small purpose-built biological enclosure or choose another suitable deployment. A sealed valley can be a terraforming experiment if that is what the player intends to do with it.

Players should be able to choose the location, scale, construction approach, environmental conditions, biological payloads, and objectives that their technology and resources make possible. Do not require a predefined Seed-to-Worldhouse progression or assume that every project is intended to become a human settlement.

See [Terraforming Seeds](../technical/biology/terraforming_seeds.md) for biological deployment and biosphere concepts, and [Terraforming Options](terraforming_options.md) for planetary-scale approaches.

## Nested environmental volumes and gas recovery

**ESTABLISHED INTENT — 2026-11-22**

A settlement may contain multiple levels of environmental containment:

1. The exterior planetary environment.
2. An enclosed Worldhouse or other large environmental volume.
3. Individual pressurized buildings, habitats, laboratories, or other facilities inside that volume.

Gas lost from an inner habitat is not necessarily lost to the planet or space. It may enter the surrounding Worldhouse volume, where it can be measured, retained, recovered, processed, and reused. Gas may also escape from the Worldhouse itself through imperfect containment, damage, or deliberate venting.

Routine atmospheric loss is an expected operating condition, not solely a symptom of damage. Better seals and maintenance can reduce leakage; damage or deterioration can increase it. Recovery equipment and improved processing can reclaim some of the gas that would otherwise be lost. The player should be able to improve these systems over time rather than treating containment as a binary perfect-seal state.

This local containment and recovery loop is distinct from natural planetary atmospheric escape and any orbital interception of escaping gases. See [Atmospheric Escape, Retention & Recovery](atmospheric_escape_and_recovery.md) for planetary-scale loss and recovery.

## Local industry and construction progression

Worldhouse development is connected to settlement industry and local resource use.

The lunar lava-tube example establishes a useful progression:
- Early inflatable habitats and imported critical equipment can support the first crew while permanent construction begins.
- Local regolith processing and fabrication can produce basic structural parts, including beams and panels.
- Those parts can be used to seal openings and skylights, build supports and partitions, and construct many kinds of early buildings and infrastructure.
- The settlement can grow into a permanent city inside the enclosed feature.
- More advanced local industry can gradually produce better materials, machinery, and complex components.

Basic locally manufactured construction parts should have broad utility early on. Do not require a specialized advanced manufacturing chain for every ordinary building before the settlement has developed the industrial capacity to support one. Imports remain useful for equipment and technologies the location cannot yet produce.

This is an example of an available development path, not a mandatory fixed sequence for every Worldhouse or settlement.

## Robots, autonomy, and remote operations

**ESTABLISHED INTENT — 2026-11-22**

A settlement remains operational when the player is elsewhere, subject to its available automation, resources, communications, and operating conditions. The player may directly control robots when present or connected, assign them roles supporting a project or mission, or leave routine work to autonomous operations and the AI Manager.

Examples of robotic and automated work include:
- Construction and repair.
- Mining, harvesting, and material handling.
- Manufacturing and processing.
- Environmental monitoring and maintenance.
- Agriculture and biological experiments.
- Loading, preparing, and servicing spacecraft.
- Supporting a player's space-based missions.

Remote interaction should respect GalaxyGame's communications model. Commands and reports may be delayed by distance, available relays, and communications conditions; remote control is not an assumption of instantaneous access everywhere. When communication is unavailable, local automation and the AI Manager may continue within their assigned authority and capabilities.

The player should be able to monitor the settlement, review its condition and activity, set priorities, assign tasks, and redirect available robots or resources without having to remain physically at the settlement.

## Relationship to the Settlement interface

The Settlement interface is the detailed workspace for an individual developed place. It should expose the capabilities needed to build, operate, inspect, and modify that place over time—not merely present a finished settlement or a list of predefined habitat types.

The interface should make it possible to work with:
- The selected location and its natural features.
- Enclosures, segments, buildings, and other structures.
- Environmental conditions and installed environmental equipment.
- Population and inhabited areas, where present.
- Resources, harvesting, inventories, production, and construction.
- Robots, assigned work, autonomy, and operational status.
- Local projects and experiments.
- Communications status and remote operations.
- Settlement support for spacecraft and other missions.

The interface should support progressive disclosure: a small outpost should remain manageable without exposing every advanced control, while a mature Worldhouse or city can expose deeper environmental, industrial, and operational detail. Exact layouts, controls, and implementation remain subject to the Player UI design.

See [Player View Architecture](../ui/02_player_view_architecture.md) for the three Player views and the Settlement context.

## Implementation boundary and open work

This page records owner-confirmed gameplay intent. It does not assert that all of the following are implemented:
- Configurable pressure and gas composition for every Worldhouse volume.
- Environmental exchange and gas accounting between buildings, Worldhouse volumes, and the exterior.
- Routine leakage, containment degradation, and recovery across nested volumes.
- General-purpose local construction and fabrication progression.
- Persistent autonomous settlement operation and AI Manager delegation.
- Remote robot tasking and monitoring through delayed communications.
- The complete Settlement interface described above.

The existing `Structures::Worldhouse` and `Structures::WorldhouseSegment` models provide structural foundations, but their presence alone does not establish the complete gameplay described here. Implementation should be checked against this intent, and gaps should become focused tasks linked to this page.

## Related wiki pages

- [Settlement Infrastructure](settlement_infrastructure.md)
- [Settlement Progression & Footholds](../player/settlement_progression_and_footholds.md)
- [Player View Architecture](../ui/02_player_view_architecture.md)
- [Terraforming Seeds](../technical/biology/terraforming_seeds.md)
- [Biosphere Simulation](../technical/biology/biosphere_simulation.md)
- [ISRU Fabrication Chain](../technical/isru_fabrication_chain.md)
- [Atmospheric Escape, Retention & Recovery](atmospheric_escape_and_recovery.md)
