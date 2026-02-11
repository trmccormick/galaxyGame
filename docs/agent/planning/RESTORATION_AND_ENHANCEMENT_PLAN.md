# Galaxy Game: Restoration and Enhancement Plan
**Date:** January 16, 2026  
**Status:** Active Development  
**Context:** Post-code-loss recovery with architectural improvements

---

## Executive Summary

This document provides a comprehensive plan for:
1. **Surgical restoration** of broken functionality (401 RSpec failures)
2. **Architectural violation remediation** (43+ location hardcodings, material naming issues)
3. **UI enhancement** (SimEarth-style admin tools + Eve Online mission system)
4. **AI Manager pattern learning** (autonomous foothold deployment)

**Philosophy:** Targeted fixes preserving post-Jan-8 improvements, not wholesale file reverts.

---

## Nightly Grinder Protocol (Autonomous Overnight Restoration)

**Goal:** Maximize restoration progress during unattended hours using fail-fast autonomous workflow

### Protocol Workflow

**Time-Optimized Cycle (15-30 min per spec):**

1. **Identify Target** (2 min)
   - Parse latest rspec log: `data/logs/rspec_full_*.log`
   - Extract highest-failure spec file
   - Skip if already in progress/completed log

2. **Quick Comparison** (3 min)
   - Diff current vs Jan 8 backup
   - Categorize: RESTORE, OBSOLETE, or COMPLEX

3. **Autonomous Decision** (NO USER PROMPT)
   - **RESTORE:** Backup → Restore → Test → Commit
   - **OBSOLETE:** Remove → Test → Commit
   - **COMPLEX:** Document issue → Skip → Log for human review

4. **Verify & Commit** (5 min)
   - Run individual spec only
   - If 100% green → Atomic commit
   - If failures → Revert backup → Log failure → Next spec

5. **Next Iteration** (5 min)
   - Update progress log
   - Identify next highest-failure spec
   - Repeat cycle (max 8 cycles per 4-hour window)

### Fail-Fast Rules

**AUTONOMOUS (No Permission Required):**
- ✅ Restore file from Jan 8 if diff shows only deletions/simple changes
- ✅ Remove spec file if not in Jan 8 backup (obsolete)
- ✅ Add missing associations/attributes if Jan 8 has them
- ✅ Commit immediately after green tests
- ✅ Skip to next spec after 3 failed restoration attempts

**SKIP & LOG (Human Review Required):**
- ⚠️ Diff shows complex logic changes (>50 lines modified)
- ⚠️ Multiple files interdependent (cascade risk)
- ⚠️ New feature post-Jan-8 conflicts with backup
- ⚠️ Spec passes but integration test fails
- ⚠️ Schema migration required

### Grok Nightly Command

```bash
"Grok, execute AUTONOMOUS NIGHTLY GRINDER PROTOCOL.

CRITICAL RULES:
- NO permission prompts - make autonomous decisions
- FAIL FAST - skip complex issues, log for human review
- Time limit:  (MANUAL - Complex Issue, Not for Nightly Grinder):**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Fix AIManager::MissionPlannerService location hardcoding violations using surgical approach.

CRITICAL: This is a COMPLEX MANUAL FIX - requires surgical approach, not full restoration.
ighest-failure spec file

2. Autonomous Decision Tree:
   
   IF spec not in Jan 8 backup:
     → REMOVE spec file
     → Log: 'Removed obsolete spec: [filename]'
     → Commit: 'chore: remove obsolete spec [name] - not in Jan 8 backup'
   
   ELSIF diff shows only deletions (file restored completely):
     → BACKUP current to tmp/pre_revert_backup/
     → RESTORE from Jan 8
     → RUN spec individually
     → IF green: COMMIT 'fix: restore [name] from Jan 8 backup'
     → IF red: REVERT, LOG 'Failed restoration: [name] - needs human review'
   
   ELSIF diff shows missing associations/attributes:
     → BACKUP current
     → ADD missing code from Jan 8
     → RUN spec individually
     → IF green: COMMIT 'fix: restore missing [feature] to [model]'
     → IF red: REVERT, LOG 'Failed partial restore: [name]'
   
   ELSIF diff shows complex changes (>50 lines):
     → SKIP
     → LOG 'Complex diff detected: [filename] - requires human surgical fix'
     → NEXT spec
   
   ELSE:
     → SKIP
     → LOG 'Unknown scenario: [filename] - requires human review'

3. Iteration Loop:
   REPEAT steps 1-2 until:
   - 4 hours elapsed OR
   - 12 specs processed OR
   - No more failing specs OR
   - 3 consecutive SKIPs (complex issues)

4. Final Report:
   Generate summary:
   - Specs restored: X
   - Specs removed: Y  
   - Specs skipped: Z
   - Current failure count: N
   - Next target: [spec_name]

VERIFICATION PER CYCLE:
- Individual spec MUST be 100% green before commit
- Never commit if spec still has failures
- Revert backup if restoration fails

REMINDER: All operations inside docker container. NO USER PROMPTS. AUTONOMOUS OPERATION ONLY."
```

### Balancing Full Runs vs Targeted Fixes

**Full Suite Strategy (Once per session):**
- Run at START of nightly grinder
- Generates fresh failure ranking
- Takes 15-20 minutes
- Provides ground truth for prioritization

**Targeted Fix Strategy (Repeated throughout night):**
- Run individual spec only (30 seconds - 2 minutes)
- Faster verification cycle
- Enables 8-12 fixes per 4-hour window

**Hybrid Approach:**
```
Hour 0:00 → Full suite run (establish baseline)
Hour 0:20 → Process top 3 specs (quick wins)
Hour 1:30 → Process next 3 specs
Hour 2:45 → Process next 3 specs  
Hour 3:30 → Final report, log complex issues
Hour 4:00 → Shutdown
```

**Morning Review:**
1. Check nightly grinder summary log
2. Review skipped/complex issues
3. Run full suite to verify progress
4. Continue manual fixes on complex issues

---

## Phase 1: Critical Restoration (Priority 1)
**Goal:** Stabilize core systems to enable development  
**Target:** Reduce failures from 401 → ~200 within 2-3 nights (nightly grinder) + 2 days (manual complex fixes)

### 1.1 AI Manager Services (36 failures - 9% of total)

**Root Cause:** Hardcoded location checks violate data-driven architecture

