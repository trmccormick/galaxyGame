---
status: backlog
priority: HIGH
type: documentation
system_domain: OTHER
mvp_alignment: OTHER
local_worker_safe: true
---

# TASK: Agent Workspace June 1 Cutover Alignment — Copy & Adapt Docs from `agent/` to `new_agent/`
**Status**: BACKLOG
**Priority**: HIGH
**Type**: documentation
**Created**: 2026-05-18
**Last Updated**: 2026-05-18

---

## Local Worker Triage Report
*To be filled by Qwen3.5 via Continue*

- **Template Conformance**: [TO DO]
- **Docker Wrapper Check**: N/A — documentation task
- **MVP Alignment**: [TO DO] — does new_agent folder have all role/rule docs needed for June 1?
- **MVP Impact Note**: [TO DO]
- **Action Line**: [TO DO]

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x (mechanical copy/adapt work) + Haiku 0.33x (review alignment)
**Why This Agent**: Systematic copy-and-adapt of existing docs with clear mapping. No complex reasoning needed; straightforward file operations.
**Supervision Level**: Standard — well-specified subtasks, exact file lists provided, clear success criteria

---

## Context

The Galaxy Game has two agent workspace folders:
- `docs/agent/` — old workflow (active until June 1, 2026)
- `docs/new_agent/` — new workflow (primary after June 1, 2026)

For a clean June 1 cutover, `new_agent/` must have **complete parity with `agent/`** but reflecting the new routing strategy (Gemini → Qwen3.5 → Perplexity → Copilot Pro instead of old routing).

Currently, `new_agent/` is **missing foundational documents** that agents need to execute safely and consistently.

**Relevant Architecture Docs** — read before starting:
- `docs/new_agent/rules/GUARDRAILS.md` — execution rules, Rules 1-24
- `docs/new_agent/README.md` — AI Stack, workflow overview, folder structure
- `docs/new_agent/CONTINUE_WORKFLOW_AUDIT.md` — Qwen3.5 triage capabilities and limits

---

## Problem Statement

**Gap**: `docs/new_agent/` lacks critical operational and role definition documents that exist in `docs/agent/`.

**Impact**: 
- New agents starting in June 1 won't have complete guidance
- Missing role definitions lead to overlapping/conflicting work
- Missing environment rules lead to command safety violations
- Missing test setup docs lead to database corruption

**Current State**:
```
docs/agent/                          docs/new_agent/
├── DOCUMENTATION_STRATEGIST.md      ❌ MISSING
├── SESSION_STRATEGIST.md            ❌ MISSING  
├── IMPLEMENTATION_AGENT_README.md   ❌ MISSING
├── TEST_ENVIRONMENT_SETUP.md        ❌ MISSING
├── rules/
│   ├── ENVIRONMENT_BOUNDARIES.md    ❌ MISSING
│   ├── CONTRIBUTOR_TASK_PLAYBOOK.md ❌ MISSING
│   ├── TASK_PROTOCOL.md             ❌ MISSING
│   └── ...
└── ...
```

---

## Acceptance Criteria

### ✅ Subtask 1: Copy Role Definition Documents
**Deliverable**: Three new files in `docs/new_agent/`
- [ ] `SESSION_STRATEGIST.md` — copied from `docs/agent/SESSION_STRATEGIST.md`
- [ ] `DOCUMENTATION_STRATEGIST.md` — copied from `docs/agent/DOCUMENTATION_STRATEGIST.md`
- [ ] `IMPLEMENTATION_AGENT_README.md` — copied from `docs/agent/IMPLEMENTATION_AGENT_README.md`

**Alignment Changes Required**:
- Remove all references to old agent names (Grok, specific Claude versions, etc.) — use role names only
- Update **AI Stack** table header to reference `docs/new_agent/README.md` instead of old locations
- Update **GitHub Copilot references** from "fallback only" to "active tier with $10/mo Pro subscription, see GITHUB_COPILOT_POLICY_TRACKING.md for June 1 update"
- Verify Continue integration mentions (should match `docs/new_agent/README.md` + `CONTINUE_WORKFLOW_AUDIT.md`)
- Update any references to `docs/agent/` paths to `docs/new_agent/` equivalents

**Success Criteria**: All three files exist, are readable, and reference correct new_agent paths

---

### ✅ Subtask 2: Copy Operational Rules
**Deliverable**: Four new files in `docs/new_agent/rules/`
- [ ] `ENVIRONMENT_BOUNDARIES.md` — copied from `docs/agent/rules/ENVIRONMENT_BOUNDARIES.md`
- [ ] `CONTRIBUTOR_TASK_PLAYBOOK.md` — copied from `docs/agent/rules/CONTRIBUTOR_TASK_PLAYBOOK.md`
- [ ] `TASK_PROTOCOL.md` — copied from `docs/agent/rules/TASK_PROTOCOL.md`
- [ ] `TEST_ENVIRONMENT_SETUP.md` — copied from `docs/agent/TEST_ENVIRONMENT_SETUP.md` (note: in root, not rules/)

