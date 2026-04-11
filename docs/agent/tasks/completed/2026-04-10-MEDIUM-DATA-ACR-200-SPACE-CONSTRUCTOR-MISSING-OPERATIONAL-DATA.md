# TASK: Create ACR-200 Space Constructor Mk1 Operational Data File
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: data
**Created**: 2026-04-10
**Last Updated**: 2026-04-10

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Data file creation from template — fully specified, no inference needed
**Supervision Level**: 🔴 Watched carefully

> ⚠️ Read every section before starting. Do not infer field values —
> derive them from the blueprint file and template only.

---

## Context

`acr_200_space_constructor_mk1_bp.json` is a well-formed blueprint for the
ACR-200 Space Construction Robot Mk1. It references an operational data file
at `units/robots/construction/acr_200_space_constructor_mk1_data.json` which
does not exist on disk. This causes a silent load error when the blueprint
is accessed at runtime. It is not currently causing test failures but will
cause undefined behavior in any service that loads this unit's operational data.

Robots are units. Robot operational data files follow the canonical template
at `data/json-data/templates/robot_unit_operational_data_v1.1.json`.

---

## Problem Statement

**Current behavior**: `acr_200_space_constructor_mk1_data.json` does not exist.
Any service calling `load_unit_info` or equivalent for this unit will fail silently
or raise a missing file error.

**Expected behavior**: File exists, is valid JSON, conforms to the robot operational
data template, and accurately reflects the ACR-200's role as a space construction robot.

---

## Files Involved

### Read These First — Do Not Edit
| File | Purpose |
|---|---|
| `data/json-data/templates/robot_unit_operational_data_v1.1.json` | Canonical template — follow this structure exactly |
| `data/json-data/operational_data/units/robots/construction/acr_200_space_constructor_mk1_bp.json` | Blueprint — derive unit identity, role, and stats from here |

### Find a Comparable Reference
```bash
ls data/json-data/operational_data/units/robots/
```
Read one existing robot `_data.json` file as a concrete example of a
filled-out template. Use it to understand expected field values and ranges.
Do not copy values — use it for structure reference only.

### Output File — Create This
| File | Purpose |
|---|---|
| `data/json-data/operational_data/units/robots/construction/acr_200_space_constructor_mk1_data.json` | New operational data file to create |

---

## Implementation Steps

> Follow these steps exactly in order.

### Step 1 — Read the template
```bash
cat data/json-data/templates/robot_unit_operational_data_v1.1.json
```
Note every required field and its expected type.

### Step 2 — Read the blueprint
```bash
cat data/json-data/operational_data/units/robots/construction/acr_200_space_constructor_mk1_bp.json
```
Extract: unit name, role, capabilities, power requirements, mass, any
stats that map to operational data fields.

### Step 3 — Find a comparable robot data file
```bash
ls data/json-data/operational_data/units/robots/
```
Read one existing `_data.json` from a comparable robot. Note field
structure and value ranges. Do not copy values.

### Step 4 — Produce a Synthesis Report and STOP
Before creating the file, produce this report and wait for approval:

```
TEMPLATE FIELDS IDENTIFIED
[list every field from the template]

BLUEPRINT VALUES MAPPED
[list every field you will populate and where the value comes from]

FIELDS REQUIRING JUDGMENT
[list any fields not derivable from blueprint — state your proposed value and reasoning]

REFERENCE ROBOT USED
[filename of the comparable robot you read]

READY TO CREATE? — waiting for approval
```

### Step 5 — Create the file (after approval only)
Write the file to:
`data/json-data/operational_data/units/robots/construction/acr_200_space_constructor_mk1_data.json`

No comments, no placeholder text, no trailing commas. Valid JSON only.

### Step 6 — Validate
```bash
python3 -c "import json; json.load(open('data/json-data/operational_data/units/robots/construction/acr_200_space_constructor_mk1_data.json'))"
```
Expected result: no output, no errors. If validation fails, fix and re-validate before reporting back.

### Step 7 — Commit from host
```bash
git add data/json-data/operational_data/units/robots/construction/acr_200_space_constructor_mk1_data.json
git commit -m "data: add acr_200_space_constructor_mk1_data.json — missing operational data file"
git push
```

---

## Acceptance Criteria
- [ ] File exists at correct path
- [ ] Valid JSON — python3 validation passes with no errors
- [ ] All required template fields present
- [ ] Values derived from blueprint, not invented
- [ ] Committed from host with descriptive message

---

## Stop Conditions — escalate to user immediately if:
- Template has required fields that have no corresponding data in the blueprint
  and no reasonable default exists
- A comparable robot data file cannot be found in the robots directory
- Validation fails after two attempts to fix

---

## Dependencies
**Blocked by**: none
**Blocks**: any service that calls load_unit_info for this unit
**Related tasks**: none

---

## Notes
- `data/` is gitignored and Docker-mounted. The file lives on the host at
  `data/json-data/operational_data/units/robots/construction/`.
- Inside the container it resolves to `/home/galaxy_game/app/data/`.
- Do not run RSpec for this task — it is not currently causing test failures.
  Validation is JSON-only.
