# Session Handoff — March 13, 2026

## Current Baseline
Last overnight run: 4023 examples, 183 failures, 18 pending
Current cluster run (manufacturing/pressurization/logistics/terra_sim): 327 examples, 13 failures

## Branch
`regional-view-phase2` — pushed to origin as of this session

## Agent Workflow
- Claude — diagnosis, task authoring
- GPT-4.1 (GitHub Copilot) — implementation
- Grok — documentation only (0.33x cost)
- Gemini Flash — complex multi-file fixes (premium, use sparingly)

## Mandatory Test Command Format
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [spec] > ./log/rspec_full_$(date +%s).log 2>&1'
```
Note: use `docker exec -it web` NOT `docker exec -it web bash -c` with docker-compose.

## Overnight Full Run Command
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'
```
Run this before bed. Check results in morning with:
```bash
tail -20 $(ls -t /home/galaxy_game/log/rspec_full_*.log | head -1)
```

---

## REMAINING FAILURES — CURRENT CLUSTER (13 total)

### 1. shell_printing_service_spec (5 failures — lines 115,127,137,153,205)
**Root cause:** Printer unit not operational in test setup.
`ShellPrintingService` raises "Printer must be operational" because factory creates
printer in non-operational state.
**Fix needed:** In spec `before` block for 'with sufficient materials' context,
make printer_unit operational. Check how `operational?` works:
```bash
docker exec -it web bash -c 'grep -n "def operational?" /home/galaxy_game/app/models/structures/base_structure.rb'
```
Then stub or set the printer operational before calling `enclose_inflatable`.

### 2. assembly_service_spec:56 (1 failure)
**Root cause:** Balance assertion mismatch — tenant fee being charged but assertion wrong.
Test description says "charges the tenant fee" so fee IS expected.
**Fix needed:** Check what fee is being charged and update assertion to expect
`initial_player_balance - fee_amount`.
```bash
docker exec -it web bash -c 'sed -n "50,80p" /home/galaxy_game/spec/services/manufacturing/assembly_service_spec.rb'
```

### 3. pressurization_service_spec (4 failures — lines 74,130,162,211)
**Root cause:** GPT-4.1 committed the rewrite but the spec in the container still
has OLD content with depot_tank references at different line numbers than expected.
The rewrite task file is at `/mnt/user-data/outputs/pressurization_spec_rewrite_v3.md`
**Fix needed:** Verify what's actually in the file and reapply the rewrite if needed:
```bash
docker exec -it web bash -c 'head -20 /home/galaxy_game/spec/services/pressurization/structure_pressurization_service_spec.rb'
```
The correct spec uses `create(:item, material_type: :gas)` NOT `create(:depot_tank)`.

### 4. logistics/contract_service_spec:18 (1 failure)
**Root cause:** `valid_settlement_pair?` returning false. Settlements created with
player owner, but method requires NPC owner.
Previous fix added `respond_to?(:is_npc?)` check but it may not have persisted.
**Fix needed:** Verify current state:
```bash
docker exec -it web bash -c 'sed -n "67,75p" /home/galaxy_game/app/services/logistics/contract_service.rb'
```
And verify spec uses `:independent` trait:
```bash
docker exec -it web bash -c 'sed -n "1,10p" /home/galaxy_game/spec/services/logistics/contract_service_spec.rb'
```

### 5. geosphere_initializer_spec:158,174 (2 failures — regolith)
**Root cause:** `before` block tries to stub `determine_regolith_depth` which
doesn't exist, but the `column_exists?` check inside the `it` blocks never runs.
Previous fix wrapped the stubs in `column_exists?` check but may not have persisted.
**Fix needed:** Verify:
```bash
docker exec -it web bash -c 'sed -n "148,158p" /home/galaxy_game/spec/services/terra_sim/geosphere_initializer_spec.rb'
```
The `before` block should have:
```ruby
if ActiveRecord::Base.connection.column_exists?(:geospheres, :regolith_depth)
  allow_any_instance_of(TerraSim::GeosphereInitializer).to receive(:determine_regolith_depth).and_return(3.0)
  allow_any_instance_of(TerraSim::GeosphereInitializer).to receive(:determine_particle_size).and_return(0.5)
end
```

