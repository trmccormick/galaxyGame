# Session Handoff — 2026-04-05

## Session Metrics
Start: 93 failures → End: 45 failures (48 cleared)
Branch: regional-view-phase2
Executor: GPT-4.1 primary, Claude Sonnet planning
Time: Full day + evening session

---

## Current Baseline
3952 examples, 45 failures, 43 pending
Previous baseline: 58 failures (stale) / 93 failures (actual at session start)
Change this session: -48 failures
**<50 target: MET ✅**

---

## What Was Accomplished

### Major Fixes Committed
1. **StateAnalyzer constructor cascade** — `strategy_selector.rb` was calling
   `StateAnalyzer.new(shared_context)` after yesterday's rewire changed it to
   0 args. Cleared ~40 failures in one commit.
   Commit: "Fix: Remove argument from StateAnalyzer.new"

2. **construction_job factory missing jobable** — `after(:build) { |job| job.jobable ||= job.settlement }`
   Cleared 2 failures: material_request_system_spec + material_request_service_spec
   Commit: construction_job factory jobable fix

3. **Financial::Transaction namespace** — `base_organization.rb` line 114
   called `FinancialTransaction.create!` → fixed to `Financial::Transaction.create!`
   Commit: "fix: base_organization — replace FinancialTransaction with Financial::Transaction namespace"

4. **Game#advance_by_days guard clause** — missing `return if days <= 0` in
   `models/game.rb` (two other versions already had it)
   Commit: "fix: game#advance_by_days — guard clause for zero or negative days"

5. **sandbox_environment.rb monkey-patch removed** — `app/services/ai_manager/testing/sandbox_environment.rb`
   was monkey-patching `ActiveRecord::Base.create` with RSpec `double()` via
   Rails autoload, contaminating the entire test suite. Removed `setup_mock_database`
   method and its call site. Cleared fitting_service + cascade cleared item_spec,
   material_lookup_service_spec, processing_service_spec.
   Commit: "fix: remove setup_mock_database monkey-patch from sandbox_environment"

6. **World knowledge service easter egg rarity** — stubbed `rand` in failing
   example for deterministic wormhole easter egg test.
   Commit: "fix: world_knowledge_service_spec — stub rand for deterministic wormhole easter egg"

---

## Architecture Decisions Made This Session

### Manufacturing Cost Model (CONFIRMED)
- Blueprint `cost_data` is display hint only — never used for runtime cost
- Real cost = BOM materials × `Market::NpcPriceCalculator.calculate_ask(settlement, material)`
- AI Manager seeds initial prices; players adjust via market
- Earth launch cost is price ceiling for locally produced goods
- `NpcPriceCalculator` already fully implemented — just needs wiring
- Jan 8 Time Machine backup of `ManufacturingService` is clean baseline reference

### Manufacturing Namespace (CONFIRMED)
- Intent was always `Manufacturing::` namespace
- January code loss left both `ManufacturingService` (git-restored legacy)
  and `Manufacturing::Service` (agent copy) in place
- `Manufacturing::Service` is a direct copy of Jan 8 version with logging added
- `ManufacturingService` is canonical for now — BOM cost refactor targets it
- Full namespace migration is a separate planned task

### AI Manager Testing Files (CONFIRMED)
- `app/services/ai_manager/testing/` contains legitimate AI governance logic
  (`ValidationSuite`, `BootstrapController`, `PerformanceMonitor`) but wrong location
- `SandboxEnvironment.setup_mock_database` was the contamination — removed
- Remaining three files stay in `app/` for now — module name `AIManager::Testing`
  is misleading but the logic is real (decision validation, scenario bootstrap,
  performance monitoring)
- Digital twin UI (`views/admin/digital_twins/`) is real work — controller uses
  Rails.cache, no connection to these testing files
- Phase 4 digital twin system will be built properly from scratch

### Settlement vs Structure Classification (CONFIRMED)
- Space stations are STRUCTURES, not settlements
- `Settlement::SpaceStation` → `Structures::SpaceStation` (part of 2026-03-31 refactor)
- `Settlement::OrbitalDepot` → `Structures::OrbitalDepot` (unmanned = structure)
- `Structures::BaseStructure` already has `belongs_to :settlement, optional: true` ✅
- Wormhole gate stations are structures (even if manned) — operational infrastructure
- `Settlement::OrbitalSettlement` is a stub — needs implementation in 2026-03-31
- `infrastructure_free_deployment_possible?` fix falls out naturally once
  SpaceStation/OrbitalDepot move to Structures — settlement query won't return them

