# Infrastructure & Logistics Architecture Index
## Pre-Player Era Logistics Pipeline & Interplanetary Architecture Specification

---

### Executive Summary

This specification establishes the deterministic physical, mechanical, and logistical framework governing the Pre-Player Era solar system infrastructure. It eliminates non-physical tropes (e.g., instant station spawning, zero-boil-off long-range transits) and enforces explicit dependencies across four primary axes:

1. **Planetary Specialization & Industrial Division of Labor**
2. **Logistics Gating & Technological Equipment Progression**
3. **Multi-Layered Operational View Hierarchy (Player & Digital Twin Systems)**
4. **Physical Station Conversion, Mass Anchoring, & Eden Snap Prevention**

---

### 1. Planetary Specialization & System-Wide Division of Labor

The solar system economy operates as a closed, highly specialized trade network. No single body operates independently; industrial output is strictly gated by thermodynamic, atmospheric, and gravity-well constraints.

```
+-----------------------------------------------------------------------------------+
|                                 MARS HUB                                          |
|                (Central Gateway / Outer-System Staging)                            |
+-----------------------------------------------------------------------------------+
       ^                                      ^                                 |
       | Ores & Metals                        | H2 & Gases                      | Inward
       |                                      |                                 v Distribution
+--------------+                       +--------------+               +-------------------+
|  MAIN BELT   |                       |    SATURN    |               |   INNER SYSTEM    |
| Ceres / 16   |                       | Titan / Gas  |               |  Earth / Luna /   |
| Psyche Hubs  |                       |  Giants Hub  |               |      Venus        |
+--------------+                       +--------------+               +-------------------+
```

#### 1.1 Earth & Luna (Precision Tech & Vacuum Manufacturing)
* **Primary Role:** R&D nucleus, precision hardware manufacturing, and early orbital assembly.
* **Outputs:** High-density avionics, quantum microelectronics, reactor control units, initial vacuum-welded structural hulls, and local lunar regolith metals/oxygen ($\text{O}_2$).
* **Key Facility:** **L1 Earth-Moon Lagrange Shipyard** — the primary deep-space vessel construction nexus.
* **Constraints:** Earth deep-well launch penalties phase out heavy raw material exports during Phase 1, restricting Earth output exclusively to high-value, low-mass technological components.

#### 1.2 Venus (The Volatile & Energy Powerhouse)
* **Primary Role:** Atmospheric volatile harvester, carbon-structure factory, and thermal energy titan.
* **Outputs:** Bulk Oxygen ($\text{O}_2$), Nitrogen ($\text{N}_2$), Carbon Nanotubes (CNTs), and synthesized Methane ($\text{CH}_4$).
* **Chemical Loop Execution:** 
  * *Carbon Dioxide Splitting:* $\text{CO}_2 \longrightarrow \text{CO} + \frac{1}{2}\text{O}_2$ (yielding massive oxidizer buffers).
  * *Sabatier Methanation Loop:* $\text{CO}_2 + 4\text{H}_2 \longrightarrow \text{CH}_4 + 2\text{H}_2\text{O}$
  * *Constraint:* Requires hydrogen ($\text{H}_2$) imports delivered from Saturn via the interplanetary cycler loop to sustain industrial-scale methanation.

#### 1.3 Mars Hub (The Outer-System Gateway)
* **Primary Role:** Staging node, orbital refinery nexus, and logistical bottleneck for outer-system resource flows.
* **Operations:** 
  * Intercepts incoming raw ore freighters from Ceres and 16 Psyche.
  * Processes and holds volatile imports from Saturn.
  * Schedules and executes inward distribution vector runs to Venus, Luna, and Low Earth Orbit (LEO).

#### 1.4 Main Belt & Saturn (Raw Material Extraction Nodes)
* **Ceres Hub:** Primary water-ice ($\text{H}_2\text{O}$) and hydration-salts extraction node for belt operations.
* **16 Psyche Node:** High-density nickel-iron ($\text{Ni}\text{-}\text{Fe}$) ore extraction and preliminary heavy-ingot forging.
* **Saturn System (Titan & Gas Giants):** Bulk volatile extraction, specializing in raw Hydrogen ($\text{H}_2$), Methane ($\text{CH}_4$), and Nitrogen ($\text{N}_2$).

