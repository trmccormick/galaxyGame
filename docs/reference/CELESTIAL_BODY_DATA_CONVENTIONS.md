# Celestial Body Data Conventions
**Created**: 2026-05-01
**Last Updated**: 2026-05-02
**Location**: /docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md

---

## Purpose

This document defines the conventions for celestial body data in
Galaxy Game. It covers how data is structured in sol.json,
sol-complete.json, and any future star system JSON files. These
conventions ensure the game engine reads world data correctly and
that future agents do not introduce data errors.

---

## Core Principle — Data Driven Architecture

**JSON describes what is estimated to exist. The game engine determines state and emergent interactions.**

- JSON data represents scientific estimates based on known survey
  data — not exhaustive inventories of all possible resources
- Survey results are guides, not guarantees — actual deposits
  discovered may vary from estimates
- The physical state of any compound is determined at runtime
  by local world conditions
- Terraforming and large scale resource extraction involve
  emergent chemical interactions between compounds that cannot
  be fully pre-calculated from static data — TerraSim models
  these progressively
- Service logic must never hardcode physical state assumptions
- New world types must work without service code changes
- Generated worlds have no JSON data — AI Manager spawns
  resource deposits procedurally on survey

---

## What "Volatile" Means in This Game

The term **volatile** refers to compounds that are gaseous at Earth
standard temperature and pressure (STP). This is a chemical
classification, not a description of physical state on any given body.

Examples of volatiles: H2O, CO2, CH4, N2, NH3, He3, SO2

On different bodies these same compounds exist in different states:
- H2O is liquid on Earth, ice in Luna PSR craters, vapour on Venus
- CH4 is gas on Earth, liquid lakes on Titan, ice on Pluto
- CO2 is gas on Earth, dry ice at Mars poles, supercritical on Venus

**The `stored_volatiles` field name describes chemical classification,
not physical state.** Never assume a volatile is gaseous just because
it appears in `stored_volatiles`.

---

## Sphere Model — Data Separation Rules

The game uses a modular sphere architecture. Each sphere tracks its
own data. Never duplicate data across sphere boundaries without
physical justification.

| Sphere | Tracks | Notes |
|---|---|---|
| `geosphere` | Compounds in crust, regolith, subsurface, trapped geological pockets | See stored_volatiles section |
| `atmosphere` | Body-wide gaseous composition, pressure, mass | Also used for contained local atmospheres |
| `hydrosphere` | Liquid and ice bodies as fluid systems | Varies by body — not always water |
| `biosphere` | Biological material, organic compounds | Abiotic compounds belong elsewhere |

### The Same Compound Can Exist in Multiple Spheres

A compound appearing in both `geosphere.stored_volatiles` AND
`atmosphere.composition` on the same body is correct if it
physically exists in both places. Examples:

- Mars: CO2 exists in atmosphere AND in polar caps AND in regolith
- Earth: CH4 exists as natural gas in geosphere AND trace amounts
  in atmosphere
- Luna: He3 exists in regolith (geosphere) only — not in atmosphere

### What Makes a stored_volatiles Entry Wrong

An entry in `stored_volatiles` is incorrect only if:
- The compound has no physical basis in the geosphere of that body
- It duplicates data that belongs exclusively in another sphere
  with no geosphere presence (e.g. Luna's N2 was listed as
  `atmosphere` — Luna has no nitrogen in its crust AND no
  atmosphere model, so the entry had no valid home)
- The values are physically impossible for that body
  (e.g. Luna having oceans: 1.35e+21)

---

## stored_volatiles — Field Definition

`geosphere_attributes.stored_volatiles` contains volatile compounds
physically present in the crust, regolith, subsurface, or trapped
geological structures of a body. Values represent estimated total
amounts based on confirmed scientific data where available.

**This is a scientific reference layer** — it records what exists
and in what quantity. It does not define where specific deposits
are located. Deposit locations are either in geological feature
files (confirmed) or spawned by the AI Manager on survey
(unconfirmed/generated).

### Storage Mechanism Keys

Each entry under a compound describes HOW that compound is stored
and therefore HOW it is extracted. Different storage mechanisms
require different equipment and industrial processes.

