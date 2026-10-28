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
| [**technical/**](technical/) | System commands and agent/developer reference |

---

## Player

Orientation and game-facing systems (what the game is trying to be, and how it plays).

| Page | Notes |
|------|--------|
| [Getting started](player/getting_started.md) | Run the game, first session |
| [Player roles and alignment](player/Player-Roles-and-Alignment.md) | Roles and alignment (verify against code) |

---

## Logistics & Markets

| Page | Notes |
|------|--------|
| [Logistics and hauling](logistics/Logistics-and-Hauling.md) | Transport and hauling intent |
| [Resource and market logistics](logistics/Resource-and-Market-Logistics.md) | Resources ↔ markets (strongest market page) |
| [Market and AI bootstrapping](logistics/Market-and-AI-Bootstrapping.md) | Market models + AI construction bootstrap |
| [Financial engine](logistics/Financial-Engine.md) | GCC/USD, peg, market friction |

---

## Astronomy & Celestial Systems

| Page | Notes |
|------|--------|
| [Scenario: Super Mars](astronomy/Scenario-Super-Mars.md) | Super-Mars test-bench scenario |
| [System blueprints](astronomy/System-Blueprints.md) | Documents **StarSim**: procedural system generation and loading JSON systems to initialize that part of the game (not manufacturing unit/structure blueprints) |
| [Celestial systems](astronomy/Celestial-Systems.md) | Per-system documentation **template** (fill per system; not a Sol dump by itself) |

---

## Infrastructure & Engineering

| Page | Notes |
|------|--------|
| [Atmospheric harvesting](infrastructure/Atmospheric-Harvesting.md) | Gas / atmosphere harvesting |
| [Station construction options](engineering/station_construction_options.md) | Options for station build pipelines |
| [Unit & Manufacturing blueprints](engineering/unit-and-manufacturing-blueprints.md) | Canonical wiki entry for crafted equipment JSON schemas, build pipelines, and operational data roles (design intent only) |

*Full pre-player logistics architecture, pipeline details, and planetary protection live under [Infrastructure](infrastructure/) — see that index for the complete table of contents.*

---

## Technical

Agent and implementer reference for **continuing work** — status, conventions, and operational orientation inside this repo.

| Page | Notes |
|------|--------|
| [Status and gaps](status-and-gaps.md) | In-repo documentation posture, known gaps, where to dig (no external status repo) |
| [AI Manager logic](logistics/AI-Manager-Logic.md) | Canonical front door for AI priority loops, ACM boundaries, and system behavior |
| [System commands](technical/System-Commands.md) | Console / simulation command reference (re-verify names before relying on them) |

*Setup, testing, and full architecture overviews live under `docs/developer/` and `docs/architecture/`. Crafted equipment schemas are documented in [Unit & Manufacturing blueprints](engineering/unit-and-manufacturing-blueprints.md).*

**Still useful later (same repo):**

- Data conventions → JSON / blueprint / operational-data norms (page TBD)
- Guardrails → link to environment / agent boundary docs under `docs/` when you want them on the front door

---

## Section status

Front door and section map are in place. Topic pages carry status banners; many details still need verify-against-code. Prefer [Status and gaps](status-and-gaps.md) and the topic pages over archaeology under `wiki_reorganization/`.

Portal and other later-game topics stay out of this front door until their design is ready to land under the appropriate section (likely Player or Development → logistics/transport).
