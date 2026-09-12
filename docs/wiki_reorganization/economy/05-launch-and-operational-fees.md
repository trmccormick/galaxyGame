# Launch & Operational Fees

**Status**: Canonical  
**Last Updated**: 2026-09-11  
**Supersedes**: `LAUNCH_PAYMENT_MODEL.md`, `FISCAL_POLICY_AND_FEES.md`  
**Derived from**: `LAUNCH_PAYMENT_MODEL.md`, `FISCAL_POLICY_AND_FEES.md`

---

## Part A: Launch Payment Model

### 1. Overview

`LaunchPaymentService` handles all launch-related payments: craft construction costs, launch-to-orbit fees, and associated financing (bonds, mixed-currency payments). It is the economic bridge between **craft manufacturing** and **orbital deployment**.

```ruby
# app/services/launch_payment_service.rb
class LaunchPaymentService
  def self.pay_for_launch!(craft:, customer_accounts:, provider_accounts:, launch_config: {})
    # 1. Calculate total mass (base craft + units + modules + rigs)
    # 2. Calculate launch cost from mass × cost_per_kg
    # 3. Process payment across configured currencies/accounts
    # 4. Create bond records if financing is used
  end
end
```

### 2. Payment Flow

```
Player/DC Account ──pay_for_launch!──> LaunchPaymentService
                                              │
                                    ┌────────┼────────┐
                                    │        │        │
                              Construction  Launch   Financing
                              Cost (GCC)   Fee (USD)  (Bond)
                                    │        │        │
                                    ▼        ▼        ▼
                              Provider    Provider   Bond Record
                              Account     Account    (issued/paid/defaulted)
```

### Step-by-Step Flow

1. **Mass Calculation** — `calculate_total_mass(craft, blueprint_service)`
   - Base craft mass from blueprint (`physical_properties.empty_mass_kg`)
   - Units mass from `base_units` associations
   - Modules mass from `base_modules` associations
   - Rigs mass from `base_rigs` associations
   - Total = sum of all components

2. **Launch Cost Calculation** — `calculate_launch_cost(total_mass_kg, launch_config)`
   - Cost per kg from config (e.g., `$544.22/kg`)
   - Currency specified in config (typically USD)
   - Construction cost added if `include_construction: true`

3. **Payment Processing** — `process_payment(...)`
   - Distributes payment across configured currencies
   - Respects `max_percentage` limits per currency
   - Creates bonds if `allow_bonds: true`
   - Transfers funds from customer accounts to provider accounts

### 3. Configuration Structure

```ruby
launch_config: {
  pricing: {
    cost_per_kg: 544.22,           # USD per kg launch cost
    currency: 'USD',                # Pricing currency
    include_construction: true,     # Add construction cost?
    construction_multiplier: 0.8    # Construction cost as fraction of launch
  },
  payment: {
    methods: [
      { currency: 'GCC', max_percentage: 50 },   # Up to 50% from GCC
      { currency: 'USD', max_percentage: 100 }   # Remainder from USD
    ],
    allow_bonds: true,
    bond_terms: {
      maturity_days: 180,
      description: "Launch service bond for satellite deployment"
    }
  }
}
```

### Payment Method Distribution

When multiple payment methods are specified:

```ruby
# Pseudo-logic from LaunchPaymentService.process_payment
remaining = launch_cost[:total]

payment_methods.each do |method|
  max_amount = remaining * (method[:max_percentage] / 100.0)
  available = customer_accounts[method[:currency]].balance
  
  actual_amount = [max_amount, available].min
  remaining -= actual_amount
  
  # Transfer from customer to provider
  customer_accounts[method[:currency]].transfer_funds(
    actual_amount, 
    provider_accounts[method[:currency]],
    "Launch payment for #{craft.name}"
  )
end

# If bonds allowed and remaining > 0:
if remaining > 0 && allow_bonds
  bond = Bond.create!(
    issuer: customer,
    holder: provider,
    currency: Currency.find_by(symbol: 'USD'),
    amount: remaining,
    issued_at: Date.current,
    due_at: Date.current + bond_terms[:maturity_days],
    status: :issued
  )
end
```

### 4. Mass Calculation Details

#### Component Hierarchy

