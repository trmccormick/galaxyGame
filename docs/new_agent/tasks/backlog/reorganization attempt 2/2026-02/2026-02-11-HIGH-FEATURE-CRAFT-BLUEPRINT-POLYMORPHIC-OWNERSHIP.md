# TASK: Blueprint Polymorphic Ownership
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: feature  
**Created**: 2026-02-11

---

## Problem Statement
Blueprint model does not support polymorphic ownership, limiting flexibility for future features.

## Goals
- Implement polymorphic ownership for blueprints
- Ensure RSpec: expect(Blueprint.new(owner: Player.first)).to be_valid
- Commit: "feat: polymorphic ownership for blueprints"

## Acceptance Criteria
- [ ] Polymorphic ownership implemented for blueprints
- [ ] RSpec test passes for polymorphic owner
- [ ] Feature is committed with correct message

## Implementation Notes
- Review blueprint.rb for ownership logic
- Implement polymorphic association
- Validate with RSpec and code review

## Diagnostic/Debugging
- grep -n 'blueprint' app/models/

## Related Files/Paths
- app/models/blueprint.rb
- spec/models/blueprint_spec.rb

## References
- Synthesis Report (2026-02-11)

---

