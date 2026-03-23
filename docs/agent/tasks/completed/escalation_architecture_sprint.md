# Escalation Architecture Sprint
**Status:** ✅ COMPLETE  
**Priority:** HIGH  
**Agent:** GPT-4.1 Copilot (Agent Mode)  
**Branch:** regional-view-phase2 (do NOT create a new branch)  
**Est:** 45-60min

---

## Critical Reading — Do This First, In This Order

**Step 1 — MANDATORY:** Read `docs/agent/README.md` completely.
This contains all rules for git commits, documentation standards,
RSpec testing, and agent behavior. Do not skip this. Do not proceed
until it is read. If you drift from these rules, you will be asked
to redo your work.

**Step 2:** Read `docs/ai_manager/RESUPPLY_AND_ESCALATION_ARCHITECTURE.md`
— the complete design this sprint implements. Understand it before
writing a single line of code.

**Step 3:** Read `docs/architecture/ai_manager/PLAYER_EMERGENCY_MISSION.md`
— emergency mission reward and trigger design.

**Step 4:** Read `docs/architecture/ai_manager/AI_PRIORITY_SYSTEM.md`
— priority tiers, especially debt_repayment.

**This sprint implements a specific, well-defined slice of a larger system.
Do not implement anything beyond what is listed here. Do not invent behavior
not described in the architecture document.**

---

## Context

The current run shows 174 failures. This sprint targets 8 of them —
the 3 integration spec failures and 5 unit spec failures, all in the
escalation service specs. All other failures are pre-existing and
are NOT our responsibility in this sprint.

---

# ✅ TASK COMPLETE — See commit and CURRENT_STATUS.md for results.
