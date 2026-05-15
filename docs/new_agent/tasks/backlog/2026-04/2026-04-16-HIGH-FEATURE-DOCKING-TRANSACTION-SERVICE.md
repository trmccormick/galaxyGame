# 2026-04-16-HIGH-FEATURE-DOCKING-TRANSACTION-SERVICE

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Feature implementation for docking transaction service
**Supervision Level**: 🔴 Watched carefully

## Context
When craft docks at structure or surface settlement spaceport, needs single entry point to buy/sell resources. Service must determine physical inventory boundary, check ownership for bypass vs market path, enforce storage capacity, apply surface outdoor storage rules, route to Marketplace#place_order.

## Problem Statement
No unified docking transaction layer for surface and orbital docking points. Craft docking logic scattered across multiple services.

**Expected**: DockingTransactionService as unified layer handling ownership routing, storage capacity, outdoor storage rules, and marketplace integration.

## Core Business Rules
- Docking always free (no arrival fee)
- Same owner bypass: direct inventory transfer, no fees, energy/time cost recorded
- Different owner market path: broker fee on placement, transaction fee on fill, GCC settlement
- Storage capacity enforced: orbital hard limit, surface pressurized hard limit, surface outdoor unlimited for eligible materials
- Outdoor storage eligibility: solid stable materials not hazardous/cryogenic/biological/radioactive

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/services/market/docking_transaction_service.rb` | New service | Create this file |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/market/marketplace.rb` | place_order interface |
| `app/models/market/npc_price_calculator.rb` | Pricing logic |
| `app/models/structures/base_structure.rb` | Inventory and owner |
| `app/models/settlement/base_settlement.rb` | Settlement marketplace |
| `config/economic_parameters.yml` | Default fees, durations |

## Implementation Steps
1. **Create service class**: DockingTransactionService with initialize(craft, docking_point)
2. **Implement sell/buy methods**: Handle same-owner bypass vs market orders
3. **Add storage capacity check**: Apply outdoor storage rules for surface settlements
4. **Implement fee resolution**: broker_fee_rate and transaction_fee_rate from marketplace or defaults
5. **Add bypass transfer logic**: Direct inventory moves with energy cost recording

## Acceptance Criteria
- [ ] DockingTransactionService created with sell/buy methods
- [ ] Same-owner bypass transfers work correctly
- [ ] Different-owner routes to marketplace with fees
- [ ] Storage capacity enforced with outdoor storage rules
- [ ] All business rules implemented
- [ ] Service specs pass

## Stop Conditions
- Marketplace model missing broker_fee_rate/transaction_fee_rate fields
- Material data missing outdoor storage eligibility fields

## Commit Instructions
```bash
git add app/services/market/docking_transaction_service.rb
git commit -m "feat: DockingTransactionService — unified docking transaction layer for buy/sell operations"
```