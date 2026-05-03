# EM Technology Tree
**Location**: `docs/architecture/systems/em_technology_tree.md`
**Status**: Canonical — required reading before any warp, portal, or AWS implementation
**Written**: 2026-04-24
**Authority**: Developer design decisions 2026-04-24

> This document is the source of truth for how EM technology progresses in the game.
> All five levels emerge from the same fundamental discovery — exotic matter (EM)
> ejected by natural wormholes. Do not implement any level out of sequence.
> Do not add warp drive or portal tech without the prerequisite levels in place.

---

## What Exotic Matter (EM) Is

Exotic matter is a substance with negative mass-energy density ejected naturally
by unstable wormhole apertures. The more unstable a wormhole becomes, the more
EM it ejects. This feedback loop is both the warning sign of impending collapse
and the primary source of harvestable EM in the early game.

EM is the foundation of every advanced technology in the game:
- Wormhole stabilization
- Artificial wormhole construction
- Portal gate networks
- Warp drive propulsion

Controlling EM supply means controlling the pace of technological expansion.

---

## The Five Levels

---

### Level 1 — EM Harvesting

**Prerequisite**: Natural wormhole observed and studied
**Unlocked by**: Eden research data reconstructed post-Snap (see storyline doc)

**What it is**: Discovery that natural wormholes eject exotic matter during
instability cycles. Development of EM skimmer infrastructure to collect,
store, and transport harvested EM.

**Key insight**: Unstable wormholes eject MORE EM than stable ones. Eden's
wormhole was chronically unstable — making Eden the leading EM research site
pre-Snap. Eden accumulated significant EM stockpiles during their isolation.

**Gameplay unlocks**:
- EM skimmer craft (orbital harvesting fleet)
- EM storage facilities at settlements
- EM as a tradeable resource on the market
- Foundation for all subsequent levels

**Infrastructure required**:
- Orbital EM skimmer fleet
- EM storage at nearby settlement
- Transport route to move EM to research/construction sites

**Current game state**: This is the active development level. Luna precursor
phase. EM harvesting service complete.

---

### Level 2 — Wormhole Stabilization

**Prerequisite**: Level 1 EM Harvesting + Counterbalance Rule discovered
**Unlocked by**: Post-Snap forensic analysis comparing Eden pre-Snap data
against System B NWH observations (see storyline doc)

**What it is**: Discovery that wormhole apertures seek mass equilibrium —
they destabilize when mass anchoring is insufficient on either side.
Harvested EM can be refocused at the aperture mouth to artificially
supplement insufficient natural mass, restoring stability.

**The Counterbalance Rule** (locked):
- Every wormhole aperture requires sufficient mass on both sides
- Natural anchors (gas giants) are most efficient
- Harvested EM refocused at the aperture supplements insufficient mass
- Without counterbalance, aperture destabilizes → more EM ejection →
  accelerating feedback loop → eventual Snap

**Stabilization Satellites**:
Temporary infrastructure — EM emitters in orbital formation around
the aperture mouth. Focus harvested EM continuously at the aperture.
Power hungry, requires steady EM supply. Used as scaffolding while
permanent AWS mass anchoring is constructed. Removed once AWS is stable.

**Gameplay unlocks**:
- Stabilization satellite construction and deployment
- Wormhole stability monitoring (early warning system)
- Foundation for AWS construction (Level 3)
- Understanding of Snap event mechanics

**What this does NOT unlock**:
- Cannot restore a wormhole that has already Snapped
- Cannot steer a destabilizing wormhole's destination
- Cannot open new wormhole connections

---

### Level 3 — Artificial Wormhole Station (AWS)

**Prerequisite**: Level 2 Stabilization + significant EM reserves
**Unlocked by**: LDC/AstroLift collaboration post-Snap (see storyline doc)

**What it is**: Application of stabilization knowledge to force open a new
spatial rift at target coordinates. Unlike natural wormholes which form
spontaneously, an AWS opens a connection to a KNOWN destination — precision
impossible with natural wormholes.

**Requirements**:
- Massive EM reserves (largest single EM expenditure in the game)
- Mass anchor at the AWS location (gas giant preferred)
- Known destination coordinates (surveyed before opening)
- If no suitable mass anchor: Barbell Strategy (two AWS 180° apart,
  using the local star as central fulcrum)

