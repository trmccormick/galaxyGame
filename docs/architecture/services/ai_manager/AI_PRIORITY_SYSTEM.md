# AI Priority System
## docs/architecture/ai_manager/AI_PRIORITY_SYSTEM.md
## Status: Authoritative — March 15, 2026
## Author: Planning Agent (Claude)


## Overview

The AI Manager uses a heuristic-based priority system for all operational
decisions. Priorities are evaluated in order — critical priorities trigger
immediate action, operational priorities are scheduled, and expansion
priorities only execute when the settlement is stable.

The priority system is implemented in `AIManager::PriorityHeuristic` and
feeds into `AIManager::StrategySelector` and `AIManager::OperationalManager`.

See also:
  financial model, construction priority order, market participation
  resource acquisition decision logic


## Priority Tiers

### Tier 1 — Critical (Immediate Action)
Evaluated every tick. Any critical condition suspends all lower-tier activity
until resolved.

| Priority | Trigger | Action |
|---|---|---|
| `life_support` | O2, water, or food below critical threshold | Emergency procurement or local generation |
| `atmospheric_maintenance` | Gas composition outside safe range | Adjust scrubbers, vents, or production |
| `debt_repayment` | Settlement GCC account negative | Suspend expansion, maximize revenue |
| `greenhouse_failure` | Greenhouse unit offline or critical | Emergency repair dispatch |

### Tier 2 — Operational (Scheduled)
Evaluated each planning cycle. Executed when no Tier 1 conditions are active.

| Priority | Trigger | Action |
|---|---|---|
| `resource_procurement` | Material shortage below operational buffer | Post buy orders, schedule production |
| `construction` | Infrastructure gap identified | Queue construction job |
| `robot_maintenance` | Robot fleet health below threshold | Schedule maintenance cycle |
| `market_participation` | Stale player buy orders profitable to fill | Produce and sell at margin |
| `side_effect_sales` | Excess side-effect resources accumulating | List on market at 5% below import cost |

### Tier 3 — Expansion (Opportunistic)
Only executed when Tier 1 and Tier 2 are fully clear and capital reserve
is sufficient.

| Priority | Trigger | Action |
|---|---|---|
| `settlement_expansion` | Population demand exceeds capacity | Build new habitat units |
| `greenhouse_expansion` | Wellbeing score trending down, capacity available | Build additional greenhouse |
| `infrastructure_upgrade` | Efficiency gains available | Upgrade existing systems |
| `megaproject_initiation` | Capital reserve threshold reached | Begin megastructure planning |

### Tier 4 — Planned (Future Implementation)
These priorities are designed and documented but not yet implemented.

| Priority | Trigger | Action |
|---|---|---|
| `wellbeing_intervention` | Morale score below retention threshold | Schedule greenhouse visits, assess crowding |
| `population_retention` | At-risk population count rising | Address morale contributors |

See `docs/agent/tasks/backlog/population_morale_wellbeing_system.md`


## Priority Checks — Implementation Detail

### `oxygen_critical?`
Returns true when O2 storage is below 15% of target mass.

```ruby
# Checks gas_storage across all settlement structures
# Threshold: 15% of target O2 mass
def oxygen_critical?
  # Aggregate O2 across settlement structures
  total_o2 = settlement.structures.sum do |s|
    s.operational_data&.dig('gas_storage', 'oxygen') || 0
  end
  total_o2 < O2_CRITICAL_THRESHOLD
end
```

### `account_negative?`
Returns true when the settlement's GCC account balance is negative.

```ruby
def account_negative?
  gcc_currency = Financial::Currency.find_by!(symbol: 'GCC')
  account = Financial::Account.find_or_create_for_entity_and_currency(
    accountable_entity: settlement,
    currency: gcc_currency
  )
  account.balance < 0
end
```

**Important:** Always use `find_or_create_for_entity_and_currency` with GCC
currency — not `settlement.account` which is ambiguous in a multi-currency
system. See `docs/agent/tasks/backlog/settlement_gcc_account_convenience_method.md`

### `nitrogen_critical?`
Returns true when N2 storage is below operational threshold.

Note: On bodies where Argon is available locally (Mars: 1.93% atmospheric Ar),
Argon extraction is a valid N2 substitute for human habitat buffer gas.
Plants and biomes still require N2 for nitrogen cycle — Ar cannot substitute
in agricultural modules.

---

## Planet-Aware Priority Logic

The priority system is context-aware. The same condition triggers different
actions depending on the settlement's planetary environment.

### Oxygen Strategy Selection

| Condition | Strategy | Priority |
|---|---|---|
| High atmospheric CO2 (>50%) AND O2 critical | Local electrolysis/photolysis viable | `:local_oxygen_generation` |
| Low atmospheric CO2 (<10%) AND O2 critical | Local generation not viable | `:refill_oxygen` (import) |
| Magnetic field < 0.3 Tesla AND high CO2 | Atmospheric stripping risk — prioritize local | `:local_oxygen_generation` |

**Mars example:** 95.3% CO2 atmosphere → `local_oxygen_generation` priority.
CO2 electrolysis (MOXIE-style) or plant photosynthesis both viable.

**Luna example:** No significant atmosphere → `refill_oxygen` priority.
Must import or produce from regolith water ice electrolysis.

**Procedurally generated bodies:** Evaluated dynamically from atmospheric
composition and magnetic field data at runtime.