**Files to Fix:**
- `galaxy_game/app/services/ai_manager/mission_planner_service.rb` (11 failures)
- `galaxy_game/app/services/ai_manager/decision_tree.rb` (2 failures)
- `galaxy_game/app/services/ai_manager/economic_forecaster_service.rb` (9 failures - cascading)

**Surgical Fix Strategy:**

<details>
<summary>MissionPlannerService - Lines 328-339 Restoration</summary>

**Current (BROKEN):**
```ruby
case location.identifier
when 'mars'
  local_resources = ['regolith', 'water_ice', 'co2']
when 'luna'
  local_resources = ['regolith', 'he3', 'oxygen']
when 'titan'
  local_resources = ['methane', 'nitrogen', 'water_ice']
```

**Fix (DATA-DRIVEN):**
```ruby
# Query actual celestial body composition
local_resources = []

# Geosphere materials (regolith composition)
if location.celestial_body.geosphere
  crust = location.celestial_body.geosphere.crust_composition || {}
  local_resources += crust.keys.map { |mat| MaterialLookupService.normalize_to_formula(mat) }
end

# Atmospheric gases
if location.celestial_body.atmosphere
  gases = location.celestial_body.atmosphere.gases.pluck(:chemical_formula)
  local_resources += gases
end

# Hydrosphere liquids
if location.celestial_body.hydrosphere
  liquids = location.celestial_body.hydrosphere.composition.keys rescue []
  local_resources += liquids.map { |mat| MaterialLookupService.normalize_to_formula(mat) }
end

local_resources.uniq!
```
</details>

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Fix AIManager::MissionPlannerService location hardcoding violations using surgical approach.

CRITICAL: Compare lines 328-450 with Jan 8 backup, but ONLY restore broken logic. Preserve all post-Jan-8 EconomicConfig integrations.

Task 1: Replace Hardcoded Location Checks (Lines 328-339)

- BACKUP current file to tmp/pre_revert_backup/mission_planner_service.rb
- REPLACE hardcoded case/when with data-driven queries:
  * Query geosphere.crust_composition for geological materials
  * Query atmosphere.gases for atmospheric resources
  * Query hydrosphere.composition for liquid materials
- Use chemical formulas (H2O not 'water', O2 not 'oxygen')
- Call MaterialLookupService.normalize_to_formula for consistency

Task 2: Fix can_produce_locally? Method Duplication

- Compare with NpcPriceCalculator#can_produce_locally? (different implementation)
- Consolidate to single service method or document intentional differences
- Use settlement.has_facility? checks, not location-specific hardcodes

Task 3: Verify All MissionPlanner Dependencies

- Test that EconomicForecasterService specs pass after MissionPlanner fix
- Verify OperationalManager specs resolve (cascading dependency)
- Check SystemArchitect specs for regressions

VERIFICATION:
- Run: bundle exec rspec spec/services/ai_manager/mission_planner_service_spec.rb
- Expect: 11/11 passing before committing
- Run: bundle exec rspec spec/services/ai_manager/economic_forecaster_service_spec.rb  
- Expect: 9/9 passing (cascade resolution)

COMMIT: Only if ALL 20 AI Manager specs passing
git add galaxy_game/app/services/ai_manager/mission_planner_service.rb
git commit -m 'fix: remove location hardcoding from MissionPlannerService - data-driven composition queries'

REMINDER: All operations inside docker container. Surgical fixes only - preserve post-Jan-8 improvements."
```

### 1.2 Material System Violations (52 failures - 13%)

**Root Cause:** Regolith universality assumptions, missing chemical formula enforcement

**Files to Fix:**
- `galaxy_game/app/models/item.rb` - regolith_handling method
- `galaxy_game/app/models/concerns/geosphere_concern.rb` - extract_volatiles, add_material
- `galaxy_game/app/services/terra_sim/geosphere_initializer.rb` - regolith properties

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Fix regolith handling to respect procedural composition system (regolith.json is_dynamic: true).

CRITICAL: Luna regolith ≠ Mars regolith ≠ Titan regolith. Each has unique geosphere.crust_composition.

Task 1: Fix Item#regolith_handling Method

- BACKUP: tmp/pre_revert_backup/item.rb
- UPDATE method to query source_body metadata
- Get composition from: source_body.geosphere.crust_composition
- Fail gracefully if source_body missing (generic fallback)
- Document requirement: regolith items MUST include source_body metadata

Task 2: Fix GeosphereConcern#extract_volatiles Chemical Formulas

- BACKUP: tmp/pre_revert_backup/geosphere_concern.rb
- Verify adds gases using chemical formulas (CO2, H2O, CH4) not common names
- Check MaterialLookupService.normalize_to_formula usage
- Ensure add_gas receives chemical_formula parameter

Task 3: Review GeosphereInitializer Regolith Assumptions

- BACKUP: tmp/pre_revert_backup/geosphere_initializer.rb (services path)
- Check for hardcoded regolith property initialization
- Ensure uses geosphere.crust_composition data, not assumptions
- Verify airless body vs atmospheric body handling doesn't hardcode materials

VERIFICATION:
- Run: bundle exec rspec spec/models/item_spec.rb -e 'regolith handling'
- Run: bundle exec rspec spec/models/concerns/geosphere_concern_spec.rb
- Run: bundle exec rspec spec/services/terra_sim/geosphere_initializer_spec.rb
- Expect: All regolith-related specs passing

COMMIT: Atomic per file
git add galaxy_game/app/models/item.rb
git commit -m 'fix: Item regolith handling respects procedural composition - queries source_body geosphere'

REMINDER: All operations inside docker container. Test each file individually before moving to next."
```

---

## Phase 2: Service Layer Stabilization (Priority 2)
**Goal:** Fix manufacturing, cost calculation, and integration tests  
**Target:** Reduce failures from ~200 → ~100

### 2.1 Manufacturing & Cost Calculator (20 failures)

**Root Cause:** EconomicConfig integration disruption, pricing calculation changes

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Restore Manufacturing cost calculation services while preserving EconomicConfig integration.

Task 1: Analyze Manufacturing::CostCalculator Diff

- Compare current vs Jan 8: galaxy_game/app/services/manufacturing/cost_calculator.rb
- Identify changes to:
  * EAP-COGS (Earth Anchor Price - Cost of Goods Sold)
  * LAP-COGS (Local Anchor Price - Cost of Goods Sold)
- Determine if EconomicConfig.local_production_cost integration was broken
- Check Tier1PriceModeler dependency

Task 2: Surgical Restoration of Broken Calculations