**Mass anchor options** (in order of efficiency):
1. Gas giant (Jupiter, Saturn scale) — most efficient, least EM needed
2. Brown dwarf — 13-80x Jupiter mass, can anchor multiple AWS simultaneously
3. Barbell Strategy — two AWS stations using star as fulcrum, EM intensive
4. Stabilization satellites — temporary only, not permanent solution

**Brown Dwarf Hubs**: Because a brown dwarf can anchor multiple AWS stations,
it becomes a galactic switchboard — radial logistics to any connected system
without linear multi-hop jumps. Controlling a brown dwarf hub is one of the
highest-value strategic positions in the late game.

**Gameplay unlocks**:
- Inter-system connections to known destinations
- Portal gate network foundation (Level 4)
- AstroLift cycler route expansion
- Faction politics around AWS construction rights and transit fees

**Sol's AWS Build Sequence** (canonical order):
1. AWS-Sol-1 opposite Saturn → Eden (reconnection mission)
2. Stabilization sats deployed at Eden aperture (temporary)
3. Eden builds permanent anchor solution (gas giant or Barbell)
4. AWS-Sol-2 or AWS-Eden-2 → System B (expansion)
5. AWS-Eden-3 → completes Sol-Eden-SystemB triangle
6. Further expansion as new systems are surveyed

---

### Level 4 — Portal Technology

**Prerequisite**: Level 3 AWS + miniaturization research
**Unlocked by**: Peacetime research following Snap crisis resolution

**What it is**: Miniaturized wormhole technology using quantum entanglement
to pair two gate endpoints. Low EM consumption. Small aperture — people and
small cargo only, not bulk freight.

**How it works**:
- Gates are manufactured as entangled pairs
- One gate physically transported to destination (deployment mission)
- Once both gates are placed, transit is instant and cheap to operate
- No mass anchor required at this scale
- Range: intra-system at Level 4a, inter-system hub-to-hub at Level 4b

**Level 4a — Intra-system portals**:
Instant transit between bases within the same solar system.
Replaces shuttle runs for personnel and small cargo.
First placement at a new outpost requires physical delivery mission.

**Level 4b — Inter-system portal hubs at AWS stations**:
Portal gates installed at AWS stations enable player jump travel
across the wormhole network — EVE Online style gate travel.
Players jump station to station across known space without sitting
on slow transit craft.

```
Player travel pattern:
  Portal jump → AWS Station A
  Grab local shuttle to next AWS
  Portal jump → AWS Station B
  Portal jump to destination base within system
```

**What portals are NOT for**:
- Bulk ore, fuel, construction materials — cyclers handle this
- Large equipment or vehicles
- Anything that needs to move in volume

**Strategic implications**:
- First player to place a portal gate at a new outpost controls
  instant access to that location
- Early portal placement is a strategic land-grab
- AWS stations become doubly valuable — wormhole anchor AND portal hub

**Gameplay unlocks**:
- Instant player movement across known space
- Personnel rapid deployment for AI Manager
- Emergency evacuation routes
- High-value low-mass cargo instant delivery (medicine, electronics)

---

### Level 5 — Warp Drive

**Prerequisite**: Level 1 EM Harvesting + Level 4 research + significant
EM propulsion research (emerges from accumulated EM knowledge)
**Unlocked by**: Long-term research — late game technology

**What it is**: EM used to generate nacelle warp bubble around a ship.
Ship carries its own EM reserve. No fixed endpoints — can reach any
system, wormhole network optional.

**The Nacelle Configuration** (from White et al. 2025):
Separate cylindrical nacelles generate the warp bubble geometry.
Interior remains in flat space-time — crew and electronics safe
from tidal forces. Resemblance to USS Enterprise nacelles is
intentional in the real physics paper this is based on.

**The Snowplow Effect** (mandatory gameplay knowledge):
Warp bubble accumulates interstellar hydrogen and dust during transit.
Particles trapped at leading edge carry massive kinetic energy.
MUST be safely discharged before arrival — Safe Arrival Protocol required.

**Safe Arrival Protocol** (required for all warp arrivals):
1. Calculate Exclusion Radius for destination body (mass-based)
2. Drop out of warp OUTSIDE Exclusion Radius
3. Aim trajectory at empty space (Dead Zone) not at planet
4. Execute the Flush — discharge accumulated particles as
   directional Radiation Flare into void
5. Use conventional propulsion for final approach (The Last Mile)