---

### 2. Logistics Gating & Equipment Progression

Outer-system expansion is strictly gated by propulsion efficiency, thermal insulation, and cryogenic boil-off thermodynamics.

```
+-------------------+      Phase 2 Gate       +-------------------+      Cycler Loop      +-------------------+
|  MK1 HLT FLEET    |  -------------------->  |   L1 SHIPYARD     |  ------------------>  |  MK2/MK3 HLTs &   |
| Direct Inner-Loop |  Builds Advanced Craft  | Vacuum Fabrication|  Eliminates Boil-Off  | Deep-Space Transit|
+-------------------+                         +-------------------+                       +-------------------+
```

#### 2.1 Heavy Lift Transport (HLT) Hull Tiers

| Tier | Primary Build Site | Operational Range | Thermal & Cryo Capabilities | Max Transit Time |
| :--- | :--- | :--- | :--- | :--- |
| **MK1 HLT** | Earth / Lunar Surface | Earth $\leftrightarrow$ Luna, Luna $\leftrightarrow$ Venus | Passive thermal shielding only. Unmitigated cryogenic boil-off over extended durations. | $< 180$ days |
| **MK2 HLT** | L1 Shipyard | Inner System $\leftrightarrow$ Mars / Main Belt | Active reliquefaction loops, multi-layer insulation (MLI), dynamic solar-shade orientation. | $1.5$ years |
| **MK3 HLT** | L1 Shipyard / Mars Orbit | Mars $\leftrightarrow$ Outer System (Saturn/Titan) | Heavy magnetic shielding, full closed-loop reliquefaction, micro-meteoroid armor, extended life support. | $3.5+$ years |

#### 2.2 The Outer System Transit Trap & Cycler Solution
* **The Outer System Transit Trap:** Unmitigated long-range transport from Titan to inner-system destinations (Luna/Earth/Mars) via direct HLT routes suffers extreme volatile boil-off and structural fatigue. All outer-system cargo must route through the Mars cycler hub network—never as unmitigated point-to-point HLT runs between Saturn and inner planets.
* **The Interplanetary Cycler Network:**
  * Transport is permanently anchored to gravity-assisted, momentum-sustained cycler trajectories (`Earth <-> Mars <-> Venus` and `Mars <-> Saturn`).
  * Cyclers feature massive, heavily shielded habitats with heavy-duty reliquefaction plants that cannot be integrated into standard landing hulls.
  * MK2/MK3 HLTs act as shuttle craft, matching vectors with cyclers for orbital insertion and extraction at terminal hubs.

---

### 3. Multi-Layered UI / UX View Architecture

The system simulation operates across four distinct player-facing scales and one specialized administrative system layer.

```
+-----------------------------------------------------------------------------------+
|                         ADMIN: DIGITAL TWIN INTERFACE                             |
|    Unconstrained Global Telemetry / Terraforming Engine / AI Tuning & Stress Tests |
+-----------------------------------------------------------------------------------+
                                         |
         +-------------------------------+-------------------------------+
         |                               |                               |
         v                               v                               v
+------------------+           +-------------------+           +-------------------+
|  SIMEARTH VIEW   |           |   ORBITAL VIEW    |           | CIVILIZATION VIEW |
| System Macro UI  |           | Strategic/Fleet   |           | Regional Grid     |
+------------------+           +-------------------+           +-------------------+
                                                                         |
                                                                         v
                                                               +-------------------+
                                                               |  SETTLEMENT VIEW  |
                                                               | Micro/Base Layout |
                                                               +-------------------+
```

