# Overview & Design

**Status**: Canonical  
**Last Updated**: 2026-09-11  
**Derived from**: `ECONOMY_OVERVIEW.md`, `economic_baseline.md` (snapshot section)

---

## System Architecture

The Galaxy Game economy is a **dual-currency, NPC-first system** with three monetary layers:

| Layer | Currency | Role | Controlled By |
|-------|----------|------|---------------|
| Space-side | **GCC** (Galactic Construction Credit) | Primary numeraire; all space pricing | LDC (sole mint authority) |
| Earth-side | **USD** (US Dollar) | Import/export anchor; spot prices | System (pre-defined) |
| NPC accounting | **Virtual Ledger** | Inter-NPC debt/credit without GCC transfer | NPCs with overdraft permission |

### Core Design Principles

1. **GCC is a currency, not a material** — it has no `production` field in the material system; it enters circulation only through LDC minting and pre-seeding
2. **NPC-first economy** — NPC-to-NPC interactions drive market formation; players participate in an already-living economy
3. **Earth anchor pricing** — all space prices derive from Earth spot prices + transport costs (delta-V); transport is never free
4. **Price discovery lifecycle** — prices start at EAP and decrease as infrastructure matures, creating a dynamic economy
5. **Virtual ledger for simulation depth** — NPCs trade on credit without depleting player-accessible GCC pools

---

## Key Models & Services

| Model/Service | Location | Purpose |
|--------------|----------|---------|
| `Financial::Currency` | `app/models/financial/currency.rb` | Currency definition (symbol, issuer, precision) |
| `Financial::Account` | `app/models/financial/account.rb` | Entity currency accounts with overdraft support |
| `Financial::Transaction` | `app/models/financial/transaction.rb` | Audit trail for all fund movements |
| `Financial::ExchangeRate` | `app/models/financial/exchange_rate.rb` | Currency pair rates (USD↔GCC) |
| `Financial::Bond` | `app/models/financial/bond.rb` | Debt instruments between entities |
| `LaunchPaymentService` | `app/services/launch_payment_service.rb` | Construction + launch cost payment processing |
| `Market::NpcPriceCalculator` | `app/services/market/npc_price_calculator.rb` | NPC buy/sell order pricing |
| `EscalationService` | `app/services/escalation_service.rb` | Price adjustment based on supply/demand |

---

## Economic Flow Summary

```
                    ┌─────────────────────────────────────┐
                    │         LDC (Mint Authority)         │
                    │                                     │
                    │  Mining Satellites → GCC Minting    │
                    │  Pre-seeded Balance → Monetary Base │
                    └──────┬──────────────────┬───────────┘
                           │                  │
              GCC deposits │                  │ GCC bond payments
                           ▼                  ▼
        ┌────────────────────────┐  ┌────────────────────────┐
        │   Player Accounts      │  │  AstroLift / NPC Corps │
        │   (no overdraft)       │  │  (overdraft allowed)   │
        └────────────┬───────────┘  └────────────┬───────────┘
                     │                           │
              Player trades                    Inter-NPC debt
                     │                  Virtual Ledger settlement
                     ▼                           │
        ┌────────────────────────┐               │
        │   NPC Markets          │◄───────────────┘
        │   (buy/sell orders)    │
        └────────────┬───────────┘
                     │
              Price discovery
                     │
                     ▼
        ┌────────────────────────┐
        │  EAP → Local Pricing   │
        │  (infrastructure ↓)    │
        └────────────────────────┘
```

---

## Configuration Sources

| Config File | Purpose |
|------------|---------|
| `config/economic_parameters.yml` | USD/GCC peg, transport costs, NPC behavior, Earth spot prices |
| `data/json-data/resources/materials/*.json` | Material definitions (GCC has no entry — it's a currency) |
| `data/json-data/missions/tasks/gcc_sat_mining_deployment/*.json` | Mining satellite deployment data |
| `data/json-data/operational_data/crafts/space/satellites/crypto_mining_satellite_data.json` | Satellite operational parameters (mining rate, power, etc.) |

---

## Appendix: Economic Baseline Snapshot Data

> **Note**: This section contains ephemeral snapshot data from the original `economic_baseline.md`. It is not canonical architecture — it reflects a point-in-time state of the economy.

### Global EM Economy Status

#### Current Metrics
- **Total Harvested EM:** 125,000.0 units
- **Current Burn Rate:** 175.5 EM/hour (pre-SOL-AOL-732356 activation)
- **Expansion Budget:** 25,000.0 EM units

#### Link Contributions to Burn Rate

| Link ID | Environment | Maintenance Tax (EM/hour) | Status |
|---------|-------------|---------------------------|--------|
| SOL-AC-01 | Cold_Start | 752.5 | stabilizing |
| SOL-SYSA-01 | Hot_Start | 25.0 | stabilizing |
| SOL-AOL-732356 | Hot_Start | 33.3 | stabilized |

#### Post-Activation Burn Rate
- **Updated Burn Rate:** 208.8 EM/hour (+33.3 EM/hour from SOL-AOL-732356)
- **Budget Impact:** SOL-AOL-732356 draws from expansion budget (33.3 EM/hour)
- **Net Expansion Capacity:** 24,791.2 EM remaining in budget

#### Burn Rate Breakdown
- **Infrastructure Maintenance:** 752.5 EM/hour (Cold_Start links)
- **Active Harvesting:** 25.0 EM/hour (Hot_Start residual EM)
- **Network Expansion:** 33.3 EM/hour (New stabilized links)
- **Total Operational Cost:** 810.8 EM/hour across all active links

#### Budget Allocation Strategy
- **Reserve Threshold:** Maintain minimum 10,000 EM in expansion budget
- **Reallocation Trigger:** When budget < 10,000 EM, reduce maintenance on low-priority links
- **Harvesting Priority:** Focus EM extraction on links with highest STE ratios
