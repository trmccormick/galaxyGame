# Intent: Worldhouse Structural Model

## 1. Core Definition
A `Structures::Worldhouse` is a **Pressurized Geological Volume**. It is a permanent transformation of a natural feature (lava tube, canyon, crater). 

## 2. Functional Rules
- **Neutrality**: The Worldhouse is an environmental "vessel." It does not have a mandatory "human-breathable" atmosphere. It is defined by its **Pressure Seal**, not its gas composition.
- **Not a Unit**: Unlike Inflatables or Robots, a Worldhouse cannot be "purchased" or "deployed." It must be **constructed** in-situ using refined materials.
- **Atmospheric Optionality**: Once sealed, the volume is hydrated via the `AtmosphericProcessorService` based on the mission need (e.g., Industrial/Vacuum, Terraforming/CO2, or Human/O2).

## 3. The Structural Dependency Chain
Construction logic must strictly follow this sequence:
1. **Bracing**: Primary load-bearing I-beams (`3d_printed_ibeam`) bolted to the geology.
2. **Paneling**: Attachment of shielding or solar-integrated panels to the bracing.
3. **Sealing**: The final airtight closure of the volume.