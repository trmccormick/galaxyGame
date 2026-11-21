# Station Construction Options

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-14  
> *Audit Summary:* Not yet verified against code. Only points marked ESTABLISHED INTENT were stated by the owner.

**Status**: DIRECTION / OPEN (Sol bootstrap ESTABLISHED)  
**Last Updated**: 2026-11-14  
**Related**: [artificial_magnetosphere.md](../infrastructure/artificial_magnetosphere.md), [terraforming_options.md](../infrastructure/terraforming_options.md), [propulsion_and_heavy_tug_economy.md](../infrastructure/propulsion_and_heavy_tug_economy.md), [settlement_progression_and_footholds.md](../player/settlement_progression_and_footholds.md), [settlement_ownership_and_governance.md](../player/settlement_ownership_and_governance.md), surface habitat and power pages, AI Manager economic loops

This page is the wiki home for orbital station and depot construction options. The governing rule is that these are **options** the AI Manager evaluates against local mass, fuel, craft class, existing infrastructure, and timeline. Nothing is hard-scripted as the single required path beyond the required Sol bootstrap.

**Purpose of the work:** The AI Manager establishes footholds, stations, and supporting infrastructure to **open locations for people and players**. Equipment and industry are means to that outcome, not the end goal.

Generated systems will not match Sol. Different moons, no moons, dry rock, ice, different asteroid populations, and different fuel availability mean a single scripted sequence fails outside the origin system. Sol is the training ground where the option set is exercised; the same options travel outward and are re-ranked by local inventory.

---

## Design Principles

1. **Options, not scripts.** The AI Manager scores available paths; local conditions and tech generation decide which (or which mix) is used. Missions define the desired outcome; they do not prescribe a fixed sequence of every harvest, process, and build step.
2. **Material preference order** (highest to lowest):
   - Local orbital material (bodies already in useful or near-useful orbits)
   - Relocate a small body, then hollow and fit-out
   - Surface-sourced local materials (then launch to orbit)
   - Imports from outside the system
3. **Fuel is always a cost.** Any mass that must change orbit or leave a gravity well consumes propellant. Fuel availability and production rate are first-class inputs into every option. ISRU-first remains the default pressure. Do not assume ice or volatiles on a body until survey supports it.
4. **Orbital presence first (default outside origin system).** Prefer establishing an orbital industrial node before heavy surface commitment when local conditions allow. Surface footholds are then fed from the orbital layer.
5. **Required Sol bootstrap (ESTABLISHED).** The current owner-confirmed order is Luna foothold → L1 Depot → second depot near LEO → main station / shipyard infrastructure. Luna supplies bulk industrial output; Earth remains the source for specialized and high-tech imports as needed. Older frozen plans that place the LEO depot before the Luna foothold or L1 Depot are historical, not the current sequence.
6. **Reproduce the proven pattern where possible.** Luna → Earth–Moon L1 is the reference template at a given intensity (e.g. enough industry for a small ISS-scale crew and material to build the orbital station/depot). Other systems adapt the same logic to whatever low-gravity sources they actually have.
7. **New foothold → NPC Development Corporation.** When the AI Manager establishes a new foothold settlement, it generally forms a new NPC Development Corporation on that world or celestial body to own and oversee the settlement’s development. Ownership is explicit from day one and remains distinct from any later Colony governance (see settlement ownership and governance).
8. **Craft roles stay distinct.** Cyclers use various drives and can act as mobile construction bases. Asteroid relocation tugs carry the slag-engine / hollow-and-relocate loop. Mk-I supports in-place work only; it does not reposition Phobos, Deimos, or similar bodies.
9. Early controlled-Sol runs and missions_v2 / profile rake testing exercise the option set; they do not lock a single sequence beyond the required Sol bootstrap.

---

## Earth–Moon Reference Pattern (required Sol bootstrap)

Earth / L1 is the **required origin-system bootstrap**, not merely a preferred exception.

