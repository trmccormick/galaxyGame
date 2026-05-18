---
title: GitHub Copilot June 1, 2026 Policy Changes — Tracking & Planning
status: POLICY_RELEASED
date_created: 2026-05-18
last_updated: 2026-05-18
policy_release_date: 2026-06-01
subscriber_status: ANNUAL_PREPAID
---

# GitHub Copilot June 1, 2026 Changes — Usage-Based Billing Model

**Status**: ✅ POLICY RELEASED — Effective June 1, 2026  
**Your Subscription**: 📌 **ANNUAL PREPAID** (June 1 policy does NOT apply until prepaid year expires)  
**When Policy Affects You**: End of prepaid year (likely May 2027)  
**Current Implication**: Path A (Copilot Pro) is locked in. No June 1-3 testing needed.  
**Action Timeline**: Defer final decision until 30 days before prepaid expiration

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

## Your Status: Annual Prepaid Plan

**What This Means**:
- ✅ You locked in Copilot Pro before June 1 via annual prepaid subscription
- ✅ June 1 policy change does NOT affect your billing until prepaid year expires
- ✅ You are NOT subject to the $10/month usage-based credit system until renewal
- ✅ You have unlimited Copilot Pro access through end of prepaid term

**Your Implications**:
- **NOW (May-June 2026)**: Use Copilot Pro freely, no credit tracking needed
- **30 days before expiration**: Decide whether to renew at new usage-based rates ($10/month credits)
- **Path A locked in**: You're automatically on Path A (Copilot Pro) until prepaid ends
- **Can ignore**: June 1-3 testing, credit budgeting, route optimization for Pro tier
- **Can focus on**: Testing local models (Codestral/Qwen3.5) in parallel to prep for potential Path B

**When You Need To Decide**:
- Decision window: Last 30 days of prepaid year
- Question: Is $10/month AI Credits worth it, or downgrade to Copilot Free + local models?
- Information needed: How many Copilot tasks do you actually need per month?

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

## June 1 Decision Framework (UPDATED FOR PREPAID STATUS)

**Your Situation**: Prepaid annual plan = no decision needed until expiration

**Revised Action Plan**:

### Phase 1: NOW through Prepaid Expiration (Use Copilot Pro Freely)

**What you can do**:
- ✅ Route complex work to Copilot Pro without budget constraints
- ✅ Test local Codestral/Qwen3.5 in parallel (preparing for potential Path B)
- ✅ Measure: How much Copilot work do you actually do per month?
- ✅ Collect: Data on local model performance for same tasks

**What you DON'T need to do**:
- ❌ Test June 1-3 (prepaid = not affected)
- ❌ Track Copilot credits (unlimited until expiration)
- ❌ Make Path A vs B decision now (do it 30 days before expiration)

### Phase 2: 30 Days Before Prepaid Expiration (Make Renewal Decision)

**At that point, decide**:
- **Option 1**: Renew at new usage-based rates ($10/month = ~$10 AI Credits/month)
  - Only viable if you use <5-10 Copilot tasks/month on average
  - Measure this data during Phase 1
  
- **Option 2**: Downgrade to Copilot Free + use local models exclusively
  - Costs $0/month
  - Requires local Codestral/Qwen3.5 to be reliable (test during Phase 1)

**Decision Criteria**:
- **Keep Copilot Pro if**: Average 1-2 tasks/month actually need Copilot (vs local)
- **Switch to Free if**: Local models handle 95%+ of your execution work

---

## Next Steps (May 18 - Prepaid Expiration)

### Phase 1A: NOW (May 18 - June 30, 2026) - Baseline Measurement

**Objective**: Collect data on typical Copilot usage to inform future decision

**What to do**:
1. [ ] Track: How many Copilot Pro tasks do you actually assign per month?
2. [ ] Record: Task complexity (simple RSpec fix vs. complex multi-file refactor)
3. [ ] Note: Alternative — could this have been done with local Codestral?
4. [ ] Collect baseline for 1-2 months

**Why**: At prepaid expiration, you'll need to know if $10/month credit budget is sustainable

### Phase 1B: Parallel (Any Time) - Local Model Testing

**Objective**: Prepare for potential Path B (downgrade to Free + local only)

**What to do**:
1. [ ] Test: Codestral on recent Rails RSpec fixes
2. [ ] Test: Qwen3.5 on model layer issues
3. [ ] Measure: Are local models good enough for 90% of work?
4. [ ] Document: Which tasks still need Copilot Pro?

**Why**: If local models are reliable, Path B becomes attractive at renewal

### Phase 2: 30 Days Before Prepaid Expiration (Likely Late April 2027)

**Decision Window Opens**:
1. [ ] Review Phase 1 data: Average monthly Copilot usage?
2. [ ] Calculate: At new $10/month credit rate, is it sustainable?
3. [ ] Compare: Local model cost (time/compute) vs. $10/month
4. [ ] Decide: Renew Path A (Pro) or switch Path B (Free + local)?

**Example Decision Tree**:
```
IF average usage >5 Copilot tasks/month
AND local models struggled in testing
THEN renew Copilot Pro ($10/month)

ELSE IF average usage <5 tasks/month
AND local models handled 95% of work
THEN downgrade to Copilot Free ($0) + local primary
```

