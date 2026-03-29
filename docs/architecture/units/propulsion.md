# Unit Registry: Propulsion Standards

## 1. Operational Data Schema
All propulsion units must expose performance metrics within the `operational_data` block for the Mission Planner to aggregate.

**Required Schema Fields:**
* `nominal_thrust_kn`: (Float) Primary value for acceleration physics ($F$).
* `isp_seconds`: (Integer) Specific Impulse for fuel consumption math.
* `fuel_type`: (String) Must match `GameConstants::RESOURCES`.

## 2. Performance Baseline (Standard Units)

## 2. Propulsion Unit Registry (2026 Audit)
All propulsion units referenced in the Mission Planner and operational data are listed below. This registry supersedes any prior references to "Epstein Drive" (not used in this project) and clarifies that "Raptor" and "Methane" refer to the same methane/LOX engine.

| Unit ID                        | Name                                 | Nominal Thrust (kN) | Fuel Type / Input         | $I_{sp}$ (s) | Notes                                      |
|--------------------------------|--------------------------------------|---------------------|--------------------------|--------------|---------------------------------------------|
| methane_engine                 | Methane Engine                       | 2000                | Methane/LOX              | 350          | Standard chemical rocket                    |
| liquid_rocket_engine           | Liquid Rocket Engine                 | 845                 | Kerosene/LOX             | 311          | Standard chemical rocket                    |
| basic_engine                   | Basic Engine                         | 1000                | Hydrazine                | 300          | Standard for small craft                    |
| nuclear_thermal_engine         | Nuclear Thermal Propulsion Unit      | 900                 | Liquid Hydrogen          | 900          | Nuclear thermal, inner solar system         |
| fusion_drive_engine            | Fusion Drive Propulsion Unit         | 2500                | Deuterium/Helium-3        | 5000         | Advanced fusion, rapid interplanetary       |
| ion_thruster_engine            | Ion Thruster Propulsion Unit         | 0.25                | Xenon Gas                | 3000         | High-efficiency, low-thrust                 |
| electromagnetic_capture_thruster_engine | Electromagnetic Capture Thruster     | 0.1                 | Interplanetary Plasma    | 10000        | Propellantless, long-duration               |

### Notes on Naming and Lore
- **Epstein Drive**: Not present in this project. All references removed for clarity.
- **Raptor/Methane**: These are the same engine; use `methane_engine` for all operational and documentation purposes.

### Unit Descriptions
- **Methane Engine**: Standard methane/LOX rocket, high thrust, moderate efficiency.
- **Liquid Rocket Engine**: Kerosene/LOX, legacy chemical rocket, lower thrust.
- **Basic Engine**: Hydrazine monopropellant, used for small craft and maneuvering.
- **Nuclear Thermal Propulsion Unit**: Liquid hydrogen propellant, heated by nuclear reactor, for sustained inner solar system operations.
- **Fusion Drive Propulsion Unit**: Deuterium/helium-3 fusion, high thrust and efficiency for rapid interplanetary travel.
- **Ion Thruster Propulsion Unit**: Ionized xenon, extremely high efficiency, low thrust, ideal for deep space and station-keeping.
- **Electromagnetic Capture Thruster**: Uses electromagnetic fields to capture and accelerate interplanetary plasma, enabling propellantless thrust for long-duration missions. (Not to be confused with EM = Exotic Matter in wormhole mechanics.)

## 3. Mission Planner Implementation
To determine craft capability, the Service performs a `reduce` operation on the container:
`total_thrust = container.units.sum { |u| u.operational_data['performance']['nominal_thrust_kn'] || 0 }`