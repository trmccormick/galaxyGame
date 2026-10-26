# Independent Review Request — GalaxyGame Task C

You are acting as the **independent reviewing agent** for a GalaxyGame task draft in the `trmccormick/agent-tasks` repository.

Your assignment is to independently determine whether this task is ready to proceed through the task lifecycle. Do not assume the previous agent's assessment is correct. Inspect the actual current files and evidence.

## READ THESE FIRST (mandatory, before any work)

Read the following governing documents before reviewing the task:

**Guardrails:**
`https://github.com/trmccormick/agent-tasks/blob/main/rules/GUARDRAILS.md`

**Specific project README:**
`https://github.com/trmccormick/agent-tasks/blob/main/projects/galaxy_game/README.md`

Then read the applicable workflow and task guidance:

- `https://github.com/trmccormick/agent-tasks/blob/main/projects/galaxy_game/REVIEW_AGENT_WORKFLOW.md`
- `https://github.com/trmccormick/agent-tasks/blob/main/projects/galaxy_game/PLANNING_AGENT_SESSION_START.md`
- `https://github.com/trmccormick/agent-tasks/blob/main/projects/galaxy_game/SESSION_GUIDANCE.md`
- `https://github.com/trmccormick/agent-tasks/blob/main/projects/galaxy_game/TASK_TEMPLATE.md`
- `https://github.com/trmccormick/agent-tasks/blob/main/projects/galaxy_game/status.md`

If any path does not exist or cannot be accessed, report that explicitly. Do not silently substitute another document.

## Task under review

**Task C — Catalog Image Containment HTTP Verification**

Current task file:

https://github.com/trmccormick/agent-tasks/blob/main/projects/galaxy_game/tasks/drafts/2026-10-17-HIGH-BUG-FIX-CATALOG-IMAGE-CONTAINMENT-C-HTTP-VERIFICATION.md

Reported latest commit:

`6ce6b7efdcf0af927b19612804fb6b72e8cdda1d`

Commit:

https://github.com/trmccormick/agent-tasks/commit/6ce6b7efdcf0af927b19612804fb6b72e8cdda1d

The task was recently reconciled and committed as a draft. Independently fetch the current `main` version and inspect the actual commit/task contents. Do not rely only on this description.

## Review objectives

Determine whether the task is:

1. Clear and bounded.
2. Consistent with the repository guardrails and GalaxyGame workflow.
3. Technically sound and achievable as written.
4. Safe for a report-only HTTP verification session.
5. Ready for human approval to move from `draft` to `backlog`.

### Inspect these areas

**A. Lifecycle and authorization**
- Confirm the task is actually in the drafts directory and has `status: draft`.
- Confirm it does not authorize dispatch while still a draft.
- Confirm draft review, human approval, backlog movement, and later dispatch are correctly separated.
- Check that the draft-specific checklist is not confused with an implementation completion checklist.
- Identify any lifecycle contradiction or premature authorization.

**B. Dependencies**
- Inspect the referenced Task A:
  `2026-10-17-HIGH-BUG-FIX-CATALOG-IMAGE-CONTAINMENT-A-CORE-REALPATH.md`
- Verify its actual current existence, status, and relevant findings.
- Check the related catalog index image resolution task if the draft relies on it.
- Determine whether Task C’s dependency is justified and correctly represented.
- Do not treat a task’s own statement that a dependency is verified as independent evidence.

**C. Technical scope**
Confirm Task C remains strictly report-only:
- No source code changes.
- No tests, route, helper, authentication, response-shape, configuration, or canonical image-selection changes.
- Only one Markdown verification report is intended.
- Distinguish inherited parent findings from evidence newly obtained through HTTP.
- Check whether acceptance criteria accurately distinguish observed facts, inferences, and unverified conditions.

**D. HTTP verification safety and feasibility**
Inspect the actual instructions for:
- Initial application reachability.
- Authentication-first behavior.
- Public admin endpoint stop condition.
- Human-supplied session handling.
- `GG_ADMIN_COOKIE` handling.
- Cookie and `Set-Cookie` redaction.
- Raw-path preservation using `curl --path-as-is`.
- Valid-image, bypass, encoded traversal, and mixed-case path requests.
- Avoiding non-image response bodies.
- Recording exact targets, status, headers, content type, byte length, and evidence limitations.
- Stop conditions when auth, app availability, or path preservation prevents safe verification.

Evaluate whether these steps are safe, reproducible, and sufficient to support the acceptance criteria. Do not suggest expanding the task beyond its approved report-only scope.

**E. Acceptance criteria**
Review AC1–AC6 individually:
- Are they objectively verifiable?
- Does each criterion have a corresponding task step and evidence requirement?
- Are any criteria impossible to satisfy under the stated stop conditions?
- Does the report distinguish unmet criteria from failed behavior?
- Are claims of verification appropriately limited?

**F. Repository consistency**
Check references to:
- Guardrails.
- Project README and session guidance.
- Review workflow.
- Task template.
- Status tracking.
- Required report location and format.

Identify stale, missing, contradictory, or inaccurate references. Verify actual files rather than assuming they exist.

## Review standards

- Be independent and evidence-based.
- Cite exact GitHub file paths and line numbers or relevant commit details for findings.
- Distinguish:
  - **VERIFIED** — directly inspected in current repository evidence.
  - **REPORTED** — stated by a prior agent but not independently confirmed.
  - **INFERENCE** — your reasoned conclusion.
  - **NOT VERIFIED** — evidence unavailable.
- Do not claim to have run HTTP verification unless you actually did so against an accessible application.
- Do not confuse review of the task instructions with execution of the task.
- Do not invent application behavior, dependency status, or successful verification.
- If something is missing, state exactly what evidence would resolve it.
- Focus on consequential issues rather than stylistic preferences.

## Required disposition

Choose exactly one:

- **PROCEED** — task is ready for human approval to move to backlog.
- **PROCEED WITH CAUTION** — task is reviewable and potentially approvable, but identified uncertainties or bounded corrections should be addressed before approval.
- **STOP** — a substantive lifecycle, safety, scope, dependency, or technical problem prevents approval.

Explain the rationale and identify any required corrections or evidence.

## Review artifact

Follow the repository’s `REVIEW_AGENT_WORKFLOW.md`.

Prepare a concise independent review artifact, approximately 1–2 pages, under:

`projects/galaxy_game/summaries/`

Use the repository’s required naming convention for a dated review file.

Include:
1. Review assignment and task/commit reviewed.
2. Documents and evidence actually inspected.
3. Findings with severity and evidence.
4. Dependency verification.
5. Acceptance-criteria assessment.
6. Lifecycle and safety assessment.
7. Disposition: PROCEED / PROCEED WITH CAUTION / STOP.
8. Rationale and any bounded recommendations.

If you cannot write to the repository, provide the complete review artifact text in your response and clearly state that it was not saved. Do not claim a file was created unless it actually was.

## Authority boundaries

This is an independent review only.

- Do not edit the task file.
- Do not change task status.
- Do not move the task from drafts to backlog.
- Do not dispatch an implementation agent.
- Do not modify source code, tests, configuration, or other tasks.
- Do not commit or push changes.
- Do not treat your recommendation as human approval.

The human owner retains approval and task-lifecycle authority.

## Final response

Return:
1. Your disposition prominently.
2. A concise explanation of the decisive findings.
3. Any missing evidence or required corrections.
4. The review artifact path if successfully saved, otherwise the full artifact text.
5. Confirmation that no task movement, dispatch, code changes, or commits were performed.

Begin by reading the mandatory documents and inspecting the live task and dependency files. Do not provide a disposition based solely on the prior agent’s summary.