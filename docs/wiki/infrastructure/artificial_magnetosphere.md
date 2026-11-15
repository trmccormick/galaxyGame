# Artificial Magnetosphere

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-14  
> *Audit Summary:* Not yet verified against code. Only points marked ESTABLISHED INTENT were stated by the owner. No dedicated blueprint or operational-data file is known for this structure yet; treat as a station-class / capital structure for classification until reviewed.

> **Wiki section:** Infrastructure  
> **Status:** DIRECTION  
> *Candidate design intent consolidated from prior lore, SOP, atmospheric-maintenance, Gemini session material, and 2026-11 owner direction on placement and sequencing. Not yet ESTABLISHED INTENT. Quantitative specs (field strength, mass, power, cost) remain OPEN.*

> **Cross-link:** Prerequisite language already appears in **[Terraforming Options](terraforming_options.md)** and **[Venus–Mars Ballistic Corridor](../technical/venus_mars_ballistic_corridor.md)**. High-throughput gas injection requires the shield to be active.

> **Cross-link:** Modular orbital panel swarms (reflectors / energy beaming) are documented in **[Modular Orbital Panel Swarms](modular_orbital_panel_swarms.md)**. Those are complementary atmospheric and power tools, not substitutes for the magnetosphere.

> **Cross-link:** Station and depot construction options (including lean moon outposts that can feed later capital builds): **[Station Construction Options](../engineering/station_construction_options.md)**.

---

## Purpose

An artificial magnetosphere (magnetic dipole shield) is a planetary-scale atmospheric-retention system. It protects a planet's atmosphere against solar-wind stripping using a planetary-scale magnetic field, with the current proposed architecture located at the planet–star L1 point. Without it, continuous bulk injection of volatiles remains a permanent utility cost ("leaky bucket"). With it, atmospheric retention approaches permanence and emergency imports can be terminated.

Mars is the current example on this page; the concept applies to any atmosphere-retention scenario where solar-wind stripping threatens long-term atmospheric viability.

This page records the recovered design intent, preferred placement and construction direction, open alternatives, and quantitative gaps that still need resolution before promotion to ESTABLISHED INTENT.

---

## Sequencing (DIRECTION — owner 2026-11)

1. **Orbital / moon industrial presence first** — lean mining outposts on Phobos/Deimos (or equivalent), local stations, and depot capacity using established construction techniques (see station construction options).
2. **Magnetosphere next** — dedicated L1 station/structure, built largely from local (moon and orbital) feedstock plus imports where necessary.
3. **High-throughput atmospheric modification only after the shield is active.**
4. **Heavy Mars surface operations** may wait until after the shield (or at least until orbital presence is real); first access footholds do not require the magnetosphere.

The shield is progressive capital infrastructure, not a day-one requirement for opening Mars access. It **is** a hard gate before high-throughput gas injection.

---

## Preferred form — L1 station / structure (DIRECTION)

**What it is:** A dedicated station or capital structure at (or near) Mars–Sun L1 that hosts the superconducting dipole and its power systems — **not** a relocated moon.

**Why not move Phobos/Deimos for this (preferred early/baseline):**
- Mk-I cannot reposition those bodies; relocation needs a later heavy-tug class and multi-year effort.
- The moons’ best early role is local feedstock and lean outposts in natural orbit.
- Coupling the shield schedule to moon relocation delays both access industry and atmospheric work.
- A dedicated L1 structure can be fed by moon mines + local construction + selective imports without sacrificing the moons as production nodes.

**Moon relocation toward L1** remains a possible **later optional** path if it clearly scores better under higher-tier capability. It is not the baseline or preferred path for the magnetosphere.

**Blueprint / classification:** No dedicated blueprint or operational-data file is known yet. Until one exists, treat the magnetosphere platform as a **station-class capital structure** for planning and AI Manager scoring. Exact structure type and ports remain OPEN for review after this page.

---

## Primary Architecture — L1 Superconducting Dipole (DIRECTION / Recovered)

**Position**  
Mars–Sun L1 (Sun-World L1). Recovered lore states approximately **1 million miles ahead of Mars**.

**Core hardware**  
- Superconducting magnet / magnet coils  
- Nuclear or fusion power cores (early tiers)  
- Heavy structural alloys / I-beam framing  

