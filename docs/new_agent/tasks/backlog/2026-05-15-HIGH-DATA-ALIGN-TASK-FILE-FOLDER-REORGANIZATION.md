# TASK: Align Task File Folder Organization by Date Prefix
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: data  
**Created**: 2026-05-15  
**Last Updated**: 2026-05-15  

---

## Agent Assignment

**Assigned To**: GPT-4.1 (0x depth)  
**Why This Agent**: Straightforward file reorganization, no architectural decisions needed, systematic execution required  
**Supervision Level**: Watched carefully (all file moves must be intentional)  

---

## Context

During a Time Machine restore operation (May 15, 2026), 112 deleted task files were recovered from `/docs/new_agent/tasks/backlog/2026-02/` folder. The restore operation successfully returned 110 files, but the files were not organized by their date prefixes. Files were restored to 2026-02 folder regardless of whether their filenames indicated they should be in 2026-04, 2026-05, or other month folders.

**File Organization Standard**:
- Files are named: `YYYY-MM-DD-PRIORITY-TYPE-DESCRIPTIVE-NAME.md`
- Files must be stored in: `/docs/new_agent/tasks/backlog/YYYY-MM/` matching the date prefix
- Example: `2026-05-01-HIGH-BUGFIX-CONTROLLER-SPECS.md` must be in `/2026-05/` folder

**Current Problem**:
- 110 files restored to 2026-02 folder contain mixed date prefixes
- 102 files have correct 2026-02 prefix (should stay in 2026-02)
- 2 files have 2026-04 prefix (should move to 2026-04)
- 6 files have 2026-05 prefix (should move to 2026-05)
- Total: 8 files are misplaced and need to be moved

All files are already committed to git in their current (incorrect) locations.

**Relevant Architecture Docs**: None (this is file organization, not code architecture)

---

## Problem Statement

The `docs/new_agent/tasks/backlog/` folder structure has misplaced files that don't match their date prefixes. A restore operation placed all 110 recovered files into the 2026-02 folder regardless of their actual dates.

**Current state**:
```
/docs/new_agent/tasks/backlog/
├── 2026-02/    (110 files, but 8 have wrong dates)
├── 2026-03/    (31 files)
├── 2026-04/    (366 files - missing 2 files)
└── 2026-05/    (1 file - missing 6 files)
```

**Expected state after reorganization**:
```
/docs/new_agent/tasks/backlog/
├── 2026-02/    (102 files with 2026-02-XX prefix)
├── 2026-03/    (31 files)
├── 2026-04/    (368 files including 2 moved from 2026-02)
└── 2026-05/    (7 files including 6 moved from 2026-02)
```

---

## Files Involved

### Misplaced Files — these MUST be moved

#### 2 files in 2026-02 that belong in 2026-04:
1. `2026-04-25-HIGH-BUGFIX-MANUFACTURING-SPEC-CELESTIAL-BODY-FACTORY-AUDIT.md`
   - Current: `docs/new_agent/tasks/backlog/2026-02/`
   - Target: `docs/new_agent/tasks/backlog/2026-04/`

2. `2026-04-26-HIGH-FEATURE-JOB-SCHEMA-JSON-MIGRATION.md`
   - Current: `docs/new_agent/tasks/backlog/2026-02/`
   - Target: `docs/new_agent/tasks/backlog/2026-04/`

#### 6 files in 2026-02 that belong in 2026-05:
1. `2026-05-01-HIGH-BUGFIX-CONTROLLER-SPECS-DELETE-ALL-FK-CONSTRAINT.md`
   - Current: `docs/new_agent/tasks/backlog/2026-02/`
   - Target: `docs/new_agent/tasks/backlog/2026-05/`

2. `2026-05-01-HIGH-BUGFIX-JOB-PROCESSOR-WORKER-SPEC-FAILURES.md`
   - Current: `docs/new_agent/tasks/backlog/2026-02/`
   - Target: `docs/new_agent/tasks/backlog/2026-05/`

3. `2026-05-01-HIGH-BUGFIX-MANUFACTURING-ASSEMBLY-SERVICE-UNKNOWN-JOB-ATTRIBUTES.md`
   - Current: `docs/new_agent/tasks/backlog/2026-02/`
   - Target: `docs/new_agent/tasks/backlog/2026-05/`