- BACKUP: tmp/pre_revert_backup/cost_calculator.rb
- Restore EAP calculation: (Earth_Spot × Refining_Factor) × USD_Peg + Transport
- Restore LAP calculation: Uses EconomicConfig.local_production_cost (by maturity)
- Verify TransportCostService integration (route-aware, cargo categories)
- Preserve any post-Jan-8 performance optimizations

Task 3: Fix ManufacturingService Material Fulfillment

- Compare: galaxy_game/app/services/manfacturing_service.rb (note typo in filename)
- Check material_requests association handling
- Verify blueprint data storage in specifications
- Ensure construction cost percentage from settlement config

VERIFICATION:
- Run: bundle exec rspec spec/services/manufacturing/cost_calculator_spec.rb
- Run: bundle exec rspec spec/services/manfacturing_service_spec.rb
- Run: bundle exec rspec spec/services/manufacturing/assembly_service_spec.rb
- Expect: 20/20 manufacturing specs passing

COMMIT:
git add galaxy_game/app/services/manufacturing/cost_calculator.rb galaxy_game/app/services/manfacturing_service.rb
git commit -m 'fix: restore EAP/LAP calculations and material fulfillment - EconomicConfig integration'

REMINDER: All operations inside docker container. Verify EconomicConfig methods exist before using."
```

### 2.2 Energy Management (5 failures)

**Root Cause:** Potential location-specific solar calculations introduced

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Verify EnergyManagement concern has no location hardcoding, fix solar factor queries.

Task 1: Review EnergyManagement Solar Methods

- Check current_solar_output_factor - should query location.solar_output_factor
- Verify no Mars/Luna-specific multipliers hardcoded
- Ensure solar_daylight? uses threshold (> 0.1) not location checks

Task 2: Compare with Jan 8 Backup

- diff galaxy_game/app/models/concerns/energy_management.rb
- Identify any new location-based conditionals
- Check if solar scaling logic was simplified incorrectly

Task 3: Fix if Violations Found

- BACKUP: tmp/pre_revert_backup/energy_management.rb
- Restore data-driven solar factor queries
- Remove any case/when location.identifier checks

VERIFICATION:
- Run: bundle exec rspec spec/models/concerns/energy_management_spec.rb
- Expect: 5/5 passing

COMMIT (if changes needed):
git add galaxy_game/app/models/concerns/energy_management.rb
git commit -m 'fix: ensure EnergyManagement uses data-driven solar factors - no location hardcoding'

REMINDER: All operations inside docker container."
```

---

## Phase 3: Integration & Model Validations (Priority 3)
**Goal:** Fix cascading integration test failures and model validations  
**Target:** Reduce failures from ~100 → ~30
**Current Status:** 408 failures remaining (as of January 19, 2026)
**Progress:** Phase 3 active - systematic model-by-model validation fixes needed

### 3.1 Integration Tests (8 failures)

**Strategy:** Fix AFTER dependencies (AI Manager, Manufacturing) stabilized

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Resolve integration test failures ONLY after Phase 1 & 2 complete.

PRE-REQUISITES:
- AIManager::MissionPlanner specs passing ✓
- Manufacturing::CostCalculator specs passing ✓
- Material system specs passing ✓

Task 1: Component Production Game Loop (3 failures)

- Run: bundle exec rspec spec/integration/component_production_game_loop_spec.rb
- Check if failures resolved by upstream fixes (manufacturing jobs)
- If still failing, review Game#process_manufacturing_jobs (Jan 13 fix documented)
- Verify ComponentProductionJob.active.each processes all jobs

Task 2: Terraforming Integration (5 failures)

- Run: bundle exec rspec spec/integration/terraforming_integration_spec.rb
- Run: bundle exec rspec spec/integration/terraforming_workflow_spec.rb
- Check if BiosphereSimulationService fixes (Jan 12) still present
- Verify ecosystem deployment, CO2 reduction, progressive changes
- Review material formula usage in gas exchange

VERIFICATION:
- All 8 integration specs passing before commit
- No new regressions in dependent services

COMMIT:
git add spec/integration/component_production_game_loop_spec.rb (if test changes)
git commit -m 'test: update integration specs for fixed upstream services'

REMINDER: All operations inside docker container. Integration tests are canaries - fix dependencies first."
```

### 3.2 Model Validations (60+ failures)

**Strategy:** Likely test setup issues, not architectural violations

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Systematic validation failure resolution using factory and database state analysis.

Task 1: Identify Failure Categories

- Run full model spec suite: bundle exec rspec spec/models --format documentation > log/model_failures.log 2>&1
- Group failures by error type:
  * FactoryNotRegistered errors → factory definition issues
  * ValidationFailed errors → test data issues  
  * NoMethodError → missing methods (check Jan 8 backup)
  * ActiveRecord errors → schema/migration issues

Task 2: Fix Factory Issues First

- Check spec/factories/ for missing factory definitions
- Compare with Jan 8: data/old-code/galaxyGame-01-08-2026/galaxy_game/spec/factories/
- Restore missing factories (e.g., celestial_bodies_hydrosphere was renamed)
- Update factory references in specs to match current model namespaces

Task 3: Database State Cleanup

- Run: RAILS_ENV=test bundle exec rake db:reset
- Run: RAILS_ENV=test bundle exec rake db:seed
- Verify test database schema matches development

Task 4: Systematic Model-by-Model Fix

- Start with Account, Biology, Environment (high failure count)
- One model at a time: compare spec with Jan 8, identify missing validations/methods
- BACKUP and restore surgically

VERIFICATION:
- Run each model spec individually after fix
- Track progress: aim for 10 model specs fixed per session

COMMIT: Per model or small group
git add spec/models/account_spec.rb galaxy_game/app/models/account.rb
git commit -m 'fix: restore Account model validations and balance methods'

REMINDER: All operations inside docker container. Don't batch commit - atomic fixes only."
```

---

## Phase 4: UI Enhancement - SimEarth Admin Panel (Priority 4)
**Goal:** Build admin tools for system projection and mission creation  
**Timeline:** After Phase 1-3 complete (test suite <50 failures)

### 4.1 Admin Dashboard Architecture

**Vision:** Blend of SimEarth (planetary simulation controls) + Eve Online (mission generation)

**Current State:**
- `galaxy_game/app/views/admin/dashboard/index.html.erb` exists
- `galaxy_game/app/views/admin/ai_manager/` has planner, missions views
- Mission profile templates in `data/json-data/missions/`

