# 2026-05-01-HIGH-BUGFIX-MANUFACTURING-ASSEMBLY-SERVICE-UNKNOWN-JOB-ATTRIBUTES.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: BUGFIX
**Name**: Fix ManufacturingService AssemblyService Unknown Job Attributes

## Context
ManufacturingService and AssemblyService use Job.update/Job.create! with attributes that don't exist on the Job model, triggering ActiveModel::UnknownAttributeError. Services call job.update with start_date and estimated_completion which are not Job columns.

## Problem
Manufacturing and Assembly services pass unknown attributes (start_date, estimated_completion) to Job model operations. These attributes should be stored in operational_data JSON column instead of as top-level attributes.

## Files
- Target: app/services/manufacturing_service.rb, app/services/assembly_service.rb
- Related: Job model, operational_data JSON column

## Steps
1. Identify all Job.update/Job.create! calls with unknown attributes
2. Move start_date, estimated_completion, and other non-column attributes to operational_data hash
3. Ensure Job creation follows the 5 mandatory fields + JSON metadata pattern
4. Update specs to match new job structure

## Acceptance Criteria
- ManufacturingService and AssemblyService specs pass without UnknownAttributeError
- All job metadata stored in operational_data JSON column
- Job creation uses correct mandatory fields only

## Stop Condition
- All 4 spec failures resolved
- Services create jobs without unknown attribute errors
- operational_data properly populated with job metadata

## Commit
`fix: migrate ManufacturingService and AssemblyService to operational_data pattern`