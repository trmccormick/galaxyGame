AI Manager Architecture — CANONICAL INTENT
MUST READ BEFORE ANY AI MANAGER CODING

Role
Procurement + Deployment Decision Layer

Coordinates settlement expansion, resource gaps, unit deployment

Does NOT: Simulate physics, calculate yields, maintain parallel data models

Decision Loop
text
1. Settlement has unmet buy orders → Identify resource gap
2. inventory_isru_units → Check deployed units (UnitLookupService)
3. assess_inputs_available → geosphere.crust_composition, atmosphere.gases, MaterialPile  
4. deploy_missing_units → TEU+PVE for water, etc.
5. power_hard_gate → 120kw minimum or blocked
6. import_escalation → Contract if local production insufficient
Data Sources (READ ONLY)
text
- UnitLookupService.find_unit(unit_type) → operational_data JSON
- settlement.celestial_body.atmosphere.gases → Live composition  
- settlement.celestial_body.geosphere.crust_composition → Volatile yields
- settlement.surface_storage.material_piles → Regolith buffer
- settlement.buy_orders.unfulfilled → Demand signal
30+ Modular Services
text
CORE: manager.rb (orchestration)
ANALYSIS: isru_evaluator.rb (unit capability vs demand)
PLANNING: resource_planner.rb (deployment sequence)
DECISION: decision_tree.rb (prioritization)
UTILITY: unit_lookup_service.rb (JSON access)
FORBIDDEN PATTERNS (Delete on sight)
text
❌ ISRU_UNITS = { ... } → UnitLookupService only
❌ GAS_COMPOSITION = { ... } → atmosphere.gases only  
❌ resource_profile hashes → settlement models only
❌ power_score = capacity/required → hard gate return nil
❌ Units::Robot.create(:ice_extraction) → TEU+PVE units only
❌ Hardcoded GCC costs → market data only
Agent Rules
text
1. **READ THIS DOC FIRST** or STOP
2. **No new data models** — use existing Rails associations
3. **No physics simulation** — units execute operational_data JSON
4. **Power = hard gate** — insufficient = blocked immediately
5. **Synthesis Report → STOP** — no code until approved
Last Updated: 2026-04-03

text
