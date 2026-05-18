# 2026-04-16-HIGH-REFACTOR-AI_MANAGER-USE-SETTLEMENT_DEPLOYMENT_SERVICE

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Architecture design for AI Manager settlement deployment service integration
**Supervision Level**: 🔴 Watched carefully

## Context
SettlementDeploymentService.establish_from_craft is now canonical settlement-deployment primitive used by BaseSettlement and player-driven deployments. AI-managed generic base-build pipeline (AutonomousConstructionManager and generic_base_build.rake) creates settlements via BaseSettlement.create! and helpers, duplicating logic not aligned with new service.

## Problem Statement
AI-managed base builds create settlements directly instead of using SettlementDeploymentService. AI trained on JSON mission patterns but Ruby-layer deployment code doesn't reflect this.

**Expected**: Clear documented path for AI-manager integration with SettlementDeploymentService - which sites move to service, how mission-profile JSON drives choices, where AI-specific behavior stays separate.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `docs/architecture/ai_manager/SETTLEMENT_DEPLOYMENT_INTEGRATION_DESIGN.md` | Design output | Create this file |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/ai_manager/autonomous_construction_manager.rb` | Current AI-managed base-build logic |
| `lib/tasks/generic_base_build.rake` | Generic-base-build pipeline |
| `app/models/settlement/base_settlement.rb` | establish_from_craft delegation |
| `app/services/settlement_deployment_service.rb` | Service contract and helpers |
| `app/data/json-data/missions/*/planetary_precursor_initial_setup_v1.json` | AI training patterns |

## Implementation Steps
1. **Review AI-manager code**: List all settlement-creation sites in AI pipeline
2. **Review shared service**: Study SettlementDeploymentService contract, expected parameters
3. **Align with patterns**: Determine how JSON patterns should drive manifest_name and craft choices
4. **Write design note**: Document current state, proposed integration, pattern-driven behavior, follow-up implementation outline

## Acceptance Criteria
- [ ] AI-manager relationship with SettlementDeploymentService clearly documented
- [ ] Recommendation includes concrete call pattern example
- [ ] Design respects AI-manager training and JSON architecture
- [ ] Output is design note, not code or PR
- [ ] Can be reviewed and approved before implementation

## Stop Conditions
- None specified

## Commit Instructions
```bash
git add docs/architecture/ai_manager/SETTLEMENT_DEPLOYMENT_INTEGRATION_DESIGN.md
git commit -m "docs: AI Manager settlement deployment service integration design — alignment with canonical service"
```