# Biology & Terraforming — Wiki Hub

> **Status:** Canonical wiki documentation for all biology, biosphere, and terraforming mechanics.  
> **Authoritative intent:** [`docs/architecture/biology/TERRAFORMING_SEED_AND_LIFE_DIRECTION.md`](../../../architecture/biology/TERRAFORMING_SEED_AND_LIFE_DIRECTION.md) — all changes should begin in the architecture dir and be reflected here.

## Pages

| Page | Purpose |
|------|---------|
| [Biosphere Simulation](./biosphere_simulation.md) | Liquid water trigger logic, BiosphereSimulationService interface, soil quality formulas, biodiversity scoring, ecosystem interaction rules. |
| [Terraforming Seeds](./terraforming_seeds.md) | Core distinctions vs Worldhouses, staged progression (Stages 1–5+), Bio-Nursery Dome categories, Top-Down and Bottom-Up adaptation pipelines. |

## Cross-Links

| Wiki Page | Relation |
|-----------|----------|
| [Terraforming Economic Integration](../../logistics/terraforming_economic_integration.md) | Seed path vs brute-force economics; GCC budget constraints. |
| [AI Manager Logic](../../logistics/ai_manager_logic.md) | Digital Twin projections feed market orders for Seed construction. |
| [Station Construction Options](../../engineering/station_construction_options.md) | Shared shell/power tech between Seeds and Worldhouses. |
| [Planetary Protection & Environmental Governance](../../infrastructure/planetary_protection_environmental_governance.md) | Contamination classes, biosafety requirements per Seed stage. |

## Notes

- Biology systems are **background-facing**; player visibility is through market orders, settlement options, and event notifications.
- Life-system scope is narrow (`:primitive` / basic life-form support) unless the direction document is updated.
- The AI Manager may choose brute-force terraforming (imported gases, orbital mirrors/shades) instead of biological methods.
