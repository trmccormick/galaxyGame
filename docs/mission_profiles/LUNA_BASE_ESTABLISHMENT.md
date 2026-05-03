# Luna Base Establishment
**Created**: 2026-05-02
**Last Updated**: 2026-05-02
**Location**: docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md
**Status**: Active — Phase 1 MVP target

---

## Overview

Luna base establishment is the first and most critical mission
in the game. No other location can be developed until the
Luna→L1 supply loop is proven and operational. This is the
AI Manager's primary training ground — patterns learned here
apply to all subsequent locations with body-specific variations.

Earth is the only prior starting point. Everything originates
from Earth until Luna is self-sustaining.

---

## Strategic Importance

Luna is not just a destination — it is the industrial foundation
for the entire inner system expansion:

- First off-Earth ISRU operation
- Source of He3 for fusion power development
- Manufacturing base for L1 station components
- LOX supplier for inner system craft operations
- Proving ground for AI Manager decision-making

**The Luna→L1 loop must close before players arrive.**
The AI Manager runs this loop autonomously as precursor
infrastructure. Player first actions assume this loop is
already operational.

---

## Luna Resource Hierarchy

Resources are listed in priority order for early game.
Priority reflects scarcity, criticality, and extraction
difficulty.

### Tier 1 — Early ISRU (Regolith Only)
All from surface regolith scooping. No specialized location
needed. Available from day one of ISRU operations.

| Resource | Process | Equipment | Primary Use |
|---|---|---|---|
| O2 | PVE breaks metal oxides | PVE unit | Life support, LOX propellant |
| H2 | TEU bakeout solar-wind hydrogen | TEU unit | LH2 propellant, Sabatier feedstock |
| He3 | TEU bakeout from regolith | TEU unit | Fusion power, high-value export |
| Metals | PVE byproduct | PVE unit | Construction, manufacturing |

**Fuel strategy**: LH2/LOX bipropellant from regolith.
Both components produced locally. No imports needed for fuel
once ISRU is operational.

**Not CH4/LOX** — Luna has no carbon source early game.
CH4 must be imported. CH4/LOX is a Mars strategy
(CO2 atmosphere → Sabatier reaction).

### Tier 2 — Mid-tier (Specialized Equipment Required)
| Resource | Source | Equipment | Notes |
|---|---|---|---|
| H2O | PSR ice mining | Ice mining operation | Rationed for human consumption |
| He3 (bulk) | Expanded regolith ops | Multiple TEU units | Export revenue |

**H2O priority**: Water from PSR mining is rationed for
human consumption first, fuel synthesis last. Research
confirms PSR mining requires dedicated power infrastructure
operating in permanently shadowed regions — not early ISRU.

**PSR mining note**: PSRs are without sunlight by definition.
Operations require battery power with traverses into shadowed
areas. This is confirmed mid-tier by NASA LCROSS/Artemis
research. Do not move PSR mining to Tier 1.

### Tier 3 — Advanced (Later Game)
| Resource | Source | Notes |
|---|---|---|
| CH4 | Sabatier (CO2 import + H2) | Requires Venus skimmer operational |
| Rare earth elements | Specialized mining | KREEP deposits |
| Bulk construction materials | Expanded manufacturing | For export to L1 |

---

## Import Dependencies

What Luna cannot produce locally in early game and must import:

| Resource | Source | Delivery | Priority |
|---|---|---|---|
| CH4 | Titan skimmer or Earth tanker | HLT or Cycler | HIGH — needed for skimmer refueling |
| N2 | Titan skimmer | HLT skimmer | HIGH — habitat atmosphere mix |
| CO2 | Venus skimmer | HLT skimmer | MEDIUM — Sabatier feedstock |
| Advanced electronics | Earth | HLT→Cycler | HIGH — cannot manufacture locally |
| Solar panels | Earth | HLT→Cycler | HIGH — power infrastructure |
| Specialized fittings | Earth | HLT→Cycler | MEDIUM — manufacturing aids |

---

## Skimmer Craft Operations