| Key | Meaning | Extraction Method | Equipment Tier |
|---|---|---|---|
| `regolith` | Compound bound in surface regolith | TEU bakeout or PVE processing | Early ISRU |
| `psr_deposits` | Solid ice in permanently shadowed regions | Physical ice mining | Ice mining operation |
| `polar_caps` | Compound frozen at poles on atmospheric bodies | Surface mining | Mid-tier |
| `clathrates` | Compound trapped in ice crystal structures | Drilling and gas collection | Advanced |
| `sedimentary_rocks` | Compound bound in rock formations | Chemical extraction | Advanced |
| `subsurface_ice` | Confirmed subsurface ice deposits | Drilling | Advanced |
| `geological_pockets` | Gas trapped in geological structures | Controlled extraction or release | Advanced |

### Geological Gas Pockets

Volatile gases can exist as trapped pockets in geological structures
on any body — natural gas pockets, volcanic gas chambers, impact
compression voids. These are valid geosphere entries regardless of
surface conditions.

Trapped gas pockets are modeled using the existing atmosphere model
attached to a geological feature record — the same pattern used for
lava tube habitats. This means:

- No new code is needed to model natural gas pockets
- A discovered gas pocket gets an atmosphere model instance
- The same TerraSim transfer mechanics apply at any scale

**Extraction is a controlled resource transfer event:**
- Mining a gas pocket → resource goes to storage/processing
- Releasing a gas pocket → TerraSim transfers mass to body atmosphere
- Pressurizing a sealed structure → transfer stored gases into
  geological feature atmosphere instance

This is the same operation as terraforming at different scale.
A player pressurizing a lava tube uses the same mechanics as
terraforming a planet — same code path, different scale parameters.

### Early ISRU vs Advanced Mining

Early ISRU (Luna MVP) accesses only:
- `regolith` — scoop and process via TEU or PVE
- `psr_deposits` — ice mining at confirmed PSR locations

Everything else requires advanced equipment and a discovered deposit
location. The game engine gates accessibility by equipment tier,
not by data presence. A compound existing in `stored_volatiles`
does not mean it is immediately accessible — it means it exists
on the body and can eventually be accessed with appropriate
technology.

---

## psr_deposits — Permanently Shadowed Region Ice

`psr_deposits` is the standard key for volatile ice deposits found
in permanently shadowed regions on airless or near-airless bodies.

### Rules
- Applies to any airless body where crater geometry creates
  permanent shadow — not limited to polar regions
- Any permanently shadowed crater at any latitude qualifies
- Not water-specific — compound key defines what is present,
  `psr_deposits` defines the storage condition
- Can apply to any volatile that freezes under PSR conditions
  (H2O on Luna/Mercury, CH4 on Titan, N2 on Pluto)
- Atmospheric bodies use `polar_caps` instead — different mechanism

### Bodies with Confirmed psr_deposits
| Body | Compound | Value | Source |
|---|---|---|---|
| Luna | H2O | 2.7e+19 | Confirmed — LCROSS impact data |
| Mercury | H2O | 1.0e+14 | Confirmed — MESSENGER data |

### Deprecated Terms — Do Not Use
- `polar_craters` → use `psr_deposits`
- `ice_caps` on airless bodies → use `psr_deposits`
- `polar_ice` → too ambiguous, use specific mechanism key

---

## Atmosphere Model Reuse Pattern

The atmosphere model is not limited to body-wide atmospheres.
It is attached to any sealed or semi-sealed structure that contains
a gaseous environment:

| Context | Atmosphere Model Attached To |
|---|---|
| Planet/moon | Celestial body |
| Lava tube habitat | Geological feature record |
| Natural gas pocket | Geological feature record |
| Pressurized crater dome | Structure record |

**Pressurization workflow (any scale):**
1. Source: `stored_volatiles`, storage tanks, or body atmosphere
2. Transfer: TerraSim resource transfer event
3. Destination: Target atmosphere model instance
4. Tracking: `stored_volatiles` totals decrease, target atmosphere
   composition and pressure update
5. Seal integrity: tested and adjusted before full pressurization

This is identical to terraforming at planetary scale. The player
learns these mechanics at lava tube scale and applies them globally.

