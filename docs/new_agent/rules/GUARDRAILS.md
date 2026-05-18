# Operational Guardrails
**Last Updated**: 2026-05-12
**Maintained By**: Session Strategist (Claude)

> Read before every task. These rules are non-negotiable.
> If a task file conflicts with these rules, STOP and flag before proceeding.

---

## Core Execution Rules

### Rule 1 — Docker
All Rails and RSpec commands MUST run inside Docker using:
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec [command]'
```
Never use `docker compose exec` — use `docker exec -it web`.
Never run Rails or RSpec on the host system directly.

### Rule 2 — Git and File System
Git commands, file moves, file creation, and folder operations
MUST happen on the Host (Mac/Windows terminal).
Never run git inside Docker.

### Rule 7 — RSpec Output
Always capture and display the FULL RSpec output including:
- All failure messages verbatim
- Full stack traces
- Summary line (X examples, Y failures, Z pending)
Never summarize or truncate RSpec output unless explicitly told to.
For large suites redirect to a log file:
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [spec] 2>&1 | tee /tmp/rspec_output.log && tail -30 /tmp/rspec_output.log'
```

### Rule 10 — Host vs Docker Paths
The host path and Docker path are different:
- **Host**: `galaxy_game/app/models/...`
- **Docker**: `/home/galaxy_game/app/models/...`
Always use the correct path context for commands and file references.
Task files use Docker paths for commands, host paths for git operations.

---

## Documentation Rules

### Rule 11 — Atomic Documentation
`TASK_OVERVIEW.md` must be updated BEFORE any task is marked In Progress or Complete.

### Rule 12 — Task File Lifecycle
Every task follows this exact path:
```
backlog/ → active/ → (work happens) → completed/
```
A task in active/ with no completion report is abandoned — flag it.
Never leave a task in active/ after work is done.

### Rule 13 — Handoff Commands
Reserve strategic context for handoff commands.
Keep active implementation discussion focused on the current sub-task only.
When switching tasks, produce a new handoff command — do not carry context forward.

### Rule 14 — Code Payload Protocol
All agents must output a raw code block for any file changes.
Precede every block with `[CODE_PAYLOAD: path/to/file]`:
```
[CODE_PAYLOAD: app/models/units/habitat.rb]
```ruby
module Units
  class Habitat < BaseUnit
    ...
  end
