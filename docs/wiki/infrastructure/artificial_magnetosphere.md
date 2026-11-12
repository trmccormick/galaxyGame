# Artificial Magnetosphere

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-10  
> *Audit Summary:* Not yet verified against code. Only points marked ESTABLISHED INTENT were stated by the owner.

> **Wiki section:** Infrastructure  
> **Status:** DIRECTION  
> *Candidate design intent consolidated from prior lore, SOP, atmospheric-maintenance, and Gemini session material. Not yet ESTABLISHED INTENT. Quantitative specs (field strength, mass, power, cost) remain OPEN.*

> **Cross-link:** Prerequisite language already appears in **[Terraforming Options](terraforming_options.md)** and **[Venus–Mars Ballistic Corridor](../technical/venus_mars_ballistic_corridor.md)**. High-throughput gas injection requires the shield to be active.

> **Cross-link:** Modular orbital panel swarms (reflectors / energy beaming) are documented in **[Modular Orbital Panel Swarms](modular_orbital_panel_swarms.md)**. Those are complementary atmospheric and power tools, not substitutes for the magnetosphere.

---

## Purpose

An artificial magnetosphere (magnetic dipole shield) is a planetary-scale atmospheric-retention system. It protects a planet's atmosphere against solar-wind stripping using a planetary-scale magnetic field, with the current proposed architecture located at the planet–star L1 point. Without it, continuous bulk injection of volatiles remains a permanent utility cost ("leaky bucket"). With it, atmospheric retention approaches permanence and emergency imports can be terminated.

Mars is the current example on this page; the concept applies to any atmosphere-retention scenario where solar-wind stripping threatens long-term atmospheric viability.

This page records the recovered design intent, the open alternatives, and the quantitative gaps that still need resolution before promotion to ESTABLISHED INTENT.

---

## Primary Architecture — L1 Superconducting Dipole (DIRECTION / Recovered)

**Position**  
Mars–Sun L1 (Sun-World L1). Recovered lore states approximately **1 million miles ahead of Mars**.

**Core hardware**  
- Superconducting magnet / magnet coils  
- Nuclear or fusion power cores (early tiers)  
- Heavy structural alloys / I-beam framing  

**Material sourcing (recovered)**  
Superconducting material is intended to be mined from Ceres (or broader Belt sources) and delivered to the Mars L1 station / depot for assembly.

**Priority**  
Mars is the clear first recipient. The shield is treated as Phase 1, Step 1a in the recovered Planetary Terraforming SOP — orbital protection before settlement or biosphere work begins.

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

---

## Alternative Architectures (OPEN)

These were mentioned in prior brainstorming and are recorded here so they are not lost. None have detailed design work.

| Architecture | Notes |
|--------------|-------|
| **Plasma torus** | Generated from Phobos/Deimos material (analogous to Io–Jupiter torus). Mentioned once as an alternative to the solid L1 dipole. No further design. |
| **Surface or near-surface superconducting loop** | Studied in real literature; not developed in recovered game material. |
| **Orbital ring / distributed coils** | Not developed beyond the primary L1 concept. |

Solar louvers / orbital panel swarms and surface ion towers appear in earlier retention-tier discussions. They improve retention but are **not** magnetosphere substitutes; they remain complementary tools documented elsewhere.

---

## Venus Question (OPEN)

Recovered material treats Venus purely as the industrial / gas-source hub and does **not** design an artificial magnetosphere for Venus.  

Session discussion has left open the possibility that both Mars and Venus may eventually receive the technology family. Until a decision is recorded, Venus remains OPEN.

---

## Construction Notes (Partial / Recovered)

- Phobos has been discussed as both an anchor for solar-reflector infrastructure and a possible base / material source for L1 shield work (including a long-duration drift toward L1).  
- Field pre-charge and curvature-ramp timelines appear in system-expansion protocol material (hours to days for coil energization).  
- Full multi-phase construction sequence, labor/AI Manager tasking, and depot roles at L1 are still incomplete.

---

## Explicitly OPEN (Do Not Invent)

- Target magnetic field strength (Tesla). NASA workshop language used a 1–2 T class dipole; the game never locked a number.  
- Total mass of the shield structure.  
- Continuous or peak power requirement (MW/GW).  
- Numeric capital cost.  
- Detailed construction staging, ownership, and AI Manager scoring weights.  
- Fail-safe behavior under extreme solar events (gameplay event concepts exist; design rules do not).  
- Whether Venus receives a parallel or later installation of the same technology family.

---

## Relation to Other Systems

- **Mass-driver / ballistic corridor** — shield is a hard gate before high-throughput injection.  
- **Modular orbital panel swarms** — complementary (insolation, optional energy beaming); not a replacement.  
- **Cycler logistics** — outer-system hydrogen and feedstock still required for early terraforming chemistry; the shield does not remove that need.  
- **Local production preference** — once the atmosphere is retained, continuous emergency imports can stop; local chemical loops become sustainable.

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

- Protection class hierarchy and governance: **[Planetary Protection & Environmental Governance](../infrastructure/planetary_protection_environmental_governance.md)**
- StarSim procedural generation and CelestialBody model contracts: **[StarSim Procedural Generation](../design/starsim_and_protection_classes.md)**
- Local habitat construction options (lava tubes, regolith berms, pressurized domes): **[Surface Habitat Options](./surface_habitat_options.md)**

### OPEN

- Whether PPC status influences additional biological containment or barrier requirements (for example, on Class-1 bodies near biospheres) is undecided. This concerns biological protection, not radiation shielding for inhabitants.
- Whether the artificial magnetosphere's Tier 2 (EM-core) retrofit provides any secondary radiation attenuation for surface habitats is undecided. Do not assume it does.

---

*This page consolidates recovered design intent from lore, SOP, atmospheric-maintenance, electromagnetic-power tier, and prior Gemini session material. Quantitative gaps remain OPEN. Cross-check against frozen documentation and any still-local JSON or task files before promoting any part to ESTABLISHED INTENT.*
```