**Enhancement Plan:**

<details>
<summary>Admin Panel Feature Matrix</summary>

| Feature | SimEarth Analog | Eve Online Analog | Implementation |
|---------|----------------|-------------------|----------------|
| **System Projector** | Planet simulation controls | - | AI Manager simulation runner |
| **Mission Builder** | - | Mission agent UI | JSON profile generator |
| **Resource Flows** | Trade/migration graphs | Market analysis | Flow visualization |
| **Pattern Library** | - | Blueprint library | AI learned patterns |
| **Settlement Monitor** | City stats | Structure browser | Real-time settlement view |
| **Terraforming Console** | Atmospheric controls | - | TerraSim parameter tweaks |

</details>

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Enhance admin dashboard with SimEarth-style system projection capabilities.

PRE-REQUISITES:
- RSpec test suite below 50 failures ✓
- AIManager services stable ✓
- Rails server starts without errors ✓

Task 1: System Projector UI Component

CREATE: galaxy_game/app/views/admin/simulation/projector.html.erb

Features:
- Solar system selector dropdown (from SolarSystem.all)
- Pattern selector (mars-terraform, venus-industrial, titan-fuel, etc.)
- Timeline controls (10/25/50/100 year projections)
- Resource visualization (D3.js charts showing GCC flow, material consumption)
- Run Simulation button → calls AIManager::MissionPlannerService.simulate

Controller: galaxy_game/app/controllers/admin/simulation_controller.rb
Actions: index, project, compare_scenarios

Task 2: Mission Profile Builder UI

CREATE: galaxy_game/app/views/admin/missions/builder.html.erb

Features:
- Template selector (from missions/ directory structure)
- Phase editor (add/remove/reorder mission phases)
- Resource manifest editor (materials, equipment, crew requirements)
- Profile metadata (difficulty, duration, GCC budget)
- Export as JSON → saves to missions/custom/
- Validation against existing schema

Controller: galaxy_game/app/controllers/admin/missions_controller.rb
Actions: new, create, edit, update, validate_profile

Task 3: Pattern Learning Dashboard

ENHANCE: galaxy_game/app/views/admin/ai_manager/planner.html.erb

Add sections:
- Completed Missions table (show successful foothold deployments)
- Pattern Extraction button (analyze mission → save as reusable pattern)
- Pattern Library (show learned patterns with success metrics)
- Apply Pattern form (select pattern + target system → generate new mission)

Service Integration: AIManager::PatternLearningService (to be created Phase 5)

VERIFICATION:
- Start server: bundle exec rails s -b 0.0.0.0
- Navigate to: http://localhost:3000/admin/simulation/projector
- Test simulation run with mars-terraform pattern
- Verify JSON response structure matches economic_forecaster output
- Test mission builder saves valid JSON to missions/custom/

COMMIT:
git add galaxy_game/app/views/admin/simulation/ galaxy_game/app/controllers/admin/simulation_controller.rb
git commit -m 'feat: add SimEarth-style system projector to admin dashboard'

git add galaxy_game/app/views/admin/missions/ galaxy_game/app/controllers/admin/missions_controller.rb  
git commit -m 'feat: add mission profile builder UI for custom mission creation'

REMINDER: All operations inside docker container. UI changes require server restart to test."
```

### 4.2 D3.js Resource Flow Visualization

**Goal:** Visual representation of GCC flow, material movement, trade routes

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Implement D3.js-based resource flow visualization for admin panel.

Task 1: Resource Flow API Endpoint

CREATE: galaxy_game/app/controllers/admin/resources_controller.rb

Endpoint: GET /admin/resources/flows/:solar_system_id
Returns JSON:
{
  nodes: [
    {id: 'earth', name: 'Earth', type: 'source'},
    {id: 'mars_colony', name: 'Mars Colony', type: 'settlement'},
    {id: 'venus_station', name: 'Venus L1', type: 'station'}
  ],
  links: [
    {source: 'earth', target: 'mars_colony', value: 15000, resource: 'H2O', gcc: 1200000},
    {source: 'venus_station', target: 'mars_colony', value: 8000, resource: 'structural_carbon', gcc: 450000}
  ]
}

Data Source: 
- Query SupplyChain model for trade records
- Aggregate by route and resource type
- Calculate GCC values using current pricing

Task 2: D3.js Flow Diagram Component

CREATE: galaxy_game/app/javascript/admin/resource_flow.js

Visualization Type: Sankey diagram or Force-directed graph
Features:
- Nodes sized by total throughput (kg/month)
- Links colored by resource type
- Hover tooltip shows GCC value, resource name, volume
- Time slider (filter by date range)
- Export as PNG button

Include in: galaxy_game/app/views/admin/resources/flows.html.erb

Task 3: Real-time Updates (Optional)

- WebSocket connection for live trade updates
- ActionCable channel: ResourceFlowChannel
- Update graph nodes when new trades execute

VERIFICATION:
- Navigate to: http://localhost:3000/admin/resources/flows
- Select Sol system
- Verify graph shows Earth → Mars → Venus flow
- Test time slider filters data correctly

COMMIT:
git add galaxy_game/app/controllers/admin/resources_controller.rb galaxy_game/app/javascript/admin/resource_flow.js
git commit -m 'feat: add D3.js resource flow visualization to admin panel'

REMINDER: All operations inside docker container. JavaScript changes may need asset recompilation."

### 4.2 SimEarth Digital Twin Sandbox **[2026-01-15] Documentation Mandate**

**Goal:** Implement Digital Twin simulation capabilities for accelerated deployment pattern testing

**Codified Intent:** The Admin Dashboard shall support a 'Digital Twin' mode where a target celestial body's data (Atmosphere, Hydrosphere, Geosphere) is cloned into a transient state. This allows for accelerated (100-year projection) 'What-If' simulations of deployment patterns (e.g., Mars-Terraforming) without impacting live game data.

**Requirement:** Successful simulation runs must be exportable as a versioned manifest_v1.1.json which can be passed to the AIManager::TaskExecutionEngine for live execution.

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Implement SimEarth Digital Twin Sandbox for accelerated deployment pattern simulation.

Task 1: Digital Twin Data Cloning Service

CREATE: galaxy_game/app/services/digital_twin_service.rb

Features:
- clone_celestial_body(celestial_body_id) → creates transient copy in Redis/memory
- simulate_deployment_pattern(pattern_name, duration_years, parameters) → runs accelerated simulation
- export_simulation_manifest → generates manifest_v1.1.json with optimized parameters
- cleanup_twin(twin_id) → removes transient data

Integration: 
- Atmosphere, Hydrosphere, Geosphere data cloning
- TerraSim integration for accelerated time projection
- Pattern parameter optimization (budget, tech level, priority)

Task 2: Admin Digital Twin UI Component

CREATE: galaxy_game/app/views/admin/simulation/digital_twin.html.erb

Features:
- Celestial body selector (dropdown from CelestialBody.all)
- Pattern selector (mars-terraform, venus-industrial, etc.)
- Simulation parameters (duration, budget multiplier, tech assumptions)
- Real-time progress visualization
- Export Manifest button → downloads manifest_v1.1.json
- Apply to Live button → passes manifest to AIManager::TaskExecutionEngine

Controller: galaxy_game/app/controllers/admin/simulation_controller.rb (extend)
Actions: create_twin, run_simulation, export_manifest, apply_to_live

Task 3: Simulation Hook Integration

ENHANCE: galaxy_game/app/services/ai_manager/mission_planner_service.rb
ENHANCE: galaxy_game/app/services/terra_sim/simulator.rb

Add source: :simulation parameter support:
- MissionPlannerService.simulate(source: :simulation) → uses digital twin data
- TerraSim::Simulator.run(source: :simulation) → accelerated time projection
- Pattern optimization hooks for AI learning

VERIFICATION:
- Start server: bundle exec rails s -b 0.0.0.0
- Navigate to: http://localhost:3000/admin/simulation/digital_twin
- Create twin of Mars, run 100-year terraform simulation
- Export manifest, verify JSON structure matches v1.1 schema
- Test 'Apply to Live' passes manifest to AI Manager

COMMIT:
git add galaxy_game/app/services/digital_twin_service.rb
git add galaxy_game/app/views/admin/simulation/digital_twin.html.erb
git add galaxy_game/app/controllers/admin/simulation_controller.rb
git commit -m 'feat: implement SimEarth Digital Twin Sandbox for accelerated deployment simulation'

REMINDER: Digital Twin operations use transient storage. Ensure cleanup on session end."
```

