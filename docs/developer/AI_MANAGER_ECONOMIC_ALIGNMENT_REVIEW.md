# AI Manager Economic Planner Alignment Review

**Date:** 2026-01-15

## Overview

This document reviews how Claude’s proposed mission planning economics and sourcing logic align with the current repository. It summarizes what already exists, identifies gaps, and suggests documentation-only follow-ups to guide future implementation (no code changes).

## Existing Implementation

- **Pattern Mapping:** `PatternTargetMapper` in `galaxy_game/app/services/ai_manager/pattern_target_mapper.rb` maps simplified pattern names (e.g., `mars-terraforming`) to target celestial body identifiers.
- **Mission Planner:** `MissionPlannerService` in `galaxy_game/app/services/ai_manager/mission_planner_service.rb` produces:
  - Timeline, phases, milestones
  - Resource requirements (by year, totals, peak demand)
  - Cost breakdown (material + transport), contingency, grand total
  - Sourcing strategy (local, regional, import) with transport ratio
  - Player revenue opportunities and basic planetary changes per pattern
- **Economic Forecaster:** `EconomicForecasterService` in `galaxy_game/app/services/ai_manager/economic_forecaster_service.rb` analyzes:
  - GCC distribution (DC vs Player), economic velocity
  - Demand curve, bottlenecks, opportunities, risk assessment
  - Transport cost analysis (flags high-transport resources)
- **Economic Parameters:** `galaxy_game/config/economic_parameters.yml` documents:
  - Currency peg (`usd_to_gcc_peg: 1.0`)
  - Transport rates per kg by cargo category (100–250 GCC/kg) and route modifiers
  - Refining factors, logistics multipliers
  - Local production maturity multipliers and sample costs at maturity (water/oxygen/iron/aluminum)
- **Bootstrap Constant:** `INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00` in `galaxy_game/config/initializers/game_constants.rb` (legacy early-era import cost).

## Blueprints and Costs

- **Blueprint Presence:** Extensive JSON blueprint library in `data/json-data/blueprints` across `components`, `structures`, `modules`, `rigs`, `units`, etc.
- **Lookup Service:** `Lookup::BlueprintLookupService` in `galaxy_game/app/services/lookup/blueprint_lookup_service.rb` loads JSON recursively, matches by `id`/`unit_id`/`name`/`aliases`/partial, and supports category filtering. Returns raw JSON without cost parsing.
- **Cost Representation:** Mixed forms:
  - Numeric-like GCC values as strings (e.g., `cost_analysis.material_cost: "7,000 GCC"` in `components/structural/sealed_lava_tube_cover_bp.json`)
  - Qualitative tiers ("High", "Very High") for materials and variants
  - Many component blueprints focus on production/variants without explicit numeric per-unit cost
- **Specs:** `galaxy_game/spec/services/lookup/blueprint_lookup_service_spec.rb` covers loading, matching, category filters, aliases, partial matches, and error handling.

## Economic Model References

- **EAP Concept:** Earth Anchor Price = Earth spot price × refining factor + transport cost. While the planner combines market price + transport for delivered cost, a dedicated helper `calculate_earth_anchor_price(resource)` does not currently exist.
- **Transport Costs:** Mature-era rates (100–200 GCC/kg) and route modifiers (e.g., `earth_to_luna: 1.0`, `earth_to_mars: 1.5`) are present in `economic_parameters.yml`. Bootstrap-era import cost (`1320 USD/kg`) exists in `GameConstants`.
- **NPC Pricing:** `economic_parameters.yml` contains `npc_behavior` for cost-based and market-based markups, but planner pricing does not currently apply explicit “undercut EAP” strategies.

## Precursor Infrastructure Logic

- **Templates:** Mission profiles are reusable and system-agnostic (see `docs/mission_profiles/00_complete_profile_library.md`). JSON precursor profiles (e.g., `data/json-data/missions/tasks/planetary-precursor-1/...`) include environment-adaptive fields.
- **Planner Assumption:** Current planner checks ISRU production using a static per-location list but does not enforce a “precursor-first local production” rule.
- **Site Context:** Lava tube site selection is not explicitly documented in settlement planning docs; it appears as blueprint/structure intent (e.g., sealed lava tube cover) rather than formalized rules.

