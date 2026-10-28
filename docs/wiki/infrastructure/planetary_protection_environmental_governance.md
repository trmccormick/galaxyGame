# Planetary Protection and Environmental Governance Specification

> **STATUS: DESIGN INTENT ONLY — TARGET DESIGN INTENT**
> This document specifies target gameplay mechanics, regulatory rules, and architectural integration hooks for StarSim, `NpcPriceCalculator`, and `AutonomousConstructionManager`. Governance caps (extraction rate limits, sanctuary blocks, quarantine requirements), policy toggles, and contamination frameworks described herein are **TARGET DESIGN INTENT ONLY** — they represent the intended simulation law and are NOT currently implemented in the codebase.

## 1. Overview & Policy Directives
The **Planetary Protection and Environmental Governance Framework** establishes physically grounded rules governing resource extraction, contamination management, and terraforming across Sol and procedural star systems within StarSim.

Rather than enforcing arbitrary background limitations, environmental governance in `galaxyGame` operates as an active, state-driven simulation layer. It directly influences market pricing (`NpcPriceCalculator`), AI construction behavior (`AutonomousConstructionManager`), cargo logistics, and research trees. These rules are **TARGET DESIGN INTENT ONLY** — no runtime enforcement code currently exists.

```
                         ASTROBIOLOGICAL LIFE DETECTION
                                       │
        ┌──────────────────────────────┼──────────────────────────────┐
        ▼                              ▼                              ▼
  CLASS 0: COMPLEX              CLASS 1: MICROBIAL             CLASS 2-4: ABIOTIC
(Multicellular/Ecosystems)    (Extremophiles/Prebiotic)      (Sterile Volatiles/Regolith)
        │                              │                              │
  100% Extraction Freeze         5% Extraction Cap /            Uncapped Industrial
  Total Settlement Ban           Bio-Harvesting & Labs          Mass & Δv Governed
  SDC Science Exclusion          BCI & Quarantine Loops         Standard Market Limits
```

---

## 2. Protection Hierarchy & Classification System

Planetary bodies are categorized into distinct Protection Classes (Class-0 through Class-4) based on astrobiological complexity and economic designation:

### Class-0: Macro/Complex Biosphere (Sanctuary World)
* **Trigger Criteria:** Detection of multicellular flora, fauna, or complex macroscopic ecosystems (`entity.has_complex_life == true`).
* **Governance Enforcement** *(TARGET DESIGN INTENT — not currently enforced in code):* Stellar Development Council (SDC) Orbital Interdiction.
* **Extraction & Settlement Rules** *(design intent only; no runtime block exists):*
  * **100% Extraction Freeze:** Commercial resource harvesting is strictly prohibited.
  * **Total Settlement Ban:** Human colonization is illegal.
  * **Science-Only Exclusion Zone:** Surface operations are limited to non-invasive orbital telemetry and authorized research probes.

### Class-1: Microbial, Prebiotic & Ice-Shell Oceans (Regulated World)
* **Trigger Criteria:** Unconfirmed/confirmed single-celled organisms, extremophiles, subsurface oceans under ice shells (e.g., Europa, Enceladus), or prebiotic organic hydrologies like Titan (`entity.has_microbial_life == true` or `entity.subsurface_ocean == true`).
* **Governance Enforcement** *(design intent — not currently enforced in code):* Regional Authorities (e.g., Titan Development Commission / TDC, SDC Local Directorate).
* **Extraction & Settlement Rules** *(TARGET DESIGN INTENT; governed by caps described in §4 below, no runtime enforcement exists):*
  * **Human Settlement Permitted:** Microbe-bearing bodies do not block colonization or habitability modules.
  * **Regulated / Capped Extraction:** Extraction is subject to body-specific caps (e.g., Titan’s 5% volatile cap) or closed-loop replacement requirements.
  * **Bio-Harvesting & Hybridization Unlocked:** Native extremophiles can be harvested and sequenced in settlement **Astrobiology Labs** to splice hyper-adaptive traits into Earth-origin flora, fauna, and bio-mining strains.
  * **Ice-Shell Precautionary Rule:** Absence of confirmed life does *not* imply sterility. Unsurveyed ice-shell oceans default to Class-1 protection pending long-term scientific survey campaigns.

### Class-2: Resource-Rich Industrial Zone
* **Trigger Criteria:** High commodity yield potential without significant ecological risk (`entity.is_abiotic == true`).
* **Rules:** Standard extraction rules apply with environmental impact assessments required.

### Class-3: Post-Terraforming Transition
* **Trigger Criteria:** Actively being terraformed but not yet self-sustaining.
* **Governance Enforcement** *(design intent only — no runtime enforcement):* Limited extraction to support ongoing operations; no commercial exploitation permitted.

### Class-4: Fully Industrialized / Abiotic Worlds
* **Trigger Criteria:** Completed terraforming or heavily modified/sterile environments, airless rocky bodies, metallic asteroids, or inorganic atmospheric layers.
* **Governance Enforcement** *(design intent only — no runtime enforcement):* Local Mining Guilds / Open Free Market.
* **Rules:** No planetary protection restrictions apply. Operations are bounded strictly by physical mass conservation, energy budgets, and delta-v constraints.

---

## 3. BCI (Bio-Contamination Incursion) Contamination Framework
Absolute sterility during deep-space operations is physically impossible. Governance mechanics focus on managing contamination risks rather than demanding zero-impact guarantees.

```
[ Unsterilized Drill / Lander ] ──► Raises Biological Containment Index (BCI) ──► Fines / License Revocation
[ Sterile Operations Budget ]   ──► Lowers BCI Risk Factor                   ──► Clears Cargo for Market
[ Raw Inbound Volatiles ]      ──► Transits Cycler Hub Quarantine Loop     ──► Deprivatizes Bio-Hazards
```