4. `2026-05-03-MEDIUM-DOCUMENTATION-DEPLOYMENT-PATTERN-AND-OPERATIONS.md`
   - Current: `docs/new_agent/tasks/backlog/2026-02/`
   - Target: `docs/new_agent/tasks/backlog/2026-05/`

5. `2026-05-06-HIGH-FEATURE-JOB-PROCESSOR-WORKER-CAPACITY.md`
   - Current: `docs/new_agent/tasks/backlog/2026-02/`
   - Target: `docs/new_agent/tasks/backlog/2026-05/`

6. `2026-05-06-MEDIUM-DATA-UNIT-OPERATIONAL-DATA-TEMPLATE-V14.md`
   - Current: `docs/new_agent/tasks/backlog/2026-02/`
   - Target: `docs/new_agent/tasks/backlog/2026-05/`

---

## Implementation Steps

### Step 1 — Move the 2 files to 2026-04

Run these exact commands from the host terminal (from `/Users/tam0013/Documents/git/galaxyGame`):

```bash
mv docs/new_agent/tasks/backlog/2026-02/2026-04-25-HIGH-BUGFIX-MANUFACTURING-SPEC-CELESTIAL-BODY-FACTORY-AUDIT.md docs/new_agent/tasks/backlog/2026-04/

mv docs/new_agent/tasks/backlog/2026-02/2026-04-26-HIGH-FEATURE-JOB-SCHEMA-JSON-MIGRATION.md docs/new_agent/tasks/backlog/2026-04/
```

**Verify Step 1 completion**:
```bash
ls -la docs/new_agent/tasks/backlog/2026-04/ | grep "2026-04-2[56]"
# Expected: 2 files matching those patterns
```

### Step 2 — Move the 6 files to 2026-05

Run these exact commands from the host terminal:

```bash
mv docs/new_agent/tasks/backlog/2026-02/2026-05-01-HIGH-BUGFIX-CONTROLLER-SPECS-DELETE-ALL-FK-CONSTRAINT.md docs/new_agent/tasks/backlog/2026-05/

mv docs/new_agent/tasks/backlog/2026-02/2026-05-01-HIGH-BUGFIX-JOB-PROCESSOR-WORKER-SPEC-FAILURES.md docs/new_agent/tasks/backlog/2026-05/

mv docs/new_agent/tasks/backlog/2026-02/2026-05-01-HIGH-BUGFIX-MANUFACTURING-ASSEMBLY-SERVICE-UNKNOWN-JOB-ATTRIBUTES.md docs/new_agent/tasks/backlog/2026-05/

mv docs/new_agent/tasks/backlog/2026-02/2026-05-03-MEDIUM-DOCUMENTATION-DEPLOYMENT-PATTERN-AND-OPERATIONS.md docs/new_agent/tasks/backlog/2026-05/

mv docs/new_agent/tasks/backlog/2026-02/2026-05-06-HIGH-FEATURE-JOB-PROCESSOR-WORKER-CAPACITY.md docs/new_agent/tasks/backlog/2026-05/

mv docs/new_agent/tasks/backlog/2026-02/2026-05-06-MEDIUM-DATA-UNIT-OPERATIONAL-DATA-TEMPLATE-V14.md docs/new_agent/tasks/backlog/2026-05/
```

**Verify Step 2 completion**:
```bash
ls -la docs/new_agent/tasks/backlog/2026-05/ | grep "2026-05"
# Expected: 7 files total (1 that was already there + 6 moved)
```

### Step 3 — Verify the counts are correct

```bash
echo "=== FINAL VERIFICATION ===" && \
for month in 02 03 04 05; do
  count=$(find docs/new_agent/tasks/backlog/2026-${month} -type f -name "*.md" 2>/dev/null | wc -l)
  echo "2026-${month}: $count files"
done
```

**Expected output**:
```
2026-02: 102 files
2026-03: 31 files
2026-04: 368 files
2026-05: 7 files
```

### Step 4 — Double-check that remaining files in 2026-02 have correct dates

```bash
find docs/new_agent/tasks/backlog/2026-02 -type f -name "*.md" | sed 's|.*/||' | cut -d'-' -f1-2 | sort | uniq -c
```

