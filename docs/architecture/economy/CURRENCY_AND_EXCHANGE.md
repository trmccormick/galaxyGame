# CURRENCY AND EXCHANGE

## GCC/USD Peg and Exchange Phases

### Bootstrap Phase (Hard Peg)
- At game launch, GCC is pegged 1:1 to USD (1 GCC = 1 USD).
- All EAP (Earth Anchor Price) calculations use this baseline.
- Rationale: Ensures price stability, prevents hyperinflation/deflation, and provides a familiar reference for early economic activity.
- USD is used for Earth-side imports/exports; GCC is used for all space-side transactions.

### Soft Peg and Managed Float
- As the space economy grows, the peg loosens:
  - **Soft Peg:** Small fluctuations allowed (±10%).
  - **Managed Float:** Exchange rate set by market forces, with AI stabilization. Space goods priced in GCC below EAP; Earth imports still anchored in USD.

### Uncoupled Phase (Full Float)
- GCC trades freely against USD; value driven by space-side supply/demand, wormhole activity, and infrastructure ROI.
- Earth imports require USD, converted at the current exchange rate.
- EAP in GCC is calculated as:

  EAP_gcc = EAP_usd / exchange_rate(USD → GCC)

- The AI Manager and all NPC buy/sell orders use the current exchange rate for all conversions.

## Uncoupling Triggers
- Sufficient GCC supply and independent space-side demand.
- Market depth and player/NPC activity support price discovery.
- AI Manager monitors for volatility and can intervene to stabilize if needed.

## USD Role in Imports/Exports
- All Earth imports are priced in USD and require conversion to GCC at the prevailing rate.
- Earth Anchor Price (EAP) acts as a price ceiling; if local or NPC prices exceed EAP, imports are triggered and paid in USD.

---

## Debt and Overdraft Controls (from GUARDRAILS.md §8)
- **Virtual Ledger Limits:** NPC entities cannot exceed 50% of their asset value in overdraft to prevent economic collapse
- **Player Debt Ceilings:** Players cannot accumulate debt exceeding 200% of their net worth
- **Interest Rate Floors:** Minimum 2% annual interest on all overdrafts to discourage excessive borrowing

## Currency Stability Measures
- **Exchange Rate Bands:** GCC/USD exchange rates limited to ±5% daily movement to prevent speculation
- **Minting Limits:** LDC limited to 5% annual GCC supply increase to control inflation
- **Burn Mechanisms:** Automatic GCC destruction for Earth exports to maintain supply equilibrium

## NPC Debt Decision Influence
- **Virtual Ledger Trading:** NPCs can trade among themselves without GCC limitations using the virtual ledger, allowing inter-NPC debt accumulation
- **Expansion Restrictions:** High debt levels (>30% of assets) prevent NPC base construction and new settlement establishment
- **Procurement Conservatism:** NPCs with corporate debt exceeding 30% of total assets become conservative buyers, refusing purchases from players to preserve capital
- **AI Manager Integration:** Debt levels are continuously monitored and influence OperationalManager decision-making for resource allocation and expansion planning
- **Expected Behavior:** Inter-NPC debt is normal and expected for efficient resource distribution, but excessive debt triggers conservative decision-making