HLT craft fitted as skimmers for early atmospheric harvesting.
All skimmers are owned and operated by AstroLift — not LDC.
Each skimmer has limited onboard processing — only enough to
refill its own propellant tanks for the return trip. All other
collected gases arrive at Luna as mixed atmospheric cargo
for the buyer to process locally.

**Cargo is not pre-sorted.** AstroLift delivers raw mixed
atmospheric gas. Market price is per unit volume/mass of
mixed cargo. LDC's onsite processing units determine what
value is extracted from the mix.

### Venus Skimmer (HLT fitted)
**Onboard processing**: CO2 separator → fills own LOX tank
for return trip only
**Needs from Luna**: CH4 only
**Delivers**: Mixed Venus atmosphere gases
(CO2, CO, SO2, trace gases — unprocessed mix)
**Key value**: Mixed gas enables Sabatier feedstock,
industrial chemical processing
**Note**: Luna must have CH4 available before Venus skimmer
can be refueled. Early game — import CH4 from Earth or Titan
skimmer first.

### Titan Skimmer (HLT fitted)
**Onboard processing**: CH4 separator → fills own CH4 tank
for return trip only
**Needs from Luna**: LOX only (available from regolith day 1)
**Delivers**: Mixed Titan atmosphere gases
(CH4, N2, trace gases — unprocessed mix)
**Key value**: Mixed gas provides CH4 for fuel and N2
for habitat atmosphere after LDC processing
**Note**: Easiest skimmer to support — Luna can provide LOX
immediately from regolith PVE. No import dependency for
skimmer refueling.

### Earth Skimmer (optional — AI Manager decision)
**Onboard processing**: O2 separator → fills own LOX tank
for return trip only
**Needs from Luna**: CH4 only
**Delivers**: Mixed Earth atmosphere gases
(N2, O2, Ar, trace gases — unprocessed mix)
**AI Manager calculates**: Is skimmer cost justified vs
shipping N2 tanks directly from Earth?
**Note**: Earth has highest gravity well of the three.
Direct tank imports may be more cost-effective than
a dedicated Earth skimmer. AI Manager decides based on
current supply chain state and demand.

### Sabatier Loop (mid-game closure)
Once Venus skimmer is delivering mixed gas regularly
and LDC is processing CO2 from the mix:
- Luna H2 (regolith TEU) + extracted CO2 → CH4 + H2O
- CH4 → refuels Venus and Earth skimmers
- H2O → human consumption (rationed)
- Loop closes — Luna becomes CH4 self-sufficient
- CH4 import dependency eliminated

---

## Organizations and Market Structure

Luna base establishment creates the first off-Earth market.
Understanding organizational ownership is critical for the
AI Manager to correctly price transactions and model the economy.

### Key Organizations

**LDC (Luna Development Corporation)**
- Operates Luna base infrastructure
- Owns ISRU operations
- Owns L1 Depot and L1 Shipyard
- Owns purpose-built craft produced at L1 Shipyard
- Revenue: LOX sales, He3 export, metals, docking fees,
  manufacturing contracts
- Role: buyer of imported gases, seller of locally
  produced resources

**AstroLift Corporation**
- Builds, owns, and operates ALL HLT craft
- Responsible for Earth→LEO operations
- Operates HLT skimmers to Venus and Titan
- LDC does not operate HLT craft — AstroLift is the
  service provider, LDC is the customer
- Similar operational model to SpaceX Starship operations
- Revenue: launch contracts, cargo delivery fees,
  mixed gas sales on arrival, standing contract revenue
- Role: primary importer of atmospheric gases to Luna

**Wormhole Consortium**
- Manages wormhole station network and logistics
- Does NOT own craft — cyclers, HLTs, skimmers are
  owned by individual corporations
- Revenue: wormhole transit fees, network maintenance

**Cycler Ownership**
Cyclers are owned by individual corporations — AstroLift,
LDC, or others. Not owned by the Wormhole Consortium.
The AI Manager tracks which organization owns each cycler
and charges/credits accordingly for each transit.

---

### Market Settlement on Arrival

When an AstroLift skimmer arrives at Luna with mixed gas
cargo, the AI Manager has three settlement options:

