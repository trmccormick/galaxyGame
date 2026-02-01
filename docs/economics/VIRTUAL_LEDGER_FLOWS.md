# Virtual Ledger Transaction Flows

## Overview

The Virtual Ledger enables complex NPC-to-NPC economic interactions without depleting player-accessible GCC pools. This document details when to use Virtual Ledger vs real GCC transactions, debt reconciliation mechanics, and solvency thresholds.

## Transaction Flow Examples

### Example 1: NPC Supply Chain (Virtual Ledger)
**Scenario**: Automated harvester delivers Titan gases to Luna when GCC reserves are low.

**Flow**:
1. **Delivery**: AstroLift harvester arrives at Luna with raw gases
2. **Virtual Payment**: Luna pays AstroLift on Virtual Ledger (GCC scarce)
   ```ruby
   luna_virtual = Account.find_for_entity(luna, :virtual_ledger)
   astrolift_virtual = Account.find_for_entity(astrolift, :virtual_ledger)
   luna_virtual.transfer(50000, astrolift_virtual, "Gas delivery payment")
   ```
3. **Service Exchange**: AstroLift receives maintenance/refueling services
4. **Virtual Offset**: Luna charges AstroLift on Virtual Ledger (net position update)
   ```ruby
   astrolift_virtual.transfer(15000, luna_virtual, "Maintenance services")
   # Net: Luna owes AstroLift 35,000 virtual credits
   ```

**Resolution**: When GCC becomes available, Virtual Ledger obligations settle with real currency.

### Example 2: Construction Contract (Mixed Flow)
**Scenario**: MDC contracts with AstroLift for Mars orbital station construction.

**Flow**:
1. **Advance Payment**: MDC pays 30% advance in GCC (available reserves)
   ```ruby
   mdc_gcc = Account.find_for_entity(mdc, :gcc)
   astrolift_gcc = Account.find_for_entity(astrolift, :gcc)
   mdc_gcc.transfer(30000, astrolift_gcc, "Construction advance")
   ```
2. **Milestone Payments**: Remaining 70% paid via Virtual Ledger obligations
   ```ruby
   mdc_virtual = Account.find_for_entity(mdc, :virtual_ledger)
   astrolift_virtual = Account.find_for_entity(astrolift, :virtual_ledger)
   mdc_virtual.transfer(70000, astrolift_virtual, "Milestone obligations")
   ```
3. **Completion Settlement**: Virtual obligations converted to GCC upon delivery

### Example 3: Resource Shortage Crisis (Virtual Ledger Priority)
**Scenario**: Emergency oxygen shortage at Mars colony during dust storm.

**Flow**:
1. **Crisis Declaration**: System flags emergency resource priority
2. **Virtual Procurement**: Colony procures oxygen via Virtual Ledger (no GCC delay)
   ```ruby
   colony_virtual = Account.find_for_entity(colony, :virtual_ledger)
   supplier_virtual = Account.find_for_entity(supplier, :virtual_ledger)
   colony_virtual.transfer(100000, supplier_virtual, "Emergency oxygen")
   ```
3. **GCC Settlement**: Emergency funds allocated post-crisis for settlement

## When to Use Virtual Ledger vs GCC

### Virtual Ledger Usage Criteria
**Primary Conditions**:
- **NPC-to-NPC Transactions**: Both parties are NPCs with overdraft capability
- **GCC Scarcity**: Available GCC reserves below operational threshold (20% of requirements)
- **Deferred Settlement**: Payment timing allows for GCC availability later
- **Economic Simulation**: Transaction supports complex NPC relationship modeling

**Specific Scenarios**:
- **Routine Supply Chains**: Regular resource deliveries between settlements
- **Service Exchanges**: Maintenance, refueling, and support services
- **Contract Advances**: Upfront payments for long-term projects
- **Resource Bartering**: Direct exchange of goods without currency transfer

### GCC Usage Criteria
**Primary Conditions**:
- **Player Involvement**: Any transaction involving player accounts
- **Sufficient Reserves**: Entity has adequate GCC without depleting critical reserves
- **Immediate Settlement**: Transaction requires instant finality
- **Priority Operations**: Emergency or time-critical activities

**Specific Scenarios**:
- **Player Contracts**: All player mission and contract payments
- **Market Purchases**: Player buying from NPC vendors
- **Emergency Supplies**: Critical resource acquisitions
- **Bond Redemptions**: Debt instrument settlements