#### 3.1 Digital Twin Interface (Admin / System AI Layer)
* **Access Level:** System Administrator / AI Overseer.
* **Scope:** Full-system real-time physical telemetry without sensor lag or fog-of-war constraints.
* **Core Systems:**
  * *Terraforming Projections:* 50-to-500-year predictive modeling of planetary atmospheric density, $\text{CO}_2$ drawdown, surface albedo, and temperature gradients.
  * *AI Manager Controls:* Routing algorithms, NPC trade risk thresholds, and simulated supply chain stress tests.
  * *Physics Verification:* Real-time monitoring of body anchor mass ratios, thermal dissipation budgets, and structural stress tensors across all active stations.

#### 3.2 SimEarth View (Macro / System Scale)
* **Perspective:** Interactive 3D orbital mechanics overview of the solar system.
* **Focus:** Global volatile trade balance ($\text{O}_2, \text{N}_2, \text{CH}_4, \text{CO}_2, \text{H}_2\text{O}$), cycler position tracking, planetary atmospheric/magnetic statuses, and major resource bottlenecks.

#### 3.3 Orbital View (Strategic Scale — Star Control / Starcraft Style)
* **Perspective:** Local orbital sector space.
* **Focus:** L1 Shipyard construction queues, orbital ring modular upgrades, station docking approach scheduling, transit fleet navigation, and fuel depot transfers.

#### 3.4 Civilization View (Regional Scale — Civ Style)
* **Perspective:** Hex/Grid regional surface map.
* **Focus:** Overland surface logistics, mining concessions, regional power grid routing (PUH/PPMU distribution units), pipeline networks, and extraction site coverage.

#### 3.5 Settlement View (Micro Scale — SimCity Style)
* **Perspective:** Tactical ground-level isometric/3D base view.
* **Focus:** 
  * Micro base engineering, power conduit linking, and fluid loop plumbing.
  * Pad allocation (enforcing a hard maximum of 2–3 landing pads per outpost to prevent unmanageable surface dust erosion).
  * Subterranean lava tube cryogenic tank farms ($\text{LOX}, \text{LCH}_4, \text{LN}_2$).
  * Survival systems configured to sustain operations through the 708-hour lunar night.

---

### 4. Station Construction Rules & Eden Snap Prevention

To prevent catastrophic structural failure ("Eden Snap Events") during planetary repositioning and orbital conversion, strict physical rules must be enforced.

#### 4.1 Conversion Pipeline & Mass Ratios (Rule B Hollowing)
When converting a raw celestial body (asteroid/moonlet) into a usable orbital station:
* **Mass Retention:** Exactly 30% of original body mass is converted into structural hull, interior decks, and load-bearing framing.
* **Slag Generation:** 70% of extracted body mass becomes inert slag.

$$\text{Total Extracted Mass} = M_{\text{hull}} (30\%) + M_{\text{slag}} (70\%)$$

* **Slag Propulsion Rule:** Generated slag must be retained and routed to electro-magnetic mass drivers to serve as reaction mass for tug station-keeping and orbit positioning.

#### 4.2 Structural Disqualifiers
A body is disqualified from station conversion if any of the following conditions are met:
1. **Cohesion Metric:** Bulk structural density $< 1.5 \text{ g/cm}^3$ (indicates a loose rubble-pile structure).
2. **Volatile Content:** Volatile mass $> 20\%$ (causes outgassing fracturing during thermo-mechanical drilling).
3. **Internal Void Ratio:** Pre-existing structural void fraction $> 40\%$.

#### 4.3 Mass Anchoring & Eden Snap Event Constraints
An "Eden Snap Event" occurs when an anchored orbital station or converted body experiences catastrophic gravitational or mechanical decoupling due to insufficient anchor mass relative to dynamic thrust stresses.

* **Minimum Static Anchor Mass Threshold ($M_{\text{anchor}}$):**

$$M_{\text{anchor}} \ge 1.0 \times 10^{15} \text{ kg} \quad (\text{Standard Planetary Conversion})$$

$$M_{\text{anchor}} \ge 5.0 \times 10^{16} \text{ kg} \quad (\text{Asteroid World Anchor / AWS Pattern})$$

* **Enforcement:** If structural stress tensors exceed body yield strength before $M_{\text{anchor}}$ criteria are met, the body suffers structural shear, terminating the conversion process and causing an immediate Eden Snap failure mode.

---