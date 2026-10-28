> **Wiki section:** Player · **Status:** needs review against current game — short intent page; detail and VERIFY flags live on Resource and market logistics

# Financial Engine

Currency, ledgers, and market friction for off-world play.

**Related wiki pages**

- [Resource and market logistics](Resource-and-Market-Logistics.md) — NPC pricing, warehouse caps, order lifecycle  
- [Market and AI bootstrapping](Market-and-AI-Bootstrapping.md) — market models + AutonomousConstructionManager  
- [Logistics and hauling](Logistics-and-Hauling.md) — transport intent (not fees)

**Deep reference:** `docs/architecture/financial_system.md` and related economy docs.

---

## Design intent

1. **Two-currency bootstrap** — Earth-side activity can stay in USD; off-world player/colony activity is denominated in **GCC**.  
2. **Peg, then float** — During bootstrap, GCC is treated as **1:1 with USD** (`GCC_TO_USD_INITIAL = 1.0` in game constants when present). After off-world volume is self-sustaining, design intent is to **uncouple** GCC and let it float. Uncoupling trigger and implementation are often still open or pending.  
3. **Import ceiling** — Earth-sourced mass is anchored by a high transport cost per kg (commonly cited as `INITIAL_TRANSPORTATION_COST_PER_KG = 1320` in constants). Local production and off-world harvest should undercut that ceiling.  
4. **Friction on markets** — Fees/taxes exist so automated or high-volume order spam is not free. Exact schedules should be confirmed against code, not copied from old notes alone.

---

## Open options

| Topic | Notes |
|-------|--------|
| When GCC unpegs | Volume threshold vs scripted scenario event — not locked |
| Fee schedule | Older notes mentioned broker / sales / surcharge style tiers; treat as **option** until matched to `Market*` / finance services |
| AI debt pressure | High AI priority on debt repayment must not always fire-sale local markets (see AI Manager page) |

---

## Component hints (verify in code)

Names seen in design notes and related wiki pages (confirm before treating as API):

- Market / trade path: `Market::Marketplace`, orders, conditions, NPC price calculator, trade execution  
- Finance path: transaction ledger / account balances (names vary by age of note)  
- Constants: `config/initializers/game_constants.rb`

---

## What was wrong before

A previous copy of fee/tax tables was stored under `Logistics-and-Hauling.md` by mistake. Logistics is transport intent; **fees and peg belong here and on the Resource/Market pages.**
