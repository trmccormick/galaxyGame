# Galaxy Game Wiki

A SimEarth-inspired space colonization game: settlements, industrial logistics, markets, and AI-driven expansion across the solar system and beyond.

This folder is the **live wiki** — the front door for players, contributors, and agents continuing work.

---

## How this wiki relates to everything else

| Material | Role |
|----------|------|
| **This folder (`docs/wiki/`)** | Live entry: orientation, design intent, open options, and in-repo status/gaps |
| **Task / work-order files** | Disposable work orders and a **harvest source** for intent — not design truth. When updated, they should link **here** |
| **`docs/wiki_reorganization/`** | Planning / archaeology archive — not day-to-day navigation |
| **`docs/architecture/`, `docs/developer/`, etc.** | Deep reference; wiki pages link out when detail is needed |

**Rule:** Design intent and open options live in these wiki pages. Work orders reference the wiki. Older task piles are ore to harvest, not a second documentation tree.

---

## Navigation by category

| Directory | Description |
|-----------|-------------|
| [**astronomy/**](astronomy/) | Celestial systems, star maps, and procedural system generation (StarSim) |
| [**logistics/**](logistics/) | Hauling, markets, financial engines, AI manager, and market bootstrapping |
| [**player/**](player/) | Orientation, getting started, and player roles / alignment |
| [**infrastructure/**](infrastructure/README.md) | Pre-player logistics architecture, atmospheric harvesting, and planetary protection |
| [**engineering/**](engineering/) | Station construction, expansion protocols, and post-snap reconnection |
| [**technical/**](technical/) | System commands, ISRU fabrication, precursor missions, biology & terraforming, and ballistic corridors |
| [**ui/**](ui/) | Interface design intent, visual identity, and reviewed user experiences |

---

## Player

Orientation and game-facing systems (what the game is trying to be, and how it plays).

| Page | Notes |
|------|--------|
| [Getting started](player/getting_started.md) | Run the game, first session |
| [Player roles and alignment](player/player_roles_and_alignment.md) | Roles and alignment (verify against code) |
| [First hour & entry state](player/first_hour_and_entry_state.md) | What players meet at entry: active starts, AWS timing, dashboard |
| [Settlement progression & footholds](player/settlement_progression_and_footholds.md) | Settlement evolution stages, first foothold requirements, expansion gates |
| [Eden disconnect & emergent history](player/eden_disconnect_and_emergent_history.md) | Snap event, post-isolation emergent states, system recovery protocols |

---

## Logistics & Markets

| Page | Notes |
|------|--------|
| [AI Manager economic loops](logistics/ai_manager_economic_loops.md) | AI Manager market interaction, debt/austerity, Virtual Ledger, stockpile buffers |
| [AI Manager & autonomous coordinators](services/ai_manager.md) | AI Manager responsibilities, decision-making, mission execution, and settlement development intent |
| [Logistics and hauling](logistics/logistics_and_hauling.md) | Transport and hauling intent |
| [Resource and market logistics](logistics/resource_and_market_logistics.md) | Resources ↔ markets (strongest market page) |
| [Market and AI bootstrapping](logistics/market_and_ai_bootstrapping.md) | Market models + AI construction bootstrap |
| [Financial engine](logistics/financial_engine.md) | GCC/USD, peg, market friction |
| [Markets, EAP & GCC/USD peg](markets/markets_eap_and_peg.md) | Canonical consolidation: markets pair + EAP ceilings + GCC/USD calibration peg |
| [EAP & AI Manager escalation](logistics/eap_and_ai_manager_escalation.md) | Earth Anchor Price escalation paths |
| [Import order & cycler models](logistics/import_order_and_cycler_models.md) | Import orders and cycler transit models |
| [Terraforming economic integration](logistics/terraforming_economic_integration.md) | Seed path vs brute-force economics — see also [Terraforming options](infrastructure/terraforming_options.md) for the mechanical pathways |
| [Skimmers & mixed volatiles](logistics/skimmer_and_mixed_volatiles.md) | Venus skimmer as in-flight processor; mixed-volatiles inventory; tanks = capacity, inventory = ledger |

---

## Astronomy & Celestial Systems

| Page | Notes |
|------|--------|
| [Scenario: Super Mars](astronomy/scenario_super_mars.md) | Super-Mars test-bench scenario |
| [System blueprints](astronomy/system_blueprints.md) | Documents **StarSim**: procedural system generation and loading JSON systems to initialize that part of the game (not manufacturing unit/structure blueprints) |
| [Celestial systems](astronomy/celestial_systems.md) | Per-system documentation **template** (fill per system; not a Sol dump by itself) |
| [Starsim & Protection Classes](astronomy/starsim_and_protection_classes.md) | Astrophysics / PPC physics expansion for StarSim-generated systems and planetary protection class frameworks |

---

## Infrastructure & Engineering

| Page | Notes |
|------|--------|
| [Atmospheric harvesting](infrastructure/atmospheric_harvesting.md) | Gas / atmosphere harvesting |
| [Atmospheric escape, retention & recovery](infrastructure/atmospheric_escape_and_recovery.md) | Natural atmospheric loss as resource depletion; technology options for retention and orbital recovery |
| [Power options](infrastructure/power_options.md) | Power generation and distribution across phases (surface, orbital, and deep-space) |
| [Settlement infrastructure](infrastructure/settlement_infrastructure.md) | Settlement and structure design intent, with a code-verified note and open items |
| [Surface habitat options](infrastructure/surface_habitat_options.md) | Surface habitat thought exercise: dome pressurization, oxygen setup, power gate |
| [Station construction options](engineering/station_construction_options.md) | Options for station build pipelines |
| [Interstellar communications](engineering/interstellar_communications.md) | Light-speed EM plus store-and-forward relays and physical carriers; portals and wormholes shorten carrier routes, not signal travel time. **Resolved:** historical FTL-communications discrepancy documented.
| [Game time and simulation loop](engineering/game_time_and_simulation_loop.md) | Proposed shared game clock, simulation advancement flow, pause/speed behavior, and code gaps |
| [Unit & Manufacturing blueprints](engineering/unit_and_manufacturing_blueprints.md) | Canonical wiki entry for crafted equipment JSON schemas, build pipelines, and operational data roles (design intent only) |
| [System B expansion protocol](engineering/02_system_b_expansion_protocol.md) | System B expansion protocol design |
| [Terraforming options](infrastructure/terraforming_options.md) | Pressure-first protection path, refined Venus→Mars mass-driver pipeline, softer longer-horizon options |

*Full pre-player logistics architecture, pipeline details, and planetary protection live under [Infrastructure](infrastructure/) — see that index for the complete table of contents.*

---

## Technical

Agent and implementer reference for **continuing work** — status, conventions, and operational orientation inside this repo.

| Page | Notes |
|------|--------|
| [Status and gaps](status-and-gaps.md) | In-repo documentation posture, known gaps, where to dig (no external status repo) |
| [Migration log](migration-log.md) | Which legacy documents have been absorbed into the wiki |
| [AI Manager logic](logistics/ai_manager_logic.md) | Canonical front door for AI priority loops, ACM boundaries, and system behavior |
| [System commands](technical/system_commands.md) | Console / simulation command reference (re-verify names before relying on them) |
| [Ballistic corridor](technical/venus_mars_ballistic_corridor.md) | Ballistic transit corridors between Venus and Mars |
| [Precursor mission deployment](technical/precursor_mission_deployment.md) | Initial precursor missions and deployment |
| [ISRU fabrication chain](technical/isru_fabrication_chain.md) | In-situ resource utilization fabrication pipelines |
| [Biology — overview](technical/biology/README.md) | Biology subfolder: biosphere simulation, terraforming seeds |
| [Biosphere simulation](technical/biology/biosphere_simulation.md) | Biosphere simulation design |
| [Terraforming seeds](technical/biology/terraforming_seeds.md) | Terraforming seed design |
| [Portals & AWS](technical/portals_and_aws.md) | Intra-system portals (EM ignition / fusion maintain, environmental variants); Artificial Wormhole Stations; institutional network control |
| [Natural wormholes & EM](technical/natural_wormholes_and_em.md) | Mass threshold, counterbalance, EM ejection/harvest/reset; natural vs AWS pairing |

*Setup, testing, and full architecture overviews live under `docs/developer/` and `docs/architecture/`. Crafted equipment schemas are documented in [Unit & Manufacturing blueprints](engineering/unit_and_manufacturing_blueprints.md).*

---

## Section status

Front door and section map are in place. Topic pages carry status banners; many details still need verify-against-code. Prefer [Status and gaps](status-and-gaps.md) and the topic pages over archaeology under `wiki_reorganization/`.

Portal and AWS design lives under [Portals & AWS](technical/portals_and_aws.md). Natural wormhole physics and EM harvesting live under [Natural wormholes & EM](technical/natural_wormholes_and_em.md).

## Wiki Standards & Conventions

All files in `docs/wiki/` follow these rules. New pages must comply:

1. **File names:** strict `lower_snake_case` — `file_name.md`. No Title-Case, no kebab-case.
2. **Links use explicit relative paths** with accurate `../` depth matching the source file's subdirectory level (e.g., a file two directories deep under `docs/wiki/` uses `../../` to reach `docs/wiki/`).
3. **All incoming links must resolve against tracked files** (`git ls-files`). Before merging, verify every new relative path exists in `git ls-files docs/wiki/`.
4. **Anchor links:** use lowercase with hyphens (`#section-title`) matching the first `#` heading exactly.
5. **No links out of the wiki.** `docs/wiki/` is the source of truth. Older documentation (`docs/architecture/`, `docs/developer/`, `docs/agent/`, `docs/design/`, `docs/wiki_reorganization/`, etc.) is frozen reference: read it, harvest what is still valid into the wiki, and cite it as plain text in the [Migration log](migration-log.md). Never link to it and never edit it.
6. **Labels.** The page banner describes the whole page: `VERIFIED AGAINST CODE`, `PARTIALLY IMPLEMENTED`, or `DESIGN INTENT`. A page that contains design the code does not implement cannot be `VERIFIED AGAINST CODE`. Section labels: `ESTABLISHED INTENT` (owner-confirmed; add the date), `DIRECTION` (under discussion, not final), `OPEN` (undecided), `RETIRED / DO NOT USE`. A number with no source is tagged `[PROPOSED / PLACEHOLDER]`; such numbers are design notes only and are never a data source for the runtime UI (see ui/README.md).
7. **Code notes are dated.** A "verified against code" section names the commit it was checked at. Keep it short: design intent first, code facts second.
8. **Wiki vs. code conflicts.** If the wiki is only stale on a detail of current behavior, update it from the code. If the difference could be a design change, ask the owner. If the owner's intent needs a code change, write a thin task (rule 9). Do not change the wiki to match code that is wrong.
9. **Thin tasks.** A task states what to build, links to the one wiki page that holds the design, and lists acceptance criteria. Design text belongs in the wiki, not in the task.
10. **Intent that affects gameplay or UI.** Record it in the wiki as `ESTABLISHED INTENT` before work starts, with a list of its undecided implementation details. Then compare it with the code and open one thin task per gap.
11. **Moving content.** Move content into the wiki before removing or merging any page. Delete duplicates instead of leaving pointer stubs, update every inbound link in the same commit, and add a row to the [Migration log](migration-log.md). Add no new information unless the owner states it; mark the rest `OPEN`. Do not edit files outside `docs/wiki/`.
12. **Checks.** Verify links and anchors case-sensitively against `git ls-files`, on Linux or CI (macOS ignores case).

These standards were standardized during Phase B of the repository hygiene sweep (2026-11-01). See [Status and gaps](status-and-gaps.md) for details.
