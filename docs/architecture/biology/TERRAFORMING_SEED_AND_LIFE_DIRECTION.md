# Terraforming Seeds, Life, and Digital Twin Direction
**Status:** Developmental direction (background systems)  
**Last updated:** 2026-10-08  
**Scope:** Keep narrow — most of this is background for the AI Manager and planetary state. Players interact mainly through market orders and settlements.

## 1. Goals
- Give the AI Manager a projection tool (Digital Twin) to rank planetary projects by cost vs benefit.
- Support staged Terraforming Seeds as cheaper, purpose-built construction projects that adapt basic life and gradually affect the biosphere.
- Distinguish Seeds from Worldhouses (shared construction tech, different purpose and cost).
- Handle the permanent uncertainty of undetected life and contamination risk lightly.
- Allow life (introduced or native) to produce both planned and unplanned biosphere effects.

## 2. Core Distinctions
- **Worldhouse**: Engineered, high-control habitat. Supports desired life under local gravity. Does not primarily change the planetary baseline.
- **Terraforming Seed**: Smaller construction project using similar shell/power/life-support tech. Starts from known minimal needs of basic Earth life (or native/hybrid packages). Adapts organisms and eventually contributes to / releases into the biosphere. Cheaper than even a small Worldhouse.
- Both respect local gravity (no artificial gravity assumed).

## 3. Digital Twin Role
- Primary tool for the AI Manager to run what-if projections on a specific world.
- Outputs for each candidate project (Seed stages, Worldhouse, atmospheric interventions, orbital assets, etc.):
  - Resource/energy cost over time (world-specific)
  - Timeline to milestones
  - Planetary benefit score
  - Residual risk (undetected life, contamination, adaptation uncertainty)
  - Confidence
- Rankings feed directly into market orders the AI Manager posts.

## 4. Life System Scope (Keep Narrow)
- Use existing `:primitive` / basic life-form support and atmospheric effect properties.
- Stage 1 Seeds start from already-researched minimal needs of basic Earth life.
- Light adaptation progress inside a Seed (simple 0→1 value + environmental stepping).
- Native life (when detected) can supply traits for hybrid/engineered packages (later path).
- No deep genetics, full ecosystems, or gravity-adaptation research trees required at this stage.

## 5. Uncertainty & Random Factor
- Sterility can never be proven — only detection confidence + residual risk.
- Contamination risk is permanent (can be reduced by better protocols at higher cost, never zero).
- Random “Unknown Life Detected” events:
  - Source unknown (native / accidental introduction / other).
  - Optional lightweight sequencing & comparison.
  - Possible simple effects on the biosphere (none, minor planned-style change, interference, or rare useful trait).
- These unplanned effects are the main random factor life introduces into terraforming projections.

## 6. AI Manager Usage
- Runs Digital Twin projections to decide: Seed vs Worldhouse vs atmospheric/orbital projects.
- Posts market orders for the chosen construction + payload + feedstock.
- Treats life-related biosphere changes (planned or random) as updates to planetary state for future rankings.

## 7. Implementation Notes / Next Steps
- Leverage existing BiosphereSimulationService + life-form atmospheric properties.
- Add Seed as a facility type that shares construction components with small Worldhouses but has distinct payload and adaptation systems.
- Extend Digital Twin outputs with the cost/benefit/risk fields above.
- Implement the lightweight unknown-life event and residual-risk factor.
- Keep all of the above background-facing; player visibility stays at market orders, settlement options, and occasional event notifications.