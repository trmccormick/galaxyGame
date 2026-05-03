# TASK: Economic Parameters — Market Fee Defaults and Order Durations
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: data
**Created**: 2026-04-16
**Last Updated**: 2026-04-16

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Simple data file edit, fully specified, no inference needed.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`config/economic_parameters.yml` defines all economic defaults for the game.
The docking transaction system requires default broker fee, transaction fee,
and valid order duration options. These do not exist yet and must be added
before `DockingTransactionService` can resolve defaults.

---

## Problem Statement

**Current**: No market fee defaults or order duration config in
`economic_parameters.yml`.

**Expected**: New `market` section added with all required defaults.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `config/economic_parameters.yml` | Add market section |

---

## Exact Change Required

Add this section to `config/economic_parameters.yml` under `economy:`,
after the existing `market_dynamics:` section:

```yaml
  # Docking transaction market defaults
  # Structure/settlement owners can override these per marketplace
  market:
    default_broker_fee: 0.01        # 1% charged on order placement
    default_transaction_fee: 0.02   # 2% charged on fill
    order_durations_days:           # Valid order lifetime options
      - 1
      - 3
      - 7
      - 30
      - 90
    same_owner_fee_waiver: true     # Waive all fees for same-owner transfers

  # Extraction pricing defaults
  extraction_pricing:
    default_risk_premium: 0.05      # 5% markup for mission risk
    depreciation_model: "linear"    # linear | accelerated
    fuel_cost_source: "local_market" # local_market | earth_anchor
```

---

## Validation

After edit, validate YAML is parseable:

```bash
docker exec -it web bash -c 'ruby -e "require \"yaml\"; YAML.load_file(\"/home/galaxy_game/config/economic_parameters.yml\"); puts \"OK\""'
```

---

## Synthesis Report Format

```
THE FAILURE
Spec: none — data task
Error: none
Expected: market and extraction_pricing sections present in economic_parameters.yml
Got: sections missing

PROPOSED FIX
[confirm exact placement in file]

RISK
[any code that reads economic_parameters.yml that might be affected]

READY TO APPLY? — waiting for approval
```

---

## Acceptance Criteria
- [ ] `market` section added with all four fields
- [ ] `extraction_pricing` section added with all three fields
- [ ] YAML validates cleanly
- [ ] No existing sections modified

## Stop Conditions
- YAML validation fails after edit — revert immediately, report error
- Existing `market_dynamics` section conflicts with new `market` section —
  flag before proceeding

## Commit Instructions
```bash
git add galaxy_game/config/economic_parameters.yml
git commit -m "data: economic_parameters — add market fee defaults and extraction pricing config"
git push
```

## Dependencies
**Blocked by**: None
**Blocks**: 2026-04-16-HIGH-FEATURE-DOCKING-TRANSACTION-SERVICE.md
**Related**: 2026-04-16-HIGH-ARCHITECTURE-RAW-RESOURCE-EXTRACTION-PRICING.md
