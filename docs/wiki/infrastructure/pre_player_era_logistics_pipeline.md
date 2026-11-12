# Pre-Player Era Logistics Pipeline

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-03  
> *Audit Summary:* Expanded specification covering autonomous trade corridors, bootstrapping mechanics for unstaffed resource nodes and extraction fleets, transit decay / delta-v expenditure equations, and depot warehousing. Code implementation pending or unverified as of audit baseline.

In the Pre-Player Era, humanity lacks pre-existing deep-space cyclers or heavy tugs. All expansion boots-strap organically from Earth, Luna, and Venus through a strict, deterministic dependency chain. This document specifies backend simulation systems: mass-balance equations, autonomous route scheduling, and transit logistics that operate prior to player intervention.

> **Cross-link:** For the downstream ISRU fabrication chain that consumes pre-player-deployed structural materials and propellant, see **[ISRU Fabrication Chain](../technical/isru_fabrication_chain.md)**.  
> **Cross-link:** Atmospheric composition targets and extraction-rate ceilings are governed by **[Atmospheric Harvesting](atmospheric_harvesting.md)**, which constrains all Venusian-skim and Titan-atm-harvest yield equations used throughout this document.  
> **Cross-link:** All planetary extraction operations, including pre-player unstaffed nodes, must respect the caps defined in **[Planetary Protection & Environmental Governance](planetary_protection_environmental_governance.md)**.

---

## 1. Core Engineering Constraints

* **Construction vs. Operation:** Building a station requires localized or imported mass, heavy equipment, and dedicated staging phases. Stations cannot be "spawned" or instantly toggled into existence.
* **The Sol Launch Bottleneck:** Ships departing Earth's gravity well face extreme mass-penalty constraints. To eliminate the need for outbound craft to carry Earth-ascent fuel overhead, orbital fuel depots must be prioritized.
* **The Venus-Luna Chemical Feedback Loop:** 
  * Luna provides structural silicates, metals, and water ice ($\text{H}_2\text{O}$) in its Permanently Shadowed Regions (PSRs), but lacks carbon and nitrogen.
  * Venusian atmospheric skimming provides Carbon Dioxide ($\text{CO}_2$) and Nitrogen ($\text{N}_2$).
  * Combining Venusian $\text{CO}_2$ with Lunar $\text{H}_2$ via the Sabatier reaction ($\text{CO}_2 + 4\text{H}_2 \rightarrow \text{CH}_4 + 2\text{H}_2\text{O}$) synthesizes **Methalox ($\text{CH}_4/\text{LOX}$) propellant** for the Heavy Lift Transport (HLT) fleet and provides nitrogen/oxygen breathing mixes for habitats.

---

## 2. Pre-Player Era Sequential Expansion Tree

### Phase 1: Sol Core & Luna Industrial Bootstrapping
* **Heavy Lift Transports (HLTs):** Early starship-type craft handle initial lifts from Earth to Low Earth Orbit (LEO) and Luna.
* **Luna Surface Industry:** Primary mining and refining of structural materials and PSR water ice.
* **Venus Skimmers:** Early HLT skimmer variants harvest atmospheric $\text{CO}_2$ and $\text{N}_2$.
* **Fuel & Life Support Production:** Lunar refineries process imported Venusian volatiles and PSR ice into Methalox fuel and life-support gases.
* **Depot Network:** Construction of LEO and Earth L1 fuel depots to service outbound HLT fleets.

### Phase 2: Earth L1 Shipyards & Fleet Scaling
* **L1 Shipyard Construction:** Built as pure orbital installations using Luna-sourced raw materials and serviced by the L1 fuel depots.
* **Capital Craft Manufacturing:** L1 shipyards provide the industrial capacity to construct specialized **Heavy Tugs** and deep-space **Cyclers**.

### Phase 3: Mars Moon Conversion
* **Tug Operations:** Heavy tugs manufactured at L1 deploy to the Martian system.
* **Moon Hollowing:** A later heavy tug class captures, repositions, and progressively hollows out Phobos and Deimos, establishing the template for planetary-anchored stations and deep-space logistics hubs. (Mk-I tugs support in-place conversion with station-keeping capability only.)

