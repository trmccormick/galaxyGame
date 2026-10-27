# Galaxy Game Wiki

A SimEarth-inspired space colonization game: settlements, industrial logistics, markets, and AI-driven expansion across the solar system and beyond.

This folder is the **live wiki** — the front door for players, contributors, and agents continuing work.

---

## How this wiki relates to everything else

| Material | Role |
|----------|------|
| **This folder (`docs/wiki/`)** | Live entry: orientation, design intent, and open options |
| **Task files (agent-tasks)** | Work orders only. Link here for intent; do not treat old tasks as design truth |
| **`docs/wiki_reorganization/`** | Planning / archaeology archive — not day-to-day navigation |
| **`docs/architecture/`, `docs/developer/`, etc.** | Deep reference; wiki pages link out when detail is needed |

**Rule:** Design intent and open options live in these wiki pages. Task files reference the wiki. Hundreds of older tasks are a **harvest source** for intent and options, not a second documentation tree. Structure first; compare to the current game and harvest by theme later.

---

## Player

Orientation and game-facing systems (what the game is trying to be, and how it plays).

| Page | Notes |
|------|--------|
| [Getting started](getting_started.md) | Run the game, first session (paths/UI may need refresh) |
| [Player roles and alignment](Player-Roles-and-Alignment.md) | Roles and alignment |
| [Logistics and hauling](Logistics-and-Hauling.md) | Transport and hauling |
| [Resource and market logistics](Resource-and-Market-Logistics.md) | Resources ↔ markets |
| [Market and AI bootstrapping](Market-and-AI-Bootstrapping.md) | Market + AI bootstrap |
| [Financial engine](Financial-Engine.md) | Money and financial systems |
| [Atmospheric harvesting](Atmospheric-Harvesting.md) | Gas / atmosphere harvesting |
| [Scenario: Super Mars](Scenario-Super-Mars.md) | Super-Mars scenario |

---

## Development

How major systems are meant to work for contributors (intent and options; link out to architecture for depth).

| Page | Notes |
|------|--------|
| [System blueprints](System-Blueprints.md) | Blueprints and related unit/structure intent |
| [Celestial systems](Celestial-Systems.md) | Bodies, systems, world structure |

*Setup, testing, and full architecture overviews live under `docs/developer/` and `docs/architecture/`; add thin wiki entry pages here as needed after the compare-to-game pass.*

---

## Technical

Agent and implementer reference for **continuing work** — status, conventions, and operational truth — not a dump of every design doc.

| Page | Notes |
|------|--------|
| [AI Manager logic](AI-Manager-Logic.md) | AI Manager intent / logic (verify against current code later) |
| [System commands](System-Commands.md) | Commands reference |

**Planned (after structure is stable and compared to current game):**

- Status and gaps → pointer to agent-tasks `projects/galaxy_game/status.md` and `NEEDS_REVIEW.md`
- Data conventions → JSON / blueprint / operational-data norms
- Guardrails → environment and agent boundaries (link to existing rules docs)

---

## Section status (structure pass)

All linked pages above are **existing** content, placed into the three sections for navigation only. Content has **not** yet been systematically checked against the current game. Prefer treating details as “needs review” until that compare pass.

Portal and other later-game topics stay out of this front door until their design is ready to land under the appropriate section (likely Player or Development → logistics/transport).
