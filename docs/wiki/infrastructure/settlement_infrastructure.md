---
title: Settlement Infrastructure
category: Infrastructure
status: LIVE (wiki entry)
last_updated: 2026-10-29
---

# Settlement Infrastructure

Settlement infrastructure covers the administrative, economic, and population systems that model how human presence expands across the Galaxy Game.

---

## Design Intent

A **Settlement** is the core administrative, economic, and population unit in Galaxy Game. It manages population, economy, contracts, and jurisdiction — and can span multiple physical structures (natural or artificial). Settlements may be placed on planetary surfaces, inside natural features (lava tubes, craters), or in orbit (e.g., L1 Gateway).

### Key Principles

| Principle | Target Behavior |
|-----------|-----------------|
| Separation of Concerns | Settlements are *administrative*, not physical structures. They host within structures but are not themselves structures. |
| Blueprint-Driven Expansion | Artificial structures are built from blueprints; settlements grow by adding structures. |
| Natural Feature Hosting | Settlements can be placed in natural features (lava tubes, craters) or artificial structures (worldhouses, stations, depots). |
| Multi-Structure Orbital Sets | Orbital settlements contain peer structures (e.g., shipyard + depot at L1 Gateway). Use `Settlement::OrbitalSettlement` for this pattern; `Settlement::SpaceStation` is deprecated. |

---

## CONFIRMED — Code State

### Habitat Tiers Enum

Source: `galaxy_game/app/models/settlement/base_settlement.rb` (line 48)

```ruby
enum settlement_type: { base: 0, outpost: 1, settlement: 2, city: 3, station: 4 }
```

| Tier | Design Intent |
|------|---------------|
| `base` | Earliest viable presence; minimal life support, few structures. |
| `outpost` | Expanded operations; secondary life-support systems added. |
| `settlement` | Self-sustaining habitat tier; integrated infrastructure loops (ISRU, power grid). |
| `city` | Dense urban scale; external trade, multi-layer logistics. |
| `station` | Orbital / microgravity habitat variant of equivalent scale. |

### OrbitalSettlement Model

Source: `galaxy_game/app/models/settlement/orbital_settlement.rb` (line 3)

```ruby
class Settlement::OrbitalSettlement < ApplicationRecord
```

- **Confirmed**: Model exists and is active.
- Replaces deprecated `SpaceStation` / `OrbitalDepot` for multi-structure orbital cases.

### SpaceStation / OrbitalDepot Namespace Split — OPEN

**Status: Confirmed retired; file-level record split is unconfirmed.**

| File | Status | Notes |
|------|--------|-------|
| `galaxy_game/app/models/settlement/space_station.rb` | RETIRED 2026-04-10 | "Do not use this class. Kept for git history only." |
| `galaxy_game/app/models/settlement/orbital_depot.rb` | RETIRED 2026-04-10 | "Do not use this class. Kept for git history only." |

**OPEN**: Do these two files remain in the repo, or have they been removed from `git ls-files`? Confirmation needed from owner.

### Deprecation — Legacy Only

Confirmed: Both `SpaceStation` and `OrbitalDepot` are **retired (legacy only)** as of 2026-04-10. No active migration is in progress; new code should use `Settlement::OrbitalSettlement` with `Structures::OrbitalStructure`.

### BaseSettlement Associations

Source: `galaxy_game/app/models/settlement/base_settlement.rb` (lines 14–35)

```ruby
has_one :marketplace, ...
has_one :location, ...
has_many :docked_crafts, ...
has_many :base_units, class_name: 'Units::BaseUnit', as: :attachable
has_many :orbital_construction_projects, class_name: 'OrbitalConstructionProject', foreign_key: 'station_id'
has_many :jobs, foreign_key: 'settlement_id', dependent: :destroy
has_many :construction_jobs, foreign_key: 'settlement_id', dependent: :destroy
```

### SettlementCore Concern — Associations & Record Path

Source: `galaxy_game/app/models/concerns/settlement/settlement_core.rb`

