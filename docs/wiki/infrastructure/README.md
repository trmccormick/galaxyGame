---
title: Infrastructure — Master Table of Contents
category: Infrastructure
status: Active Index
last_updated: 2026-10-28
---

# Infrastructure

This directory is the home for infrastructure wiki pages. It covers pre-player logistics pipelines, atmospheric harvesting, planetary protection, and related architectural references.

---

## Master Pipeline

### Pre-Player Era Logistics — Consolidated

All pre-player station-construction content (Sol/Luna → L1 Shipyards → Mars Moons → Belt expansion tree, Venus-Luna Sabatier loop, hard gates $\ge 50\text{ t}$ payload / $\ge 120\text{ t/day}$) is now in one canonical reference:

→ **[Station Construction Options](../engineering/station_construction_options.md)**

The former three files — `pre_player_era_logistics_pipeline.md`, `pre_player_era_logistics_architecture.md`, and `pre_player_era_logistics_station_construction_pipeline.md` — have been replaced with pointer stubs that redirect here.

---

## Atmospheric Harvesting

→ [`Atmospheric-Harvesting.md`](./Atmospheric-Harvesting.md)

Extraction economics, Earth atmosphere baseline, and Venusian-analog harvesting targets. See [Planetary Protection](#planetary-protection) for environmental caps that bound extraction yields and rates.

---

## Planetary Protection & Environmental Governance

→ [`planetary_protection_environmental_governance.md`](./planetary_protection_environmental_governance.md)

Planetary protection protocols, environmental governance frameworks, and ecological compliance rules for colonization activities across celestial bodies. Governs Class-0 sanctuaries and atmospheric caps.

---

## Settlement Infrastructure

→ [`settlement_infrastructure.md`](./settlement_infrastructure.md)

Settlement tiers (base → outpost → settlement → city/station), life support requirements, growth-stage gates, and orbital multi-structure patterns (design intent).

---

## Core Industrial Rules

1. **No Magic Spawns:** Station construction is an active, physical engineering process requiring localized or imported mass, equipment, and structural assembly time.
2. **Chemical Hard Gates:** Advanced interplanetary logistics (Phase 2+) cannot commence until the Venus-Luna Sabatier chemical loop is actively supplying Methalox ($\text{CH}_4/\text{LOX}$) to LEO/L1 fuel depots.
3. **Slag Propellant Economy:** Asteroid relocation tugs utilize the 70% waste slag generated during laser hollowing (Rule B mechanics) as reaction mass propellant (`slag_fuel_id`) for self-sustaining long-haul transit.
4. **Structural Anchoring:** Station builds around bodies without natural moons require captured, repositioned asteroids to act as physical structural anchors, preventing catastrophic failure events (e.g., the Eden Snap Event).

---

## Related Architecture References

| Resource | Purpose |
|----------|---------|
| `docs/architecture/stations/` | Station classification and component modules. |
| `docs/architecture/patterns/settlement_patterns.md` | Deterministic settlement evolution patterns. |
| `docs/architecture/asteroid_conversion_logic.md` | Hollowing rules, density thresholds, structural transformation parameters. |
| `docs/architecture/systems/asteroid_conversion_physics.md` | Physical mechanics and conversion efficiency functions. |