---

## Phase 5: AI Manager Pattern Learning System (Priority 5)
**Goal:** Enable AI to learn from successful missions and deploy to new systems autonomously  
**Timeline:** After UI complete, test suite stable

### 5.1 Pattern Extraction Architecture

**Concept:** AI Manager analyzes completed missions → extracts reusable patterns → applies to new systems

**Pattern Structure:**
```json
{
  "pattern_id": "mars-terraform-learned-2026-01-15",
  "source_mission": "mars-settlement-2024",
  "success_metrics": {
    "gcc_efficiency": 0.87,
    "timeline_accuracy": 0.92,
    "resource_waste": 0.05
  },
  "required_conditions": {
    "celestial_body_type": "terrestrial_planet",
    "atmosphere_present": true,
    "surface_water_ice": true,
    "solar_flux_range": [0.4, 1.6]
  },
  "deployment_sequence": [
    {"phase": "orbital_survey", "duration_days": 30, "equipment": [...]},
    {"phase": "foothold_establishment", "duration_days": 90, "equipment": [...]}
  ],
  "learned_optimizations": [
    "prioritize_isru_early_reduces_gcc_by_15_percent",
    "habitat_staging_reduces_construction_time_by_20_days"
  ]
}
```

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Implement AI Manager pattern learning and autonomous deployment system.

PRE-REQUISITES:
- RSpec suite stable (<30 failures) ✓
- Admin UI complete ✓
- AIManager::MissionPlanner refactored (data-driven) ✓

Task 1: Create Pattern Learning Service

CREATE: galaxy_game/app/services/ai_manager/pattern_learning_service.rb

Methods:
- extract_pattern_from_mission(mission_id) → analyzes completed mission
  * Calculate success metrics (GCC efficiency, timeline accuracy)
  * Identify celestial body conditions (atmosphere, resources, gravity)
  * Extract deployment sequence (phases, equipment, timeline)
  * Detect optimizations (ISRU timing, staging strategies)
  * Save as JSON to data/json-data/missions/learned_patterns/

- analyze_pattern_applicability(pattern_id, target_system_id) → compatibility check
  * Compare target celestial bodies with pattern required_conditions
  * Score match quality (0.0 - 1.0)
  * Identify required adaptations (e.g., different atmosphere composition)

- apply_pattern_to_system(pattern_id, target_system_id) → generate new mission
  * Load learned pattern JSON
  * Query target system celestial bodies
  * Adapt deployment sequence for local resources
  * Generate mission profile JSON
  * Save to missions/generated/

Task 2: Pattern Storage Model

CREATE: galaxy_game/app/models/ai_manager/learned_pattern.rb

Attributes:
- pattern_id (string, unique)
- source_mission_id (references missions)
- success_score (decimal, 0.0-1.0)
- required_conditions (jsonb)
- deployment_sequence (jsonb)
- optimizations (jsonb)
- times_applied (integer, default 0)
- success_rate (decimal, tracks pattern effectiveness)

Validations:
- Unique pattern_id
- success_score between 0 and 1
- required_conditions must include celestial_body_type

Task 3: Autonomous Deployment Decision Tree

ENHANCE: galaxy_game/app/services/ai_manager/operational_manager.rb

Add method: evaluate_expansion_opportunity(wormhole_system_id)

Logic:
1. Query learned patterns sorted by success_rate DESC
2. For each pattern, call analyze_pattern_applicability(pattern, wormhole_system)
3. If match quality > 0.75:
   - Generate mission using apply_pattern_to_system
   - Create AIManager::Mission record
   - Log decision: "Deploying mars-terraform pattern to Alpha Centauri B (match: 0.89)"
4. If no good match:
   - Fall back to procedural mission generation (current behavior)
   - Log: "No learned pattern applicable, generating custom mission"

Task 4: Pattern Learning Specs

CREATE: galaxy_game/spec/services/ai_manager/pattern_learning_service_spec.rb

Test scenarios:
- Extracts pattern from completed Mars mission
- Identifies applicable patterns for Venus-like exoplanet
- Adapts pattern for different atmospheric composition
- Generates valid mission JSON from learned pattern
- Tracks pattern success rate over multiple deployments

