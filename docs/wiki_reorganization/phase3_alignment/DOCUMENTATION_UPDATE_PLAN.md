# Documentation Update Plan

**Created**: 2026-07-16  
**Purpose**: Prioritized list of documentation requiring updates to align with confirmed architecture and implementation. Implementation is correct; documentation is outdated, incomplete, or missing.

---

## Update Priorities

### CRITICAL (Blocks contributor understanding, affects MVP)

#### D1: AI Manager Service Inventory

**Current State**: `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` describes "8 core files" as the AIManager architecture.

**Reality**: 80+ service files in `app/services/ai_manager/` implementing independent concerns.

**Issue**: Contributors see discrepancy and may think system is broken or over-engineered. Blocks clear understanding of AIManager purpose.

**Impact**: CRITICAL — AI Manager is 2nd-largest service layer in app (after Rails default services). Misunderstanding blocks feature development.

**Fix Required**:
1. Restructure `AI_MANAGER_ARCHITECTURE.md` into two sections:
   - **Orchestration Layer**: 8 core files (manager, initializers, schedulers)
   - **Services Inventory**: Organize 80+ services into logical groups (pricing, economy, settlement, exploration, combat, etc.)
2. Create service dependency map showing how services interact
3. Add "How to Add a New AIManager Service" contributor guide

**Files to Update**:
- `docs/architecture/ai_manager/AI_MANAGER_ARCHITECTURE.md` (rewrite)
- `docs/architecture/ai_manager/services_inventory.md` (create new)
- `docs/CONTRIBUTING.md` (add "AIManager Services" section)

**Effort**: 6-8 hours

**Timeline**: Complete before next public preview build

---

#### D2: Manufacturing Chain Overview

**Current State**: `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md` marked "Draft/Stub" — incomplete.

**Reality**: Full manufacturing chain implemented: raw materials → processed materials → components → blueprints → assembly jobs.

**Issue**: Manufacturing system is playable loop but not documented. Contributors lack understanding of chain logic.

**Impact**: CRITICAL — Manufacturing is player core gameplay loop. Missing docs block feature additions and balance updates.

**Fix Required**:
1. Document full chain with service integration points:
   - Raw material → `MaterialProcessingService` → processed material
   - Processed material → `ComponentProductionService` → component
   - Components → `AssemblyService` → finished blueprint
2. Add cost flow diagram (material cost → processing cost → component cost → final price)
3. Explain NPC factory system (how NPCs drive manufacturing demand)
4. Document how blueprints gate access to manufacturing types

**Files to Update**:
- `docs/architecture/manufacturing/MANUFACTURING_SYSTEM_OVERVIEW.md` (complete stub)
- `docs/architecture/manufacturing/` (add service integration guides)

**Effort**: 4-5 hours

**Timeline**: Complete within 1 sprint

---

### HIGH (Affects player understanding, integration work)

#### D3: NPC Economy Integration Flow

**Current State**: Individual economy components documented (pricing, contracts, market). Integration flow missing.

**Reality**: NPC economy goes: AIManager initializes → creates pricing → generates orders → players see opportunities → contracts created → ledger tracks transactions.

**Issue**: Players/contributors can't follow decision flow. Unclear how NPC prices affect player opportunities.

**Impact**: HIGH — Players confused about pricing logic. Contributs can't extend economy system.

**Fix Required**:
1. Create "NPC Economy Lifecycle" section in economy overview
2. Document decision flow: NPC need → price calculation → opportunity creation → contract generation → player response
3. Explain how player automation fallback works (what if no player accepts contract?)
4. Add sequence diagram showing NPC-player economic interaction

**Files to Update**:
- `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md` (add integration flow)
- `docs/architecture/economy/contracts.md` (explain NPC opportunity creation)
- `docs/architecture/ai_manager/` (add economy orchestration docs)

**Effort**: 3-4 hours

**Timeline**: Complete within 1 sprint