**Expected output**: Only `2026-02` should appear (102 times)

### Step 5 — Verify no files were accidentally deleted

```bash
echo "Total files moved: 8"
echo "2026-04 count increase: 2 (from 366 to 368)"
echo "2026-05 count increase: 6 (from 1 to 7)"
echo "2026-02 count decrease: 8 (from 110 to 102)"
```

### Step 6 — Create git commit for the file reorganization

From host terminal:

```bash
cd /Users/tam0013/Documents/git/galaxyGame

git add docs/new_agent/tasks/backlog/2026-02/ docs/new_agent/tasks/backlog/2026-04/ docs/new_agent/tasks/backlog/2026-05/

git commit -m "chore: align task files to correct month folders by date prefix

Moved 8 misplaced files from 2026-02 to their correct folders:
- 2 files moved to 2026-04 (2026-04-25, 2026-04-26)
- 6 files moved to 2026-05 (2026-05-01 x3, 2026-05-03, 2026-05-06 x2)

Folder structure now matches file date prefixes:
- 2026-02: 102 files (all 2026-02-XX)
- 2026-03: 31 files
- 2026-04: 368 files (366 + 2 moved)
- 2026-05: 7 files (1 + 6 moved)"

git push
```

---

## Acceptance Criteria

- [ ] All 8 misplaced files moved to correct month folders
- [ ] 2026-02 folder contains exactly 102 files (all with 2026-02 prefix)
- [ ] 2026-04 folder contains exactly 368 files (366 + 2 moved)
- [ ] 2026-05 folder contains exactly 7 files (1 + 6 moved)
- [ ] No files were accidentally deleted during the move
- [ ] All files remain readable and accessible
- [ ] Git commit created documenting the reorganization
- [ ] Changes pushed to repository

---

## Stop Conditions — escalate to user immediately if:

- Any file cannot be found in source location
- Target folder doesn't exist
- Move operation fails with permission error
- File count verification doesn't match expected counts
- Any files from 2026-02 are deleted instead of moved
- Git commit fails

---

## Completion Report

*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  

### What was changed

- Moved `2026-04-25-HIGH-BUGFIX-MANUFACTURING-SPEC-CELESTIAL-BODY-FACTORY-AUDIT.md` from 2026-02 → 2026-04
- Moved `2026-04-26-HIGH-FEATURE-JOB-SCHEMA-JSON-MIGRATION.md` from 2026-02 → 2026-04
- Moved `2026-05-01-HIGH-BUGFIX-CONTROLLER-SPECS-DELETE-ALL-FK-CONSTRAINT.md` from 2026-02 → 2026-05
- Moved `2026-05-01-HIGH-BUGFIX-JOB-PROCESSOR-WORKER-SPEC-FAILURES.md` from 2026-02 → 2026-05
- Moved `2026-05-01-HIGH-BUGFIX-MANUFACTURING-ASSEMBLY-SERVICE-UNKNOWN-JOB-ATTRIBUTES.md` from 2026-02 → 2026-05
- Moved `2026-05-03-MEDIUM-DOCUMENTATION-DEPLOYMENT-PATTERN-AND-OPERATIONS.md` from 2026-02 → 2026-05
- Moved `2026-05-06-HIGH-FEATURE-JOB-PROCESSOR-WORKER-CAPACITY.md` from 2026-02 → 2026-05
- Moved `2026-05-06-MEDIUM-DATA-UNIT-OPERATIONAL-DATA-TEMPLATE-V14.md` from 2026-02 → 2026-05
- Created git commit documenting folder reorganization
- Pushed changes to repository

### Issues discovered

[Report any problems encountered]

### Follow-up tasks needed

**After this reorganization is complete**:
1. The user will need to verify the 2 missing files from the original 112-file deletion (should be searchable now that the folder structure is correct)
2. May need to audit other month folders (2026-03, 2026-04) to check if additional misplaced files exist in those folders

### Lessons learned

[Observations about the organization process]

---

## Dependencies

**Blocked by**: none  
**Blocks**: [2026-05-15-MEDIUM-DATA-INVESTIGATE-MISSING-2-FILES-FROM-RESTORE.md] (pending verification after reorganization)  
**Related tasks**: none  
