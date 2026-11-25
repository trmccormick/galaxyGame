# Modular Orbital Panel Swarms
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-07  
> *Audit Summary:* Design intent specification (page status DIRECTION). Not audited against code; implementation pending or unverified as of audit baseline.

> **Wiki section:** Infrastructure  
> **Status:** DIRECTION  
> *Candidate design intent, except the section marked ESTABLISHED INTENT (octagonal panel design and swarm concept). Geometry, exact placement distances, and full performance numbers remain open.*

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
- **Industrial processing role:** native CO₂ cracking yields solid carbon (CNT feedstock) + O₂ on Venus; H₂O from any H₂+CO₂ reaction is removed from the atmosphere and stored in cold-shadow CNT tanks behind the L1 shade until later safe re-injection. See [terraforming_options.md](terraforming_options.md) for processing details.
- **Solar-wind proton capture:** panel mesh can embed secondary, low-volume H₂ harvest; this does not replace bulk H₂ logistics.

### Mars — Solar Reflector

- Clearer intent that the reflector capability is built.
- Uses the same modular CNT frame family, adapted with a reflective layer (lunar aluminum or equivalent).
- Primary function is to increase surface insolation / temperature on Mars.

Standardized modular octagonal CNT panels are the structural unit for both Venus L1 shade and later Mars L1 concentrator arrays (see the ESTABLISHED INTENT section below). Exact dimensions, PV-to-reflector ratios and the proton-capture mesh remain **OPEN**.

---

## Standardized Modular Octagonal CNT Panels and Swarm Concept — ESTABLISHED INTENT (owner, 2026-11-16)

For large L1 shade, concentrator, and swarm-style arrays, the owner confirmed the panel design and the swarm concept below. The spatial-field placement model further down is not part of this confirmation.

- Regular octagonal high-tensile CNT frame.
- Interchangeable infill (photovoltaic or high-reflectivity mirror).
- Designed to tessellate into a flexible, repairable swarm/web.
- Compatible with the existing swarm-type model already documented on this page.

### Still OPEN

- Exact physical dimensions.
- Exact mix ratios of PV vs reflector panels.
- Whether solar-wind proton capture mesh is baseline or optional.

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

Interplanetary power beaming (for example Venus → Mars or other targets) has **not been decided**. It remains a future option the AI Manager may score later and is not required for the basic shade or reflector roles.

---

## Operations (Local Station Support)

Local stations deploy service craft that carry bots.

- Bots travel to the swarm to perform repairs on damaged panels.
- For hydrogen-capture panels, bots can extract hydrogen from the panels’ temporary storage and return it to the station.
- Replacement of failed panels and recycling of recovered material are also handled through the same station → craft → bot loop.

This keeps maintenance, resource recovery, and panel replacement inside the existing station logistics pattern rather than requiring a separate global system.

---

## Production & Deployment Notes

- Fabrication is intended to occur in orbit (or at high-altitude Venus facilities) using local carbon feedstock. **Preferred early source:** Venus-sourced CNT from atmospheric CO₂ cracking is the preferred and currently best-understood feedstock for the standardized modular panels because of abundant CO₂ availability. The structural material concept itself is flexible, however — other locations may later produce analogous high-tensile structural panels from local feedstocks. Venus is preferred, not a hard restriction.
- Panels produced at Venus can be adapted and shipped/configured for Mars use.
- Exact orbital distance of any Venus shade remains unspecified.
- Size of a swarm matters (total panel count), but tracking stays at the aggregate level described above.

---

## Generic Spatial Field Model (OWNER-CONFIRMED DESIGN INTENT; IMPLEMENTATION PENDING)

The owner confirmed a deliberately small, generic model for spatially anchored fields. The model is intended to support structural swarms and arrays (including Venus solar shades and Mars reflectors), EM-harvestable clouds, Easter-egg phenomena, and other future spatial collections or effects without requiring a separate spatial model for each use case.

The conceptual record has only three core elements:

- **Name:** identifies the field.
- **Spatial location:** one spatial anchor for the field.
- **Metadata:** holds the field-specific description and changing state.

Metadata is intentionally flexible and can include the field type, component blueprint references, component types and properties, quantities/configurations, and other domain-specific information. For engineered swarms, metadata can identify the generic component blueprints used to define the actual panel or other component types. The spatial-field model itself does not need to encode every component property as a first-class field.

### Dynamic extent and aggregate condition

The field's area or volume is part of its metadata and is dynamic: it can expand, contract, or otherwise change as the represented swarm or phenomenon changes. The metadata may distinguish the configured physical extent from the effective/operational extent where that distinction matters (for example, a reflector swarm may still occupy its full deployed area while damage reduces its effective reflective coverage).

The model is intended to support aggregate simulation rather than requiring every underlying component to be represented as an independently simulated entity. For example, a solar flare can update a swarm's aggregate condition: the proportion or quantity of units damaged, the amount/severity of damage, and the proportion requiring repair, preparation, or replacement. The simulation need not retain an individual damage record for every panel when aggregate state is sufficient for gameplay and system behavior.

This is a generic design intent, not a finalized metadata schema or claim of existing implementation. The exact metadata structure, blueprint-reference contract, spatial geometry representation, aggregate damage calculations, and update rules remain OPEN. The simulation does not yet implement this spatial-field model.

### Existing location models (verified against code at galaxyGame `67dfa40`, 2026-11-16)

- `Location::CelestialLocation` places an object on or above a celestial body: surface coordinates plus an optional altitude (not negative).
- `Location::SpatialLocation` places an object at x, y, z coordinates within a spatial context.
- Neither table has an extent or field-size column. Whether a Lagrange point is placed with one of these two models is not established.

### Types that need placement (need stated by the owner; mechanism OPEN)

The owner states the game needs some form of placement for the following (owner, 2026-11-17). How it is built is not decided.

- **Structural swarms / L1 arrays:** the octagonal CNT panel and swarm concept is ESTABLISHED INTENT (owner, 2026-11-16; see above). How a swarm is placed is OPEN. L1 arrays remain a later option.
- **EM-harvestable clouds:** the game needs a way to determine the harvestable EM field produced by a wormhole discharge. Whether this uses the existing location models, and its extent, yields and harvesting rules, are OPEN.
- **Easter-egg fields / phenomena:** the game needs a way to place easter eggs in a system. Which location model applies, and the triggers and effects, are OPEN.

Whether these share one placement approach or each type defines its own is OPEN (see the list below).

### Open (do not invent)

- Final metadata schema and validation rules for each field type.
- The exact blueprint-reference contract for generic components and configurations.
- How a Lagrange-point or other free-space anchor is represented by the existing location models.
- Optional metadata such as intensity or density profiles, tags, lifecycle, ownership or control, where a use case requires them.
- Exact spatial geometry representation, field-shape changes, fall-off curves, yields and interaction rules.
- Aggregate damage, repair, preparation and replacement calculations, including when percentages versus absolute quantities are appropriate.
- Interaction rules between overlapping or co-located fields (overlap, stacking, conflict).

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
