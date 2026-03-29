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
