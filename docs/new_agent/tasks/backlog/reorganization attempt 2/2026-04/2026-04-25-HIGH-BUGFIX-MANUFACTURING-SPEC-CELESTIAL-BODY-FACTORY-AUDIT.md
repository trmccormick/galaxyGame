# 2026-04-25-HIGH-BUGFIX-MANUFACTURING-SPEC-CELESTIAL-BODY-FACTORY-AUDIT.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: BUGFIX
**Name**: Factory Graph Audit Celestial Body Identifier Hardcoding

## Context
Manufacturing::Service specs fail during setup because create(:base_settlement) triggers identifier uniqueness collisions in its association chain. A full diagnostic traced the chain through multiple factory associations.

## Problem
Factory graph has hardcoded celestial body identifiers causing uniqueness collisions during spec setup. The create(:base_settlement) factory chain creates duplicate identifiers that violate database constraints.

## Files
- Target: Factory files in spec/factories/
- Related: BaseSettlement factory and associated celestial body factories

## Steps
1. Audit the factory graph starting from create(:base_settlement)
2. Identify hardcoded celestial body identifiers causing collisions
3. Update factories to use dynamic identifiers or sequence generators
4. Ensure DatabaseCleaner preserved tables don't conflict with factory data
5. Test that manufacturing specs can create settlements without collisions

## Acceptance Criteria
- create(:base_settlement) works without identifier collisions
- Manufacturing::Service specs pass setup phase
- Factory graph uses dynamic identifiers where needed
- No hardcoded identifier conflicts

## Stop Condition
- Factory graph audit complete
- Identifier uniqueness collisions resolved
- Manufacturing specs can run without setup failures

## Commit
`fix: resolve celestial body identifier collisions in factory graph`