```
Craft (satellite)
├── base_craft (from blueprint)
├── base_units (installed units like solar_panel, ion_thruster)
├── base_modules (installed modules like basic_sensor, power_controller)
└── base_rigs (installed rigs like gpu_coprocessor_rig)
```

#### Mass Lookup Priority

```ruby
# 1. Use craft's built-in method (preferred)
mass = craft.calculate_mass if craft.respond_to?(:calculate_mass)

# 2. Fallback: manual calculation
base_mass = craft.get_base_craft_mass || blueprint.dig('physical_properties', 'empty_mass_kg')
units_mass = craft.base_units.sum { |u| get_unit_mass(u) }
modules_mass = craft.base_modules.sum { |m| get_module_mass(m) }
rigs_mass = craft.base_rigs.sum { |r| get_rig_mass(r) }
total = base_mass + units_mass + modules_mass + rigs_mass
```

#### Blueprint Lookup Fallback Chain

```ruby
def find_unit_blueprint(blueprint_service, unit_type)
  # Try without category first
  bp = blueprint_service.find_blueprint(unit_type)
  return bp if bp
  
  # Try with categories
  %w[units computers energy propulsion storage].each do |cat|
    bp = blueprint_service.find_blueprint(unit_type, cat)
    return bp if bp
  end
  nil
end
```

### 5. GCC Mining Satellite Example

#### Manifest Data

```json
// crypto_mining_satellite_01_manifest_v2.json
{
  "craft": {
    "id": "crypto_mining_satellite",
    "blueprint_id": "generic_satellite"
  },
  "financing": {
    "required": true,
    "amount": 1857986.22,
    "maturity_days": 180,
    "interest_rate": 0.05
  }
}
```

#### Integration Test Payment Call

```ruby
LaunchPaymentService.pay_for_launch!(
  craft: satellite,
  customer_accounts: { 
    gcc: ldc_gcc_account, 
    usd: ldc_usd_account 
  },
  provider_accounts: { 
    gcc: astrolift_gcc_account, 
    usd: astrolift_usd_account 
  },
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

---

## Part B: Fiscal Policy & Fees

### Fee Structure

| Fee Type                | Variable/Rate         | Notes                                                      |
|------------------------|-----------------------|------------------------------------------------------------|
| Transaction Tax        | 0.5%                  | Applied to all market transactions                         |
| Corporate Income Tax   | 10%                   | Applied to corporate profits                               |
| Base Maintenance Cost  | Varies by asset       | See economic_baseline.md for EM/hour breakdown             |
| Sabatier Discount      | Applied to ISRU ops   | Reduces maintenance cost for Sabatier-enabled facilities   |
| Import Duty (Earth)    | Included in EAP       | Paid in GCC, covers USD procurement and logistics          |
| Manufacturing Fees     | Facility-specific     | Sinks for GCC, e.g., LDC reprocessing, shipyard, etc.      |
| Upkeep (Base/Facility) | Asset-specific        | See economic_baseline.md for details                       |

---

### Reserve Requirements (from GUARDRAILS.md §8)
- **LDC Stabilization Reserves:** Lunar Development Corporation must maintain 25% of total GCC supply as stabilization reserves
- **System-wide Liquidity:** Minimum 10% of all currencies held in liquid reserves for market stability
- **Emergency Funds:** 5% of annual GDP allocated to economic crisis response funds

### Development Corporation Structure (from GUARDRAILS.md §8)
- **Non-Profit Status:** Development Corporations (DCs) are non-profit entities formed for each world to establish base-level infrastructure
- **Profit Reinvestment:** DCs generate profits but reinvest them entirely rather than distributing dividends, focusing on expansion rather than profit extraction
- **Inter-DC Interest Exemption:** DCs do not charge interest to other DCs for loans or services, prioritizing collective expansion over individual profit
- **For-Profit NPC Corporations:** AstroLift and other NPC corporations are for-profit entities essential for logistics and specialized services
- **Infrastructure Focus:** DCs prioritize base infrastructure establishment while for-profit NPCs handle commercial logistics and transportation

### Sabatier-Linked Maintenance Discounts
- Apply to facilities using in-situ resource utilization (ISRU) with Sabatier reactors
- Reduces ongoing costs for Sabatier-enabled facilities
- All fees and taxes are subject to AI Manager enforcement and may be adjusted by governance events
