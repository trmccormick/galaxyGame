# Galaxy Game — Agent README
**Last Updated**: March 22, 2026  
**Purpose**: Read this first. It tells you what the project is, where everything lives, and which document governs your role.

---

## What Is Galaxy Game

Galaxy Game is a space colonization simulation built in Ruby on Rails. Players manage settlements across the solar system and beyond, handling:

- **Resource extraction** — ISRU (in-situ resource utilization), mining, atmospheric harvesting
- **Life support** — closed-loop ecosystems, waste recycling, water/oxygen/food cycles
- **Manufacturing** — unit assembly, blueprint-driven construction, material processing
- **Trade & logistics** — markets, contracts, supply chains between settlements
- **Terraforming** — long-timescale atmosphere, biosphere, and temperature simulation
- **Engineered worlds** — technology-driven colonization for hostile environments (Titan, Europa)
- **AI Manager** — autonomous settlement expansion, resource allocation, wormhole network routing

The codebase is a Rails monolith with a large RSpec test suite currently under active restoration. Most development work flows through the agent task system in `docs/agent/tasks/`.

---

## Your Role

The human will tell you your role in the session handoff. Find your document below and read it before doing anything else.

| Role | You Are | Read This |
|---|---|---|
| **Implementation Agent** | Fixing code, running specs, committing fixes | [`IMPLEMENTATION_AGENT_README.md`](IMPLEMENTATION_AGENT_README.md) |
| **Session Strategist** | Triaging failures, directing implementation agents, maintaining priority stack | [`SESSION_STRATEGIST.md`](SESSION_STRATEGIST.md) |
| **Planner** | Creating task files, reviewing backlog, routing work | [`WORKFLOW_README.md`](WORKFLOW_README.md) |

If your role is not specified in the handoff, ask before proceeding.

---

## 🚨 The 5-Stage Workflow Gate (MANDATORY)

## 🚨 The 7-Stage Surgical Workflow (MANDATORY)
Applies to: Session Strategists, Documentation Strategists, and Planners. This protocol is the only authorized way to move from a "Problem" to a "Fixed Spec." No agent may skip stages.

### PHASE A: PREPARATION (The Map Room)
**Research Intent:** Search docs/ for original architectural patterns. Identify the "Canonical Precedent" (e.g., how was the last structure validated?).

**Audit Documentation:** Compare "Intent" vs. "Recorded State." Document any discrepancies in the chat.

**Code Inquiry (Human-in-the-Loop):** Request specific grep, cat, or ls commands. Constraint: You must see the current code logic before proposing changes.

### PHASE B: AUTHORIZATION (The Gate)
**Draft Action Plan:** Present a bulleted sequence of the fix (e.g., "Step 1: Update callback, Step 2: Fix Factory").

**Human Approval:** STOP. Do not generate a task file until the human explicitly approves the Action Plan.

### PHASE C: EXECUTION & OVERSIGHT (The Engine Room)
**Task & Handoff:** Generate the .md file in active/ and provide the copy-paste Handoff Command for the Implementation Agent (GPT-4.1/Local).

**Guidance & Review:** Monitor the Implementation Agent’s output.

Compare their results against the Action Plan.

Provide course corrections if they hit unexpected errors.

Finalize the session by updating CURRENT_STATUS.md and drafting the Session Handoff.


## Current Project State

> **Always check [`CURRENT_STATUS.md`](CURRENT_STATUS.md) for the live state.**  
> The summary below is a snapshot — CURRENT_STATUS.md is the authoritative source.

- **Phase**: RSpec test suite restoration — reducing failures toward target of <50
- **Stack**: Ruby 3.4.3, Rails, PostgreSQL, Docker (all work runs in container)
- **Test suite**: ~3,900 examples, failures being reduced session by session
- **Integration specs**: Do not touch until unit/service layer is clean

---

## Where Everything Lives

