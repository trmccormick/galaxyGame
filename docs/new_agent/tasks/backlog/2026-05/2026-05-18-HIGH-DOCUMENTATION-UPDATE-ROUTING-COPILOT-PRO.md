---
status: backlog
priority: HIGH
type: documentation
system_domain: OTHER
mvp_alignment: OTHER
local_worker_safe: true
---

# TASK: Update Agent Routing & README for GitHub Copilot Pro Secondary Tier
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
- **MVP Alignment**: [TO DO]
- **MVP Impact Note**: Clarifies where Copilot Pro fits in agent selection now that June 1 usage-based billing is official
- **Action Line**: READY FOR CLOUD HANDOFF

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x (mechanical updates to routing tables and references)
**Why This Agent**: Systematic updates to existing documentation with clear before/after examples. No complex reasoning needed.
**Supervision Level**: Standard — well-defined changes, existing document structures to follow

---

## Context

June 1, 2026 brought official GitHub Copilot Pro policy: **usage-based billing** with $10/month = 1,000 AI Credits.

This changes Copilot Pro's role from **"avoid/fallback"** to **"secondary execution tier for simple work"**.

Current docs still reflect old "unknown policy" stance. They need updates to match new reality:
- Copilot Pro is not free (costs credits)
- Copilot Pro is not unlimited (5-7 tasks/month max)
- Copilot Pro IS strategically useful for specific work types (single-file fixes, boilerplate)

**Relevant docs**:
- `docs/new_agent/GITHUB_COPILOT_POLICY_TRACKING.md` — newly updated with full policy details, credit economics, routing logic
- `docs/new_agent/README.md` — AI Stack table needs update
- `docs/new_agent/rules/AGENT_ROUTING.md` — needs Copilot Pro section with decision tree

---

## Problem Statement

**Gap**: Routing docs don't reflect Copilot Pro's new secondary-tier role with credit budget.

**Impact**:
- Agents don't know when to route work to Copilot Pro vs. GPT-4.1 0x
- Routing decisions unclear, may waste credits on wrong task types
- No guidance on monthly budget tracking

**Current State**:
```
README.md AI Stack table:
  GitHub Copilot | Pro ($10/mo) | Token pool | June 2026 policy update pending
  
AGENT_ROUTING.md:
  [No Copilot Pro section]
  
Rules/GUARDRAILS.md:
  [No Copilot credit budget rules]
```

---

## Acceptance Criteria

### ✅ Subtask 1: Update README.md AI Stack Table

**Current entry**:
```
| GitHub Copilot | Pro ($10/mo) | Token pool | June 2026 policy update pending |
```

**New entry**:
```
| **GitHub Copilot Pro** | Pro ($10/mo) | 1K credits/mo, secondary execution | Simple fixes, boilerplate. See AGENT_ROUTING.md for routing logic. Credit tracking: COPILOT_PRO_MONTHLY_LOG.md |
```

**Changes**:
- [ ] Change "Token pool" to specific "1K credits/mo"
- [ ] Clarify role as "secondary execution" (not primary, not fallback, not experimental)
- [ ] List what it's good for: "Simple fixes, boilerplate, single-file work"
- [ ] Reference routing table and monthly log
- [ ] Remove "June 2026 policy update pending" phrase (policy now released)

**Success Criteria**: AI Stack table clearly shows Copilot Pro is secondary tier with budget constraint

---

### ✅ Subtask 2: Add Copilot Pro Section to AGENT_ROUTING.md

**Location**: Add new section after "GitHub Copilot & Perplexity Integration" (if exists) or as new top-level section

**Content to add**:

