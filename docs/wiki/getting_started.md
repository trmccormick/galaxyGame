> **Wiki section:** Player · **Status:** refreshed for current run path (UI details still evolve with the game)

# Getting Started

Short path to run Galaxy Game and orient yourself. Design intent and system pages live in the [wiki Home](README.md). Authoritative development status lives in the **agent-tasks** repo: `projects/galaxy_game/status.md` (not in old phase counts inside this repository).

---

## Prerequisites

- Docker and Docker Compose
- Git

Full contributor setup (Ruby, local Postgres, etc.): [docs/developer/setup.md](../developer/setup.md).

---

## Run the game (Docker — preferred)

From the repository root:

```bash
git clone https://github.com/trmccormick/galaxyGame.git
cd galaxyGame

docker-compose -f docker-compose.dev.yml up
```

When the stack is up, open:

**http://localhost:3000**

If the UI exposes a dedicated game view, try **http://localhost:3000/game** as well; routing may change as the interface evolves.

### First-time data

If the view reports missing celestial bodies or an empty system:

```bash
# In the web container (service name may be `web` — adjust if your compose file differs)
docker-compose -f docker-compose.dev.yml exec web bin/rails db:seed
```

Then refresh the browser.

---

## What you should expect

Galaxy Game is a settlement, logistics, and expansion simulation — not a combat RPG. Typical early session:

1. **Solar / system view** — bodies and basic navigation  
2. **Time controls** — run / pause / speed (if present in the current UI)  
3. **Inspect a body** — mass, atmosphere, and related sphere data when seeded  
4. **Deeper loops** — industry, markets, transport, and AI Manager behavior are documented under [Player](README.md#player) and [Development](README.md#development); not all of that is fully wired in the live UI yet  

Exact menus, panels, and labels change as the client is restored. Prefer the wiki and agent-tasks status over screenshots in old notes.

---

## Where to go next

| Goal | Go to |
|------|--------|
| Wiki front door (Player / Development / Technical) | [README.md](README.md) |
| Roles, logistics, markets, scenarios | Player links on the wiki Home |
| Blueprints, celestial model | Development links on the wiki Home |
| Current failures, in-flight work, review queue | agent-tasks: `projects/galaxy_game/status.md`, `NEEDS_REVIEW.md` |
| Contributor environment and boundaries | [docs/developer/setup.md](../developer/setup.md), docs under `docs/developer/` and agent rules |

---

## Common issues

| Symptom | What to try |
|---------|-------------|
| Nothing at localhost:3000 | Confirm compose finished starting; check container logs for the web service |
| Empty system / no bodies | Run `db:seed` in the web container, then refresh |
| Specs / CI confusion | Always use `unset DATABASE_URL && RAILS_ENV=test` in the container; see project README status note |
| “Phase 3 / old failure counts” in random docs | Ignore — use agent-tasks `status.md` |

---

## Note on this page

This page is **how to start and where truth lives**. It is not a full design document. System intent and open options belong on the topic pages linked from the [wiki Home](README.md). Older task files may describe alternate UI or flows; treat those as harvest material, not as the current start path.
