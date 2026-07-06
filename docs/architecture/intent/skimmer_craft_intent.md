# Intent: Specialized Skimmer Craft (Venus & Titan)

## 1. Core Identity
Skimmers are specialized **Units** designed for deep-gravity atmospheric harvesting and high-efficiency refueling. They are defined by their ability to operate in extreme pressure/thermal environments and their dual-mode docking capability (Depot and Cycler).

## 2. Processing Model — Limited Onboard, Mostly Raw Delivery

Skimmers have **limited processing capacity** — only enough to refill their own fuel tanks. The vast majority of harvested atmospheric cargo is delivered as **raw mixed gas** to Luna for LDC processing units.

| Phase | Behavior |
| :--- | :--- |
| **In-atmosphere** | Extract raw atmosphere, begin onboard fractionation |
| **Transit** | Limited processing continues — only enough CH4 (Titan) or LOX (Venus) to refill skimmer's own fuel tanks |
| **Docked/Landed at Luna** | Skimmer adds its onboard processing capacity + storage to the base temporarily. Processing augments base refinery throughput. |
| **Departure** | Raw cargo tanks are empty — all unprocessed atmospheric gas has been offloaded to LDC facilities. Next launch window begins fresh harvest. |

### Onboard Processing (Fuel Self-Sufficiency Only)

| Craft Type | Primary Feedstock | Onboard Processing | Onboard Output |
| :--- | :--- | :--- | :--- |
| **Venus Skimmer** | Raw Venusian Atmosphere | Sabatier Reactor / CO2 Scrubbing | LOX for skimmer's own fuel tanks only |
| **Titan Skimmer** | Raw Titan Atmosphere | Methane Fractionation / H2 Separation | CH4 for skimmer's own fuel tanks only |

**Key constraint**: Onboard processing is NOT sufficient to process the full cargo load. The majority of harvested gas (CO2/N2 from Venus, CH4/N2 from Titan) is delivered raw to Luna's LDC for downstream processing.

## 3. Modular Integration (Docking Logic)

### At L1 Depot — Active Refinement Mode
- **Processing Augmentation**: While docked at the L1 Depot, the skimmer's onboard processors are slaved to the Depot's `MainRefineryController`. 
- **Throughput Boost**: Docked skimmers provide a `RefineryThroughputModifier` (e.g., +15% per skimmer) to the Depot's processing speed.
- **Storage Contribution**: Skimmer cargo tanks become temporary base storage while docked, increasing total depot capacity.
- **Power Coupling**: Skimmers draw from the Depot's power grid during processing to preserve their internal batteries for the return descent.

### At Luna Settlement — Surface Contingency Mode
- If the L1 Depot is at capacity, skimmers can land at the Luna Settlement.
- Must operate in "Storage + Processing Augment" mode — the Luna surface environment does not support high-heat dissipation required for active skimmer-assisted refining.
- Skimmer adds its onboard processing capacity and storage to the base temporarily until next launch window.
- Raw cargo tanks are fully offloaded by departure — empty tanks depart for the next harvest cycle.

## 4. Navigation & Redundancy
- **Cycler Integration**: Skimmers are configured to dock with Cyclers using the same standard docking port as the L1 Depot.
- **Surface Contingency**: If the L1 Depot is at capacity, skimmers can land at the Luna Settlement, but must operate in "Storage Only" mode as the Luna surface environment does not support the high-heat dissipation required for active skimmer-assisted refining.