### Phase 4: Belt Expansion & Asteroid Repositioning
* **Belt Operations:** Heavy tugs move into the Asteroid Belt to capture and route raw asteroids.
* **No-Moon Structural Anchoring:** Asteroids are repositioned into orbit around moonless bodies (such as Venus, Eden, and System B) to act as physical structural anchors for permanent AWS/WS stations.
* **Cycler Network Lock:** Regular cycler transit routes become fully operational, finalizing the pre-player infrastructure network.

---

## 3. Automated Trade Corridors & Cycler Route Scheduling

Prior to player intervention, autonomous trade corridors execute continuous mass transfers between source nodes (Luna, Venusian skimmers, Belt asteroids) and destination depots (LEO, L1, Mars-orbit hubs) on fixed orbital schedules. The simulation resolves these routes through an internal **CyclerRouteScheduler** backend that computes departure windows, transit durations, and cargo manifests at each simulation tick.

> **Grounding Note:** All corridor repeat periods, transfer efficiencies, and orbital parameters in this section are **[PROPOSED / PLACEHOLDER]** estimates derived from standard orbital mechanics (Hohmann transfers, delta-v budgets, synodic periods). They have not been validated against game constants or architecture specs. The section describes the intended design framework rather than game-canonical values.

### 3.1 Orbital Cycler Topology

Each corridor links two bodies via a Hohmann or patched-conic transfer orbit with a configurable repeat period $T_{\text{cycle}}$. Corridor class defines the tug class assigned:

| Corridor Class | Source | Destination | Tug Class | Repeat Period (typical) | Grounding |
|---|---|---|---|---|---|
| Core-Sol-1 | Earth LEO | Luna | HLT-Mk-I | 73 h | **[PROPOSED / PLACEHOLDER]** — Hohmann transfer period from LEO to Luna; derived from orbital mechanics, not game constants |
| Core-Sol-2 | LEO | Venus Skim Depot | HLT-Mk-II | 584 h | **[PROPOSED / PLACEHOLDER]** — Earth-Venus Hohmann transfer period; derived from orbital mechanics |
| Deep-Luna-1 | Lunar Surface | L1 Fuel Depot | Heavy-Tug Mk-I | 14 d | **[PROPOSED / PLACEHOLDER]** — Luna-L1 transfer period estimate; not game-validated |
| Mars-Shot-1 | L1 Fuel Depot | Phobos Transfer Orbit | Heavy-Tug Mk-III | 26 mo | **[PROPOSED / PLACEHOLDER]** — Earth-Mars synodic period Hohmann transfer; derived from orbital mechanics |
| Belt-Raid-1 | Main Belt Capture Point | Eden System Anchor | Heavy-Tug Mk-V | ~3.2 yr | **[PROPOSED / PLACEHOLDER]** — inner-belt to outer-system transfer period estimate; not game-validated |

### 3.2 Departure Window Resolution

A departure window $W_i$ for corridor $C$ opens when:

$$
\Delta\theta(t) = \left| \lambda_{\text{dep}}(t) - \lambda_{\text{arr}}(t) - \Delta\theta_{\text{Hohmann}} \right| < \epsilon_{\text{window}}
$$

where $\lambda$ is the body's ephemeris longitude, $\Delta\theta_{\text{Hohmann}} = n \cdot \Delta t_{\text{transit}} / 2$ (with $n$ revolutions), and $\epsilon_{\text{window}}$ is the phasing tolerance (design-baseline: 0.5°) — **[PROPOSED / PLACEHOLDER]** phasing tolerance derived from orbital mechanics; not game-validated.

### 3.3 Autonomous Manifest Scheduling

The **AutonomousManifestResolver** assigns cargo to each scheduled departure in reverse-priority order:

1. Propellant (Methalox) — highest priority, enables all subsequent transit
2. Structural silicates and refined metals
3. Biosphere seed stock and PSR-derived water
4. Volatile synthetics (NH₃, CH₄ from Sabatier off-gas)
5. Spare components for station construction

No player-facing interface governs these assignments; manifests resolve via a greedy knapsack solver constrained by tug $I_{\text{sp}}$, dry mass $m_d$, and departure window width.

---

## 4. Bootstrapping Mechanics

Unstaffed resource nodes deploy autonomously during the pre-player era, scaling extraction capacity from zero toward an asymptotic design throughput defined by infrastructure availability.