**Material sourcing (preferred direction + recovered)**  
- **Preferred:** Structural and bulk material from Phobos/Deimos mines and local orbital industry, using the same construction techniques already used for stations/depots; specialty items (e.g. superconducting feedstock) imported as needed (Ceres/Belt sources appear in recovered notes).  
- Recovered lore also pointed at Ceres/Belt superconducting material delivered to a Mars L1 assembly site — compatible with the preferred path (imports for specialty mass, local for bulk).

**Priority**  
Mars is the clear first recipient. Recovered Planetary Terraforming SOP language treated orbital protection as early in the terraforming sequence. Owner direction (2026-11) clarifies: **orbital/moon industry and access footholds first; magnetosphere before high-throughput atmospheric modification** — not “no foothold until the shield exists.”

**Retention figures already in design material**  
- Atmospheric-maintenance language: ~98 % retention at the highest tier  
- `terraforming_patterns.json`: `magnetosphere_retention: 0.95`  

These numbers are treated as existing design intent, not newly invented values.

---

## Power / Technology Tiers (Recovered)

Recovered material describes a three-tier evolution of the shield itself (not three competing locations):

| Tier | Power basis | Retention (recovered) | Notes |
|------|-------------|------------------------|-------|
| Tier 1 | Fusion-powered | 60–80 % | High maintenance, heat-limited |
| Tier 2 | Electromagnetic-core (EM-core) retrofit | 95 %+ | Near-zero maintenance; requires electromagnetic-core synthesis tech |
| Tier 3 | Wormhole-stabilized | ~100 % | Self-sustaining; requires advanced wormhole tech |

Complementary framing recovered from electromagnetic-power documents: fusion supplies local power; electromagnetic systems handle "big science" loads (shields, portals, tugs).

> **Terminology note:** On this page "EM-core" and "electromagnetic systems" refer to electromagnetic power and field generation for the magnetosphere.  
> Exotic Matter (also abbreviated EM on the wormhole/portal pages) is a separate concept and is documented only under Natural Wormholes & Exotic Matter and Portals & AWS.

Exact power draw in MW/GW was never recorded and remains OPEN.

---

## Prerequisite Relationship

High-throughput atmospheric injection (raw-gas mass-driver path or refined O₂/N₂ + CNT-shell path) requires the artificial magnetosphere (or equivalent L1 shield) to be already active. Otherwise injected gas is stripped by solar wind and the economics remain permanently leaky.

This relationship is already stated in the terraforming-options and ballistic-corridor pages; this page is the home for the shield itself.

Early Mars footholds, lean moon outposts, and orbital depot/station construction do **not** require the magnetosphere. Surface expansion and terraforming injection do care about sequencing relative to the shield (see Sequencing above).

---

## Alternative Architectures (OPEN)

These were mentioned in prior brainstorming and are recorded here so they are not lost. None have detailed design work.

| Architecture | Notes |
|--------------|-------|
| **Plasma torus** | Generated from Phobos/Deimos material (analogous to Io–Jupiter torus). Mentioned once as an alternative to the solid L1 dipole. No further design. Does not by itself require relocating either moon. |
| **Surface or near-surface superconducting loop** | Studied in real literature; not developed in recovered game material. |
| **Orbital ring / distributed coils** | Not developed beyond the primary L1 concept. |
| **Later moon relocation as L1 anchor** | Optional higher-tier path only; not preferred baseline (see Preferred form). |

Solar louvers / orbital panel swarms and surface ion towers appear in earlier retention-tier discussions. They improve retention but are **not** magnetosphere substitutes; they remain complementary tools documented elsewhere.

---

## Venus Question (OPEN)

Recovered material treats Venus purely as the industrial / gas-source hub and does **not** design an artificial magnetosphere for Venus.  

Session discussion has left open the possibility that both Mars and Venus may eventually receive the technology family. Until a decision is recorded, Venus remains OPEN.

---

## Construction Notes

