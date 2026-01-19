# LEDGERS.md - Virtual Ledger and Economic Transaction Flows

## Overview

The Galaxy Game implements a dual-economy system anchored to Earth, with three currencies: GCC (Galactic Construction Credits), Virtual Ledger (NPC accounting), and USD (Earth fiat). This document details the Virtual Ledger mechanics, GCC/USD transaction flows, and Earth anchor integration that enable realistic economic simulation while maintaining player-facing currency stability.

## Virtual Ledger System

### Purpose and Design Philosophy

The Virtual Ledger serves as an accounting mechanism for NPC-to-NPC economic interactions, enabling complex economic simulation without depleting player-accessible currency pools. It allows NPCs to engage in trade, contracts, and resource allocation using "virtual" credits that represent economic activity but don't transfer actual GCC.

**Key Principles:**
- **Simulation Depth**: Enables realistic NPC economies with debt, credit, and trade relationships
- **Player Protection**: Prevents NPC activities from draining GCC pools available to players
- **Scalability**: Supports thousands of NPC entities without currency inflation concerns
- **Auditability**: Maintains complete transaction records for economic analysis

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

## GCC/USD Exchange Flows

### GCC Minting and Distribution

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

### USD Revenue Streams

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

### Exchange Rate Mechanics

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

## Earth Anchor Integration

### Economic Foundation

Earth serves as the ultimate economic anchor, providing stability and value reference:

**Earth's Role:**
- **USD Source**: All USD originates from Earth economic activity
- **Value Anchor**: GCC and Virtual Ledger values derive from USD convertibility
- **Technology Transfer**: Earth provides advanced technology and research
- **Market Access**: Earth represents the largest market for space resources

### Bidirectional Value Flow

The economy maintains balanced flows between Earth and space:

**Earth → Space:**
- Capital investment (bonds, contracts)
- Technology transfer
- Launch services
- Market demand for resources

**Space → Earth:**
- Resource exports (helium-3, rare earths)
- Scientific data
- Technology demonstrations
- Strategic positioning

**Balanced Flow Example:**
```ruby
# Earth company invests in lunar mining
earth_investment = 10000000 # USD
ldc_bond = Bond.create!(issuer: ldc, denomination: :usd, amount: earth_investment)

# LDC uses funds for GCC mining expansion
gcc_minted = earth_investment / exchange_rate
# Mining produces helium-3
# Helium-3 sold back to Earth at profit
# Cycle continues with net value creation
```

## Transaction Flow Patterns

### NPC-to-NPC Economic Simulation

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

### Player-NPC Interactions

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

### Earth-Player Transactions

Earth anchor provides player economic stability:

**Import/Export:**
```ruby
# Player imports Earth technology
player_usd = Account.find_for_entity(player, :usd)
earth_supplier = Account.find_for_entity(earth_corp, :usd)

player_usd.transfer(cost, earth_supplier, "Technology import")
```

**Bond Trading:**
```ruby
# Player buys LDC bond
player_usd.transfer(bond_price, ldc_usd, "Bond purchase")
# Receives interest payments over time
```

## Implementation Architecture

### Account Model Extensions

The polymorphic account system supports multiple currencies per entity:

```ruby
class Financial::Account < ApplicationRecord
  belongs_to :accountable, polymorphic: true
  belongs_to :currency
  has_many :ledger_entries

  # Currency-specific behavior
  def can_overdraft?
    currency.virtual_ledger? && accountable.is_npc?
  end
end
```

### Ledger Entry System

Complete audit trail for all economic transactions:

```ruby
class Financial::LedgerEntry < ApplicationRecord
  belongs_to :from_account, class_name: 'Financial::Account'
  belongs_to :to_account, class_name: 'Financial::Account'
  belongs_to :currency

  # Transaction metadata
  validates :amount, numericality: { greater_than: 0 }
  validates :description, presence: true
end
```

### Exchange Rate Management

Dynamic exchange rates with stabilization mechanisms:

```ruby
class ExchangeRate < ApplicationRecord
  # GCC to USD rate
  def self.current_gcc_to_usd
    # Market-determined with LDC intervention
    base_rate = calculate_market_rate
    stabilization_factor = calculate_ldc_intervention
    base_rate * stabilization_factor
  end
end
```

## Economic Guardrails and Stability

### Virtual Ledger Limits

Prevent economic collapse through overdraft controls:

**Limits:**
- **Per-Entity Cap**: Maximum overdraft based on entity size/reputation
- **System-wide Reserve**: LDC maintains Virtual Ledger reserves for stabilization
- **Interest Charges**: Overdrafts accrue interest to encourage resolution

### GCC Supply Controls

GCC minting limited to prevent inflation:

**Controls:**
- **Mining Capacity**: Limited by available mining infrastructure
- **LDC Monopoly**: Only LDC can mint GCC
- **Burn Mechanisms**: GCC destroyed through Earth exports and losses

### USD Anchor Stability

Earth provides ultimate economic stability:

**Stabilization:**
- **Convertibility**: GCC always convertible to USD through LDC
- **Bond Market**: LDC bonds provide liquidity
- **Earth Contracts**: Steady USD inflow from Earth activities

## Testing and Validation

### Economic Simulation Tests

Comprehensive testing of economic flows:

```ruby
describe "Virtual Ledger Mechanics" do
  it "allows NPC overdrafts" do
    npc_account = create(:account, :virtual_ledger, accountable: npc_entity)
    expect(npc_account.can_overdraft?).to be true
  end

  it "prevents player overdrafts" do
    player_account = create(:account, :gcc, accountable: player)
    expect(player_account.can_overdraft?).to be false
  end
end
```

### Integration Tests

End-to-end economic flow validation:

- **NPC Supply Chains**: Multi-entity economic relationships
- **GCC/USD Exchange**: Currency conversion accuracy
- **Earth Anchor Flows**: USD stability and convertibility
- **Contract Settlements**: Virtual to real currency transitions

## Future Enhancements

### Advanced Features

- **Derivatives Market**: GCC/USD futures and options
- **Interstellar Trade**: Multi-system economic networks
- **Central Bank Functions**: LDC as galactic central bank
- **Economic AI**: NPC economic decision-making optimization

### Research Areas

- **Inflation Modeling**: Long-term currency stability
- **Market Psychology**: NPC economic behavior patterns
- **Interplanetary Economics**: Multi-planet economic systems
- **Cryptocurrency Integration**: GCC as blockchain-based currency