VERIFICATION:
- Run: bundle exec rspec spec/services/ai_manager/pattern_learning_service_spec.rb
- Run: bundle exec rspec spec/models/ai_manager/learned_pattern_spec.rb
- Test admin UI: Extract pattern from completed mission
- Test admin UI: Apply learned pattern to Alpha Centauri system
- Verify generated mission JSON validates against schema

COMMIT:
git add galaxy_game/app/services/ai_manager/pattern_learning_service.rb galaxy_game/app/models/ai_manager/learned_pattern.rb
git commit -m 'feat: AI Manager pattern learning from completed missions'

git add galaxy_game/app/services/ai_manager/operational_manager.rb
git commit -m 'feat: autonomous pattern deployment to new wormhole systems'

REMINDER: All operations inside docker container. This enables Eve Online-style emergent gameplay."
```

### 5.2 Wormhole Scouting Integration

**Goal:** Tie pattern learning to wormhole expansion (documented in grok_notes Jan 15)

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Integrate pattern learning with wormhole scouting workflow.

Context: Per Jan 15 grok_notes, wormhole scouting should generate complete systems on-demand, then AI evaluates patterns.

Task 1: Enhance WormholeScoutingService

UPDATE: galaxy_game/app/services/wormhole/wormhole_scouting_service.rb

Replace line 62 (just loads seed data) with:
- Call StarSim::ProceduralGenerator.generate_complete_system_from_seed(seed_data)
  * Preserve all seed bodies (real exoplanet data)
  * Fill in missing system elements (gas giants, ice giants, asteroids)
  * Generate 3-10 asteroids per system
  * Add dwarf planets for outer systems

- After system generated, call AIManager::PatternLearningService.evaluate_system_prizes(system_id)
  * Returns: {terraformable_worlds: 2, rare_resources: ['he3', 'exotic_ices'], strategic_value: 0.82}

- Decision tree:
  IF strategic_value > 0.7 AND learned_pattern_applicable?
    → Build permanent station, deploy learned pattern
  ELSIF strategic_value > 0.5
    → Build basic outpost, generate custom mission
  ELSE
    → Close temporary wormhole, log as "low value system"

Task 2: Enhance ProceduralGenerator

UPDATE: galaxy_game/app/services/star_sim/procedural_generator.rb

Add method: generate_complete_system_from_seed(seed_json)

Features:
- Preserve ALL seed bodies (don't replace real exoplanet data)
- Fill missing system elements:
  * If no gas giants and stellar_mass > 0.8 solar: add 1-2 gas giants
  * If no ice giants and distance > 10 AU: add 1 ice giant  
  * Add asteroid belt (3-10 asteroids) between rocky and gas planets
  * Add dwarf planets for outer systems (> 30 AU)
- Maintain orbital mechanics (no overlapping orbits)
- Generate complete geosphere/atmosphere/hydrosphere for all bodies

Task 3: Update Wormhole Scouting Specs

UPDATE: galaxy_game/spec/services/wormhole/wormhole_scouting_service_spec.rb

Test scenarios:
- Generates complete system from Alpha Centauri seed
- AI evaluates Proxima b as high-value terraforming target
- Deploys learned mars-terraform pattern when applicable
- Creates basic outpost for medium-value systems
- Closes wormhole for low-value systems (no prizes)

VERIFICATION:
- Run: bundle exec rspec spec/services/wormhole/wormhole_scouting_service_spec.rb
- Run: bundle exec rspec spec/services/star_sim/procedural_generator_spec.rb
- Test manually: Open wormhole to test system, verify complete generation
- Check logs for AI decision: "Alpha Centauri B matches mars-terraform pattern (0.89)"

COMMIT:
git add galaxy_game/app/services/wormhole/wormhole_scouting_service.rb
git commit -m 'feat: wormhole scouting generates complete systems and evaluates patterns'

git add galaxy_game/app/services/star_sim/procedural_generator.rb
git commit -m 'feat: ProceduralGenerator fills complete systems from seed data'

REMINDER: All operations inside docker container. This completes the autonomous expansion loop."
```

---

## Phase 6: Documentation & Guardrails (Priority 6)
**Goal:** Prevent future violations, codify architectural principles  
**Timeline:** Ongoing throughout Phases 1-5

### 6.1 Fix Existing Documentation Violations

**Files with Errors:**
- `docs/ai_manager/PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md` (Jan 15 - GPT-5 created, contains hardcoded resource lists)

**Grok Command:**

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Fix documentation violations that perpetuate location hardcoding anti-patterns.

Task 1: Review PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md

PROBLEM: Document contains hardcoded resource lists by location
Example: 'Luna: oxygen, water, regolith'

CORRECT APPROACH: Query-based references
Example: 'Luna: Query geosphere.crust_composition for available geological materials, atmosphere.gases for volatiles'

UPDATE document to:
- Remove all hardcoded material lists
- Add examples of data-driven queries
- Reference regolith.json procedural system
- Document chemical formula requirement (H2O not 'water')

Task 2: Create Material Naming Standards Document

CREATE: docs/developer/MATERIAL_NAMING_STANDARDS.md

Content:
- Chemical Formula Protocol: ALWAYS use H2O, O2, CO2, CH4, not common names
- Regolith Procedural System: Never assume universal regolith, always query source_body
- Liquid Material Support: Hydrosphere supports any liquid (CH4, H2O, C2H6, NH3)
- Atmosphere Gases: Always chemical formulas, stored in atmosphere.gases table
- Material Lookup: MaterialLookupService.normalize_to_formula(common_name) → formula

Examples:
✅ CORRECT: atmosphere.add_gas('O2', 1000, molar_mass: 32.0)
❌ WRONG: atmosphere.add_gas('oxygen', 1000)

Task 3: Enhance GROK_TASK_PLAYBOOK.md

ADD section: Data-Driven Validation Protocol

Pre-commit checklist:
□ No case/when location.identifier hardcoding
□ No 'water' string literals (use 'H2O')
□ No universal 'regolith' (query geosphere.crust_composition)
□ No Mars/Luna/Titan-specific constants in service logic
□ All material references use chemical formulas
□ Settlement production checks query actual facilities/modules

VERIFICATION:
- Review updated docs for accuracy
- Cross-reference with existing architecture docs (hydrosphere_system.md, regolith.json)

COMMIT:
git add docs/ai_manager/PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md
git commit -m 'docs: fix hardcoded resource lists - add data-driven query examples'

git add docs/developer/MATERIAL_NAMING_STANDARDS.md
git commit -m 'docs: create material naming standards - enforce chemical formula protocol'

