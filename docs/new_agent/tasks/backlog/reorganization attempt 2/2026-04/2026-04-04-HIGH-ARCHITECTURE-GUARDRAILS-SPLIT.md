# 2026-04-04-HIGH-ARCHITECTURE-GUARDRAILS SPLIT

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# TASK: Split GUARDRAILS.md — Move Game Design Content to Correct Docs
**Status**: BACKLOG  
**Priority**: MEDIUM  
**Type**: documentation  
**Created**: 2026-03-22

---

## Original Content

# TASK: Split GUARDRAILS.md — Move Game Design Content to Correct Docs
**Status**: BACKLOG  
**Priority**: MEDIUM  
**Type**: documentation  
**Created**: 2026-03-22  
**Last Updated**: 2026-03-22  

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x  
**Why This Agent**: Requires reading both source and target docs, making judgment
calls about what to add vs what already exists, and avoiding duplication.
A 0x agent will create duplicate content or place things incorrectly.  
**Supervision Level**: Standard — produce a plan first, wait for approval before moving content  

> ⚠️ No application code changes. No RSpec runs. No docker exec.
> All operations are file reads and writes on the host filesystem.

---

## Context

`docs/GUARDRAILS.md` has grown over time into a mixed document containing both
agent operating rules AND game design decisions. Local agents couldn't find the
correct doc for a topic so they updated GUARDRAILS.md instead. The result is
681 lines of mixed content that makes it hard for any agent to find what they need.

The correct home for each section already exists in `docs/`. This task moves
game design content to those homes and leaves only agent operating rules in
GUARDRAILS.md.

**Root cause of the problem**: No doc index existed, so agents updated the
nearest known file. `docs/agent/AGENT_ROUTING.md` now provides that index
going forward.

---

## Problem Statement

**Current**: GUARDRAILS.md contains game design decisions mixed with agent rules  
**Expected**: GUARDRAILS.md contains agent operating rules only. Game design
decisions live in their correct subdirectory docs.

---

## Files Involved

### Source (read and modify)
| File | Current size |
|---|---|
| `docs/GUARDRAILS.md` | 681 lines — the file being cleaned up |

### Target files (add content to these — do NOT overwrite, append or merge)
| File | GUARDRAILS Section to Move There |
|---|---|
| `docs/architecture/WORMHOLE_NETWORK_INTENT.md` | Section 2 — Anchor Law |
| `docs/architecture/DUAL_ECONOMY_INTENT.md` | Sections 3, 8 — Market & GCC, Economic System |
| `docs/architecture/visual_layer_stack.md` | Section 7.5 — Terrain Generation & Rendering |
| `docs/architecture/terrainforge_layer.md` | Section 14 — Monitor Interface & Layer System |
| `docs/architecture/biosphere_system.md` | Section 13 (mislabeled) — Sphere Creation Optimization |
| `docs/architecture/atmospheric_maintenance_system.md` | Section 2 — Atmospheric Maintenance Mandate |
| `docs/flavor/EASTER_EGGS.md` | Section 11 — Sci-Fi Easter Eggs |
| `docs/gameplay/mechanics.md` | Section 10 — Player Experience Boundaries |
| `docs/architecture/ai_manager/` | Section 9 — Sol as Training Data |

### New file needed
| File | Content |
|---|---|
| `docs/systems/em_power_shield_technology.md` | EM Power Transition & Shield Technology Evolution section |

### Stays in GUARDRAILS.md (do not move)
- Role boundaries (Planner vs Executor) — top section
- Section 5 — Namespace preservation, service placement rules
- Section 7 — Path configuration standards
- Section 12 — Environment & Container Management
- Section 13 — Database Environment Protection
- Code & Documentation Sync mandate (Section 1)

---

## Implementation Steps

> **Stop after Step 2 and wait for approval before making any changes.**

### Step 1 — Read and map current content

Read `docs/GUARDRAILS.md` in full. For each section, confirm:
- Which target file it belongs in (use the table above)
- Whether the target file already contains similar content
- Whether the content should be appended, merged, or skipped if duplicate

### Step 2 — Produce a Content Map

Before moving anything, produce a report in this format:

```
GUARDRAILS CONTENT MAP

Section: [name]
Target: [file path]
Action: [append | merge | skip — already covered | new file]
Notes: [any overlap or conflict with existing target content]

[repeat for each section]

SECTIONS STAYING IN GUARDRAILS:
[list]

READY TO PROCEED? — waiting for approval
```

