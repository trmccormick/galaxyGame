# Station Construction Options

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-10 (orbital-first + Earth/L1 exception)  
**Related**: [artificial_magnetosphere.md](../infrastructure/artificial_magnetosphere.md), [terraforming_options.md](../infrastructure/terraforming_options.md), surface habitat and power pages, AI Manager economic loops

This page is the wiki home for orbital station and depot construction options. The governing rule is that these are **options** the AI Manager evaluates against local mass, fuel, tug class, existing infrastructure, and timeline. Nothing is hard-scripted as the single required path for Sol or for later systems.

---

## Design Principles

1. **Options, not scripts.** The AI Manager scores available paths; local conditions and tech generation decide which (or which mix) is used.
2. **Material preference order** (highest to lowest):
   - Local orbital material (bodies already in useful or near-useful orbits)
   - Relocate a small body, then hollow and fit-out
   - Surface-sourced local materials (then launch to orbit)
   - Imports from outside the system
3. **Fuel is always a cost.** Any mass that must change orbit or leave a gravity well consumes propellant. Fuel availability and production rate are first-class inputs into every option.
4. **Orbital presence first (default outside origin system).** Prefer establishing an orbital industrial node before heavy surface commitment when local conditions allow. Surface footholds are then fed from the orbital layer.
5. **Earth / L1 is the exception.** Humans start on the surface of the home world; the first orbital presence must be established by leaving that surface. This bootstrap is unique to the origin system.
6. **Reproduce the proven pattern where possible.** Luna → Earth–Moon L1 is the reference template. Other systems adapt the same logic to whatever low-gravity sources they actually have.
7. Early controlled-Sol runs and missions_v2 training data exercise the option set; they do not lock a single sequence.

---

## Earth–Moon Reference Pattern (locked exception)

Earth / L1 is the **exception** to the orbital-first preference used everywhere else.

- Humans begin on the surface of the home world. The first orbital presence (Luna → Earth–Moon L1) must be built by leaving that surface.
- **Only realistic path once Luna is available**: Luna sources and builds → feeds Earth–Moon L1.
- Earth does not yet possess asteroid-moving tugs. Asteroid-relocation options therefore require the L1 presence to exist first (so tugs and supporting industry can be built and operated from L1).
- Building large shipyards in LEO and lifting the bulk of mass from Earth is possible in principle but is not cost-effective once the Luna → L1 pattern is available. It is treated as an inferior option.

This is the baseline the AI Manager already knows. Outside the origin system the preferred pattern flips: start with orbital presence when possible, then feed surface activity from orbit.

---

## Mars Option Set

Mars follows the default **orbital-first** pattern (unlike Earth). Phobos and Deimos are available low-gravity orbital sources. Typical options the AI Manager can score:

1. **In-place conversion as mining outposts (early preferred)**  
   Hollow / process Phobos and Deimos in their natural orbits. Add slag-expulsion drives for station-keeping only. Primary early role is local resource production and the seed of an orbital industrial presence.

2. **Mine the moons and feed local station construction**  
   Use material and industrial capacity on the moons (or in Mars orbit) to fabricate modules, then assemble stations the same way Luna feeds Earth L1. Reproduces the known pattern with local mass; surface activity is fed from this orbital layer.

3. **Relocate smaller asteroids**  
   Capture bodies that fit current tug class, move them into useful Mars orbit or L1, hollow, and fit-out as depots or structural platforms.

4. **Later optional repositioning**  
   If fuel and capability exist, already-hollowed bodies may be slowly adjusted with slag or mass-driver propulsion. This is a higher-tier option, not part of the first controlled-Sol rake.

Magnetosphere / L1 shield construction remains independent of moon relocation (see [artificial_magnetosphere.md](../infrastructure/artificial_magnetosphere.md)).

---

## Venus Option Set

Venus also follows the default **orbital-first** pattern. It has no useful native large moons in the Phobos/Deimos class, so options collapse to:

1. **Local orbital / small-body relocation + hollow + fit-out**  
   Bring a suitable small body, convert it, and use it as the structural core or platform for depot and station. Preferred route to an early orbital industrial presence.

2. **Surface-to-orbit once local industry exists**  
   Higher energy cost (gravity well), still preferred over interplanetary imports when local capacity is mature. Used after (or in support of) the orbital layer, not as the primary bootstrap.

3. **Module import + assemble in place**  
   Lowest preference; mainly bootstrap or specialized components.

**Targets at Venus** are ordinary industrial infrastructure (orbital propellant/volatile depot, staging / manufacturing station, mass-driver support, etc.). These are **not** Artificial Wormhole Stations (AWS). AWS is a separate, later-gated system.

---

## Generic Decision Inputs for the AI Manager

When choosing among options the AI Manager weighs at least:

- Available local orbital mass vs. surface mass
- Fuel production rate and storage
- Current tug class and capacity
- Existing industrial nodes (can they feed an L1-style assembly pattern?)
- Timeline pressure and CapEx
- Whether a magnetosphere or other progressive infrastructure is also being scored in the same window

The same first-principles scoring travels outside Sol. Different systems will present different inventories of moons, small bodies, and tech generation; the option set stays the same, the ranking changes.

---

## Open Questions / Future Work

- Exact data structures for scoring material source + fuel cost + tug class together.
- How slag station-keeping performance is modeled for hollowed Phobos/Deimos-class bodies.
- Thresholds at which the AI Manager prefers small-body relocation over pure local-module construction.
- Parameterization of the same options for moonless vs. moon-rich targets beyond Sol.

All numerical values and ownership models remain **OPEN**.