| Association | Type | Source (line) |
|-------------|------|---------------|
| `owner` | `belongs_to :owner, polymorphic: true, optional: true` | line 9 |
| `colony` | `belongs_to :colony, ...` | line 10 |
| `marketplace_account` | `has_one :account, ...` | line 15 |
| `accounts` | `has_many :accounts, ...` | line 19 |
| `structures` | `has_many :structures, class_name: 'Structures::BaseStructure', as: :attachable` | line 22 |
| `missions` | `has_many :missions, dependent: :destroy` | line 25 |
| `inventory` | `has_one :inventory, as: :inventoryable, dependent: :destroy` | line 29 |

---

## OPEN — Needs Owner Confirmation

### Per-Tier Descriptions & Requirements

The habitat tier enum values (`base`, `outpost`, `settlement`, `city`, `station`) are confirmed in code (line 48 of `base_settlement.rb`). However, the following items are **unconfirmed** and require owner input:

| Item | Current Status | Source Citation |
|------|----------------|-----------------|
| Per-tier life-support requirements (what must be online before each tier) | Unconfirmed in code or docs | None found |
| Per-tier structure-count ranges (e.g., "base = 1–2 structures") | Design-intent only; not in code | [LUNA_SETTLEMENT_LIFECYCLE.md](../design/LUNA_SETTLEMENT_LIFECYCLE.md) — design document, not implementation spec |
| Per-tier construction durations & costs | Unconfirmed | No database migrations or config files found |

### Habitat Tiers Growth-Stage Definitions

| Growth Stage | Design Intent (Unconfirmed) | Source Citation |
|--------------|-----------------------------|-----------------|
| `base` → `outpost` | 1–2 structures, minimal life support | [LUNA_SETTLEMENT_LIFECYCLE.md](../design/LUNA_SETTLEMENT_LIFECYCLE.md) |
| `outpost` → `settlement` | 3–5 structures, expanded ISP, full ISRU | [LUNA_SETTLEMENT_LIFECYCLE.md](../design/LUNA_SETTLEMENT_LIFECYCLE.md) |
| `settlement` → `city` | 6–10+ structures, multi-system integration | [LUNA_SETTLEMENT_LIFECYCLE.md](../design/LUNA_SETTLEMENT_LIFECYCLE.md) |

**OPEN**: Owner confirmation needed to promote these design-intent values to implementation specs or archive them.

### Stage-Gate Rules

- **Target Pattern (Unconfirmed)**: Each tier requires its prior life-support loop to be online.
- **Source**: [LUNA_SETTLEMENT_LIFECYCLE.md](../design/LUNA_SETTLEMENT_LIFECYCLE.md) — design document only; no code enforcement found.
- **OPEN**: Is there a `adjust_settlement_type_based_on_population` method that gates tiers? Code at `base_settlement.rb` line 281 confirms the method exists and adjusts type by population, but exact thresholds are not documented.

### Namespace Split Confirmation (SpaceStation / OrbitalDepot)

See [CONFIRMED — Code State](#spacespacestation-oraldepot-namespace-split--open) above. **OPEN**: Confirm these files still exist in `git ls-files`.

---

## Model Relationships Summary

| Model | Responsibility | Confirmed Status |
|-------|---------------|-----------------|
| `Settlement::BaseSettlement` | Core admin unit; population-driven tier gating via `adjust_settlement_type_based_on_population` (line 281) | ✅ Code confirmed |
| `Structures::BaseStructure` | Physical asset (natural or artificial); subclassed for worldhouses, space stations, depots. | ✅ Standard Rails pattern; subclasses confirmed in codebase |
| `Settlement::OrbitalSettlement` | Orbital-specific behavior; replaces deprecated SpaceStation for multi-structure cases. | ✅ Code confirmed (`galaxy_game/app/models/settlement/orbital_settlement.rb`) |

---

## Harvest Log

| Date | Action | Author |
|------|--------|--------|
| 2026-10-29 | Rewritten per workflow: stripped outward GitHub links and canonical front-matter; grounded code state to live model; separated OPEN items with source citations. | Automated |
