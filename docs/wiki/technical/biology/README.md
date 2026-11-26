# Biology & Terraforming — Wiki Hub

> **Status:** Canonical wiki documentation for all biology, biosphere, and terraforming mechanics.  
> **Wiki authority:** Design intent lives in the active wiki. This section covers biology and terraforming-specific biosphere behavior; broader environmental simulation and sphere interactions are defined in the TerraSim and sphere-model pages.

**Page roles (keep distinct):**
- `README.md` (this page) — established direction and navigation.
- `sphere_models_and_interactions.md` — source-verified implementation notes.
- `biosphere_simulation.md` — intended behavior and proposed simulation architecture.
- `terraforming_seeds.md` — possible biological deployment and development concepts (including historical stage design).

## Pages

| Page | Purpose |
|------|---------|
| [Biosphere Simulation](./biosphere_simulation.md) | Intended biosphere behavior and proposed simulation architecture (not a source-verified implementation inventory). |
| [TerraSim — Environmental Simulation](../terrasim.md) | Natural-world simulation, historical calibration, environmental events, terraforming, and future tuning direction. |
| [Celestial-Body Sphere Models & Environmental Interactions](../sphere_models_and_interactions.md) | **Source-verified** sphere data ownership, couplings, and current service behavior across body types. |
| [Terraforming Seeds](./terraforming_seeds.md) | Seed vs Worldhouse concepts; **candidate** staged lifecycle (not an inevitable full-terraform track); Bio-Nursery and adaptation pipeline design. Owner direction for initial simple-life Mars use is on that page. |
| [Contamination & Biosafety](../../infrastructure/contamination_and_biosafety.md) | Biological contamination, containment, residual risk, and biosafety relationships for Seeds, Bio-Nurseries, and Worldhouses. |

## Cross-Links

| Wiki Page | Relation |
|-----------|----------|
| [Terraforming Economic Integration](../../logistics/terraforming_economic_integration.md) | Seed path vs brute-force economics; GCC budget constraints. |
| [AI Manager Logic](../../logistics/ai_manager_logic.md) | Digital Twin projections feed market orders for Seed construction. |
| [Station Construction Options](../../engineering/station_construction_options.md) | Shared shell/power tech between Seeds and Worldhouses. |
| [Planetary Protection & Environmental Governance](../../infrastructure/planetary_protection_environmental_governance.md) | Contamination classes, biosafety requirements per Seed stage. |
| [Terraforming options](../../infrastructure/terraforming_options.md) | Atmospheric and engineering pathways; biology may run alongside or instead of brute-force methods. |

## Established Direction — Simple Life and Initial Mars Terraforming

- For current strategic planning, assume that simple life will be found and that simple life can be used in Mars's initial terraforming. This is a working premise for planning, not a claim that a discovery or deployment workflow is already implemented or scientifically validated.
- The initial biological contribution is worthwhile on its own. It must not depend on completing full planetary terraforming; full terraforming may never be undertaken or completed.
- Keep the initial use focused on simple organisms and practical early effects. More complex ecosystems, engineered or hybrid organisms, and later biosphere development remain possible extensions, not prerequisites for the initial Mars use case. Whether any particular historical Seed stage definition fully captures that initial use remains **OPEN**.
- Preserve existing biology models, services, experiments, and RSpec coverage. Further development is deferred until gameplay or operational needs make it relevant; this is continuation later, not abandonment.
- Biology systems are **background-facing**; player visibility is through market orders, settlement options, and event notifications.
- The AI Manager may choose brute-force terraforming (imported gases, orbital mirrors/shades) alongside or instead of biological methods. Simple-life use does not make full biological or planetary terraforming mandatory.
