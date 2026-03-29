# Logic: Shipyard Generational Progression

## 1. Generation 0: The HLT Era (Pre-Shipyard)
- **Primary Chassis**: `heavy_lift_transport` (The universal HLT frame).
- **Source**: Earth-Launch / Initial Manifest (USD Funded).
- **Architecture**: Must remain aerodynamic and structurally optimized for Earth-to-Orbit launch and potential atmospheric entry (Venus/Titan).
- **Role**: This is the "Standard Craft" used for all precursor missions until the L1 Station is operational.

## 2. Generation 1: Station-Built Vessels (Post-L1)
- **Source**: L1 Depot Shipyard (GCC Funded).
- **Manufacturing**: 70% Lunar Materials (I-Beams, Panels) + 30% Earth-imported Tier 3 Electronics.
- **Design Freedom**: These vessels are built in microgravity. They are **non-aerodynamic** and can exceed the mass/volume constraints of the HLT frame by an order of magnitude.
- **The Transition**: Once the L1 Shipyard is online, the HLT frame becomes a "ferry" or "feeder" rather than the primary long-haul vessel.

## 3. Infrastructure Requirements
To transition from "Variant Fitting" (HLT) to "Full Construction" (Station-Class), the L1 Settlement must have:
- **Installed Unit**: `automated_assembly_rig_mk1` (or equivalent Shipyard Module).
- **Power Surplus**: A dedicated processing bus to handle the high energy cost of welding/joining structural I-beams.
- **Resource Buffer**: Minimum stock of `3d_printed_ibeam` and `advanced_composites` stored in the Depot inventory.

## 4. Simulation Rule
- **Build vs. Buy**: HLT variants can be "purchased" via Earth manifest. Station-Class ships must be "built" using the `ConstructionJob` logic at a qualified shipyard.