- **Preferred build path:** After moon mines and local stations/depot exist, construct the L1 magnetosphere platform as a station-class structure using local feedstock and established techniques, plus imports for specialty components.  
- **Phobos/Deimos:** Remain in natural orbit as production nodes for this path. Long-duration drift of a moon toward L1 is **not** the preferred approach; it is retained only as a possible later option under higher-tier tug capability.  
- Field pre-charge and curvature-ramp timelines appear in system-expansion protocol material (hours to days for coil energization).  
- Full multi-phase construction sequence, labor/AI Manager tasking, ownership (e.g. local Development Corporation vs specialized authority), and depot roles at L1 remain incomplete.  
- **No blueprint / operational data** for this structure is known in-repo yet; classify as station-class capital structure until a blueprint review says otherwise.

---

## Explicitly OPEN (Do Not Invent)

- Target magnetic field strength (Tesla). NASA workshop language used a 1–2 T class dipole; the game never locked a number.  
- Total mass of the shield structure.  
- Continuous or peak power requirement (MW/GW).  
- Numeric capital cost.  
- Detailed construction staging, ownership, and AI Manager scoring weights.  
- Fail-safe behavior under extreme solar events (gameplay event concepts exist; design rules do not).  
- Whether Venus receives a parallel or later installation of the same technology family.  
- Exact structure blueprint, ports, and operational-data schema (none known yet).

---

## Relation to Other Systems

- **Mass-driver / ballistic corridor** — shield is a hard gate before high-throughput injection.  
- **Modular orbital panel swarms** — complementary (insolation, optional energy beaming); not a replacement.  
- **Cycler logistics** — outer-system hydrogen and feedstock still required for early terraforming chemistry; the shield does not remove that need.  
- **Local production preference** — once the atmosphere is retained, continuous emergency imports can stop; local chemical loops become sustainable.  
- **Station construction options** — lean moon outposts and local stations are the preferred industrial base that later feeds magnetosphere construction; moon relocation is not required.

---

## Relation to Protection Classes & Local Shielding

These three concepts operate at different scales and serve different purposes. They are **not** substitutes for one another.

| Concept | Scale | Purpose | What it covers |
|---------|-------|---------|----------------|
| **Planetary Protection Classes (PPC)** | Planetary / governance | Biological contamination risk management and extraction rights | Whether a body has life (complex or microbial), what extraction limits apply, which authority governs |
| **Local habitat shielding** | Habitat / personal safety | Radiation and decompression protection for individual structures | Regolith berms, lava tubes, pressurized domes, structural integrity — protects inhabitants from local environment |
| **Artificial magnetosphere** | Planetary / atmospheric retention | Retaining a rebuilt atmosphere against solar-wind stripping at L1 | Superconducting dipole shield; enables long-term atmospheric permanence; prerequisite for high-throughput gas injection |

### Key distinctions

- **PPC does not provide radiation protection.** Protection classes govern biological contamination and extraction governance. They say nothing about how inhabitants are shielded from stellar or cosmic radiation.
- **The artificial magnetosphere does not replace habitat shielding.** The L1 dipole retains the planet's atmosphere; it does not protect individual habitats from radiation, micrometeorites, or explosive decompression. Local shielding remains required regardless of magnetosphere status.
- **Habitat shielding requirements are determined by the local physical environment and occupancy requirements, not by PPC classification alone.** PPC governs biological contamination and permitted activities; it does not specify radiation shielding for inhabitants.

### Cross-links

- Protection class hierarchy and governance: **[Planetary Protection & Environmental Governance](planetary_protection_environmental_governance.md)**
- StarSim procedural generation and CelestialBody model contracts: **[StarSim Procedural Generation](../design/starsim_and_protection_classes.md)** (path may vary; see astronomy/design indexes)
- Local habitat construction options (lava tubes, regolith berms, pressurized domes): **[Surface Habitat Options](surface_habitat_options.md)**

### OPEN

- Whether PPC status influences additional biological containment or barrier requirements (for example, on Class-1 bodies near biospheres) is undecided. This concerns biological protection, not radiation shielding for inhabitants.
- Whether the artificial magnetosphere's Tier 2 (EM-core) retrofit provides any secondary radiation attenuation for surface habitats is undecided. Do not assume it does.

---

*This page consolidates recovered design intent from lore, SOP, atmospheric-maintenance, electromagnetic-power tier, prior Gemini session material, and 2026-11 owner direction on preferred L1 station/structure form and sequencing. Quantitative gaps remain OPEN. Cross-check against frozen documentation and any still-local JSON or task files before promoting any part to ESTABLISHED INTENT.*