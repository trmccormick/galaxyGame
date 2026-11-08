---
title: Infrastructure — Master Table of Contents
category: Infrastructure
status: Active Index
last_updated: 2026-11-07
---

# Infrastructure

This directory is the home for infrastructure wiki pages. It covers pre-player logistics pipelines, atmospheric harvesting, surface habitats, power options, terraforming pathways, planetary protection, modular orbital panel swarms, and related architectural references.

---

## Master Pipeline

### Pre-Player Era Logistics

The **primary pre-player pipeline narrative** is:

[`pre_player_era_logistics_pipeline.md`](./pre_player_era_logistics_pipeline.md)

This page walks the full expansion tree: Sol Core → L1 Shipyards → Mars Moon Conversion → Belt Expansion, including the Venus-Luna Sabatier volatile loop and Heavy Tug propulsion economy. Read this first to understand how off-world industry bootstraps.

### Supporting Pre-Player Docs (Linked References)

| Document | Summary |
|----------|---------|
| [`pre_player_era_logistics_architecture.md`](./pre_player_era_logistics_architecture.md) | Architecture overview — system-level view of pre-player logistics flows and service boundaries. |
| [`pre_player_era_logistics_station_construction_pipeline.md`](./pre_player_era_logistics_station_construction_pipeline.md) | Station-specific construction pipeline details (phases, gates, dependency chains). |

These files expand on the primary pipeline narrative with focused detail. They link into each other; see [Core Industrial Rules](#core-industrial-rules) for cross-cutting constraints.

---

## Atmospheric Harvesting

→ [`atmospheric_harvesting.md`](./atmospheric_harvesting.md)

Extraction economics, Earth atmosphere baseline, and Venusian-analog harvesting targets. See [Planetary Protection](#planetary-protection--environmental-governance) for environmental caps that bound extraction yields and rates.

---

## Planetary Protection & Environmental Governance

→ [`planetary_protection_environmental_governance.md`](./planetary_protection_environmental_governance.md)

Planetary protection protocols, environmental governance frameworks, and ecological compliance rules for colonization activities across celestial bodies. Governs Class-0 sanctuaries and atmospheric caps.

---

## Surface Habitats & Power

→ [`surface_habitat_options.md`](./surface_habitat_options.md)  
Design options for surface (or near-surface) habitats that become available once power, logistics, and industrial base are mature: a thought exercise on dome pressurization, oxygen setup and power.

→ [`power_options.md`](./power_options.md)  
Power generation and distribution strategies across phases (surface, orbital, deep-space). Covers solar arrays, nuclear thermal reactors, RTGs, and hybrid grids.

---

## Modular Orbital Panel Swarms

→ [`modular_orbital_panel_swarms.md`](./modular_orbital_panel_swarms.md)

Shared technology family for Venus solar-shade functions (optional / progressive) and Mars solar-reflector functions. Covers the swarm tracking model (spatial location + counts by panel type/configuration), optional additive capabilities (solar collection, hydrogen capture, energy beaming), and the local-station → service-craft → bot operations loop. Production side lives in the technical ISRU Fabrication Chain page.

---

## Artificial Magnetosphere

→ [`artificial_magnetosphere.md`](./artificial_magnetosphere.md)

L1 magnetic dipole shield design intent for Mars atmospheric retention. Consolidates recovered L1 dipole concept, 3-tier power evolution (Fusion → EM-Core → Wormhole-Stabilized), construction materials, staging, and open quantitative gaps. Prerequisite for high-throughput Venus→Mars mass-driver injection.

---

→ [`terraforming_options.md`](./terraforming_options.md)  
Planetary-scale atmosphere modification options: raw-gas pressure-first path (protection of population and infrastructure), refined Venus→Mars mass-driver pipeline (O₂/N₂ + CNT shells), and softer longer-horizon approaches (gradual Venus siphon, Titan, KBOs). Magnetosphere prerequisite applies to high-throughput injection methods.

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
```
