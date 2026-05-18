# Agent Routing
**Last Updated**: 2026-05-12
**Maintained By**: Session Strategist (Claude)

> Read DECISIONS.md before this file.
> Routing decisions here are based on actual model capabilities, not just cost.

---

## The Cluster

### Cloud Agents
| Agent | Cost | Capability | Available Until |
|---|---|---|---|
| Claude | Premium | Planning, strategy, architecture gates | Gates only |
| Grok | 0.25x | Logic audit, synthesis reports, investigation | RETIRED 2026-05-15 |
| GPT-4.1 | 0x free | Mechanical implementation, file tasks | Ongoing |
| Haiku 4.5 | 0.33x | Implementation, spec fixes, handoffs | Weekly limit applies |
| Perplexity/Gemini | Manual | Strategist fallback when Claude unavailable | Manual only |

### Local Agents (via Continue on Intel Mac)
| Model | Node | IP | Best For |
|---|---|---|---|
| Codestral | M4 | 10.6.186.161 | Architecture reasoning, synthesis before implementation |
| Qwen2.5-Coder 14B | M4 | 10.6.186.161 | Multi-file implementation with context |
| DeepSeek-Coder 16B | M4 | 10.6.186.161 | Logic verification, second opinion |
| Qwen3-Coder 30B | Windows | 10.6.186.50 | Heavy implementation, primary local worker |
| Qwen2.5-Coder 3B | Windows | 10.6.186.50 | Fast single-file edits |
| Llama 3.1 8B | Windows | 10.6.186.50 | Fallback chat only — not for implementation |
| Nomic Embed | Windows | 10.6.186.50 | RAG/codebase indexing — always on, never reassign |
| Qwen2.5-Coder 1.5B | Windows | 10.6.186.50 | Tab autocomplete — always on, never reassign |

---

## Critical Local Model Limitations

> These limitations apply to ALL local models via Continue.
> Violating these rules produces fabricated output that looks real.

### What local models CAN do
- Create and edit files when exact content is provided
- Read files that Continue can access on the filesystem
- Apply specific code changes with clear before/after
- List directory contents via Continue file tools

### What local models CANNOT do
- Execute terminal commands (no shell access)
- Run Docker commands or RSpec
- Run git commands
- Access the internet or external APIs
- Know which tests are currently failing without being told
- Analyze real runtime behavior without actual output provided

### The Fabrication Rule — CRITICAL
**Local models MUST NOT report output from commands they did not actually run.**

If asked to analyze test failures without actual test output provided:
- ✅ CORRECT: "I can see these spec files exist but I cannot report which are failing. Please run the tests and paste the output."
- ❌ WRONG: Inventing a list of failing tests based on file names seen in the directory

If asked to run a command the model cannot execute:
- ✅ CORRECT: "I cannot execute this command. Please run it on the host and paste the output."
- ❌ WRONG: Fabricating what the output would look like

**Mixing real file data with fabricated command output is the most dangerous failure mode.**
A document that is 30% real makes the 70% fabrication look credible.

### RAG Status Warning
Local model codebase search is only reliable when Nomic Embed has actively indexed
the codebase. If RAG status is unknown, use a cloud agent for any codebase search.

---

## Routing Table

### Planning & Strategy
| Task | Agent | Reason |
|---|---|---|
| Session triage and priority stack | Claude | Premium gate only |
| Produce task files | Claude | Premium gate only |
| Session handoff review | Claude | Premium gate only |
| Perplexity/Gemini fallback planning | Perplexity or Gemini | Manual — when Claude not available |

### Investigation & Synthesis
| Task | Agent | Reason |
|---|---|---|
| Read 8+ files and produce risk report | Grok (until May 15) then Codestral | Cross-file reasoning |
| Logic audit before implementation | Grok (until May 15) then DeepSeek 16B | Needs judgment |
| Codebase search and summarize | Qwen3-30B + Nomic Embed | Fully local, RAG-assisted |
| Identify root cause from error | Grok (until May 15) then Codestral | Pattern recognition |

### Implementation
| Task | Agent | Reason |
|---|---|---|
| Single file edit — exact before/after specified | Qwen2.5-Coder 3B or GPT-4.1 | Mechanical |
| Single file edit — needs some inference | Qwen2.5-Coder 14B | Better context handling |
| Multi-file refactor — patterns specified | GPT-4.1 or Qwen3-30B | Heavy lifting |
| Multi-file refactor — needs reasoning | Codestral → Qwen2.5-14B | Architect then implement |
| Create missing fixture or config file | GPT-4.1 | Zero reasoning needed |
| Factory trait fix | GPT-4.1 | Mechanical |
| Add logger call to rescue block | GPT-4.1 | Mechanical |
| Architecture refactor | Codestral synthesis → GPT-4.1 implement | Never skip synthesis |

### Data & JSON
| Task | Agent | Reason |
|---|---|---|
| JSON file edits — small targeted | Qwen2.5-Coder 3B | Fast, low risk |
| JSON file audits — cross-file validation | Grok or Codestral | Needs judgment |
| Large JSON generation | GPT-4.1 | Free, handles volume |

### Documentation
| Task | Agent | Reason |
|---|---|---|
| Update .md files after code change | Qwen2.5-Coder 3B or GPT-4.1 | Mechanical |
| Write new architecture docs | Claude | Premium gate |
| Session handoff document | GPT-4.1 or Grok | End of session |

### Repository Operations
| Task | Agent | Reason |
|---|---|---|
| Codebase-wide grep/search | Local M4 or Windows via Continue | Never send full codebase to cloud |
| git add / commit / push | Human on host only | No agent commits without human review |
| File moves and renames | Human on host | Simple terminal commands |

---

## Decision Rules

### When to use cloud vs local
- **Cloud first** if: task needs cross-session memory, complex reasoning across 5+ files,
  or architectural judgment
- **Local first** if: task is a targeted file edit, search, or follows an explicit pattern

### When NOT to use GPT-4.1
- Tasks requiring investigation before fixing — use Grok or Codestral first
- Architecture decisions — always Claude or Codestral synthesis first
- Anything touching BaseUnit, concerns, or shared services without a synthesis report

### When NOT to use local models
- Tasks requiring knowledge of project history or prior decisions
- Anything that needs to read DECISIONS.md and reason about conflicts
- Session planning and priority stacking

### After Grok Retires (May 15, 2026)
- Logic audits → Codestral (M4)
- Synthesis reports → Codestral (M4)
- Investigation → DeepSeek 16B (M4) for second opinion
- If M4 unavailable → Claude at next premium gate

---

## June 2026 Changes
Update this file when GitHub Copilot workflow changes take effect in June.
Gemini is researching the new Copilot capabilities — update routing table
when that research is complete.

---

## Communication Protocol
All agents must output a raw code block for any file changes.
Precede every block with `[CODE_PAYLOAD: path/to/file]` to ensure
work can be recovered if the file-write tool fails.