### Nitrogen/Buffer Gas Strategy

| Condition | Strategy | Priority |
|---|---|---|
| N2 critical AND Mars-like Ar available | Extract Ar as human buffer substitute | `:local_argon_extraction` |
| N2 critical AND no local source | Import N2 | `:import_nitrogen` |
| Agricultural module needs N2 | Cannot substitute Ar — must import | `:import_nitrogen` |

**Note:** Ar is valid as human habitat buffer gas at correct partial pressure.
Ar is NOT valid for agricultural modules — no nitrogen fixation possible.
Luna has no local N2 or Ar source — permanent N2 import dependency.

### Methane Synthesis Opportunity

When excess CO and H2 are present (Sabatier reaction feedstocks):

```
CO + 3H2 → CH4 + H2O  (Sabatier)
```

Priority: `:methane_synthesis`
- Triggered when CO inventory > threshold AND H2 inventory > threshold
- Methane is fuel — valuable for logistics and heating
- Converts waste gases into usable resource
- AI Manager evaluates market price before triggering

---

## Financial Health & Priority Escalation

### Account Monitoring
The settlement GCC account is monitored every planning cycle.
`account_negative?` triggers `debt_repayment` priority immediately.

When `debt_repayment` is active:
- All expansion (Tier 3) suspended
- Market participation maximized (fill stale orders, sell excess)
- Construction paused unless life-critical
- Fee schedule reviewed upward by AI Manager
- Robot workforce redirected to revenue-generating activities

### DC Financial Model Connection
Development Corporations are non-profit but must cover operating costs.
A negative account means the virtual ledger buffer is exhausted — genuine
financial distress. LDC sponsorship can provide emergency capital for
child DCs in distress.

See `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md`
Section 2 for full DC financial model.

---

## Storage Capacity Priority

When settlement tank farm capacity drops below 10%:

Priority: `:construct_storage_module`

This prevents:
- Production shutdowns when storage is full
- Loss of valuable side-effect resources (nowhere to store them)
- Life support degradation (O2/N2 tanks full, can't produce more)

Storage construction is Tier 2 operational — higher priority than general
expansion but lower than life support and debt repayment.

---

## Decision Flow

```
Every tick:
  Evaluate Tier 1 (Critical)
  ├── oxygen_critical? → local_oxygen_generation OR refill_oxygen
  ├── atmospheric_maintenance? → adjust composition
  ├── account_negative? → debt_repayment
  └── greenhouse_failure? → emergency_repair

  If no Tier 1 active:
  Evaluate Tier 2 (Operational)
  ├── resource_shortage? → procurement
  ├── storage_critical? → construct_storage_module
  ├── robot_health_low? → robot_maintenance
  ├── stale_buy_orders_profitable? → market_participation
  ├── methane_synthesis_available? → methane_synthesis
  └── excess_resources? → side_effect_sales

  If no Tier 1 or Tier 2 active:
  Evaluate Tier 3 (Expansion)
  ├── population_demand? → settlement_expansion
  ├── wellbeing_trending_down? → greenhouse_expansion
  └── capital_reserve_sufficient? → infrastructure_upgrade OR megaproject
```

---

## `get_priorities` Return Values

`AIManager::PriorityHeuristic#get_priorities` returns an array of symbols
representing all currently active priorities, ordered by tier:

```ruby
# Example return values
[]                                    # All clear
[:refill_oxygen]                      # O2 critical, standard body
[:local_oxygen_generation]            # O2 critical, high CO2 body
[:debt_repayment]                     # Account negative
[:refill_oxygen, :debt_repayment]     # Both critical simultaneously
[:local_argon_extraction]             # N2 critical, Ar available
[:methane_synthesis]                  # Excess CO + H2
[:construct_storage_module]           # Tank farm below 10%
```

---

## Implementation Files

| File | Purpose |
|---|---|
| `app/services/ai_manager/priority_heuristic.rb` | Priority check methods |
| `app/services/ai_manager/strategy_selector.rb` | Strategy selection from priorities |
| `app/services/ai_manager/operational_manager.rb` | Core AI decision engine |
| `app/services/ai_manager/performance_tracker.rb` | Decision outcome tracking |
| `spec/services/ai_manager/priority_heuristic_spec.rb` | Priority system tests |

---

## Known Spec Issues (as of March 15, 2026)

`priority_heuristic_spec.rb` has 12 failures due to `settlement.account`
returning nil — same pattern as assembly_service_spec fix. Fix task:
`docs/agent/tasks/backlog/priority_heuristic_spec_account_fix.md`

The spec itself is correct and comprehensive — it tests planet-aware oxygen
strategy, argon extraction, methane synthesis, and storage capacity priorities.
Fix is mechanical account lookup pattern only.

---

## Future Priority Tiers (Planned)

### Wellbeing System (Tier 4)
When `population_morale_wellbeing_system.md` is implemented:
- `morale_critical?` — morale below retention threshold
- `wellbeing_intervention` — schedule greenhouse visits, food variety check
- `population_retention` — address at-risk population

Feeds from `wellbeing_output` block in unit operational data v1.3+.
See `docs/agent/tasks/backlog/population_morale_wellbeing_system.md`

### Inter-DC Alert System (Planned)
When inter-DC sponsorship is active:
- LDC monitors child DC account health
- Distress signal triggers emergency capital transfer
- Prevents cascade failure in expanding network
