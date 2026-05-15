# 2026-04-16-MEDIUM-DATA-ECONOMIC-PARAMETERS-MARKET-FEES

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Data task for economic parameters market fee defaults
**Supervision Level**: 🔴 Watched carefully

## Context
config/economic_parameters.yml defines all economic defaults. Docking transaction system requires default broker fee, transaction fee, and valid order duration options. These don't exist yet and must be added before DockingTransactionService can resolve defaults.

## Problem Statement
No market fee defaults or order duration config in economic_parameters.yml.

**Expected**: New market section added with all required defaults.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `config/economic_parameters.yml` | Economic defaults | Add market and extraction_pricing sections |

## Implementation Steps
1. **Add market section**: Under economy: after market_dynamics:, add market defaults
2. **Add extraction_pricing section**: Include risk premium, depreciation model, fuel cost source
3. **Validate YAML**: Ensure file parses correctly after changes

## Acceptance Criteria
- [ ] market section added with default_broker_fee, default_transaction_fee, order_durations_days, same_owner_fee_waiver
- [ ] extraction_pricing section added with default_risk_premium, depreciation_model, fuel_cost_source
- [ ] YAML validates cleanly
- [ ] No existing sections modified

## Stop Conditions
- YAML validation fails after edit
- Existing market_dynamics section conflicts with new market section

## Commit Instructions
```bash
git add config/economic_parameters.yml
git commit -m "data: economic_parameters — add market fee defaults and extraction pricing config"
```