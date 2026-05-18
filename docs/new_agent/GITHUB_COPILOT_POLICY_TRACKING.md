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

### CRITICAL: Death of the 0x Free Tier

**Major Policy Change**: GitHub is removing the 0x free tier for ALL agents. Every model now has a cost.

**Current State (May 31, 2026)**:
```
GPT-4.1           = 0x (unlimited, FREE) ← PRIMARY EXECUTION
Haiku             = 0.33x (paid)
Claude Sonnet     = 1x (paid)
Claude Opus       = 1.5x (paid)
Local Codestral   = 0 tokens (local, unlimited)
Local Qwen3.5     = 0 tokens (local, unlimited)
```

**Expected After June 1 (ASSUMPTION - NEEDS VERIFICATION)**:
```
GPT-4.1           = 0.5x? (paid, but cheaper than Sonnet) ← NEW COST UNKNOWN
Haiku             = 0.33x (paid, remains cheapest premium)
Claude Sonnet     = 1x (paid, standard)
Claude Opus       = 1.5x (paid, premium)
Local Codestral   = 0 tokens (local, unlimited) ← BECOMES PRIMARY
Local Qwen3.5     = 0 tokens (local, unlimited) ← BECOMES PRIMARY
```

**Impact**: Your unlimited GPT-4.1 0x tier is **GONE**. All execution work now has a cost UNLESS you use local models.

### GitHub Copilot Pro: Usage-Based Billing Model (OFFICIAL)

**Pricing & Credits**:
- Subscription fee: **$10/month** (unchanged from old pricing)
- Monthly credit allotment: **$10 in AI Credits** (1:1 dollar to credit ratio)
- Credit consumption: Based on **input tokens + output tokens + cached tokens**
- Cost per credit: **~$0.01 per credit**, but varies significantly by model
- When depleted: **Agent usage halts completely** — NO fallback to cheaper models

**What's Free** (doesn't consume credits):
- ✅ Standard inline code completions
- ✅ "Next Edit Suggestions"
- ✅ Basic autocomplete in VS Code

**What Costs Credits**:
- ❌ Standard chat & coding agents (all multi-step interactions)
- ❌ Code Review via GitHub Actions (ALSO consumes Actions minutes at GitHub standard rates)
- ❌ Complex multi-file agent sessions (burn through credits "significantly faster")

**Credit Consumption Rates by Model Type** (from official policy):
- Lightweight models: Fraction of a credit per task
- Standard models (Sonnet): Variable, roughly 1-2 credits per moderate task
- Complex multi-file sessions: 5-10+ credits per task
- **GPT-4.1 rates: NOT SPECIFIED** in official policy

**Annual Plan Subscribers**:
- Old annual plans remain valid until expiration
- Updated with "model multipliers" (method for computing quota consumption not specified)
- After expiration: Move to Copilot Free tier or upgrade to monthly Pro

**Other Plans** (for reference):
- Copilot Pro+: $39/month = $39 in AI Credits
- Copilot Business: $19/user/month + $30 promo credits through August
- Copilot Enterprise: $39/user/month + $70 promo credits through August

### What Changed From Old Policy

**Old System (Pre-June 1)**:
- Premium Request Units (PRUs)
- Fallback to cheaper model when limits reached
- Unclear cost structure

**New System (June 1+)**:
- GitHub AI Credits ($1 = 100 credits? NO — $1 = 1 credit, 1:1 ratio)
- NO fallback mechanisms — stops completely when depleted
- Clear: ~$0.01 per credit, varies by model
- All 0x free tiers eliminated

### Tracking & Billing

**How to monitor**:
- GitHub Copilot Billing Settings page
- "Billing Preview" shows estimated spend
- Real-time view of which models/tasks consuming credits
- Hard spending limits available for organizations (not individual Pro accounts)

---

## Analysis & What's Still Unknown

### What We Now Know (Concrete)

1. ✅ **$10 credit budget, period.** No "1,000 credits" ambiguity — $10 = 10 credits at ~$0.01/credit
2. ✅ **No fallback.** When depleted, agent usage STOPS until next billing cycle
3. ✅ **Lightweight models use fractions of a credit** (good for cheap tasks)
4. ✅ **Code completions remain free** (no credit consumption)
5. ✅ **Avoid Code Review** (costs both Actions minutes + credits)
6. ✅ **Complex multi-file sessions are expensive** ("burn through credits significantly faster")

### Critical Remaining Unknown #1: GPT-4.1 Availability & Pricing

**The Policy Says**: "Standard Chat & Coding Agents consume AI Credits at varying API rates per model"

**What This Means**: Each model has a different cost multiplier.