git add docs/developer/GROK_TASK_PLAYBOOK.md
git commit -m 'docs: add data-driven validation protocol to prevent location hardcoding'

REMINDER: Documentation commits done on HOST machine, not docker container."
```

### 6.2 Code Review Checklist

**Add to `docs/developer/CODE_REVIEW_CHECKLIST.md`:**

```markdown
# Galaxy Game Code Review Checklist

## Architectural Compliance

### Data-Driven Systems
- [ ] No hardcoded location checks (`case location.identifier when 'mars'`)
- [ ] Celestial body data queried from geosphere/atmosphere/hydrosphere
- [ ] Material composition uses procedural systems (regolith.json, crust_composition)
- [ ] Economic config uses EconomicConfig service, not hardcoded constants

### Material Naming
- [ ] Chemical formulas used (H2O, O2, CO2, CH4) not common names
- [ ] MaterialLookupService.normalize_to_formula called when needed
- [ ] Regolith items include source_body metadata
- [ ] Hydrosphere methods use primary_liquid, not assume water

### Service Integration
- [ ] TransportCostService used for shipping calculations (no hardcoded rates)
- [ ] Tier1PriceModeler used for EAP (Earth Anchor Price)
- [ ] NpcPriceCalculator respects EAP ceiling, uses can_produce_locally?
- [ ] EconomicConfig provides all pricing/rates (single source of truth)

### Testing Requirements
- [ ] All modified specs passing individually
- [ ] No regressions in related specs
- [ ] Factories use correct namespaces (CelestialBodies::Spheres::Hydrosphere)
- [ ] Chemical formulas in test data (not 'water', 'oxygen')

### Commit Hygiene
- [ ] Atomic commits (only files worked on in session)
- [ ] Descriptive commit messages (feat/fix/docs prefix)
- [ ] Backup to tmp/pre_revert_backup/ before major changes
- [ ] Documentation updated if feature behavior changed
```

---

## Progress Tracking

### Daily Workflow
 (Human Review - 30 min):**
1. Pull latest from git
2. Review nightly grinder summary: `cat log/nightly_grinder_summary_*.txt`
3. Check progress: failures reduced from X → Y
4. Run full RSpec suite: `RAILS_ENV=test bundle exec rspec > ./data/logs/rspec_full_$(date +%s).log 2>&1`
5. Identify complex issues flagged by grinder
6. Review this plan, select manual fix commands for complex issues

**Daytime Development (Human-Attended - Variable):**
1. Work on complex issues flagged by nightly grinder
2. Execute manual surgical fix commands (AI Manager, complex services)
3. Verify individual spec passes + check regressions
4. Backup files before major changes
5. Atomic commit (only changed files)
6. Answer questions/tune agent as needed

**Evening Setup (5 min):**
1. Run full suite: generates fresh baseline for nightly grinder
2. Update grok_notes.md with day's progress
3. **Launch nightly grinder** (autonomous 4-hour cycle)
4. Log off - grinder runs unattended

**Nightly Grinder (Autonomous - 4 hou Strategy |
|-------|--------|------------------|----------|
| Phase 1 | 3-4 nights | Simple restorations <50 failures | Nightly grinder (auto) |
| Phase 1 | Week 1 | AI Manager + Materials <50 total | Manual surgical fixes |
| Phase 2 | Week 2 | Manufacturing + Energy <100 total | Mixed auto/manual |
| Phase 3 | Week 3 | Integration + Models <30 total | Mostly auto |
| Phase 4 | Week 4-5 | Admin UI functional, simulation runs | Manual development |
| Phase 5 | Week 6-7 | Pattern learning deployed | Manual development |
| Phase 6 | Ongoing | Documentation complete, no violations | Manual + review |

**Nightly Grinder Velocity:**
- Target: 8-12 specs per 4-hour night
- Expected: 40-60 simple specs per week (5 nights)
- Manual: 5-10 complex specs per week (daytime)
- **Total:** ~50-70 specs resolved per week

| Phase | Target | Success Criteria |
|-------|--------|------------------|
| Phase 1 | Week 1 | AI Manager + Materials <50 failures |
| Phase 2 | Week 2 | Manufacturing + Energy <100 total |
| Phase 3 | Week 3 | Integration + Models <30 total |
| Phase 4 | Week 4-5 | Admin UI functional, simulation runs |
| Phase 5 | Week 6-7 | Pattern learning deployed, autonomous expansion |
| Phase 6 | Ongoing | Documentation complete, no new violations |

### Current Status (Jan 16, 2026)

**Completed:**
- ✅ RSpec failures catalogued (401 total)
- ✅ Architectural violations documented (43+ instances)
- ✅ Surgical fix strategy defined
- ✅ Grok commands generated for Phase 1-2
- ✅ Nightly grinder protocol operational (3 cycles complete)
- ✅ Marketplace spec restored (19/19 passing)
- ✅ Orbital Shipyard spec restored (26/26 passing)
- ✅ Hydrosphere spec removed (obsolete, no Jan 8 backup)

**In Progress:**
- 🔄 Phase 1 restoration (~398 failures remaining)
- 🔄 Nightly autonomous grinding (fail-fast protocol)

**Pending:**
- ⏸️ UI enhancement (after test suite <50 faStrategy | Est. Time |
|------|----------|----------|------------|----------|-----------|
| mission_planner_service.rb | 11 | P1 | High | Manual surgical | 3-4h |
| economic_forecaster_service.rb | 9 | P1 | Medium | Manual (cascade) | 2h |
| cost_calculator.rb | 2 | P2 | Medium | Manual surgical | 2-3h |
| item.rb (regolith) | 1 | P2 | Low | Nightly grinder | 30min |
| geosphere_concern.rb | 3 | P2 | Medium | Manual surgical | 2h |
| energy_management.rb | 5 | P2 | Low | Nightly grinder | 30min |
| Integration specs | 8 | P3 | Low | Nightly grinder | 1h |
| Model validations | 60+ | P3 | Low/each | Nightly grinder | 8-10 nights |

**Complexity Definitions:**
- **Low:** Simple restore/remove (nightly grinder handles autonomously)
- **Medium:** Partial surgical fix required (may be grinder-compatible)
- **High:** Complex logic changes (manual surgical fix only)
| economic_forecaster_service.rb | 9 | P1 | Medium | 2 (cascade) |
| cost_calculator.rb | 2 | P2 | Medium | 2-3 |
| item.rb (regolith) | 1 | P2 | Low | 1 |
| geosphere_concern.rb | 3 | P2 | Medium | 2 |
| energy_management.rb | 5 | P2 | Low | 1-2 |
| Integration specs | 8 | P3 | Low | 1 (cascade) |
| Model validations | 60+ | P3 | Low/each | 10-15 total |

---

## Appendix B: Grok Command Templates

### Template: Surgical File Fix

```
"Grok, execute all commands ONLY within the web docker container.

