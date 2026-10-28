> **Wiki section:** Technical · **Status:** living summary — update when the project baseline or major gaps change; do not treat as a full issue tracker

# Status and Gaps

Same-repo orientation for contributors and agents: what this documentation set treats as solid, what is in flux, and where to read more **inside galaxyGame**.

This page is not a complete bug list. Prefer code, specs, and the topic pages linked from the [wiki Home](README.md) over old task narratives.

---

## Documentation posture

| Area | Posture |
|------|---------|
| [Wiki Home](README.md) | Live front door (Player / Development / Technical) |
| Topic pages under `docs/wiki/` | Intent and options; many still need verify-against-code |
| `docs/architecture/`, `docs/developer/`, `docs/gameplay/` | Deep reference — quality varies by age |
| `docs/wiki_reorganization/` | Planning / archaeology only — not day-to-day navigation |

**Rule:** Design intent and open options live on wiki topic pages. Ephemeral work lists are not a second design wiki.

---

## What is in better shape (documentation)

- **Markets (docs):** [Resource and market logistics](logistics/Resource-and-Market-Logistics.md) and [Market and AI bootstrapping](logistics/Market-and-AI-Bootstrapping.md) are the strongest market writeups; both still carry VERIFY / PENDING markers — trust the flags.
- **Getting started:** [Getting started](player/getting_started.md) matches the Docker-oriented run path in the project README.
- **Logistics vs finance split:** [Logistics and hauling](logistics/Logistics-and-Hauling.md) is transport intent; [Financial engine](logistics/Financial-Engine.md) is currency/peg/friction. Do not mix them.
- **StarSim (docs):** [System blueprints](astronomy/System-Blueprints.md) covers StarSim — system generation and loading JSON systems to initialize that part of the game. It is **not** about manufacturing unit/structure blueprints.
- **Scenarios / atmosphere:** [Scenario: Super Mars](astronomy/Scenario-Super-Mars.md) and [Atmospheric harvesting](infrastructure/Atmospheric-Harvesting.md) are useful design/test-bench material; confirm constants against `config/initializers` when implementing.

---

## Known documentation gaps

| Gap | Notes |
|-----|--------|
| Unit / manufacturing blueprints | No dedicated wiki page yet for craftable unit JSON + operational-data intent. [System blueprints](astronomy/System-Blueprints.md) is StarSim (systems), not that topic |
| Celestial systems | [Celestial systems](astronomy/Celestial-Systems.md) is a **template**, not a filled Sol (or other) system page |
| Player roles / factions | [Player roles and alignment](player/Player-Roles-and-Alignment.md) is detailed; treat as intent until matched to current models/UI |
| Portal / late-game FTL transport | Intentionally out of the front door until design is ready to land under logistics/transport |
| Command reference drift | [System commands](technical/System-Commands.md) may name services or baselines that have moved — re-check before scripting around them |
| Architecture sprawl | Large trees under `docs/architecture/` and legacy `docs/agent/` are uneven; prefer wiki entry pages first |

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
| AI Manager | [AI Manager logic](logistics/AI-Manager-Logic.md); `docs/architecture/ai_manager/` |
| Testing habits | `docs/testing/`, practical testing notes under `docs/` |

---

## How to update this page

When you close a major gap or lock an option on a topic page, add a short dated line under a “Recent doc updates” list below (or adjust the tables). Keep this page short.

### Recent doc updates

- **2026-10-27** — Wiki Home + three sections; logistics/finance split fixed; topic banners; this status page added (no external-repo status links).