```markdown
## GitHub Copilot Pro — Secondary Execution Tier

**Status**: Active, usage-based billing effective June 1, 2026  
**Cost**: $10/month = 1,000 AI Credits  
**Budget**: ~5-7 tasks/month (estimate 150-200 credits per task average)  
**Best used for**: Single-file fixes, boilerplate, factory definitions, simple Rails tweaks  
**Avoid for**: Multi-file refactors, complex reasoning, architectural decisions  

### Routing Decision Tree

```
Is this task a simple single-file fix?
├─ YES → Is Copilot Pro monthly budget available (< 70% consumed)?
│        ├─ YES → Route to Copilot Pro
│        └─ NO → Route to GPT-4.1 0x
│
└─ NO → Route to GPT-4.1 0x (multi-file, complex, or reasoning work)
```

### Monthly Credit Budget

- **Starting budget**: 1,000 credits on June 1 (each month)
- **Sustainable burn**: ~140 credits/day (1,000 ÷ 30 days)
- **Safe threshold**: When reaching 700 credits used (70%), switch all remaining work to GPT-4.1 0x
- **Tracking**: See `docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md`

### Task Routing Examples

| Task | Routing | Why |
|------|---------|-----|
| Fix single RSpec error | Copilot Pro | Simple, small context, ~100-150 credits |
| Add Rails model method | Copilot Pro | Single file, boilerplate, ~150 credits |
| Rewrite service class | GPT-4.1 0x | Multi-method, complex logic, better for unlimited |
| Refactor 3 related files | GPT-4.1 0x | Large context, unlimited budget safer |
| Architectural decision | Claude 1x | Reasoning required, premium justified |

### Credit Estimation

Expected credit consumption per task type:
- Simple syntax fix: ~50-100 credits
- Single factory definition: ~100-150 credits
- Simple controller action: ~150-200 credits
- RSpec single-file fix: ~100-150 credits
- Rails model with validations: ~200-250 credits
- Multi-file refactor: **Use GPT-4.1 0x instead** (too expensive)

**Note**: These are estimates. Actual consumption depends on file size, context required, and response length.

### Important Rules

1. **Never use for multi-file work** — context window cost multiplies credits needed
2. **Don't enable GitHub Actions Code Review** — costs Actions minutes + AI credits (double cost)
3. **Monitor credit usage weekly** — GitHub Billing page updates daily
4. **At 70% consumed, stop using Copilot Pro** — complete month with GPT-4.1 0x
5. **Document each task's estimated vs. actual credits** — helps calibrate future months
```

**Success Criteria**:
- [ ] New section added with clear decision tree
- [ ] Routing examples provided
- [ ] Credit estimation guidance included
- [ ] Links to COPILOT_PRO_MONTHLY_LOG.md and GITHUB_COPILOT_POLICY_TRACKING.md
- [ ] Rules are explicit and unambiguous

---

### ✅ Subtask 3: Add Copilot Credit Budget Rule to GUARDRAILS.md

**Location**: New Rule (after current Rule 24, so probably Rule 25)

**Content**:

```markdown
## Rule 25: GitHub Copilot Pro Credit Budget Discipline

Copilot Pro has a monthly budget of ~1,000 AI Credits ($10/month). Credits are consumed by token usage and depleted until next billing cycle. Enforce budget discipline:

### The Rules

1. **Track credits like cash** — Monitor `docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md` weekly
2. **Stop at 70%** — When 700 credits used, route all remaining work to GPT-4.1 0x for rest of month
3. **Only simple work** — Route to Copilot Pro only for single-file fixes, boilerplate, basic tweaks
4. **Estimate before assigning** — Use credit estimation guide in AGENT_ROUTING.md
5. **Never do multi-file refactors with Copilot Pro** — Large context = expensive, use GPT-4.1 0x instead
6. **No GitHub Actions Code Review** — Costs both Actions minutes AND AI credits; manually review instead

### Why This Matters

Depleted Copilot credits mid-month means:
- Copilot Pro stops working (GitHub doesn't charge overage, just disables feature)
- Work must shift to GPT-4.1 0x (free but less convenient than Copilot integration)
- Remaining month has one less tool available

Budget discipline means:
- ✅ Copilot Pro available when truly needed
- ✅ Predictable monthly cost
- ✅ No surprises on last day of month
- ✅ Better planning for next month

### What Happens at 0 Credits?

If you exceed budget:
- Copilot stops responding to chat/edit requests
- Inline completions still work (they're free)
- You have two options:
  1. Wait for next billing cycle (~30 days)
  2. Contact GitHub for manual credit top-up (not automatic)

**Prevention > Recovery**: Budget discipline avoids this situation entirely.
```

**Success Criteria**:
- [ ] Rule 25 added to GUARDRAILS.md
- [ ] Budget discipline explained clearly
- [ ] Consequences of overage documented
- [ ] Links to tracking and routing docs

---

### ✅ Subtask 4: Create COPILOT_PRO_MONTHLY_LOG.md Template

**File**: `docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md` (NEW)

**Content**:

