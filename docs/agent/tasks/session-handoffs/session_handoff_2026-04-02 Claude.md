Session Handoff — 2026-04-02
Session Metrics
Start: 59 failures → End: unknown (no full suite run today — intentional, focus was design restoration not spec chasing)
Agent budget: GPT-4.1 primary, Claude Sonnet strategist/planner
Time: Full day session
What Was Completed
DB Recovery:

GPT-4.1 had contaminated dev DB by running commands with DATABASE_URL set
Restored ar_internal_metadata environment from test back to development
Dev DB confirmed intact at migration 20260327213844

Commits landed today:

isru_operations.md — authoritative ISRU agent rules, references existing docs
Units factory operational? fix — sets operational_properties.status correctly
Orbital shipyard stub — Settlement::OrbitalSettlement stub + factory + spec fixes
MaterialProcessingService restored — removed agent bloat, uses UnitLookupService + geosphere

Key Architectural Decisions Made
ISRU design confirmed and documented:

JSON is the source of truth. Ruby is the executor. Never hardcode unit behavior.
TEU and PVE are independent machines — no hard chain dependency
PVE output amounts are zero by design — geosphere-driven yields
atmosphere.gases is live state — always read this, never composition field
MaterialPile is a flow buffer, not primary storage
Power is a hard gate for ISRU, not a weighted score
Regolith Harvester Rover is the logistics layer at bootstrap phase
Bootstrap sequence: power/comms → ISRU → gas processing → construction scales

Agent policy confirmed:

GPT-4.1 0x is the default implementation agent
Claude Sonnet 1x only when task cannot be pre-specified
Never fix specs against wrong implementations — fix the design first
Active folder = agent working on it RIGHT NOW, max 1-2 files

Remaining ISRU Work
ISRUEvaluator restoration (next priority)
Task file: docs/agent/tasks/active/2026-04-02-HIGH-BUG-FIX-RESTORE-ISRU-EVALUATOR-INTENDED-DESIGN.md
Agent: GPT-4.1 0x
What it does: Remove ISRU_UNITS and GAS_COMPOSITION constants, implement throughput evaluation using UnitLookupService + geosphere.crust_composition + atmosphere.gases
Data chains confirmed working:

settlement.celestial_body.geosphere.crust_composition
settlement.celestial_body.atmosphere.gases.pluck(:name, :percentage).to_h
Lookup::UnitLookupService.new.find_unit(unit.unit_type)
Factory pattern: create(:large_moon, :luna) → create(:celestial_location, celestial_body:) → create(:base_settlement, :independent, location:)

EscalationService fix (after ISRUEvaluator)
Task file: docs/agent/tasks/validated/2026-02-11-HIGH-ESCALATION-FIX-WATER-ESCALATION-ISRU-CHAIN.md
Note: Needs expanding into full task file before assigning. Validated stub only.
What it does: Remove generic robot water extraction, replace with TEU/PVE chain check
Why ISRU Matters
ISRU works correctly
  → Lunar base develops autonomously
    → Structural components produced locally
      → L1 Station components fabricated
        → L1 Settlement (Shipyard + Depot) established
          → Cycler network becomes possible
First Action Tomorrow
Assign ISRUEvaluator restoration to GPT-4.1:
Read these files before touching anything:
1. docs/agent/README.md
2. docs/architecture/operations/isru_operations.md
3. docs/agent/tasks/active/2026-04-02-HIGH-BUG-FIX-RESTORE-ISRU-EVALUATOR-INTENDED-DESIGN.md

Run Step 1 blast radius audit only. STOP and report.
Path Reminder

Host app files: galaxy_game/app/...
Container paths: /home/galaxy_game/app/... (or just app/... from working dir)
Docs: docs/... (repo root, host only)
Always unset DATABASE_URL before RSpec
Never docker-compose exec — always docker exec -it web