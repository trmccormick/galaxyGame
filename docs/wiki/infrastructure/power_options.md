# Power Options for Settlements and Homesteads

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-04  
> *Audit Summary:* DRAFT from an owner and Gemini brainstorm (2026-11-04), written up by Grok and Qwen. Not yet verified against code or frozen docs. Only points marked ESTABLISHED INTENT were stated by the owner.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-04  
**Related**: [surface_habitat_options.md](surface_habitat_options.md), [settlement_progression_and_footholds.md](../player/settlement_progression_and_footholds.md)

This page is the wiki home for near-term and longer-term power options that unlock different scales of settlement and surface habitat. High continuous power density is the primary gate for comfortable, large-volume habitats (see the thought exercise in [Surface Habitat Options](surface_habitat_options.md)).

No major conflicting prior power architecture was found; this page consolidates the preferred near-term direction (orbital beaming) and the fallback options.

---

## Preferred Near-Term: Orbital Solar / Space-Based Power Beaming

**DIRECTION**

- Orbital solar concentrators or thin-film reflector arrays in suitable high orbit (areostationary or equivalent).
- Energy is collected above the atmosphere and dust, then beamed (microwave or laser) to a surface rectenna near the settlement or homestead.
- Advantages:
  - Continuous or near-continuous supply (no night, far less dust attenuation).
  - Bypasses the reduced solar flux at Mars distance and surface dust accumulation.
  - Scalable; additional orbital assets increase available power without expanding the surface footprint.
  - Uses physics and engineering approaches already studied for terrestrial space-based solar power.
- Enables the high-power homestead package (atmospheric compressors, active HVAC, pool thermal management, large-scale 3D printing, etc.).

**OPEN**
- Exact beam type, rectenna size, and conversion efficiency assumptions.
- Mass and deployment cost of the initial orbital assets.
- Vulnerability to orbital debris, station-keeping, or adversarial interference.
- Whether early footholds can bootstrap with small surface arrays and later upgrade to beamed power.

---

## Surface Solar + Storage

**OPEN / fallback**

- Conventional photovoltaic arrays with battery or other storage.
- Severely limited by:
  - Lower insolation at Mars distance.
  - Dust accumulation and global dust storms.
  - Long nights and seasonal variation.
- Suitable for low-power outposts, sensors, or early temporary modules.
- Insufficient by itself for a large high-power habitat without very large array + storage mass.

---

## Nuclear Options

**OPEN**

- Compact fission reactors (surface or buried).
- Radioisotope thermoelectric generators (RTGs) — useful for low continuous power (rovers, remote stations) but inadequate for habitat-scale loads.
- Fusion — longer-term aspirational option; not required for the near-term design direction.

Nuclear sources remain valuable for baseload or for locations where orbital beaming is impractical, but they are not the preferred first solution for unlocking large surface habitats.

---

## Power as a Progression Gate

**DIRECTION**

- Early AI footholds can operate on modest power (surface solar + storage, small reactors, or limited beamed power).
- The transition to high-power surface habitats (large domes with full atmospheric plants and gardens; see the thought exercise in the surface habitat page) is gated by the availability of continuous high-density power.
- Once orbital beaming or equivalent is online, the energy constraint relaxes and civil-engineering-scale surface construction becomes practical.

This keeps the early game focused on survival and industrial bootstrap while making the later large-habitat layer feel earned.

---

## Open Questions

- Minimum continuous kilowatts required to support a single high-power homestead versus a multi-homestead dome complex.
- How power is metered, priced, and allocated when multiple players or AI Managers share a beamed-power node.
- Failure and degradation modes (dust on rectenna, orbital asset loss, beam interruption) and required local backup.
- Whether players can eventually own or operate their own orbital power assets.

All specific numbers and ownership models remain **OPEN**.