**Alignment Changes Required**:
- Verify all Docker commands use correct container paths (unchanged from agent/)
- Update any "Implementation Agent" references to link to the new `IMPLEMENTATION_AGENT_README.md`
- Update any "Session Strategist" references to link to the new `SESSION_STRATEGIST.md`
- Ensure "Rule N" numbering doesn't conflict with `docs/new_agent/rules/GUARDRAILS.md` (which already has Rules 1-24)
  - If CONTRIBUTOR_TASK_PLAYBOOK or others have numbered rules, rename them to avoid conflict (e.g., "Principle 1" instead of "Rule 1")
- Add cross-reference in `GUARDRAILS.md` linking to these operational rules where relevant

**Success Criteria**: All four files exist, command forms are correct, no conflicting numbering

---

### ✅ Subtask 3: Update README.md & Folder Structure References
**Deliverable**: Updated `docs/new_agent/README.md` with complete folder structure guide
- [ ] Add section "Role Definition Documents" pointing to SESSION_STRATEGIST.md, DOCUMENTATION_STRATEGIST.md, IMPLEMENTATION_AGENT_README.md
- [ ] Add section "Operational Rules" pointing to ENVIRONMENT_BOUNDARIES.md, CONTRIBUTOR_TASK_PLAYBOOK.md, TASK_PROTOCOL.md, TEST_ENVIRONMENT_SETUP.md
- [ ] Update folder structure diagram to show new files
- [ ] Verify "Before You Touch Any Code" reading order includes new documents where relevant
- [ ] Update AI Stack table to clarify GitHub Copilot Pro is "active tier" not "reserved"

**Success Criteria**: README.md completely documents all available role/rule docs, newcomers can find everything from README

---

### ✅ Subtask 4: Create June 1 Cutover Verification Checklist
**Deliverable**: New file `docs/new_agent/JUNE_1_CUTOVER_CHECKLIST.md`

**Content Scope** (exactly this, no more):
1. **Pre-Cutover Verification** (May 31, 2026)
   - [ ] All 7 new role/rule docs exist and are readable
   - [ ] GITHUB_COPILOT_POLICY_TRACKING.md has been updated with June 1 policy details
   - [ ] All GitHub Copilot references in docs point to latest policy
   - [ ] README.md folder structure diagram matches actual files
   - [ ] No broken cross-references between docs/agent and docs/new_agent

2. **Cutover Day Checklist** (June 1, 2026)
   - [ ] Switch primary workflow pointer from `docs/agent/` to `docs/new_agent/` in project README
   - [ ] Archive `docs/agent/` to `docs/agent-deprecated-2026-05/`
   - [ ] Verify all new task creation templates point to `docs/new_agent/` paths
   - [ ] Confirm GitHub Copilot Pro token policy is correctly documented
   - [ ] Create first "new_agent cutover session" task using new routing

3. **Post-Cutover Validation** (June 2-3, 2026)
   - [ ] Run 3 sample tasks through new workflow (Gemini → Qwen3.5 → Perplexity → Copilot)
   - [ ] Document any missing pieces in DECISIONS.md
   - [ ] Validate no regressions in task quality

**Success Criteria**: Checklist is clear, actionable, and can be used as-is for June 1 transition

---

### ✅ Subtask 5: Verify No Cross-Folder Conflicts
**Deliverable**: Validation that new_agent docs don't contradict agent docs during transition

**What to Check**:
- [ ] No contradictory AI Stack tables between `docs/agent/README.md` and `docs/new_agent/README.md`
- [ ] GUARDRAILS.md (both folders) don't have overlapping rule numbers
- [ ] TASK_TEMPLATE.md (both folders) are compatible — same format for triage reports
- [ ] AGENT_ROUTING.md docs explain different routing strategies without being contradictory

**Success Criteria**: Any conflicts documented in a "MIGRATION_CONFLICTS.md" file (if any exist) so they're easy to resolve

---

## Implementation Plan

**Phase 1: Mechanical Copy (0x agent, 30 min)**
1. Copy 7 files from agent/ to new_agent/ preserving exact content
2. Stage in git for review

**Phase 2: Alignment Review (0.33x agent, 45 min)**
1. Review all 7 files for GitHub Copilot references
2. Review for role/path references that need updating
3. Identify any cross-references that need fixing
4. Flag numbering conflicts with existing GUARDRAILS.md