### Agent Operations
```
docs/agent/
├── README.md                          ← you are here
├── CURRENT_STATUS.md                  ← live project state, check every session
├── IMPLEMENTATION_AGENT_README.md     ← implementation agent role and rules
├── SESSION_STRATEGIST.md              ← session triage role
├── WORKFLOW_README.md                 ← planner role
├── TASK_TEMPLATE.md                   ← canonical template for new task files
├── AGENT_ROUTING.md                   ← agent roster, cost guide, doc index
├── rules/
│   ├── TASK_PROTOCOL.md               ← task creation standards (planner reference)
│   └── ENVIRONMENT_BOUNDARIES.md     ← command safety rules
├── tasks/
│   ├── active/                        ← currently assigned tasks
│   ├── backlog/                       ← queued tasks (~176 files)
│   ├── critical/                      ← start here if present
│   ├── completed/                     ← finished tasks, reference only
│   └── session-handoffs/              ← end-of-session handoff documents
└── planning/
    └── RESTORATION_AND_ENHANCEMENT_PLAN.md  ← 6-phase project roadmap
```

### Project Documentation
```
docs/
├── GUARDRAILS.md                      ← agent operating rules — read this version only
├── CURRENT_STATUS.md                  ← live project state
├── GLOSSARY_SYSTEM_MECHANICS.md       ← game mechanics terminology
├── MIGRATION_GUIDE.md                 ← database migration patterns
├── PRACTICAL_TESTING_GUIDE.md         ← testing quick reference
├── agent/                             ← agent operations (see above)
├── architecture/                      ← system design, game mechanics, intent docs
│   ├── ai_manager/                    ← AI manager architecture docs
│   ├── planetary_patterns/            ← planetary pattern docs
│   └── planning/                      ← architecture planning docs
├── ai_manager/                        ← AI manager design and strategy
├── api/                               ← API documentation
├── crafts/                            ← craft design docs
├── data/                              ← data reference docs
├── developer/                         ← setup guides, coding patterns
├── economics/                         ← economic system docs
├── flavor/                            ← easter eggs, narrative flavor
├── gameplay/                          ← game mechanics and terraforming
├── legacy/                            ← historical reference only, do not modify
├── market/                            ← market system docs
├── mission_profiles/                  ← mission design docs
├── operations/                        ← operational docs
├── reference/                         ← technical reference material
├── storyline/                         ← narrative, lore, faction design
├── systems/                           ← individual game system docs
├── testing/                           ← testing guides
├── tutorials/                         ← user tutorials
├── user/                              ← user-facing docs
└── wormhole_expansion/                ← wormhole network expansion docs
```

### Codebase
```
app/
├── models/                            ← Rails models
│   ├── units/                         ← game units (base_unit, life support, energy, etc.)
│   ├── celestial_bodies/              ← planets, stars, moons, etc.
│   ├── biology/                       ← life forms, biosphere simulation
│   ├── organizations/                 ← factions, companies, governments
│   └── settlement/                    ← settlement and habitat models
├── services/
│   ├── ai_manager/                    ← AI Manager services
│   ├── manufacturing/                 ← production and assembly services
│   ├── logistics/                     ← supply chain and contract services
│   └── lookup/                        ← data lookup services
└── javascript/                        ← frontend JS (surface_view, monitor, biome_renderer)

data/                                  ← host-side data directory (gitignored)
├── json-data/                         ← mounted into container at /home/galaxy_game/app/data
│   ├── blueprints/units/              ← unit blueprint files (*_bp.json)
│   ├── operational_data/units/        ← unit operational data (*_data.json)
│   └── templates/                     ← versioned templates (never modify directly)
├── geotiff/                           ← NASA elevation data files
└── logs/                              ← RSpec log output (maps to /home/galaxy_game/log/)

spec/
├── models/                            ← model specs
├── services/                          ← service specs
├── integration/                       ← integration specs (do not touch during restoration)
└── factories/                         ← FactoryBot factories
```