end
```
This ensures work can be recovered if the file-write tool fails.

---

## Economic Rules

### Rule 15 — Financial Constants
All financial calculations must strictly adhere to DECISIONS.md:
- 1:1 USD/GCC peg — no conversion logic
- SCC Surcharge: 0.5%
- Broker Fee: 0.3%
- Sales Tax: 3.37%
- Lunar loss rate: 15% on iron and silicate sourcing

Never hardcode these values in Ruby — read from game constants.

---

## Safety Rules

### Rule 16 — No Parallel RSpec Runners
Only ONE implementation agent runs RSpec at a time.
Task creation, documentation, and research can run in parallel.
Implementation cannot.

### Rule 17 — Synthesis Before Implementation
Any task touching BaseUnit, shared concerns, or services used across
multiple models MUST have a Synthesis Report approved before any code changes.
No exceptions.

### Rule 18 — Integration Specs Are Quarantined
Do not assign work on integration specs until unit/service layer is clean.
Integration specs that fail are noted but not touched.
They will self-resolve as unit specs green up.

### Rule 19 — Stop Conditions
Stop immediately and report to human if:
- A currently passing spec breaks after your change
- Same failure persists after two fix attempts
- Root cause is in a shared concern or base class
- A database migration is needed
- Any architectural decision is required
- Fix requires changing more files than the task specifies

### Rule 20 — Local Model Fabrication Prohibition
**Applies to all local models running via Continue.**

Local models CANNOT execute terminal commands, Docker, RSpec, or git.
Local models CAN read files and create/edit files via Continue.

If a task requires command execution:
- Ask the human to run the command and paste the output
- Never fabricate what the output would look like
- Never mix real file data with invented command results

If asked to analyze test failures:
- Only report failures that were provided as input
- Never invent failure lists from directory listings
- State clearly: "I cannot run tests. Please provide the test output."

Fabricated output that looks real is more dangerous than obvious failure.
A model that says "I can't do this" is always preferable to one that invents results.

### Rule 21 — Qwen3.5 Triage Phase Requirements
**Applies to Continue-based Qwen3.5 models during task triage.**

When Qwen3.5 is triaging task files, it MUST:
1. Add frontmatter fields: `status`, `priority`, `type`, `system_domain`, `mvp_alignment`, `local_worker_safe`
2. Add "Local Worker Triage Report" section with:
   - Template Conformance: PASS/FAIL
   - Docker Wrapper Check: PASS/FAIL/N/A
   - MVP Alignment: VALID/STALE/OBSOLETE
   - MVP Impact Note: one-line connection to goal
   - Action Line: READY FOR CLOUD HANDOFF | NEEDS MANUAL REVIEW | OBSOLETE
3. Verify Agent Assignment is present with "Why This Agent" rationale
4. Add implementation steps if not present or enhance if incomplete
5. Add code examples/PORO patterns where applicable
6. Cross-reference DECISIONS.md and GUARDRAILS.md

**Triage Phase Output Quality**: Task file should be 100% ready for cloud agent handoff with no additional human specification needed.

### Rule 22 — Continue Model Scope Limits
**Applies to all Continue agents (any model/size).**

Continue models have these fixed constraints:
- ✅ CAN read task files, model definitions, service code, specs
- ✅ CAN understand Rails patterns and Ruby syntax
- ✅ CAN generate code examples and PORO patterns
- ✅ CAN verify template conformance structurally
- ❌ CANNOT execute terminal commands or shell scripts
- ❌ CANNOT run Docker, RSpec, or rails commands
- ❌ CANNOT execute git commands
- ❌ CANNOT verify code actually works
- ❌ CANNOT access the live database
- ❌ CANNOT see which tests are currently failing

When a Continue model hits these limits:
- ✅ CORRECT: "I cannot run this test. Please paste the RSpec output and I'll analyze it."
- ✅ CORRECT: "This code requires database verification. Please check the schema."
- ❌ WRONG: Inventing what the test output would be
- ❌ WRONG: Assuming database schema based on Rails conventions

### Rule 23 — Token Conservation (Core Strategy)
**Applies to all agents in the planning/triage/implementation chain.**

Token conservation is THE core constraint. Follow this hierarchy:

1. **0 Token Tier (Always Use First)**
   - Gemini for planning/triage (web, free tier)
   - Qwen3.5 for task detailing (Continue, local)
   - Perplexity for task validation (web, free tier)
   - Local models for implementation synthesis (Continue, 0 tokens)
   - GPT-4.1 0x for mechanical implementation (free tier)

2. **Free Token Tier (Use if 0-token option exhausted)**
   - Claude free web (~0 tokens) for alignment checks only
   - Haiku 0.33x for fast fixes on well-specified tasks

3. **Premium Tier (RESERVE for complex work)**
   - Claude 1x only when:
     - Codestral synthesis insufficient
     - Cross-session memory required
     - New architectural pattern design needed
   - Use sparingly — maybe once per month

**Golden Rule**: If a task can be completed with 0 tokens, using premium tokens is a bug.

### Rule 24 — Perplexity Workflow Integration
**Applies to task validation phase before cloud agent handoff.**

Perplexity's role in the workflow:

1. **Task Clarity Validation**: "Is this task clear enough for GPT-4.1?"
   - Review Qwen3.5 output for ambiguities
   - Flag if acceptance criteria are testable
   - Verify docker commands are correct

2. **Routing Verification**: "Is this task routed to the right agent?"
   - Confirm task complexity level matches agent tier
   - Check if parallelization is safe
   - Suggest re-routing if needed

3. **Workflow Management**: "Can we run these tasks in parallel?"
   - Review task dependencies
   - Identify blocking relationships
   - Optimize execution order

**Perplexity does NOT replace task creation** — it validates Qwen3.5 output before cloud handoff.
