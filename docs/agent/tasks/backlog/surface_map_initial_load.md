# Surface Map Initial Load Requires Refresh

## Status
Backlog — Not blocking RSpec restoration, but affects usability.

## Issue
On first load, the surface map does not render tiles until the browser is manually refreshed. This disrupts the user experience and may indicate a JavaScript load order or DOM ready issue.

## Investigation Targets
- Check JavaScript load order for surface view and tileset renderer
- Investigate DOMContentLoaded or window.onload event handling
- Review async asset loading and initialization sequence
- Confirm that all required data and assets are available before rendering starts

## Acceptance Criteria
- Surface map tiles render correctly on first load without requiring a manual refresh
- No regressions in map rendering or performance

---

**Priority:** Medium — UI polish, not blocking RSpec restoration
**Agent Assignment:** GPT-4.1 (Copilot)
**Created:** March 4, 2026