```markdown
# GitHub Copilot Pro Monthly Budget Log

Tracking sheet for monthly AI credit consumption. Start a new section each month.

---

## June 2026 (First month with usage-based billing)

**Billing Cycle**: June 1-30, 2026  
**Total Budget**: 1,000 AI Credits  
**Beginning Balance**: 1,000 credits  
**Current Balance**: [UPDATE WEEKLY] 
**Ending Balance**: [TO FILL AT MONTH-END]  
**Total Consumed**: [TO FILL AT MONTH-END]  
**Overage**: None expected

### Task Log

| Date | Task File | Work Type | Est. Credits | Actual* | Notes |
|------|-----------|-----------|---|---|---|
| 2026-06-01 | [task] | Single-file RSpec fix | 100 | TBD | [result] |
| 2026-06-XX | | | | | |

*Actual = observed in GitHub Billing page after task completion

### Weekly Status Check

| Week | Cumulative Used | Remaining | % Consumed | On Track? |
|------|---|---|---|---|
| Week 1 (1-7) | [TBD] | [TBD] | [TBD]% | ✓/✗ |
| Week 2 (8-14) | [TBD] | [TBD] | [TBD]% | ✓/✗ |
| Week 3 (15-21) | [TBD] | [TBD] | [TBD]% | ✓/✗ |
| Week 4 (22-30) | [TBD] | [TBD] | [TBD]% | ✓/✗ |

**Target**: Consume ~250 credits/week to stay under 1,000/month

### Lessons for Next Month

- **Biggest credit consumers**: [task types that used most]
- **Unexpected high-cost tasks**: [any surprises]
- **Next month adjustments**: [routing changes, estimation calibration]
- **What worked well**: [successful budget practices]

---

## May 2026 (Pre-billing, tracking only)

No credits consumed. Workflow testing only.

---

## Archive

Completed months moved below for historical reference.

```

**Success Criteria**:
- [ ] Template created at `docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md`
- [ ] June 2026 section ready to fill in
- [ ] Weekly tracking columns included
- [ ] Clear where actual vs. estimated go
- [ ] Space for lessons learned

---

## Implementation Plan

**Phase 1: README Update (15 min)**
- Find AI Stack table in README.md
- Replace Copilot Pro row with new content
- Verify links are correct

**Phase 2: AGENT_ROUTING.md Update (30 min)**
- Add new "GitHub Copilot Pro" section
- Add decision tree diagram
- Add task routing examples table
- Add credit estimation guide
- Verify links to supporting docs

**Phase 3: GUARDRAILS.md Update (20 min)**
- Add Rule 25 for credit budget discipline
- Explain consequences of overage
- Link to tracking and routing docs

**Phase 4: Create Monthly Log Template (10 min)**
- Create new file at docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md
- Set up June 2026 section
- Provide example task log structure

**Total Estimated Time**: 1.25 hours for 0x agent

---

## Specific Files to Update

### Files to EDIT:
```
docs/new_agent/README.md
  - AI Stack table: update GitHub Copilot row

docs/new_agent/rules/AGENT_ROUTING.md
  - Add new section: "GitHub Copilot Pro — Secondary Execution Tier"
  - Include decision tree, routing examples, credit estimation

docs/new_agent/rules/GUARDRAILS.md
  - Add new Rule 25: GitHub Copilot Pro Credit Budget Discipline
```

### Files to CREATE:
```
docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md
  - Monthly tracking template for credit consumption
```

---

## Definition of Done

1. ✅ README.md AI Stack table updated with Copilot Pro secondary tier description
2. ✅ AGENT_ROUTING.md has new Copilot Pro section with decision tree
3. ✅ GUARDRAILS.md has new Rule 25 on budget discipline
4. ✅ COPILOT_PRO_MONTHLY_LOG.md created with June 2026 section ready
5. ✅ All cross-references correct (links to docs work)
6. ✅ Committed to git with clear commit message

---

## Completion Report Template

When done, fill in:

```markdown
# Completion Report: Update Routing & README for Copilot Pro

## Subtasks Completed
- [x] README.md AI Stack table updated
- [x] AGENT_ROUTING.md new Copilot Pro section added
- [x] GUARDRAILS.md Rule 25 added
- [x] COPILOT_PRO_MONTHLY_LOG.md created
- [x] Cross-references verified
- [x] Committed to git

## Files Changed
- docs/new_agent/README.md — UPDATED (1 table row)
- docs/new_agent/rules/AGENT_ROUTING.md — UPDATED (new section)
- docs/new_agent/rules/GUARDRAILS.md — UPDATED (new rule)
- docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md — NEW

## Quick Checklist
- [x] Decision tree in routing is clear
- [x] Credit estimation examples provided
- [x] Monthly log template ready to use
- [x] All links/references verified
- [x] No broken cross-references

## Ready to Use?
YES — June 1 cutover complete, Copilot Pro now documented in routing

## Notes
[Any issues encountered, clarifications needed, or follow-up items]
```

---

## Notes for 0x Agent

- **This is mechanical copy/update work** — well-defined what goes where
- **Use existing GITHUB_COPILOT_POLICY_TRACKING.md as reference** — has all policy details, credit economics, decision trees
- **Tables should be clear** — routing examples help agents make quick decisions
- **Monthly log is a template** — gets filled in as June progresses, you're just creating the structure
- **Links should work** — verify paths are correct before committing

