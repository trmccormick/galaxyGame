# Intent: Specialized Skimmer Craft (Venus & Titan)

## 1. Core Identity
Skimmers are specialized **Units** designed for deep-gravity atmospheric harvesting and high-efficiency refueling. They are defined by their ability to operate in extreme pressure/thermal environments and their dual-mode docking capability (Depot and Cycler).

## 2. Craft-Specific Roles & Processing
While independent, each skimmer carries a "Lite" version of the `AtmosphericRefineryService`.

| Craft Type | Primary Feedstock | Onboard Processing | Primary Output |
| :--- | :--- | :--- | :--- |
| **Venus Skimmer** | Raw Venusian Atmosphere | Sabatier Reactor / CO2 Scrubbing | LOX (Liquid Oxygen) |
| **Titan Skimmer** | Raw Titan Atmosphere | Methane Fractionation / H2 Separation | CH4 (Liquid Methane) |

## 3. Modular Integration (Docking Logic)
- **Active Refinement**: While docked at the **L1 Depot**, the skimmer’s onboard processors are slaved to the Depot’s `MainRefineryController`. 
- **The "Efficiency Boost"**: Docked skimmers provide a `RefineryThroughputModifier` (e.g., +15% per skimmer) to the Depot’s processing speed.
- **Power Coupling**: Skimmers draw from the Depot’s power grid during processing to preserve their internal batteries for the return descent.

## 4. Navigation & Redundancy
- **Cycler Integration**: Skimmers are configured to dock with Cyclers using the same standard docking port as the L1 Depot.
- **Surface Contingency**: If the L1 Depot is at capacity, skimmers can land at the Luna Settlement, but must operate in "Storage Only" mode as the Luna surface environment does not support the high-heat dissipation required for active skimmer-assisted refining.