# Systems Intent: Environmental Volume Management

## 1. The Worldhouse as a Neutral Vessel
A `Structures::Worldhouse` is defined strictly by its **Pressure Integrity**. It does not possess an inherent "Biome" or "Atmosphere" upon completion of the Sealing phase.

## 2. Atmospheric Optionality (The "Content" Layer)
Once a volume is sealed, the `AtmosphericProcessorService` hydrates the volume based on the **Target Profile**.

| Profile Type | Primary Purpose | Atmospheric Composition | Constraints |
| :--- | :--- | :--- | :--- |
| **Industrial/Robotic** | Foundry/Manufacturing | N2 or Vacuum-Buffered | High heat-sink requirement; 0% O2 to prevent oxidation. |
| **Pre-Terraforming** | CO2 Conversion | High CO2 / Trace Minerals | Specific humidity/temp for extremophile life (e.g., cyanobacteria). |
| **Human Habitation** | Crew Life Support | O2/N2 Mix (Standard) | Strict radiation/toxin filtration; narrow thermal band. |

## 3. Engineering Dependencies
- **The Worldhouse Seal**: Must reach 100% before any gas injection occurs.
- **The Thermal Loop**: In robotic-heavy environments (like those using the CAR-300), heat dissipation is the primary environmental constraint, not respiratory gas.
- **The Humidity Variable**: Critical for both biological growth (plants) and preventing static/corrosion in robotic foundries.

## 4. Strategic Logic
- **Precursor Alignment**: AI Managers should prioritize "Life-Form Conversion" atmospheres if the mission goal is terraforming, rather than wasting Earth-launched O2 on a space where humans haven't arrived yet.