**What's Missing**: 
- ❌ Is GPT-4.1 available in Copilot Pro at all?
- ❌ If yes, what's its cost multiplier? (Cheaper than Sonnet? Same as Sonnet? More?)
- ❌ Is there any 0x equivalent in Copilot Pro?

**Why It Matters**: If GPT-4.1 is expensive (>Sonnet) or unavailable, Path A (keep Copilot Pro) becomes unviable.

### Critical Remaining Unknown #2: Model Multiplier Mapping

**The Policy Hints**: Annual plans get "updated usage multipliers" for computing quota consumption

**What This Means**: Different models cost different amounts

**What's Missing**:
- ❌ Exact multiplier for Haiku (0.33x equivalent? Less?)
- ❌ Exact multiplier for Sonnet (1x equivalent?)
- ❌ Exact multiplier for Opus (1.5x equivalent?)
- ❌ Do these multipliers apply to monthly Pro credits too, or only annual plans?

**Why It Matters**: Budget sustainability depends on knowing which model to use for which task.

### What You CAN Infer Now

**From "~$0.01 per credit" and "complex multi-file sessions burn through significantly faster"**:

A simple fix might cost:
- 0.1-0.5 credits (cheap models)
- 0.5-2 credits (standard models)

A complex multi-file refactor might cost:
- 5-10+ credits (at standard rates)

**At $10/month**:
- Best case: 20+ simple fixes per month (if lightweight models cheap enough)
- Worst case: 1-2 complex tasks per month (if multi-file expensive)
- Most likely: 5-10 mixed tasks per month

### Decision Framework (Updated)

**The fundamental question**: Is local Codestral/Qwen3.5 execution faster or more economical than Copilot Pro?

**Path A Decision Rule** (Keep Copilot Pro):
- IF GPT-4.1 available in Copilot Pro
- AND GPT-4.1 costs ≤ Sonnet equivalent cost
- AND simple fixes cost <0.5 credits
- THEN keep Copilot Pro ($10/month sustainable)

**Path B Decision Rule** (Downgrade to Free):
- IF GPT-4.1 not available
- OR GPT-4.1 costs > Sonnet equivalent
- OR simple fixes cost >1 credit
- THEN downgrade to Free, use local Codestral/Qwen3.5 exclusively

**Test Metrics** (June 1-3):
1. Assign 1 simple RSpec fix to Copilot Pro
2. Check Billing Preview: How many credits consumed?
3. Calculate: $10 ÷ credits_per_task = tasks_sustainable_per_month
4. Compare to: How many tasks can M4 Codestral handle daily?
5. Choose path based on which is faster/cheaper

---

## Decision: Revised Routing Strategy (Post-June 1)

**THE FUNDAMENTAL SHIFT**: All 0x free agents disappear. GPT-4.1 will have a cost (amount unknown). You MUST choose between Copilot Pro or local models.

**Your $10 Budget Reality**:
- $10/month in credits
- ~$0.01 per credit average
- Simple fixes: likely 0.1-0.5 credits each (20-100 tasks if lightweight models cheap)
- Complex multi-file: likely 5-10+ credits each (1-2 tasks max)
- Most likely sustainable: 5-10 mixed tasks/month

**Two Possible Workflows**:

### Path A: Copilot Pro Becomes Primary Execution (IF GPT-4.1 Available + Cheap)

```
Planning: Gemini (0)
Triage: Qwen3.5 (0, local)
Validation: Perplexity (0)

IMPLEMENTATION (if GPT-4.1 cheap):
├─ Simple fixes (RSpec, model, controller)
│  └─ Copilot Pro ($10/month = 5-10 tasks sustainable)
│
├─ Complex multi-file work
│  └─ Local Codestral (unlimited) [Copilot too expensive for this]
│
└─ Rare architectural work
   └─ Claude 1x (premium, expensive)
```

**Sustainability**: 5-10 Copilot Pro tasks/month, 20+ local Codestral tasks/month  
**Budget risk**: Medium — if GPT-4.1 is expensive or unavailable, Path A fails

### Path B: Local Models Become Primary Execution (IF Copilot Pro Too Expensive)

```
Planning: Gemini (0)
Triage: Qwen3.5 (0, local)
Validation: Perplexity (0)

IMPLEMENTATION (primary execution):
├─ All mechanical work (90%)
│  └─ Local Codestral (unlimited) OR Qwen3.5 (unlimited)
│
├─ When local models overwhelmed
│  └─ Copilot Pro (for urgent work, if budget permits)
│
└─ Rare architectural work
   └─ Claude 1x (premium, expensive)
```

**Sustainability**: Unlimited local work, minimal Copilot/Claude spend  
**Budget risk**: Low — local unlimited, $10 saved monthly

### Updated AI Stack (June 1+, Post-Decision)

