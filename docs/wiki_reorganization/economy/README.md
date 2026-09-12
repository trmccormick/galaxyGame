# Economy Documentation Hub

**Status**: Canonical entry point for all economy/financial documentation  
**Last Updated**: 2026-09-11  
**Related**: All pages under `economy/`

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

## Documentation Map

### Overview & Design
- **[01-overview-and-design.md](./01-overview-and-design.md)** — System architecture, key models/services, economic flow diagram, configuration sources

### Currencies & Accounts
- **[02-currencies-and-accounts.md](./02-currencies-and-accounts.md)** — Currency model, account model, GCC/USD peg phases, stability measures, numeraire rules

### Market & Pricing
- **[03-market-and-pricing.md](./03-market-and-pricing.md)** — Price discovery lifecycle, EAP calculation, ISRU pricing, market operations, GCC coupling status

### Bonds & Financing
- **[04-bonds-and-financing.md](./04-bonds-and-financing.md)** — Bond model, launch service bonds, GCC mining bonds, inter-DC bonds, repayment flows, GCC minting architecture

### Launch & Operational Fees
- **[05-launch-and-operational-fees.md](./05-launch-and-operational-fees.md)** — Launch payment flow, mass calculation, configuration structure, fiscal policy and fee structure

### NPC Economy Reference
- **[07-npc-economy-lifecycle.md](./07-npc-economy-lifecycle.md)** — Data model inventory, NPC lifecycle phases, agent documentation

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

*This is the entry point for economy documentation. All other pages in this section are authoritative references derived from code.*
