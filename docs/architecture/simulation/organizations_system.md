# Organizations System Architecture

## Organization Types

The Galaxy Game features several organization types that structure the economic and institutional landscape:

### Enum Values
```ruby
enum organization_type: {
  development_corporation: 0,
  corporation: 1,
  consortium: 2,
  government: 3,
  tax_authority: 4,
  insurance_corporation: 5
}
```

### Type Descriptions

**Development Corporation (0)**
- Specialized corporations focused on colony development
- Handle terraforming, infrastructure projects
- Example: Lunar Development Corporation (LDC)
- **Always NPC by default** - Enables virtual ledger trading

**Corporation (1)**
- Standard profit-oriented corporate entities
- Can participate in consortiums as members
- Example: AstroLift (logistics and ship operations)
- **Can be NPC** - Set `operational_data: { 'is_npc' => true }` for virtual ledger

**Consortium (2)**
- Joint ventures formed by multiple corporations for high-capital infrastructure projects
- Can be specialized by purpose (logistics, terraforming, etc.)
- Examples: 
  - Wormhole Transit Consortium (interstellar logistics and infrastructure)
  - TerraGen Terraforming Consortium (planetary development and colonization)
- See: [Consortium Framework](../storyline/03_consortium_framework.md) and [TerraGen Consortium](../storyline/04_terra_gen_consortium.md)

**Government (3)**
- Governmental organizations
- Cannot join consortiums as members
- Tax and regulatory functions

**Tax Authority (4)**
- Specialized government entities handling taxation
- GCC tax collection and enforcement
- Cannot join consortiums

**Insurance Corporation (5)**
- Risk management and insurance services
- Specialized financial instruments

---

## Consortium Membership System

### Model: ConsortiumMembership

**Purpose:** Junction model linking corporations to consortiums with investment tracking.

**Associations:**
```ruby
belongs_to :consortium, class_name: 'Organizations::BaseOrganization'
belongs_to :member, class_name: 'Organizations::BaseOrganization'
```

### Membership Eligibility Rules

**Validation: `member_must_be_corporation`**

Only organizations with `organization_type: 'corporation'` can join a consortium.

**Eligible:**
- ✅ `corporation` (standard corporations)
- ✅ `development_corporation` - **Note:** Currently validation only allows 'corporation' type

**Ineligible:**
- ❌ `government` - Government entities cannot be consortium members
- ❌ `tax_authority` - Tax authorities cannot join consortiums
- ❌ `insurance_corporation` - Currently excluded from consortiums
- ❌ `consortium` - Consortiums cannot join other consortiums

### Business Logic Rationale

Consortiums represent **corporate joint ventures** for high-capital infrastructure projects:

1. **Capital Investment:** Members invest GCC capital to fund construction
2. **Voting Rights:** Each member votes on Route Proposals based on investment
3. **Dividend Returns:** Members receive dividends from transit fees and operations
4. **Risk Sharing:** Corporations share both investment risk and operational rewards

**Why only corporations?**
- Government entities operate on tax revenue, not profit motive
- Tax authorities would create conflicts of interest
- Consortiums need aligned profit incentives for effective governance

**Historical Context:**
The Wormhole Transit Consortium emerged from the "Snap" crisis when AstroLift (logistics) 
and LDC (construction) combined capabilities to rebuild artificial wormhole infrastructure.

### Key Fields

**Tracking Investment:**
- `investment_amount` - GCC capital invested by member
- `ownership_percentage` - Percentage of consortium owned (0-100)
- `voting_power` - Weighted voting power in Route Proposals

**Membership Status:**
- `membership_status` - active, suspended, withdrawn
- `joined_at` - Timestamp of membership creation
- `membership_terms` - JSONB field for custom terms (e.g., `founding_member: true`)

**Scopes:**
```ruby
scope :active, -> { where(membership_status: 'active') }
scope :founding, -> { where("membership_terms->>'founding_member' = 'true'") }
```

---

## NPC Organizations & Virtual Ledger

### NPC Identification

**Method: `BaseOrganization#is_npc?`**

Returns `true` if:
1. Organization type is `development_corporation` (always NPC)
2. OR `operational_data['is_npc']` explicitly set to `true`

**Purpose:** Enables virtual ledger trading (negative balances allowed)

### Virtual Ledger Trading

**What is it?**
NPC-to-NPC transactions using internal accounting instead of actual GCC transfers.

**How it works:**
- NPCs can have negative account balances
- Transactions recorded but no real GCC moves
- Balances settle when players enter the economy

**Why?**
- Realistic NPC economic activity without draining player GCC pools
- Development Corps can pay subcontractors before mission revenue
- Consortium members can settle internal accounts
- LDC can maintain supply chains independent of player timing

**Example Flow:**
```
1. LDC (NPC) → Subcontractor (NPC): -10,000 GCC (virtual)
2. Subcontractor (NPC) → Supplier (NPC): -5,000 GCC (virtual)
3. Player sells to LDC: +20,000 GCC (real)
4. LDC virtual balance: -10,000 + 20,000 = +10,000 GCC
```

### NPC Organization Types

**Always NPCs:**
- ✅ `development_corporation` - Automatic NPC status

**Optional NPCs (requires flag):**
- ⚙️ `corporation` - Must set `operational_data: { 'is_npc' => true }`
- ⚙️ `consortium` - Must set `operational_data: { 'is_npc' => true }`

**Never NPCs:**
- ❌ `government` - Government entities don't use virtual ledger
- ❌ `tax_authority` - Tax collection uses real GCC only
- ❌ Player-owned organizations - Always use real GCC

### Setting NPC Status

**Factory Example:**
```ruby
create(:organization,
  organization_type: :corporation,
  operational_data: { 'is_npc' => true }
)
```

**Development Corps (automatic):**
```ruby
create(:organization,
  organization_type: :development_corporation
  # is_npc? returns true automatically
)
```

See: [Financial System - Virtual Ledger](./financial_system.md#virtual-ledger-system-npc-trading)

---

## Related Documentation

- [Consortium Framework (Storyline)](../storyline/03_consortium_framework.md) - High-level institutional overview
- [Economic Systems](../storyline/07_economic_systems.md) - GCC integration and dividends
- [Crisis Mechanics](../storyline/02_crisis_mechanics.md) - How Snap events drive consortium formation
