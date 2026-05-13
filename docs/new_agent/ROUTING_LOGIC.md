# Routing Logic — Quick Reference
**Last Updated**: 2026-05-12

> Full routing table is in `rules/AGENT_ROUTING.md`.
> This file is a quick-reference summary only.

---

## The One Rule
**Local models handle file reads and targeted edits.
Cloud agents handle reasoning, investigation, and multi-file work.
Claude handles planning only — never implementation.**

---

## Quick Routing

| I need to... | Use |
|---|---|
| Plan a session / triage failures | Claude (premium gate) |
| Audit logic before implementing | Grok → Codestral after May 15 |
| Fix a single spec — cause is known | GPT-4.1 or Qwen2.5-3B |
| Fix a single spec — cause unknown | Grok → Codestral after May 15 |
| Multi-file refactor | Codestral synthesis → GPT-4.1 or Qwen3-30B |
| Search the codebase | Qwen3-30B + Nomic Embed (local) |
| Edit a JSON file | Qwen2.5-3B (local) |
| Write docs after a change | GPT-4.1 or Qwen2.5-3B |

---

## Hard Rules
- M4 must stay caffeinated (caffeinate / pmset) for stable connection
- All codebase-wide scans go to local models — never send full codebase to cloud
- Cloud agents receive only the specific file snippets needed for the task
- One RSpec runner at a time — never parallel
- Grok retires 2026-05-15 — all Grok tasks must complete before that date

---

## After May 15 (Grok Retired)
- Logic audits → Codestral (M4)
- Synthesis reports → Codestral (M4)  
- Second opinion → DeepSeek 16B (M4)
- If M4 unavailable → wait for next Claude premium gate

---

## June 2026
GitHub Copilot workflow changes take effect.
Update `AGENT_ROUTING.md` when Gemini's research on new Copilot
capabilities is complete. Do not route tasks to Copilot until
routing rules are formally documented here.
