---
title: Infrastructure & Logistics Architecture Index
category: Infrastructure & Engineering
status: Active Index
last_updated: 2026-10-27
---

# Infrastructure & Logistics Architecture

This directory serves as the ground-truth repository for all physical engineering workflows, resource feedback loops, and deployment pipelines governing industrial expansion throughout the Sol system and beyond.

---

## 1. Primary Documentation Index

* **[`pre_player_era_logistics_pipeline.md`](./pre_player_era_logistics_pipeline.md)**
  * **Scope:** Master Pre-Player Era expansion pipeline, Sabatier volatile feedback loops, L1 shipyard bootstrapping, and heavy tug slag propulsion economics.
  * **Core Topics:**
    * Sol Launch Bottleneck & Fuel Depot Network (LEO / L1).
    * Venus-Luna Volatile Feedback Loop ($\text{CO}_2 / \text{N}_2$ skimming + Lunar PSR $\text{H}_2\text{O}$ ice $\rightarrow$ Methalox propellant).
    * Four-Phase Industrial Progression Tree (Sol Core $\rightarrow$ L1 Shipyards $\rightarrow$ Mars Moon Conversion $\rightarrow$ Belt Expansion).
    * Heavy Tug Operations & Mass-Driver Slag Propulsion Economy.

---

## 2. Core Industrial Rules

1. **No Magic Spawns:** Station construction is an active, physical engineering process requiring localized or imported mass, equipment, and structural assembly time.
2. **Chemical Hard Gates:** Advanced interplanetary logistics (Phase 2+) cannot commence until the Venus-Luna Sabatier chemical loop is actively supplying Methalox ($\text{CH}_4/\text{LOX}$) to LEO/L1 fuel depots.
3. **Slag Propellant Economy:** Asteroid relocation tugs utilize the 70% waste slag generated during laser hollowing (Rule B mechanics) as reaction mass propellant (`slag_fuel_id`) for self-sustaining long-haul transit.
4. **Structural Anchoring:** Station builds around bodies without natural moons require captured, repositioned asteroids to act as physical structural anchors, preventing catastrophic failure events (e.g., the Eden Snap Event).

---

## 3. Related Architecture References

* `docs/architecture/stations` — Station classification and component modules.
* `docs/architecture/patterns/settlement_patterns.md` — Deterministic settlement evolution patterns.
* `docs/architecture/asteroid_conversion_logic.md` — Hollowing rules, density thresholds, and structural transformation parameters.
* `docs/architecture/systems/asteroid_conversion_physics.md` — Physical mechanics and conversion efficiency functions.