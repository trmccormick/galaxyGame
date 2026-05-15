# Task Overview — Current Session
**Last Updated**: 2026-05-14
**Branch**: `regional-view-phase2`
**Baseline**: 3956 examples, 22 failures, 57 pending

> This file tracks the current session's task stack.
> It is written by the planning agent (Claude or Gemini) at session start
> and updated as tasks complete. Individual task files live in `tasks/active/`.

---

## Session Goal

Reduce RSpec failures from 22 toward 0.
Monthly milestone: Luna settled, ISRU producing, AI Manager trained on pattern.

---

## Priority Stack

Tasks are listed in execution order. Do not skip ahead — later tasks may
depend on earlier ones passing specs cleanly.

| Priority | Task File | Agent | Status |
|---|---|---|---|
| — | *(populate at session start)* | — | — |

---

## Game Economy Reference

These values are locked in `rules/DECISIONS.md`. Do not change them
without a formal decision record.

| Parameter | Value |
|---|---|
| Currency Peg | 1 USD = 1 GCC (Galactic Crypto Currency) |
| SCC Surcharge (PLEX trading) | 0.5% |
| Broker Fee (PLEX trading) | 0.3% |
| Sales Tax (PLEX trading) | 3.37% |
| Manufacturing logic | Market vs. Build balance |

---

## How to Use This File

**Planning agent (Claude/Gemini)** — at session start:
1. Review last session handoff in `tasks/session-handoffs/`
2. Check current RSpec baseline
3. Populate the Priority Stack table above
4. Create individual task files in `tasks/active/`
5. Update this file's Last Updated date and baseline numbers

**Implementation agent** — during session:
1. Read this file to understand session context
2. Work only your assigned task from `tasks/active/`
3. Update Status column when complete
4. Do not reprioritize — flag conflicts to human

**At session end**:
1. Archive completed tasks to `tasks/completed/`
2. Write session handoff to `tasks/session-handoffs/session_handoff_YYYY-MM-DD.md`
3. Update baseline numbers in this file for next session
