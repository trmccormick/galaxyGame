> **Wiki Section:** Player · **Status:** Active / Refreshed for current stack & environment realities

# Getting Started

This guide provides the shortest path to running **Galaxy Game** locally and orienting yourself within the simulation environment. Design intent and core systems are mapped in the [Wiki Index](../README.md). Authoritative development task status lives in `agent-tasks`: `projects/galaxy_game/status.md`.

---

## Prerequisites & Setup Options

You can run Galaxy Game using either the **Docker Stack** (recommended for quick startup and consistency) or a **Native Local Setup** (recommended for active Rails core development).

| Environment Component | Docker Path (Preferred) | Local Native Path |
| :--- | :--- | :--- |
| **Container / Engine** | Docker & Docker Compose | — |
| **Ruby Version** | Handled in Docker (`ruby:3.4.3`) | Ruby `3.4.3` *(Note: older `setup.md` mentions `3.2.5` — `3.4.3` is current in Dockerfile)* |
| **Database** | PostgreSQL 16 (Compose service) | PostgreSQL 16 (Local) |
| **In-Memory Cache** | Redis & Memcached (Compose) | Redis Server |
| **Validation Script** | Run `./scripts/check_prerequisites.sh` to verify host software before starting. |

---

## Option A: Docker Setup (Preferred)

From the repository root:

```bash
git clone https://github.com/trmccormick/galaxyGame.git
cd galaxyGame

# Launch development stack (Web, Workers, Redis, Postgres, Memcached)
docker-compose -f docker-compose.dev.yml up
```

*Note: Alternate Compose files exist for specific workflows, such as `docker-compose.prod.yml` for minimal production stack tests and `docker-compose.dev.llm.yml` for local LLM integration testing.*

### Accessing the UI