- Humans begin on the surface of the home world. The first orbital presence must be built by leaving that surface.
- **Required sequence (ESTABLISHED; owner-confirmed 2026-11-21):** establish the **Luna foothold**, then the **L1 Depot**, then the **second depot near LEO**, and then the **main station / shipyard infrastructure**. Luna supplies bulk industrial output; specialized and high-tech imports continue to come from Earth as needed. These open the wider system.
- **Only realistic construction path once Luna is available:** Luna sources and builds → feeds Earth–Moon L1.
- Earth does not yet possess asteroid-moving tugs. Asteroid-relocation options therefore require the L1 presence to exist first (so tugs and supporting industry can be built and operated from L1).
- Building large shipyards in LEO and lifting the bulk of mass from Earth is possible in principle but is not cost-effective once the Luna → L1 pattern is available. It is treated as an inferior option.

Outside the origin system the preferred pattern flips: start with orbital presence when possible, then feed surface activity from orbit. Station and depot *functions* remain necessary as infrastructure expands; their physical arrangement, scale, and construction style stay open to local conditions.

---

## Mars Option Set

Mars follows the default **orbital-first** pattern (unlike Earth). Phobos and Deimos are available low-gravity orbital sources. **No single path is correct.** The AI Manager scores local mass, fuel, craft class, survey results, and timeline, then chooses (or mixes) options.

### Early lean path (Luna-parallel brainstorm — one preferred early option)

One coherent early path mirrors early Luna at similar intensity: enough industry for a small ISS-scale crew and enough material to stand up an orbital depot (and later station), without committing to hollowed moon-stations or relocation.

1. **L1 shipyard** builds **one cycler** with **attached HLT support craft** (cyclers use various drives; not slag-dependent).
2. Cycler acts as the **construction base** in the Mars system and may make **multiple trips** back to Earth/L1. **No tug required.**
3. HLT moves equipment to **one moon** (Phobos *or* Deimos).
4. **Lean mining outpost** only (in place, Mk-I compatible):
   - Survey / site setup (**do not assume ice or volatiles**)
   - Deploy extraction gear, minimal power/comms, small stockpile
   - Support a small ISS-scale crew
   - Extract **structural / industrial feedstock** as survey allows
   - **Hollowing not required** early
5. Stand up a **Mars orbital depot** as a **separate** setup (not on the moon). Seed the depot with **imported propellant** on early cycler trips so cyclers can refuel. Local propellant only if survey and industry support it later.
6. **Station** (crew/industrial) can follow the depot; depot is on the critical path because it sustains the cycler loop.
7. **Mars surface** comes later, after orbital/moon presence and material feed are underway.
8. Second moon, second cycler, heavier industry = optional expansions once the refuel loop works.

**Out of scope for this early path:** embedded slag drives on the moons, fusion inside the moons, moon-as-station/depot, and any relocation. Those are later options.

**Dry moon:** structural feedstock may still be valid early; propellant stays imported (or from another known source) until a deliberate later path (e.g. fusion-tier industry + slag on a tug-class hollow program, or Mars surface volatiles) is chosen. Fusion itself has material needs; do not collapse “dry ⇒ slag drives” into one step.

### Other options the AI Manager may score

1. **Pure orbital assemble**  
   Deliver modules to Mars orbit and assemble station/depot with little or no moon work. Faster structure possible; weaker local-mass story.

2. **Import complete (or major) stations from L1 → assemble in Martian orbit**  
   Use existing L1 industry to build station units, ship them, final assembly at Mars. High import mass and fuel/time cost; useful bootstrap or parallel top-up when local feed is slow.

3. **Heavier in-place work on a moon**  
   Hollow and fit out a moon as station/depot in natural orbit (still no relocation under Mk-I). Different intent from lean mining outpost; more mass and time.

4. **Small-asteroid capture → hollow → station**  
   Requires an asteroid relocation tug (slag-engine loop is native to that craft when hollowing). Capture, move into useful orbit/L1, hollow, fit-out. Strong when tug class and a suitable body exist; not the opening move under Mk-I-only constraints.

5. **Later repositioning of worked moons**  
   With Mk2+ (or later tug/cycler capability), already-worked bodies may be moved if that scores better. Early path does not depend on this.

6. **Two-moon / multi-cycler expansion**  
   After one outpost + depot loop is healthy, open the second moon and/or add cyclers as capacity allows.

7. **Surface-first**  
   Usually scores poorly against orbital-first default; only when orbital options are blocked or clearly worse.

