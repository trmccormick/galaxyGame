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

### GitHub Copilot Pro: Usage-Based Billing Model

**Pricing & Credits**:
- Subscription fee: **$10/month** (unchanged from old pricing)
- Monthly credit allotment: **$10 USD = 1,000 AI Credits**
- Credit consumption: Based on **input tokens + output tokens + cached tokens**
- Token multipliers: **UNKNOWN** — do 0.33x/0.5x/1x apply to Copilot credits?
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

### Credit Economics (PENDING MULTIPLIER CLARIFICATION)

**If Copilot Pro applies cost multipliers to credits**:

Example calculations (using hypothetical multipliers):
```
Simple fix via Haiku 0.33x:      50 credits
Simple fix via GPT-4.1 0.5x:    100 credits  
Simple fix via Sonnet 1x:       200 credits
Complex task via Sonnet 1x:     800 credits
```

**At $10/month = 1,000 credits**:
- Heavy Haiku usage: ~20 tasks/month
- Mixed GPT-4.1 (0.5x) + Sonnet: ~8-10 tasks/month
- Heavy Sonnet usage: ~5 tasks/month

**Critical Unknown**: What multipliers does Copilot Pro apply?

### Tracking & Billing

**How to monitor**:
- GitHub Billing Overview page shows credit consumption
- "Billing Preview" experience displays token usage
- Can see how agentic tasks drain budget
- Official guide: "Models and Pricing for GitHub Copilot"

---

## Analysis & Unknowns (Critical for June 1 Decision)

### The Core Problem: GPT-4.1 0x Is Disappearing

**Current reality** (May 31, 2026):
- You rely on unlimited GPT-4.1 0x for 70% of execution work
- Gemini (0) → Qwen3.5 (0) → Perplexity (0) → **GPT-4.1 0x (0, unlimited)** ← YOUR FOUNDATION

**After June 1**:
- GPT-4.1 will still exist BUT is no longer 0x (no longer free)
- Cost multiplier unknown (0.5x? 1x? 2x?)
- May no longer be available through standard APIs, only Copilot Pro?
- Your unlimited tier **VANISHES**

**Impact**: You MUST route to either:
1. **Copilot Pro** (if GPT-4.1 available + cost is reasonable)
2. **Local Codestral/Qwen3.5** (unlimited, always free)
3. **Claude premium** (expensive, reserved for complex only)

### Critical Unknown #1: GPT-4.1 Availability in Copilot Pro

**Question**: Will GitHub include GPT-4.1 in Copilot Pro's model selection?

**If YES (likely)**:
- Cost multiplier would be 0.33x? 0.5x? or 1x?
- Copilot Pro might be viable (depends on multiplier)

**If NO (unlikely but possible)**:
- You lose access to GPT-4.1 through Copilot
- Stuck with Claude/Sonnet models only
- Downgrade to Copilot Free, use local models exclusively

### Critical Unknown #2: Token Multipliers in Copilot Pro

**Current system** (pre-June 1):
- Haiku = 0.33x cost (cheaper)
- Claude Sonnet = 1x cost (standard)
- GPT-4.1 = 0x cost (FREE)

**Question**: Do these multipliers apply within Copilot's 1,000 monthly credits?

**Scenario A: Multipliers Apply to Copilot Credits**
```
1,000 credits budget:
├─ Heavy Haiku 0.33x → ~30 complex tasks/month
├─ Mixed GPT-4.1 0.5x → ~10-15 tasks/month
└─ Heavy Sonnet 1x → ~5-7 tasks/month
```
**Impact**: Copilot Pro MIGHT be viable if GPT-4.1 is 0.5x or cheaper

**Scenario B: Copilot Standardizes to 1x for All Models**
```
1,000 credits budget:
└─ Any model = 1x cost → ~5-7 tasks/month (regardless of model)
```
**Impact**: Copilot Pro becomes expensive relative to local models. Not worth keeping.

**Scenario C: Different Pricing Tiers (Copilot Pro Base vs. Pro+)**
```
Copilot Pro ($10) = access to Sonnet only
Copilot Pro+ ($39?) = access to GPT-4.1, Opus, etc.
```
**Impact**: You might be on wrong tier. Need to evaluate Pro vs. Pro+.

### What This Means for Your June 1 Decision

