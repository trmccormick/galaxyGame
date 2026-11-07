# Modular Orbital Panel Swarms

> **Wiki section:** Infrastructure  
> **Status:** DIRECTION  
> *Candidate design intent. Not yet ESTABLISHED INTENT. Geometry, exact placement distances, and full performance numbers remain open.*

> **Cross-link:** Production side (CNT fabricators and downstream feedstock) lives in **[ISRU Fabrication Chain](../technical/isru_fabrication_chain.md)**.

> **Cross-link:** Atmospheric harvesting of CO₂ and N₂ from Venus/Titan is covered in **[Atmospheric Harvesting](atmospheric_harvesting.md)**.

> **Cross-link:** Settlement and station infrastructure is covered in **[Settlement Infrastructure](settlement_infrastructure.md)**.

---

## Purpose & Scope

This page documents the deployment, operation, and planetary roles of modular orbital panel swarms. These swarms are the shared technology family used for:

- Venus solar-shade functions (optional / progressive)
- Mars solar-reflector functions (clearer intent that the capability is built)
- Optional additive capabilities (solar collection, hydrogen capture, energy beaming)

The panels themselves are produced primarily from Venus-sourced carbon via CNT fabricators (see the technical page linked above). This page owns the infrastructure side: how swarms are placed, tracked, supported, and used.

---

## Swarm Model

Individual panels, struts, I-beams, and similar components are **never** tracked as discrete entities.

Representation uses a **swarm model**. Each swarm entry records:

- Spatial location of the swarm.
- Counts of panels by type / configuration (metadata).

Panel mixes are allowed and expected. Technology available at the time a panel was deployed can differ from later panels in the same swarm, so the swarm must track the quantity of each distinct type (for example, plain Mk1 shade-only panels versus later panels that include power-beaming capability, solar collection, hydrogen capture, etc.).

Aggregate state (damaged, under repair, queued for replacement + recycling) is tracked against those counts.

Events and effects are expressed at the swarm level, for example:

- “Solar flare damaged electronics in X panels of type Y”
- “Bots are replacing X panels”
- “Repairs underway on X panels”
- “Energy transmission output reduced by Z”

Blueprint + location together determine the functional properties of the swarm (solar blocked, solar collected, power beamed, hydrogen captured, etc.).

---

## Planetary Roles

### Venus — Solar Shade (Optional / Progressive)

- The shade is an option, not a mandatory project.
- Construction can be gradual; the swarm may be partial or absent depending on how the game progresses.
- Primary function is reduction of solar constant at Venus.
- Same modular frame family is used; configuration starts as basic shade / structural and can later receive additive modules.

### Mars — Solar Reflector

- Clearer intent that the reflector capability is built.
- Uses the same modular CNT frame family, adapted with a reflective layer (lunar aluminum or equivalent).
- Primary function is to increase surface insolation / temperature on Mars.

Exact orbital distance of any Venus shade remains unspecified. Multiple designs remain allowed; the octagonal CNT frame form is the current working assumption, not a hard lock.

---

## Optional / Additive Configurations

All configurations share the same underlying modular frame family. Capabilities are additive rather than unique per planet.

| Configuration | Primary function | Notes |
|---------------|------------------|-------|
| Basic shade / structural | Solar-constant reduction (Venus) or structural backbone | Core CNT frame |
| Solar-collector equipped | Local power generation | Panels can carry photovoltaic layers |
| Hydrogen-capture equipped | Atmospheric or depot H₂ collection | Useful near Venus or at gas depots |
| Reflective (Mars) | Surface insolation boost | Lunar aluminum or equivalent reflective layer |
| Energy-beaming capable | Directed power transfer | Enables Venus → Mars (or other location) energy beaming as an optional later capability |

Energy-beaming is treated as an optional addon path that can grow from the same panel family; it is not required for the basic shade or reflector roles.

---

## Operations (Local Station Support)

Local stations deploy service craft that carry bots.

- Bots travel to the swarm to perform repairs on damaged panels.
- For hydrogen-capture panels, bots can extract hydrogen from the panels’ temporary storage and return it to the station.
- Replacement of failed panels and recycling of recovered material are also handled through the same station → craft → bot loop.

This keeps maintenance, resource recovery, and panel replacement inside the existing station logistics pattern rather than requiring a separate global system.

---

## Production & Deployment Notes

- Fabrication is intended to occur in orbit (or at high-altitude Venus facilities) using local carbon feedstock.
- Panels produced at Venus can be adapted and shipped/configured for Mars use.
- Exact orbital distance of any Venus shade remains unspecified.
- Size of a swarm matters (total panel count), but tracking stays at the aggregate level described above.

---

## Open Items (Do Not Invent)

- Precise geometry tolerances and structural load numbers.
- Exact power-beaming efficiency, wavelength, or aperture requirements.
- Detailed degradation / repair-drone rules for large arrays.
- Whether energy beaming is gated behind a later tech unlock or available as a progressive addon.
- Final data schema for the swarm aggregate (counts, percentages, integrity model, etc.).
- Exact spatial placement rules and any station-proximity requirements.

---

*This page is DIRECTION only. It consolidates session clarifications and existing Phase 14 / Venus industrial role language. Cross-check against frozen documentation before promoting any part to ESTABLISHED INTENT.*
```
