# Currency Creation and Local Monetary Operations

**Status**: Canonical design guidance; broader operational support is not yet implemented  
**Last Updated**: 2026-11-25  
**Related**: [Currencies & Accounts](./02-currencies-and-accounts.md), [Economy Overview](./01-overview-and-design.md), [Bonds & Financing](./04-bonds-and-financing.md)

---

## 1. Purpose and Scope

GalaxyGame starts with GCC and USD because those are sufficient for the initial Sol/Luna economy. The existing currency architecture was designed to accommodate more than those two currencies. This page describes how the game can use that foundation as economic activity expands; it does not propose a replacement currency model or a separate monetary simulation.

Additional currencies may include other Earth national currencies (such as EUR or GBP) and locally issued currencies used by a corporation, consortium, settlement, world, or system. A local currency may be useful when an economy's access to external financial networks or liquid reserves is insufficient for its normal activity.

## 2. Existing Foundation

The current financial model already contains the principal data concepts:

- **Currency definition:** Financial::Currency has a polymorphic optional issuer, symbol, precision, and an is_system_currency flag.
- **Separate balances:** Financial::Account belongs to an accountable entity and a specific currency. One entity can hold multiple currencies in separate accounts.
- **Currency-aware records:** transactions are associated with currencies; exchange-rate records identify directed from/to currency pairs.
- **Currency-denominated obligations:** bonds support obligations denominated in a currency.

The model therefore provides a foundation for multiple currencies and issuing authorities. The fact that GCC is issued under LDC policy does not make LDC the issuer or governor of every future currency.

The is_system_currency flag currently distinguishes predefined/system currencies from other currencies. Its exact classification semantics should be reviewed before relying on it to represent every kind of AI-managed or institutionally issued currency.

## 3. When a Local Currency May Be Useful

Currency creation is one possible response to an economic constraint, not an automatic response to a low balance in GCC or USD.

An AI Manager or authorized institution should first consider:

1. **Existing liquid balances:** what currency is actually available to spend, rather than merely recorded as wealth or assets.
2. **Authorized transfers:** whether another entity can and is permitted to transfer funds or provide a budget.
3. **Existing currencies and exchange access:** whether available currencies can be exchanged at a usable rate and through an accessible financial route.
4. **Obligations and debt:** upcoming payments, debt service, contracts, wages, and other currency-specific liabilities.
5. **Economic capacity:** local resource stocks, productive output, infrastructure, expected income, and trade position.
6. **Operational isolation:** whether the settlement or system can reliably obtain external liquidity or participate in external financial networks.

A local currency becomes a reasonable option when the economy needs a durable local medium of exchange, unit of account, or source of liquidity and the issuer can establish credible governance and acceptance.

A resource-rich, productive world can still be cash-poor. Resource wealth, productive capacity, infrastructure value, trade surplus, debt, and liquid purchasing power are related but distinct economic conditions.

## 4. Independent Issuers and AI Manager Authority

A currency must have an identifiable issuer and an explicit policy. That policy should define, as applicable:

- who is authorized to issue the currency;
- the purpose and intended users of the currency;
- issuance limits or rules and how new units enter circulation;
- the initial recipient or distribution process;
- the backing, assets, revenues, or economic commitments (if any) supporting confidence;
- accounting, audit, and reporting responsibilities;
- rules for redemption, exchange, and retirement; and
- which AI Manager or institution has authority to change policy.

The AI Manager may recommend or administer currency creation only within its delegated authority. It should evaluate the local economy and the consequences for existing stakeholders; it should not gain unrestricted minting authority merely because it manages a settlement.

### Eden example

If Eden remains disconnected from Sol for long enough, its independent AI Manager may determine that a local currency is appropriate. That decision need not depend on Eden having no GCC at all. Eden could already hold GCC and still establish a local currency to support local liquidity, pricing, obligations, and monetary independence—much as LDC established GCC for the Luna development economy.

Reconnection to Sol does not automatically invalidate Eden's currency. Eden may continue using it alongside GCC, USD, and other currencies, with exchange relationships determined by actual economic and institutional arrangements.

## 5. Coexistence and Currency-Denominated Obligations

Currencies coexist; they are not interchangeable labels for a single balance.

- An entity may hold GCC, USD, EUR, and a local currency in separate accounts.
- A GCC-denominated obligation remains a GCC obligation unless its terms permit conversion or settlement in another currency.
- USD reserves do not automatically satisfy a GCC obligation, and GCC reserves do not automatically satisfy a local-currency obligation.
- A transfer between entities requires authority, available funds or credit, and a valid transaction in the relevant currency.
- Exchange rates provide a conversion basis; they do not themselves move funds or grant access to another entity's reserves.
- Exchange, conversion, and settlement must preserve the currency denomination and audit trail of the original obligation.

