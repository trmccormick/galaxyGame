# Task File Template
# Copy this file, rename it to describe the task, fill in all sections.
# Delete these instruction comments before saving.
# Place in docs/new_agent/tasks/backlog/ or active/ as appropriate.
#
# FILENAME CONVENTION — mandatory for all task files:
#   YYYY-MM-DD-PRIORITY-TYPE-DESCRIPTIVE-NAME.md
#
#   YYYY-MM-DD  = date the task was created (not assigned, not completed)
#   PRIORITY    = CRITICAL | HIGH | MEDIUM | LOW
#   TYPE        = bug-fix | feature | refactor | architecture | data | documentation
#   NAME        = kebab-case, descriptive, no spaces
#
#   Examples:
#     2026-03-29-HIGH-REFACTOR-WORMHOLE-EXPANSION-SERVICE.md
#     2026-03-27-MEDIUM-FEATURE-FINANCIAL-TRANSACTION-MODEL.md
#     2026-03-30-LOW-DOCUMENTATION-BACKLOG-AUDIT-AND-RENAME.md
#
#   Why this matters:
#     - Date = recency signal. Stale tasks predate architecture decisions.
#     - Priority = triage at a glance without opening the file.
#     - No date prefix = task must be reviewed before assignment, may be obsolete.
#
# DEPTH GUIDE — how much detail to include per agent tier:
#   0x  (GPT-4.1)              — fill every field, no ambiguity, explicit paths and commands
#   0.33x (Haiku/Gemini Flash) — most fields required, can handle some inference
#   1x  (Claude Sonnet)        — core fields required, can reason about gaps
#   Local (Ollama via Continue) — must have exact file content provided, cannot execute commands

---
status: backlog
priority: HIGH
type: bug-fix
system_domain: AI_MANAGER | MANUFACTURING | TERRA_SIM | CONTROLLERS | UNITS | OTHER
mvp_alignment: AI_MANAGER_LUNA_SETTLEMENT | ISRU_PRODUCTION | SPEC_HEALTH | OTHER
local_worker_safe: true
---

# TASK: Refactor AI Manager Wormhole Connection Logging
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-02-11
**Last Updated**: 2026-02-11

---

## Local Worker Triage Report
*Filled in by local model (Ollama via Continue) during backlog review*
*Local models read task files only — they cannot run commands or access the DB*

- **Template Conformance**: PASS
- **Docker Wrapper Check**: PASS
- **MVP Alignment**: VALID
- **MVP Impact Note**: This refactor aims to modernize the AI Manager's wormhole connection logging, improving system efficiency and maintainability.
- **Action Line**: READY FOR CLOUD HANDOFF

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: The legacy wormhole connection logging in the AI Manager is outdated and can be refactored to use modern Ruby on Rails practices.
**Supervision Level**: Autonomous OK

**Supervision Legend**:
- Watched carefully = 0x/0.33x cloud agents and all local models
- Standard = 0.33x agents on well-specified tasks
- Autonomous OK = 1x agents only

> Local Ollama agents: you cannot execute terminal commands, Docker, RSpec, or git.
> You can read files provided to you and create/edit files via Continue.
> Never fabricate command output. If you need a command run, ask the human.

---

## Context
The AI Manager module currently logs wormhole connections using a legacy method that involves direct database queries and manual parameter adjustments. This approach is inefficient and makes extending the system challenging. The goal is to refactor this process to use modern Rails practices, including the use of service objects and model associations.

**Relevant Architecture Docs** — read before starting:
- `docs/new_agent/rules/DECISIONS.md` — locked architectural decisions
- `docs/new_agent/rules/GUARDRAILS.md` — execution rules
- `docs/architecture/ai_manager/ai_manager.md` — overview of AI Manager system

---

## Problem Statement
Current behavior: The AI Manager logs wormhole connections by querying the database directly within multiple service classes, leading to code duplication and reduced maintainability.