---

#### D4: Multiple Gameplay Loops Documentation

**Current State**: No documentation explaining loop independence or player entry points.

**Reality**: 6 independent loops (exploration, terraforming, settlement, logistics, trading, combat) exist; players can focus on any one.

**Issue**: Players don't know which loop they're in or how to switch. New contributors don't understand multiloop design.

**Impact**: HIGH — Player onboarding fails; contributors misalign feature work with game intent.

**Fix Required**:
1. Create `docs/gameplay/gameplay_loops_overview.md` explaining:
   - Each loop's core loop (goal → action → reward)
   - Entry point (how player accesses loop)
   - Dependencies on other loops
   - Example progression path for each loop
2. Add visualization showing loop independence
3. Link each loop to relevant service documentation

**Files to Create**:
- `docs/gameplay/gameplay_loops_overview.md` (new)
- `docs/gameplay/loops/exploration_loop.md` (new)
- `docs/gameplay/loops/terraforming_loop.md` (new)
- `docs/gameplay/loops/settlement_loop.md` (new)
- `docs/gameplay/loops/logistics_loop.md` (new)
- `docs/gameplay/loops/trading_loop.md` (new)

**Effort**: 5-6 hours

**Timeline**: Complete within 1 sprint

---

#### D5: Cost-Based Economy and Earth Anchor Pricing

**Current State**: EconomicConfig logic not documented. Earth anchor ceiling not explained.

**Reality**: `EconomicConfig` sets Earth anchor price ceiling. All NPC prices anchored to Earth costs via formula. Scaling logic exists but not explained.

**Issue**: Contributors can't understand how to balance prices or add new material types.

**Impact**: HIGH — Economy balancing blocked. Price adjustment requests can't be fulfilled without code review.

**Fix Required**:
1. Document Earth anchor pricing formula: `(earth_base_price * scaling_factor) + locality_premium`
2. Explain EAP concept and why it matters (prevents hyperinflation in isolated colonies)
3. Document how to adjust pricing without code changes (YAML config)
4. Add price scaling examples (Earth → Luna → Mars → Venus)

**Files to Update**:
- `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md` (add pricing section)
- `docs/reference/economic_constants.md` (create if not exists)

**Effort**: 2-3 hours

**Timeline**: Complete within 1 sprint

---

### MEDIUM (Improves contributor experience, supports future features)

#### D6: Worldhouse Design and Lava-Tube Enclosure Pattern

**Current State**: Worldhouses documented as "structures built over terrain." Enclosure pattern/biome integration not explained.

**Reality**: Worldhouses are lava-tube habitats engineered to support terraforming-seed biomes. Enclosure enables artificial atmosphere/humidity control for staged life-form deployment.

**Issue**: Contributors don't understand Worldhouse purpose in terraforming pipeline. Design appears arbitrary.

**Impact**: MEDIUM — Terraforming feature development blocked. Contributors can't implement Worldhouse-specific mechanics.

**Fix Required**:
1. Explain Worldhouse as lava-tube enclosure pattern (real-world precedent: lunar lava tubes)
2. Document biome integration: Worldhouse → PlanetBiome (terraforming-seed) → LifeFormDeployment
3. Add lifecycle diagram: bare worldhouse → engineered conditions → deployed life forms → expanded terraforming
4. Explain why Worldhouses don't have Biosphere records (engineered, not self-sustaining)

**Files to Update**:
- `docs/architecture/structures/worldhouse_design.md` (expand with enclosure pattern)
- `docs/architecture/biology/terraforming_design.md` (add Worldhouse section)

**Effort**: 3-4 hours

**Timeline**: Complete within 2 sprints

---

#### D7: Governance Hierarchy Diagram

**Current State**: Colony → Settlement → Structure hierarchy documented in text only.

**Reality**: Clear three-tier hierarchy exists in code with validation rules.

**Issue**: Visual learners and new contributors confused by text-only explanation.

