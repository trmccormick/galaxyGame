# 2026-04-16-HIGH-ARCHITECTURE-RAW-RESOURCE-EXTRACTION-PRICING

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Architecture design for raw resource extraction pricing
**Supervision Level**: 🔴 Watched carefully

## Context
Harvested raw resources (mined gases, raw ore) have no material purchase cost - resource itself is free. But true cost includes craft fuel, depreciation, energy, risk. Without floor price model, NpcPriceCalculator cannot value these resources or determine if local extraction is economically viable vs Earth import.

Earth Anchor Price (EAP) serves as ceiling - if local extraction break-even exceeds EAP, importing from Earth is cheaper.

## Problem Statement
NpcPriceCalculator has no model for raw harvested resources. Falls back to Earth import cost which doesn't reflect extraction economics.

**Expected**: Break-even cost model computing minimum viable sell price for harvested resource based on actual mission costs. Feeds into cost_based_bid as floor price for NPC buyers.

## Break-Even Formula
floor_price_per_kg = (fuel_cost_round_trip + craft_depreciation_per_mission + energy_cost_during_extraction + risk_premium) ÷ kg_extracted_per_mission

## Files Involved
### Primary Files — you will read
| File | Purpose |
|---|---|
| `app/models/market/npc_price_calculator.rb` | Integration point for extraction cost calculation |
| `app/models/craft/base_craft.rb` | Craft operational data for fuel/energy consumption |
| `config/economic_parameters.yml` | Economic parameters for risk premium, depreciation |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `data/json-data/materials/` | Material data for extraction pricing signals |
| `app/models/material.rb` | Material model and cost_data structure |

## Implementation Steps
1. **Design break-even formula**: Specify each component with data sources and fallbacks
2. **Define integration point**: Add calculate_extraction_cost method to NpcPriceCalculator
3. **Specify viability check**: Logic for when local extraction is viable vs import
4. **Define economic parameters**: New fields needed in economic_parameters.yml
5. **Specify material data signal**: How to flag extraction-priced resources

## Acceptance Criteria
- [ ] Break-even formula fully specified with data sources for each component
- [ ] Integration point in NpcPriceCalculator described exactly
- [ ] Viability check logic defined
- [ ] economic_parameters.yml additions listed
- [ ] Material data signal defined
- [ ] No code changes made

## Stop Conditions
- None specified

## Commit Instructions
```bash
git add docs/architecture/raw_resource_extraction_pricing_design.md
git commit -m "docs: raw resource extraction pricing architecture design — break-even model and NpcPriceCalculator integration"
```