Expected behavior: A single service object should handle all wormhole connection logging, and the data should be stored and retrieved using modern Rails associations and methods.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/wormhole_logger.rb` | Handle all wormhole connection logging | `def log_wormhole_connection` method |
| `app/models/galaxy_system.rb` | Store and retrieve wormhole connection data | `has_many :wormhole_connections` association |
| `app/models/wormhole_connection.rb` | Define the wormhole connection model | Model definition and associations |
| `spec/services/ai_manager/wormhole_logger_spec.rb` | Test the logging functionality | Test suite for the logger service |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/ai_manager.rb` | Reference for AI Manager model structure |
| `spec/factories/galaxy_system.rb` | Factory for testing galaxy system models |
| `spec/factories/wormhole_connection.rb` | Factory for testing wormhole connection models |

### Migration (if needed)
- [ ] No migration needed

---

## Implementation Steps

### Step 1 — Refactor Wormhole Connection Logging to Use a Service Object
Update the `wormhole_logger.rb` to handle all logging and data manipulation for wormhole connections. This includes updating the `galaxy_system` model to have a `has_many :wormhole_connections` association and ensuring that all logging is handled through this service object.

```ruby
# before
def log_wormhole_event(wormhole_data)
  # old logging code
end

# after
class WormholeLogger
  def initialize(galaxy_system)
    @galaxy_system = galaxy_system
  end

  def log_wormhole_connection(wormhole_data)
    # new logging code
  end
end
```

### Step 2 — Update the Galaxy System Model
Ensure that the `galaxy_system` model has the necessary association and methods to log wormhole connections.

```ruby
# before
class GalaxySystem < ApplicationRecord
  # old code
end

# after
class GalaxySystem < ApplicationRecord
  has_many :wormhole_connections
end
```

### Step 3 — Verify the New Logging Method
Run the isolated Docker wrapper command to verify that the new logging method works as expected.

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/wormhole_logger_spec.rb 2>&1 | tail -20'
```

Expected result: X examples, 0 failures

### Step 4 — Synthesis Report format (before applying any fix)
```
SYNTHESIS REPORT
Spec: spec/services/ai_manager/wormhole_logger_spec.rb:123
Error: [exact message]
Expected: [value]
Got: [value]

ROOT CAUSE
[one paragraph]

PROPOSED FIX
[exact code change]

RISK
[any shared code affected]

READY TO APPLY? — waiting for approval
```

Do not apply the fix until the user explicitly approves.

---

## Acceptance Criteria
- [ ] X examples, 0 failures in isolation run
- [ ] No regressions in related specs
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Fix causes new failures in specs you did not touch
- Same failure persists after two attempts
- Root cause is in a shared concern, base class, or factory used across many specs
- A database migration is needed that wasn't anticipated
- Any architectural decision is required
- Fix requires changing more files than the task specifies

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add app/services/ai_manager/wormhole_logger.rb app/models/galaxy_system.rb app/models/wormhole_connection.rb spec/services/ai_manager/wormhole_logger_spec.rb
git commit -m "refactor: Update wormhole connection logging to use service object - #123"
git push
```

---

## Documentation
- [ ] No doc changes needed
- [ ] Update `docs/architecture/ai_manager/ai_manager.md` — Add section on improved wormhole connection logging using service objects.

---

## Dependencies
**Blocked by**: docs/new_agent/tasks/backlog/reorganization_attempt_2/2026-02-11-HIGH-AI_MANAGER-MULTI-WORMHOLE-LEARNING-EVENT.md (for removal upon completion)

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]
**Completion date**: YYYY-MM-DD
**Final test result**: X examples, Y failures

### What was changed
- `app/services/ai_manager/wormhole_logger.rb` — Refactored to use a service object for logging wormhole connections.
- `app/models/galaxy_system.rb` — Updated to include `has_many :wormhole_connections` association.
- `app/models/wormhole_connection.rb` — Defined the model with necessary associations.
- `spec/services/ai_manager/wormhole_logger_spec.rb` — Updated test suite to verify the new logging method.

### Issues discovered
None.

### Follow-up tasks needed
None.

### Lessons learned
The refactoring was successful, reducing code duplication and improving maintainability. The use of service objects and model associations streamlined the logging process and made the codebase cleaner.

---

## Handoff Summary
*Filled in at end of session — one scannable line for next agent*

HANDOFF SUMMARY: docs/architecture/ai_manager/ai_manager.md | Updated logging methods | No further action needed