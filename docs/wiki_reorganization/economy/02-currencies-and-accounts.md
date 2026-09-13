# Currencies & Accounts

**Status**: Canonical  
**Last Updated**: 2026-09-11  
**Supersedes**: `CURRENCY_AND_EXCHANGE.md`, `financial_system.md`, `LEDGERS.md`  
**Derived from**: `CURRENCIES_AND_ACCOUNTS.md` (primary), `CURRENCY_AND_EXCHANGE.md`, `financial_system.md`, `LEDGERS.md`

---

## 1. Currency Model

### `Financial::Currency`

```ruby
# app/models/financial/currency.rb
module Financial
  class Currency < ApplicationRecord
    belongs_to :issuer, polymorphic: true, optional: true
    has_many :accounts
    has_many :transactions

    validates :name, presence: true, uniqueness: true
    validates :symbol, presence: true, uniqueness: true, format: /\A[A-Z0-9]{2,5}\z/
    validates :is_system_currency, inclusion: [true, false]
    validates :precision, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 8 }

    scope :system_currencies, -> { where(is_system_currency: true) }
  end
end
```

**Key properties:**
- `symbol` — 2–5 uppercase characters (e.g., "GCC", "USD")
- `is_system_currency` — flags pre-defined system currencies vs. player-created ones
- `precision` — decimal places (0–8)
- `issuer` — polymorphic association to the entity that mints this currency (e.g., LDC for GCC)

### System Currencies

| Symbol | Name | Issuer | Role |
|--------|------|--------|------|
| **GCC** | Galactic Construction Credit | LDC (Luna Development Corporation) | Primary space economy currency; numeraire for pricing |
| **USD** | US Dollar (Earth fiat) | System (no issuer) | Earth-side import/export pricing; bootstrap anchor |

**GCC is a currency, not a material.** It has no `production` field in the material system (`data/json-data/resources/materials/`). GCC enters circulation exclusively through:
1. **LDC minting** — mining satellite output credited to LDC's GCC account
2. **Pre-seeding** — initial balance seeded at game start

No other entity can mint GCC. NPC corporations (AstroLift, etc.) earn GCC through productive activity only.

---

## 2. Account Model

### `Financial::Account`

```ruby
# app/models/financial/account.rb
module Financial
  class Account < ApplicationRecord
    belongs_to :accountable, polymorphic: true   # Player, Colony, Organization
    belongs_to :colony, optional: true
    belongs_to :currency, required: true
    has_many :transactions, dependent: :destroy

    attr_accessor :balance, :lock_version

    def self.find_or_create_for_entity_and_currency(accountable_entity:, currency:)
      # Creates account with balance=0.0 if none exists
    end

    def can_overdraft?
      accountable_type == 'Colony' || 
      (accountable.respond_to?(:is_npc?) && accountable.is_npc?)
    end

    def transfer_funds(amount, recipient_account, description = nil)
      # Raises "Insufficient funds" if can't overdraft and balance < amount
      # Uses optimistic locking (lock_version) for concurrency safety
    end

    def deposit(amount, description = nil)
      # Adds to balance; creates Transaction record
    end

    def withdraw(amount, description = nil)
      # Subtracts from balance; checks overdraft permission
    end
  end
end
```

**Key behaviors:**
- **Polymorphic accountability** — any entity (Player, Colony, Organization) can own accounts
- **Per-currency accounts** — an entity has separate accounts per currency (e.g., LDC has `ldc_gcc_account` and `ldc_usd_account`)
- **Overdraft permission** — NPCs and Colonies can have negative balances (virtual ledger); players cannot
- **Optimistic locking** — `lock_version` prevents concurrent modification races

### Account Types Per Entity

| Entity | GCC Account | USD Account | Virtual Ledger |
|--------|------------|-------------|----------------|
| LDC | ✅ (mint recipient) | ✅ | ✅ |
| AstroLift | ✅ | ✅ | ✅ |
| Other DCs (MDC, VDC, etc.) | ✅ | ✅ | ✅ |
| Player | ✅ | ✅ | ❌ (players cannot overdraft) |
| NPC Settlements | ✅ | — | ✅ |

