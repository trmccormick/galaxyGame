# BaseCraft Model Refactor & Concern/Service Audit

## Problem Statement
The BaseCraft model contains excessive business logic, direct service calls, and concern overlap. This violates architectural boundaries and makes maintenance, testing, and future expansion difficult.

## Current Issues
- Business logic (unit/module creation, atmosphere, stats) is embedded in the model.
- Significant overlap with concerns (HasUnits, HasModules, EnergyManagement, etc.).
- Direct service calls (e.g., UnitModuleAssemblyService, Lookup services) in model methods.
- Deeply nested atmosphere/location logic.
- Validation and deployment logic not separated.
- Model is responsible for too many behaviors, reducing clarity and testability.

## Task Objectives
1. **Audit BaseCraft model for business logic, concern, and service overlap.**
2. **Move business logic to appropriate concerns or service objects.**
3. **Ensure BaseCraft only handles persistence, associations, and minimal logic.**
4. **Refactor atmosphere/location logic into dedicated concerns/services.**
5. **Clarify validation and deployment logic boundaries.**
6. **Update/merge with existing tasks if overlap is found.**
7. **Document architectural intent and refactor plan.**

## Subtasks
- [ ] Review all BaseCraft methods for concern/service overlap
- [ ] Identify business logic to move to concerns/services
- [ ] Refactor atmosphere/location logic
- [ ] Separate validation/deployment logic
- [ ] Update tests for new boundaries
- [ ] Document refactor plan and architectural boundaries
- [ ] Merge/update backlog tasks if overlap is found

## Success Criteria
- BaseCraft model is lean, focused, and maintainable
- Business logic is in concerns/services
- No duplicate or overlapping code
- All tests pass after refactor
- Documentation updated

## Notes
- Exclude monitor and grinder tasks from scope
- Align with /docs/agent architectural intent
- Review related backlog tasks for consolidation

---
**Created:** February 20, 2026
**Status:** Backlog
**Owner:** Agent/Dev Team