**If Unknowns Resolve Favorably** (GPT-4.1 available + 0.5x multiplier):
- ✅ Keep Copilot Pro
- ✅ Route simple work through Copilot Pro
- ✅ Use local models for large/complex tasks
- **Monthly budget**: 1,000 credits ÷ 150 credits/task = ~6-7 tasks sustainable

**If Unknowns Resolve Unfavorably** (No GPT-4.1 OR 1x multiplier):
- ❌ Downgrade to Copilot Free
- ❌ Route ALL mechanical work to local Codestral/Qwen3.5
- ❌ Save $10/month
- **New workflow**: Gemini → Qwen3.5 → Perplexity → Codestral (local, unlimited) → Claude 1x (premium only)

### Recommended Pre-June 1 Action

**Before June 1 cutover**:
1. [ ] Test GPT-4.1 through Copilot Pro if available in beta
2. [ ] Measure actual credit consumption for sample task
3. [ ] Check GitHub billing page for cost multipliers
4. [ ] Decide: Keep Pro ($10) or downgrade to Free ($0)?

**After June 1**:
1. [ ] Verify GPT-4.1 is available in Copilot Pro
2. [ ] Run test task, measure credits
3. [ ] Calculate: cost per task via Copilot vs. local model
4. [ ] Make permanent subscription decision based on data

---

## Decision: Revised Routing Strategy (Post-June 1)

**THE FUNDAMENTAL SHIFT**: You're losing unlimited GPT-4.1 0x. Everything now has a cost.

**Two Possible Workflows**:

### Path A: Copilot Pro Becomes Primary Execution (IF GPT-4.1 Available + Reasonable Cost)

```
Planning: Gemini (0)
Triage: Qwen3.5 (0, local)
Validation: Perplexity (0)

IMPLEMENTATION:
├─ Simple fixes (RSpec, model, controller)
│  └─ Copilot Pro (1,000 credits/month budget)
│
├─ Complex multi-file work
│  └─ Local Codestral (unlimited) OR Copilot Pro (if budget)
│
└─ Rare architectural work
   └─ Claude 1x (premium, expensive)
```

**Sustainability**: 5-7 Copilot Pro tasks/month, 20+ local Codestral tasks/month

### Path B: Local Models Become Primary Execution (IF Copilot Pro Too Expensive)

```
Planning: Gemini (0)
Triage: Qwen3.5 (0, local)
Validation: Perplexity (0)

IMPLEMENTATION:
├─ All mechanical work (90%)
│  └─ Local Codestral (unlimited) OR Qwen3.5 (unlimited)
│
├─ When local models overwhelmed
│  └─ Copilot Pro (1,000 credits/month) OR Claude 1x
│
└─ Rare architectural work
   └─ Claude 1x (premium, expensive)
```

**Sustainability**: Unlimited local work, minimal Copilot/Claude spend

### Updated AI Stack (June 1+, Post-Decision)

**OPTION A: Keep Copilot Pro** (if GPT-4.1 available + ≤0.5x cost)

| Tier | Agent | Cost | Role | Monthly Volume |
|---|---|---|---|---|
| **0-Token** | Gemini | 0 | Planner | Unlimited |
| **0-Token** | Qwen3.5 (local) | 0 | Detail, triage | Unlimited |
| **0-Token** | Perplexity | 0 | Validation | Unlimited |
| **Paid** | Copilot Pro (1K credits) | $10/mo | Primary execution | 5-7 tasks |
| **Premium** | Claude 1x | 1x cost | Rare complex work | 1-2 tasks |

**OPTION B: Downgrade to Copilot Free** (if Pro too expensive)

| Tier | Agent | Cost | Role | Monthly Volume |
|---|---|---|---|---|
| **0-Token** | Gemini | 0 | Planner | Unlimited |
| **0-Token** | Qwen3.5 (local) | 0 | Detail, triage, execution | Unlimited |
| **0-Token** | Codestral (local) | 0 | Primary execution | Unlimited |
| **0-Token** | Perplexity | 0 | Validation | Unlimited |
| **Free** | Copilot Free | 0 (completions only) | Inline suggestions | Unlimited |
| **Premium** | Claude 1x | 1x cost | Rare complex work | 1-2 tasks |

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
- ✅ Limited Copilot Pro budget (1K credits/month)
- ✅ Local Codestral/Qwen3.5 as overflow
- ✅ Must be strategic about which work goes where
- ⚠️ Need to track credit usage monthly

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

