> **Wiki section:** Technical · **Status:** living summary — update when the project baseline or major gaps change; do not treat as a full issue tracker

# Status and Gaps

Same-repo orientation for contributors and agents: what this documentation set treats as solid, what is in flux, and where to read more **inside galaxyGame**.

This page is not a complete bug list. Prefer code, specs, and the topic pages linked from the [wiki Home](README.md) over old task narratives.

---

## Documentation posture

| Area | Posture |
|------|---------|
| [Unit & Manufacturing blueprints](engineering/unit-and-manufacturing-blueprints.md) | DESIGN INTENT ONLY — canonical entry for crafted equipment JSON schemas, build pipelines, and operational data roles |
| [AI Manager Logic](logistics/ai_manager_logic.md) | CANONICAL FRONT DOOR — single entry for AI priority loops, ACM boundaries, and system behavior; deep specs linked out to `docs/architecture/ai_manager/` |
| [Wiki Home](README.md) | Live front door (Player / Development / Technical); navigation by category table added 2026-10-28 |
| Topic pages under `docs/wiki/` | Intent and options; many still need verify-against-code |
| `docs/architecture/`, `docs/developer/`, `docs/gameplay/` | Deep reference — quality varies by age |
| `docs/wiki_reorganization/` | Planning / archaeology only — not day-to-day navigation |

**Rule:** Design intent and open options live on wiki topic pages. Ephemeral work lists are not a second design wiki.

---

## What is in better shape (documentation)

- **Markets (docs):** [Resource and market logistics](logistics/Resource-and-Market-Logistics.md) and [Market and AI bootstrapping](logistics/market_and_ai_bootstrapping.md) are the strongest market writeups; both still carry VERIFY / PENDING markers — trust the flags.
- **Getting started:** [Getting started](player/getting_started.md) matches the Docker-oriented run path in the project README.
- **Logistics vs finance split:** [Logistics and hauling](logistics/Logistics-and-Hauling.md) is transport intent; [Financial engine](logistics/Financial-Engine.md) is currency/peg/friction. Do not mix them.
- **StarSim (docs):** [System blueprints](astronomy/System-Blueprints.md) covers StarSim — system generation and loading JSON systems to initialize that part of the game. It is **not** about manufacturing unit/structure blueprints.
- **Scenarios / atmosphere:** [Scenario: Super Mars](astronomy/Scenario-Super-Mars.md) and [Atmospheric harvesting](infrastructure/Atmospheric-Harvesting.md) are useful design/test-bench material; confirm constants against `config/initializers` when implementing.

---

## Known documentation gaps

| Gap | Notes |
|-----|--------|
| Celestial systems | [Celestial systems](astronomy/Celestial-Systems.md) is a **template**, not a filled Sol (or other) system page |
| Player roles / factions | [Player roles and alignment](player/Player-Roles-and-Alignment.md) is detailed; treat as intent until matched to current models/UI |
| Portal / late-game FTL transport | Intentionally out of the front door until design is ready to land under logistics/transport |
| Command reference drift | [System commands](technical/System-Commands.md) may name services or baselines that have moved — re-check before scripting around them |
| Architecture sprawl | Large trees under `docs/architecture/` and legacy `docs/agent/` are uneven; prefer wiki entry pages first |

## Resolved gaps (2026-10-28 consolidation pass)

| Gap resolved | New canonical page |
|-------------|-------------------|
| Unit / manufacturing blueprints | [Unit & Manufacturing blueprints](engineering/unit-and-manufacturing-blueprints.md) — DESIGN INTENT ONLY, covers crafted equipment JSON schemas and build pipelines |
| AI Manager intent / priority logic | [AI Manager Logic](logistics/ai_manager_logic.md) — canonical front door (ACM boundaries, 3-tier priority loops, safety policies) |
| Market pricing & bootstrapping pair | [Resource and Market Logistics](logistics/Resource-and-Market-Logistics.md) + [Market and AI Bootstrapping](logistics/market_and_ai_bootstrapping.md) — designated canonical wiki pair with cross-banners; EAP + peg/unpeg design intent added 2026-10-28 |
| Infrastructure TOC coherence | [Infrastructure/README.md](infrastructure/README.md) — restructured as master table of contents, pre_player_era content consolidated into [Station Construction Options](engineering/station_construction_options.md) |
| System commands verification posture | [System Commands](technical/System-Commands.md) — banner updated to VERIFY AGAINST CODE with app/services/ runtime pointers |

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
| Architecture overview | [docs/architecture/overview.md](../architecture/overview.md) (and subfolders as needed) |
| Markets / economy | Wiki market pages above; `docs/architecture/` financial / organizations material |
| AI Manager | [AI Manager logic](logistics/ai_manager_logic.md); `docs/architecture/ai_manager/` |
| Testing habits | `docs/testing/`, practical testing notes under `docs/` |

---

## How to update this page

When you close a major gap or lock an option on a topic page, add a short dated line under a “Recent doc updates” list below (or adjust the tables). Keep this page short.

### Recent doc updates

- **2026-10-29** — Promoted settlement infrastructure intent (tiers, life support, growth stages) into `infrastructure/settlement_infrastructure.md`; linked from wiki Home and Infrastructure TOC. Active task tracking and sprint status reside in the external `agent-tasks` repository; `docs/wiki/` is reserved for enduring design intent and architecture specs.
- **2026-10-28** — Categorical directory reorganization (`astronomy/`, `logistics/`, `player/`, `infrastructure/`, `engineering/`, `technical/`); all Home-page link repairs; new "Navigation by Category" IA table on the Home page; `planetary_protection_environmental_governance.md` design-only spec added to infrastructure.
- **2026-10-29** — Aligned Financial Engine (logistics/Financial-Engine.md) with canonical market pair: added explicit GCC/USD peg, EAP ceiling terminology and `Resource-and-Market-Logistics.md` + `market_and_ai_bootstrapping.md` as canonical authority pointers; updated wiki/README.md link.
- **2026-10-28** — P0/P1 wiki consolidation pass: created [Unit & Manufacturing Blueprints](engineering/unit-and-manufacturing-blueprints.md) as canonical entry (separate from StarSim); updated [AI Manager Logic](logistics/ai_manager_logic.md) as single front door for AI priorities/ACM boundaries; designated [Resource-and-Market-Logistics.md](logistics/Resource-and-Market-Logistics.md) + [market_and_ai_bootstrapping.md](logistics/market_and_ai_bootstrapping.md) as canonical market pair with cross-banners; restructured [Infrastructure TOC](infrastructure/README.md); added System Commands VERIFY AGAINST CODE banner and archival supersede note to wiki_reorganization/README.md.
- **2026-10-28**: Synchronized market pair with EAP, USD/GCC calibration peg, post-unpeg interface roles, and target design intent status.
