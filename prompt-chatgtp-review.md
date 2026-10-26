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
Chatgpt reply

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
Disposition: REVISE

Findings:

A — VERIFIED: Step 1 old text matches TASK_TEMPLATE.md:14 exactly once. Step 2 old text is the sentence ending at TASK_TEMPLATE.md:116; it occurs exactly once as a substring, not as a whole line. Step 3 old text matches TASK_TEMPLATE.md:376 exactly once. The draft's reference to line 421 is incorrect: that line is the RISK field. 

GitHub
 

GitHub

B — VERIFIED: The new wording implements approved-only backlog, phase/domain grouping, no date folders, flat-backlog omission, and human escalation rather than deletion. These match the decisions at NEEDS_REVIEW.md:179 and :143. 

GitHub
 

GitHub

C — INFERRED: The expected diff stat of 3 insertions, 3 deletions, one file is consistent with three single-line replacements. The five grep counts are plausible for the resulting file, but they are not independently verified by execution; this is a read-only review.

D — VERIFIED: The dispatch block preserves the template's structure and wording with project, filename, absolute-path and flat-backlog substitutions. Omitting [SUBFOLDER]/ is correct for this project's flat backlog. Accept, but the task incorrectly says lines 150–152 of the template are the stale-copy wording; actual template lines are 133–135. 

GitHub
 

GitHub

E — INFERRED: Appropriate scope for local Qwen. One material early-stop ambiguity: Step 0 dispatch says the task must be moved before reading it, while the draft itself directs the agent to edit TASK_TEMPLATE.md; the draft also says stop only at three conditions, yet the review gate requires waiting for human authorization. Clarify that authorization is a mandatory stop, not an optional continuation.

F — VERIFIED: Review gate is a hard stop; commit and push require separate authorization; git add . and git add -A do not appear in the draft. 

GitHub

G — VERIFIED: The new line 17 conflicts with template line 95, which still prescribes tasks/backlog/[SUBFOLDER]/. Line 14 is also still dated-folder wording and is the task's intended edit. More importantly, template lines 133–135 say “Never leave stale copies in the source folder” and “Only ONE result should exist. Paste this output before committing.” These conflict with the decision to report duplicates without deleting or moving them. Leaving them out of scope will confuse an agent because the dispatch block is mandatory and copied verbatim. 

GitHub
 

GitHub
 

GitHub

Required changes:

Draft line 59: Replace Do NOT edit anything inside the dispatch block code fence (lines 132-162). Step 2 edits a sentence outside it, above the fence. with Do NOT edit anything inside the dispatch block code fence (lines 118-144). Step 2 edits a sentence outside it, above the fence. (actual template fence is lines 118–144).

Draft line 113: Replace the claim that dispatch lines 150–152 do not conflict with Step 3 with: The dispatch block's stale-copy rule at TASK_TEMPLATE.md lines 133-135 conflicts with the duplicate-reporting decision. This task leaves those lines unchanged; a separate task must reconcile them before dispatching agents under the updated policy.

Draft line 64: Replace the stop-points sentence with: Only stop at: (a) an old text that is not found exactly once, (b) a check that still fails after one retry, or (c) the review gate. At the review gate, stop and wait for reviewer disposition and separate human authorization.

Scope: Either include the dispatch stale-copy lines in this task or explicitly block dispatch until that contradiction is fixed. The current task claims three line edits only, so the safer change is to make the block explicit and sequence the follow-up.

Questions for the human:

Should the dispatch stale-copy contradiction be added to this task, or remain a separate prerequisite task?

The draft's Step 4 grep counts were not executed; should the implementing agent report actual counts before requesting review?

