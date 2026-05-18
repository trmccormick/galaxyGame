# 2026-04-10-HIGH-ARCHITECTURE-ORBITAL-MARKET-SYSTEM

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Architecture design for orbital market system
**Supervision Level**: 🔴 Watched carefully

## Context
Orbital economy core loop involves harvester craft docking at orbital structures, selling raw gases and buying processed propellant. Current implementation uses direct inventory manipulation without market orders, price discovery, or GCC settlement.

## Problem Statement
Gas transfer between craft and depot modeled as direct inventory manipulation. No order book, no price discovery, no player participation in orbital markets.

**Expected behavior**: Proper order book at each orbital structure with sellers/buyers, order matching, GCC settlement, processing pipeline integration, and AI Manager participation.

## Files Involved
### Primary Files — you will read
| File | Purpose |
|---|---|
| `app/models/market/marketplace.rb` | Existing marketplace model |
| `app/models/financial/account.rb` | GCC settlement system |
| `app/services/processing_service.rb` | Processing pipeline |
| `app/services/ai_manager/` | AI Manager market participation |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/architecture/` | Related architecture docs |
| `app/models/market/` | Existing market models |

## Implementation Steps
1. **Audit existing infrastructure**: Marketplace, Order models, Financial::Account transfers, Processing pipeline, AI Manager participation
2. **Design order book**: Decide location (OrbitalStructure/Settlement/Marketplace), model fields, matching algorithm
3. **Design processing pipeline**: Input consumption, output production, time model
4. **Design AI Manager participation**: Depot owner strategy, inventory management
5. **Define implementation phases**: MVP order book, processing integration, AI participation, player UI
6. **Document risks and open questions**

## Acceptance Criteria
- [ ] Existing market infrastructure fully audited
- [ ] Order book location decided with reasoning
- [ ] Order model designed with full field list
- [ ] GCC settlement flow described
- [ ] Processing pipeline integration described
- [ ] AI Manager participation strategy described
- [ ] Implementation phases defined
- [ ] No code changes made

## Stop Conditions
- Market::Marketplace already implements full order book
- Financial::Account cannot support atomic transfer on order fill
- Processing pipeline requires game tick system that doesn't exist

## Commit Instructions
```bash
git add docs/architecture/orbital_market_system_design.md
git commit -m "docs: orbital market system architecture design — order book, processing pipeline, AI participation"
```