---

## 3. GCC/USD Peg & Exchange Phases

### Phase 1: Hard Peg (Bootstrap)

- **Rate**: 1 GCC = 1 USD (fixed)
- **Source**: `economic_parameters.yml` → `currency.usd_to_gcc_peg: 1.0`
- **Purpose**: Price stability at launch; familiar Earth-anchored baseline
- **Scope**: All EAP (Earth Anchor Price) calculations use identical values in both currencies

### Phase 2: Soft Peg / Managed Float (Early Game)

- **Range**: ±10% fluctuation allowed
- **Mechanism**: `Financial::ExchangeRateService` adjusts rate based on GCC supply vs. demand
- **GCC behavior**: All space-side transactions use GCC; LDC mining satellites are primary supply source
- **USD behavior**: Earth-side imports/exports priced in USD, converted at current rate

### Phase 3: Full Float (Late Game / Act 3+)

- **Rate**: Market-driven, no peg constraint
- **Drivers**: Wormhole activity, infrastructure ROI, GCC mining rate, space economy depth
- **EAP calculation**: `EAP_gcc = EAP_usd / exchange_rate(USD → GCC)`
- **GCC appreciation possible** if space economy outgrows Earth anchor

### Uncoupling Triggers

1. Sufficient GCC supply and independent space-side demand
2. Market depth and player/NPC activity support price discovery
3. AI Manager monitors for volatility; can intervene to stabilize

---

## 4. Currency Stability Measures (Guardrails)

From `docs/GUARDRAILS.md` §8:

| Measure | Value | Purpose |
|---------|-------|---------|
| NPC overdraft limit | 50% of asset value | Prevent economic collapse from NPC debt spirals |
| Player debt ceiling | 200% of net worth | Prevent player insolvency |
| Interest rate floor | 2% annual | Discourage excessive borrowing |
| Exchange rate bands | ±5% daily movement | Prevent speculation |
| LDC minting limit | 5% annual supply increase | Control inflation |
| LDC stabilization reserves | 25% of total GCC supply | Market intervention capacity |
| System-wide liquidity | 10% in liquid reserves | Market stability |

---

## Three-Pillar Audience Guide

### For Players 🎮
- **You have two currencies**: GCC (space-side, primary) and USD (Earth-side, for imports)
- **Early game peg is 1:1** — your GCC earnings equal USD value at launch
- **GCC may appreciate over time** — as space economy grows, GCC could become more valuable than USD
- **Players cannot overdraft** — if you run out of GCC/USD, you must earn more before spending
- **Exchange rate affects import costs** — when GCC depreciates, Earth imports cost more in GCC terms

### For Administrators ⚙️
- **GCC monetary base**: 250,000,000 GCC pre-seeded at game start
- **Daily emission**: 1,000,000 GCC/cycle from LDC mining satellites (ongoing)
- **LDC is sole mint authority** — no other entity can create GCC
- **NPC overdraft limit**: 50% of asset value (prevents economic collapse from debt spirals)
- **Player debt ceiling**: 200% of net worth (prevents player insolvency)
- **Interest rate floor**: 2% annual (discourages excessive borrowing)
- **GCC stabilization reserves**: 25% of total GCC supply held by LDC

### For Developers 🔧
- **Currency model**: `Financial::Currency` — symbol (2-5 uppercase chars), precision (0-8 decimals), issuer polymorphic
- **Account model**: `Financial::Account` — polymorphic accountable, per-currency, optimistic locking via `lock_version`
- **Exchange rate service**: `Financial::ExchangeRateService.convert(amount, from, to)` handles all currency conversions
- **Peg phases**:
  - Phase 1: Hard peg (1.0) at launch
  - Phase 2: Soft peg ±10% based on GCC supply/demand
  - Phase 3: Full float driven by market forces