**Stop here. Do not move any content until the human approves the map.**

### Step 3 — Move content (after approval)

For each section in the approved map:

1. Read the target file
2. Check for existing coverage of the same topic
3. If not covered — append the section with a source note:
   ```markdown
   ---
   *Moved from GUARDRAILS.md — [date]*
   ```
4. If already covered — note it in completion report, do not duplicate
5. Remove the section from GUARDRAILS.md

### Step 4 — Create new file for EM/Shield content

```
docs/systems/em_power_shield_technology.md
```

Use the EM Power Transition & Shield Technology Evolution section from
GUARDRAILS.md as the initial content. Add standard header:

```markdown
# EM Power & Shield Technology
**Last Updated**: 2026-03-22
**Source**: Moved from GUARDRAILS.md
```

### Step 5 — Clean up GUARDRAILS.md

After all sections are moved:
- Remove moved sections
- Keep all sections listed under "Stays in GUARDRAILS.md"
- Add a header note:

```markdown
> This file contains agent operating rules only.
> Game design decisions have been moved to their correct docs in docs/.
> See docs/agent/AGENT_ROUTING.md for the documentation index.
```

### Step 6 — Move root orphan files

While in docs/, also move these misplaced root files:

```bash
mv docs/ADMIN_DASHBOARD_REDESIGN.md docs/developer/
mv docs/escalation_data_flow.md docs/architecture/ai_manager/
mv docs/luna_ai_manager_visualization.md docs/architecture/ai_manager/
mv docs/orbital_settlement_strategies.md docs/architecture/
mv docs/star_naming_architecture.md docs/architecture/
```

### Step 7 — Archive GUARDRAILS old versions

```bash
mv docs/GUARDRAILS.md.old docs/archive/
mv docs/GUARDRAILS.md.old2 docs/archive/
mv docs/GUARDRAILS.md.old3.md docs/archive/
mv docs/GUARDRAILS.md.old4.md docs/archive/
```

---

## Synthesis Report Format

After Step 2, produce the Content Map and stop.
After Step 3-7, produce a completion report:

```
COMPLETION REPORT

Sections moved: [N]
Sections skipped (already covered): [N]
New files created: [list]
Root orphans moved: [N]
Old versions archived: [N]

Remaining GUARDRAILS.md size: ~[N] lines

Issues discovered:
[any content that didn't fit neatly, overlaps found, gaps identified]

Follow-up tasks needed:
[anything that should be a new backlog task]
```

---

## Acceptance Criteria
- [ ] GUARDRAILS.md contains agent operating rules only
- [ ] GUARDRAILS.md has a header note pointing to AGENT_ROUTING.md
- [ ] All game design sections moved to correct target files
- [ ] No duplicate content created in target files
- [ ] `docs/systems/em_power_shield_technology.md` created
- [ ] 5 root orphan files moved to correct subdirectories
- [ ] 4 GUARDRAILS `.old` files archived
- [ ] Completion report produced

---

## Stop Conditions
- Stop after Step 2 — do not move content without approval of the Content Map
- If a section doesn't clearly fit any target — flag it, do not guess
- If target file already covers the content well — skip, do not duplicate
- If uncertain about any placement — stop and ask

---

## Commit Instructions

Make two atomic commits — one for content moves, one for file moves:

```bash
# Commit 1 — content reorganization
git add docs/GUARDRAILS.md docs/architecture/ docs/flavor/ docs/gameplay/ docs/systems/
git commit -m "docs: move game design content from GUARDRAILS.md to correct docs"

# Commit 2 — file moves and cleanup
git add docs/
git commit -m "docs: move root orphan files, archive GUARDRAILS old versions"

git push
```

---

## Dependencies
**Blocked by**: `TASK_DOCS_AGENT_CLEANUP.md` should run first to clean up
`docs/agent/` — but not strictly required  
**Blocks**: Nothing  
**Related**: `docs/agent/TASK_DOCS_AGENT_CLEANUP.md`

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:  
**Completion date**:  
**GUARDRAILS.md final size**:  

### Sections moved
[list]

### Sections skipped
[list with reason]

### Issues discovered
[overlaps, gaps, content that didn't fit]

### Follow-up tasks needed
[new backlog items identified]

