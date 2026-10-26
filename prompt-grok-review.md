You are a REVIEW agent (read-only). Review one draft task file from the public GitHub repo trmccormick/agent-tasks. Do not edit, create, or commit anything, and do not write a replacement task. Return a review only.

Read these at commit 7625086 (raw URLs):
1. Draft under review:
https://raw.githubusercontent.com/trmccormick/agent-tasks/7625086/projects/agent-tasks/tasks/drafts/2026-10-23-MEDIUM-DOCUMENTATION-TASK-TEMPLATE-BACKLOG-PATH-AND-STALE-COPY-WORDING.md
2. File it edits (edit targets are lines 17, 130, 421; line 130 is outside the dispatch code fence, which runs from line 132 to 162):
https://raw.githubusercontent.com/trmccormick/agent-tasks/7625086/TASK_TEMPLATE.md
3. Decisions it implements: the newest entry "Draft-gate commit 442a462" Status line, and the 2026-10-20 lifecycle entry Status line (around line 134), in
https://raw.githubusercontent.com/trmccormick/agent-tasks/7625086/projects/agent-tasks/NEEDS_REVIEW.md

If you cannot open any of these URLs, say so and stop. Do not guess file contents.

Check, and label each finding VERIFIED (you read it; quote the line), REPORTED (stated in a doc, name it) or INFERRED (your conclusion):
A. Each "old:" line in Steps 1-3 appears in TASK_TEMPLATE.md exactly once, character for character. Step 2's old text is only the end of the sentence on line 130; say whether it occurs exactly once.
B. Each "new:" line matches the decisions in item 3: backlog holds approved tasks only, grouped by phase or domain, no date folders; a project with a flat backlog omits the [SUBFOLDER]/ segment; a duplicate copy is reported to the human, not deleted.
C. The five grep counts in Step 4 are correct for the edited file, and the expected git diff --stat (3 insertions, 3 deletions, one file) matches three single-line edits.
D. The dispatch block in the draft matches the template's block (TASK_TEMPLATE.md lines 132-162), with only the allowed substitutions; the agent-tasks backlog is flat, so "[SUBFOLDER]/" is omitted from the path lines. Say whether you accept that.
E. Sized for a small local Qwen model: one concern, one file, exact old and new text, a grep check, numbered steps, one sentence naming the only stop points, a fixed completion line. Say if anything would make it stop early or guess.
F. The review gate is a hard stop, commit and push authorized separately, and no "git add ." or "git add -A" anywhere.
G. Does any new line contradict another line in TASK_TEMPLATE.md? Specifically: the new line 17 uses [SUBFOLDER] while line 104 also says tasks/backlog/[SUBFOLDER]/, and lines 150-152 inside the dispatch block say "Never leave stale copies in the source folder". The task leaves lines 150-152 out of scope; say whether leaving them would confuse an agent, and quote them. Also list any other line in TASK_TEMPLATE.md that still contradicts the three decisions.

Return exactly:
Disposition: GO, REVISE, or STOP (STOP means do not proceed at all; REVISE means fix the listed items first)
Findings: one line each, with its label and the line numbers or quoted text it rests on
Required changes (only if REVISE or STOP): numbered, each naming the exact line and the replacement text
Questions for the human: only things you could not verify
Keep it under one page.


---------------------
Grok reply

Disposition: GOFindings:
A. VERIFIED: Each old text appears exactly once. L17: # For APPROVED TASKS: Place in tasks/backlog/{YYYY-MM}/ or tasks/active/ as directed by human after review approval.; L130 end: Fill [project], [SUBFOLDER]and[FILENAME] as usual. Change nothing else. (exactly once); L421: > ❌ Do NOT proceed if two results appear — a stale copy exists and must be removed first.
B. VERIFIED: News match decisions. Draft-gate 442a462 Status (NEEDS_REVIEW L173): backlog holds approved tasks only, no date folders / remove {YYYY-MM}; 2026-10-20 lifecycle Status (L134): stray copies reported/escalated, removed only with human approval. New L17 and L130 implement flat/no-date and omit-[SUBFOLDER]/; new L421 is report-only.
C. VERIFIED/INFERRED: Olds are single unique lines → three single-line edits yield git diff --stat 3 ins/3 del on one file. Post-edit greps will be 0/1/1/0/1 (only one {YYYY-MM} exists; the other three phrases are unique).
D. VERIFIED: Draft dispatch (L17–47) matches TASK_TEMPLATE L132–162 with only allowed substitutions; agent-tasks is flat so `[SUBFOLDER]/ correctly omitted from path lines. Accept.
E. VERIFIED: One concern, one file, exact old/new, grep check, numbered steps, single stop-points sentence (L76), fixed completion line. No early-stop or guess triggers beyond the stated (a)(b)(c).
F. VERIFIED: REVIEW GATE is hard stop (L104–106); commit/push need separate human messages; “Never git add . or git add -A” (L110).
G. VERIFIED: New L17 [SUBFOLDER] is consistent with L104. Dispatch L150–152 (quoted: “Never leave stale copies in the source folder” / “Only ONE result should exist. Paste this output before committing.”) left out of scope (draft L136); they do not force deletion and the task notes possible later rewording. No other line in TASK_TEMPLATE.md still asserts date-folder backlog or “must be removed first.”
Required changes: noneQuestions for the human: none

