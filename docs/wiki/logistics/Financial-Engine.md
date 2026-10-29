> **Wiki section:** Player · **Status:** short intent page; detail and VERIFY flags live on the canonical market pair below

# Financial Engine

Currency, ledgers, and market friction for off-world play.

**Canonical authority:** For pricing logic, GCC/USD peg unpeg model, EAP enforcement, and all bootstrapping mechanics, refer to:
- **[Resource & Market Logistics](Resource-and-Market-Logistics.md)** — ECC canonical spec (NPC pricing, EAP ceilings, warehouse caps, order lifecycle)
- **[Market and AI Bootstrapping](market_and_ai_bootstrapping.md)** — ECC canonical spec (bootstrap peg, market models, AutonomousConstructionManager)

> **Cross-link:** For the authoritative pre-player-era logistics routing (Mars cycler hub network, MK1/MK2/MK3 HLT gating, Venus-Luna chemical loop), see **[Station Construction Options](../engineering/station_construction_options.md)**.

---

## Design intent

1. **Two-currency bootstrap** — Earth-side activity uses USD; off-world player/colony activity is denominated in **GCC**. Bootstrap peg starts at **1:1** (`GCC_TO_USD_INITIAL = 1.0`) so blueprints and material data can embed present-day real-world values without fantasy pricing scales.
2. **GCC/USD peg, then unpeg** — During bootstrap GCC trades 1:1 to USD; off-world volume and trade value eventually rival the Earth channel at which point GCC is allowed to float freely. Peg/unpeg trigger remains a `[TARGET DESIGN INTENT]` — no runtime enforcement yet.
3. **EAP ceiling** — Every resource price is capped by the **Earth Anchor Price**: `EAP = Earth USD reference cost (+ refining where applicable) + transport cost`. At bootstrap peg 1:1, EAP maps directly to GCC per kg. Local production facilities override EAP with a locally-derived cost model instead of Earth import pricing.
4. **Friction on markets** — Fees/taxes keep automated or high-volume order spam from being free. Exact schedules should be confirmed against code, not copied from old notes alone.

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
