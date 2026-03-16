# Session Handoff — March 15, 2026

## Current Baseline
Last overnight run: 4020 examples, 185 failures, 18 pending
Expected next run: significantly lower — all cluster targets resolved plus
additional fixes committed today

## Branch
`regional-view-phase2` — pushed to origin as of this session

## Agent Workflow
- Claude — diagnosis, task authoring, architecture decisions
- GPT-4.1 (GitHub Copilot) — implementation
- Grok — documentation only — **UNAVAILABLE until next month**
- Gemini Flash — complex multi-file fixes (premium, use sparingly)
- GPT-4o — fallback when GPT-4.1 losing context
- GPT-5 mini — simple mechanical fixes, single-method additions
- Raptor mini (preview) — 0x cost, calibrate on low-risk tasks

**GPT-4.1 Escalation Rule:** If GPT-4.1 fails twice on the same file, stop
and escalate to Claude before attempting another patch. Today's `base_unit.rb`
corruption was caused by too many failed patch attempts without escalation.

---

## FIXES COMMITTED TODAY

### Cluster Failures (all resolved)
- ✅ `geosphere_initializer_spec:158,174` — method_defined? guard added
- ✅ `assembly_service_spec:56` — GCC account lookup fixed, assertion direction corrected
- ✅ `shell_printing_service_spec` (5 failures) — base_unit.rb restored from
  66ac54f2, `can_store_material?` added as public method, spec setup fixed
- ✅ `priority_heuristic_spec` (12 failures) — GCC account lookup fixed throughout
  spec and service

### Additional Fixes
- ✅ `blueprint player association` — `has_many :blueprints` added to Player
- ✅ `manfacturing_service_spec:81` — megastructure spec marked pending
  (requires MegaProjectService, not ManufacturingService)
- ✅ Dome model/spec/routes/factories removed — dead code cleanup
- ✅ `lunar_space_elevator.json` placed in correct blueprint directory

### Base Unit Restoration Note
`base_unit.rb` was corrupted by multiple failed GPT-4.1 patch attempts.
Restored from commit `66ac54f2` and `can_store_material?` added cleanly.
The file is now stable. Do not patch without Claude diagnosis first.

---

## REMAINING FAILURES — KNOWN

### Pre-existing (not our responsibility this session)
- `strategy_selector_spec:233,381` — 2 failures (Gemini Flash task assigned)
- `route_proposal_spec` + `route_proposal_vote_spec` — schema issue
- Integration specs (~25 failures) — separate project
- Models cluster (~50 failures) — separate project
- `base_unit_spec:194` — `process_resources` gas buffer, pre-existing

### Pollution-dependent (passing in isolation, resolve in next run)
- `processing_service_spec`
- `wormhole_consortium_formation_service_spec`
- `material_processing_service_spec`

---

## MANDATORY TEST COMMAND FORMAT
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [spec] > ./log/rspec_full_$(date +%s).log 2>&1'
```

## Overnight Full Run Command
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > ./log/rspec_full_$(date +%s).log 2>&1'
```

---

## CRITICAL TASKS REMAINING (2)
Both EAP tasks need reconciling with today's architecture work before assigning.
Review `docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md` and
`docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md` first.

**DO NOT assign to GPT-4.1 without Claude review:**
- `docs/agent/tasks/critical/eap_market_integration.md`
- `docs/agent/tasks/critical/eap_resource_economics_enhancement.md`

**Key context for EAP tasks:**
- EAP formula is correct for Luna: Earth spot + transport = Luna price
- N2 spot price needs fixing ($0.05 → ~$0.15-0.20/kg)
- CO2 spot price missing (needed for Sabatier)
- Titan→Luna and Venus→Luna route modifiers missing
- Routes should be data-driven from DB, not hardcoded
- `RouteCostCalculator#get_distance` needs wiring to StarDistance records
- `TransportCostService#in_situ_refueling_available?` always returns false
- Regional prices fluctuate by local abundance — CO2 is free on Mars
- AstroLift harvester supply chain sets Titan/Venus gas prices on Luna

---

## ACTIVE TASKS

### In Progress
- `PHASE_2_REGIONAL_VIEW_IMPLEMENTATION.md` — current branch focus
- `blueprint_player_association_fix.md` — completed today, move to done

### Needs Verification (GPT-4.1 added status comments but didn't verify)
- `implement_maturity_based_snap_triggers.md`
- `implement_terrainforge_layer.md` — confirmed NOT complete, stays active
- `phase4b_task_breakdown.md`
- `planetary-view-phase1.md` — task says ✅ complete but no git evidence
- `test_ai_manager_mvp.md`

---

