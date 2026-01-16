# Financial System Architecture

## Account Model

The Galaxy Game uses a polymorphic account system where any entity (Player, Colony, Organization, etc.) can have multiple currency accounts.

### Core Components

**Financial::Account**
- Polymorphic `accountable` association (Player, Colony, Organization, etc.)
- Belongs to `currency` (GCC, USD, etc.)
- Tracks `balance` with optimistic locking (`lock_version`)
- Has many `transactions` for audit trail

**Key Methods:**
```ruby
# Find or create account for entity and currency
Account.find_or_create_for_entity_and_currency(accountable_entity:, currency:)

# Transfer funds between accounts
account.transfer_funds(amount, recipient_account, description)

# Check if account can have negative balance
account.can_overdraft?
```

---

## Virtual Ledger System (NPC Trading)

### Purpose
Allows NPC-to-NPC trade without actual GCC transfers, enabling realistic economic simulation without draining player-facing currency pools.

### Implementation

**NPC Identification:**
```ruby
# In Organizations::BaseOrganization
def is_npc?
  # Development Corporations are NPCs by default
  return true if development_corporation?
  # Or explicitly marked as NPC in operational_data
  operational_data&.dig('is_npc') == true
end
```

**Overdraft Permission:**
```ruby
# In Financial::Account
def can_overdraft?
  accountable_type == 'Colony' || 
  (accountable.respond_to?(:is_npc?) && accountable.is_npc?)
end
```

**Transfer Logic:**
```ruby
def transfer_funds(amount, recipient_account, description)
  # Check overdraft permission for non-NPC accounts
  unless can_overdraft?
    raise "Insufficient funds" if amount > balance
  end
  
  # Allow negative balances for NPCs (Virtual Ledger)
  # Actual GCC only required for player-facing transactions
end
```

### Business Logic

**Player-to-Player Transactions:**
- ✅ Real GCC transfers
- ❌ No overdraft allowed
- Balances must be non-negative

**NPC-to-NPC Transactions (Virtual Ledger):**
- ✅ Virtual accounting (can go negative)
- ✅ Overdraft allowed
- No actual GCC movement
- Example: LDC → Subcontractor → Supplier chain

**Player-to-NPC / NPC-to-Player:**
- Real GCC on player side (enforced balance)
- Virtual ledger on NPC side (can overdraft)
- Example: Player sells to LDC (gets GCC), LDC pays with virtual ledger

### NPC Organization Types

**Always NPCs:**
- `development_corporation` - LDC, MTA (by default)

**Can be NPCs (with flag):**
- `corporation` - Set `operational_data: { 'is_npc' => true }`
- `consortium` - Set `operational_data: { 'is_npc' => true }`

**Never NPCs:**
- Player-owned organizations (always use real GCC)

### Use Cases

1. **Development Corps Internal Trade:**
   - LDC pays subcontractor for construction
   - Subcontractor buys materials from supplier
   - All on virtual ledger until player involvement

2. **Mission Payouts:**
   - LDC pays player in real GCC (LCAS mints new GCC)
   - LDC's virtual balance goes negative
   - Balanced by resource sales from players

3. **Consortium Operations:**
   - Consortium members settle internal accounts
   - Virtual until dividends paid to players

---

## Currency System

### GCC (Galactic Credit Currency)

**Characteristics:**
- Primary player-facing currency
- Initially coupled to USD for bootstrap
- Eventually decouples as economy matures
- Minted by Lunar Currency Authority Satellite (LCAS)

**Supply Model:**
- 80% hard cap for scarcity
- 20% controlled minting reserve for flexibility
- Crisis response capability

**Governance:**
- LDC sets transaction fees
- Block rewards for infrastructure
- Player influence via reputation/voting

### USD (United States Dollar)

**Usage:**
- Restricted to NPC corp-to-corp transactions
- Earth imports from player requests
- LDC maintains USD reserves

**Flow:**
1. Player pays GCC to LDC for Earth import
2. LDC uses USD reserves to procure goods
3. Goods delivered to player

---

## Economic Priority System

AI Manager decision flow for material sourcing:

### Priority Hierarchy

1. **Player Market (GCC)** - Always try players first
   - Post buy orders on marketplace
   - Wait for player sellers
   - Maximizes player engagement

2. **NPC Trade (Virtual Ledger)** - If no players available
   - Trade with NPC organizations
   - Virtual accounting (no actual GCC)
   - Faster but less engaging

3. **Earth Import (USD)** - Last resort only
   - Request from LDC Earth reserves
   - Expensive and slow
   - Discourages over-reliance on Earth

### Timeout Logic

- Wait 24-48 hours for player market response
- Escalate to NPC trade if timeout
- Final fallback to Earth import
- Performance metrics track self-sufficiency

---

## GCC Faucets and Sinks

### Faucets (GCC Creation)

**LCAS Minting:**
- Controlled minting for LDC resource budget
- Mission payouts to players
- Guaranteed buy orders for lunar resources

**Player Activities:**
- Resource extraction rewards
- Mission completion bonuses
- Contract fulfillment payments

### Sinks (GCC Destruction)

**LDC Facilities:**
- Reprocessing fees
- Manufacturing service charges
- Base upkeep costs

**Trade & Import:**
- Import duties for Earth goods
- Transaction fees on marketplace
- Consortium membership dues

---

## Currency Precision Standards

The financial system uses different decimal precision levels based on currency type and use case:

### GCC (Galactic Credit Currency)
- **Precision**: 15 digits total, 8 decimal places (`decimal(15, 8)`)
- **Range**: 0.00000001 to 9999999.99999999 GCC
- **Rationale**: Cryptocurrency-style precision for micro-transactions
- **Use Cases**:
  - Manufacturing material costs (fractional component pricing)
  - Energy trading (kWh micro-billing)
  - Cargo freight rates (per-kg fractional charges)
  - AI NPC trading (high-volume low-value transactions)
  - Future expansion: micro-transaction game mechanics

### USD (United States Dollar)
- **Precision**: 15 digits total, 2 decimal places (`decimal(15, 2)`)
- **Range**: 0.01 to 9999999999999.99 USD
- **Rationale**: Standard fiat currency precision (cents)
- **Use Cases**:
  - Earth import/export transactions
  - Real-world economic modeling
  - Campaign storyline Earth-Mars trade

### Database Schema
```ruby
# transactions table
t.decimal :amount, precision: 15, scale: 8  # GCC default
t.string :currency, default: 'GCC'         # GCC or USD

# accounts table
t.decimal :balance, precision: 20, scale: 8  # GCC default (larger for accumulation)
```

### Migration History
- **2024-09-15**: Initial financial system created with scale: 2 (standard currency)
- **2026-01-16**: Increased to scale: 8 for GCC micro-transaction support

---

## Related Documentation

- [Economic Systems (Storyline)](../storyline/07_economic_systems.md) - High-level economic overview
- [Organizations System](./organizations_system.md) - Organization types and NPC flags
- [AI Intelligence](../storyline/06_ai_intelligence.md) - AI Manager decision logic