> ⚠️ `data/` is gitignored and Docker-mounted. Never reference paths inside it
> with hardcoded strings. Always use `GalaxyGame::Paths::CONSTANT` in application code.
> Inside the container, json-data resolves to `/home/galaxy_game/app/data`.
> On the host, logs are at `./data/logs/` which maps to `/home/galaxy_game/log/`.

---

## Critical Rules — Every Agent

These apply regardless of role. Violations have caused data loss in the past.

**1. All commands run inside Docker — no exceptions**
```bash
# Correct
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/path/to/spec.rb'

# Git is the only exception — runs on host directly
git add [specific files]
git commit -m "..."
```

**2. Always unset DATABASE_URL before RSpec**  
Omitting it points Rails at the development database and will corrupt it.

**3. Never use `docker-compose exec`**  
Always use `docker exec -it web`. The compose form has caused dev database corruption.

**4. Never modify template files**  
Copy → rename → edit the copy. Templates live in `data/json-data/templates/` on the host.

**5. Never create documentation during implementation tasks**  
Flag the gap in your completion report. Create docs in a separate task.

**6. Read `GUARDRAILS.md` before making architectural changes**  
It defines what is and isn't permitted. Use the current version — ignore `.old` files.

**7. RSpec Output Policy — Never Stream Full Output**
- Single spec file: `rspec spec/path/to/file_spec.rb` OK to stream
- Multiple files or full suite: ALWAYS redirect → `rspec spec/... > log/rspec_full_$(date +%s).log 2>&1`
- Report back ONLY: final summary line + targeted failure snippets from the log
- NEVER paste full RSpec output to chat/IDE — crashes VSCode buffer (happens repeatedly)

**8. Never recreate large or canonical documentation files**
Always use direct file operations (mv/cp) to move or copy large or canonical documentation files (such as wh-expansion.md or architecture docs). Never attempt to read and then recreate these files, as this risks data loss, corruption, or loss of metadata. This rule applies to all agents and automation.

---

## Key Architectural Decisions

These are locked. Do not change without explicit human approval.

| Decision | Detail |
|---|---|
| `biomass` | Cultivated algae bioreactor output only — not raw organic waste |
| `digestate` | Post-digestion slurry from biogas digester — distinct from compost |
| Gas outputs | All route through tank farm — no direct unit-to-unit transfer |
| `growing_medium` | Flexible input on inflatable greenhouse — accepts hydroponic_medium or compost |
| Craft name | Heavy Lift Launcher (not Starship) |
| Engine name | Methane Engine (not Raptor Engine) |
| Folder: `biogas_generator_engine` | Lives in `energy/` |
| Folder: `biogas_digester` | Lives in `life_support/` |
| Blueprint version | v1.3 is current standard |
| Terraforming vs Engineered | Terraforming = habitable zone worlds. Engineered = hostile environments. Different strategy trees. |

**Before touching life support units or precursor mission code, read:**
- `docs/architecture/life_support_waste_recycling_architecture.md`
- `docs/architecture/precursor_mission_bootstrap_architecture.md`

---

## Session Handoff

At the end of every session the Session Strategist produces a handoff note covering:
- Starting and ending failure baseline
- What was completed
- Architectural decisions made
- Tomorrow's priority list

Handoff documents live in `docs/agent/tasks/session-handoffs/`.
Check the most recent one before starting work each session.

---

## Agent Routing Quick Reference

Full routing guide with cost tiers: [`AGENT_ROUTING.md`](AGENT_ROUTING.md)

| Need | Use |
|---|---|
| Architecture decision | Planning Agent (free web) |
| Task file creation | Planning Agent (free web) |
| Simple targeted fix | Low-tier implementation agent (0x) |
| Multi-step implementation | Mid-tier implementation agent (0.25-0.33x) |
| Complex reasoning / stuck agent | High-tier implementation agent (1x) |
| Game design brainstorming | Creative web agent (free) |
| Sprite / image generation | Image generation agent (free) |
| Research / external reference | Research web agent (free) |