**The Warp Bomb** (violation of Safe Arrival Protocol):
Intentional or negligent violation of the protocol. Exiting warp
directly within a planet's atmosphere releases relativistic shockwave.
Can strip atmosphere, render settlements uninhabitable via radiation,
or overwhelm AWS resonance sensors triggering a Snap Event.
Strategic weapon. War crime under interplanetary law (if enforced).

**EM_Friction**: Distance from natural mass anchor increases decay
rate of EM used in propulsion. Warp ships carry limited EM reserves.
Bulk cargo still cheaper on cyclers — warp does not replace cyclers,
it supplements them for time-sensitive or high-value transit.

**Gameplay unlocks**:
- Reach any system without wormhole network dependency
- AstroLift cycler dominance disrupted (not destroyed)
- Warp Bomb as strategic threat — political consequences
- Deep space exploration beyond known wormhole network
- Late game player power expression

---

## Technology Interdependencies

```
Natural Wormhole Discovery
        ↓
Level 1 — EM Harvesting ←─────────────────────────┐
        ↓                                          │
Level 2 — Wormhole Stabilization                   │
        ↓                                          │
Level 3 — AWS (Artificial Wormhole Station)        │
        ↓                                          │
Level 4a — Intra-system Portal Tech                │
        ↓                                          │
Level 4b — Inter-system Portal Hubs at AWS         │
        ↓                                          │
Level 5 — Warp Drive ──────────────────────────────┘
          (also draws on accumulated Level 1-4 knowledge)
```

Portal tech and warp drive are two applications of the same physics.
They are not separate tech trees — they emerge from the same fundamental
understanding of exotic matter.

---

## Controlled NWH Snap — Advanced Technique

**Not a technology level** — an application of Level 2 knowledge.
Discovered during Sol's experiment removing stabilization sats from
System B NWH for study.

**What it is**: By sending sufficient mass through a destabilizing NWH
at the right moment in the decay cycle, the snap can be triggered
deliberately rather than waiting for natural collapse.

**What you CAN control**: WHEN the snap occurs.
**What you CANNOT control**: WHERE the aperture snaps to.
The destination is determined by mass distribution in the surrounding
region — nature finds its own equilibrium. Cannot be steered.

**The process**:
1. Identify unstable NWH (or allow stabilized NWH to destabilize
   by removing stabilization sats)
2. Survey surrounding space thoroughly — identify likely destination
   based on mass distribution data (educated gamble, not precision)
3. Send sufficient mass through at the optimal decay moment
4. Asteroid relocation tugs are the primary tool for mass delivery
5. Aperture snaps — destination unknown until it opens

**Risk**: Destination could be empty void, stellar interior, or
populated system (unintended first contact).

**Strategic value**:
- Cheaper than AWS for opening new connections
- One-way — existing connection lost permanently
- Asteroid relocation tugs become dual-use: mining AND NWH steering
- Reading mass distribution data becomes a valuable expertise

**Political implications**:
Anyone with asteroid relocation tugs and enough mass can trigger
a controlled snap. This makes natural wormholes a strategic vulnerability
— a rogue actor could redirect Sol's NWH. Tugs become regulated assets.

---

## Backend Implementation Notes

```ruby
# Services needed
WarpArrivalService         # calculates Radiation_Vector, checks Exclusion_Zone
WormholeStabilityService   # monitors EM output, predicts instability
ControlledSnapService      # mass delivery calculation, snap trigger timing
EmRefocusingService        # stabilization sat EM focusing at aperture

# Models needed
ExclusionZone              # calculated on CelestialBody, mass-based formula
GravityLoad                # tracks gravitational stress on WormholeNetwork
EmFriction                 # decay rate of EM in warp propulsion by distance
StabilizationSatellite     # temporary aperture stabilization infrastructure
PortalGate                 # entangled pair, tracks both ends, deployment status

# Key attributes
WormholeNetwork.gravity_load        # total stress across all active gates
CelestialBody.exclusion_radius      # calculated from mass
NaturalWormhole.em_output_rate      # increases with instability
NaturalWormhole.stability_index     # decreasing → approaching snap
PortalGate.entangled_pair_id        # links two gates manufactured together
PortalGate.deployed                 # both ends must be deployed to activate
WarpShip.em_reserve                 # current EM fuel level
WarpShip.accumulated_particles      # snowplow buildup — must flush before arrival
```