### PVE Volatile Output (CONFIRMED)
- `mixed_volatiles` is wrong — real composition is known from geosphere data
- PVE units output each volatile by chemical formula (`H2O`, `CO2`, `N2`, `CH4`)
- Natural variation ±5%: `variation = 1.0 + (rand * 0.10 - 0.05)`
- `depleted_regolith` = input minus all extracted volatiles
- JSON sentinel `geosphere_volatiles` drives service routing
- Task written: `2026-04-04-HIGH-BUG-FIX-MATERIAL-PROCESSING-SERVICE-PVE-GEOSPHERE-VOLATILE-OUTPUTS.md`

### Windows Ollama Agent (STATUS)
- qwen3-coder:30b installed on Windows 11 gaming desktop (always on)
- Connected via Continue CLI (`cn`) with local config
- Terminal access working: `docker exec web` (no `-t` flag in cn)
- **GPU not accelerating** — AMD RX 580-era card (GFX8), ROCm not supported on Windows
- Vulkan enabled but `total_vram="0 B"` — model runs on CPU only
- 30B model too slow for practical use on CPU — overnight run didn't complete basic task
- **Decision: Use GPT-4.1 for all active session work, revisit Ollama when GPU works**
- qwen2.5-coder:3b (1.9GB) may be viable for simple tasks on CPU

---

## Remaining Failures — 45 Total

### Integration Specs — Do Not Touch (26 failures)
```
spec/integration/ai_manager/escalation_integration_spec.rb — 1
spec/integration/component_production_game_loop_spec.rb — 3
spec/integration/covering_system_integration_spec.rb — 1
spec/integration/manufacturing_pipeline_e2e_spec.rb — 3
spec/integration/terraforming_integration_spec.rb — 4
spec/integration/terraforming_workflow_spec.rb — 2
spec/integration/tug_construction_integration_spec.rb — 4
spec/services/ai_manager/manager_integration_spec.rb — 4
spec/services/ai_manager/manager_system_orchestrator_integration_spec.rb — 2
spec/services/ai_manager/expansion_service_spec.rb — 7 (INVENTED)
```

### Unit/Service — Addressable (19 failures)

#### Tasks Written — Ready to Assign
| Spec | Failures | Task File | Agent |
|---|---|---|---|
| `material_processing_service_spec.rb` | 2 | `2026-04-04-HIGH-BUG-FIX-MATERIAL-PROCESSING-SERVICE-PVE-GEOSPHERE-VOLATILE-OUTPUTS.md` | Claude Sonnet |
| `manfacturing_service_spec.rb` | 1 | `2026-04-04-HIGH-REFACTOR-MANUFACTURING-SERVICE-BOM-COST-VIA-NPC-PRICE-CALCULATOR.md` | Claude Sonnet |

#### Needs Factory Work
| Spec | Failures | Notes |
|---|---|---|
| `base_organization_profit_spec.rb` | 1 | `Financial::Transaction` needs `Financial::Account` + `Currency` factory setup. Task written: `2026-04-04-MEDIUM-BUG-FIX-BASE-ORGANIZATION-DISTRIBUTE-PROFITS-INVENTED-TRANSACTION-ATTRIBUTE.md` |

#### Architectural Decision Pending
| Spec | Failures | Notes |
|---|---|---|
| `space_station_spec.rb` | 1 | Blocked by 2026-03-31 orbital settlement refactor |
| `wormhole_expansion_service_spec.rb` | 1 | `infrastructure_free_deployment_possible?` — resolves after 2026-03-31 |

#### Not Yet Diagnosed
| Spec | Failures | Notes |
|---|---|---|
| `processing_service_spec.rb` | 3 | Was cleared by sandbox fix but reappeared — needs error messages |
| `item_spec.rb` | 1 | Luna identifier LUNA-37 vs LUNA-01 — factory isolation issue |
| `material_lookup_service_spec.rb` | 1 | Logger mock expects error, receives 0 times |
| `strategy_selector_spec.rb` | 1 | Scoring logic — backlog LOW |
| `game_data_generator_spec.rb` | 1 | Missing fixture — backlog LOW |

---

## Backlog Tasks Written This Session
All in `docs/agent/tasks/backlog/`:

