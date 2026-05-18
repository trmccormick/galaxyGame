# 2026-05-06-MEDIUM-DATA-UNIT-OPERATIONAL-DATA-TEMPLATE-V14.md

**Agent**: 0.33x
**Priority**: MEDIUM
**Type**: DATA
**Name**: Unit Operational Data Template v1.4

## Context
Task A adds `job_types` reader methods to `BaseUnit`. This task updates the operational data template and unit JSON files to include the `job_types` block so the methods have data to read.

## Problem
The unit operational data template needs to be updated to version 1.4 to include job_types configuration for the JobProcessorWorker capacity system.

## Files
- Target: `data/json-data/templates/unit_operational_data_v1.3.json` (update to v1.4)
- Related: Unit JSON files that use this template

## Steps
1. Update unit_operational_data_v1.3.json to v1.4
2. Add job_types block after processing_capabilities
3. Add processing_type to operational_properties
4. Add resources block after storage
5. Update unit JSON files to include the new fields

## Acceptance Criteria
- Template updated to v1.4 with job_types configuration
- Unit JSON files include job_types and resources blocks
- BaseUnit job_types reader methods have data to read
- Template follows existing JSON structure conventions

## Stop Condition
- Unit operational data template v1.4 is complete
- All unit JSON files updated with new fields
- JobProcessorWorker can read job capacity data

## Commit
`data: update unit operational data template to v1.4`