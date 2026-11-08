# Artificial Magnetosphere

> **Wiki section:** Infrastructure  
> **Status:** DIRECTION  
> *Candidate design intent consolidated from prior lore, SOP, atmospheric-maintenance, and Gemini session material. Not yet ESTABLISHED INTENT. Quantitative specs (field strength, mass, power, cost) remain OPEN.*

> **Cross-link:** Prerequisite language already appears in **[Terraforming Options](terraforming_options.md)** and **[Venus–Mars Ballistic Corridor](../technical/venus_mars_ballistic_corridor.md)**. High-throughput gas injection requires the shield to be active.

> **Cross-link:** Modular orbital panel swarms (reflectors / energy beaming) are documented in **[Modular Orbital Panel Swarms](modular_orbital_panel_swarms.md)**. Those are complementary atmospheric and power tools, not substitutes for the magnetosphere.

---

## Purpose

An artificial magnetosphere (magnetic dipole shield) is the primary long-term solution for retaining a rebuilt Martian atmosphere against solar-wind stripping. Without it, continuous bulk injection of volatiles remains a permanent utility cost (“leaky bucket”). With it, atmospheric retention approaches permanence and emergency imports can be terminated.

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
| Tier 2 | EM-core retrofit | 95 %+ | Near-zero maintenance; requires EM-core synthesis tech |
| Tier 3 | Wormhole-stabilized | ~100 % | Self-sustaining; requires advanced wormhole tech |

Complementary framing recovered from EM-power documents: fusion supplies local power; EM systems handle “big science” loads (shields, portals, tugs).

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

*This page consolidates recovered design intent from lore, SOP, atmospheric-maintenance, EM-power tier, and prior Gemini session material. Quantitative gaps remain OPEN. Cross-check against frozen documentation and any still-local JSON or task files before promoting any part to ESTABLISHED INTENT.*
```