- **GCC has no material entry** — it's a currency, not a producible good

---

## 5. Debt & Overdraft Controls

### NPC Inter-Debt (Virtual Ledger)

Inter-NPC debt is **normal and expected** for efficient resource distribution:
- NPCs trade on virtual ledger without GCC constraints
- Accumulated debt influences decision-making at thresholds:
  - **>30% of assets in debt**: Expansion restrictions (cannot build new bases)
  - **Corporate debt >30%**: Procurement conservatism (refuse player purchases)

### Player Debt

- Players **cannot** use virtual ledger
- Players **cannot** overdraft — `transfer_funds` raises "Insufficient funds" if balance < amount
- Player debt ceiling: 200% of net worth

---

## 6. GCC as Numeraire

GCC is the **numeraire** (unit of account) for the space economy:

- All NPC buy/sell orders posted in GCC
- EAP calculations convert USD → GCC via exchange rate service
- Material pricing, transport costs, and ISRU fees all expressed in GCC for space-side transactions
- USD remains the numeraire only for Earth-side pricing (spot prices in `economic_parameters.yml`)

```ruby
# NpcPriceCalculator uses this pattern:
usd_eap = earth_spot_price(material) + transport_cost_usd
gcc_eap = usd_eap / Financial::ExchangeRate.get_rate('USD', 'GCC')
```

---

## 7. Pre-Seeding & Minting Overview

See [04-bonds-and-financing.md](./04-bonds-and-financing.md) for full details on:
- Mining satellite deployment and GCC production (1000 GCC/hr, 6-hour cycles)
- Halving schedule and supply cap mechanics
- LDC as sole mint authority
- Pre-seeded balance as initial monetary base (wound down per price discovery lifecycle)

---

## 8. Virtual Ledger Transaction Patterns

### Overdraft Mechanics

NPC accounts in the Virtual Ledger can operate with negative balances (overdrafts), representing economic relationships and credit extensions:

```ruby
# In Financial::Account
def can_overdraft?
  return true if accountable.is_npc?
  return false # Players cannot overdraft
end
```

**Overdraft Scenarios:**
- **Trade Credit**: Supplier extends credit to buyer for delayed payment
- **Contract Advances**: Upfront payments for long-term delivery contracts
- **Economic Buffers**: Negative balances absorb market fluctuations
- **Debt Restructuring**: Overdrafts converted to formal debt instruments

### Virtual Ledger Transactions

Transactions in the Virtual Ledger create economic relationships without actual fund transfers:

```ruby
# Example: NPC colony contracts with NPC mining corp
colony_account = Account.find_for_entity(colony, :virtual_ledger)
mining_account = Account.find_for_entity(mining_corp, :virtual_ledger)

# Contract signing - no funds move
ledger_entry = LedgerEntry.create!(
  from_account: colony_account,
  to_account: mining_account,
  amount: 1000000, # Virtual credits
  description: "Mining contract for 1000 tons regolith",
  transaction_type: :contract_obligation
)

# Overdraft created if colony lacks funds
colony_account.balance -= 1000000 # Can go negative
mining_account.balance += 1000000
```

### GCC/USD Exchange Flows

#### GCC Minting and Distribution

GCC (Galactic Construction Credits) are the primary space economy currency, minted exclusively by the Lunar Development Corporation (LDC):

**GCC Sources:**
- **Lunar Mining**: LDC mines helium-3 and rare earth elements, converting to GCC
- **Infrastructure Fees**: Construction and maintenance fees paid in GCC
- **Resource Royalties**: Percentage of extracted resources converted to GCC

**Minting Process:**
```ruby
# LDC mints GCC from mining proceeds
mining_revenue_usd = 5000000 # From Earth sales
exchange_rate = ExchangeRate.current_gcc_to_usd
gcc_minted = mining_revenue_usd / exchange_rate

ldc_gcc_account = Account.find_for_entity(ldc, :gcc)
ldc_gcc_account.deposit(gcc_minted, "GCC minting from lunar mining")
```

