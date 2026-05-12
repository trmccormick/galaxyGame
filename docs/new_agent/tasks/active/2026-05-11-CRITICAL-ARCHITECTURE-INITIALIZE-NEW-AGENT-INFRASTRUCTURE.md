# TASK: Populate New Agent Logic & Temporal Backlog Curation

**Status**: ACTIVE
**Priority**: CRITICAL
**Type**: architecture
**Created**: 2026-05-11

---

## Agent Assignment
**Assigned To**: Windows 11 Node (Ollama)
**Why This Agent**: Local logic processing to synthesize legacy rules into the newly created blank files.
**Supervision Level**: 🔴 **Strict Review Required**. Verbatim accuracy on financial logic is mandatory.

---

## Context
Folders and blank files have been initialized. The agent must now migrate core DNA (Rules/Decisions) from `docs/agent/` to `docs/new_agent/` and perform the temporal sort of the backlog.

---

## Objectives
1. **Rule Transcription**: Populate `rules/GUARDRAILS.md` with Rules 1, 7, and 10 from the project root or legacy docs.
2. **Logic Extraction**: Populate `rules/DECISIONS.md` with core financial and architecture mandates.
3. **Temporal Sorting**: Move backlog files into `/2026_04` and `/2026_05` based on their filename prefixes.

---

## Execution Steps
1. **Populate `rules/GUARDRAILS.md`**:
   - Locate Rule 1 (Docker), Rule 7 (RSpec), and Rule 10 (Paths) in `docs/agent/README.md` or `docs/agent/rules/`.
   - Write them verbatim into `docs/new_agent/rules/GUARDRAILS.md`.
2. **Populate `rules/DECISIONS.md`**:
   - Extract: 1:1 USD-to-GCC peg.
   - Extract: SCC Surcharge (0.5%), Broker Fee (0.3%), Sales Tax (3.37%).
   - Extract: "No Hardcoded Luna Logic" principle.
3. **Temporal Migration**:
   - Move all files in `docs/agent/tasks/backlog/` starting with '2026-04' to `docs/new_agent/tasks/backlog/2026_04/`.
   - Move all files in `docs/agent/tasks/backlog/` starting with '2026-05' to `docs/new_agent/tasks/backlog/2026_05/`.

---

## Completion Report
*Filled in by the agent*
**Completed by**:  
**Completion date**:  
**Summary of Logic Extracted**: [List specific values found for Tax and Currency]