**Option 1 — Spot market sell order**
Post mixed gas cargo at market price. Wait for buyers.
Best when: market price is favorable and AstroLift
can afford to wait for best price.

**Option 2 — Quick buy order fill**
Fill an existing buy order already posted by LDC
or another buyer. Immediate settlement, no waiting.
Best when: LDC has posted buy orders at acceptable
prices and AstroLift wants immediate liquidity.

**Option 3 — Standing contract**
Pre-arranged price with LDC outside spot market.
Guaranteed buyer on arrival at agreed price.
Best when: both parties want supply chain stability
over market price optimization.

**Standing contracts are strategically important
for critical gases:**
- LDC needs steady mixed gas supply — life support
  processing cannot wait for spot market settlement
- Standing contract guarantees supply at agreed price
- AstroLift gets guaranteed revenue per run
- Both sides benefit from stability over price volatility
- AI Manager maintains standing contracts for critical
  supply runs and uses spot market for discretionary cargo

---

### Market Transactions — Early Game

Every resource transfer between organizations is a market
transaction tracked in GCC (Galactic Crypto Currency):

| Transaction | Seller | Buyer | Settlement |
|---|---|---|---|
| HLT launch | AstroLift | LDC | Per launch contract |
| Mixed Venus gas | AstroLift | LDC | Standing or spot |
| Mixed Titan gas | AstroLift | LDC | Standing or spot |
| LOX export | LDC | AstroLift/market | Spot or standing |
| He3 export | LDC | Market | Spot market, high value |
| Metals | LDC | Market | Spot market |
| Docking fees | LDC | AstroLift | Per docking event |
| Refueling | LDC | AstroLift | Per refueling event |
| CH4 (post-Sabatier) | LDC | Market | Spot market |

---

### Market Establishment Sequence

The market builds naturally as the Luna→L1 loop closes:

1. **Earth launch phase** — AstroLift charges LDC per
   HLT launch. First market transactions established.
2. **ISRU operational** — LDC begins LOX and He3 sales.
   First Luna export revenue.
3. **Titan skimmer arrives** — AstroLift sells mixed Titan
   gas to LDC. Standing contracts established for critical
   supply runs.
4. **Venus skimmer arrives** — AstroLift sells mixed Venus
   gas to LDC. LDC processes for CO2, SO2, other compounds.
5. **L1 Depot IOC** — LDC charges docking and refueling
   fees. AstroLift skimmers dock here instead of Luna surface.
6. **Sabatier loop closes** — LDC produces CH4 locally
   from processed CO2. CH4 standing contract with AstroLift
   no longer needed. LDC begins selling CH4 to market.
7. **L1 Shipyard operational** — LDC builds purpose-built
   craft. AstroLift retires skimmer/tanker role on non-LEO
   routes. Focuses on Earth→LEO permanently.

---

### Player Entry Point

Players enter after the AI Manager has established this
market. The market exists before players arrive.

Players can:
- Work for LDC (ISRU operations, construction contracts)
- Work for AstroLift (delivery contracts, skimmer runs)
- Independent trading (buy LOX from LDC, sell to passing craft)
- Negotiate their own standing contracts with any organization
- Eventually establish their own organizations

**Player market actions:**
- Players see live spot market prices
- Players can fill buy/sell orders like AstroLift AI does
- Players can negotiate standing contracts with organizations
- Players can undercut AstroLift on gas imports if they
  acquire their own craft
- AI Manager adjusts market prices based on supply/demand
  including player actions

---

## Luna→L1 Build Sequence

### Prerequisites on Luna (before L1 construction begins)
All of these must be operational before L1 Depot construction:

1. Regolith ISRU operational — O2, H2, He3, metals
2. 3D printer operational — mk1 I-beams and panels
   from regolith-derived materials
3. Mass launcher operational — throws components
   to L1 orbital position
4. HLT craft available — positions components
   for final assembly

### L1 Phase 1 — Depot
- Shell assembled from Luna-manufactured I-beams and panels
- HLT positions components, construction shuttles assemble
- Pressurized via atmosphere concern
  (same code pattern as lava tube habitat)
