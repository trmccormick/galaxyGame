# Core Architecture: Modular Containers

## 1. The Universal Container (Chassis / Structure / Node)
All physical entities (Settlements, Tugs, Skimmers, Industrial Hubs) are **Containers**. They provide the physical framework but no innate capabilities.

* **Attributes**: `dry_mass_kg`, `power_grid_capacity_kw`, `thermal_load_max`.
* **Slots**: Standardized sockets for Units, Rigs, and Modules.

## 2. Global Capability Summation
A Container’s performance is the dynamic sum of its installed components.

| Capability | Logic | Requirement |
| :--- | :--- | :--- |
| **Thrust** | `sum(units.nominal_thrust_kn)` | Propulsion Slots |
| **Life Support** | `sum(units.o2_output_kg_day)` | Utility/Habitat Slots |
| **Storage** | `sum(units.m3_capacity)` | Cargo/Storage Slots |

## 3. Modular Interaction (Cannibalization)
Because capabilities are tied to units in sockets, the Mission Planner can resolve resource gaps by suggesting part transfers between containers (e.g., moving an engine from a Skimmer to an HLT).