**OPTION A: Keep Copilot Pro** (if GPT-4.1 available + cost ≤ Sonnet)

| Tier | Agent | Cost | Role | Monthly Capacity |
|---|---|---|---|---|
| **0-Token** | Gemini | 0 | Planner | Unlimited |
| **0-Token** | Qwen3.5 (local) | 0 | Detail, triage | Unlimited |
| **0-Token** | Perplexity | 0 | Validation | Unlimited |
| **Paid** | Copilot Pro | $10/mo | Primary execution (simple work) | 5-10 tasks |
| **Local** | Codestral (M4) | 0 | Complex/large context | Unlimited |
| **Premium** | Claude 1x | 1x cost | Rare architectural | 1-2 tasks |

**OPTION B: Downgrade to Copilot Free** (if Pro too expensive)

| Tier | Agent | Cost | Role | Monthly Capacity |
|---|---|---|---|---|
| **0-Token** | Gemini | 0 | Planner | Unlimited |
| **0-Token** | Qwen3.5 (local) | 0 | Detail, triage, execution | Unlimited |
| **0-Token** | Codestral (M4) | 0 | Primary execution | Unlimited |
| **0-Token** | Perplexity | 0 | Validation | Unlimited |
| **Free** | Copilot Free | 0 (completions only) | Inline suggestions | Unlimited |
| **Premium** | Claude 1x | 1x cost | Rare architectural | 1-2 tasks |

---

## Workflow Impact: Before vs After June 1

### Before June 1 (Current: Unlimited 0x Tier)
```
Gemini (0)           → Plan
   ↓
Qwen3.5 (0, local)   → Triage & detail
   ↓
Perplexity (0)       → Validate
   ↓
GPT-4.1 0x (0, FREE) → PRIMARY EXECUTION (unlimited)
   ↓
Claude 1x (premium)  → Complex work only
```

**Characteristics**:
- ✅ Unlimited GPT-4.1 execution
- ✅ No budget constraints
- ✅ Route ALL mechanical work to GPT-4.1 0x
- ✅ Copilot Pro not in workflow (experimental/unknown)

### After June 1 (OPTION A: Copilot Pro + Local Models)

**Assumption**: GPT-4.1 available in Copilot Pro at reasonable cost

```
Gemini (0)           → Plan
   ↓
Qwen3.5 (0, local)   → Triage & detail
   ↓
Perplexity (0)       → Validate
   ↓
IMPLEMENTATION (choose based on work type):
├─ Simple fix        → Copilot Pro (budget: 5-7 tasks/month)
├─ Complex work      → Local Codestral (unlimited)
└─ Rare/architecture → Claude 1x (premium)
```

**Characteristics**:
- ✅ Limited Copilot Pro budget ($10/month = ~10 credits at $0.01/credit)
- ✅ Local Codestral/Qwen3.5 as overflow for complex work
- ✅ Must route strategically: simple → Copilot, complex → local
- ⚠️ Need to track credit usage monthly (can run out mid-month)
- ⚠️ When depleted: NO fallback, Copilot stops working

### After June 1 (OPTION B: Local-First + Claude Premium)

**Assumption**: Copilot Pro too expensive or GPT-4.1 not available

```
Gemini (0)           → Plan
   ↓
Qwen3.5 (0, local)   → Triage & detail
   ↓
Perplexity (0)       → Validate
   ↓
IMPLEMENTATION (primary execution):
├─ 90% mechanical    → Local Codestral/Qwen3.5 (unlimited)
├─ Emergency backup  → Copilot Free (completions only)
└─ Rare/complex      → Claude 1x (premium, limited use)
```

**Characteristics**:
- ✅ Primary execution fully unlimited (local models)
- ✅ Minimal budget constraints
- ✅ $10/month saved (downgrade to Free)
- ✅ Depends on local model quality

---

## June 1 Decision Framework

**Before committing to Option A or B, TEST**:

### Pre-June 1 Test (May 25-31)
1. [ ] Assign one simple RSpec fix to Copilot Pro
2. [ ] Measure: Credits consumed
3. [ ] Calculate: Cost per task
4. [ ] Compare to: Local Codestral cost (unlimited)
5. [ ] Decide: Is $10/month worth the convenience?