| File | Priority | Agent | Notes |
|---|---|---|---|
| `2026-04-04-HIGH-BUG-FIX-MATERIAL-PROCESSING-SERVICE-PVE-GEOSPHERE-VOLATILE-OUTPUTS.md` | HIGH | Claude Sonnet | Luna dependency chain |
| `2026-04-04-HIGH-REFACTOR-MANUFACTURING-SERVICE-BOM-COST-VIA-NPC-PRICE-CALCULATOR.md` | HIGH | Claude Sonnet | Needs NpcPriceCalculator wiring |
| `2026-04-04-HIGH-BUG-FIX-AIMANAGER-TESTING-FILES-REMOVE-FROM-APP-AUTOLOAD.md` | HIGH | GPT-4.1 | Remaining 3 testing files reclassification |
| `2026-04-04-MEDIUM-BUG-FIX-BASE-ORGANIZATION-DISTRIBUTE-PROFITS-INVENTED-TRANSACTION-ATTRIBUTE.md` | MEDIUM | GPT-4.1 | Needs Financial::Account factory |
| `2026-04-04-MEDIUM-BUG-FIX-CONSTRUCTION-JOB-FACTORY-MISSING-JOBABLE.md` | MEDIUM | GPT-4.1 | ✅ COMPLETED this session |
| `2026-04-04-MEDIUM-BUG-FIX-MANUFACTURING-PIPELINE-E2E-THERMAL-EXTRACTION-INTERFACE.md` | MEDIUM | GPT-4.1 | Blocked until <50 failures — NOW MET |
| `2026-04-04-MEDIUM-BUG-FIX-GAME-ADVANCE-BY-DAYS-NEGATIVE-GUARD.md` | MEDIUM | GPT-4.1 | ✅ COMPLETED this session |
| `2026-04-04-MEDIUM-BUG-FIX-BASE-ORGANIZATION-PROFIT-SPEC-FINANCIAL-TRANSACTION-NAMESPACE.md` | MEDIUM | GPT-4.1 | ✅ COMPLETED this session |
| `2026-04-04-LOW-BUG-FIX-WORLD-KNOWLEDGE-SERVICE-EASTER-EGG-RARITY-SPEC.md` | LOW | GPT-4.1 | ✅ COMPLETED this session |
| `2026-04-04-LOW-BUG-FIX-MANUFACTURING-PIPELINE-E2E-THERMAL-EXTRACTION-INTERFACE.md` | LOW | GPT-4.1 | Integration spec — wait for unit layer clean |

---

## Files Modified This Session
- `galaxy_game/app/services/ai_manager/strategy_selector.rb` — StateAnalyzer constructor fix
- `galaxy_game/app/services/ai_manager/testing/sandbox_environment.rb` — removed setup_mock_database
- `galaxy_game/app/models/game.rb` — advance_by_days guard clause
- `galaxy_game/app/models/organizations/base_organization.rb` — Financial::Transaction namespace
- `galaxy_game/spec/factories/construction_job.rb` — jobable default
- `galaxy_game/spec/models/organizations/base_organization_profit_spec.rb` — Transaction schema assertions
- `galaxy_game/spec/services/ai_manager/world_knowledge_service_spec.rb` — rand stub

---

## First Actions Monday

1. **Run full suite baseline** to confirm 45 failures still clean after weekend:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
grep "examples," data/logs/rspec_full_*.log | tail -1
```

2. **Diagnose remaining undiagnosed failures** — `processing_service_spec.rb` (3),
   `item_spec.rb` (1), `material_lookup_service_spec.rb` (1):
```bash
grep -A 12 "ProcessingService\|item_spec\|MaterialLookup" data/logs/rspec_full_*.log | grep -A 10 "Failure/Error" | head -60
```

3. **Route PVE task** — `2026-04-04-HIGH-BUG-FIX-MATERIAL-PROCESSING-SERVICE-PVE-GEOSPHERE-VOLATILE-OUTPUTS.md`
   to Claude Sonnet — HIGH priority, Luna dependency chain

4. **Review 2026-03-31 orbital settlement refactor** — blocker conditions met,
   `OrbitalSettlement` is a stub ready for implementation, `BaseStructure` already
   has all needed associations

## Do Not Do Monday
- Do not touch `spec/integration/` specs
- Do not touch `expansion_service_spec.rb` — invented
- Do not bulk delete `app/services/ai_manager/testing/` files — legitimate logic,
  needs reclassification not deletion
- Do not use qwen3-coder:30b for time-sensitive tasks — CPU only, too slow

---

## Agent Routing — Updated
| Agent | Cost | Use For |
|---|---|---|
| GPT-4.1 | 0x (GitHub Copilot) | All active session fixes, quick turnaround |
| qwen3-coder:30b | 0x (local) | NOT VIABLE until GPU works — CPU too slow |
| qwen2.5-coder:3b | 0x (local) | Simple single-file tasks only, low reasoning |
| Claude Sonnet | Premium | Planning, architecture, complex multi-file tasks |

## Notes for Next Session
- `cn` CLI is installed and working on Mac — use `docker exec web` not `docker exec -it web`
- Windows AMD GPU (GFX8/RX580-era) does not support ROCm on Windows
- Vulkan enabled but showing `total_vram="0 B"` — not accelerating inference
- Jan 8 Time Machine backup available for manufacturing service reference
- The `AIManager::Testing` module name is misleading — logic is real AI governance,
  not test infrastructure. Reclassification task written.
- Rake tasks are acceptance tests for AI Manager — run after every ISRU fix:
```bash
docker exec web bash -c 'unset DATABASE_URL && bundle exec rake ai:sol:gcc_bootstrap'
docker exec web bash -c 'unset DATABASE_URL && bundle exec rake ai:lunar_base:with_isru'
```
