# 2026-04-26-HIGH-FEATURE-JOB-SCHEMA-JSON-MIGRATION.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: FEATURE
**Name**: Refactor Manufacturing Services to use operational_data JSON for Job attributes

## Context
The Job model requires 5 mandatory fields: owner, settlement, job_type, output_type, completes_at. All dynamic job metadata must live in the operational_data JSON column, not as top-level attributes.

## Problem
Manufacturing services need to be refactored to properly use the operational_data JSON column for job attributes instead of storing metadata as top-level attributes. ComponentProductionService is almost complete but missing output_type.

## Files
- Target: `galaxy_game/app/services/manufacturing/component_production_service.rb`
- Related: Job model, MaterialProcessingService (already migrated)

## Steps
1. Update ComponentProductionService to provide all 5 mandatory Job fields
2. Add output_type: 'Component' to job creation
3. Ensure all non-column metadata is stored in operational_data JSON
4. Update specs to reference correct job structure
5. Verify all manufacturing services follow the same pattern

## Acceptance Criteria
- ComponentProductionService provides all 5 mandatory Job fields
- output_type is correctly set for component jobs
- All job metadata stored in operational_data JSON column
- Specs pass with updated job structure
- Consistent pattern across all manufacturing services

## Stop Condition
- Manufacturing services fully migrated to operational_data JSON pattern
- All job creation follows the 5 mandatory fields + JSON metadata pattern
- ComponentProductionService spec passes

## Commit
`refactor: migrate ComponentProductionService to operational_data JSON pattern`