1. **Phase 1 – Pre-Deployment Screening:** Assess incoming material and equipment for biological contamination risk, enforce quarantine protocols, and set sterilization requirements.
2. **Phase 2 – Deployment Monitoring:** Track biological material introduction during active operations. Operators can allocate operational funds (**Sterilization Budgets**) for thermal sweeps, radiation baths, and sealed bio-barriers to maintain low BCI ratings.
3. **Phase 3 – Post-Contact Contamination Assessment:** Evaluate ecosystem impact. Raw volatile shipments sourced from high-risk Class-1 environments must transit through designated quarantine nodes on cycler hubs (e.g., Mars Cyclers) before clearing for open-market trade distribution.

---

## 4. Sol System Specific Governance & World Policies

### Titan (Titan Development Commission — TDC / Titan Defense Council)
* **Status:** Class-1 Prebiotic Hydrocarbon Reservoir.
* **Cap Mechanism:** Hard **5% total volatile extraction cap** relative to initial atmospheric and liquid surface mass, with a $\pm 0.1\%$ pressure tolerance threshold.
* **Closed-Loop Balance:** Managed as a closed-loop volatile reservoir. Extraction beyond baseline thresholds requires offset injections (e.g., overproduction methane or imported neutral buffers) monitored by the TDC.

### Venus (Dynamic AI Manager Policy Toggle)
Venus represents a historical pivot in Sol governance. Early terraforming projects were initiated, but when superior extra-solar targets (such as Eden) were discovered, the economic cost of Venusian terraforming led to an operational shift. Venus supports two dynamic policy states evaluated by the `AutonomousConstructionManager`:

```
                                  VENUS POLICY TOGGLE
                                           │
         ┌─────────────────────────────────┴─────────────────────────────────┐
         ▼                                                                   ▼
OPTION A: TERRAFORMING RESERVE                                   OPTION B: INDUSTRIAL POWERHOUSE
(Legacy / Strategic Reserve)                                     (Default / Uncapped Skimming)
         │                                                                   │
  • Managed N₂ Export Quotas                                      • Uncapped N₂ and CO₂ Skimming
  • 1-Bar Buffer Reserve Target                                   • Zero Hydrogen Import Requirement
  • Mandatory Hydrogen Import Credits (HICs)                      • Carbon Nanotube / Composite Production
```

* **Option A (Terraforming Reserve State):** Exports are managed against a strict **1-bar Earth-equivalent buffer target** ($\sim 4 \times 10^{18}\ \text{kg}$ $N_2$) out of its $\sim 1.68 \times 10^{19}\ \text{kg}$ total pool. Outer-system freighters delivering Hydrogen or Water-Ice earn **Hydrogen Import Credits (HICs)**, reducing export tariffs on outbound Venusian Nitrogen used for Bosch/Sabatier reduction ($CO_2 + 2H_2 \rightarrow C + 2H_2O$).
* **Option B (Pure Industrial Powerhouse — Default/Current Era):** Uncapped $N_2$ and $CO_2$ skimming operates without terraforming tariffs or HIC requirements. Skimmer fleets harvest $CO_2$ for in-situ cracking into Oxygen and solid Carbon for graphenated hulls, carbon nanotube structures, and colony life-support reserves. Human presence remains in high-altitude aerostats.

### Mars & Luna PSR
* **Mars:** Primary System Terraforming Project with protected volatile reserves and sustained atmospheric-density investments.
* **Luna PSR:** Volatile mass budgeting for cryogenic infrastructure and regolith displacement subject to SDC orbital debris limits.

---

## 5. Regulatory Caps Summary Table

| Celestial Body | Extraction Cap | Storage Allowed? | Primary Regulatory Body | Key Commodities |
| :--- | :--- | :--- | :--- | :--- |
| **Titan** | **5% Total Mass Cap** | Yes (Closed-Loop Volatile Reservoir) | TDC / SDC | Methane, Organics, Methane Injection Credits |
| **Venus** | Uncapped (Option B) / Quota (Option A) | Temporary Skim Depot | SDC | Nitrogen, Carbon Dioxide, Acid Condensates |
| **Luna (PSR)** | Volatile Budgeted | Local Cryo Storage | Earth-Luna Depot Authority | Water Ice, Electrolytic $O_2$ |

---

## 6. Technical & Code Integration Architecture

### Persistent Entity State Serialization
Planetary protection parameters serialize directly into the entity JSON definition during StarSim system instantiation:

```json
{
  "entity_id": "sol_venus",
  "planetary_protection_class": "Class_2_Industrial",
  "governance_policy": "Option_B_Industrial_Powerhouse",
  "has_microbial_life": false,
  "has_complex_life": false,
  "extraction_cap_ratio": 1.0,
  "n2_buffer_reserve_kg": 4.0e18,
  "bci_risk_index": 0.02
}
```

### Market & AI Hooks *(design intent only — no runtime hooks currently exist)*
1. **`NpcPriceCalculator`:** Reads `planetary_protection_class` and `governance_policy` to dynamically scale export tariffs, apply HIC discounts, or restrict contraband trades from interdicted Class-0/Class-1 worlds. *(TARGET DESIGN INTENT — no code currently implements this hook.)*
2. **`AutonomousConstructionManager`:** Evaluates world states when routing AI builder fleets—directing cloud skimmers to Venus under Option B, or prioritizing hydrogen processing depots and sunshades if Option A is active. *(TARGET DESIGN INTENT — no integration currently exists.)*