# Bonds & Financing

**Status**: Canonical  
**Last Updated**: 2026-09-11  
**Supersedes**: `GCC_MINTING_AND_PRESEEDING.md` (merged)  
**Derived from**: `BONDS_AND_FINANCING.md`, `GCC_MINTING_AND_PRESEEDING.md`

---

## 1. Bond Model

### `Financial::Bond`

```ruby
# app/models/financial/bond.rb
module Financial
  class Bond < ApplicationRecord
    belongs_to :issuer, polymorphic: true      # Who owes the debt (e.g., LDC)
    belongs_to :holder, polymorphic: true      # Who is owed (e.g., AstroLift)
    belongs_to :currency                        # Face currency (USD or GCC)

    enum status: { issued: "issued", paid: "paid", defaulted: "defaulted" }

    has_many :repayments, class_name: "Financial::BondRepayment", dependent: :destroy

    validates :amount, numericality: { greater_than: 0 }
    validates :issued_at, presence: true
    validates :status, presence: true

    def total_repaid(exchange_rate_service = nil)
      # Sums all repayments, converting to face currency if needed
    end

    def paid_off?(exchange_rate_service = nil)
      total_repaid >= amount
    end
  end
end
```

### `Financial::BondRepayment`

Each repayment records a partial or full payment toward the bond's face value. Repayments may be in a different currency than the bond's face currency — conversion uses the current exchange rate at time of repayment.

---

## 2. Bond Lifecycle

```
[ISSUED] ──repayments──> [PAID]
    │                          │
    └── default ──────────> [DEFAULTED]
```

| Status | Meaning |
|--------|---------|
| `issued` | Active obligation; repayments may be made |
| `paid` | Fully repaid (total_repaid >= amount) |
| `defaulted` | Issuer failed to meet obligations |

---

## 3. Bond Types in Galaxy Game

### 3.1 Launch Service Bonds

**Purpose**: Finance satellite launch costs before mining revenue begins.

**Example** — GCC Mining Satellite deployment:

```json
// crypto_mining_satellite_01_manifest_v2.json
{
  "financing": {
    "required": true,
    "amount": 1857986.22,
    "maturity_days": 180,
    "interest_rate": 0.05,
    "description": "Launch debt financing for GCC mining satellite"
  }
}
```

**Payment structure** (via `LaunchPaymentService`):
```ruby
LaunchPaymentService.pay_for_launch!(
  craft: satellite,
  customer_accounts: { gcc: ldc_gcc_account, usd: ldc_usd_account },
  provider_accounts: { gcc: astrolift_gcc_account, usd: astrolift_usd_account },
  launch_config: {
    payment: {
      methods: [
        { currency: 'GCC', max_percentage: 50 },
        { currency: 'USD', max_percentage: 100 }
      ],
      allow_bonds: true,
      bond_terms: {
        maturity_days: 180,
        description: "Launch service bond for satellite deployment"
      }
    }
  }
)
```

**Key characteristics:**
- **Issuer**: LDC (or contracting DC)
- **Holder**: AstroLift (launch service provider)
- **Currency**: USD face value (GCC equivalent calculated at repayment)
- **Maturity**: 180 days (configurable per bond)
- **Interest**: 5% (configurable)

### 3.2 GCC Mining Bonds

**Purpose**: Long-term financing secured by mining satellite asset; creates recurring GCC demand sink.

**Example structure** (to be defined in schema):
```json
{
  "bond_type": "gcc_mining",
  "issuer": "LDC",
  "holder": "AstroLift",
  "face_amount_gcc": 500000,
  "monthly_payment_gcc": 25000,
  "term_months": 24,
  "collateral": "crypto_mining_satellite_01",
  "status": "issued"
}
```

**Key characteristics:**
- **Issuer**: LDC
- **Holder**: AstroLift (or other infrastructure investor)
- **Currency**: GCC (space-side obligation)
- **Payment frequency**: Monthly fixed GCC payments
- **Collateral**: Mining satellite asset (bond secured by productive capacity)
- **Default consequence**: Satellite ownership transfers to holder

**Design rationale**: Creates recurring GCC demand (LDC must mine or acquire GCC to service debt). If mining output drops (halving, satellite failure), AstroLift bears partial risk. Ties AstroLift's incentives to mining infrastructure health.

### 3.3 Inter-DC Bonds

**Purpose**: Cross-settlement capital allocation; enables DCs to fund large projects without depleting operational reserves.

**Key characteristics:**
- **Interest exemption**: DCs do not charge interest to other DCs (per `docs/GUARDRAILS.md` §8)
- **Non-profit status**: DCs are non-profit entities focused on infrastructure expansion
- **Profit reinvestment**: All profits reinvested, no dividends distributed

### 3.4 USD-Denominated Capital Bonds

**Purpose**: Major capital projects requiring Earth-side funding.

**Risk**: If GCC depreciates against USD after issuance, the debt burden increases in GCC terms. This is an intentional credit risk mechanic — DCs must manage USD exposure carefully.

---

## 4. Bond Repayment Flow

