# TASK: Add Admin Celestial Body Show View
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: feature  
**Created**: 2026-02-11

---

## Problem Statement
Missing or incomplete admin show view for celestial bodies, limiting admin visibility and management.

## Goals
- Design and implement show view for celestial bodies
- Ensure RSpec: expect(page).to have_content('Celestial Body')
- Commit: "feat: add admin celestial body show view"

## Acceptance Criteria
- [ ] Admin show view for celestial bodies exists and is functional
- [ ] RSpec test passes for content presence
- [ ] Feature is committed with correct message

## Implementation Notes
- Review existing admin celestial bodies views
- Add/complete show.html.erb as needed
- Validate with RSpec and UI

## Diagnostic/Debugging
- grep -n 'celestial_body' app/views/admin/celestial_bodies/

## Related Files/Paths
- app/views/admin/celestial_bodies/show.html.erb
- spec/controllers/admin/celestial_bodies_controller_spec.rb

## References
- Synthesis Report (2026-02-11)

---