---

## TerraSim Integration — Volatile Tracking

When volatiles move between spheres or structures TerraSim manages
the transfer. The three systems that must stay in sync:

1. **`stored_volatiles`** — total reservoir remaining in geosphere
2. **Geological feature atmosphere instances** — specific accessible
   pockets that have been discovered or created
3. **Body atmosphere** — what has been released to the surface

**Implementation note (2026-05-02)**: The atmosphere concern is
already written for lava tube and worldhouse structures. Extending
it to natural geological gas pockets requires minimal adjustment —
allowing the concern to attach to a geological feature record of
pocket type. The core transfer mechanics via TerraSim are already
in place. The remaining gap is connecting `stored_volatiles` totals
to spawned geological feature instances so amounts stay in sync
when pockets are discovered, mined, or released.
See backlog task: AI Manager Resource Spawning System.

---

## Real Data vs Procedural Data

### Known Bodies (Sol System)
- Only confirmed scientific data goes in JSON
- Estimated amounts acceptable where science provides ranges
- Speculative deposits NOT hardcoded — AI Manager spawns them
- Confirmed deposit locations in geological feature files
- Unconfirmed deposit locations spawned by AI Manager on survey

### Generated Bodies
- JSON files are produced by StarSim and follow the same sphere
  separation conventions as sol.json
- Fields like `volatile_reservoir` and `material_yield_bias` are
  StarSim-specific hints for the AI Manager — they do not replace
  `stored_volatiles` and should be treated as generation metadata
- `stored_volatiles` will be absent on first generation — the AI
  Manager resource spawning system handles deposit creation on
  first survey, the same role `stored_volatiles` plays for known
  worlds
- Same storage mechanism keys apply when `stored_volatiles` is
  populated
- Generated files may require manual tweaking before use in game —
  flag any format inconsistencies against this document

### What Goes Where
| Data Type | Location |
|---|---|
| Total estimated amounts | `stored_volatiles` in sol.json |
| Confirmed deposit locations | geological features files |
| Unconfirmed deposit locations | Spawned by AI Manager on survey |
| Physical landforms | geological features files |
| Contained atmospheres | atmosphere model on geological feature |

---

## Materials Array vs stored_volatiles

| Field | Purpose |
|---|---|
| `materials` | High level resource inventory — what exists and approximate abundance |
| `stored_volatiles` | Geosphere volatile storage — where and how volatiles are held in the ground |

Both may reference the same compound. The service layer reads both.

---

## Geological Features — Separation Rule

Physical landforms (craters, lava tubes, valleys, ridges) and
confirmed deposit locations belong in separate geological feature
files, not inline in sol.json.

**Correct pattern:**
data/json-data/geological_features/luna/craters.json
data/json-data/geological_features/luna/lava_tubes.json

Never embed geological feature data inline in sol.json or
sol-complete.json. If a feature file does not exist for a body
flag it as a gap — do not embed inline as a workaround.

---

## Agent Rules — Do Not Violate

1. Never add data to `stored_volatiles` without physical basis
   on that body
2. Never use `ice_caps` for airless bodies — use `psr_deposits`
3. Never use `polar_craters` — use `psr_deposits`
4. Never hardcode physical state assumptions in service logic
5. Never embed geological features inline in sol.json
6. The same compound can exist in multiple spheres if it
   physically exists in both — this is correct, not a violation
7. Always validate JSON after editing:
   `cat [file] | python3 -m json.tool --no-indent > /dev/null && echo "VALID"`
8. Never edit large JSON files with search/replace tools —
   use targeted manual edits in VSCode only
9. Both sol.json and sol-complete.json must always be kept in sync
10. Deposit locations are never hardcoded for unconfirmed deposits —
    AI Manager spawns them on survey

---

## Changelog

| Date | Change | Author |
|---|---|---|
| 2026-05-01 | Established psr_deposits standard, sphere separation rules | Claude (Session Strategist) |
| 2026-05-01 | Removed cross-sphere contamination from Luna stored_volatiles | Manual edit |
| 2026-05-02 | Full document written incorporating geological gas pocket model, TerraSim integration notes, atmosphere model reuse pattern | Claude (Session Strategist) |