## BACKLOG TASKS CREATED TODAY
- `geosphere_initializer_procedural_architecture.md` — StarSim WIP context
- `priority_heuristic_spec_account_fix.md` — COMPLETED today
- `settlement_gcc_account_convenience_method.md` — add gcc_account helper
- `blueprint_polymorphic_ownership.md` — orgs/settlements owning blueprints
- `megaproject_service_manufacturing_pipeline.md` — MegaProjectService needed
- `dc_bond_financing_system.md` — bond financing design
- `population_morale_wellbeing_system.md` — greenhouse wellbeing, morale
- `logistics_provider_capabilities_serialization_fix.md` — from yesterday

---

## ARCHITECTURE DOCS WRITTEN/UPDATED TODAY

### New
- `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md`
  — DC economics, LDC as mint, player-first principle, harvester supply
  chain, logistics network, Earth revenue streams, bootstrap sequence

### Updated
- `docs/architecture/ai_manager/AI_PRIORITY_SYSTEM.md` — full rewrite,
  planet-aware oxygen strategy, financial health, storage capacity,
  methane synthesis, all priority tiers documented
- `docs/architecture/ai_manager/PLAYER_EMERGENCY_MISSION.md` — full
  rewrite, acquisition order, GCC gate, compounding failure state
- `docs/architecture/ai_manager/ai_manager_expansion_and_wormhole_network.md`
  — DC expansion financial model, system completion on wormhole opening,
  cross-references added
- `docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md` — LDC as mint section,
  construction cost evaluation, AI Manager cross-reference added

### Data Files
- `data/json-data/operational_data/units/life_support/inflatable_greenhouse_data.json`
  — updated to v1.3 (human_accessible, wellbeing_output, operational_modes,
  diagnostics, CO2 as free input on Mars)
- `data/json-data/templates/unit_operational_data_v1_3.json` — new template

---

## KEY ARCHITECTURE DECISIONS MADE TODAY

### Player-First Economics
- Player contracts always posted before DC robots produce
- DC robots are the safety net, not the default
- GCC gate: `account_negative?` → robots produce, no player contract posted
- DC maintains standing buy orders as natural player on-ramp (buyer of last resort)

### LDC as the Mint
- LDC is sole GCC issuer, backed by Luna's productive capacity
- Virtual ledger = monetary base, wound down as real revenue develops
- Payment preference: real GCC → real USD → virtual ledger

### LDC Earth Revenue Streams
- He-3 mining (player mission opportunity)
- Lunar samples and scientific data
- Refueling services for returning Earth craft
- Research grants and sponsorships

### Harvester Supply Chain
- AstroLift owns Titan/Venus skimmers, launched from Earth
- Sells gases to LDC at Luna, LDC refuels skimmers
- Symbiotic — neither can succeed without the other
- Virtual ledger backs both in early game, GCC=USD peg removes currency risk

### Regional Resource Abundance
- Resources abundant locally = near-zero extraction cost
- Mars CO2: free (95.3% atmosphere)
- Titan N2/CH4: free (abundant)
- Luna N2: none — permanent import
- Price on body = MIN(local extraction, cheapest supply node + transport)

### Logistics Network
- Every settled body is a network node
- Price differentials = player arbitrage opportunities
- AI Manager monitors surpluses/deficits, posts logistics contracts
- Players fill contracts; NPC logistics (AstroLift, Vector, Zenith) as fallback

### Greenhouse Wellbeing
- Inflatable greenhouse: human-accessible, habitat pressure, wellbeing output
- Based on Antarctic EDEN ISS research — biophilia effect is real and measurable
- `wellbeing_output` block in v1.3 template feeds future morale system
- Robot-only industrial greenhouses for scale, human-accessible for wellbeing

### Unit Operational Data v1.3
- New optional blocks: `operational_status`, `operational_modes`,
  `habitat_systems` (human_accessible), `wellbeing_output`, `diagnostics`,
  `telemetry`
- v1.2 files remain valid — migration is gradual, not forced

### Settlement Account Pattern (systemic fix)
- `settlement.account` is ambiguous and fragile in multi-currency system
- Always use `Financial::Account.find_or_create_for_entity_and_currency`
  with GCC currency
- Backlog task exists for `gcc_account` convenience method on BaseSettlement
- This pattern was the root cause of assembly_service, priority_heuristic
  spec failures

### base_unit.rb Restoration
- File was corrupted by multiple failed GPT-4.1 patch attempts
- Restored from commit `66ac54f2`
- `can_store_material?` added as public method (called by inventory.rb externally)
- `operational?` reads from `operational_data['status']` and `power.connected`
- Do not patch this file without Claude diagnosis first

---

## NEXT SESSION PRIORITIES
1. Queue overnight full run — get new baseline
2. Review overnight results — confirm pollution-dependent failures resolved
3. Reconcile EAP critical tasks with today's architecture before assigning
4. Verify 5 unverified active tasks against git history
5. Continue spec stabilization toward 150 failure target
6. Consider passing `settlement_gcc_account_convenience_method.md` to
   GPT-4.1 — small, well-defined, addresses systemic account pattern issue

## TARGET
185 → ~150 failures (overnight run should show significant improvement)
