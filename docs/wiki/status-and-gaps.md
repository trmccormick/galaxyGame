> **Wiki section:** Technical · **Status:** living summary — update when the project baseline or major gaps change; do not treat as a full issue tracker

# Status and Gaps

Same-repo orientation for contributors and agents: what this documentation set treats as solid, what is in flux, and where to read more **inside galaxyGame**.

This page is not a complete bug list. Prefer code, specs, and the topic pages linked from the [wiki Home](README.md) over old task narratives.

---

## Documentation posture

| Area | Posture |
|------|---------|
| [Unit & Manufacturing blueprints](engineering/unit_and_manufacturing_blueprints.md) | DESIGN INTENT ONLY — canonical entry for crafted equipment JSON schemas, build pipelines, and operational data roles |
| [AI Manager Logic](logistics/ai_manager_logic.md) | CANONICAL FRONT DOOR — single entry for AI priority loops, ACM boundaries, and system behavior; deep specs linked out to [`docs/architecture/ai_manager/`](../architecture/ai_manager/) |
| [Wiki Home](README.md) | Live front door (Player / Development / Technical); navigation by category table added 2026-10-28 |
| Topic pages under `docs/wiki/` | Intent and options; many still need verify-against-code |
| `docs/architecture/`, `docs/developer/`, `docs/gameplay/` | Deep reference — quality varies by age |
| `docs/wiki_reorganization/` | Planning / archaeology only — not day-to-day navigation |

**Rule:** Design intent and open options live on wiki topic pages. Ephemeral work lists are not a second design wiki.

---

## What is in better shape (documentation)

- **Markets (docs):** [Resource and market logistics](logistics/resource_and_market_logistics.md) and [Market and AI bootstrapping](logistics/market_and_ai_bootstrapping.md) are the strongest market writeups; both still carry VERIFY / PENDING markers — trust the flags.
- **Getting started:** [Getting started](player/getting_started.md) matches the Docker-oriented run path in the project README.
- **Logistics vs finance split:** [Logistics and hauling](logistics/logistics_and_hauling.md) is transport intent; [Financial engine](logistics/financial_engine.md) is currency/peg/friction. Do not mix them.
- **StarSim (docs):** [System blueprints](astronomy/system_blueprints.md) covers StarSim — system generation and loading JSON systems to initialize that part of the game. It is **not** about manufacturing unit/structure blueprints.
- **Scenarios / atmosphere:** [Scenario: Super Mars](astronomy/scenario_super_mars.md) and [Atmospheric harvesting](infrastructure/atmospheric_harvesting.md) are useful design/test-bench material; confirm constants against `config/initializers` when implementing.

---

## Known documentation gaps

| Gap | Notes |
|-----|--------|
| Celestial systems | [Celestial systems](astronomy/celestial_systems.md) is a **template**, not a filled Sol (or other) system page |
| Player roles / factions | [Player roles and alignment](player/player_roles_and_alignment.md) is detailed; treat as intent until matched to current models/UI |
| Command reference drift | [System commands](technical/system_commands.md) may name services or baselines that have moved — re-check before scripting around them |
| Architecture sprawl | Large trees under `docs/architecture/` and legacy `docs/agent/` are uneven; prefer wiki entry pages first |

## Draft pages added (2026-11-04 owner and Gemini brainstorm; unverified)

These topics now have a draft wiki home. The pages are first drafts from a brainstorm and are not yet verified:

