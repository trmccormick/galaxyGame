# TASK: Unit Operational Data Template v1.4
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: data
**Created**: 2026-05-06
**Promote after**: Task A complete

---

## Agent Assignment
**Assigned To**: Gemini (docs/data agent)
**Why This Agent**: JSON data updates, no application code changes
**Supervision Level**: 🟡 Standard

---

## Context

Task A adds `job_types` reader methods to `BaseUnit`. This task
updates the operational data template and unit JSON files to
include the `job_types` block so the methods have data to read.

**Depends on**: Task A complete

---

## Template Change

Update `data/json-data/templates/unit_operational_data_v1.3.json`
to v1.4. Add these blocks:

**Add after `processing_capabilities`:**
```json
"job_types": {
  "_comment": "Job types this unit can process. Used by JobProcessorWorker for capacity.",
  "supported": [],
  "max_concurrent": 1
},
```

**Add to `operational_properties`:**
```json
"processing_type": ""
```

**Add `resources` block after `storage`:**
```json
"resources": {
  "stored": {},
  "consumption_rate": {},
  "production_rate": {}
},
```

**Update metadata version to 1.4 and add changelog entry.**

---

## Unit JSON Files to Update

### Fabricators → job_types: component_production
All files in:
`data/json-data/operational_data/units/production/fabricators/`

Add:
```json
"job_types": {
  "supported": ["component_production"],
  "max_concurrent": 1
}
```

### Extractors → job_types: material_processing
Files:
- `thermal_extraction_unit_mk1_data.json`
- `planetary_volatiles_extractor_mk1_data.json`
- `planetary_volatiles_extractor_mk2_data.json`
- `planetary_volatiles_extractor_mk3_data.json`

Add:
```json
"job_types": {
  "supported": ["material_processing"],
  "max_concurrent": 1
}
```

### Refineries → job_types: material_processing
All files in:
`data/json-data/operational_data/units/production/refineries/`

Add:
```json
"job_types": {
  "supported": ["material_processing"],
  "max_concurrent": 1
}
```

---

## Acceptance Criteria
- [ ] Template updated to v1.4
- [ ] All fabricator JSON files have job_types: component_production
- [ ] All extractor JSON files have job_types: material_processing
- [ ] All refinery JSON files have job_types: material_processing
- [ ] All files validate as valid JSON
- [ ] Changelog updated in template

---

## Completion Report
**Completed by**:
**Completion date**: