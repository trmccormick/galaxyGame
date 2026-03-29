# Operations: Work Camp to Settlement Flow

## Phase 1: The Work Camp (Provisional)
As established in the `lunar_base_with_isru_pipeline.rake` and the `car_300_deployment_robot_mk1` blueprint:
- **Activity**: Deployment of units and 3D-printing protective regolith shells.
- **Role**: Provides radiation and micrometeoroid shielding. It is a protective "cocoon," not a primary pressure vessel.
- **Power**: Operates on a high-kilowatt industrial loop (e.g., 40kW per CAR-300 unit).

## Phase 2: Proper Construction (The Worldhouse)
Utilizes the output of the Work Camp’s ISRU pipeline (e.g., `3d_printed_ibeam`).
- **Dependency Chain**:
    1. **Bracing**: Primary structural I-beams (processed regolith/alloy) bolted into rock.
    2. **Paneling**: Installation of heavy/solar-integrated panels to the frame.
    3. **Sealing**: The final airtight transformation of the geological volume.
- **Transition**: Completion updates the `Structure` status to `covered` and `sealed`, enabling full atmospheric pressurization and biome initiation.