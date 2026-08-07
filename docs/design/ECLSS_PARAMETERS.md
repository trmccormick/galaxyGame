# ECLSS_PARAMETERS.md

## Overview
This document defines the core constants, formulas, and baseline parameters for the Environmental Control and Life Support System (ECLSS) in *Galaxy Game*. It converts real-world spaceflight operational metrics into game engine variables that drive commodity consumption, structural decay, crew health penalties, and emergency response thresholds. Reference this document when implementing backend tick processors, tuning station maintenance sinks, or balancing life support module upgrades.

## Source Basis
Parameters in this document are derived directly from empirical telemetry and operational data from NASA and ISS ECLSS subsystems. Key source baselines include ISS Brine Processor Assembly performance metrics, structural micro-leak tracking across module joints, microgravity human physiological degradation studies, and standard orbital emergency resupply protocols.

## System Formulas & Mathematical Models

### 1. Water Recycling and Compound Loss
The water recovery loop models distillation and catalytic processing. A hard efficiency ceiling guarantees that habitats cannot function as perpetual closed loops, driving ongoing market demand for raw ice and volatile imports.

Daily Water Loss (kg) = (Crew Count * Daily Consumption per Crew) * (1 - Module Efficiency)

* **Standard Crew Water Intake:** 3.5 kg/person/day (hydration, food rehydration, basic hygiene).
* **Compound Volume Decay over N Cycles:** Remaining Water = Initial Volume * (Efficiency)^N

### 2. Micro-Leaks and Thermal Expansion Decay
Atmospheric leakage accounts for passive gas loss through hull welds, seals, and airlock cycles. The loss rate scales with exposed surface area and is multiplied by thermal expansion stress caused by direct solar exposure (180°C temperature deltas).

Daily Atmospheric Loss (kg) = (Base Leak Rate / 7) * (Exposed Surface Area / 100) * Thermal Multiplier

* **Atmospheric Composition Drain:** 78% N2, 21% O2, 1% Trace Gases.
* **Thermal Mitigation:** Sub-surface or regolith-shielded habitats set the Thermal Multiplier to 1.0 due to subterranean temperature stabilization.

### 3. Microgravity Physiological Degradation
Crew members stationed in environments below 0.9g experience progressive physical degradation unless countermeasures or rotating habitats are utilized.

Daily Crew Health Decay = (0.01 / 30) * (1.0 - Effective g-force)

* At 0g, crew health/efficiency degrades by 1% per 30-day period (0.033% per day).
* Medical commodity consumption (e.g., `CalciumSupplements`, `Medkits`) doubles when Effective g-force < 0.1.

---

## Game Parameters / Constants

| Constant Name | Value | Source | Engine Notes |
| :--- | :--- | :--- | :--- |
| `BASE_WATER_RECOVERY_EFFICIENCY` | `0.98` | ISS Brine Processor | Top-tier mechanical recycling limit |
| `LOW_TIER_WATER_EFFICIENCY` | `0.93` | Legacy ISS Assembly | Un-upgraded or damaged module baseline |
| `CREW_WATER_DAILY_KG` | `3.5` | NASA Bioastronautics | Per-capita daily metabolic requirement |
| `BASE_MICRO_LEAK_KG_PER_WEEK` | `0.4536` | ISS ~1mm Leak Data | Baseline loss (1 lb/week) per 100 m^2 hull |
| `THERMAL_CYCLING_MULTIPLIER` | `1.8` | Orbital Stress Data | Applied to unshielded exterior hulls |
| `REGOLITH_SHIELD_MULTIPLIER` | `1.0` | Subsurface Thermal Data | Applied when regolith depth >= 3.0m |
| `ZERO_G_BONE_LOSS_PER_MONTH` | `0.01` | NASA Space Physiology | 1% skeletal density loss per 30 days |
| `CRITICAL_BUFFER_THRESHOLD_DAYS`| `14` | ISS Resupply Timelines | Triggers high-priority market buy orders |
| `EMERGENCY_BUFFER_THRESHOLD_DAYS`| `3` | ISS Emergency Protocols | Triggers morale collapse and health decay |

