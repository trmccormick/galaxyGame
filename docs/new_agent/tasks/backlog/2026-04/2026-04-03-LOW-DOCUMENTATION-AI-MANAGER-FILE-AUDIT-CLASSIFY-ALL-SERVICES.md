# 2026-04-03-LOW-DOCUMENTATION-AI-MANAGER-FILE-AUDIT-CLASSIFY-ALL-SERVICES

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Read-only audit and classification of AI Manager services
**Supervision Level**: 🔴 Watched carefully

## Context
The app/services/ai_manager/ directory contains ~83 files. Only 5 files reference real application services. The remaining ~78 files may contain real game logic, invented parallel logic, or duplicates. This audit classifies every file before any changes are made.

## Problem Statement
Need to classify all AI Manager service files to determine:
- Which contain real game logic worth preserving
- Which are invented parallel implementations
- Which duplicate existing services
- Which can be safely archived

**Current behavior**: Unknown status of 78+ files
**Expected behavior**: Complete classification of all files with preservation recommendations

## Files Involved
### Primary Files — you will read
| File | Purpose |
|---|---|
| `app/services/ai_manager/*.rb` | All AI Manager service files (~83 total) |
| `spec/services/ai_manager/*_spec.rb` | Corresponding spec files |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/agent/ai_manager/AI_MANAGER_COMMAND.md` | AI Manager command structure |
| `docs/agent/ai_manager/AI_MANAGER_ROLE.md` | AI Manager role definition |
| `docs/agent/README.md` | Agent documentation standards |

## Implementation Steps
1. **Read mandatory docs**: AI_MANAGER_COMMAND.md, AI_MANAGER_ROLE.md, AI_MANAGER_DAMAGE_INVENTORY.md
2. **Audit in batches**: Work through 7 batches of files systematically
3. **Classify each file**: Answer 4 questions (real services, hardcoded data, specs, external callers)
4. **Document findings**: Use exact output format for each file
5. **Generate summary**: Count classifications and provide recommendations

## Acceptance Criteria
- [ ] All ~83 files audited and classified
- [ ] Classification uses exact format (CORE/LEGITIMATE/INVENTED/DUPLICATE/UNKNOWN)
- [ ] Files with Luna/ISRU/TEU/PVE logic flagged
- [ ] Files referencing EscalationService flagged
- [ ] Complete summary counts and next action recommendations provided

## Stop Conditions
- File deletions or modifications attempted
- RSpec execution during audit
- Incomplete batch processing

## Commit Instructions
```bash
git add docs/agent/ai_manager/AI_MANAGER_FILE_AUDIT_2026-04-03.md
git commit -m "docs: AI Manager file audit — classify all 83 services"
```