---

## KNOWN FAILURES (pre-existing, not our responsibility this session)

- `strategy_selector_spec:233,381` — 2 failures (Gemini Flash task assigned:
  `docs/agent/tasks/backlog/strategy_selector_scoring_spec_fixes.md`)
- `world_knowledge_service_spec:9` — pollution-dependent, passes in isolation
- `fitting_service_spec:30,47` — pollution-dependent, passes in isolation
- `game_spec:66,72` — pollution-dependent, passes in isolation
- `route_proposal_spec` + `route_proposal_vote_spec` — schema issue, `proposal_id` column
- Integration specs (~25 failures) — complex, separate project
- Models cluster (~50 failures) — separate project
- `lookup/unit_lookup_service_spec` — 14 failures (new, needs investigation)
- `lookup/planetary_geological_feature_lookup_service_spec` — 14 failures (pollution)

---

## KEY ARCHITECTURE NOTES (READ BEFORE WRITING ANY NEW SERVICE)

### Inventory System
- ALL physical items live in `settlement.inventory.items` or `craft.inventory.items`
- Gas items: `inventory.items.where(material_type: :gas)`
- Units (inflatable_gas_storage etc.) add CAPACITY only — never store item quantities
- NEVER query `structure.operational_data['gas_storage']` for gas quantities
- Full doc: `docs/architecture/inventory_system.md` (committed this session)

### Settlement Ownership
- Settlements ALWAYS have an owner (player or NPC corporation)
- NPC check: `owner.respond_to?(:is_npc?) && owner.is_npc?`
- Never check `owner.nil?` alone — always include nil fallback for safety
- `:independent` factory trait sets `owner: nil` for test isolation

### Settlement orbital?
- `orbital?` method added to `BaseSettlement` this session
- Returns true if `is_a?(SpaceStation) || settlement_type == 'station'`

### AI Manager Resource Decisions
- Full doc: `docs/agent/decisions/03_resource_decisions.md` (committed this session)
- AI Manager must verify ownership before acting on any resource
- Standing orders system is a backlog task

---

## FILES MODIFIED THIS SESSION
- `app/services/manufacturing/cost_calculator.rb` — operator precedence fix + print_breakdown fix
- `app/services/manufacturing/byproduct_manufacturing_service.rb` — use inventory not structures
- `app/services/pressurization/structure_pressurization_service.rb` — use inventory not structures
- `app/services/logistics/contract_service.rb` — NPC ownership check
- `app/services/logistics/inventory_manager.rb` — added orbital? usage
- `app/services/terra_sim/atmosphere_simulation_service.rb` — clamp temperatures
- `app/services/terra_sim/geosphere_simulation_service.rb` — use public ice_tectonics_enabled?
- `app/models/settlement/base_settlement.rb` — added orbital? method
- `app/models/celestial_bodies/spheres/geosphere.rb` — made ice_tectonics methods public
- `spec/services/ai_manager/mission_planner_service_spec.rb` — factory + atmosphere fixes
- `spec/services/pressurization/structure_pressurization_service_spec.rb` — full rewrite
- `spec/services/terra_sim/geosphere_initializer_spec.rb` — ice giant + regolith fixes
- `spec/rails_helper.rb` — descendants cache reset
- `docs/architecture/inventory_system.md` — new
- `docs/agent/decisions/03_resource_decisions.md` — new

---

## NEXT SESSION PRIORITIES
1. Verify/reapply fixes that may not have persisted (pressurization, geosphere, logistics)
2. Fix shell_printing_service_spec (5 failures)
3. Fix assembly_service_spec:56 (1 failure)
4. Investigate unit_lookup_service_spec (14 new failures)
5. Queue overnight full suite run before bed
6. Target: 183 → ~150 failures
