# 2026-03-23-CRITICAL-TASK-WEDNESDAY-SURGICAL-AUDIT

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: Claude 1x — Critical architecture documentation task requiring high reasoning for content extraction
**Supervision Level**: Standard

## Context
GUARDRAILS.md contains mixed logic with "Wormhole Anchor Law" and "Economic Overheads" alongside agent operating rules. Need to extract game design logic into specialized docs without losing nuances.

## Problem Statement
GUARDRAILS.md contains 681 lines of mixed agent rules and game design logic. Makes it hard to find information. Need to split into specialized docs.

**Expected**: GUARDRAILS.md < 150 lines with strictly technical agent protocols. Game design logic moved to appropriate docs.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `docs/GUARDRAILS.md` | Source file | Extract game design logic, keep agent protocols |
| `docs/architecture/` | Target docs | Move Wormhole Anchor Law, Economic Overheads |
| `docs/mission_profiles/` | Target docs | Move Mission logic |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/GLOSSARY_SYSTEM_MECHANICS.md` | Verify economic constants match |

## Implementation Steps
1. **Analyze GUARDRAILS.md**: Locate Wormhole Anchor Law and Economic Overheads sections
2. **Verify against Glossary**: Ensure 0.5% SCC, 0.3% Broker, 3.37% Sales Tax match GLOSSARY_SYSTEM_MECHANICS.md
3. **Execute split**: Move Game Design logic to docs/architecture/ and Mission logic to docs/mission_profiles/
4. **Clean root**: Leave only Agent Operating Rules (Git, Docker, Atomic Commits) in GUARDRAILS.md

## Acceptance Criteria
- [ ] GUARDRAILS.md is < 150 lines and contains strictly technical agent protocols
- [ ] No game design logic remains in the root Guardrails

## Stop Conditions
- Economic constants don't match Glossary — verify and update
- Game design logic extraction loses important nuances — stop and ask

## Commit Instructions
```bash
git add docs/GUARDRAILS.md
git add docs/architecture/
git add docs/mission_profiles/
git commit -m "docs: surgical guardrails audit — extract game design logic to specialized docs"
```