Objective: Fix [SPECIFIC_ISSUE] in [FILE_NAME] using surgical approach.

CRITICAL: Compare with Jan 8 backup, restore ONLY broken logic. Preserve post-Jan-8 improvements.

Task 1: Analyze Diff
- Compare: galaxy_game/app/[PATH]/[FILE_NAME]
- Identify: [SPECIFIC_METHOD] changes between Jan 8 and current
- Determine: Breaking changes vs improvements

Task 2: Surgical Restoration
- BACKUP: tmp/pre_revert_backup/[FILE_NAME]
- RESTORE: [SPECIFIC_LINES] with [CORRECT_LOGIC]
- PRESERVE: [POST_JAN_8_FEATURES]

Task 3: Verify Dependencies
- Test: [DEPENDENT_SPECS]
- Check: No regressions in [RELATED_FILES]

VERIFICATION:
- Run: bundle exec rspec [SPEC_PATH]
- Expect: [X]/[X] passing

COMMIT:
git add [FILES]
git commit -m '[TYPE]: [DESCRIPTION]'

REMINDER: All operations inside docker container. Surgical fixes only."
```

### Template: Documentation Update

```
"Grok, documentation task (execute on HOST machine).

Objective: [UPDATE/CREATE] [DOC_NAME] to [PURPOSE].

Task: Update [SPECIFIC_SECTIONS]
- Add: [NEW_CONTENT]
- Fix: [INCORRECT_EXAMPLES]
- Remove: [VIOLATIONS]

VERIFICATION:
- Cross-reference with [RELATED_DOCS]
- Ensure consistency with architecture

COMMIT (on host):
git add docs/[PATH]/[FILE]
git commit -m 'docs: [DESCRIPTION]'

REMINDER: Documentation commits on host, NOT docker container."
```

---

## Appendix C: Reference Links
## Appendix D: Nightly Grinder Log Format

**Summary Log Template:** `log/nightly_grinder_summary_[timestamp].txt`

```
=== NIGHTLY GRINDER SUMMARY ===
Start Time: 2026-01-16 22:00:00
End Time: 2026-01-17 01:45:32
Duration: 3h 45m 32s

BASELINE:
- Initial Failures: 401
- Latest Log: data/logs/rspec_full_1768570591.log

RESTORED (Full Restoration from Jan 8):
✅ galaxy_game/spec/models/account_spec.rb (7 examples, 0 failures)
✅ galaxy_game/spec/models/financial/transaction_spec.rb (1 example, 0 failures)
✅ galaxy_game/spec/models/settlement/city_spec.rb (8 examples, 0 failures)

REMOVED (Obsolete - Not in Jan 8 Backup):
🗑️ galaxy_game/spec/models/hydrosphere_spec.rb (no backup found)

PARTIAL RESTORED (Added Missing Features):
🔧 galaxy_game/app/models/craft/base_craft.rb (added status attribute)
🔧 galaxy_game/app/models/settlement/base_settlement.rb (added orbital_construction_projects)

SKIPPED (Complex - Requires Human Review):
⚠️ galaxy_game/spec/services/ai_manager/mission_planner_service_spec.rb
   Reason: Diff shows >100 lines changed, location hardcoding violations
   Action: Flagged for manual surgical fix (see RESTORATION_AND_ENHANCEMENT_PLAN.md Phase 1.1)

⚠️ galaxy_game/spec/services/manufacturing/cost_calculator_spec.rb
   Reason: EconomicConfig integration changes, requires merge analysis
   Action: Flagged for manual review

FAILURES (Restoration Attempted but Failed):
❌ galaxy_game/spec/models/exotic_material_spec.rb
   Reason: Restored from backup but 3/7 examples still failing
   Revert: Yes (backup preserved)
   Action: Requires investigation - may need factory updates

RESULTS:
- Specs Restored: 3
- Specs Removed: 1
- Specs Partially Restored: 2 (model changes)
- Specs Skipped: 2
- Specs Failed: 1
- Total Processed: 9 specs

ESTIMATED PROGRESS:
- Previous Failures: 401
- Resolved This Session: ~20 failures
- **Estimated Current: ~381 failures**
- Next Full Run Required: Yes (to confirm actual count)

NEXT TARGETS (Top 5 by Failure Count):
1. ai_manager/mission_planner_service_spec.rb (11) - COMPLEX
2. ai_manager/economic_forecaster_service_spec.rb (9) - COMPLEX
3. integration/component_production_game_loop_spec.rb (3) - LOW
4. concerns/geosphere_concern_spec.rb (3) - MEDIUM
5. models/item_spec.rb (1) - LOW

RECOMMENDATIONS FOR HUMAN REVIEW:
1. Run full suite to confirm actual failure count
2. Review exotic_material_spec.rb failure logs (factory issue suspected)
3. Begin manual surgical fixes on AI Manager services (Phase 1.1)
4. Consider running second nightly cycle tonight if time permits

=== END SUMMARY ===
```

---

**End of Plan**  
**Next Actions:**
1. **Immediate:** Launch nightly grinder for autonomous overnight restoration
2. **Morning:** Review grinder summary, run full suite, identify manual complex fixes
3. **Daytime:** Execute Phase 1.1 (AI Manager) manual surgical fixesregolith.json`
- **Hydrosphere System Docs:** `docs/systems/hydrosphere_system.md`
- **Economic Config:** `data/json-data/config/economic_parameters.yml`
- **Mission Profiles:** `data/json-data/missions/`
- **Jan 8 Backup:** `data/old-code/galaxyGame-01-08-2026/`
- **Grok Notes:** `docs/developer/grok_notes.md`
- **Guardrails:** `docs/GUARDRAILS.md`
- **Data-Driven Systems:** `docs/architecture/DATA_DRIVEN_SYSTEMS.md`

---

**End of Plan**  
**Next Action:** Execute Phase 1.1 - AI Manager MissionPlannerService surgical fix