```ruby
# Integration test pattern (from gcc_mining_sat_integration_simplified.rb)
current_date = Date.current
bonds = Bond.where(issuer: ldc, holder: astrolift, status: :issued)

bonds.each do |bond|
  if current_date >= bond.due_at
    # Calculate GCC equivalent for USD-denominated bonds
    exchange_rate = Financial::ExchangeRate.get_rate('USD', 'GCC')
    gcc_needed = (bond.amount * exchange_rate).round(2)
    available_gcc = ldc_gcc_account.balance.to_f

    if available_gcc >= gcc_needed
      ldc_gcc_account.transfer_funds(gcc_needed, astrolift_gcc_account,
        "Bond repayment for Bond ##{bond.id}")
      bond.update!(status: :paid)
    else
      # Insufficient GCC — default risk
      # TODO: Default handling logic
    end
  end
end
```

**Repayment considerations:**
- USD bonds require currency conversion at repayment time (GCC → USD rate matters)
- GCC bonds have no conversion risk but depend on mining output sufficiency
- Partial repayments tracked via `BondRepayment` records
- `total_repaid()` handles cross-currency conversion automatically

---

## 5. Bond Financing in the Economic System

### Supply-Side Impact

Bonds create **GCC demand sinks**:
1. Monthly GCC payments remove GCC from LDC circulation
2. If AstroLift doesn't fully re-spend received GCC, net supply decreases
3. Halving schedule reduces mining output → tighter GCC supply

### Risk Management

---

## 6. GCC Minting & Pre-Seeding Architecture

**Document Status**: Canonical  
**Created**: 2026-09-08  
**Last Updated**: 2026-09-11  
**Related Docs**: [05-launch-and-operational-fees.md](./05-launch-and-operational-fees.md), `economic_parameters.yml`

### 6.1 Narrative

A GCC mining satellite is deployed into a valid orbital location (orbital, planetary orbit, or Lagrange point). Once in position, the satellite begins autonomous GCC mining using onboard computational units. Mining occurs on a fixed interval — every 6 hours per the task list profile (`gcc_satellite_mining_tasks_v1.json`).

Each mining cycle produces GCC at a rate defined by the satellite's operational data: **1000 GCC per hour** (`crypto_mining_satellite_data.json`), yielding **6000 GCC per 6-hour cycle**.

All newly minted GCC flows exclusively to the **LDC (Luna Development Corporation)**, which acts as the sole mint authority. The LDC uses this GCC supply to:

1. Fund early operations and infrastructure deployment
2. Make fixed monthly GCC bond payments to AstroLift (the primary launch service provider)
3. Finance satellite launch costs via mixed payment methods (GCC + USD + bonds)

The pre-seeded GCC supply (initial monetary base established at game start) is gradually wound down as local/regional market history matures and displaces the artificial peg, per [03-market-and-pricing.md](./03-market-and-pricing.md).

**Key principle**: *Earth cost is Luna bootstrap only; local/regional market history is the long-term gauge.*

### 6.2 Halving Schedule & Supply Cap

| Parameter | Value | Notes |
|-----------|-------|-------|
| Mining rate | 1000 GCC/hour | Per satellite operational data |
| Cycle interval | 6 hours | Per task list profile |
| Output per cycle | 6,000 GCC | 1000 × 6 |
| Daily output (per sat) | 24,000 GCC | 4 cycles/day |
| Halving period | TBD | Every N months, mining rate halves |
| Supply cap | TBD | Maximum total GCC ever minted |
| Initial halving trigger | TBD | After X months or Y total GCC minted |

**Design rationale**: A halving schedule mirrors Bitcoin's disincentive model — early miners produce aggressively to seed the economy, then production slows as market-based pricing takes over. The supply cap prevents infinite inflation and anchors long-term value expectations.

**Implementation note**: Halving logic should be driven by `economic_parameters.yml` under a new `gcc_mining` section (see Blueprint/Data Gaps).

### 6.3 LDC as Sole Recipient

All GCC minted by the satellite is credited to the LDC's account. No other entity (including AstroLift, player settlements, or NPC merchants) can directly receive newly minted GCC.

This is enforced by:
- The mining satellite's operational data specifying LDC as the sole recipient
- The `Financial::Account` system routing all minted GCC to LDC's designated account
- No alternative minting paths exist in the codebase

### 6.4 Pre-Seeded Supply

The initial monetary base is established at game start through pre-seeding:
- A fixed amount of GCC is credited to LDC's account before any mining occurs
- This provides immediate liquidity for early operations
- The pre-seeded amount is gradually displaced by real revenue as the economy matures
- See [03-market-and-pricing.md](./03-market-and-pricing.md) for the price discovery lifecycle that governs this wind-down

### 6.5 Supply-Side Impact on Economy

GCC minting creates **GCC supply pressure**:
1. Mining satellites continuously add GCC to LDC's account
2. LDC distributes GCC through: operations funding, bond payments, infrastructure deployment
3. Halving schedule reduces mining output over time → disincentive for early accumulation
4. Supply cap prevents infinite inflation
