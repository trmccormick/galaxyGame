# Task: Populate Agent Guide Stubs
**Task ID**: TASK-GUIDES-001
**Assigned To**: Qwen3-30B (Windows) or Codestral (M4)
**Priority**: High
**Status**: Ready

---

## Objective

Read the legacy agent documentation in `docs/agent/` and populate the
stub files in `docs/new_agent/agent_guides/` with relevant content.

Do not invent content. Only extract and reorganize what exists in the
legacy docs. If a section has no relevant content in the legacy docs,
leave the comment placeholder in place and add a note:
`<!-- AGENT: No content found in legacy docs for this section -->`

---

## Source Files

Read all files in: `docs/agent/`

List every file you find there before starting extraction.
If a file's purpose is unclear, note it in your Synthesis Report.

---

## Target Files

| Guide | Path | Domain |
|---|---|---|
| Galaxy Game | `docs/new_agent/agent_guides/galaxy_game.md` | Game project |
| Samvera Hyku | `docs/new_agent/agent_guides/samvera_hyku.md` | Hyku app |
| Samvera Hyrax | `docs/new_agent/agent_guides/samvera_hyrax.md` | Hyrax engine |
| WVU Knapsack | `docs/new_agent/agent_guides/wvulibraries_knapsack.md` | WVU local overrides |

---

## Instructions

### Step 1 — Inventory
List every file in `docs/agent/` with a one-line description of its content.
Output this as your Synthesis Report and STOP.
Wait for human approval before proceeding.

### Step 2 — Extract (after approval)
For each target guide file:
1. Read the stub — note every `<!-- AGENT: ... -->` comment section
2. Search the legacy docs for content relevant to that section
3. Replace the comment with real content in the same markdown style as the stub
4. Keep the `<!-- AGENT: ... -->` comment as a reference above your content
   so the human reviewer knows what was requested vs what was found
5. Output the complete populated file as a CODE_PAYLOAD block

### Step 3 — Report
After all four files are output, produce a summary:
- Which sections were populated
- Which sections had no legacy content
- Any legacy content that didn't fit any guide (flag for human review)

---

## Output Format

Follow `docs/new_agent/COMMUNICATION_PROTOCOL.md` exactly.

Each file must be output as:

```
[CODE_PAYLOAD: docs/new_agent/agent_guides/galaxy_game.md]
```
followed by the complete file in a fenced code block.

---

## Constraints

- Do not modify any files in `docs/agent/` — read only
- Do not populate sections with guessed or invented content
- Do not summarize away important detail — preserve specifics
- Keep each guide focused on its domain — do not cross-contaminate
- If you find content that belongs in `rules/DECISIONS.md` instead
  of a guide, flag it rather than duplicating it

---

## Completion Report

After human reviews and approves the output, fill this in:

```
## Completion Report

**Completed by**:
**Date**:
**Files populated**:
**Sections with no legacy content**:
**Flagged items for human review**:
```
