---
title: Settlement Infrastructure — Intent & Live Index
category: Infrastructure
status: DESIGN INTENT (promoted from `docs/architecture/settlement/README.md`)
last_updated: 2026-10-29
canonical_source: docs/architecture/settlement/README.md
---

# Settlement Infrastructure

> **This page is the canonical wiki entry for settlement infrastructure intent.**  
> See [wiki Home](../README.md) for navigation and category structure.

---

## Design Intent (Target)

A **Settlement** is the core administrative, economic, and population unit in Galaxy Game. It manages population, economy, contracts, and jurisdiction — and can span multiple physical structures (natural or artificial). Settlements may be placed on planetary surfaces, inside natural features (lava tubes, craters), or in orbit (e.g., L1 Gateway).

### Key Principles

| Principle | Target Behavior |
|-----------|----------------|
| Separation of Concerns | Settlements are *administrative*, not physical structures. They host within structures but are not themselves structures. |
| Blueprint-Driven Expansion | Artificial structures are built from blueprints; settlements grow by adding structures. |
| Natural Feature Hosting | Settlements can be placed in natural features (lava tubes, craters) or artificial structures (worldhouses, stations, depots). |
| Multi-Structure Orbital Sets | Orbital settlements contain peer structures (e.g., shipyard + depot at L1 Gateway). Use `Settlement::OrbitalSettlement` for this pattern; `Settlement::SpaceStation` is deprecated. |

### Habitat Tiers (Enum Values)

The game model uses an enum to classify settlement maturity and scale:

| Tier | Design Intent |
|------|---------------|
| `base` | Earliest viable presence; minimal life support, few structures. |
| `outpost` | Expanded operations; secondary life-support systems added. |
| `settlement` | Self-sustaining habitat tier; integrated infrastructure loops (ISRU, power grid). |
| `city` | Dense urban scale; external trade, multi-layer logistics. |
| `station` | Orbital / microgravity habitat variant of equivalent scale. |

### Life Support & Infrastructure Requirements (Target)

1. **Power Grid** — Required before any structure can operate; tier scales with settlement class.
2. **Atmospheric Processing** — Pressurized habitat cells, air recycling; tied to `Atmospheric-Harvesting` wiki entry for external supply chains.
3. **ISRU Loop** — In-situ resource utilization provides baseline materials; detailed in [ISRU Fabrication Chain](../technical/isru_fabrication_chain.md).
4. **Logistics Linkage** — Transport connections to markets (see [Logistics & Hauling](../logistics/Logistics-and-Hauling.md)) and financial engine ([Financial Engine](../logistics/Financial-Engine.md)).

### Settlement Growth Stages (Target Pattern)

```
base ──► outpost ──► settlement ──► city / station
  │          │            │            │
  ▼          ▼            ▼            ▼
 1–2 struct 3–5 struct   6–10 struct  10+ struct, multi-system
 minimal ISP expanded ISP  full ISRU    integrated trade
```

- **Stage gate**: Each tier requires its prior life-support loop to be online.
- **Blueprint dependency**: Artificial structures require blueprints and construction time.
- **Natural features** bypass some early construction steps but still need power + atmosphere.

### Orbital Settlements (Target Pattern)

Orbital settlements (e.g., L1 Gateway) are a single settlement instance containing multiple peer structures:

```
Settlement::OrbitalSettlement (L1 Gateway)
 ├── Structures::SpaceStation   (shipyard / repair)
 └── Structures::OrbitalDepot    (cargo / refueling)
```

### Model Relationships (Target Code Schema)

| Model | Responsibility |
|-------|----------------|
| `BaseSettlement` | Core admin unit; `has_many :structures`, `has_many :base_units`, `has_one :location`, `belongs_to :colony`. |
| `Structures::BaseStructure` | Physical asset (natural or artificial); subclassed for worldhouses, space stations, depots. |
| `Settlement::OrbitalSettlement` | Planned orbital-specific behavior; replaces deprecated `SpaceStation` for multi-structure cases. |

---

## Current Code State vs Design Intent

> **Status: Many of these items are still in flux. Verify against running code before relying on them.**

| Aspect | Target Intent | Current State | Conflict / Notes |
|--------|--------------|---------------|------------------|
| Settlement enum (`base/outpost/settlement/city/station`) | Enum on `BaseSettlement` for tier classification. | *Verify: does the running model use this exact enum?* | Unknown — needs verify-against-code. |
| Multi-structure orbital settlement | `OrbitalSettlement` with `has_many :structures`. | `SpaceStation` is deprecated; migration path not fully implemented. | **Stale reference**: [docs/architecture/settlement/README.md](https://github.com/trmccormick/galaxyGame/blob/main/docs/architecture/settlement/README.md) notes this explicitly. |
| Structure association | All structures subclass `BaseStructure`, linked via `has_many :structures`. | Pattern documented in model code; verify subclasses exist. | None known — standard Rails pattern. |
| Blueprint construction pipeline | Structures built from blueprints over time. | Covered under [Station Construction Options](../engineering/station_construction_options.md). | Consistent. |

### Stale References to Audit

- `app/models/settlement/space_station.rb` — marked as deprecated in source architecture; migration to `OrbitalSettlement` is incomplete.
- `docs/architecture/patterns/settlement_patterns.md` — linked from source architecture but quality varies (per wiki posture guidance). Prefer wiki pages first.
- `docs/architecture/overview.md` — broad overview may reference phases that have moved; defer to running code + topic pages.

---

## Links & Cross-References

| Resource | Role |
|----------|------|
| [Source architecture](https://github.com/trmccormick/galaxyGame/blob/main/docs/architecture/settlement/README.md) | `docs/architecture/settlement/README.md` — original intent document (archived reference) |
| [SETTLEMENT-PATTERNS](https://github.com/trmccormick/galaxyGame/blob/main/docs/architecture/patterns/settlement_patterns.md) | Deterministic settlement evolution patterns (`docs/architecture/patterns/`) |
| [Worldhouse Intent](https://github.com/trmccormick/galaxyGame/blob/main/docs/architecture/intent/worldhouse_intent.md) | Worldhouse pattern detail (`docs/architecture/intent/`) |
| [ISRU Fabrication Chain](../technical/isru_fabrication_chain.md) | In-situ resource utilization pipelines (infra foundation for settlements) |
| [Station Construction Options](../engineering/station_construction_options.md) | Pre-player station/build pipelines relevant to settlement growth |

---

## Known Gaps

| Gap | Notes |
|-----|-------|
| Settlement → Structure migration timeline | No documented per-tier construction requirements (costs, durations, prerequisites). |
| Life-support tier gating | When each life-support system must be online before the next tier — not yet defined in code or docs. |
| Orbital settlement migration plan | `SpaceStation` deprecation noted but no implementation tracker or deadline. |