### Decision Algorithm
```ruby
def choose_transaction_method(buyer, seller, amount)
  # Players always use real GCC
  return :gcc if buyer.is_player? || seller.is_player?

  # Check GCC availability (buyer perspective)
  gcc_available = buyer.gcc_balance
  reserve_threshold = buyer.operational_reserves * 0.2

  if gcc_available >= amount + reserve_threshold
    return :gcc
  else
    return :virtual_ledger
  end
end
```

## Debt Reconciliation Mechanics

### Automatic Reconciliation Triggers
**GCC Availability**:
- Entity GCC balance exceeds Virtual Ledger obligations by 25%
- Triggers automatic settlement of outstanding debts

**Contract Completion**:
- Project milestones achieved trigger proportional debt settlement
- Final delivery converts all Virtual Ledger obligations to GCC

**Periodic Settlement**:
- Monthly reconciliation cycle settles debts where possible
- Priority given to high-value or long-standing obligations

### Manual Reconciliation Options
**Asset Swaps**:
```ruby
# Colony swaps regolith for water rights
colony_virtual.transfer(50000, supplier_virtual, "Regolith delivery")
supplier_virtual.transfer(50000, colony_virtual, "Water rights transfer")
# Net zero - obligations offset without currency
```

**Debt Restructuring**:
```ruby
# Convert Virtual Ledger debt to formal bond
virtual_debt = colony.virtual_ledger_balance
bond = Bond.create!(
  issuer: colony,
  holder: creditor,
  amount: virtual_debt,
  denomination: :gcc
)
# Virtual obligation becomes formal debt instrument
```

**Bankruptcy Proceedings**:
- Entities with Virtual Ledger debt > 200% of assets enter restructuring
- Assets liquidated, debts forgiven or converted to equity stakes

### Reconciliation Priority
1. **Critical Operations**: Emergency supplies and essential services
2. **High-Value Contracts**: Large construction or infrastructure projects
3. **Long-Standing Debts**: Obligations older than 90 days
4. **Small Balances**: Debts under 1,000 GCC cleared opportunistically

## Solvency Thresholds

### Individual Entity Thresholds
**GCC Reserve Requirements**:
- **Operational Reserve**: 20% of monthly operational costs
- **Contingency Reserve**: 10% of annual budget
- **Strategic Reserve**: 5% of total assets

**Virtual Ledger Limits**:
- **Overdraft Cap**: Maximum 50% of entity asset value
- **Monthly Limit**: Maximum 25% of monthly revenue in new obligations
- **Concentration Limit**: No single creditor > 30% of total obligations

### System-Wide Thresholds
**GCC Money Supply**:
- **Inflation Control**: GCC supply growth limited to 5% annually
- **Reserve Requirements**: LDC maintains 15% of total GCC supply as reserves
- **Burn Mechanisms**: GCC removed through Earth exports and operational losses

**Virtual Ledger System Health**:
- **Total Overdraft Limit**: System-wide virtual debt < 25% of GCC money supply
- **Reconciliation Rate**: Minimum 70% of virtual obligations reconciled monthly
- **Default Rate**: Maximum 2% of virtual obligations result in defaults

### Monitoring and Alerts
**Entity-Level Alerts**:
- **Reserve Warning**: GCC reserves drop below 25% threshold
- **Overdraft Alert**: Virtual debt exceeds 40% of assets
- **Reconciliation Delay**: Outstanding obligations > 60 days

**System-Level Monitoring**:
- **GCC Velocity**: Rate of GCC circulation through economy
- **Virtual Debt Ratio**: Virtual obligations as percentage of economic activity
- **Reconciliation Efficiency**: Percentage of virtual debt converted to GCC

### Crisis Intervention
**Economic Stabilization**:
- **LDC Intervention**: LDC can issue emergency GCC for critical settlements
- **Debt Moratorium**: Temporary suspension of Virtual Ledger interest accrual
- **Asset Liquidation**: Forced sale of non-essential assets to generate GCC

**Recovery Mechanisms**:
- **Debt Forgiveness**: Partial forgiveness for entities in recovery
- **Reinvestment Grants**: USD grants converted to GCC for rebuilding
- **Priority Contracts**: Emergency contracts prioritized for affected entities</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/economics/VIRTUAL_LEDGER_FLOWS.md