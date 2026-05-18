# 2026-04-07-HIGH-DATA-AI-MANAGER-MISSION-PROFILE-TRAINING-REFRESH

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Data refresh for AI Manager mission profile training
**Supervision Level**: 🔴 Watched carefully

## Context
AI Manager learns expansion behavior from mission profile JSON files via MissionProfileAnalyzer. Last training run was 2026-01-19 with 5/10 patterns failed. Since then, ISRU interface, manufacturing service BOM, lunar precursor missions, and Venus patterns have changed materially.

## Problem Statement
NPC making expansion decisions based on 3-month-old training data that predates architectural changes. Need to refresh training data to reflect current ISRU lifecycle, BOM structure, and economic model.

**Current state**: training_results.json dated 2026-01-19, 5/10 patterns failed
**Expected state**: All mission profiles pass validation against current architecture

## Files Involved
### Primary Files — you will edit
| File | Purpose |
|---|---|
| `app/services/ai_manager/mission_profile_analyzer.rb` | Training engine |
| `app/data/ai_manager/training_results.json` | Output — will be regenerated |
| `app/data/ai_manager/enhanced_training_report.json` | Output — will be regenerated |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/data/json-data/missions/` | Mission profile JSON files (source of truth) |
| `docs/ai_manager/` | Current AI Manager architecture |
| `docs/architecture/precursor_mission_bootstrap_architecture.md` | Precursor mission canonical flow |

## Implementation Steps
1. **Audit changes since January**: Compare current mission profiles against January training report
2. **Validate MissionProfileAnalyzer**: Confirm it reflects current interfaces (BOM structure, ISRU lifecycle, NpcPriceCalculator)
3. **Fix analyzer if needed**: Update analyzer before retraining if stale
4. **Re-run training**: Execute training integration test script
5. **Review output**: Confirm all 10 patterns pass validation
6. **Document behavioral changes**: Note what changed in NPC expansion behavior

## Acceptance Criteria
- [ ] All 10 mission patterns pass validation (0 failed)
- [ ] training_results.json dated 2026-04-07 or later
- [ ] Analyzer correctly reflects current ISRU lifecycle
- [ ] Analyzer correctly reflects current BOM/NpcPriceCalculator structure
- [ ] Behavioral change summary documented

## Stop Conditions
- More than 3 patterns require JSON changes to pass
- MissionProfileAnalyzer requires significant refactoring
- Any mission profile JSON changes conflict with architectural constraints

## Commit Instructions
```bash
git add app/data/ai_manager/training_results.json
git add app/data/ai_manager/enhanced_training_report.json
git commit -m "data: refresh AI Manager mission profile training — updated to current ISRU and BOM architecture"
```