**Impact**: MEDIUM — Onboarding slower; contributor errors around hierarchy.

**Fix Required**:
1. Add ASCII or Mermaid diagram to README showing hierarchy and relationships
2. Add validation rules (e.g., "Colony requires 2+ Settlements")
3. Show example: "Earth Colony" → "Valles Marineris Settlement" → "Lava Tube Worldhouse" (structure)

**Files to Update**:
- `docs/architecture/structures/README.md` (add hierarchy diagram)

**Effort**: 1 hour

**Timeline**: Complete within 1 sprint

---

#### D8: OrbitalDepot Namespace History

**Current State**: Dual namespace exists (root-level RETIRED, Settlement::active). History not documented.

**Reality**: Namespace consolidated to Settlement:: because orbital settlements use same administrative model as ground settlements.

**Issue**: Contributors may see both namespaces and think there's a conflict or redundancy.

**Impact**: MEDIUM — Potential for accidental code resurrection in root namespace.

**Fix Required**:
1. Add "Namespace Evolution" note explaining why root-level OrbitalDepot is RETIRED
2. Explain that consolidation into Settlement:: is intentional pattern (single administrative model)
3. Note that root version is kept for git history only

**Files to Update**:
- `docs/architecture/structures/README.md` (add namespace history)
- Code comment in `app/models/orbital_depot.rb` (clarify RETIRED status)

**Effort**: 0.5 hour

**Timeline**: Complete within 1 sprint

---

#### D9: TerraSim Regression Engine Roadmap

**Current State**: `docs/architecture/terrasim/OVERVIEW.md` notes regression engine "not yet implemented." No roadmap.

