# AI Manager: Mission Planner Architecture

## 1. Core Philosophy: The "No-Magic" Protocol
The Mission Planner is a **Logistics Diagnostic Tool**. Resources and capabilities only exist if they are physically present, harvestable, or transportable via active modular assets.

## 2. Sourcing Hierarchy (The Three-Tier Check)
Every mission requirement (Materials, Units, Fuel) must be resolved through this sequence. If a tier fails or is blocked, the planner moves to the next.

| Tier | Name | Logic | Requirement |
| :--- | :--- | :--- | :--- |
| **1** | **Local ISRU** | Can the settlement harvest/process it? | Active `Robots` + `ProcessingUnits` |
| **2** | **System Trade** | Is it available at another node in-system? | Active `Tug` (HLT) + `CargoCapacity` |
| **3** | **Network Import** | Is it available via the Sol/Earth Umbilical? | `SolarSystem.connectivity_status == :connected` |

**The Hard Block:** If `connectivity_status` is `:orphaned`, Tier 3 is skipped. If Tiers 1 and 2 also return null, the project status is `BLOCKED: RESOURCE_UNAVAILABLE`.

## 3. Propulsion Physics (The "Towing Phase")
Intra-system movement and Asteroid Conversion require a propulsion-capable container.

* **Formula (SI Units):**
  $$t = \sqrt{\frac{2 \cdot d}{\frac{F}{m}}}$$
  - $t$: Time in seconds ($s$)
  - $d$: Distance in meters ($m$)
  - $F$: Total Nominal Thrust ($N$) (Sum of `nominal_thrust_kn * 1000`)
  - $m$: Total Mass ($kg$) (`Chassis.dry_mass_kg` + `Units.mass_kg` + `Inventory.mass_kg`)

## 4. Survival Gates (Life Support)
In `:orphaned` or `:distressed` systems, biological stability overrides industrial progress.

* **Runway Calculation:**
  $$HoursRemaining = \frac{Inventory['oxygen']}{Population \cdot 0.84 \text{ kg/day}}$$
* **The Gate:** If $HoursRemaining < (MissionDuration \cdot 1.2)$, the Planner flags `CRITICAL_RISK` and prioritizes an **ISRU: Oxygen** mission as a prerequisite.