**Phase 3: Create New Checklist (0x agent, 30 min)**
1. Create JUNE_1_CUTOVER_CHECKLIST.md from template above
2. Ensure it's actionable and complete

**Phase 4: Final README Update (0.33x agent, 20 min)**
1. Update README.md folder structure to reflect all new docs
2. Verify cross-reference integrity

**Total Estimated Time**: 2-3 hours for a 0x agent + 1x review

---

## Specific Files to Copy

### Role Definitions
```
Source: docs/agent/DOCUMENTATION_STRATEGIST.md
Target: docs/new_agent/DOCUMENTATION_STRATEGIST.md
Size: ~100 lines

Source: docs/agent/SESSION_STRATEGIST.md
Target: docs/new_agent/SESSION_STRATEGIST.md
Size: ~80 lines

Source: docs/agent/IMPLEMENTATION_AGENT_README.md
Target: docs/new_agent/IMPLEMENTATION_AGENT_README.md
Size: ~150 lines
```

### Operational Rules
```
Source: docs/agent/rules/ENVIRONMENT_BOUNDARIES.md
Target: docs/new_agent/rules/ENVIRONMENT_BOUNDARIES.md
Size: ~80 lines

Source: docs/agent/rules/CONTRIBUTOR_TASK_PLAYBOOK.md
Target: docs/new_agent/rules/CONTRIBUTOR_TASK_PLAYBOOK.md
Size: ~150 lines

Source: docs/agent/rules/TASK_PROTOCOL.md
Target: docs/new_agent/rules/TASK_PROTOCOL.md
Size: ~100 lines

Source: docs/agent/TEST_ENVIRONMENT_SETUP.md
Target: docs/new_agent/rules/TEST_ENVIRONMENT_SETUP.md (note: move from root to rules/)
Size: ~200 lines
```

---

## GitHub Copilot References to Update

**Search term**: `github.*copilot|copilot.*pro|copilot.*june`

**Update Pattern** (in all 7 files):
```
OLD: "GitHub Copilot — research/non-critical only, token model unknown"
NEW: "GitHub Copilot Pro — active $10/month tier, token allocation unknown until June 1, 2026 policy update"
```

**Link to add everywhere**: `See docs/new_agent/GITHUB_COPILOT_POLICY_TRACKING.md for June 1 policy status`

---

## Definition of Done

1. ✅ Seven files copied and aligned (no broken links)
2. ✅ GitHub Copilot references updated to reflect "active tier" + Pro subscription cost
3. ✅ All cross-references point to correct new_agent paths
4. ✅ No numbering conflicts with GUARDRAILS.md (current: Rules 1-24)
5. ✅ JUNE_1_CUTOVER_CHECKLIST.md created and actionable
6. ✅ README.md updated with complete role/rule doc references
7. ✅ All 7 files committed to git with clear commit message

---

## Completion Report Template

When done, fill in:

```markdown
# Completion Report: Agent Workspace June 1 Cutover Alignment

## Subtasks Completed
- [x] Role Definition Documents copied (3 files)
- [x] Operational Rules copied (4 files)
- [x] GitHub Copilot references updated
- [x] Cross-references verified
- [x] JUNE_1_CUTOVER_CHECKLIST.md created
- [x] README.md updated
- [x] Committed to git

## Files Changed
- docs/new_agent/SESSION_STRATEGIST.md — NEW
- docs/new_agent/DOCUMENTATION_STRATEGIST.md — NEW
- docs/new_agent/IMPLEMENTATION_AGENT_README.md — NEW
- docs/new_agent/rules/ENVIRONMENT_BOUNDARIES.md — NEW
- docs/new_agent/rules/CONTRIBUTOR_TASK_PLAYBOOK.md — NEW
- docs/new_agent/rules/TASK_PROTOCOL.md — NEW
- docs/new_agent/rules/TEST_ENVIRONMENT_SETUP.md — NEW
- docs/new_agent/JUNE_1_CUTOVER_CHECKLIST.md — NEW
- docs/new_agent/README.md — UPDATED

## Conflicts/Gaps Found
[List any issues that came up during alignment]

## Ready for June 1?
YES / NO / WITH CAVEATS

## Next Steps
[Anything that needs follow-up or further alignment]
```

---

## Notes

- **Why 0x is good for this**: The work is systematic and well-specified. No ambiguity about what needs copying or how to update references.
- **Why 0.33x review is important**: Catch subtle alignment issues that could break the June 1 transition (e.g., conflicting GUARDRAILS numbering).
- **Why we do this now**: If we wait until June 1, we'll be scrambling. Doing it in May means we have time to fix conflicts.
- **Not in scope**: Creating new role documents or rules. This is copy + alignment only. Gaps = flag them, don't invent solutions.

