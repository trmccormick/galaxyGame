# 2026-05-01-HIGH-BUGFIX-CONTROLLER-SPECS-DELETE-ALL-FK-CONSTRAINT.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: BUGFIX
**Name**: Fix Controller Specs CelestialBodies Delete All FK Constraint

## Context
10 controller specs fail when before blocks call CelestialBodies::CelestialBody.delete_all due to foreign key constraint violations. delete_all bypasses ActiveRecord callbacks and FK cascade rules, causing failures when other tables reference celestial_bodies.

## Problem
Controller specs using CelestialBodies::CelestialBody.delete_all fail with PG::ForeignKeyViolation because delete_all issues raw SQL DELETE that doesn't respect foreign key constraints from locations, settlements, and other tables.

## Files
- Target: Controller spec files with failing before blocks
- Related: Database schema with celestial_bodies foreign key constraints

## Steps
1. Identify all controller specs using CelestialBodies::CelestialBody.delete_all
2. Replace delete_all with destroy_all or proper cleanup sequence
3. Ensure foreign key constraints are respected during test setup
4. Verify all 10 controller specs pass

## Acceptance Criteria
- All 10 controller specs pass without FK constraint violations
- Celestial body cleanup works properly in test setup
- No raw SQL deletes that bypass ActiveRecord constraints

## Stop Condition
- Controller specs run without foreign key constraint errors
- Test database cleanup works correctly
- All affected specs pass

## Commit
`fix: resolve FK constraints in controller specs delete_all calls`