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

## Player

Orientation and game-facing systems (what the game is trying to be, and how it plays).

| Page | Notes |
|------|--------|
| [Getting started](getting_started.md) | Run the game, first session |
| [Player roles and alignment](Player-Roles-and-Alignment.md) | Roles and alignment (verify against code) |
| [Logistics and hauling](Logistics-and-Hauling.md) | Transport and hauling intent |
| [Resource and market logistics](Resource-and-Market-Logistics.md) | Resources ↔ markets (strongest market page) |
| [Market and AI bootstrapping](Market-and-AI-Bootstrapping.md) | Market models + AI construction bootstrap |
| [Financial engine](Financial-Engine.md) | GCC/USD, peg, market friction |
| [Atmospheric harvesting](Atmospheric-Harvesting.md) | Gas / atmosphere harvesting |
| [Scenario: Super Mars](Scenario-Super-Mars.md) | Super-Mars test-bench scenario |

---

## Development

How major systems are meant to work for contributors (intent and options; link out to architecture for depth).

| Page | Notes |
|------|--------|
| [System blueprints](System-Blueprints.md) | Documents **StarSim**: procedural system generation and loading JSON systems to initialize that part of the game (not manufacturing unit/structure blueprints) |
| [Celestial systems](Celestial-Systems.md) | Per-system documentation **template** (fill per system; not a Sol dump by itself) |

*Setup, testing, and full architecture overviews live under `docs/developer/` and `docs/architecture/`. A dedicated wiki page for **unit / manufacturing blueprints** (craftable equipment JSON, etc.) is still a gap — see [Status and gaps](status-and-gaps.md). StarSim is covered by System blueprints.*

---

## Technical

Agent and implementer reference for **continuing work** — status, conventions, and operational orientation inside this repo.

| Page | Notes |
|------|--------|
| [Status and gaps](status-and-gaps.md) | In-repo documentation posture, known gaps, where to dig (no external status repo) |
| [AI Manager logic](AI-Manager-Logic.md) | Priority matrix seed (expand from `docs/architecture/ai_manager/` when doing AI work) |
| [System commands](System-Commands.md) | Console / simulation command reference (re-verify names before relying on them) |

**Still useful later (same repo):**

- Data conventions → JSON / blueprint / operational-data norms (page TBD)
- Guardrails → link to environment / agent boundary docs under `docs/` when you want them on the front door

---

## Section status

Front door and section map are in place. Topic pages carry status banners; many details still need verify-against-code. Prefer [Status and gaps](status-and-gaps.md) and the topic pages over archaeology under `wiki_reorganization/`.

Portal and other later-game topics stay out of this front door until their design is ready to land under the appropriate section (likely Player or Development → logistics/transport).
