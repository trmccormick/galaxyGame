# Dynamic Surface Liquid Coverage Calculation

## Problem
Currently, `surface_liquid_coverage` is a fixed value in the JSON and view for bodies like Earth and Titan. This does not reflect real-time or simulated environmental changes (e.g., ice melting, climate effects, seasonal variation).

## Impact
- Hydrosphere coverage is static and cannot respond to environmental changes.
- Scientific accuracy and simulation realism are limited.
- Map and sidebar display may become outdated as conditions change.

## Proposed Solution
- Implement a backend method/service to dynamically calculate `surface_liquid_coverage` based on hydrosphere state, temperature, climate, and other relevant factors.
- Update JSON generation and frontend to use this calculated value.
- Ensure coverage updates as conditions change (e.g., melting ice, rainfall, evaporation).

## Tasks
- [ ] Design algorithm for dynamic coverage calculation (Earth, Titan, other bodies)
- [ ] Integrate calculation into backend model/service
- [ ] Update JSON generation logic
- [ ] Update frontend and ERB to use dynamic value
- [ ] Test with simulated environmental changes

## Notes
- Prioritize scientific accuracy and simulation realism.
- Document edge cases (e.g., Titan's polar concentration, Earth's seasonal variation).
- Ensure backward compatibility for bodies without dynamic data.

---
This issue is documented for future backlog prioritization.
