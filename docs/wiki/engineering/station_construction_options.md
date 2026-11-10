# Station Construction Options

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-10 (orbital-first + Earth/L1 exception; implementation boundary clarified)  
**Related**: [artificial_magnetosphere.md](../infrastructure/artificial_magnetosphere.md), [terraforming_options.md](../infrastructure/terraforming_options.md), surface habitat and power pages, AI Manager economic loops

This page is the wiki home for orbital station and depot construction options. These are **options for the AI Manager to evaluate**, not a claim that the current AI Manager already implements a complete construction-option planner. Local mass, fuel, tug class, existing infrastructure, and timeline are intended decision inputs. Nothing is hard-scripted as the single required path for Sol or for later systems.

This page covers **station and depot construction choices**. It does not define the complete settlement-progression sequence or determine the first access/foothold activity at every world. In particular, Venus atmospheric harvesting and its fuel/logistics loops are separate from the question of when and how a Venus orbital station is constructed.

---

## Design Principles

1. **Options, not scripts.** The intended AI Manager evaluates available paths; local conditions and technology determine which option or combination is appropriate.
2. **Material preference order** (highest to lowest):
   - Local orbital material (bodies already in useful or near-useful orbits)
   - Convert a suitable small body in place, then hollow and fit it out
   - Relocate a small body that the available tug class can handle, then hollow and fit it out
   - Surface-sourced local materials, then launch to orbit
   - Imports from outside the system
3. **Fuel is always a cost.** Any mass that must change orbit or leave a gravity well consumes propellant. Fuel availability and production rate are intended to be first-class inputs into option evaluation.
4. **Orbital presence first (default outside the origin system).** Prefer establishing an orbital industrial node before heavy surface commitment when local conditions allow. Surface footholds can then be supported from the orbital layer.
5. **Earth / L1 is the exception.** Humans start on the surface of the home world; the first orbital presence must be established by leaving that surface. This bootstrap is unique to the origin system.
6. **Reproduce the proven pattern where possible.** Luna → Earth–Moon L1 is the reference template. Other systems adapt the same logic to whatever low-gravity sources they actually have.
7. **Validation is a future objective.** Controlled-Sol runs should exercise the option set and produce evidence for evaluation. Missions V2 has not yet been used for AI Manager training; this page does not imply that training or validation has already occurred.

---

## Current Implementation Boundary

**Code status: prototype, not the complete option evaluator described by this design.**

The current `StarSim::ExpansionManagerService#execute_orbital_first_doctrine` is a limited first attempt. It:

- Creates a seed cycler / orbital depot with precursor-item metadata.
- Branches on whether the target is a moon and, for moons, uses a simple hardcoded size/gravity check (diameter greater than 3,000 km and surface gravity greater than 1.0).
- Creates a surface settlement for a moon that passes that check, a depot for a smaller moon, or an orbital hub for a planet.
- Creates a fixed set of bootstrap market orders and schedules a seven-day safety-net logistics job.

It does **not** yet compare construction alternatives or score available mass, fuel production, tug class/capacity, relocation feasibility, existing industrial capacity, cost, or timeline. The hardcoded moon check is not a general location-selection model. This implementation is evidence of an initial orbital-first prototype, not evidence that the broader decision framework is implemented, trained, or validated.

---

## Earth–Moon Reference Pattern (origin-system exception)

Earth / L1 is the **exception** to the orbital-first preference intended for other systems.

- Humans begin on the surface of the home world. The first orbital presence (Luna → Earth–Moon L1) must be built by leaving that surface.
- Once Luna is available, the reference path is Luna-sourced construction and logistics feeding Earth–Moon L1.
- Earth does not initially possess asteroid-moving tugs. Asteroid-relocation options therefore require the L1 presence to exist first, so suitable tugs and supporting industry can be built and operated from L1.
- Building large shipyards in LEO and lifting the bulk of mass from Earth is possible in principle, but is not the preferred economic path once the Luna → L1 pattern is available.

This is the reference pattern for future AI Manager planning. It should not be read as a claim that the current prototype already evaluates or selects this full sequence.

---

## Mars Option Set

