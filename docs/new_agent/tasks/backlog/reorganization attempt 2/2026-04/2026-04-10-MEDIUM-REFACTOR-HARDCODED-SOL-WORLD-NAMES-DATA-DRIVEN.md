# 2026-04-10-MEDIUM-REFACTOR-HARDCODED-SOL-WORLD-NAMES-DATA-DRIVEN

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Audit and refactor hardcoded Sol world names to data-driven approach
**Supervision Level**: 🔴 Watched carefully

## Context
Game supports multiple star systems beyond Sol, but services hardcode Sol world names (Mars, Venus, Titan, Europa) in case statements and string matching. This doesn't scale - adding new worlds requires hunting down case statements across services.

## Problem Statement
Services pattern-match on celestial body names/classes to determine orbital altitudes, construction strategies, resource availability, etc. Should be data-driven: celestial bodies carry their own operational attributes.

**Core principle**: Services ask the celestial body what it is, don't pattern-match on name to decide behavior.

## Files Involved
### Primary Files — you will read
| File | Purpose |
|---|---|
| `app/services/ai_manager/depot_adapter.rb` | Example of hardcoded calculate_orbital_altitude |
| `app/models/celestial_bodies/` | Celestial body models and attributes |
| `data/json-data/` | Celestial body operational data |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `db/schema.rb` | Celestial body classification attributes |
| All service files with hardcoded world names | Services to audit |

## Implementation Steps
1. **Find all hardcoded references**: Grep for Mars, Venus, Titan, Europa, etc. in services/models
2. **Classify each reference**: Data lookup (acceptable), behavior branch (must refactor), string construction (acceptable), comments (ignore)
3. **Identify underlying attributes**: What each behavior branch is really about (orbital altitude, gravity, atmosphere type, etc.)
4. **Audit celestial body data**: Check if orbital altitude, classification attributes already exist
5. **Recommend data-driven pattern**: How to replace behavior branches with attribute reads

## Acceptance Criteria
- [ ] All hardcoded Sol world name behavior branches identified
- [ ] Each classified and underlying attribute identified
- [ ] Celestial body data audited for existing attributes
- [ ] Recommended data-driven pattern documented
- [ ] Implementation phases defined
- [ ] No code changes made

## Stop Conditions
- More than 50 Type B references found
- Schema changes required for celestial body classification

## Commit Instructions
```bash
git add docs/architecture/hardcoded_sol_world_names_audit.md
git commit -m "docs: hardcoded Sol world names audit — data-driven refactor plan"
```