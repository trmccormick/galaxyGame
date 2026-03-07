# DomeSchema ArchitectureReview
**Task ID**: DomeSchema_ArchitectureReview
**Priority**: MEDIUM
**Status**: PENDING
**Created**: March 6, 2026

## Description
Namespace fix complete: spec/models/dome_spec.rb now correctly uses Settlement::Dome
NEW BLOCKER: PG::UndefinedTable "domes" does not exist

## Architecture Questions
1. Does Settlement::Dome require dedicated "domes" table?
2. OR polymorphic settlement_domes in settlements table?
3. OR JSON attributes in BaseSettlement (capacity, occupancy)?
4. Confirm current schema: docker exec -it web RAILS_ENV=test rails dbconsole -c "SELECT * FROM domes LIMIT 1;"

## Steps
1. DIAGNOSE schema: rails db:migrate:status | grep dome
2. ARCHITECTURE REVIEW:
   - BaseSettlement polymorphic units/buildings?
   - DomeService manufacturing → Dome instances?
   - Current settlement schema design
3. DESIGN SOLUTION (migration OR model refactor)
4. DOCUMENT decision in fix_dome_model_spec_namespace.md update
5. PREPARE GPT-4.1 handoff for migration/implementation

## Dependencies
None (standalone schema design)

## Estimated Time
30 minutes

## RSpec Impact
dome_spec.rb 0/3 → 3/3 green (post-migration)

## Success Criteria
Architecture decision + migration plan

## Handoff Agent
GPT-4.1 (migration execution)

## Coordination
Perplexity (review)