#### USD Revenue Streams

USD serves as the Earth anchor currency, earned through Earth-facing activities:

**USD Sources:**
- **Earth Contracts**: Services provided to Earth companies (research, data, samples)
- **Lunar Exports**: Helium-3, rare earths, scientific data sales
- **LEO Fuel Sales**: Propellant for Earth-departing spacecraft
- **Bond Issuance**: LDC issues USD-denominated bonds for expansion funding

**LEO Fuel Sales Example:**
```ruby
# Earth ship refuels at LEO depot
fuel_cost_usd = 250000 # Cost of lunar-derived LOX/LH2
earth_ship_account = Account.find_for_entity(earth_company, :usd)
ldc_usd_account = Account.find_for_entity(ldc, :usd)

earth_ship_account.transfer(fuel_cost_usd, ldc_usd_account, "LEO refueling")
```

#### Exchange Rate Mechanics

Exchange rates between GCC and USD are market-determined but stabilized by LDC interventions:

**Rate Determination:**
- **Market Forces**: Supply/demand from trade activities
- **LDC Stabilization**: LDC buys/sells to maintain stability
- **Earth Anchor**: USD pegged to Earth fiat currencies
- **Inflation Controls**: GCC supply limited by mining capacity

**Exchange Operations:**
```ruby
# Player exchanges USD for GCC
player_usd = Account.find_for_entity(player, :usd)
player_gcc = Account.find_for_entity(player, :gcc)
ldc_usd = Account.find_for_entity(ldc, :usd)
ldc_gcc = Account.find_for_entity(ldc, :gcc)

exchange_rate = ExchangeRate.current_gcc_to_usd
gcc_amount = usd_amount / exchange_rate

# Atomic exchange through LDC
player_usd.transfer(usd_amount, ldc_usd, "USD to GCC exchange")
ldc_gcc.transfer(gcc_amount, player_gcc, "GCC delivery")
```

### Transaction Flow Patterns

#### NPC-to-NPC Economic Simulation

Virtual Ledger enables complex NPC economic relationships:

**Supply Chain Example:**
```
Raw Material Supplier (Virtual overdraft: -500k)
    ↓ (sells to)
Manufacturing Corp (Virtual balance: +200k)
    ↓ (sells to)
Construction Company (Virtual balance: +300k)
    ↓ (sells to)
Colony (Virtual overdraft: -1M)
```

**Resolution Mechanisms:**
- **Contract Completion**: Overdrafts resolved through delivery payments
- **Debt Restructuring**: Overdrafts converted to formal bonds
- **Bankruptcy**: Extreme overdrafts trigger entity dissolution

#### Player-NPC Interactions

Players interact with NPC economies through multiple channels:

**Direct Trade:**
```ruby
# Player sells resources to NPC colony
player_gcc = Account.find_for_entity(player, :gcc)
npc_colony_virtual = Account.find_for_entity(colony, :virtual_ledger)

# NPC pays with Virtual Ledger credit
npc_colony_virtual.transfer(credit_amount, player_gcc, "Resource purchase")
```

**Contract Systems:**
- **Fixed Price**: Immediate GCC transfer
- **Milestone Payment**: Virtual Ledger obligations with GCC settlement
- **Revenue Share**: Percentage of future earnings

### Economic Guardrails and Stability

#### Virtual Ledger Limits

Prevent economic collapse through overdraft controls:

**Limits:**
- **Per-Entity Cap**: Maximum overdraft based on entity size/reputation
- **System-wide Reserve**: LDC maintains Virtual Ledger reserves for stabilization
- **Interest Charges**: Overdrafts accrue interest to encourage resolution

#### GCC Supply Controls

GCC minting limited to prevent inflation:

**Controls:**
- **Mining Capacity**: Limited by available mining infrastructure
- **LDC Monopoly**: Only LDC can mint GCC
- **Burn Mechanisms**: GCC destroyed through Earth exports and losses