| Topic | Draft page | Status |
|-------|---------------|--------|
| AI Manager economic behavior (debt/austerity, NPC bands, Virtual Ledger, stockpile targets) | [AI Manager Economic Loops](logistics/ai_manager_economic_loops.md) | DIRECTION — some ESTABLISHED anchors |
| Surface / near-surface habitats (thought exercise on dome pressurization and power) | [Surface Habitat Options](infrastructure/surface_habitat_options.md) | DESIGN INTENT (thought exercise) |
| Power generation and distribution across phases | [Power Options](infrastructure/power_options.md) | DIRECTION |
| Settlement evolution stages, first foothold requirements, expansion gates | [Settlement Progression & Footholds](player/settlement_progression_and_footholds.md) | DIRECTION (draft) |
| Eden disconnect: snap physics, residual EM field, reconnection sequence, emergent post-isolation states | [Eden Disconnect & Emergent History](player/eden_disconnect_and_emergent_history.md) | DIRECTION — snap physics and reconnection sequence (tug + EM harvesters + sats only → conversion → full AWS) stated by the owner, page still marks it DIRECTION; emergent archetypes OPEN |
| Portal rules (mass limits, EM consumption, pairing) + AWS inter-system networking | [Portals & AWS](technical/portals_and_aws.md) | DIRECTION / OPEN — intra-system low-mass + pairing are established direction; inter-system Level 4b details remain more open |
| Atmosphere modification / terraforming pathways (pressure-first protection, refined mass-driver, softer options) | [Terraforming options](infrastructure/terraforming_options.md) | DIRECTION / OPEN (unreviewed Gemini draft) |

## Gaps with a draft home (2026-11-04; not yet resolved)

These were listed as open or missing. The draft pages above now cover them, pending verification:

| Gap | Draft page |
|-----|-----------|
| AI Manager market behavior, debt-driven austerity, inter-NPC clearing, NPC buy/sell bands | [AI Manager Economic Loops](logistics/ai_manager_economic_loops.md) — consolidates intent from brainstorm; adds missing austerity/80-90 band/ledger rules |
| Surface habitat design options (thought exercise only, not a planned structure type) | [Surface Habitat Options](infrastructure/surface_habitat_options.md) |
| Power generation and distribution strategies across phases (surface, orbital, deep-space) | [Power Options](infrastructure/power_options.md) — power infrastructure evolution |
| Settlement tier progression, early foothold requirements, expansion gates between tiers | [Settlement Progression & Footholds](player/settlement_progression_and_footholds.md) — tiered evolution from early foothold |
| Post-snap behavior of disconnected systems, emergence rules, reconnection mechanics | [Eden Disconnect & Emergent History](player/eden_disconnect_and_emergent_history.md) — snap event + emergent states + recovery protocols |
| Atmosphere modification / pressure-first protection / Venus→Mars mass-driver pathways | [Terraforming options](infrastructure/terraforming_options.md) |
| Portal technology and AWS networking | [Portals & AWS](technical/portals_and_aws.md) — intra-system low-mass + pairing as live design; inter-system details still open |
| What a new player meets at entry (active starts, AWS timing, dashboard) | [First Hour and Entry State](player/first_hour_and_entry_state.md) |

| Gap resolved | New canonical page |
|-------------|-------------------|
| Unit / manufacturing blueprints | [Unit & Manufacturing blueprints](engineering/unit_and_manufacturing_blueprints.md) — DESIGN INTENT ONLY, covers crafted equipment JSON schemas and build pipelines |
| AI Manager intent / priority logic | [AI Manager Logic](logistics/ai_manager_logic.md) — canonical front door (ACM boundaries, 3-tier priority loops, safety policies) |
| Market pricing & bootstrapping pair | [Resource and Market Logistics](logistics/resource_and_market_logistics.md) + [Market and AI Bootstrapping](logistics/market_and_ai_bootstrapping.md) — designated canonical wiki pair with cross-banners; EAP + peg/unpeg design intent added 2026-10-28 |
| Infrastructure TOC coherence | [Infrastructure/README.md](infrastructure/README.md) — restructured as master table of contents, pre_player_era content consolidated into [Station Construction Options](engineering/station_construction_options.md) |
| System commands verification posture | [System Commands](technical/system_commands.md) — banner updated to VERIFY AGAINST CODE with app/services/ runtime pointers |

---

## Game / implementation flux (high level)

Exact failure counts and branch tips change often. For this wiki:

- Prefer **running the app and specs in this repo** over memorized phase numbers in old markdown.
- Project README and `docs/README.md` may still contain historical phase language; when they disagree with current behavior, **code and current specs win**.
- Design is allowed to move: update the relevant **wiki topic** (intent + options table) rather than scattering new truth into one-off notes.

---

## Same-repo places to dig deeper

