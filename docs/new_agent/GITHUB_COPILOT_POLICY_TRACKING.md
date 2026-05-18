---
title: GitHub Copilot June 1, 2026 Policy Changes — Tracking & Planning
status: POLICY_RELEASED
date_created: 2026-05-18
last_updated: 2026-05-18
policy_release_date: 2026-06-01
---

# GitHub Copilot June 1, 2026 Changes — Usage-Based Billing Model

**Status**: ✅ POLICY RELEASED — Effective June 1, 2026  
**Current Setup**: Pro subscription at $10/month → $10 in AI Credits/month  
**New Model**: Usage-based with monthly credit allotment  
**Impact**: Changes Copilot from unlimited to resource-constrained tier

---

## What We Know (June 1, 2026 - OFFICIAL POLICY)

### GitHub Copilot Pro: Usage-Based Billing Model

**Pricing & Credits**:
- Subscription fee: **$10/month** (unchanged from old pricing)
- Monthly credit allotment: **$10 USD = 1,000 AI Credits**
- Credit consumption: Based on **input tokens + output tokens + cached tokens**
- When depleted: **Copilot stops working** (no fallback to cheaper models)

**What's Free** (doesn't consume credits):
- ✅ Standard inline code completions
- ✅ "Next Edit Suggestions"
- ✅ Basic autocomplete in VS Code

**What Costs Credits**:
- ❌ Multi-step coding interactions (chats, agent tasks)
- ❌ Code Review via GitHub Actions (also consumes Actions minutes)
- ❌ Caching benefits (technically saves tokens, but still consumed from budget)

**Annual Plan Subscribers**:
- Old annual plans remain valid until expiration
- Token consumption multiplier applied (requests consume quota more rapidly)
- After expiration: Move to Copilot Free tier
- Option: Transition to monthly paid plan

### Credit Economics

**Example calculations** (approximate, varies by model):
- Simple code completion: 50-200 credits (input + output)
- Multi-turn chat: 500-2,000 credits depending on context/responses
- Single-file fix: 200-500 credits
- Multi-file complex task: 1,000-5,000 credits

**At $10/month = 1,000 credits**:
- 5-10 simple fixes per day
- 2-3 complex multi-file tasks per day
- Budget exhaustion possible by mid-month if used for ALL coding work

### Tracking & Billing

**How to monitor**:
- GitHub Billing Overview page shows credit consumption
- "Billing Preview" experience displays token usage
- Can see how agentic tasks drain budget
- Official guide: "Models and Pricing for GitHub Copilot"

---

## Analysis & Answers (From Official Policy)

### Question 1: Can Copilot Pro Be Primary Execution Agent?

**Answer**: NO — at least not as the ONLY execution agent.

**Reasoning**:
- 1,000 credits/month = ~200-300 implementation tasks maximum
- Galaxy Game has ~100+ active tasks monthly
- Mixed high/low complexity means some days you'll burn budget quickly on complex tasks
- Risk: Mid-month budget depletion = Copilot unavailable

**Best Practice**: Copilot Pro as **secondary execution agent**
- Primary: GPT-4.1 0x (free tier, unlimited)
- Secondary: Copilot Pro (1,000 credits/month, reserve for specific work types)
- Fallback: Continue (Qwen3.5 local, unlimited)

### Question 2: Which Work Types Should Route to Copilot Pro?

