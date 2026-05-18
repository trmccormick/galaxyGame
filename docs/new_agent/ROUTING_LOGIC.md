# Routing Logic — Quick Reference
**Last Updated**: 2026-05-17

> Full routing table and agent details are in `rules/AGENT_ROUTING.md`.
> This file is a quick-reference summary only.

---

## The One Rule

**Local models handle file reads and targeted edits.**
**Cloud agents handle reasoning, review, and planning.**
**Cloud agents never receive the full codebase — snippets only.**

---

## AI Stack at a Glance

| Agent | Cost | When to Use |
|---|---|---|
| Codestral (M4) | Free/local | Architecture, complex multi-file reasoning |
| Qwen3.5-27B (Windows) | Free/local | High-complexity coding, logic analysis, second opinion |
| Qwen3.5-9B (Windows) | Free/local | Primary coding workhorse, implementation, general tasks |
| Qwen3-30B (Windows) | Free/local | Legacy high-complexity tasks (migrating to 3.5 series) |
| Qwen2.5-14B (M4) | Free/local | Implementation, code refinement |
| Qwen2.5-3B (Windows) | Free/local | Small targeted edits, JSON, docs |
| Llama 3.1 8B (Windows) | Free/local | General tasks, lightweight chat |
| Claude (web) | Free tier | Planning sessions, documentation writing |
| Gemini (web) | Free | Galaxy Game review, plan preparation |
| Perplexity (web) | Free | Research, Samvera/Hyku docs lookup |
| GitHub Copilot | Tokens (conserve) | Work/Samvera tasks only — see note below |

> **Copilot note**: Token-based billing takes effect June 2026.
> Do not route Galaxy Game tasks to Copilot.
> Routing rules will be updated after Gemini research is complete.

---

## Quick Routing Table

| Task | Agent |
|---|---|
| Plan a session / triage failures | Claude (web) |
| First-level review, Galaxy Game | Gemini |
| Research Samvera/Hyku community | Perplexity |
| Architecture decision / multi-file design | Codestral (M4) |
| Audit logic before implementing | Codestral (M4) |
| Fix a single spec — cause is known | Qwen3.5-9B or Qwen2.5-3B |
| Fix a single spec — cause unknown | Codestral → Qwen3.5-9B |
| Multi-file refactor | Codestral synthesis → Qwen3.5-9B |
| Search the codebase | Qwen3.5-9B + Nomic Embed |
| Edit a JSON / small config file | Qwen2.5-3B |
| Write docs after a change | Qwen2.5-3B or Qwen3.5-9B |
| Complex logic / second opinion | Qwen3.5-27B (M4) or DeepSeek 16B (M4) |
| Work/Samvera tasks | Copilot (token budget aware) |

---

## Hard Rules

- M4 must stay caffeinated (`caffeinate` / `pmset`) for stable Ollama connection
- All codebase-wide scans go to local models — never send full codebase to cloud
- Cloud agents receive only the specific file snippets needed for the task
- One RSpec runner at a time — never run parallel spec execution
- Commits always from the Intel Mac (host/orchestration node)
- Do not route to Copilot until new routing rules are documented post-June 2026