**Reality**: Regression engine is future enhancement (not MVP-blocking per intent #12 playable-loop focus).

**Issue**: Contributors don't know if regression engine is planned, deprioritized, or abandoned.

**Impact**: MEDIUM — Feature roadmap clarity for simulation team.

**Fix Required**:
1. Add "Future Enhancements" section to TerraSim overview
2. Document regression engine design intent: What problem does it solve? (Climate feedback loops?)
3. Estimate effort and timeline (post-Mars phase?)
4. Link to any related feature requests or research

**Files to Update**:
- `docs/architecture/terrasim/OVERVIEW.md` (add roadmap section)

**Effort**: 1-2 hours

**Timeline**: Complete within 2 sprints

---

### VERIFICATION REQUIRED (Implementation check needed)

#### D10: Biome vs PlanetBiome Implementation (NULL biosphere_id Check)

**Current State**: Model architecture resolved (Confirmed Design). Schema implementation not verified.

**Reality**: Design intent requires `planet_biomes.biosphere_id` to allow NULL (for worldhouse-only biomes with no Biosphere).

**Issue**: If schema doesn't allow NULL, worldhouse-only biomes can't exist without forcing Biosphere record creation.

**Impact**: LOW-MEDIUM — Affects worldhouse terraforming feature. Not MVP-blocking if workaround exists (e.g., empty Biosphere record), but design-correct approach requires NULL check.

**Action**:
1. Check migration: Does `planet_biomes.biosphere_id` have `null: false` constraint?
2. If NULL not allowed: Add migration to change constraint to `null: true`
3. Document finding and reason in `docs/architecture/biology/biome_model.md`

**Files to Check**:
- `galaxy_game/db/migrate/*create_planet_biomes*` (check schema)
- `galaxy_game/db/schema.rb` (verify current state)

**Files to Update**:
- `docs/architecture/biology/biome_model.md` (document schema decision)

**Effort**: 0.5-1 hour

**Timeline**: Complete before worldhouse terraforming implementation

---

#### D11: Terraforming-Seed Target Conditions Tracking

**Current State**: Design distinguishes engineered biomes (terraforming-seeds) from planetary biospheres. Target-condition tracking status unknown.

**Reality**: Design intent requires tracking target vs current environmental conditions (for staging life forms).

**Issue**: If target-condition tracking doesn't exist, it may need to be added as backlog item.

**Action**:
1. Check `LifeFormDeployment` model: Does it track target_conditions or target_temperature/humidity?
2. If not present: Document as "future enhancement" in backlog
3. If present: Document implementation in `docs/architecture/biology/terraforming_design.md`

**Files to Check**:
- `app/models/life_form_deployment.rb` (check attributes)
- `app/models/planet_biome.rb` (check associations)

**Files to Update**:
- `docs/architecture/biology/terraforming_design.md` (document implementation or backlog item)

**Effort**: 0.5-1 hour

**Timeline**: Complete before terraforming feature expansion

---

#### D12: Technology Level vs MK Mapping (Exact Mechanics)

**Current State**: Intent confirms two-axis (TL = capability, MK = iteration). Exact mapping undefined.

**Reality**: Code has tech tree with 19 categories but exact TL/MK gating rules not formalized.

**Issue**: Contributors can't understand how to balance tech progression or add new tech types.

**Action**:
1. Check tech tree implementation: How are TL and MK currently constrained?
2. Document exact rules (e.g., "TL2 allows MK1-MK2 for any blueprint type")
3. Create mapping table: TL levels × available MK tiers

**Files to Check**:
- `app/services/ai_manager/technology_tree_service.rb` (check TL/MK logic)
- `config/technology_tree.yml` (check configuration)
- `docs/reference/DESIGN_INTENT_ART_BIBLE_BLUEPRINT_VISUALIZATION.md` (check current docs)

**Files to Update**:
- `docs/architecture/technology_tree.md` (document exact mapping)

**Effort**: 2-3 hours

**Timeline**: Complete before tech progression feature balancing (high priority for player progression)

---

## Documentation Update Roadmap

### Sprint 1 (Next Sprint)
1. **CRITICAL**: D1 (AI Manager inventory) — 6-8 hours
2. **HIGH**: D3 (NPC economy flow) — 3-4 hours
3. **MEDIUM**: D7 (Hierarchy diagram) — 1 hour
4. **MEDIUM**: D8 (OrbitalDepot history) — 0.5 hour

**Total Sprint 1**: ~14 hours

### Sprint 2
1. **CRITICAL**: D2 (Manufacturing overview) — 4-5 hours
2. **HIGH**: D4 (Gameplay loops) — 5-6 hours
3. **HIGH**: D5 (EAP pricing) — 2-3 hours
4. **VERIFICATION**: D10, D11 (Biome/terraforming checks) — 1-2 hours

**Total Sprint 2**: ~14 hours

### Sprint 3
1. **MEDIUM**: D6 (Worldhouse design) — 3-4 hours
2. **MEDIUM**: D9 (TerraSim roadmap) — 1-2 hours
3. **VERIFICATION**: D12 (TL/MK mapping) — 2-3 hours

**Total Sprint 3**: ~8 hours

---

## Success Criteria

**Documentation updates are complete when:**
1. All 12 gaps have corresponding updates
2. New contributor can understand architecture without code review
3. Contributor can add new service/blueprint/technology without guidance
4. Player can identify which gameplay loop aligns with their playstyle
5. No recurring questions about "why does this exist?" in contributor discussions

---

## Owner Assignment (Recommended)

- **D1** (AI Manager): @architecture_lead (highest priority)
- **D2** (Manufacturing): @systems_lead
- **D3** (NPC Economy): @systems_lead
- **D4** (Gameplay Loops): @design_lead
- **D5** (EAP Pricing): @systems_lead
- **D6** (Worldhouse): @terraforming_lead
- **D7** (Hierarchy): @quick_win (1 hour)
- **D8** (OrbitalDepot): @quick_win (0.5 hour)
- **D9** (TerraSim): @simulation_lead
- **D10**, **D11**, **D12**: Code verification before documentation