### Post-June 1 Confirmation (June 1-7)
1. [ ] Verify GPT-4.1 availability in Copilot Pro
2. [ ] Confirm token multipliers apply (or don't)
3. [ ] Run 3 sample tasks through chosen path
4. [ ] Finalize subscription decision
5. [ ] Update AGENT_ROUTING.md with confirmed workflow

---

## Next Steps (May 31 - June 7)

### Immediate (May 31, 2026 - 1 Day Before June 1)

**Decision Point**: Which path will you take June 1+?

**Option A: Test Copilot Pro** (if you want to keep $10/mo subscription)
1. [ ] Assign one simple RSpec fix to Copilot Pro today
2. [ ] Check GitHub Billing page tomorrow for credits consumed
3. [ ] Calculate: `task_complexity × cost_per_credit = monthly_estimate`
4. [ ] Ask: "Is this cost acceptable vs. local model?"

**Option B: Prepare Local Model Fallback** (if considering downgrade)
1. [ ] Test recent Codestral performance on Rails work
2. [ ] Document which models available on M4 Mac
3. [ ] Verify Continue gem integration working smoothly
4. [ ] Plan: How many concurrent local tasks can M4 handle?

### Critical (June 1, 2026 - Official Cutover)

**When policy takes effect**:
1. [ ] Verify GPT-4.1 status: Available in Copilot Pro? What cost?
2. [ ] Confirm which models available in Copilot Pro
3. [ ] Check GitHub Billing page: Do token multipliers apply?
4. [ ] Update GITHUB_COPILOT_POLICY_TRACKING.md with findings

**Make Subscription Decision**:
- [ ] Option A: Keep Copilot Pro at $10/mo (if reasonable cost)
- [ ] Option B: Downgrade to Copilot Free (save $10, use local models)

### Confirmation (June 2-7, 2026)

**Run through new workflow**:
1. [ ] Assign 3 test tasks to chosen execution tier
2. [ ] Measure actual token consumption / credit usage
3. [ ] Compare quality and speed vs. alternatives
4. [ ] Document lessons in GITHUB_COPILOT_POLICY_TRACKING.md

**Update Routing Docs**:
1. [ ] Update README.md AI Stack table with confirmed workflow
2. [ ] Update AGENT_ROUTING.md with June 1+ routing logic
3. [ ] Create COPILOT_PRO_MONTHLY_LOG.md if keeping Pro
4. [ ] Commit with clear "Post-June 1 Cutover" message

---

## Critical Unknowns Summary

**These MUST be resolved by June 1 to make routing decisions**:

| Unknown | Why It Matters | Test Method |
|---|---|---|
| Is GPT-4.1 available in Copilot Pro? | If NO: Path B only; If YES: Path A possible | Check Copilot Pro model selector |
| What's the cost multiplier for GPT-4.1? | If 0.5x: ~10 tasks/mo; If 1x: ~5 tasks/mo; If 2x: too expensive | Run test task, check GitHub Billing |
| Do token multipliers apply to Copilot credits? | If YES: Haiku cheaper; If NO: all same cost | Compare Haiku vs. Sonnet task costs |
| Is there a Copilot Pro+ tier? | If YES: different pricing might be worth it | Check GitHub Copilot pricing page |

**Decision Tree**:
```
GPT-4.1 available in Copilot Pro?
├─ YES → What's the cost multiplier?
│         ├─ ≤0.5x → Keep Copilot Pro (Path A)
│         ├─ 1x → Marginal, test both paths
│         └─ >1x → Downgrade to Free (Path B)
│
└─ NO → Downgrade to Copilot Free (Path B mandatory)
```

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

## The Big Picture: What June 1 Means for You

**The Shift**:
```
BEFORE June 1          AFTER June 1
────────────           ────────────
Unlimited GPT-4.1 0x   → GPT-4.1 costs something (unknown multiplier)
All work free          → All cloud work has a cost (unless local)
Simple decision        → Complex routing decision
```

**The Problem**:
Your entire workflow depends on unlimited GPT-4.1 0x. June 1 breaks that assumption. You need a new primary execution tier:
- **Option A**: Copilot Pro (if GPT-4.1 available + cost reasonable)
- **Option B**: Local Codestral (unlimited, always free)

**The Decision**:
Can't be made until unknowns are resolved (GPT-4.1 availability, cost multiplier, etc.). This will be tested June 1-3.

**The Stakes**:
- **If you guess wrong**: Burnout credits mid-month or lose execution capacity
- **If you plan right**: Seamless transition, maybe save $10/month

---

## Document Status

| Document | Status | Purpose |
|---|---|---|
| GITHUB_COPILOT_POLICY_TRACKING.md | ✅ Updated with policy + unknowns | Decision framework for June 1 |
| README.md (AI Stack table) | ⏳ Blocked on June 1 decision | Will update after testing Path A/B |
| AGENT_ROUTING.md | ⏳ Blocked on June 1 decision | Will add confirmed routing post-test |
| COPILOT_PRO_MONTHLY_LOG.md | ⏳ Conditional on keeping Pro | Create IF choosing Path A |

**Action Owner**: Session Strategist (You)  
**Decision Deadline**: June 1, 2026  
**Test Window**: June 1-7, 2026  
**Implementation**: June 7+, 2026

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