Mars follows the intended default **orbital-first** pattern (unlike the Earth bootstrap). Phobos and Deimos provide low-gravity orbital sources. Options include:

1. **In-place conversion as mining outposts (early preferred)**  
   Convert Phobos and Deimos in their natural orbits. Under the initial Mk1 tug limitation, this avoids requiring relocation of the moons. Slag-expulsion thrust is for station-keeping only, not for relocating these bodies. Their primary early role is local resource production and the seed of an orbital industrial presence.

2. **Mine the moons and feed local station construction**  
   Use material and industrial capacity on the moons (or in Mars orbit) to fabricate modules, then assemble stations using the same general pattern as Luna feeding Earth–Moon L1. Surface activity can be supported from this orbital layer.

3. **In-place conversion of other suitable small bodies**  
   A later capability step allows suitable small bodies to be converted where they already are, without first moving them with a tug. This is distinct from relocating a body.

4. **Relocate larger or less conveniently placed bodies (later capability)**  
   Moving a body requires a tug class and capability appropriate to its mass and trajectory, or a capture-to-anchor approach. This is not an Mk1 capability. Exact Mk2/Mk3 mass thresholds and station-keeping delta-v budgets remain open.

5. **Later optional repositioning of converted bodies**  
   If the required propulsion, fuel, and control capabilities exist, an already-converted body may be repositioned. Slag station-keeping capability alone does not establish this ability.

The owner-harvested distinctions above are intentional: **in-place conversion is not relocation**, and station-keeping thrust is not a body-moving tug. The phase labels recorded in the migration log are retained there pending clarification of how they map to the broader game progression phases.

Magnetosphere / L1 shield construction remains independent of moon relocation (see [artificial_magnetosphere.md](../infrastructure/artificial_magnetosphere.md)).

---

## Venus Option Set

Venus can use the intended default **orbital-first station-construction** pattern. It has no useful native large moons in the Phobos/Deimos class, so station/depot options include:

1. **Local orbital material or small-body relocation + hollow + fit-out**  
   Convert a suitable body in place where possible, or bring in a body that the available tug capability can handle. Use it as the structural core or platform for a depot or station.

2. **Surface-to-orbit once local industry exists**  
   This has a higher energy cost because of Venus's gravity well, but may be preferable to interplanetary imports once local capacity is mature.

3. **Module import + assemble in place**  
   Lowest preference; mainly for bootstrap or specialized components.

**Scope note:** This option set concerns station/depot construction. It does not prescribe the first Venus foothold or the order of Venus atmospheric skimmer deployment, gas harvesting, fuel production, and logistics. Those operations should be evaluated on their own requirements and may support or precede orbital station construction.

Venus targets here are ordinary industrial infrastructure (orbital propellant/volatile depot, staging / manufacturing station, mass-driver support, etc.). These are **not** Artificial Wormhole Stations (AWS). AWS is a separate, later-gated system.

---

## Generic Decision Inputs for the AI Manager

The intended evaluator should consider at least:

- Available local orbital mass vs. surface mass
- Fuel production rate and storage
- Current tug class and capacity
- Whether a proposed body can be converted in place or must be relocated
- Existing industrial nodes and whether they can feed an L1-style assembly pattern
- Timeline pressure and capital expenditure
- Whether a magnetosphere or other progressive infrastructure is also being evaluated in the same planning window

The same first-principles options can be considered outside Sol. Different systems will present different inventories of moons, small bodies, and technology; the available options and their ranking will vary with those conditions.

---

## Open Questions / Future Work

- Exact data structures for scoring material source, fuel cost, tug class, and in-place conversion versus relocation together.
- How slag station-keeping performance is modeled for hollowed Phobos/Deimos-class bodies.
- Exact Mk2/Mk3 mass thresholds and relocation capabilities.
- Thresholds at which the AI Manager prefers small-body relocation over local-module construction.
- Parameterization of the same options for moonless vs. moon-rich targets beyond Sol.
- How Venus atmospheric harvesting and fuel/logistics operations establish or support the station-construction layer.

All numerical values and ownership models remain **OPEN**.
