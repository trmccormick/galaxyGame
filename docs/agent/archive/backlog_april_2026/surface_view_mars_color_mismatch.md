# Surface View Mars Color Mismatch

## Status
Backlog — Not blocking RSpec restoration, but affects UI polish.

## Issue
Mars surface view renders as grey instead of the expected rust red shown in the monitor view. This creates a visual inconsistency and may confuse users comparing the two interfaces.

## Investigation Targets
- Compare biome color data pipeline between monitor view and surface view renderer
- Check if surface view is using the correct color mapping for Mars (iron-rich/rust worlds)
- Validate that surface view receives and applies the `surface_color_hint` or equivalent metadata
- Confirm that monitor and surface view use the same biome/color logic

## Acceptance Criteria
- Mars surface view matches the rust red color of the monitor view
- Color mapping is consistent for all iron-rich worlds
- No regressions in other planet rendering

---

**Priority:** Medium — UI polish, not blocking RSpec restoration
**Agent Assignment:** GPT-4.1 (Copilot)
**Created:** March 4, 2026