This distinction matters even within Sol. Luna could accumulate substantial GCC reserves through its early role in the GCC monetary system and also earn USD through Earth-facing commerce—for example, selling fuel to ships departing Earth. Luna's productive wealth and infrastructure would be additional sources of economic strength. Its GCC and USD balances remain separate spendable resources.

## 6. Real-World Exchange Rates as Reference Data

Real-world foreign-exchange data should be used to help tune and validate Earth-currency relationships. USD, EUR, GBP, and other represented national currencies can use observed real-world rates as reference inputs.

Useful applications include:

- establishing initial exchange-rate relationships;
- checking conversion calculations and quoted-pair conventions;
- calibrating Earth-side import/export prices;
- testing historical currency movement and volatility; and
- comparing game tuning against recognizable economic conditions.

Reference data should retain its provenance: provider/source, currency pair, quote convention, observation/effective timestamp, retrieval timestamp, and whether the rate is indicative, historical, or an executable market quote. Historical rates must remain historical; updating a current reference must not rewrite past transactions.

Real-world rates are not a permanent rule for the game. Admin tuning may adjust them, and fictional currencies may diverge as their own supply, demand, production, trade, confidence, and institutional conditions evolve. A local currency may initially be compared with GCC or USD and later develop an independent exchange value.

No specific external FX provider or live-ingestion workflow is established by the code reviewed for this page. Such integration should be selected and implemented deliberately; currency creation and ordinary simulation must not depend on a live external API being available.

## 7. Economic Consequences for AI Manager Decisions

Currency-aware economic planning should distinguish:

- **liquidity:** spendable balances in each currency;
- **purchasing power:** what those balances can buy locally or through accessible exchange;
- **wealth:** resources, productive assets, infrastructure, and claims;
- **solvency:** obligations and debts relative to assets and expected income;
- **trade position:** exports, imports, contracts, and expected receipts; and
- **financial access:** whether funds and exchange routes are actually available to the settlement.

An AI Manager should not assume that another settlement's GCC or USD reserves are available to it. Transfers require explicit authority, budgets, agreements, or contracts. Nor should it assume that a shortage of one currency proves that the local economy is unproductive or that currency creation is the only solution.

Currency creation can improve local liquidity and support monetary independence, but it does not create physical resources, productive capacity, or real wealth by itself. Issuance that exceeds credible economic demand or governance capacity can instead undermine purchasing power and confidence.

## 8. Current Implementation Boundaries

The following distinctions are important when reading the current code:

### General foundations verified in source

- Financial::Currency supports an optional polymorphic issuer and currency precision.
- Financial::Account is associated with an accountable entity and a currency; transfers reject accounts with different currencies.
- Financial::ExchangeRate stores directed currency-pair rates.
- Financial::Bond is a currency-denominated financial instrument.

### Initial USD/GCC assumptions verified in source

- Seeds currently create USD and GCC as the system currencies.
- Market::TradeExecutionService selects GCC for market trade settlement.
- Market::PurchaseService selects GCC for purchases.
- Financial::SettlementService clears GCC debt against USD reserves using the documented bootstrap 1:1 relationship.
- AIManager::SystemIntelligenceService scores economic health using GCC and USD balances.

These are current integration choices, not evidence that the underlying currency/account model is limited to USD and GCC.

### Gaps to address before broader currency use

- Market orders, pricing, purchase execution, taxes, and settlement need to carry the actual transaction currency rather than assume GCC.
- AI Manager financial assessment and procurement decisions need to account for all relevant currency balances, obligations, exchange access, and delegated budgets.
- Currency creation needs an authorized operational workflow and per-currency issuance/distribution policy.
- Exchange-rate handling must not silently treat a missing currency pair as 1:1. Current source has 1.0 fallbacks in both Financial::ExchangeRate.get_rate and the in-memory Financial::ExchangeRateService#get_rate; this is unsafe for unconfigured currency pairs.
- External real-world FX reference ingestion, historical observations, provenance, and controlled refresh are not demonstrated in the reviewed implementation.
- Currency classification should be reviewed to ensure system-defined, institutionally issued, and AI-authorized local currencies can be represented without conflating their governance.

These are integration and operational gaps. They do not require replacing the existing currency model by default.

---

## 9. Related Design Principles

1. GCC issuance rules are specific to GCC and LDC; they are not universal monetary rules.
2. USD/GCC parity is an initial bootstrap reference, not a universal peg for every currency.
3. Additional Earth currencies and local currencies can coexist.
4. Currency balances, resource wealth, productive capacity, infrastructure, debt, and trade position must remain distinct in economic reasoning.
5. Currency creation is a policy decision and a possible response to local economic conditions—not an automatic consequence of isolation or low GCC reserves.
6. Reconnection to Sol does not require an independently established local currency to disappear.

---

## Change History

- **2026-11-25**: Added currency creation, local monetary operations, real-world FX reference data, and current implementation boundaries after reviewing the currency models and selected market/AI Manager services.