- Refueling capability established — LOX from Luna
- **Gate**: HLT skimmers now dock at Depot
  instead of landing on Luna surface
- Tankers begin Luna→L1 material runs

### L1 Phase 2 — Shipyard (after Depot IOC)
- Built using same I-beam/panel method as Depot
- Construction shuttles built here for local L1 operations
- Purpose-built craft production begins:
  - Custom tankers — replace HLT on Luna→L1 route
  - Custom Venus skimmers — dedicated separator config
  - Custom Titan skimmers — dedicated CH4/N2 collection
  - Construction shuttles — Depot↔Shipyard local ops only

---

## Craft Lifecycle — HLT

HLT (Heavy Lift Transport) is the workhorse of early game.
Owned and operated by AstroLift throughout all phases.

| Phase | HLT Role | Replaced By |
|---|---|---|
| Earth launch | Earth→LEO cargo/crew | Never replaced — permanent role |
| Early Luna | Precursor cargo delivery, surface asset | N/A |
| Skimmer phase | Fitted with harvester modules | Purpose-built skimmers (L1 Shipyard) |
| Tanker phase | Luna→L1 material runs | Custom tankers (L1 Shipyard) |

**HLT is never retired** — it remains on Earth→LEO
permanently. All other roles are handed off to purpose-built
craft as L1 Shipyard comes online.

---

## Full Luna→L1 Economic Loop

This is the MVP loop the AI Manager must prove before
players arrive:

Earth launches → AstroLift HLT → LEO Depot
LEO Depot → Cycler → L1 Depot
Luna regolith → ISRU → O2, H2, He3, metals
Luna ISRU → 3D printer → I-beams, panels
Luna → mass launcher → L1 position
AstroLift HLT assembly → L1 Depot shell
L1 Depot IOC → AstroLift skimmers dock here
AstroLift Titan skimmer → mixed gas → Luna
AstroLift Venus skimmer → mixed gas → Luna
LDC processes mixed gas → CO2 extracted
Luna Sabatier (LDC) → CH4 (loop closes)
LDC → custom tankers → L1 Depot
L1 Depot → Shipyard construction
L1 Shipyard → purpose-built craft
Purpose-built skimmers → steady gas supply
Luna + L1 fully operational → players arrive

**Every step depends on the previous.** The AI Manager
must sequence this correctly and adapt when supply chains
stall or missions are delayed.

---

## AI Manager Decision Points

At each stage the AI Manager evaluates:

**Resource decisions:**
- PrecursorCapabilityService → what is locally available
- Gap analysis → what must be imported
- Route cost-benefit → Earth tanker vs skimmer vs Sabatier

**Skimmer deployment timing:**
- Is Luna ready to refuel Titan skimmer? (LOX available day 1)
- Is Luna ready to refuel Venus skimmer? (needs CH4 first)
- Is Sabatier loop ready to close? (needs steady CO2 supply)
- Is standing contract or spot market better for this run?

**L1 construction trigger:**
- Is ISRU production sufficient for component manufacturing?
- Is 3D printer outputting I-beams and panels at required rate?
- Is mass launcher operational and calibrated?
- Are enough HLT craft available for assembly operations?

**Shipyard trigger:**
- Is Depot fully operational and stable?
- Is material supply from Luna sufficient for Shipyard construction?
- Is there enough demand to justify purpose-built craft production?

**Market decisions:**
- Should AstroLift post spot sell order or fill existing buy order?
- Is standing contract price still fair given current market?
- Is LDC LOX production sufficient to sell excess to market?
- Has Sabatier loop closed — can CH4 import contract be ended?

---

## Mission Profile References

- Luna V2 mission profile: data/json-data/missions/
  luna_base_establishment_manifest_v2.json (Task 3 — pending)
- Titan harvester: data/json-data/missions/tasks/
  titan_harvester_mission/
- Venus harvester: data/json-data/missions/tasks/
  venus_harvester_mission/
- Generic tasks: data/json-data/missions/tasks_v2/
- NPC deployment pattern: docs/patterns/deployment/
  NPC_INITIAL_DEPLOYMENT_SEQUENCE.md