## Documentation Gaps

- **EAP & Transport Model:** No concise doc page unifying EAP formula, refining factors, transport cargo categories, route modifiers, and the bootstrap constant for the planner’s context.
- **Precursor-First Policy:** Missing an explicit statement that basic resources (e.g., O2, water, regolith) are always locally sourced after precursor phases, with environment-specific capability maps.
- **NPC Pricing Strategy:** Undercutting EAP and minimum margin logic is configured but not described as planner-facing behavior.
- **Blueprint Cost Schema:** Lacks a standardized numeric schema for blueprint costs (e.g., `unit_cost_gcc: Float`), making consumption by services inconsistent.
- **Settlement Site Selection:** The “lava tube default” starting location is not clearly documented in settlement planning or patterns.

## Recommendations (Docs Only)

- **Add Economic Model Section:** In `docs/developer/AI_MANAGER_PLANNER.md`, add a “Economic Model for Mission Planner” section covering:
  - EAP formula with examples (Titanium to Luna/Mars)
  - Transport cargo categories + route modifiers with sample totals
  - Refining factors and logistics multipliers
  - Bootstrap vs mature era selection guidance
- **Precursor Infrastructure Assumptions:** In `docs/ai_manager/02_settlement_planning.md` (or a new precursor page), document environment-aware capability maps (Luna/Mars/Titan/Europa/etc.) and a “local-first” sourcing rule post-precursor.
- **NPC Pricing Behavior:** Summarize cost-based vs market-based pricing, minimum profit margins, and how NPCs undercut Earth import when local supply exists.
- **Blueprint Cost Schema Guidance:** Propose a minimal standard for numeric costs and a parsing convention (e.g., `unit_cost_gcc`, `research_cost_gcc`, `installation_cost_gcc`) while allowing qualitative descriptors for materials.
- **Site Selection Note:** Document lava tube settlement context and its effect on sourcing and construction (e.g., cover panels, sealed entrance systems).

## Open Questions

- **Blueprint Numeric Costs:** Should blueprints consistently include parsed numeric fields (GCC) for manufactured items, or remain descriptive with planner deriving costs via EAP/local production configs?
- **Era Selection:** When should planner use the legacy bootstrap constant (1320 USD/kg) vs mature rates? Should there be a mission-level toggle (bootstrap vs mature)?
- **Regional Sourcing Rules:** Should planner explicitly prefer regional NPC sources to undercut EAP when market history is insufficient?

## References

- Planner: `docs/developer/AI_MANAGER_PLANNER.md`
- Settlement Planning: `docs/ai_manager/02_settlement_planning.md`
- Economic Baseline: `docs/market/economic_baseline.md`
- Patterns: `docs/architecture/settlement_patterns.md`, `docs/mission_profiles/00_complete_profile_library.md`
- Services: `galaxy_game/app/services/ai_manager/mission_planner_service.rb`, `galaxy_game/app/services/ai_manager/economic_forecaster_service.rb`, `galaxy_game/app/services/ai_manager/pattern_target_mapper.rb`
- Config: `galaxy_game/config/economic_parameters.yml`, `galaxy_game/config/initializers/game_constants.rb`
- Blueprints: `data/json-data/blueprints/...`
- Blueprint Lookup: `galaxy_game/app/services/lookup/blueprint_lookup_service.rb`, `galaxy_game/spec/services/lookup/blueprint_lookup_service_spec.rb`

---

This review is documentation-only and intended to guide future planner economics and sourcing enhancements aligned with existing data and configuration.

## Follow-up Documents

- Economic Model section appended to: `docs/developer/AI_MANAGER_PLANNER.md`
- Precursor capabilities documented in: `docs/ai_manager/PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md`
- Blueprint schema guidance: `docs/developer/BLUEPRINT_COST_SCHEMA_GUIDE.md`
