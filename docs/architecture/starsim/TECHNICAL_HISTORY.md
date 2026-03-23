# StarSim Technical History

## Math Formulas and Algorithms

- **Radiolytic Degradation Math**: Used to "rewind the clock" on planetary resources, simulating the loss of volatiles and habitability over millions of years due to radiation exposure. (See: GROK_EXPANSION_v6.md note)
- **Thrust-to-Mass Calculation**: Referenced in Tug Operations JSON for Phobos relocation, involving AI-driven thrust/mass logic.
- **Gravity-Assist/Transit Time**: Ceres-Mars Logistical Bridge JSON defines transit times and fuel-saving paths for Belt resources.

## JSON Structures
- **Celestial Body Schema**: Includes fields like `phosphorus_availability`, `core_oxygen_index`, `Gas_Reserves`, and `Regolith-linked Gas Reserves (RLGR)`.
- **Terraforming_Phases.json**: Contains "Seed" logic for initial conditions.
- **Mars Pattern JSON**: Includes "Propellant-Excavation" logic.
- **Mars_Expansion_Logic.json**: Implements "Moon-First" mandate.
- **Mission Profiles**: Modular JSONs for each phase (e.g., mars_orbital_establishment_profile.json, mars_skimmer_deployment_phase_v1.json, etc.)

## Ruby Snippets
- No unique Ruby code found in the archives that is not already present in the current app/ folder.

## Historical Failures and Lessons
- **Noisy Output**: Previous generators produced maps with excessive randomness and lack of large-scale coherence (see references to "noisy" and "incorrect scale").
- **Incorrect Scale**: JSON and generator logic sometimes mismatched real planetary scales, leading to unrealistic gameplay.
- **Failure to Balance**: Early attempts did not use 4X-style heuristics, resulting in poor playability and resource distribution.
- **Overly Global Models**: Initial Mars settlement JSONs focused on global terraforming and atmospheric skimmers, which proved unmanageable and did not align with new "Quick Win" strategies (local compressors, aerogel panels, gas storage).
- **Lack of Weathering/Erosion**: No regression filter or erosion simulation was applied, so barren states were not convincingly derived from lush/goal states.

---

*This document synthesizes technical and design lessons from the StarSim chat archives to inform future generator improvements.*
