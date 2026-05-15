# Galaxy Game — Domain Context Guide
**Last Updated**: May 14, 2026
**Populated By**: GitHub Copilot
**Source**: `docs/agent/`

> This file provides domain context for any agent working on the Galaxy Game project.
> `@file` this into your Continue session before starting any Galaxy Game task.
> Do not duplicate content already in `rules/DECISIONS.md` — reference it instead.

---

## Codebase Overview
<!-- AGENT: Extract from legacy docs — what is this project, what does it do,
     what is the tech stack (language, framework, key gems/libraries) -->
Galaxy Game is a space colonization simulation built in Ruby on Rails. Players manage settlements across the solar system and beyond, handling resource extraction (ISRU, mining, atmospheric harvesting), life support (closed-loop ecosystems, waste recycling, water/oxygen/food cycles), manufacturing (unit assembly, blueprint-driven construction, material processing), trade & logistics (markets, contracts, supply chains between settlements), terraforming (long-timescale atmosphere, biosphere, and temperature simulation), engineered worlds (technology-driven colonization for hostile environments like Titan, Europa), and AI Manager (autonomous settlement expansion, resource allocation, wormhole network routing).

The codebase is a Rails monolith with a large RSpec test suite currently under active restoration. Tech stack includes Ruby 3.4.3, Rails, PostgreSQL, Docker (all work runs in container).

---

## Key Domain Concepts
<!-- AGENT: Extract core game concepts agents need to understand to work on this code.
     Examples: what is a Robot, what is a Battery, what is PLEX, what is ISRU,
     what is the AI Manager, what is the Luna/regional system.
     One paragraph per concept. -->
**ISRU (In-Situ Resource Utilization)**: Extracting and processing resources directly from planetary bodies without needing to transport everything from Earth, enabling self-sustaining colonies.

**AI Manager**: Autonomous system for settlement expansion, resource allocation, and wormhole network routing that manages complex decision-making for colony operations.

**Luna/Regional System**: Settlement management across different celestial bodies, with regional variations in resource availability, environmental challenges, and colonization strategies.

**PLEX**: Not found in legacy docs — may refer to some game mechanic or unit type.

**Robot/Battery Pattern**: No specific content found in legacy docs for this pattern.

---

## Economy Rules
<!-- AGENT: Extract economy and currency rules from legacy docs.
     Known values to confirm or expand:
     - 1 USD = 1 GCC (Galactic Crypto Currency)
     - SCC Surcharge: 0.5%
     - Broker Fee: 0.3%
     - Sales Tax: 3.37%
     - Manufacturing: Market vs. Build balance
     Add any other economy rules found in legacy docs. -->
Player-driven market (EVE-style). Governed by 'Market vs. Build' logic and fixed tax overheads:
- SCC Surcharge: 0.5%
- Broker Fee: 0.3%
- Sales Tax: 3.37%

---

## Code Patterns
<!-- AGENT: Extract the Robot/Battery pattern, job lifecycle, and any other
     recurring patterns agents must follow when writing or editing code.
     Include file locations where these patterns are defined. -->

### Unit Model Pattern (Robot/Battery Pattern)
All unit subclasses follow the Robot/Battery pattern:
- Read everything from `operational_data`
- No `attr_accessor` for config values
- No `initialize` overrides
- No hardcoded unit type lists in BaseUnit
- `job_types` driven by `operational_data`

Defined in: docs/new_agent/rules/DECISIONS.md

### No Hardcoded Luna Logic
All Luna-specific behavior must be data-driven from `operational_data` or JSON config files.
No Ruby class may contain hardcoded Luna resource values, capacities, or production rates.
If a value is Luna-specific, it belongs in the Luna mission profile JSON, not in code.

---

## Codebase Map (Summary)
<!-- AGENT: Extract key directory and file locations from legacy docs or CODEBASE_MAP.md.
     Focus on locations most relevant to active development:
     models, specs, jobs, services, config. -->
Key locations from legacy docs:

- `app/models/` - Rails models including units, celestial_bodies, biology, organizations, settlement
- `app/services/` - Services including ai_manager, manufacturing, logistics, lookup
- `spec/` - RSpec tests with models, services, integration specs
- `data/json-data/` - Blueprint files, operational data, templates (mounted into container)
- `docs/agent/` - Agent operations, protocols, tasks

---

## Active Development Context
<!-- AGENT: Extract current branch, active feature area, and any known constraints
     or gotchas relevant to the current phase of development.
     Current known: branch regional-view-phase2, Luna/ISRU work, AI Manager training. -->
Current development phase: RSpec test suite restoration, reducing failures toward target of <50. Active areas include AI Manager services, manufacturing pipeline, unit lookup services. Recent work on Luna settlement integration, ISRU processing chains, and planetary geological features.

---

## RSpec Conventions
<!-- AGENT: Extract any project-specific RSpec conventions, helpers, shared examples,
     or spec folder structure that agents need to know. -->
All Rails/RSpec commands run inside Docker container using `docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ...'`. Never run RSpec on host or without unsetting DATABASE_URL. Use local let blocks for dependencies instead of global seeds. For full suite runs, always redirect output to log files. Single spec files can stream output, but multiple files must log.

---

## What Not To Do
<!-- AGENT: Extract any explicit warnings, anti-patterns, or common mistakes
     documented in legacy agent files for this project. -->
Never run RSpec without unsetting DATABASE_URL (will corrupt dev database). Never use docker-compose exec (caused dev database corruption). Never modify template files directly — copy and rename. Never recreate large documentation files — use direct file operations. Always validate JSON data files with python3 before saving. Never create world constants in factories — use finders for Sol bodies, GCC, USD, etc. Never stream full RSpec output to chat — redirect to logs. Never apply fixes without user approval.