When container boot completes:
* **Primary Interface:** [http://localhost:3000](http://localhost:3000)
* **Direct Game View:** [http://localhost:3000/game](http://localhost:3000/game) *(Routing and UI views are actively evolving)*

### First-Time Data & Seeding

If the UI reports missing celestial bodies or an empty planetary system:

```bash
docker-compose -f docker-compose.dev.yml exec web bin/rails db:seed
```

---

## Option B: Native Local Setup (Full Contributor)

If developing outside Docker:

1. **Environment Setup:** Ensure PostgreSQL 16 and Redis are running locally.
2. **Environment Variables:** Inspect `env/` templates (`.env.dev.local.app`, `.env.db`). Copy or configure your local database URL accordingly.
3. **Dependencies & DB Setup:**
   ```bash
   bundle install
   bin/rails db:create db:migrate db:seed
   bin/rails server
   ```

*For complete step-by-step local tooling details, see [Developer Setup Guide](../../developer/setup.md).*

---

## What You Should Expect

Galaxy Game is a long-term **settlement, logistics, and expansion simulation** — not an arcade or combat RPG. In the current build:

1. **Solar / System View:** Renders configured celestial bodies and basic navigation framework.
2. **Body Inspection:** View mass, atmosphere, and surface parameters once seeded.
3. **Simulated Loops:** Advanced industry, multi-tier logistics, financial engines, and AI Manager automation are actively being wired into the client. Consult topic guides under [`player/`](../README.md#player) and [`development/`](../README.md#development) for documented specs vs. active UI state.

---

## Environment & Documentation Discrepancies

Because the project is in active development, keep the following discrepancies in mind:

* **Ruby Version Alignment:** The container environment uses **Ruby 3.4.3** (`Dockerfile`), whereas older dev documentation lists **3.2.5**. Prefer 3.4.3 for local setups.
* **Environment Files:** Default passwords and URLs are defined in `.env.db` and `.env.dev.local.app`. Ensure `.env.redis` is created if your custom environment demands explicit Redis credentials.
* **Database Spec Environment:** When running tests inside the container, always clear host DB settings:
  ```bash
  unset DATABASE_URL && RAILS_ENV=test bundle exec rspec
  ```

---

## Common Troubleshooting

| Symptom / Error | Recommended Fix |
| :--- | :--- |
| **No response at `localhost:3000`** | Confirm Docker Compose completed setup. Check container logs via `docker-compose -f docker-compose.dev.yml logs -f web`. |
| **Empty system / No planets** | Run `bin/rails db:seed` in the web container and refresh browser. |
| **Database Connection Refused** | Verify the `db` service healthcheck completed or check `.env.dev.local.app` for host binding. |
| **Stale Phase/Task references** | Ignore old phase numbers or task count summaries in legacy docs; refer strictly to `agent-tasks/projects/galaxy_game/status.md`. |

### ESTABLISHED INTENT — Player Independence: Staying Put Is Valid Play

**There is no requirement to expand beyond your initial settlement.** Building a private settlement is optional, not a requirement for participation or continued progression.

**Confirmed points:**

- Players may remain at NPC/AI Manager-developed footholds indefinitely and operate meaningful businesses there.
- Building a private settlement is optional, not a requirement for participation or continued progression.
- Players may stay where they are, relocate, or expand their operations elsewhere.
- Expansion is an opportunity, not an obligation.

**Why this matters:** The current UI and documentation frame progression as expansion-driven (new colonies, new systems). This section records the design principle that **staying put is a valid long-term play style**. Expansion should be optional, not mandatory, for players who prefer depth over breadth.

> **Note:** Not every foothold type or settlement offers identical services or access rules. Eligibility and available services depend on the specific foothold's infrastructure and the AI Manager's operational state.

### Undecided Implementation Details

- Does the current economy support a single-location player indefinitely? (e.g., can one settlement produce enough to sustain itself and trade?)
- Are there gameplay incentives that penalize non-expansion (e.g., resource depletion at one location)? If so, should they exist?
- Should the UI reflect this option more clearly — e.g., "I want to stay here" as a valid strategic choice?

### Player Mobility

#### Local-System Travel: Portal Network

Within a solar system, players can use the portal network to travel between connected locations (planets, moons, orbital stations). Portals provide intra-system transportation shortcuts.

#### Interstellar Travel: Wormhole Transit

For interstellar travel, a player can:
1. Travel to a wormhole station in their current system.
2. Take transport through the wormhole to another connected system.
3. Travel onward from the destination wormhole station to a settlement or other destination.

**Wormholes provide physical transportation only.** They do not bypass communication physics — interstellar messages still propagate at light speed with distance-dependent delays. See [Interstellar Communications](../engineering/interstellar_communications.md) for established intent on communication constraints.

#### Player Location vs. Asset Location

A player's physical location is independent of the location of their ships, assets, and business operations:
- Ships and assets remain where they were left unless actively moved.
- Business operations (harvesting, manufacturing, trading) continue at their established locations regardless of the player's current position.
- Players can relocate their personal base of operations without necessarily abandoning existing operations elsewhere.

### Asset Relocation Choices

When a player relocates, they have multiple options for handling their assets. These are alternative choices — the player is not required to move every asset.

| Option | Description |
|--------|-------------|
| **1. Own ships** | The player can use their own ships to transport equipment, inventory, supplies, and other assets to the new location. |
| **2. NPC logistics companies** | The player can hire NPC logistics providers to transport assets using normal cyclers. |
| **3. Sell and repurchase** | The player can sell assets on the local market for GCC and purchase replacements at the destination. |

**Additional choices:**
- Players may retain existing operations at their previous location without moving any assets.
- Players may transport selected assets while leaving others behind.
- Players may sell some assets and transport others, mixing approaches as needed.

**Undecided implementation details:**
- Relative cost, speed, and availability of each option.
- Contract structure for NPC logistics services.
- Detailed operating rules (e.g., transit time, risk of loss, market liquidity at destination).

---

## Where To Go Next

* **[Wiki Index Page](../README.md):** Main entry point for `player/`, `development/`, and `technical/` documentation.
* **[Player Roles & Alignment](player_roles_and_alignment.md):** Faction alignment, player scopes, and operational roles.
* **[Developer Setup](../../developer/setup.md):** Deep-dive into local Ruby, PostgreSQL, RuboCop, and testing environments.
* **Active Project Status:** Check `agent-tasks: projects/galaxy_game/status.md`.