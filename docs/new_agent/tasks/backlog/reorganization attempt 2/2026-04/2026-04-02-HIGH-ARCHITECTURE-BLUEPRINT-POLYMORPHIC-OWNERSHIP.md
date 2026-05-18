# 2026-04-02-HIGH-ARCHITECTURE-BLUEPRINT POLYMORPHIC OWNERSHIP

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Task: Blueprint Polymorphic Ownership
## Priority: High (architecture, future-proofing)

## Problem
Blueprints are currently only ownable by players (`player_id` foreign key). This is too narrow for...

---

## Original Content

# Task: Blueprint Polymorphic Ownership
## Priority: High (architecture, future-proofing)

## Problem
Blueprints are currently only ownable by players (`player_id` foreign key). This is too narrow for the intended architecture, which requires blueprints to be ownable by:
- Players (personal blueprints)
- Organizations/Corporations (shared corporate blueprints)
- Settlements (site-specific blueprints)

## Solution
- Add a polymorphic `owner` association to blueprints (`owner_type`, `owner_id` columns)
- Write a migration to add these columns and populate them from existing `player_id`
- Keep `player_id` for backwards compatibility during the transition
- Update all code and specs to use the polymorphic `owner` association
- Update `ManufacturingService` and related services to use `owner` polymorphically
- Remove `player_id` only after all code and data are migrated

## Migration Steps
1. Add `owner_type` (string) and `owner_id` (bigint) to blueprints
2. Backfill `owner_type: 'Player'`, `owner_id: player_id` for all existing blueprints
3. Update associations in Blueprint and Player models
4. Update all usages in services and specs
5. Remove `player_id` after full migration and validation

## Note
Do NOT implement until all affected services and specs are identified and a full migration plan is approved.

