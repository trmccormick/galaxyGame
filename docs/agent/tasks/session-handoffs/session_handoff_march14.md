# Session Handoff — March 14, 2026

## Current Baseline
Last overnight run: 4022 examples, 174 failures, 18 pending
Current cluster run (manufacturing/pressurization/logistics/terra_sim): 317 examples, 8 failures, 2 pending

## Branch
`regional-view-phase2` — pushed to origin as of this session

## Agent Workflow
- Claude — diagnosis, task authoring, architecture decisions
- GPT-4.1 (GitHub Copilot) — implementation
- Grok — documentation only (0.33x cost) — **UNAVAILABLE until next month, premium exhausted**
- Gemini Flash — complex multi-file fixes (premium, use sparingly)

## Mandatory Test Command Format
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [spec] > ./log/rspec_full_$(date +%s).log 2>&1'
```
Note: use `docker exec web` (no `-it`) for long-running commands to avoid interruption.
Use `docker exec -it web bash -c` for short commands only.

## Overnight Full Run Command
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'
```

---

## REMAINING FAILURES — CURRENT CLUSTER (8 total)

### 1. assembly_service_spec (1 failure)
**Root cause:** Account balance mismatch — tenant fee assertion wrong.
**Status:** Was fixed earlier this session but may have regressed. Verify.
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/assembly_service_spec.rb:56 --format documentation 2>&1 | tail -20'
```

### 2. shell_printing_service_spec (5 failures)
**Root cause:** `status` attribute missing on `printer_unit` — printer not
operational in test setup.
**Status:** Was partially addressed this session but still failing.
```bash
docker exec -it web bash -c 'grep -n "def operational?" /home/galaxy_game/app/models/structures/base_structure.rb'
docker exec -it web bash -c 'sed -n "100,215p" /home/galaxy_game/spec/services/manufacturing/shell_printing_service_spec.rb'
```

### 3. geosphere_initializer_spec:158,174 (2 failures)
**Root cause:** `determine_regolith_depth` method missing — column_exists? guard
may have been lost in this session's changes.
**Fix needed:** Verify the guard is still in place:
```bash
docker exec -it web bash -c 'sed -n "143,165p" /home/galaxy_game/spec/services/terra_sim/geosphere_initializer_spec.rb'
```
The before block should have:
```ruby
if ActiveRecord::Base.connection.column_exists?(:geospheres, :regolith_depth)
  allow_any_instance_of(TerraSim::GeosphereInitializer).to receive(:determine_regolith_depth).and_return(3.0)
  allow_any_instance_of(TerraSim::GeosphereInitializer).to receive(:determine_particle_size).and_return(0.5)
end
```

---

## COMPLETED THIS SESSION
- ✅ Pressurization spec duplicate block removed (4 failures resolved)
- ✅ DatabaseCleaner strategy moved to before(:suite) — pollution fix applied to rails_helper.rb
- ✅ Settlement factory default owner changed from player to DC corporation
- ✅ `:independent` trait restored to colony: nil only
- ✅ `development_corporation` factory trait added to organizations factory
- ✅ `valid_settlement_pair?` confirmed correct — NPC ownership check is right
- ✅ `Logistics::Provider` records seeded for AstroLift, Zenith, Vector
- ✅ `find_provider` method added to ContractService
- ✅ `PlayerContractService` call guarded with `defined?` check
- ✅ contract_service_spec passes with stubbed find_provider
- ✅ Architecture docs committed to docs/architecture/

## KNOWN FAILURES (pre-existing, not our responsibility)
- `strategy_selector_spec:233,381` — 2 failures (Gemini Flash task assigned)
- `world_knowledge_service_spec:9` — pollution-dependent
- `fitting_service_spec:30,47` — pollution-dependent
- `game_spec:66,72` — pollution-dependent
- `route_proposal_spec` + `route_proposal_vote_spec` — schema issue
- Integration specs (~25 failures) — separate project
- Models cluster (~50 failures) — separate project
- `lookup/unit_lookup_service_spec` — 14 failures (needs investigation)
- `lookup/planetary_geological_feature_lookup_service_spec` — 14 failures

## BACKLOG TASKS CREATED THIS SESSION
- `docs/agent/tasks/backlog/logistics_provider_capabilities_serialization_fix.md`
  — `find_provider` capabilities field serialized as JSON string vs Ruby array.
  Silent failure in production if no provider found. Fix: JSON.parse with rescue.

---

## KEY ARCHITECTURE DECISIONS MADE THIS SESSION

### Settlement Ownership
- Default settlement owner is DC corporation (not player)
- `:independent` trait = no colony membership only, always has an owner
- Settlements ALWAYS have an owner (player, NPC corp, eventually colony)

### Logistics Provider Architecture
- `Logistics::Provider` = operational interface of a logistics corporation
- `Organizations::BaseOrganization` = economic/legal entity
- Two layers linked via `belongs_to :organization`
- Full intent: `docs/architecture/LOGISTICS_PROVIDER_INTENT.md`

### Contract Service
- `valid_settlement_pair?` checks NPC ownership — CORRECT, do not change
- Internal transfers are DC/NPC corporation B2B only (LDC ↔ AstroLift model)
- `PlayerContractService` is Act 2 — guarded with `defined?` check
- Provider assigned to every contract via `find_provider` by capability

### Price Discovery
- GCC pegged 1:1 to USD at launch (market priming)
- EAP = Earth spot price × refining factor + transport cost
- Prices drop as infrastructure matures (LEO depot → L1 shipyard → cyclers)
- Full lifecycle: `docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md`
- LOX is always locally produced — never on Earth import list for est. settlements
- N2 is permanent import on Luna — no local source

### Precursor Mission Sequence (ALL launched from Earth)
1. Luna base deployment (Heavy Lift Transport, AstroLift)
2. Venus harvester in optimal transfer window (~112 day transit)
   → delivers N2 and LOX to Luna
3. Multiple Titan harvesters staggered (~900 day transit each)
   → delivers methane and N2 to Luna
   → minimum 3 harvesters for uninterrupted methane supply
- Luna landing pads MUST be ready before harvesters return (critical path)
- Self-sustaining loop: Titan methane → Sabatier → more LOX → refuel harvester

### Construction Player Participation Model
- Large DC projects (Worldhouse, terraforming) = fully AI Manager driven
- Player participation = supply chain only (fill component/material buy orders)
- Player scale = personal bases, ships, small structures = fully player driven

### Craft Naming
- "Heavy Lift Transport" replaces "Starship" — avoids IP issues
- Blueprint: `heavy_lift_transport_bp.json`
- Cycler blueprints still reference `ibeam` — needs updating to `3d_printed_ibeam`

---

## NEXT SESSION PRIORITIES
1. Verify/fix assembly_service_spec:56 (balance assertion)
2. Fix shell_printing_service_spec (5 failures — printer operational status)
3. Verify geosphere_initializer_spec regolith guard still in place
4. Fix find_provider capabilities serialization (backlog task exists)
5. Investigate unit_lookup_service_spec (14 failures)
6. Queue overnight full suite run
7. Target: 174 → ~150 failures

## ARCHITECTURE DOCS NEEDING PRICE DISCOVERY UPDATE
`docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md` was placed this session but
needs updating with:
- Correct precursor mission sequence (Earth-launched harvesters)
- N2 permanent import dependency
- Harvester fleet economics (3+ Titan harvesters for continuous supply)
- Luna readiness dependency (critical path for harvester return)
- Technology progression effect on production costs (PVE Mk1→Mk3 efficiency)
- GCC/USD peg section already added ✅
