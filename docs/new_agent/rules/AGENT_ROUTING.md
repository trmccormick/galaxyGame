# Agent Routing
**Last Updated**: 2026-05-12
**Maintained By**: Session Strategist (Claude)

> Read DECISIONS.md before this file.
> Routing decisions here are based on actual model capabilities, not just cost.

---

## The Cluster

### Planning Gate (ALWAYS FIRST)
| Agent | Role | Cost | Status |
|---|---|---|---|
| **Gemini** | PRIMARY planner, session triage | Free web | Always available |
| Claude | Secondary planning (Gemini fallback) | Premium | Gates only |
| Perplexity | Research fallback | Free web | Manual only |

---

### Triage & Detailing Phase (NEW — May 2026)
| Model | Node | Provider | Role |
|---|---|---|---|
| **Qwen3.5 27B** | M4 | Continue | Heavy auditing, complex multi-file reasoning, architectural gap checking |
| **Qwen3.5 9B** | M4 / Windows | Continue | Markdown formatting, template conformance, implementation detail |

**What Qwen3.5 does in this phase**:
- ✅ Reads task files from backlog
- ✅ Verifies template conformance against TASK_TEMPLATE.md
- ✅ Assesses MVP alignment (valid vs. stale vs. obsolete)
- ✅ Adds implementation detail, code examples, acceptance criteria
- ✅ Produces "Local Worker Triage Report" section
- ✅ Routes to appropriate cloud agent

**Output**: Detailed task file + triage report → Cloud agent gets fully-specified task

---

### Cloud Implementation Agents
| Agent | Cost | Capability | When to Use |
|---|---|---|---|
| Gemini | Free web | Strategic decisions after triage | Rarely — already used for planning |
| Claude Sonnet | 1x | Complex reasoning, architecture | Blocked until Gemini detail is approved |
| GPT-4.1 | 0x free | Mechanical implementation | Standard for Qwen3.5-prepared tasks |
| Haiku 4.5 | 0.33x | Fast implementation, spec fixes | Well-specified tasks from Qwen3.5 |

---

### Local Execution Agents (via Continue on Intel/M4/Windows)
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

### Planning Gate (Session Start)
| Task | Agent | Reason |
|---|---|---|
| Session triage and priority stack | Gemini | PRIMARY gatekeeper |
| Produce initial task recommendations | Gemini | Understand MVP alignment |
| Route tasks for Qwen3.5 triage vs direct handoff | Gemini | Quality assessment |

### Qwen3.5 Triage Phase (All Tasks)
| Task | Agent | Reason |
|---|---|---|
| Read backlog task files and assess | Qwen3.5 27B (M4) | Heavy reasoning, multi-file |
| Verify template conformance | Qwen3.5 9B (M4 or Windows) | Structural analysis |
| Add implementation detail, code examples | Qwen3.5 (either size) | Code pattern understanding |
| Identify MVP alignment | Qwen3.5 27B (M4) | Requires reasoning |
| Produce triage report | Qwen3.5 (either size) | Structured output |
| Route to cloud agent | Qwen3.5 27B (M4) | Complex decision-making |

**Output from this phase**: Task file with "Local Worker Triage Report" + detailed implementation steps

### Investigation & Synthesis (After Triage)
| Task | Agent | Reason |
|---|---|---|
| Cross-file reasoning (8+ files) | Claude Sonnet (1x) | Only after Qwen3.5 triage |
| Logic audit before implementation | Claude or Codestral | Judgment call on architecture |
| Codebase search | Qwen3-Coder 30B + Nomic Embed | RAG-assisted local search |
| Identify root cause from error | Claude or Codestral | Pattern recognition |

### Implementation (Cloud Agents)
| Task | Agent | Reason |
|---|---|---|
| Single file edit — exact specs from Qwen3.5 | GPT-4.1 0x or Haiku 0.33x | Mechanical, well-prepared task |
| Single file edit — needs some inference | GPT-4.1 0x | Better context handling |
| Multi-file refactor — patterns specified | GPT-4.1 0x or Claude 1x | Heavy lifting |
| Multi-file refactor — needs reasoning | Codestral → GPT-4.1 | Architect then implement |
| Create missing fixture or config | GPT-4.1 0x | Mechanical |
| Factory trait fix | GPT-4.1 0x | Mechanical |
| Add logger call to rescue block | GPT-4.1 0x | Mechanical |
| Architecture refactor | Claude 1x (synthesis only) → GPT-4.1 | Never skip synthesis |

### Data & JSON
| Task | Agent | Reason |
|---|---|---|
| JSON file edits — small targeted | Qwen2.5-Coder 3B (Windows) | Fast, low risk |
| JSON file audits — validation | Qwen3.5 27B (M4) | Needs judgment |
| Large JSON generation | GPT-4.1 0x | Free, handles volume |

### Documentation
| Task | Agent | Reason |
|---|---|---|
| Update .md files after code change | Qwen2.5-Coder 3B or GPT-4.1 | Mechanical |
| Write new architecture docs | Claude 1x | Premium gate |
| Session handoff document | GPT-4.1 0x or Haiku 0.33x | End of session |
| Update task files (post-implementation) | GPT-4.1 0x | Mechanical update |

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