**Good fit for Copilot credits** (lower token consumption):
- ✅ Single-file RSpec fixes (small context window)
- ✅ Inline code completions (free, doesn't use credits)
- ✅ Quick controller/model tweaks
- ✅ Standard factory definitions
- ✅ Boilerplate Rails scaffolding

**Bad fit for Copilot credits** (high token consumption):
- ❌ Multi-file refactors (large context)
- ❌ Complex architectural decisions (need reasoning, not just code)
- ❌ Spec debugging (lots of back-and-forth)
- ❌ Service layer redesigns
- ❌ Anything involving code review via GitHub Actions

### Question 3: How Many Tasks per Month?

**Budget breakdown** (assuming average 150 credits per task):
- 1,000 credits ÷ 150 credits/task = **~6-7 tasks/month max**
- If tasks average 200 credits = **5 tasks/month**
- If tasks average 100 credits = **10 tasks/month**

**Recommendation**: Assume **5-7 Copilot Pro tasks/month as sustainable budget**, save the rest for emergencies.

### Question 4: Is $10/Month Worth It?

**Cost-benefit analysis**:
- Free tier (inlline completions): Still unlimited, no billing
- $10/month → ~6-7 complex tasks in addition to unlimited completions
- Compare to GPT-4.1 0x: Free, unlimited, slightly worse for boilerplate
- Compare to Qwen3.5 Continue: Free, unlimited, good for most work

**Verdict**: Worth it IF you use completions + 5-7 targeted tasks.
**Not worth it**: If you never use the credits (better to downgrade to Free).

### Question 5: What About Caching?

**Official note**: Cached tokens still consumed from budget but provide significant savings on repeated requests.

**Implication**: Copilot Pro good for:
- Repeated patterns (Rails migrations, RSpec templates)
- Complex models you reference often
- Bad for one-off tasks

---

## Decision: Revised Routing Strategy (Post-June 1)

**New Copilot Pro Role**: Secondary execution tier, not primary or fallback.

### Updated AI Stack (Effective June 1, 2026)

| Tier | Agent | Cost | Role | Monthly Volume |
|---|---|---|---|---|
| **0-Token** | Gemini | 0 | Planner, triage, strategy | Unlimited |
| **0-Token** | Qwen3.5 (Continue) | 0 | Detail work, code generation | Unlimited |
| **0-Token** | Perplexity | 0 | Task validation, routing | Unlimited |
| **0-Token** | GPT-4.1 0x | 0 | Primary execution agent | Unlimited |
| **Paid** | GitHub Copilot Pro | $10 = 1K credits | Secondary execution (selective) | 5-7 tasks |
| **Premium** | Claude 1x | 1x cost | Complex reasoning (rare) | 1-2 tasks |

### Routing Logic (NEW)

```
Planning: Gemini
    ↓
Triage & Detail: Qwen3.5 (Continue)
    ↓
Validation: Perplexity
    ↓
IMPLEMENTATION DECISION TREE:
    ├─ Single-file, simple fix
    │  └─ Route to: Copilot Pro (if credits available)
    │     └─ If credits low/empty: GPT-4.1 0x
    │
    ├─ Multi-file refactor
    │  └─ Route to: GPT-4.1 0x (unlimited, good for large context)
    │
    ├─ Complex Rails patterns
    │  └─ Route to: GPT-4.1 0x OR Qwen3.5 (if pattern-based)
    │
    └─ Architectural/reasoning work
       └─ Route to: Claude 1x (RESERVE for essential only)
```

### Monthly Budget (Example)

**Assuming 100 tasks/month total**:
- 10% simple single-file fixes → **Copilot Pro** (6-7 tasks, ~1K credits)
- 70% medium complexity → **GPT-4.1 0x** (70 tasks, free)
- 15% complex Rails patterns → **Qwen3.5/GPT-4.1** (15 tasks, free)
- 5% architectural → **Claude 1x** (5 tasks, premium, ~0.33x cost)

**Credit consumption estimate**:
- 6 Copilot Pro tasks × 150-200 credits avg = **900-1,200 credits**
- **May exceed budget by 100-200 credits** depending on task complexity
- **Strategy**: Be conservative, assume 1,000 credits = max 5-6 tasks safely

---

## Workflow Impact: Pre vs Post June 1

### Before June 1 (Old Unlimited Model)
```
Copilot Pro: "Research/non-critical only"
Reasoning: Unknown token costs, so reserved it

Workflow: Gemini → Qwen3.5 → Perplexity → GPT-4.1 0x (no Copilot in routing)
```

### After June 1 (Usage-Based Credits)
```
Copilot Pro: $10/month = 1,000 credits = 5-7 targeted tasks
Reasoning: Known costs, can be strategic about usage

Workflow: Gemini → Qwen3.5 → Perplexity → [Copilot Pro for simple work] → GPT-4.1 0x (fallback)
```

**Key Difference**: Copilot moves from "avoid" to "use strategically"

---

## Implementation: How to Track Budget

### Option 1: Manual Tracking (Simple)
Create a monthly log file: `docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md`

Example entry:
```
## May 2026 (First month)

| Date | Task | Estimated Credits | Notes |
|------|------|---|---|
| 2026-05-20 | RSpec fix, single file | ~150 | Simple syntax fix |
| 2026-05-22 | Factory definition | ~100 | Boilerplate, cached template |
| Total | | ~250 | 750 credits remaining |
```

### Option 2: GitHub Billing Page (Automatic)
- Check GitHub Billing Overview daily
- Watch for threshold warnings (at 70%, 90%, 100%)
- Screenshot monthly for audit trail

### Recommendation
Use **Option 1** (manual log) + **occasional Option 2 checks** to catch overage early

---

## Critical Rules for Copilot Pro Usage

### Rule 1: Don't Exceed 1,000 Credits/Month
- Monitor credits like a budget
- Once at 70% consumed (700 credits), switch to GPT-4.1 0x for rest of month
- Adjust task selection to conserve credits

### Rule 2: Prioritize Simple Work
- Use Copilot Pro for: single-file fixes, boilerplate, templates
- Use GPT-4.1 0x for: complex multi-file work, refactors, reasoning
- Never use Copilot Pro for architectural decisions

### Rule 3: Document Credit-Consuming Tasks
- Tag task files with `credits_used: ~150` in completion report
- Helps forecast future months
- Identifies high-cost work patterns

### Rule 4: No GitHub Actions Code Review
- Do NOT enable "Copilot Code Review" in GitHub Actions during heavy session months
- Code Review consumes Actions minutes + AI credits (double cost)
- Manual review is free alternative

---

## Timeline & Cutover Steps

**May 31, 2026 (Pre-cutover check)**:
- [ ] Confirm Copilot Pro reflects new billing model
- [ ] Update AGENT_ROUTING.md with Copilot Pro placement
- [ ] Create COPILOT_PRO_MONTHLY_LOG.md template
- [ ] Test one simple task with Copilot Pro to measure credit usage

**June 1, 2026 (Cutover day)**:
- [ ] Official policy takes effect
- [ ] Begin tracking credits in monthly log
- [ ] Update README.md "AI Stack" table with new Copilot info
- [ ] Document first month's credit usage

**June 2-30, 2026 (Monitoring phase)**:
- [ ] Track each task's credit consumption
- [ ] Adjust routing if monthly burn rate too high
- [ ] Check GitHub Billing page weekly
- [ ] Report final credit usage at month-end

---

## Immediate Action Items (May 31 - June 2)

### Subtask 1: Update AGENT_ROUTING.md
Add new section: **GitHub Copilot Pro (Usage-Based Credits)**

Content to add:
```markdown
## GitHub Copilot Pro — Secondary Execution Tier ($10/month = ~1K credits)

**Placement**: Secondary execution agent for simple, single-file work  
**Budget**: 5-7 tasks/month estimated (1,000 credits ÷ 150-200 per task)  
**When to route here**: Single-file RSpec fixes, boilerplate, factories, simple tweaks  
**When NOT to route**: Multi-file refactors, complex reasoning, architectural work  
**Fallback**: If credits exhausted mid-month, use GPT-4.1 0x

**Credit tracking**: See docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md
```

### Subtask 2: Create COPILOT_PRO_MONTHLY_LOG.md Template
File: `docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md`

Content:
```markdown
# GitHub Copilot Pro Monthly Budget Log

**Month**: June 2026  
**Total Budget**: 1,000 AI Credits  
**Beginning Balance**: 1,000 credits  
**Ending Balance**: [TO FILL]  
**Overage**: [IF ANY]

## Task Log

| Date | Task | Est. Credits | Actual* | Notes |
|------|------|---|---|---|
| 2026-06-01 | [task name] | 150 | TBD | [notes] |

*Actual credits consumed per GitHub Billing page. Fill in after month-end.

## Summary

- **Tasks completed**: X
- **Avg credits/task**: Y
- **Burn rate**: Z credits/day
- **Lessons for next month**: [notes]

---

*Start a new section each month. Archive previous months.*
```

### Subtask 3: Test One Simple Task with Copilot Pro
**Goal**: Measure actual credit consumption vs. estimates

**Steps**:
1. Pick a simple single-file RSpec fix from backlog
2. Assign to Copilot Pro in VS Code
3. Complete the task
4. Check GitHub Billing page for credits used
5. Calculate: Task scope → Estimated credits vs. Actual
6. Document in COPILOT_PRO_MONTHLY_LOG.md
7. Use data to calibrate future estimates

**What to measure**:
- Input tokens (file size + context)
- Output tokens (generated code)
- Total credits consumed
- Compare to 150-credit estimate

---

## FAQ: GitHub Copilot Pro Usage-Based Billing

**Q: If I don't use Copilot Pro, can I downgrade to Free?**  
A: Yes, but you lose inline completions enhancements. Basic completions still free. Worth keeping Pro for completions alone if you do steady coding.

**Q: What happens if I exceed 1,000 credits mid-month?**  
A: Copilot stops working until next billing cycle. GitHub doesn't charge overage; it just disables the feature.

**Q: Can I check my current credit balance?**  
A: Yes, GitHub Billing Overview page shows real-time consumption. Check weekly to avoid surprises.

**Q: Does caching help save credits?**  
A: Slightly, but it's not magic. Repeated patterns on same files do benefit, but don't rely on caching to extend budget significantly.

**Q: Should we use Copilot Code Review in GitHub Actions?**  
A: NO — during heavy development months. Code Review consumes both Actions minutes AND AI credits. Manual review is free alternative.

**Q: What if my team members also use Copilot Pro?**  
A: Each person has own 1,000 credits/month. Credits are NOT shared unless on Enterprise plan (future). Track each person's usage separately.

**Q: Can we pool credits across the team?**  
A: Only on GitHub Enterprise tier. Current plan (Pro) has individual budgets.

**Q: What models does Copilot Pro use?**  
A: Typically Claude 3.5 Sonnet or equivalent. Exact model not disclosed, but quality is high for the price.

**Q: Is this better than paying for Claude directly?**  
A: Depends on usage. $10/month Copilot = ~6-7 complex Claude tasks. Direct Claude at similar cost gives unlimited API requests. Tradeoff: Copilot integrated in VS Code (convenient) vs. Claude API (flexible).

---

## Current Workflow (Effective June 1, 2026)

✅ **GitHub Copilot Pro INTEGRATED into routing**

```
Planning Gate (0 tokens):
  Gemini — Review session, prioritize work

Triage & Detailing (0 tokens):
  Qwen3.5 (Continue) — Detail tasks, add code examples

Validation (0 tokens):
  Perplexity — Check clarity, routing, test-ability

Implementation Decision:
  IF simple single-file fix AND credits available
    → Route to GitHub Copilot Pro ($10/mo budget)
  ELSE
    → Route to GPT-4.1 0x (unlimited, free)

Complex reasoning (rare):
  Claude 1x (reserved for architectural/multi-session work only)
```

**Key difference from pre-June 1**: Copilot Pro now has a defined place in the routing, with credit budget tracked monthly.

---

## Next Steps (Post June 1)

1. **Update docs/new_agent/README.md AI Stack table**
   - Change GitHub Copilot from "unknown" to "Pro $10/mo, 1K credits/month, secondary execution"

2. **Update docs/new_agent/rules/AGENT_ROUTING.md**
   - Add GitHub Copilot Pro section with routing logic
   - Link to COPILOT_PRO_MONTHLY_LOG.md

3. **Create docs/new_agent/COPILOT_PRO_MONTHLY_LOG.md**
   - Monthly tracking template for credit consumption
   - Starts June 1, 2026

4. **Test with one real task** (June 1-3)
   - Measure actual credit consumption
   - Calibrate estimates for future months
   - Document learnings

5. **Monitor GitHub Billing page**
   - Check weekly during June
   - Adjust routing if burn rate too high
   - Plan for July based on actual usage

---

## Document Status

| Document | Status | Next Action |
|---|---|---|
| GITHUB_COPILOT_POLICY_TRACKING.md | ✅ Updated with official policy | Monitor GitHub Billing |
| README.md (AI Stack table) | ⏳ Needs update | Update after June 1 with real data |
| AGENT_ROUTING.md | ⏳ Needs Copilot Pro section | Add after confirming usage patterns |
| COPILOT_PRO_MONTHLY_LOG.md | ⏳ Needs creation | Create before June 1 |

---

## Glossary: Key Terms

| Term | Definition |
|---|---|
| **AI Credits** | Monthly budget for Copilot Pro. $1 USD = 100 credits. $10/month = 1,000 credits. |
| **Input tokens** | Tokens in your prompt/context. Counted toward credits. |
| **Output tokens** | Tokens in Copilot's response. Counted toward credits. |
| **Cached tokens** | Saved tokens from repeated patterns. Still consume budget but save on repeated queries. |
| **Budget cycle** | Monthly reset on billing date (typically 1st of month). |
| **Overage** | If you exceed 1,000 credits, Copilot stops working until next month. GitHub does NOT charge overage. |
| **Fallback** | When Copilot Pro budget exhausted, route work to GPT-4.1 0x or Continue instead. |