Magnetosphere / L1 shield construction remains **independent** of moon relocation or moon-as-station choices (see [artificial_magnetosphere.md](../infrastructure/artificial_magnetosphere.md)). High-throughput atmospheric injection cares that a shield is active; it does not require Phobos or Deimos to be moved.

### Mars L1 infrastructure sub-options (DIRECTION / OPEN)

**One valid path among others.** The preferred early Mars path remains: cycler + HLT → lean mining outpost on one moon (survey first, hollowing not required) → separate orbital depot → station later → surface later. Ranking depends on technology available at the time. This L1 sub-path is simply one coherent way to add progressive infrastructure into the option set.

* **Compact L1 magnetic shield station (~1–2 MW class).** Early / pre-settlement option: deploy a magnetic dipole station at Mars–Sun L1 before high-throughput atmospheric modification. Primary effect — deflects solar wind, creates protective magnetosheath over the planet, halts atmospheric stripping.
* **Modular octagonal CNT panel array at the same L1 location** (mid-to-late phase). Later option that can serve dual roles: local power generation for station systems + light reflection / concentration toward the surface. The frame is a standard 100 m class octagonal CNT structure with interchangeable PV or reflector infill and optional embedded solar-wind H₂ capture mesh. Panel geometry, ratios, and specific design parameters are **DIRECTION / design candidate**, not locked.

---

## Venus Option Set

Venus also follows the default **orbital-first** pattern. It has no useful native large moons in the Phobos/Deimos class, so options collapse to:

1. **Local orbital / small-body relocation + hollow + fit-out**  
   Bring a suitable small body (tug class required for relocation), convert it, and use it as structural core or platform for depot and station.

2. **Pure orbital assemble / module import**  
   Build from delivered modules when no suitable body is available or tug capacity is lacking.

3. **Surface-to-orbit once local industry exists**  
   Higher energy cost (gravity well); used after (or in support of) the orbital layer, not as the primary bootstrap.

**Targets at Venus** are ordinary industrial infrastructure (orbital propellant/volatile depot, staging / manufacturing station, mass-driver support, etc.). These are **not** Artificial Wormhole Stations (AWS). AWS is a separate, later-gated system.

---

## Craft role summary

| Craft | Role in construction options |
|-------|------------------------------|
| **Cycler** | Interplanetary delivery; mobile construction base; various drives (not slag-only). Configs (e.g. Mars Constructor) carry mining/construction gear and can transfer units to depot/station. |
| **HLT / Mk-I support craft** | Move equipment from cycler to surface or small body; **in-place work only** — does not reposition Phobos/Deimos-class bodies. |
| **Asteroid relocation tug** | Capture, relocate, hollow; **slag engines** use hollowing waste as reaction mass; hybrid propulsion possible. Later/heavier option when that class exists. |
| **Depot / station** | Permanent nodes; receive transferred gear; depot especially important for cycler refueling once seeded. |

---

## Generic Decision Inputs for the AI Manager

When choosing among options the AI Manager weighs at least:

- Survey results (ice/volatiles vs dry rock; structural feedstock)
- Available local orbital mass vs surface mass
- Fuel production rate, storage, and whether the depot is seeded
- Current craft class (cycler only vs tug available)
- Existing industrial nodes (can they feed an L1-style assembly pattern?)
- Timeline pressure and CapEx
- Whether a magnetosphere or other progressive infrastructure is also being scored in the same window

The same first-principles scoring travels outside Sol. Different systems will present different inventories of moons, small bodies, and tech generation; the option set stays the same, the ranking changes.

---

## Open Questions / Future Work

- Exact data structures for scoring material source + fuel cost + craft class together.
- How non-slag station-keeping is modeled for early lean outposts on natural moon orbits.
- Thresholds at which the AI Manager prefers small-body relocation (tug) over lean cycler + outpost or pure orbital assemble.
- Parameterization of the same options for moonless vs moon-rich targets beyond Sol.
- Numeric propellant seed sizes and cycler multi-trip cadence for the lean Mars path (remain OPEN; do not invent).

All numerical values remain **OPEN** unless marked ESTABLISHED INTENT elsewhere.