---

## June 1, 2026 - What Changes for You (Prepaid)

**You**: Nothing changes immediately. Your prepaid subscription continues.

**Everyone Else on monthly billing**: Moves to usage-based $10/month credits, limited budget.

**Implication**: You have an unfair advantage during June 1 - August 2026 (roughly). Everyone else is struggling with credit budgets; you're unlimited.

**Smart Move**: Use this window to test Codestral/Qwen3.5 extensively while you have unlimited Copilot as backup.

---

## Renewal Decision Reference (For ~April/May 2027)

### Path A: Renew Copilot Pro at $10/month

**Keep if**:
- ✅ You consistently use 5+ Copilot tasks per month
- ✅ Those tasks are complex enough that local models frequently fail
- ✅ The $10/month cost is acceptable vs. your alternatives
- ✅ You value Copilot's UX over local model setup/management

**Renew as**: Monthly Copilot Pro subscription ($10/month = $10 AI Credits)

### Path B: Downgrade to Copilot Free

**Switch if**:
- ✅ Local models (Codestral/Qwen3.5) handle 90%+ of your work reliably
- ✅ You average <2 Copilot tasks per month on non-local work
- ✅ You're willing to manage Continue gem + local ollama cluster
- ✅ You want to save $10/month

**Switch to**: Copilot Free (code completions only) + all execution work to local Codestral/Qwen3.5

---

## Critical Unknowns Summary (For Future Reference)

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

## Immediate Action Items (May 18, 2026)

### Priority 1: Establish Measurement Baseline (This Week)

**Goal**: Start collecting data on actual Copilot usage

**Action**:
1. [ ] Create or update a tracking file: `docs/new_agent/COPILOT_PRO_USAGE_TRACKING.md`
2. [ ] Log task details: Date, complexity level, whether local model could work
3. [ ] Plan to review this data when prepaid expires (~12 months from now)

**Why**: Data drives decision at renewal time

### Priority 2: Test Local Models (Ongoing, 1-2 months)

**Goal**: Collect parallel data on Codestral/Qwen3.5 performance

**Action**:
1. [ ] Assign mix of tasks to local Codestral (not Copilot Pro)
2. [ ] Record: Quality, speed, any failures
3. [ ] Identify: Which task types local models struggle with?
4. [ ] Document in: `docs/new_agent/LOCAL_MODEL_TESTING_LOG.md`

**Why**: At renewal, you'll know if downgrading to Free is viable

### Priority 3: No Action Needed Before June 1

**NOT required**:
- ❌ Test credit consumption (your prepaid plan doesn't use credits yet)
- ❌ Verify GPT-4.1 availability (doesn't affect you until renewal)
- ❌ Update routing docs for June 1 (your workflow unchanged)
- ❌ Make subscription decision (do it April/May 2027)

---

## FAQ: GitHub Copilot Pro Billing

**Q: Since I'm prepaid, when does usage-based billing affect me?**  
A: Not until your prepaid year expires. You have unlimited Copilot Pro access through renewal. Use this time to test local models.

**Q: What happens at renewal (likely April/May 2027)?**  
A: You choose: (1) Renew at new $10/month usage-based rates, OR (2) Downgrade to Copilot Free ($0). Your prepaid discount ends.

**Q: Can I cancel mid-prepaid term?**  
A: Check your GitHub account. Most annual subscriptions allow cancellation, but you may lose the discount. Downgrade to Free instead.

**Q: What's the advantage of prepaid vs. monthly?**  
A: You locked in an old unlimited tier. Monthly billing (June 1+) uses the new credit system. You got lucky.

**Q: Should I use all my prepaid Copilot time before renewal?**  
A: Not necessary, but might as well — you've already paid for it. Use it to test complex tasks vs. local models.

**Q: What if I don't actually need Copilot at renewal?**  
A: Downgrade to Copilot Free. Keep it for inline code completions (free) and avoid the $10/month subscription.

**Q: Can I downgrade now, then re-upgrade later?**  
A: Yes, but you lose the prepaid discount immediately and lose the rest of your prepaid time. Not recommended.

---

## Summary: What Prepaid Means for You

| Factor | Impact |
|---|---|
| **June 1 policy change** | Doesn't affect you immediately ✅ |
| **Urgency to decide** | Low — decide April/May 2027 when prepaid expires ✅ |
| **Action now** | Collect data on actual usage + test local models 📊 |
| **Advantage** | Unlimited Copilot while others are budget-constrained 🎯 |
| **Smart move** | Use this window to thoroughly evaluate Codestral/Qwen3.5 📈 |

**Recommendation**: Keep using Copilot Pro as-is until prepaid expires. In parallel, test local models extensively. When renewal comes, you'll have solid data to choose Path A (renew) or Path B (downgrade + local).

---

## Old Action Items (Deprecated - These Were for Monthly Billing Users)

The following testing tasks were written for users on monthly plans starting June 1. Since you have prepaid, these don't apply now:

- ❌ Test credit consumption June 1-3
- ❌ Verify GPT-4.1 availability immediately
- ❌ Update routing docs for June 1 cutover
- ❌ Create monthly credit tracking June 1 (defer to April 2027)

These will become relevant when your prepaid year expires (likely April/May 2027).