| Topic | Start here |
|-------|------------|
| Run / setup | [Getting started](player/getting_started.md), [docs/developer/setup.md](../developer/setup.md), root `README.md` |
| Docs map | [docs/README.md](../README.md) |
| Architecture overview | [docs/architecture/overview.md](../architecture/overview.md) (and subfolders as needed) — system-wide architecture intent; deep specs live in architecture subdirectories |
| Markets / economy | Wiki market pages above; [financial engine specs](../logistics/financial_engine.md#Architecture-Cross-References); [AI Manager economic alignment](../logistics/market_and_ai_bootstrapping.md#Architecture-Cross-References) |
| AI Manager | [AI Manager logic](logistics/ai_manager_logic.md); deep specs at [docs/architecture/ai_manager/](../architecture/ai_manager/) |
| Testing habits | `docs/testing/`, practical testing notes under `docs/` |

---

## How to update this page

When you close a major gap or lock an option on a topic page, add a short dated line under a “Recent doc updates” list below (or adjust the tables). Keep this page short.

### Recent doc updates

- **2026-10-29** — Promoted settlement infrastructure intent (unsourced tier and growth-stage details moved to its OPEN block; see Migration log) into `infrastructure/settlement_infrastructure.md`; linked from wiki Home and Infrastructure TOC. Active task tracking and sprint status reside in the external `agent-tasks` repository; `docs/wiki/` is reserved for enduring design intent and architecture specs.
- **2026-10-28** — Categorical directory reorganization (`astronomy/`, `logistics/`, `player/`, `infrastructure/`, `engineering/`, `technical/`); all Home-page link repairs; new "Navigation by Category" IA table on the Home page; `planetary_protection_environmental_governance.md` design-only spec added to infrastructure.
- **2026-10-29** — Aligned Financial Engine (logistics/financial_engine.md) with canonical market pair: added explicit GCC/USD peg, EAP ceiling terminology and `resource_and_market_logistics.md` + `market_and_ai_bootstrapping.md` as canonical authority pointers; updated wiki/README.md link.
- **2026-10-28** — P0/P1 wiki consolidation pass: created [Unit & Manufacturing Blueprints](engineering/unit_and_manufacturing_blueprints.md) as canonical entry (separate from StarSim); updated [AI Manager Logic](logistics/ai_manager_logic.md) as single front door for AI priorities/ACM boundaries; designated [resource_and_market_logistics.md](logistics/resource_and_market_logistics.md) + [market_and_ai_bootstrapping.md](logistics/market_and_ai_bootstrapping.md) as canonical market pair with cross-banners; restructured [Infrastructure TOC](infrastructure/README.md); added System Commands VERIFY AGAINST CODE banner and archival supersede note to wiki_reorganization/README.md.
- **2026-10-28**: Synchronized market pair with EAP, USD/GCC calibration peg, post-unpeg interface roles, and target design intent status.

### Phase C code alignment & cross-linkage (2026-11-01)

- **Item C.1 — Code Alignment Banners**: Standardized 3-line blockquote banners (`DESIGN INTENT` / `PARTIALLY IMPLEMENTED` / `VERIFIED AGAINST CODE`) across all 7 target wiki specs plus player roles page — committed, pushed (`origin/main`) ✅
  - `technical/system_commands.md`: PARTIALLY IMPLEMENTED (3 of 4 claimed services don't exist)
  - `markets/markets_eap_and_peg.md`: PARTIALLY IMPLEMENTED (marketplace/NPC pricing verified; unpeg mechanics design intent)
  - `logistics/financial_engine.md`: PARTIALLY IMPLEMENTED (ledger structure exists; settle_with_usd stubbed) — **glitch fixed: stray table-row `|` removed from canonical authority block** ✅
  - `logistics/ai_manager_logic.md`: PARTIALLY IMPLEMENTED (task_execution_engine.rb verified; coordinators pending)
  - `infrastructure/atmospheric_harvesting.md`: DESIGN INTENT (constants defined, no AtmosphereProcessor service)
  - `infrastructure/settlement_infrastructure.md`: VERIFIED AGAINST CODE (settlement/* models match codebase) ✅
  - `engineering/unit_and_manufacturing_blueprints.md`: VERIFIED AGAINST CODE (blueprints, base_unit, fabricator match) ✅
- **Item C.2 — Code Verification Audit**: Verified each page's design claims against live code; reported missing services and stubbed implementations ✅
- **Item C.3 — Celestial Systems Template**: Fleshed out `astronomy/celestial_systems.md` with code-grounded generation specs (StarSim::ProceduralGenerator seed fields, spectral type weights, wormhole compliance rules), 5 architecture cross-links, and Generation Paths Reference table — committed, pushed (`origin/main`) ✅
- **Item C.4 — Architecture Cross-Linkage**: Added Architecture Cross-References sections to 4 pages; fixed absolute paths → relative links in 2 files; all 16 new relative links verified against `git ls-files` with zero broken refs — committed, pushed (`origin/main`) ✅
- **Item C.5 — Player Roles & Alignment Refresh**: Added DESIGN INTENT banner to `player_roles_and_alignment.md`; documented that FactionStandingEngine, AccountabilityService, and PlayerDashboardController do not exist; Player model confirmed minimal (name, active_location, basic associations) — committed, pushed (`origin/main`) ✅
- **Cross-link maintenance**: Updated `status-and-gaps.md` architecture/developer directory references to clickable wiki links (was bare text); fixed `financial_engine.md` markdown glitch (stray table-row `|` in prose block) ✅

### Phase B hygiene sweep (2026-11-01)

- **Global naming standardization** — All wiki files across `logistics/`, `engineering/`, `player/`, `technical/`, `infrastructure/` renamed to strict `lower_snake_case`. Legacy Title-Case / kebab-case filenames removed.
  - Items B.1 (Logistics & Engineering): committed, pushed (`origin/main`) ✅
  - Item B.2 (Player, Technical, Infrastructure): committed, pushed (`origin/main`) ✅
- **Global link integrity verification** — All 194 internal wiki relative links and all 30 cross-wiki links verified against tracked files; zero broken paths found. ✅

### Documentation updates (2026-11-02)

- **Player independence** — Added "Staying Put Is Valid Play" section to [`player/getting_started.md`](player/getting_started.md): documents that remaining at one location is a valid long-term play style; expansion is optional. Originally classified as POSSIBLE DESIGN; promoted to ESTABLISHED INTENT in the same session (2026-11-02).
- **NPC footholds for player businesses** — Added section to [`infrastructure/settlement_infrastructure.md`](infrastructure/settlement_infrastructure.md): players may establish and operate businesses at NPC footholds without building private settlements. Originally classified as POSSIBLE DESIGN; promoted to ESTABLISHED INTENT in the same session (2026-11-02).
- **Player economic roles** — Added section to [`logistics/resource_and_market_logistics.md`](logistics/resource_and_market_logistics.md): harvesting, manufacturing, trading, and logistics as distinct player business types that can support other settlements. Originally classified as POSSIBLE DESIGN; promoted to ESTABLISHED INTENT in the same session (2026-11-02).
- **Autonomous cargo ships** — Added section to [`logistics/logistics_and_hauling.md`](logistics/logistics_and_hauling.md): distinguishes autonomous navigation (baseline) from configurable commercial activity (optional layer). Originally classified as POSSIBLE DESIGN; promoted to ESTABLISHED INTENT in the same session (2026-11-02).
- **Interstellar communications (NEW PAGE)** — Created [`engineering/interstellar_communications.md`](engineering/interstellar_communications.md): establishes light-speed electromagnetic communication with distance-dependent delays; store-and-forward relay network via stations and ships; dedicated data couriers for high-bandwidth transfers. Wormholes provide physical transit only, not instant messaging. **Resolved:** the historical discrepancy with `WORMHOLE_NETWORK_INTENT.md` (which contained an entry never reflecting owner intent) is documented in the wiki page itself; the external file was not modified (frozen documentation). Classified as ESTABLISHED INTENT (2026-11-02).
- **AI Manager expansion scouting** — Added GAP 6 and section to [`services/ai_manager.md`](services/ai_manager.md): AI Manager should scout and evaluate unconnected systems before committing permanent network connections. Originally classified as POSSIBLE DESIGN; promoted to ESTABLISHED INTENT in the same session (2026-11-02).
- **Wiki README navigation** — Added interstellar communications entry to Engineering section of wiki Home page with conflict flag.