---

## Rails Implementation Notes

This document directly impacts the background tick processing engines and resource accounting logic.

* **Affected Models:** `HabitationNode`, `ResourceBuffer`, `InstalledModule`, `CrewGroup`.
* **Primary Service:** `ProcessEclssTickService`.

```ruby
class ProcessEclssTickService
  BASE_WATER_ECLSS_EFFICIENCY = 0.98
  MICRO_LEAK_KG_PER_WEEK      = 0.453592 # 1 lb per week per 100m^2
  BONE_DENSITY_LOSS_PER_DAY   = 0.01 / 30.0 # 1% loss per month in 0g

  def initialize(habitation_node)
    @node = habitation_node
    @buffer = habitation_node.resource_buffer
  end

  def call
    ActiveRecord::Base.transaction do
      process_water_loop!
      process_atmospheric_leaks!
      process_crew_gravity_impact!
      evaluate_emergency_thresholds!
    end
  end

  private

  def process_water_loop!
    water_module = @node.installed_modules.find_by(module_type: 'WaterRecoveryUnit')
    efficiency = water_module&.operational? ? water_module.efficiency : 0.90

    total_water_needed = @node.crew_count * @node.daily_water_per_crew
    water_recycled = total_water_needed * efficiency
    unrecoverable_loss = total_water_needed - water_recycled

    @buffer.deduct!(:purified_water, unrecoverable_loss)
    @buffer.add!(:sludge_waste, unrecoverable_loss)
  end

  def process_atmospheric_leaks!
    thermal_factor = @node.exposed_to_thermal_cycling? ? THERMAL_CYCLING_MULTIPLIER : 1.0
    daily_leak = (MICRO_LEAK_KG_PER_WEEK / 7.0) * (@node.exposed_surface_area / 100.0) * thermal_factor

    # Drains proportionally to standard atmospheric mix
    @buffer.deduct!(:nitrogen, daily_leak * 0.78)
    @buffer.deduct!(:oxygen, daily_leak * 0.21)
  end

  def process_crew_gravity_impact!
    return if @node.effective_g_force >= 0.9

    gravity_deficit = 1.0 - @node.effective_g_force
    degradation = BONE_DENSITY_LOSS_PER_DAY * gravity_deficit

    @node.crew_groups.find_each do |crew|
      crew.degrade_health!(degradation)
      # Increase medical supply consumption under low gravity
      @buffer.deduct!(:medical_supplies, crew.size * 0.05)
    end
  end

  def evaluate_emergency_thresholds!
    days_remaining = @buffer.calculate_days_remaining(:purified_water)
    if days_remaining <= EMERGENCY_BUFFER_THRESHOLD_DAYS
      @node.trigger_emergency_protocol!
    elsif days_remaining <= CRITICAL_BUFFER_THRESHOLD_DAYS
      @node.issue_automated_market_buy_orders!
    end
  end
end
```

---

## Open Design Questions

- **Dynamic Efficiency Degradation:** Should module efficiency decay linearly with usage time, requiring maintenance items (FilterCartridge, CatalyticBed) to maintain the 98% water recovery cap?
- **Airlock Cycle Losses:** Should airlock cycling for EVAs/docking deduct a fixed gas volume per event, or should it be abstracted entirely into the continuous micro-leak rate?

## Related Files

- `ECONOMIC_ENGINE_SURFACE_VS_ORBITAL.md` — Details how resource loss rates fuel orbital market demand.
- `ECLSS_SYSTEM_ARCHITECTURE.md` — Details the 6 functional life support loops and cascading failures.
- `HABITATION_NODE_ARCHITECTURE.md` — Class structures for nodes running the ECLSS tick.
