# Wormhole Maintenance Job

## Documentation

The wormhole maintenance job is responsible for calculating and applying the ongoing Exotic Matter (EM) maintenance tax for each active wormhole contract.

### Planned Logic
- The maintenance tax calculation should incorporate a lookup for the anchor_body.mass to apply the Gravity-Based Maintenance Offset (see wormhole_system.md) before the Sabatier reduction is applied.
- This ensures that contracts anchored to high-mass bodies (e.g., Jupiter-class gas giants) receive a reduced maintenance cost, while unanchored or inner-system links pay the full rate.

---

See also: docs/architecture/wormhole_system.md for anchor mass multipliers and offset logic.