> **Grounding Note:** All numerical coefficients, thresholds, and rate equations in this section (deployment efficiency $\alpha_k$, attrition rate $\lambda_k$, scaling exponent $\beta_k$, fill thresholds) are **[PROPOSED / PLACEHOLDER]** values derived from economic bootstrap modeling and logistics simulation frameworks. They have not been validated against game constants or architecture specs.

### 4.1 Unstaffed Resource Node Deployment

Each unstaffed node type deploys at a rate $\dot{N}_{\text{deploy}}$ governed by upstream material availability:

$$
\dot{N}_{\text{deploy},\,k}(t) = \alpha_k \cdot \min_j \left( \frac{M_{\text{avail},\,j}(t)}{m_{\text{per-node},\,k,\,j}} \right) \cdot e^{-\lambda_k t}
$$

* $k$: node class (Luna-Miner Mk-I, Venus-Skim-Vessel, Belt-Capture-Barge)
* $\alpha_k$: deployment efficiency coefficient
* $j$: upstream resource index (Methalox, silicates, PSR-water)
* $m_{\text{per-node},\,k,\,j}$: mass of resource $j$ consumed per node $k$ deployment
* $\lambda_k$: attrition / failure rate for early node deployments

### 4.2 Automated Extraction Fleet Dynamics

Extraction fleet throughput at node $k$ evolves as:

$$
Y_k(t) = Y_{\text{design},\,k} \cdot \left( 1 - e^{-\beta_k \cdot N_{\text{deployed},\,k}(t)} \right) \cdot \eta_{\text{infrastructure},\,k}(t)
$$

* $Y_{\text{design},\,k}$: design-baseline throughput for node type $k$ (kg/s)
* $\beta_k$: scaling exponent for fleet density effects
* $\eta_{\text{infrastructure},\,k}(t)$: infrastructure availability ratio (0–1), reflecting upstream depot fill states and tug fleet health

### 4.3 Autonomous Depot Warehousing

Each depot maintains a fill level $F_d(t)$ updated per tick by incoming cargo minus outbound dispatch:

$$
F_d(t+\Delta t) = F_d(t) + \sum_{\text{in}} \frac{Q_{\text{cargo},\,\text{in}}(t)}{\rho_{\text{resource}}} - \sum_{\text{out}} \frac{Q_{\text{dispatch},\,\text{out}}(t)}{\rho_{\text{resource}}}
$$

Depots trigger autonomous restock requests when $F_d < F_{\text{threshold}}$ and issue cargo manifests to the **AutonomousManifestResolver** (Section 3). Design-baseline fill thresholds:

| Depot Location | Propellant Threshold | Structural Threshold | Biosphere Seed Threshold | Grounding |
|---|---|---|---|---|
| LEO | 60% | 40% | — | **[PROPOSED / PLACEHOLDER]** — depot restock thresholds from logistics simulation baseline; not game-validated |
| Earth L1 | 80% | 50% | 30% | **[PROPOSED / PLACEHOLDER]** — L1 depot thresholds; derived from mission reserve practices |
| Lunar Surface Depot | 70% | 60% | 20% | **[PROPOSED / PLACEHOLDER]** — Luna depot thresholds; not game-validated |
| Mars Transfer Hub | 75% | 55% | 40% | **[PROPOSED / PLACEHOLDER]** — Mars hub thresholds; not game-validated |

---

## 5. Systemic Cargo Loss, Transit Decay & Delta-V Budgeting

Transit between nodes is subject to deterministic mass-loss mechanisms that the simulation resolves as fractional depletion of each dispatched cargo parcel.

### 5.1 Transit Decay Model

Cargo mass $m_c$ arriving at destination after transit time $\Delta t_{\text{transit}}$:

$$
m_c(t+\Delta t_{\text{transit}}) = m_c(t) \cdot e^{-\delta \cdot \Delta t_{\text{transit}}} \cdot (1 - \lambda_{\text{loss}})
$$

* $\delta$: continuous transit-decay rate (design-baseline: 10⁻⁶ s⁻¹ for volatile losses, 0 for structural mass) — **[PROPOSED / PLACEHOLDER]** decay rate estimate; not game-validated
* $\lambda_{\text{loss}}$: one-time transit loss fraction per corridor segment (e.g., docking error, cargo-handling spill) — **[PROPOSED / PLACEHOLDER]** loss fraction estimate; not game-validated

### 5.2 Delta-V Expenditure Formula

Each tug leg consumes propellant governed by the Tsiolkovsky equation:

$$
\Delta v = I_{\text{sp}} \cdot g_0 \cdot \ln\left(\frac{m_{\text{wet}}}{m_{\text{dry}}}\right)
$$

Available delta-v margin for leg $\ell$ on corridor $C$:

$$
\Delta v_{\text{margin},\,\ell} = \Delta v_{\text{capable}} - \left( \sum_{i=1}^{n_{\text{burn}}} \Delta v_{\text{burn},\,i} + \Delta v_{\text{target-insertion}} + \Delta v_{\text{budget-reserve}} \right)
$$

* $\Delta v_{\text{capable}}$: tug class maximum delta-v (design-baseline values by tug Mk-class in the tug-class configuration table) — **[PROPOSED / PLACEHOLDER]** derived from spacecraft propulsion design; not game-validated
* $\Delta v_{\text{burn},\,i}$: individual impulse burn on leg $\ell$ (transit-phase, correction, insertion) — **[PROPOSED / PLACEHOLDER]** burn estimate; not game-validated
* $\Delta v_{\text{target-insertion}}$: target-body capture / orbital insertion burn — **[PROPOSED / PLACEHOLDER]** insertion delta-v estimate; not game-validated
* $\Delta v_{\text{budget-reserve}}$: contingency reserve (design-baseline: 15% of total budgeted $\Delta v$) — **[PROPOSED / PLACEHOLDER]** reserve margin standard; not game-validated

### 5.3 Transfer Efficiency Metric

Round-trip transfer efficiency for corridor $C$ with $N_s$ segments and per-segment loss $\lambda_i$:

$$
\eta_{\text{transfer},\,C} = \frac{\sum_{k=1}^{N_{\text{roundtrips}}} m_{\text{arrived},\,k}}{\sum_{k=1}^{N_{\text{roundtrips}}} m_{\text{dispatched},\,k}} = \prod_{i=1}^{N_s} (1 - \lambda_i)
$$

Design-baseline transfer efficiencies by corridor class:

| Corridor Class | One-Way $\eta_{\text{transfer}}$ | Round-Trip $\eta_{\text{transfer}}^2$ | Grounding |
|---|---|---|---|
| Core-Sol-1 (LEO → Luna) | 0.96 | 0.922 | **[PROPOSED / PLACEHOLDER]** — transfer efficiency estimate from cargo loss models; not game-validated |
| Core-Sol-2 (LEO → Venus) | 0.94 | 0.884 | **[PROPOSED / PLACEHOLDER]** — Venus corridor efficiency; not game-validated |
| Deep-Luna-1 (Lunar Surface → L1) | 0.97 | 0.941 | **[PROPOSED / PLACEHOLDER]** — Luna-L1 efficiency estimate; not game-validated |
| Mars-Shot-1 (L1 → Phobos TOI) | 0.91 | 0.828 | **[PROPOSED / PLACEHOLDER]** — Mars corridor efficiency; not game-validated |
| Belt-Raid-1 (Belt → Eden Anchor) | 0.88 | 0.774 | **[PROPOSED / PLACEHOLDER]** — belt-to-outer-system efficiency; not game-validated |

### 5.4 Delta-V Gating of Corridor Availability

A corridor $C$ becomes transit-available at the earliest tick where all required tug class capacities satisfy:

$$
\Delta v_{\text{margin},\,C} \geq \Delta v_{\text{mission-min}} + \Delta v_{\text{budget-reserve}}
$$

If this condition is not met (e.g., insufficient depot fill state for propellant resupply), the corridor remains **idle** in the simulation and does not generate cargo inflow or manifest scheduling events.

---

## 6. Cross-Reference & Governance Summary

| Specification | Relation to This Pipeline |
|---|---|
| [ISRU Fabrication Chain](../technical/isru_fabrication_chain.md) | Downstream consumer of pre-player-deployed structural materials and propellant |
| [Atmospheric Harvesting](atmospheric_harvesting.md) | Source for Venusian skimming yield equations used in Section 4 |
| [Planetary Protection & Environmental Governance](planetary_protection_environmental_governance.md) | Caps on all pre-player extraction, including unstaffed node deployment ceilings |

---

*Last updated: 2026-11-03 — pipeline expanded with trade corridors (Section 3), bootstrapping mechanics (Section 4), transit decay / delta-v equations (Section 5)*