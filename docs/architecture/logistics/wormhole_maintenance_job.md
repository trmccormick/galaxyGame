# Wormhole Maintenance Job

## Documentation

The wormhole maintenance job is responsible for calculating and applying the ongoing Exotic Matter (EM) maintenance tax for each active wormhole contract.

### Planned Logic
- The maintenance tax calculation should incorporate a lookup for the anchor_body.mass to apply the Gravity-Based Maintenance Offset (see wormhole_system.md) before the Sabatier reduction is applied.
- This ensures that contracts anchored to high-mass bodies (e.g., Jupiter-class gas giants) receive a reduced maintenance cost, while unanchored or inner-system links pay the full rate.


See also: docs/architecture/wormhole_system.md for anchor mass multipliers and offset logic.

## Sabatier Narrative

The "Sabatier Offset" represents a 40% reduction in EM maintenance tax for wormhole contracts with active local fuel production. This models the in-universe effect of on-site Sabatier reactors converting CO₂ and H₂ into methane and water, reducing the need for imported Exotic Matter. This logic was formalized in the January 2026 bug fix, ensuring that the `sabatier_offset_active` flag is properly parsed and applied.

### Calculation Order
1. **Gravity Offset:** Apply the anchor mass multiplier (see wormhole_system.md).
2. **Sabatier Reduction:** If `sabatier_offset_active` is true, apply the 40% reduction to the already-offset maintenance tax.