- Data conventions: docs/reference/
  CELESTIAL_BODY_DATA_CONVENTIONS.md

---

---

## Open Items and Design Notes

### LEO Depot
Same design pattern as L1 Depot — LDC owned. Depot only —
no shipyard at LEO. All shipyard operations are at L1
exclusively. LEO Depot is a fuel transfer and staging
point only. Serves as the first fuel transfer point in 
the supply chain:

- Outbound craft fuel up with LOX and CH4 before heading
  to Luna or further out
- Inbound craft offload excess LOX and CH4 as sell orders
  before returning to Earth — no point carrying mass not
  needed for Earth landing
- Luna LOX and imported/generated CH4 are the primary
  fuels available at LEO Depot
- Creates a market at LEO — craft buy/sell fuel en route

**Design intent**: LEO Depot closes the Earth↔Luna fuel
loop. Craft leaving Earth are fully fueled. Craft returning
from Luna sell excess propellant rather than waste it
re-entering Earth's gravity well.

---

### Cycler Ownership
Cyclers are owned by individual corporations — AstroLift,
LDC, or other player/NPC corporations. Not consortium-owned.
The Wormhole Consortium manages the wormhole network only,
not the craft that use it.

The AI Manager tracks cycler ownership and bills/credits
the correct organization for each transit leg.

---

### Mixed Gas Processing Facility
**Status**: Backlog — needs design and testing

Luna needs a structure to process incoming mixed atmospheric
gas from AstroLift skimmers. Concept:
- Factory-style structure fitted with appropriate units
- Separators, refineries, storage units
- Similar pattern to Nuclear Fuel Reprocessing Facility
  blueprint (see He3 section below) but for atmospheric
  gas processing
- Output: separated CO2, N2, CH4, SO2, trace gases
  ready for use or further processing

**Next step**: Review existing unit and structure blueprints
to determine if units already exist or need designing.
Backlog task for Claude/Gemini — low complexity,
pattern already established.

---

### Standing Contract Mechanics
Either buyer or seller can initiate a standing contract.
The other party must approve. Both must have the
items/capacity to fulfill.

Works similar to Eve Online contract system — already
designed in the game. Key points for AI Manager:
- AI Manager can create standing contracts on behalf
  of LDC or AstroLift
- Standing contracts take priority over spot market
  for critical supply runs
- AI Manager monitors contract fulfillment and flags
  breaches
- Either party can propose price renegotiation based
  on market conditions

---

### He3 Market and Fusion Processing

**He3 buyers by game phase:**

Early game — Earth market only. He3 is extremely high
value for fusion research. LDC sells via spot market.
AstroLift or cycler transports to Earth.

Mid game — Luna and L1 fusion power plants come online.
Local He3 demand grows. LDC sells to local market
at shorter transit cost. He3 powers mixed gas processing
and base operations.

Long term — He3 fusion fuel for inner system expansion.
Dedicated fusion processing facilities needed.

**Fusion processing facility concept (untested):**
A Nuclear Fuel Reprocessing Facility blueprint exists
as a reference pattern (uranium focused). He3 fusion
processing would follow similar structure:
- Isotope handling units
- Fusion fuel preparation
- High-value storage and containment
- Different reaction chain from uranium — needs
  separate facility design

**Status**: Concept only — untested, needs refinement.
The uranium reprocessing blueprint is a design pattern
reference, not a He3 facility specification. Do not
implement He3 processing from that blueprint directly.
Design and test a dedicated He3 fusion fuel facility
when fusion power comes online in game progression.

**Backlog**: He3 Fusion Processing Facility blueprint —
design when fusion power tier is ready for implementation.

---

## Notes for Next Session

- Luna V2 mission profile JSON (Task 3) must be written
  in tasks_v2 format so AI Manager can execute it
- Existing V1 manifest needs review before V2 is written
- Rake task needs updating to use TaskExecutionEngineV2
  after Task 2 completes
- Full loop proof via rake task is Phase 1 endgame
- Organizations and market structure needs its own
  dedicated doc — too important to live only here